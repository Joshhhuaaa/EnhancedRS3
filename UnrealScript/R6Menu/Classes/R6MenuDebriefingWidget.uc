//=============================================================================
//  R6MenuDebriefingWidget.uc : Menu Poping at the end of the mission
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Alexandre Dionne
//=============================================================================


class R6MenuDebriefingWidget extends R6MenuLaptopWidget;


//Top Labels showing location of the current mission
var R6WindowTextLabel			m_CodeName, 
                                m_DateTime, 
                                m_Location;

//Mission Objectives dimensions 
var FLOAT                       m_fObjHeight;

//Missions Objectives for the current Mission
var R6WindowWrappedTextArea		m_MissionObjectives;


//BIG MISSIN RESULT LABEL AT THE TOP OF THE PAGE
var R6WindowTextLabel           m_MissionResultTitle;
var FLOAT                       m_fMissionResultTitleHeight, m_fMissionResultTitleWidth;
var Texture                     m_TBGMissionResult;
var Region                      m_RBGMissionResult;
var Region						m_RBGExtMissionResult;

//NAV BAR
var R6MenuDebriefNavBar         m_DebriefNavBar;
var FLOAT                       m_fNavAreaY;

var R6MenuSingleTeamBar         m_pR6RainbowTeamBar;   // the rainbows for the mission with their stats
var R6MenuCarreerStats          m_RainbowCarreerStats;
var FLOAT                       m_fPaddingBetween, m_fStatsWidth;

var Array<R6Operative>          m_MissionOperatives;

var BOOL                        m_bReadyShowWindow;
var BOOL                        m_bMissionVictory;
var INT                         m_iCountFrame;
var Sound                       m_sndVictoryMusic;
var Sound                       m_sndLossMusic;

function Created()
{
    local FLOAT    LabelWidth, NavXPos;    
    local FLOAT    fStatsHeight, fStatsWidth;
    

    Super.Created();

    //*************************** Title Labels
	LabelWidth = (m_Right.WinLeft - m_left.WinWidth) /3;    

    // CODE NAME
	m_CodeName = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_left.WinWidth, 
                                                m_Top.WinHeight, 
		                                        LabelWidth, 
                                                18, 
                                                self));
    

    // DATE TIME
	m_DateTime = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_CodeName.WinLeft + m_CodeName.WinWidth,
                                                m_Top.WinHeight, 
                                                LabelWidth,
                                                18, 
                                                self));
    

    // LOCATION
	m_Location = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_DateTime.WinLeft + m_DateTime.WinWidth, 
                                                m_Top.WinHeight, 
                                        		m_DateTime.WinWidth, 
                                                18, 
                                                self));

    //MISSION RESULT
    m_MissionResultTitle = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                21, 
                                                52, 
		                                        m_fMissionResultTitleWidth, 
                                                m_fMissionResultTitleHeight, 
                                                self));    
    m_MissionResultTitle.m_bUseBGColor      = true;    
    m_MissionResultTitle.m_BGTexture        = m_TBGMissionResult;
    m_MissionResultTitle.m_BGTextureRegion  = m_RBGMissionResult;
	m_MissionResultTitle.m_BGExtRegion		= m_RBGExtMissionResult;
    m_MissionResultTitle.m_Drawstyle        = 5; //ERenderStyle.STY_Alpha;
    m_MissionResultTitle.m_BorderColor      = Root.Colors.GrayLight;
    m_MissionResultTitle.m_bDrawBorders     = true;
    m_MissionResultTitle.m_bDrawBG          = true;
	m_MissionResultTitle.m_bUseExtRegion    = true; // draw the BG with extremities and center texture
        

    //*************************** Mission objectives
    m_MissionObjectives = R6WindowWrappedTextArea(CreateWindow(class'R6WindowWrappedTextArea', 
		                                                       m_MissionResultTitle.WinLeft, 
                                                               87, 
                                   	                           m_MissionResultTitle.WinWidth,                                                           
                                                               m_fObjHeight, 
                                                               self));
    m_MissionObjectives.m_BorderColor = Root.Colors.GrayLight;    
    m_MissionObjectives.SetScrollable(true);
	m_MissionObjectives.VertSB.SetBorderColor(Root.Colors.GrayLight);  
    m_MissionObjectives.VertSB.SetHideWhenDisable(true);
    m_MissionObjectives.VertSB.SetEffect(true);
    m_MissionObjectives.m_BorderStyle = ERenderStyle.STY_Normal;
    m_MissionObjectives.VertSB.m_BorderStyle = ERenderStyle.STY_Normal;   
    m_MissionObjectives.m_bUseBGTexture = true;
    m_MissionObjectives.m_BGTexture = Texture'UWindow.WhiteTexture';
    m_MissionObjectives.m_BGRegion.X = 0;
    m_MissionObjectives.m_BGRegion.Y = 0; 
	m_MissionObjectives.m_BGRegion.W = m_MissionObjectives.m_BGTexture.USize;       
    m_MissionObjectives.m_BGRegion.H = m_MissionObjectives.m_BGTexture.VSize;
    m_MissionObjectives.m_bUseBGColor = true;
    m_MissionObjectives.m_BGColor = Root.Colors.Black;
    m_MissionObjectives.m_BGColor.A = Root.Colors.DarkBGAlpha;

    m_NavBar.HideWindow();

    
    //DEBRIEF NAV BAR

    m_fNavAreaY = m_Bottom.WinTop - 33 - m_fLaptopPadding;
    NavXPos = m_Left.WinWidth + 2;
    
    m_DebriefNavBar = R6MenuDebriefNavBar(CreateWindow(class'R6MenuDebriefNavBar', m_NavBar.WinLeft, m_NavBar.Wintop, m_NavBar.WinWidth, m_NavBar.WinHeight, self));

    fStatsHeight = 227;
    
    //Team stats
    m_pR6RainbowTeamBar = R6MenuSingleTeamBar( CreateControl(class'R6MenuSingleTeamBar', m_MissionObjectives.WinLeft, m_MissionObjectives.WinTop + m_MissionObjectives.WinHeight + 3, m_fStatsWidth, fStatsHeight, self));    
    m_pR6RainbowTeamBar.m_bDrawBorders          = true;  
    m_pR6RainbowTeamBar.m_bDrawTotalsShading    = true;  
    m_pR6RainbowTeamBar.m_IFirstItempYOffset    = 4;    
    m_pR6RainbowTeamBar.m_IBorderVOffset = 0;
    m_pR6RainbowTeamBar.m_fRainbowWidth = 131;
    m_pR6RainbowTeamBar.m_fTeamcolorWidth=21;
    m_pR6RainbowTeamBar.m_fHealthWidth=23;
    m_pR6RainbowTeamBar.m_fSkullWidth=23;
    m_pR6RainbowTeamBar.m_fEfficiencyWidth=25;
    m_pR6RainbowTeamBar.m_fShotsWidth=39;
    m_pR6RainbowTeamBar.m_fHitsWidth=32;    
    m_pR6RainbowTeamBar.m_fBottomTitleWidth=175;
    m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_fXItemOffset = 1;
    m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_fXItemRightPadding = 1;
    m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_fItemHeight = 18;    
    m_pR6RainbowTeamBar.resize();

    m_RainbowCarreerStats = R6MenuCarreerStats(CreateWindow(class'R6MenuCarreerStats', 
                                         m_pR6RainbowTeamBar.WinLeft + m_pR6RainbowTeamBar.WinWidth + m_fPaddingBetween, 
                                         m_pR6RainbowTeamBar.WinTop, 
                                         301, 
                                         m_pR6RainbowTeamBar.WinHeight,
                                         self));
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    Super.Paint(C,X,Y);
    if (m_bReadyShowWindow)
    {
        if (m_iCountFrame == 1)
        {
            m_bReadyShowWindow = false;
            GetPlayerOwner().StopAllMusic();
            R6AbstractHUD(GetPlayerOwner().myHUD).StopFadeToBlack();
            GetPlayerOwner().ResetVolume_TypeSound(SLOT_Music);

            if(m_bMissionVictory)
                GetPlayerOwner().PlayMusic(m_sndVictoryMusic);
            else
                GetPlayerOwner().PlayMusic(m_sndLossMusic);
        }
        m_iCountFrame = 1;
    }
}

function ShowWindow()
{
    local R6MissionDescription CurrentMission;
    //local R6GameInfo GameInfo;
    local R6MissionObjectiveMgr moMgr;
    local int i;
    local string szObjectiveDesc;
    local Canvas C;


    C = class'Actor'.static.GetCanvas();

    //Force Menu Res
    C.m_iNewResolutionX = 640;
    C.m_iNewResolutionY = 480;
    C.m_bChangeResRequested = true;
    
	GetLevel().m_bAllow3DRendering = false;

    Super.ShowWindow();

    m_DebriefNavBar.m_ContinueButton.bDisabled = false;

	GetPlayerOwner().SetPause(true);
    
    m_bReadyShowWindow = true;
    m_iCountFrame = 0;

    CurrentMission = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission);


    ///////////////////////////// Show Mission Location /////////////////////////////////////////

    m_CodeName.SetProperties( Localize(CurrentMission.m_MapName,"ID_CODENAME" ,CurrentMission.LocalizationFile),
                              TA_Center, Root.Fonts[F_IntelTitle], Root.Colors.White, false);

    m_DateTime.SetProperties( Localize(CurrentMission.m_MapName,"ID_DATETIME" ,CurrentMission.LocalizationFile),
                              TA_Center, Root.Fonts[F_IntelTitle], Root.Colors.White, false);
    
    m_Location.SetProperties( Localize(CurrentMission.m_MapName,"ID_LOCATION", CurrentMission.LocalizationFile),
                              TA_Center, Root.Fonts[F_IntelTitle], Root.Colors.White, false);

    
    ///////////////////////////////// Update Mission Objectives /////////////////////////////////

    moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
    
    
    m_MissionObjectives.clear();
    m_MissionObjectives.m_fXOffset=10;
    m_MissionObjectives.m_fYOffset=5;
    m_MissionObjectives.AddText( Localize("Briefing","SUMMARY","R6Menu"), Root.Colors.BlueLight, Root.Fonts[F_SmallTitle]);


    ////////////////////////////   Show Mission Results ///////////////////////////////////////////
    


    ///////////////////////////////////////////////////////////
    // MISSION SUCESSFULL
    ///////////////////////////////////////////////////////////
    if( moMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success )
    {
        m_bMissionVictory = true;
        m_MissionResultTitle.SetProperties( Localize("DebriefingMenu","SUCCESS","R6Menu"),
                              TA_Center, Root.Fonts[F_MenuMainTitle], Root.Colors.Green, true);
        m_MissionResultTitle.m_BGColor = Root.Colors.Green;                        

        //We fill the text box with all the primary obectives and their status
        for ( i = 0; i < moMgr.m_aMissionObjectives.Length; ++i )
        {
            if ( (!moMgr.m_aMissionObjectives[i].m_bMoralityObjective)  && (moMgr.m_aMissionObjectives[i].m_bVisibleInMenu))
            {
                szObjectiveDesc = Localize( "Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, 
                                            moMgr.Level.GetMissionObjLocFile( moMgr.m_aMissionObjectives[i] ) );
                    
            
                if(moMgr.m_aMissionObjectives[i].isCompleted())            
                    szObjectiveDesc = "-"@szObjectiveDesc@":"@Localize("OBJECTIVES","SUCCESS","R6Menu");            
                else
                    szObjectiveDesc = "-"@szObjectiveDesc@":"@Localize("OBJECTIVES","FAILED","R6Menu");                

                m_MissionObjectives.AddText( szObjectiveDesc, Root.Colors.White, Root.Fonts[F_ListItemSmall]);      
            }     
        }         
        
    }       
    else
    {
        ///////////////////////////////////////////////////////////
        // MISSION FAILED
        ///////////////////////////////////////////////////////////
        m_bMissionVictory = false;

        m_MissionResultTitle.SetProperties( Localize("DebriefingMenu","FAILED","R6Menu"),
                              TA_Center, Root.Fonts[F_MenuMainTitle], Root.Colors.Red, true);

        m_MissionResultTitle.m_BGColor = Root.Colors.Red;        

  

        //We fill the text box with all the primary obectives and their status
        //When we fail we have to check for morality objectives
        for ( i = 0; i < moMgr.m_aMissionObjectives.Length; ++i )
        {
            if ( moMgr.m_aMissionObjectives[i].m_bVisibleInMenu)
            {
                szObjectiveDesc = "";
            
                // display onlu morality if it has failed
                if ( moMgr.m_aMissionObjectives[i].m_bMoralityObjective )
                {
                    if ( moMgr.m_aMissionObjectives[i].isFailed() )
                    {
                        szObjectiveDesc = "-"@Localize( "Game", moMgr.m_aMissionObjectives[i].m_szDescriptionFailure, 
                                                    moMgr.Level.GetMissionObjLocFile( moMgr.m_aMissionObjectives[i] ) );
                    }
                }
                else
                {
                    if ( moMgr.m_aMissionObjectives[i].isCompleted() )
                        szObjectiveDesc = Localize("OBJECTIVES", "SUCCESS", "R6Menu");            
                    else
                        szObjectiveDesc = Localize("OBJECTIVES", "FAILED",  "R6Menu");                

                    szObjectiveDesc = "-"@Localize("Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, 
                                      moMgr.Level.GetMissionObjLocFile( moMgr.m_aMissionObjectives[i] ) )@":"@szObjectiveDesc;
                }
        
                if ( szObjectiveDesc != "" )
                {
                    m_MissionObjectives.AddText( szObjectiveDesc, Root.Colors.White, Root.Fonts[F_ListItemSmall]);      
                }
            }     
        } 

        if( R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingPlayerCampaign )
        {
            m_DebriefNavBar.m_ContinueButton.bDisabled = true; //it should bring them back at the right place
        }
    }   
        
    ///////////////////////////////// Build Operatives List Box and stats ///////////////////////////////////
    
    m_pR6RainbowTeamBar.RefreshTeamBarInfo();    
    ////// Build none Saving game modes Mission operatives /////////////////////////////////////
    if( !R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingPlayerCampaign)
    {
        BuildMissionOperatives();

    }

    if(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.Items.Next != None)
    {
        m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.SetSelectedItem(R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.Items.Next));
        DisplayOperativeStats(R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_SelectedItem).m_iOperativeID);                   
    }        
    else
    {        
        m_RainbowCarreerStats.UpdateStats("","","","","");
        
    }

}

function HideWindow()
{
    local Canvas C;

    C = class'Actor'.static.GetCanvas();    
    
    Super.HideWindow();

    //Force Game Res
    C.m_iNewResolutionX = 0;
    C.m_iNewResolutionY = 0;
    C.m_bChangeResRequested = true;

	GetLevel().m_bAllow3DRendering = true;

    GetPlayerOwner().SetPause(false);
}

function BuildMissionOperatives()
{
    /////////This is usefull for non campain game modes /////////////////////
    local R6Operative      tmpOperative;
    local R6WindowListIGPlayerInfoItem tmpItem;

    //Empty the game operatives

    m_MissionOperatives.remove(0, m_MissionOperatives.length); 
    

    tmpItem = R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.Items.Next);
    while(tmpItem != None)
    {
        tmpOperative = New(None) class<R6Operative>(DynamicLoadObject(R6Console(Root.Console).m_CurrentCampaign.m_OperativeClassName[tmpItem.m_iOperativeID], class'Class'));     
        tmpItem.m_iOperativeID = m_MissionOperatives.Length; // To quicky access it in array
        m_MissionOperatives[m_MissionOperatives.Length] = tmpOperative;     
        
        tmpOperative.m_iNbMissionPlayed = 1;
        tmpOperative.m_iTerrokilled     = tmpItem.iKills;
        tmpOperative.m_iRoundsfired     = tmpItem.iRoundsFired;
        tmpOperative.m_iRoundsOntarget  = tmpItem.iRoundsHit;
        tmpOperative.m_iHealth          = tmpItem.eStatus;

        tmpItem = R6WindowListIGPlayerInfoItem(tmpItem.Next);
    }

}


function DisplayOperativeStats(int _OperativeId)
{
    //Displays The carreer stats of the operative just selected
    local R6Operative           tmpOperative;
    local R6PlayerCampaign      MyCampaign;    
    local R6MissionRoster       PlayerCampaignOperatives;
    local R6WindowListIGPlayerInfoItem selectedItem;
    local Region                R;
    
    selectedItem = R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_SelectedItem);
    
    if( R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingPlayerCampaign)
    {
        MyCampaign   = R6Console(Root.Console).m_PlayerCampaign;         
        PlayerCampaignOperatives = MyCampaign.m_OperativesMissionDetails; 
        tmpOperative = PlayerCampaignOperatives.m_MissionOperatives[_OperativeId];        
    }        
    else    
        tmpOperative = m_MissionOperatives[_OperativeId];                
    
    
    
    m_RainbowCarreerStats.UpdateStats(tmpOperative.GetNbMissionPlayed(),
        tmpOperative.GetNbTerrokilled(),
        tmpOperative.GetNbRoundsfired(),
        tmpOperative.GetNbRoundsOnTarget(),
        tmpOperative.GetShootPercent());   
    
    R.X = tmpOperative.m_RMenuFaceX;
    R.Y = tmpOperative.m_RMenuFaceY;
    R.W = tmpOperative.m_RMenuFaceW;
    R.H = tmpOperative.m_RMenuFaceH;
    
    m_RainbowCarreerStats.UpdateFace(tmpOperative.m_TMenuFace, R);
    m_RainbowCarreerStats.UpdateTeam(selectedItem.m_iRainbowTeam);
    m_RainbowCarreerStats.UpdateName(tmpOperative.GetName());
    m_RainbowCarreerStats.UpdateSpeciality(tmpOperative.GetSpeciality());
    m_RainbowCarreerStats.UpdateHealthStatus(tmpOperative.GetHealthStatus());
    
    
        
        
}


function Notify(UWindowDialogControl C, byte E)
{
    //We get notified if someone clicked on an operative of the list
    if( E == DE_Click )
    {
        switch(C)
        {
        case m_pR6RainbowTeamBar.m_IGPlayerInfoListBox:
            if(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_SelectedItem != None)
                DisplayOperativeStats(R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_SelectedItem).m_iOperativeID);           
            break;        
        }
    }    
}

defaultproperties
{
     m_fObjHeight=72.000000
     m_fMissionResultTitleHeight=32.000000
     m_fMissionResultTitleWidth=598.000000
     m_fPaddingBetween=3.000000
     m_fStatsWidth=294.000000
     m_TBGMissionResult=Texture'R6MenuTextures.Gui_BoxScroll'
     m_sndVictoryMusic=Sound'Music.Play_theme_MissionVictory'
     m_sndLossMusic=Sound'Music.Play_theme_MissionLoss'
     m_RBGMissionResult=(X=134,Y=104,W=28,H=30)
     m_RBGExtMissionResult=(X=116,Y=104,W=16,H=30)
}
