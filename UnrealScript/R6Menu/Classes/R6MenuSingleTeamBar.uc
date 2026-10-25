//=============================================================================
//  R6MenuSingleTeamBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/18 * Created by Alexandre Dionne
//=============================================================================


class R6MenuSingleTeamBar extends UWindowDialogControl;

const C_fTEAMBAR_ICON_HEIGHT = 16;
const C_fTEAMBAR_MISSIONTIME_HEIGHT = 14;
const C_fTEAMBAR_TOTALS_HEIGHT = 15;
const C_fXICONS_START_POS    = 0;

var INT m_IBorderVOffset;

var R6WindowTextLabel           m_BottomTitle, m_TimeMissionTitle, m_TimeMissionValue, m_KillLabel, m_EfficiencyLabel, m_RoundsFiredLabel, m_RoundsTakenLabel;
var FLOAT                       m_fBottomTitleWidth;

var INT                         m_iTotalNeutralized;              // Team total Number of kills
var INT                         m_iTotalEfficiency;         // Team total Efficiency (hits/shot)
var INT                         m_iTotalRoundsFired;        // Team total Rounds fired (Bullets shot by the player)
var INT                         m_iTotalRoundsTaken;        // Team total Rounds taken (Rounds that hits the player)

var R6WindowSimpleIGPlayerListBox m_IGPlayerInfoListBox;      // List of players with scroll bar

var bool                        m_bDrawBorders;
var bool                        m_bDrawTotalsShading;

var Texture                     m_TIcon;
var Texture                     m_TBorder, m_THighLight;
var Region                      m_RBorder, m_RHighLight;

var FLOAT                       m_fTeamcolorWidth, m_fRainbowWidth, m_fHealthWidth, m_fSkullWidth, 
                                m_fEfficiencyWidth, m_fShotsWidth, m_fHitsWidth;

var INT                         m_INameTextPadding; //Put some padding at the left of the player name
var INT                         m_IFirstItempYOffset;

var bool                        bShowLog;


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    local INT IDblOffset;   

    IDblOffset = 2 * m_IBorderVOffset;

    //mask == opaque (joueur selectionne) sinon alpha 
    

    if(m_bDrawTotalsShading)
    {
        //bg shading
        R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, 0, C_fTEAMBAR_ICON_HEIGHT, WinWidth, WinHeight - C_fTEAMBAR_ICON_HEIGHT);
    }

    C.Style = ERenderStyle.STY_Alpha;    

    DrawInGameSingleTeamBar(C, C_fXICONS_START_POS, 1, C_fTEAMBAR_ICON_HEIGHT);
    DrawInGameSingleTeamBarUpBorder( C, m_IBorderVOffset, 0, WinWidth - IDblOffset, C_fTEAMBAR_ICON_HEIGHT); // 2 is the frame border 
    DrawInGameSingleTeamBarMiddleBorder( C, m_IBorderVOffset, WinHeight - C_fTEAMBAR_TOTALS_HEIGHT - C_fTEAMBAR_MISSIONTIME_HEIGHT, WinWidth - IDblOffset, C_fTEAMBAR_TOTALS_HEIGHT);
    DrawInGameSingleTeamBarDownBorder( C, m_IBorderVOffset, WinHeight - C_fTEAMBAR_MISSIONTIME_HEIGHT, WinWidth - IDblOffset, C_fTEAMBAR_MISSIONTIME_HEIGHT); 

           
    if(m_bDrawBorders)
        DrawSimpleBorder(C);   
    


}


function Created()
{
    local FLOAT YLabelPos, fXOffset;

    m_BorderColor = Root.Colors.GrayLight;

	fXOffset = 4;
    YLabelPos = WinHeight - C_fTEAMBAR_MISSIONTIME_HEIGHT;

    m_TimeMissionTitle       = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, YLabelPos, m_fBottomTitleWidth, C_fTEAMBAR_MISSIONTIME_HEIGHT, self));    
    m_TimeMissionTitle.Align          = TA_CENTER;
    m_TimeMissionTitle.m_Font         = Root.Fonts[F_SmallTitle];
    m_TimeMissionTitle.TextColor      = Root.Colors.BlueLight;    
    m_TimeMissionTitle.m_fLMarge      = fXOffset;
    m_TimeMissionTitle.SetNewText(Localize("DebriefingMenu","MissionTime","R6Menu"),true);
    m_TimeMissionTitle.m_bDrawBorders = false;

    m_TimeMissionValue       = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_TimeMissionTitle.WinWidth, YLabelPos, WinWidth - m_TimeMissionTitle.WinWidth, C_fTEAMBAR_MISSIONTIME_HEIGHT, self));    
    m_TimeMissionValue.Align          = TA_CENTER;
    m_TimeMissionValue.m_Font         = Root.Fonts[F_SmallTitle];
    m_TimeMissionValue.TextColor      = Root.Colors.White;
    m_TimeMissionValue.m_bDrawBorders = false;    
	
	YLabelPos -= C_fTEAMBAR_TOTALS_HEIGHT;
    m_BottomTitle       = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, YLabelPos, m_fBottomTitleWidth, C_fTEAMBAR_TOTALS_HEIGHT, self));
    m_BottomTitle.Align          = TA_CENTER;
    m_BottomTitle.m_Font         = Root.Fonts[F_SmallTitle];
    m_BottomTitle.TextColor      = Root.Colors.BlueLight;
    m_BottomTitle.m_fLMarge      = fXOffset;
    m_BottomTitle.SetNewText(Localize("MPInGame","TotalTeamStatus","R6Menu"),true);
    m_BottomTitle.m_bDrawBorders = false;

    m_KillLabel         = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_fBottomTitleWidth, YLabelPos, m_fSkullWidth, C_fTEAMBAR_TOTALS_HEIGHT, self));
    m_KillLabel.Text            = "00";
    m_KillLabel.Align           = TA_CENTER;
    m_KillLabel.m_Font          = Root.Fonts[F_SmallTitle];
    m_KillLabel.TextColor       = Root.Colors.White;
    m_KillLabel.m_bDrawBorders  = false;

    m_EfficiencyLabel   = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_KillLabel.WinLeft + m_KillLabel.WinWidth, YLabelPos, m_fEfficiencyWidth, C_fTEAMBAR_TOTALS_HEIGHT, self));
    m_EfficiencyLabel.Text      = "00";
    m_EfficiencyLabel.Align     = TA_CENTER;
    m_EfficiencyLabel.m_Font    = Root.Fonts[F_SmallTitle];
    m_EfficiencyLabel.TextColor = Root.Colors.White;
    m_EfficiencyLabel.m_bDrawBorders = false;

    m_RoundsFiredLabel  = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_EfficiencyLabel.WinLeft + m_EfficiencyLabel.WinWidth, YLabelPos, m_fShotsWidth, C_fTEAMBAR_TOTALS_HEIGHT, self));
    m_RoundsFiredLabel.Text         = "00";
    m_RoundsFiredLabel.Align        = TA_CENTER;
    m_RoundsFiredLabel.m_Font       = Root.Fonts[F_SmallTitle];
    m_RoundsFiredLabel.TextColor    = Root.Colors.White;
    m_RoundsFiredLabel.m_bDrawBorders = false;

    m_RoundsTakenLabel  = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RoundsFiredLabel.WinLeft + m_RoundsFiredLabel.WinWidth, YLabelPos, m_fHitsWidth, C_fTEAMBAR_TOTALS_HEIGHT, self));
    m_RoundsTakenLabel.Text         = "00";
    m_RoundsTakenLabel.Align        = TA_CENTER;
    m_RoundsTakenLabel.m_Font       = Root.Fonts[F_SmallTitle];
    m_RoundsTakenLabel.TextColor    = Root.Colors.White;
    m_RoundsTakenLabel.m_bDrawBorders = false;

    CreateIGPListBox();

}


function DrawInGameSingleTeamBarMiddleBorder( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    
    
    //Top
    DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, m_RBorder.H , 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);

    //Middle Line
    DrawStretchedTextureSegment(C, m_fBottomTitleWidth, _fY, m_RBorder.W, _fHeight, 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);

    //Bottom
    DrawStretchedTextureSegment(C, _fX, _fY+_fHeight - m_RBorder.H, _fWidth, m_RBorder.H , 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);
    

}

function DrawInGameSingleTeamBarDownBorder( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);    
    
    //Middle Line
    DrawStretchedTextureSegment(C, m_fBottomTitleWidth, _fY, m_RBorder.W, _fHeight, 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);

    if(!m_bDrawBorders)
    {
        //Bottom
        DrawStretchedTextureSegment(C, _fX, _fY+_fHeight - m_RBorder.H, _fWidth, m_RBorder.H , 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);
    }  

}

function DrawInGameSingleTeamBarUpBorder( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    //Top
    DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, m_BorderTextureRegion.H, 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Bottom
    DrawStretchedTextureSegment(C, _fX, _fY + _fHeight, _fWidth, m_BorderTextureRegion.H , 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
}



function DrawInGameSingleTeamBar( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fHeight)
{
    local FLOAT fXOffset, fWidth;
    local Region RIconRegion, RIconToDraw;
    local R6MenuRSLookAndFeel R6LAF;

    R6LAF = R6MenuRSLookAndFeel(LookAndFeel);
    C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);    
    
    // draw the Team color icon
    RIconToDraw.X = 52;
    RIconToDraw.Y = 52;
    RIconToDraw.W = 12;
    RIconToDraw.H = 12;
    fXOffset      = _fX;
    fWidth        = m_fTeamcolorWidth;

    RIconRegion = R6LAF.CenterIconInBox( fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                      RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);

    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    // draw separation
    DrawStretchedTextureSegment(C, fXOffset + fWidth, _fY, m_RBorder.W, _fHeight, 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);
    
    C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);    
    // draw the Rainbow Operative icon
    RIconToDraw.X = 0;
    RIconToDraw.Y = 0;
    RIconToDraw.W = 13;
    RIconToDraw.H = 14;
    fXOffset      = fXOffset + fWidth;
    fWidth        = m_fRainbowWidth;

    RIconRegion = R6LAF.CenterIconInBox( fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                      RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);

    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    // draw separation
    DrawStretchedTextureSegment(C, fXOffset + fWidth, _fY, m_RBorder.W, _fHeight, 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);
     
    C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);    
    // draw the health icon
    RIconToDraw.X = 0;
    RIconToDraw.Y = 28;
    RIconToDraw.W = 13;
    RIconToDraw.H = 14;
    fXOffset      = fXOffset + fWidth;
    fWidth        = m_fHealthWidth;

    RIconRegion = R6LAF.CenterIconInBox( fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                      RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);

    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    // draw separation
    DrawStretchedTextureSegment(C, fXOffset + fWidth, _fY, m_RBorder.W, _fHeight, 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);
        
    C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);    
    // draw the kill icon
	RIconToDraw.X = 14;
	RIconToDraw.Y = 0;
	RIconToDraw.W = 13;
	RIconToDraw.H = 14;
    fXOffset      = fXOffset + fWidth;
    fWidth        = m_fSkullWidth;

    RIconRegion = R6LAF.CenterIconInBox( fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                      RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);

    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    // draw separation
    DrawStretchedTextureSegment(C, fXOffset + fWidth, _fY, m_RBorder.W, _fHeight, 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);

    C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);    
    // draw the % icon
    RIconToDraw.X = 28;
    RIconToDraw.Y = 0;
    RIconToDraw.W = 14;
    RIconToDraw.H = 14;
    fXOffset      = fXOffset + fWidth;
    fWidth        = m_fEfficiencyWidth;

    RIconRegion = R6LAF.CenterIconInBox( fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                      RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);
    
    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    // draw separation
    DrawStretchedTextureSegment(C, fXOffset + fWidth, _fY, m_RBorder.W, _fHeight, 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);

    C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);    
    // draw the bullet icon
    RIconToDraw.X = 49;
    RIconToDraw.Y = 14;
    RIconToDraw.W = 7;
    RIconToDraw.H = 14;
    fXOffset      = fXOffset + fWidth;
    fWidth        = m_fShotsWidth;

    RIconRegion = R6LAF.CenterIconInBox( fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                      RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);

    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    // draw separation
    DrawStretchedTextureSegment(C, fXOffset + fWidth, _fY, m_RBorder.W, _fHeight, 
                                     m_RBorder.X, m_RBorder.Y, m_RBorder.W, m_RBorder.H, m_TBorder);

    C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);    
    // draw the target icon
    RIconToDraw.X = 14;
    RIconToDraw.Y = 28;
    RIconToDraw.W = 16;
    RIconToDraw.H = 14;
    fXOffset      = fXOffset + fWidth;
    fWidth        = m_fHitsWidth;

    RIconRegion = R6LAF.CenterIconInBox( fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                      RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);  
    
}


//===============================================================================
// Refresh server info
//===============================================================================
function RefreshTeamBarInfo()
{	
    local R6MissionObjectiveMgr moMgr;    
    local FLOAT fMissionTime;
    
    // playtest log
    local bool          bPlayTestLog;
    local int           i, iRainbowDead, iTerroNeutralized;
    local R6RainbowTeam currentTeam;
    local R6GameInfo    GameInfo;


    m_iTotalNeutralized       = 0;
    m_iTotalEfficiency  = 0;
    m_iTotalRoundsFired = 0;
    m_iTotalRoundsTaken = 0;
    ClearListOfItem();
    
   AddItems( );  

   moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
   
   if(moMgr.m_eMissionObjectiveStatus == eMissionObjStatus_none )
   {
    
        fMissionTime = GetLevel().Level.TimeSeconds - R6GameInfo(GetLevel().Game).m_fRoundStartTime;
   }        
   else
   {    
        bPlayTestLog = true;
        fMissionTime = R6GameInfo(GetLevel().Game).m_fRoundEndTime - R6GameInfo(GetLevel().Game).m_fRoundStartTime;
   }       

    m_TimeMissionValue.SetNewText( class'Actor'.static.ConvertIntTimeToString( fMissionTime), true);
    m_KillLabel.SetNewText(string(m_iTotalNeutralized) , true);
    m_EfficiencyLabel.SetNewText( string(m_iTotalEfficiency) , true);
    m_RoundsFiredLabel.SetNewText( string(m_iTotalRoundsFired) , true);
    m_RoundsTakenLabel.SetNewText( string(m_iTotalRoundsTaken) , true);       

    // todop: needed for how long?
    if ( bPlayTestLog )
    {
        GameInfo = R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game);
        for ( i = 0; i < 3 ; i++ )
        {    
            currentTeam = R6RainbowTeam(GameInfo.GetRainbowTeam(i));

		    if (currentTeam != None)
		    {
                iRainbowDead += currentTeam.m_iMembersLost;
            }
        }
        
        log( "-PLAYTEST- " $R6Console(Root.Console).master.m_StartGameInfo.m_MapName );
        log( "-PLAYTEST- mode                 =" $Root.Console.ViewportOwner.Actor.Level.GetGameTypeClassName( GameInfo.m_szGameTypeFlag )  );
        log( "-PLAYTEST- difficulty level     =" $GameInfo.m_iDiffLevel );
        log( "-PLAYTEST- mission time length  =" $m_TimeMissionValue.Text );
        log( "-PLAYTEST- terro neutralized    =" $m_iTotalNeutralized ); 
        log( "-PLAYTEST- rainbow killed       =" $iRainbowDead );
        log( "-PLAYTEST- nb of retries        =" $R6GameInfo(GetLevel().Game).m_iNbOfRestart); 
    }
    
}



function AddItems()
{
    local R6WindowListIGPlayerInfoItem  NewItem;
	local INT                           i, y;
    local R6RainbowTeam                 currentTeam;
    local R6GameInfo                    GameInfo;



    GameInfo = R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game);
    m_iTotalNeutralized = GameInfo.GetNbTerroNeutralized();
    for ( i = 0; i < 3 ; i++ )
    {    
        currentTeam = R6RainbowTeam(GameInfo.GetRainbowTeam(i));

		if (currentTeam != None)
		{
			for ( y = 0; y < currentTeam.m_iMemberCount + currentTeam.m_iMembersLost; y++)
			{                       

					NewItem = R6WindowListIGPlayerInfoItem(m_IGPlayerInfoListBox.Items.Append(m_IGPlayerInfoListBox.ListClass));

               
					NewItem.m_iRainbowTeam          = i;
					NewItem.stTagCoord[0].fXPos     = 0;
					NewItem.stTagCoord[0].fWidth    = m_fTeamcolorWidth;            

					NewItem.szPlName                = currentTeam.m_Team[y].m_CharacterName ;
					NewItem.stTagCoord[1].fXPos     = NewItem.stTagCoord[0].fXPos + NewItem.stTagCoord[0].fWidth + m_INameTextPadding;
					NewItem.stTagCoord[1].fWidth    = m_fRainbowWidth - m_INameTextPadding;            
                    
                    
					switch(currentTeam.m_Team[y].m_eHealth)
					{
					case HEALTH_Healthy:
						NewItem.eStatus                 = NewItem.ePlStatus.ePlayerStatus_Alive;
						break;
					case HEALTH_Wounded:
						NewItem.eStatus                 = NewItem.ePlStatus.ePlayerStatus_Wounded;
						break;
					case HEALTH_Incapacitated:
                        NewItem.eStatus                 = NewItem.ePlStatus.ePlayerStatus_Incapacitated;
                        break;
					case HEALTH_Dead:
						NewItem.eStatus                 = NewItem.ePlStatus.ePlayerStatus_Dead;
						break;                    
					}
                    

					NewItem.stTagCoord[2].fXPos     = NewItem.stTagCoord[1].fXPos + NewItem.stTagCoord[1].fWidth;
					NewItem.stTagCoord[2].fWidth    = m_fHealthWidth;                

					NewItem.iKills                  = currentTeam.m_Team[y]. m_iKills;
					NewItem.stTagCoord[3].fXPos     = NewItem.stTagCoord[2].fXPos + NewItem.stTagCoord[2].fWidth;
					NewItem.stTagCoord[3].fWidth    = m_fSkullWidth;

					if(currentTeam.m_Team[y].m_iBulletsFired > 0)
						NewItem.iEfficiency             
                            = Min(currentTeam.m_Team[y].m_iBulletsHit / FLOAT(currentTeam.m_Team[y].m_iBulletsFired) * 100, 100);
					else
						NewItem.iEfficiency             
                            = 0;                    

					NewItem.stTagCoord[4].fXPos     = NewItem.stTagCoord[3].fXPos + NewItem.stTagCoord[3].fWidth;
					NewItem.stTagCoord[4].fWidth    = m_fEfficiencyWidth;

					NewItem.iRoundsFired            = currentTeam.m_Team[y].m_iBulletsFired;
					NewItem.stTagCoord[5].fXPos     = NewItem.stTagCoord[4].fXPos + NewItem.stTagCoord[4].fWidth;
					NewItem.stTagCoord[5].fWidth    = m_fShotsWidth;

					NewItem.iRoundsHit              = currentTeam.m_Team[y].m_iBulletsHit;
					NewItem.stTagCoord[6].fXPos     = NewItem.stTagCoord[5].fXPos + NewItem.stTagCoord[5].fWidth;
					NewItem.stTagCoord[6].fWidth    = m_fHitsWidth;  
                    
                    NewItem.m_iOperativeID          = currentTeam.m_Team[y].m_iOperativeID;
                    
					m_iTotalRoundsFired += NewItem.iRoundsFired;
					m_iTotalRoundsTaken += NewItem.iRoundsHit;

                    if(bshowlog)
                    {
                        log("CurrentTeam = " $ CurrentTeam $ " y = " $ y);
                        log("currentTeam.m_Team[y].m_CharacterName"@currentTeam.m_Team[y].m_CharacterName);
                        log("currentTeam.m_Team[y].m_eHealth"@currentTeam.m_Team[y].m_eHealth);
                        log("currentTeam.m_Team[y]. m_iKills"@currentTeam.m_Team[y]. m_iKills);
                        log("currentTeam.m_Team[y].m_iBulletsFired"@currentTeam.m_Team[y].m_iBulletsFired);
                        log("currentTeam.m_Team[y].m_iBulletsHit"@currentTeam.m_Team[y].m_iBulletsHit);
                        log("NewItem.iEfficiency"@NewItem.iEfficiency);
                    }
			}
		}
    }
    
    if(m_iTotalRoundsFired == 0)
        m_iTotalEfficiency = 0;
    else
        m_iTotalEfficiency = Min(m_iTotalRoundsTaken / FLOAT(m_iTotalRoundsFired) * 100, 100);    
}


function Register(UWindowDialogClientWindow	W)
{
	NotifyWindow = W;
	Notify(DE_Created);
    m_IGPlayerInfoListBox.Register(W);
}


function ClearListOfItem()
{
    m_IGPlayerInfoListBox.Items.Clear();
}


//===============================================================================
// Get the total height of the header ALPHA TEAM and TOTAL TEAM STATUS
//===============================================================================
function FLOAT GetPlayerListBorderHeight()
{
    return C_fTEAMBAR_ICON_HEIGHT + m_IFirstItempYOffset + C_fTEAMBAR_MISSIONTIME_HEIGHT + C_fTEAMBAR_TOTALS_HEIGHT;
}


//***************************** INIT SECTION *******************************


function CreateIGPListBox()
{
	
    // Create window for serever list
 	m_IGPlayerInfoListBox = R6WindowSimpleIGPlayerListBox(CreateWindow( class'R6WindowSimpleIGPlayerListBox', 0,  C_fTEAMBAR_ICON_HEIGHT + m_IFirstItempYOffset, WinWidth, WinHeight -  GetPlayerListBorderHeight(), self));
	m_IGPlayerInfoListBox.SetCornerType(No_Borders);


    // TODO might need to add something for specific fonts, textures, etc.

    m_IGPlayerInfoListBox.m_Font = Root.Fonts[F_ListItemBig];

}

function Resize()
{
    m_IGPlayerInfoListBox.WinTop = C_fTEAMBAR_ICON_HEIGHT + m_IFirstItempYOffset;
    m_IGPlayerInfoListBox.SetSize(WinWidth, WinHeight -  GetPlayerListBorderHeight());

	m_TimeMissionTitle.WinWidth	= m_fBottomTitleWidth;
    m_TimeMissionValue.WinLeft  = m_TimeMissionTitle.WinWidth;
    m_TimeMissionValue.WinWidth	= WinWidth - m_TimeMissionTitle.WinWidth;
    m_BottomTitle.WinWidth      = m_fBottomTitleWidth;
    m_KillLabel.WinWidth        = m_fSkullWidth;
    m_KillLabel.WinLeft         = m_BottomTitle.WinLeft + m_BottomTitle.WinWidth;
    m_EfficiencyLabel.WinWidth  = m_fEfficiencyWidth;
    m_EfficiencyLabel.WinLeft   = m_KillLabel.WinLeft + m_KillLabel.WinWidth;
    m_RoundsFiredLabel.WinWidth = m_fShotsWidth;
    m_RoundsFiredLabel.WinLeft  = m_EfficiencyLabel.WinLeft + m_EfficiencyLabel.WinWidth;
    m_RoundsTakenLabel.WinWidth = m_fHitsWidth;
    m_RoundsTakenLabel.WinLeft  = m_RoundsFiredLabel.WinLeft + m_RoundsFiredLabel.WinWidth;

    m_TimeMissionTitle.WinWidth	= m_fBottomTitleWidth;
    m_TimeMissionTitle.m_bRefresh = true;
    m_BottomTitle.WinWidth	= m_fBottomTitleWidth;
    m_BottomTitle.m_bRefresh = true;

}

defaultproperties
{
     m_IBorderVOffset=2
     m_INameTextPadding=2
     m_fBottomTitleWidth=210.000000
     m_fTeamcolorWidth=30.000000
     m_fRainbowWidth=145.000000
     m_fHealthWidth=35.000000
     m_fSkullWidth=50.000000
     m_fEfficiencyWidth=50.000000
     m_fShotsWidth=50.000000
     m_fHitsWidth=50.000000
     m_TIcon=Texture'R6MenuTextures.Credits.TeamBarIcon'
     m_TBorder=Texture'UWindow.WhiteTexture'
     m_THighLight=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RBorder=(W=1,H=1)
     m_RHighLight=(X=75,Y=35,W=1,H=1)
}
