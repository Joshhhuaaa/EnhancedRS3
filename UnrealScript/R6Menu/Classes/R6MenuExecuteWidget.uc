//=============================================================================
//  R6MenuExecuteWidget.uc : This widget is the last one in the planning phase
//                            this widget allows the player to choose the team
//                            he will play in and has a last glance at team copositions
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/12 * Created by Alexandre Dionne
//=============================================================================


class R6MenuExecuteWidget extends R6MenuLaptopWidget;


//Top Labels showing location of the current mission
var R6WindowTextLabel			m_CodeName, 
                                m_DateTime, 
                                m_Location;

//Missions Objectives for the current Mission
var R6WindowWrappedTextArea		m_MissionObjectives;

//Mission Objectives and map dimensions 
var FLOAT                       m_fObjWidth, m_fObjHeight, m_fMapWidth;

//Small world map top right 
var R6WindowBitMap              m_SmallMap;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                              Team Summarrys
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var R6WindowTeamSummary m_RedSummary, m_GreenSummary, m_GoldSummary;
var FLOAT               m_fTeamSummaryWidth, m_fTeamSummaryYPadding, m_fTeamSummaryXPadding, m_fTeamSummaryMaxHeight;
var R6WindowButton      m_RedSummaryButton, m_GreenSummaryButton, m_GoldSummaryButton;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////






/////////////////////////////////////////////////////////////////////////
//                           Bottom Buttons
/////////////////////////////////////////////////////////////////////////
var R6WindowButton              m_GoPlanningButton, m_GoGameButton, m_ObserverButton;

var Texture                     m_TObserverButton,      m_TGoPlanningButton, m_TGoGameButton;
var Region                      m_RGoPlanningButtonUp,  m_RGoPlanningButtonDown, m_RGoPlanningButtonOver, m_RGoPlanningButtonDisabled;
var Region                      m_RGoGameButtonUp,      m_RGoGameButtonDown,     m_RGoGameButtonOver,     m_RGoGameButtonDisabled;
var Region                      m_RObserverButtonUp,    m_RObserverButtonDown,   m_RObserverButtonOver,   m_RObserverButtonDisabled;

//Buttons coordinates
var FLOAT                       m_fGoPlanningButtonX, m_fGoGameButtonX, m_fObserverButtonX, 
                                m_fButtonHeight, m_fButtonAreaY, m_fButtonY;


/////////////////////////////////////////////////////////////////////////



function Created()
{
    local FLOAT    LabelWidth;
    local FLOAT    fTeamSummaryYPos;

    Super.Created();

    //*************************** Title Labels
	LabelWidth = int(m_Right.WinLeft - m_left.WinWidth )/3;
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

    //*************************** Mission objectives
    m_MissionObjectives = R6WindowWrappedTextArea(CreateWindow(class'R6WindowWrappedTextArea', 
		                                                       m_Left.WinWidth + m_fLaptopPadding, 
                                                               m_Location.Wintop + m_Location.WinHeight, 
                                   	                           m_fObjWidth,
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

    m_SmallMap =    R6WindowBitMap(CreateWindow(class'R6WindowBitMap', 
                                                m_MissionObjectives.WinLeft + m_MissionObjectives.WinWidth + 4, 
                                                m_MissionObjectives.WinTop, 
		                                        m_fMapWidth, 
                                                m_fObjHeight,
                                                self));
    m_SmallMap.m_BorderColor = Root.Colors.GrayLight;
    m_SmallMap.m_BorderStyle = ERenderStyle.STY_Normal;
    m_SmallMap.m_bDrawBorder = true;
    m_SmallMap.bStretch      = true;
    m_SmallMap.m_iDrawStyle  = 5; // Alpha    

    m_NavBar.HideWindow();

    m_fButtonAreaY = m_Bottom.WinTop - 33 - m_fLaptopPadding;
    m_fButtonY = m_fButtonAreaY +1;

    /////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////
    //                      Bottom Buttons and Borders
    /////////////////////////////////////////////////////////////////////////////////////////////
    m_BorderColor = Root.Colors.BlueLight;    

    m_GoPlanningButton  = R6WindowButton(CreateControl( class'R6WindowButton', m_fGoPlanningButtonX, m_fButtonY, m_RGoPlanningButtonUp.W, m_fButtonHeight, self));
    m_GoPlanningButton.DisabledTexture    =   m_TGoPlanningButton;
    m_GoPlanningButton.DownTexture        =   m_TGoPlanningButton;
    m_GoPlanningButton.OverTexture        =   m_TGoPlanningButton;
    m_GoPlanningButton.UpTexture          =   m_TGoPlanningButton;
    m_GoPlanningButton.UpRegion           =   m_RGoPlanningButtonUp;
    m_GoPlanningButton.DownRegion         =   m_RGoPlanningButtonDown;   
    m_GoPlanningButton.DisabledRegion     =   m_RGoPlanningButtonDisabled;
    m_GoPlanningButton.OverRegion         =   m_RGoPlanningButtonOver;
    m_GoPlanningButton.bUseRegion         = true;
    m_GoPlanningButton.ToolTipString      = Localize("ExecuteMenu","GOPLANNING","R6Menu");
    m_GoPlanningButton.m_iDrawStyle       =  5; //Alpha

    m_GoGameButton      = R6WindowButton(CreateControl( class'R6WindowButton', m_fGoGameButtonX, m_fButtonY, m_RGoGameButtonUp.W, m_fButtonHeight, self));
    m_GoGameButton.DisabledTexture    =   m_TGoGameButton;
    m_GoGameButton.DownTexture        =   m_TGoGameButton;
    m_GoGameButton.OverTexture        =   m_TGoGameButton;
    m_GoGameButton.UpTexture          =   m_TGoGameButton;
    m_GoGameButton.UpRegion           =   m_RGoGameButtonUp;
    m_GoGameButton.DownRegion         =   m_RGoGameButtonDown;   
    m_GoGameButton.DisabledRegion     =   m_RGoGameButtonDisabled;
    m_GoGameButton.OverRegion         =   m_RGoGameButtonOver;
    m_GoGameButton.bUseRegion         = true;
    m_GoGameButton.ToolTipString      = Localize("ExecuteMenu","GOGAME","R6Menu");
    m_GoGameButton.m_iDrawStyle       =  5; //Alpha


    m_ObserverButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_fObserverButtonX, m_fButtonY +1, m_RObserverButtonUp.W, m_fButtonHeight, self));
    m_ObserverButton.DisabledTexture    =   m_TObserverButton;
    m_ObserverButton.DownTexture        =   m_TObserverButton;
    m_ObserverButton.OverTexture        =   m_TObserverButton;
    m_ObserverButton.UpTexture          =   m_TObserverButton;
    m_ObserverButton.UpRegion           =   m_RObserverButtonUp;
    m_ObserverButton.DownRegion         =   m_RObserverButtonDown;   
    m_ObserverButton.DisabledRegion     =   m_RObserverButtonDisabled;
    m_ObserverButton.OverRegion         =   m_RObserverButtonOver;    
    m_ObserverButton.bUseRegion         = true;
    m_ObserverButton.ToolTipString      = Localize("ExecuteMenu","OBSERVER","R6Menu");
    m_ObserverButton.m_iDrawStyle       = 5; //Alpha

    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    //                              TEAM SUMMARYS                                       //
    //////////////////////////////////////////////////////////////////////////////////////

    fTeamSummaryYPos = 152;
    m_fTeamSummaryMaxHeight =  237;

    m_RedSummary    = R6WindowTeamSummary(CreateWindow(class'R6WindowTeamSummary', m_MissionObjectives.WinLeft, fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
    m_RedSummary.SetTeam(0);    
    m_RedSummary.bAlwaysBehind = true;
    m_GreenSummary  = R6WindowTeamSummary(CreateWindow(class'R6WindowTeamSummary', m_RedSummary.WinLeft + m_RedSummary.WinWidth + m_fTeamSummaryXPadding, fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
    m_GreenSummary.SetTeam(1);
    m_GreenSummary.bAlwaysBehind = true;
    m_GoldSummary   = R6WindowTeamSummary(CreateWindow(class'R6WindowTeamSummary', m_GreenSummary.WinLeft + m_GreenSummary.WinWidth + m_fTeamSummaryXPadding, fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
    m_GoldSummary.SetTeam(2);    
    m_GoldSummary.bAlwaysBehind = true;
    
    m_RedSummaryButton = R6WindowButton(CreateControl(class'R6WindowButton', m_MissionObjectives.WinLeft, fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_RedSummaryButton.ToolTipString = Localize("ExecuteMenu","OverATeam","R6Menu");
    m_RedSummaryButton.m_BorderColor = Root.Colors.BlueLight;        
    m_RedSummaryButton.m_bDrawSimpleBorder = true;

    m_GreenSummaryButton = R6WindowButton(CreateControl(class'R6WindowButton', m_RedSummary.WinLeft + m_RedSummary.WinWidth + m_fTeamSummaryXPadding, fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_GreenSummaryButton.ToolTipString = Localize("ExecuteMenu","OverATeam","R6Menu");
    m_GreenSummaryButton.m_BorderColor = Root.Colors.BlueLight;      
    m_GreenSummaryButton.m_bDrawSimpleBorder = true;

    m_GoldSummaryButton = R6WindowButton(CreateControl(class'R6WindowButton', m_GreenSummary.WinLeft + m_GreenSummary.WinWidth + m_fTeamSummaryXPadding, fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_GoldSummaryButton.ToolTipString = Localize("ExecuteMenu","OverATeam","R6Menu");
    m_GoldSummaryButton.m_BorderColor = Root.Colors.BlueLight;    
    m_GoldSummaryButton.m_bDrawSimpleBorder = true;
}


function ShowWindow()
{
    local R6MissionObjectiveMgr moMgr;
    local int i;
    local string szDescription;
    local R6GameOptions pGameOptions;

    //Mission about to be played
    local R6MissionDescription CurrentMission;

    Super.ShowWindow();

    CurrentMission = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission);

    m_CodeName.SetProperties( Localize(CurrentMission.m_MapName,"ID_CODENAME",CurrentMission.LocalizationFile),
                              TA_Center, Root.Fonts[F_IntelTitle], Root.Colors.White, false);

    m_DateTime.SetProperties( Localize(CurrentMission.m_MapName,"ID_DATETIME",CurrentMission.LocalizationFile),
                              TA_Center, Root.Fonts[F_IntelTitle], Root.Colors.White, false);
    
    m_Location.SetProperties( Localize(CurrentMission.m_MapName,"ID_LOCATION",CurrentMission.LocalizationFile),
                              TA_Center, Root.Fonts[F_IntelTitle], Root.Colors.White, false);
        

    ///////////////////////////////// Update Mission Objectives /////////////////////////////////

    moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
    
    m_MissionObjectives.clear();
    
    m_MissionObjectives.m_fXOffset=10;
    m_MissionObjectives.m_fYOffset=5;
    m_MissionObjectives.AddText( Localize("Briefing","Objectives","R6Menu"), Root.Colors.BlueLight, Root.Fonts[F_SmallTitle]);
    
    
    //m_MissionObjectives.AddText( Localize( m_CurrentMission.Default.m_MapName, "ID_OBJECTIVES", m_CurrentMission.LocalizationFile, true), White, Root.Fonts[F_ListItemSmall]);

   
    //We fill the text box with all the primary obectives and their status
    for ( i = 0; i < moMgr.m_aMissionObjectives.Length; ++i )
    {
        if ( (!moMgr.m_aMissionObjectives[i].m_bMoralityObjective)  && (moMgr.m_aMissionObjectives[i].m_bVisibleInMenu))
        {                                
            szDescription = "-"@Localize( "Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, 
                                        moMgr.Level.GetMissionObjLocFile( moMgr.m_aMissionObjectives[i] ) );
            m_MissionObjectives.AddText( szDescription, Root.Colors.White, Root.Fonts[F_ListItemSmall]);      
        }     
    }    
    
    
    m_SmallMap.T = CurrentMission.m_TWorldMap;
    m_SmallMap.R = CurrentMission.m_RWorldMap;


    CalculatePlanningDetails();
    UpdateTeamRoster();

    if(R6MenuRootWindow(Root).m_bPlayerPlanInitialized == false)
    {
        pGameOptions = class'Actor'.static.GetGameOptions();
        if( pGameOptions.PopUpLoadPlan == true)
        {
            R6MenuRootWindow(Root).m_ePopUpID = EPopUpID_LoadPlanning;
            R6MenuRootWindow(Root).PopUpMenu(true);      
        }   
    }
    

    
}

function CalculatePlanningDetails()
{
    local R6PlanningInfo PlanningInfo;
    local int            iWaypoint, iGoCode, i, y;
    local R6WindowTeamSummary TeamSummarys[3];

   
    TeamSummarys[0] = m_RedSummary;
    TeamSummarys[1] = m_GreenSummary;
    TeamSummarys[2] = m_GoldSummary; 

    
    for(i=0; i<3; i++)
    {
        
        PlanningInfo = R6PlanningInfo(Root.Console.Master.m_StartGameInfo.m_TeamInfo[i].m_pPlanning);    
        iWaypoint = 0;
        iGoCode   = 0;

        for(y=0; y < PlanningInfo.m_NodeList.Length; y++ )
        {
            
            if( (R6ActionPoint(PlanningInfo.m_NodeList[y]).m_eActionType == EPlanActionType.PACTTYP_GoCodeA) ||
                (R6ActionPoint(PlanningInfo.m_NodeList[y]).m_eActionType == EPlanActionType.PACTTYP_GoCodeB) ||
                (R6ActionPoint(PlanningInfo.m_NodeList[y]).m_eActionType == EPlanActionType.PACTTYP_GoCodeC) 
              )
                iGoCode++;
        
        }

        iWaypoint = PlanningInfo.m_NodeList.Length;

        TeamSummarys[i].SetPlanningDetails(string(iWaypoint), string(iGoCode));

    }   
    
}

function UpdateTeamRoster()
{
    
    local int                       i, y;
    local R6WindowTeamSummary       TeamSummarys[3];
    local R6WindowButton            TeamSummaryButton[3];
    local R6Operative               tmpOperative;    
    local R6WindowTextIconsListBox  tmpListBox[3], currentListBox;
    local R6WindowListBoxItem       tmpItem;
    local R6MenuRootWindow          R6Root;
    local bool                      bselectedSet;

#ifndefMPDEMO
   
    TeamSummarys[0] = m_RedSummary;
    TeamSummarys[1] = m_GreenSummary;
    TeamSummarys[2] = m_GoldSummary;

    //Drop selections
    TeamSummaryButton[0] = m_RedSummaryButton;
    TeamSummaryButton[1] = m_GreenSummaryButton;
    TeamSummaryButton[2] = m_GoldSummaryButton;

    m_RedSummary.SetSelected(false);
    m_GreenSummary.SetSelected(false);
    m_GoldSummary.SetSelected(false);
    m_RedSummaryButton.m_bDrawBorders = false;
    m_GreenSummaryButton.m_bDrawBorders = false;
    m_GoldSummaryButton.m_bDrawBorders = false;

    //Needed to find what team is selected
    bselectedSet = false;
    
    m_RedSummary.Init();
    m_GreenSummary.Init();
    m_GoldSummary.Init();

    R6Root = R6MenuRootWindow(Root);
    
    
    tmpListBox[0] = R6Root.m_GearRoomWidget.m_RosterListCtrl.m_RedListBox.m_listBox;
    tmpListBox[1] = R6Root.m_GearRoomWidget.m_RosterListCtrl.m_GreenListBox.m_listBox;
    tmpListBox[2] = R6Root.m_GearRoomWidget.m_RosterListCtrl.m_GoldListBox.m_listBox;

    //Parse Lists Boxes
    for(y=0; y<3; y++)
    {
        currentListBox = tmpListBox[y];
        tmpItem = R6WindowListBoxItem(currentListBox.Items.Next);
        
        for(i=0; i< currentListBox.Items.Count(); i++)
        {            
            tmpOperative = R6Operative(tmpItem.m_Object);
        
            if(tmpOperative != None)    
            {                
                TeamSummarys[y].AddOperative(tmpOperative);
                
                if(bselectedSet == false)
                {   //This is to select a default player team
                    TeamSummaryButton[y].m_bDrawBorders = true;
                    TeamSummarys[y].SetSelected(true);
                    bselectedSet = true;
                }
            }

            tmpItem = R6WindowListBoxItem(tmpItem.Next);
        }

    }
#endif
}


function Notify(UWindowDialogControl C, byte E)
{ 
    if( E == DE_Click )
    {
        switch(C)
        {
        case m_GoPlanningButton:
            Root.ChangeCurrentWidget(PreviousWidgetID);
            break;
        case m_GoGameButton:
            R6MenuRootWindow(Root).LeaveForGame(false, GetTeamStart());
            break;
        case m_ObserverButton:
            R6MenuRootWindow(Root).LeaveForGame(true, GetTeamStart());
            break;

        case m_RedSummaryButton:            
            if( m_RedSummary.OperativeCount() > 0)
            {
                m_RedSummary.SetSelected(true);
                m_GreenSummary.SetSelected(false);
                m_GoldSummary.SetSelected(false);
                m_RedSummaryButton.m_bDrawBorders    = true;
                m_GreenSummaryButton.m_bDrawBorders  = false;
                m_GoldSummaryButton.m_bDrawBorders   = false;
            }            
            break;
        case m_GreenSummaryButton:            
            if( m_GreenSummary.OperativeCount() > 0)
            {
                m_RedSummary.SetSelected(false);
                m_GreenSummary.SetSelected(true);
                m_GoldSummary.SetSelected(false);
                m_RedSummaryButton.m_bDrawBorders    = false;
                m_GreenSummaryButton.m_bDrawBorders  = true;
                m_GoldSummaryButton.m_bDrawBorders   = false;
            }            
            break;
        case m_GoldSummaryButton:            
            if( m_GoldSummary.OperativeCount() > 0)
            {
                m_RedSummary.SetSelected(false);
                m_GreenSummary.SetSelected(false);
                m_GoldSummary.SetSelected(true);
                m_RedSummaryButton.m_bDrawBorders    = false;
                m_GreenSummaryButton.m_bDrawBorders  = false;
                m_GoldSummaryButton.m_bDrawBorders   = true;
            }            
            break;
        }
    }    
}

function Paint(Canvas C, Float X, Float Y)
{

    local FLOAT boxX;
        
    Super.Paint(C, X, Y);

    boxX = m_Left.WinWidth + 2;

    R6WindowLookAndFeel(LookAndFeel).DrawBox(Self, C, boxX,
                                                   m_fButtonAreaY,
                                                   640 - (2*(boxX)),
                                                   33);   
}

function INT GetTeamStart()
{
    if (m_RedSummary.m_bIsSelected)
        return 0;
    else if (m_GreenSummary.m_bIsSelected)
        return 1;
    else if (m_GoldSummary.m_bIsSelected)
        return 2;

	return 0;
}

defaultproperties
{
     m_fObjWidth=396.000000
     m_fObjHeight=98.000000
     m_fMapWidth=196.000000
     m_fTeamSummaryWidth=196.000000
     m_fTeamSummaryYPadding=4.000000
     m_fTeamSummaryXPadding=4.000000
     m_fGoPlanningButtonX=172.000000
     m_fGoGameButtonX=442.000000
     m_fObserverButtonX=303.000000
     m_fButtonHeight=33.000000
     m_TObserverButton=Texture'R6MenuTextures.Gui_02'
     m_TGoPlanningButton=Texture'R6MenuTextures.Gui_01'
     m_TGoGameButton=Texture'R6MenuTextures.Gui_01'
     m_RGoPlanningButtonUp=(X=26,Y=120,W=25,H=30)
     m_RGoPlanningButtonDown=(X=26,Y=180,W=25,H=30)
     m_RGoPlanningButtonOver=(X=26,Y=150,W=25,H=30)
     m_RGoPlanningButtonDisabled=(X=26,Y=210,W=25,H=30)
     m_RGoGameButtonUp=(Y=120,W=25,H=30)
     m_RGoGameButtonDown=(Y=180,W=25,H=30)
     m_RGoGameButtonOver=(Y=150,W=25,H=30)
     m_RGoGameButtonDisabled=(Y=210,W=25,H=30)
     m_RObserverButtonUp=(X=179,W=33,H=30)
     m_RObserverButtonDown=(X=179,Y=60,W=33,H=30)
     m_RObserverButtonOver=(X=179,Y=30,W=33,H=30)
     m_RObserverButtonDisabled=(X=179,Y=90,W=33,H=30)
}
