//=============================================================================
//  R6MenuCustomMissionWidget.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCustomMissionWidget extends R6MenuWidget
                config(USER);


var color  m_TitleTextColor;

var bool	bshowlog;

var R6WindowButton	                    m_ButtonStart;
var R6WindowButton	                    m_ButtonMainMenu;
var R6WindowButton	                    m_ButtonOptions;

var R6WindowSimpleFramedWindow          m_Map;

var R6WindowTextLabel		        	m_LMenuTitle; 

var R6WindowTextLabelCurved             m_LGameLevelTitle;
var R6WindowTextListBox			        m_GameLevelBox;
var R6WindowSimpleCurvedFramedWindow    m_DifficultyArea;

var R6FileManagerCampaign               m_pFileManager;
    
var  R6MenuHelpWindow                   m_pHelpWindow;            // the help window (tooltip)

var R6WindowButton						m_pButPraticeMission;
var R6WindowButton						m_pButLoneWolf;
var R6WindowButton						m_pButTerroHunt;
var R6WindowButton						m_pButHostageRescue;
var R6WindowButton						m_pButCurrent;

var R6WindowSimpleFramedWindow          m_TerroArea;


//To update when we come back from a custom menu game
var string                              m_LastMapPlayed;    
var config  string                      CustomMissionMap;    
var config  INT                         CustomMissionGameType;

var   Font    m_LeftButtonFont;
var   Font    m_LeftDownSizeFont;

function Created()
{
	local   Font                                buttonFont;
	local   color                               Co;
	local   color                               TitleTextColor;
	local   INT                                 iFiles, i;
	local   String                              szFilename;	
	
	local bool bInTab;
    local   R6WindowListBoxItem   NewItem;
    local   R6MenuRootWindow      R6Root;

    local INT   XPos;

    R6Root = R6MenuRootWindow(Root);


	buttonFont		= Root.Fonts[F_PrincipalButton];
    
     //=================================================================================
    // Help Zone
    //=================================================================================
        // create the help window
    m_pHelpWindow = R6MenuHelpWindow(CreateWindow(class'R6MenuHelpWindow', 150, 429, 340, 42, self)); //std param is set in help window    
    

	m_ButtonMainMenu                    = R6WindowButton(CreateControl( class'R6WindowButton', 10, 421, 250, 25, self));
    m_ButtonMainMenu.ToolTipString      = Localize("Tip","ButtonMainMenu","R6Menu");
	m_ButtonMainMenu.Text               = Localize("SinglePlayer","ButtonMainMenu","R6Menu");	
	m_ButtonMainMenu.Align              = TA_LEFT;	
	m_ButtonMainMenu.m_buttonFont       = buttonFont;
	m_ButtonMainMenu.ResizeToText();	

	m_ButtonOptions = R6WindowButton(CreateControl( class'R6WindowButton', 10, 452, 250, 25, self));
    m_ButtonOptions.ToolTipString       = Localize("Tip","ButtonOptions","R6Menu");	
    m_ButtonOptions.Text                = Localize("SinglePlayer","ButtonOptions","R6Menu");	
	m_ButtonOptions.Align               = TA_LEFT;		
	m_ButtonOptions.m_buttonFont        = buttonFont;
	m_ButtonOptions.ResizeToText();    

    XPos = m_pHelpWindow.WinLeft + m_pHelpWindow.WinWidth;
	
	m_ButtonStart = R6WindowButton(CreateControl( class'R6WindowButton', XPos, 452, WinWidth - XPos - 20, 25, self));
    m_ButtonStart.ToolTipString     = Localize("Tip","ButtonStart","R6Menu");
	m_ButtonStart.Text              = Localize("CustomMission","ButtonStart1","R6Menu");	
	m_ButtonStart.Align             = TA_RIGHT;		
	m_ButtonStart.m_buttonFont      = buttonFont;    
	m_ButtonStart.ResizeToText();		
    m_ButtonStart.m_bWaitSoundFinish= true;

    m_Map = R6WindowSimpleFramedWindow(CreateWindow(class'R6WindowSimpleFramedWindow', 390, 268, 230, 130, self));
    m_Map.CreateClientWindow(class'R6WindowBitMap');
    m_Map.m_eCornerType = All_Corners;   
    

	m_TitleTextColor = Root.Colors.White;
		
	
	m_LMenuTitle        = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 18, WinWidth - 8, 25, self));
	m_LMenuTitle.Text           = Localize("CustomMission","Title","R6Menu");
	m_LMenuTitle.Align          = TA_Right;
	m_LMenuTitle.m_Font         = Root.Fonts[F_MenuMainTitle];
	m_LMenuTitle.TextColor      = m_TitleTextColor;
	m_LMenuTitle.m_BGTexture    = None;
    m_LMenuTitle.m_bDrawBorders = False;
    

	m_GameLevelBox = R6WindowTextListBox(CreateControl( class'R6WindowTextListBox', 198, 102, 156, 296, self));
    m_GameLevelBox.ListClass=class'R6WindowListBoxItem';
    m_GameLevelBox.SetCornerType(Bottom_Corners);    	
    m_GameLevelBox.ToolTipString = Localize("Tip","CustomMListBox","R6Menu");

	m_LGameLevelTitle = R6WindowTextLabelCurved(CreateWindow(class'R6WindowTextLabelCurved', 198, 72, 156, 31, self));
	m_LGameLevelTitle.Text          = Localize("CustomMission","TitleGameLevel","R6Menu");
	m_LGameLevelTitle.Align         = TA_Center;
	m_LGameLevelTitle.m_Font        = Root.Fonts[F_PopUpTitle];
	m_LGameLevelTitle.TextColor     = m_TitleTextColor;	


	m_DifficultyArea = R6WindowSimpleCurvedFramedWindow(CreateWindow(class'R6WindowSimpleCurvedFramedWindow', 390, 72, m_Map.WinWidth, 122, self));
	m_DifficultyArea.CreateClientWindow(class'R6MenuDiffCustomMissionSelect');
	m_DifficultyArea.m_title        = Localize("SinglePlayer","Difficulty","R6Menu"); 
	m_DifficultyArea.m_TitleAlign   = TA_Center;
	m_DifficultyArea.m_Font         = Root.Fonts[F_PopUpTitle];
	m_DifficultyArea.m_TextColor    = m_TitleTextColor;	
    m_DifficultyArea.m_BorderColor  = Root.Colors.White;
    m_DifficultyArea.SetCornerType(All_Corners);

    m_TerroArea = R6WindowSimpleFramedWindow(CreateWindow(class'R6WindowSimpleFramedWindow', 390, m_DifficultyArea.WinTop + m_DifficultyArea.WinHeight -1, m_DifficultyArea.WinWidth, 63, self));
    m_TerroArea.CreateClientWindow(class'R6MenuCustomMissionNbTerroSelect');    
    m_TerroArea.SetCornerType(Bottom_Corners);    
    m_TerroArea.HideWindow();
	

	if(R6Root.m_pFileManager == NONE)
	{
		log("R6MenuRootWindow(Root).m_pFileManager == NONE");
	}

    m_pFileManager      = new class'R6FileManagerCampaign'; 

	InitCustomMission();
}

function bool ValidateBeforePlanning()
{
    local R6MenuRootWindow R6Root;

	//Make sure we can start the planning Phase

        
    //This Might Have to change
    //This Part populate the game Operative for the planning phase
    
    R6Root = R6MenuRootWindow(Root);


    if(R6Root == None)
    {
        if(bShowlog)log("ValidateBeforePlanning: R6Root == None");
        return false;
    }
        
    
    if((m_GameLevelBox.m_SelectedItem == NONE))
    {
        if(bShowlog)log("ValidateBeforePlanning: m_GameLevelBox.m_SelectedItem == NONE");
		return false;
    }
        
        
        
    if( m_GameLevelBox.m_SelectedItem.HelpText == "")
    {
        if(bShowlog)log("ValidateBeforePlanning: m_GameLevelBox.m_SelectedItem.HelpText == \"\"");
        return false;
    }
         
	
    R6Root.ResetCustomMissionOperatives();
    
    if(R6Root.m_GameOperatives.Length <= 0)
    {
        if(bShowlog)log("R6Root.m_GameOperatives.Length <= 0");
        return false;
    }        
    else 
    {
        if(bShowlog)log("ValidateBeforePlanning: return true");
        return true;
    }	

}


function GotoPlanning()
{

    local   R6MenuRootWindow                R6Root;
    local   R6MissionDescription            CurrentMission;
    local   R6WindowListBoxItem             SelectedItem;
    local   R6Console                       R6Console;
    
    R6Root = R6MenuRootWindow(Root);

	//Make sure that ValidateBeforePlanning() has returned true
	//Before calling this

    SelectedItem = R6WindowListBoxItem(m_GameLevelBox.m_SelectedItem);
    CurrentMission  = R6MissionDescription(SelectedItem.m_Object); //IF THIS IS NONE WE ARE SCREWED

    R6Console = R6Console(Root.console);
    
    R6Console.master.m_StartGameInfo.m_CurrentMission = CurrentMission;
	R6Console.master.m_StartGameInfo.m_MapName = CurrentMission.m_MapName;
	R6Console.master.m_StartGameInfo.m_DifficultyLevel = R6MenuDiffCustomMissionSelect(m_DifficultyArea.m_ClientArea).GetDifficulty();
	R6Console.master.m_StartGameInfo.m_iNbTerro = R6MenuCustomMissionNbTerroSelect(m_TerroArea.m_ClientArea).GetNbTerro();
	R6Console.master.m_StartGameInfo.m_GameMode = GetLevel().GetGameTypeClassName(GetLevel().ConvertGameTypeIntToString(m_pButCurrent.m_iButtonID));

    CustomMissionMap = CurrentMission.m_MapName;
    CustomMissionGameType = m_pButCurrent.m_iButtonID;

    SaveConfig();
	
    Root.ResetMenus();
    R6Root.m_bLoadingPlanning = true;
    R6Console.PreloadMapForPlanning();       
    
    
}

function ShowWindow()
{
    RefreshList();

    Super.ShowWindow();
}

function BOOL CampainMapExistInMapList(R6MissionDescription pMission)
{
	local INT iMission;

	for( iMission=0; iMission < R6Console( Root.Console ).m_aMissionDescriptions.length; iMission++ )
	{
		if(pMission == R6Console( Root.Console ).m_aMissionDescriptions[iMission])
			return true;
	}

	return false;
}

function RefreshList()
{
    local   int          i, iCampaign, iMission;
    local   R6console    r6Console;
    local   string       szMapName;	
    local   R6WindowListBoxItem  NewItem, ItemToSelect;
    local   string       szGameType;
    local   R6MissionDescription mission;

    r6console = R6Console( Root.Console );
    szGameType = GetLevel().ConvertGameTypeIntToString(m_pButCurrent.m_iButtonID);

    m_GameLevelBox.Clear();    
    
    // loop on campaign and list all thier mission in the right order
    iCampaign = 0;
    while ( iCampaign < r6console.m_aCampaigns.length )
    {
        iMission = 0;
        while ( iMission < r6console.m_aCampaigns[iCampaign].m_missions.length )
        {
            mission = r6console.m_aCampaigns[iCampaign].m_missions[iMission];
#ifdefSPDEMO
            if ( mission.m_missionIniFile == "OIL_REFINERY.INI" )
            {           
#endif

            // a campaign and is available and is for the current mod
            if ( mission.IsAvailableInGameType( szGameType ) && mission.m_MapName != "" && CampainMapExistInMapList(mission))
            {
                szMapName = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );

                if ( szMapName == "" ) // failed to find the name, copy the map map (usefull for debugging)
                {
                    szMapName = mission.m_MapName;
                }

                NewItem = R6WindowListBoxItem(m_GameLevelBox.Items.Append(m_GameLevelBox.ListClass));
                NewItem.HelpText = szMapName;
                NewItem.m_Object = mission;                

                if ( mission.m_bIsLocked )
                {
					NewItem.m_bDisabled = true;
                }                
                else if((mission.m_MapName == m_LastMapPlayed) && (ItemToSelect == None))
                {                    
                    ItemToSelect = NewItem;
                }

            }
#ifdefSPDEMO
            }
#endif
            ++iMission;
        }
        ++iCampaign;
    }   
    
    // loop on the mission description and add all none campaign mission
    iMission = 0;
    while ( iMission < r6console.m_aMissionDescriptions.length )
    {
		mission = r6console.m_aMissionDescriptions[iMission];
#ifdefSPDEMO
        if ( mission.m_missionIniFile == "OIL_REFINERY.INI" )
        {           
#endif
        // not a campaign and is available and is for the current mod
        if ( !mission.m_bCampaignMission && mission.IsAvailableInGameType( szGameType ) && mission.m_MapName != "" )
        {            
            szMapName = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );
            if ( szMapName == ""  ) // failed to find the name, copy the map map (usefull for debugging)
            {
                szMapName = mission.m_MapName;
            }
            
            NewItem = R6WindowListBoxItem(m_GameLevelBox.Items.Append(m_GameLevelBox.ListClass));
            NewItem.HelpText = szMapName;
            NewItem.m_Object = mission;            

            if ( mission.m_bIsLocked )
            {
                NewItem.m_bDisabled = true;
            }
            else if((mission.m_MapName == m_LastMapPlayed) && (ItemToSelect == None))
            {                
                ItemToSelect = NewItem;
            }
        }
#ifdefSPDEMO
        }
#endif

        ++iMission;
    }

    if(m_GameLevelBox.Items.Count() > 0)
    {
        if(ItemToSelect != None)
          m_GameLevelBox.SetSelectedItem(ItemToSelect);
        else
            m_GameLevelBox.SetSelectedItem(R6WindowListBoxItem(m_GameLevelBox.Items.Next));

        m_GameLevelBox.MakeSelectedVisible(); 
    }

    //TO DO : FILTER MAPS 
	UpdateBackground();

    m_LastMapPlayed = "";    
}

function InitCustomMission()
{
	local bool bCheckedRvSDir, bCheckCampaignMission;
	local String            szDir;	
    local int               i, iFiles;
    local R6MenuRootWindow  R6Root;
    local R6PlayerCampaign  MyCampaign;    
    local   R6console             r6Console;

    R6Root = R6MenuRootWindow(Root);
    r6console = R6Console( Root.Console );


    MyCampaign          = new class'R6PlayerCampaign'; 

/////////////////////////////////////////////////////////////////
// Parse all available player campains to unlock maps succeeded
/////////////////////////////////////////////////////////////////
	bCheckedRvSDir = false;
	szDir = class'Actor'.static.GetModMgr().GetCampaignDir();
	while(szDir != "")
	{
	    iFiles = R6Root.m_pFileManager.GetNbFile( szDir, "cmp");	
	    for (i=0; i<iFiles; i++)
    	{
			R6Root.m_pFileManager.GetFileName( i, MyCampaign.m_FileName);
    	    MyCampaign.m_FileName = Left(MyCampaign.m_FileName, InStr(MyCampaign.m_FileName,"."));
    	    MyCampaign.m_OperativesMissionDetails = None;
        	MyCampaign.m_OperativesMissionDetails = new(None) class'R6MissionRoster';
        
        	m_pFileManager.LoadCampaign(MyCampaign);
            
			bCheckCampaignMission = false;
			if(i == 0)
				bCheckCampaignMission = true;
			R6Console.UpdateCurrentMapAvailable(MyCampaign, bCheckCampaignMission);
		}
		if((bCheckedRvSDir == false) && (!class'Actor'.static.GetModMgr().IsRavenShield()))
		{
			bCheckedRvSDir = true;
			szDir = class'Actor'.static.GetModMgr().GetDefaultCampaignDir();
		}
		else
		{
			szDir = "";
		}
    }


    // End list of map unlock in each campaign
    m_LastMapPlayed = CustomMissionMap; 

    r6Console.UnlockMissions();
}

//=================================================================================
// Setup Help Text
//=================================================================================
function ToolTip(string strTip) 
{
    m_pHelpWindow.ToolTip(strTip);
}

//=================================================================================
// UpdateBackground: update background
//=================================================================================
function UpdateBackground()
{
	if ( GetLevel().GameTypeUseNbOfTerroristToSpawn( GetLevel().ConvertGameTypeIntToString(m_pButCurrent.m_iButtonID)) )
	{
		m_DifficultyArea.SetCornerType(Top_Corners);
		m_TerroArea.ShowWindow();

		// randomly update the background texture
		Root.SetLoadRandomBackgroundImage("OtherMission");
	}
	else
	{
		m_DifficultyArea.SetCornerType(All_Corners);
		m_TerroArea.HideWindow();

		// randomly update the background texture
		Root.SetLoadRandomBackgroundImage("PracticeMission");
	}
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Root.PaintBackground( C, self);
}

function Notify(UWindowDialogControl C, byte E)
{
    local   R6WindowListBoxItem     SelectedItem;
    local   R6MissionDescription    CurrentMission;
    local   R6WindowBitMap          mapBitmap;
    
    
    if(E == DE_Click)
    {   
        switch(C)
        {

        case m_ButtonMainMenu:
			Root.ChangeCurrentWidget(MainMenuWidgetID);
			break;
		case m_ButtonOptions:
			Root.ChangeCurrentWidget(OptionsWidgetID);
			break;	
        case m_ButtonStart:
            if( ValidateBeforePlanning() )
                GotoPlanning();	
            break;            
        case m_pButPraticeMission:
        case m_pButLoneWolf:
        case m_pButTerroHunt:
        case m_pButHostageRescue:
        case m_pButCurrent:
            m_pButCurrent.m_bSelected = false;
            R6WindowButton(C).m_bSelected = true;
            m_pButCurrent = R6WindowButton(C);
            RefreshList();            
            break;
        case m_GameLevelBox:
            mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);
            SelectedItem = R6WindowListBoxItem(m_GameLevelBox.m_SelectedItem);
            
            if(SelectedItem == None)
            {
                mapBitmap.T = None;
                break;
            }


            if(SelectedItem.m_Object == None)
                break;
            
            CurrentMission  = R6MissionDescription(SelectedItem.m_Object);
            
            if(CurrentMission == None)
                break;
            
            //This is for the current mission overview texture
            //Bottom right og the page
            mapBitmap.R = CurrentMission.m_RMissionOverview;
            mapBitmap.T = CurrentMission.m_TMissionOverview;
            break;
        default:
            break;
        }
        
    }
    else if (E == DE_DoubleClick)
    {
        if (C == m_GameLevelBox) // start a game on a double-click on the list
        {
            if( ValidateBeforePlanning() )
                GotoPlanning();	
        }
    }

}

function CreateButtons()
{
    local   FLOAT   fXOffset, fYOffset, fWidth, fHeight, fYPos;    
    
    fXOffset = 10;
    //fYOffset = 36;
    fYOffset = 26;
    
    fWidth   = 200;
    fHeight  = 25;
    fYPos    = 64;
    
    // define Pratice mission button
    m_pButPraticeMission = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButPraticeMission.ToolTipString		= Localize("Tip","GameType_Practice","R6Menu");
    m_pButPraticeMission.Text				= Localize("CustomMission","ButtonPractice","R6Menu");
    m_pButPraticeMission.m_iButtonID		= GetLevel().ConvertGameTypeToInt("RGM_PracticeMode");
    m_pButPraticeMission.Align				= TA_Left;		
    m_pButPraticeMission.m_buttonFont		= m_LeftButtonFont;
    m_pButPraticeMission.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButPraticeMission.ResizeToText();    
    
    fYPos += fYOffset;
    
    // define LoneWolf mission button
    m_pButLoneWolf = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButLoneWolf.ToolTipString	= Localize("Tip","GameType_LoneWolf","R6Menu");
    m_pButLoneWolf.Text				= Localize("CustomMission","ButtonLoneWolf","R6Menu");
    m_pButLoneWolf.m_iButtonID		= GetLevel().ConvertGameTypeToInt("RGM_LoneWolfMode");
    m_pButLoneWolf.Align			= TA_Left;		
    m_pButLoneWolf.m_buttonFont		= m_LeftButtonFont;
    m_pButLoneWolf.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButLoneWolf.ResizeToText();
    
    fYPos += fYOffset;
    
    // define TerroHunt mission button
    m_pButTerroHunt = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButTerroHunt.ToolTipString		= Localize("Tip","GameType_TerroristHunt","R6Menu");
    m_pButTerroHunt.Text				= Localize("CustomMission","ButtonTerroHunt","R6Menu");
    m_pButTerroHunt.m_iButtonID			= GetLevel().ConvertGameTypeToInt("RGM_TerroristHuntMode");
    m_pButTerroHunt.Align				= TA_Left;		
    m_pButTerroHunt.m_buttonFont		= m_LeftButtonFont;
    m_pButTerroHunt.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButTerroHunt.ResizeToText();
    
    fYPos += fYOffset;
    
    // define HostageRescue mission button
    m_pButHostageRescue = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButHostageRescue.ToolTipString		= Localize("Tip","GameType_HostageRescue","R6Menu");
    m_pButHostageRescue.Text				= Localize("CustomMission","ButtonHostageRescue","R6Menu");
    m_pButHostageRescue.m_iButtonID			= GetLevel().ConvertGameTypeToInt("RGM_HostageRescueMode");
    m_pButHostageRescue.Align				= TA_Left;
    m_pButHostageRescue.m_buttonFont		= m_LeftButtonFont;
    m_pButHostageRescue.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButHostageRescue.ResizeToText();

    switch(CustomMissionGameType)
    {
    case m_pButPraticeMission.m_iButtonID:
        m_pButCurrent = m_pButPraticeMission;
        break;
    case m_pButLoneWolf.m_iButtonID:
        m_pButCurrent = m_pButLoneWolf;
        break;
    case m_pButTerroHunt.m_iButtonID:
        m_pButCurrent = m_pButTerroHunt;
        break;
    case m_pButHostageRescue.m_iButtonID:
        m_pButCurrent = m_pButHostageRescue;
        break;
    default:
        m_pButCurrent = m_pButPraticeMission;
    }
    
    m_pButCurrent.m_bSelected = true;   
}

function BOOL ButtonsUsingDownSizeFont()
{
    local BOOL result;   
    
    if( m_pButPraticeMission.IsFontDownSizingNeeded()   ||
        m_pButLoneWolf.IsFontDownSizingNeeded()         ||
        m_pButTerroHunt.IsFontDownSizingNeeded()        ||
        m_pButHostageRescue.IsFontDownSizingNeeded()
       )
        result = true;    
    
    return result;
    
}



function ForceFontDownSizing()
{
    
    m_pButPraticeMission.m_buttonFont = m_LeftDownSizeFont;
    m_pButLoneWolf.m_buttonFont       = m_LeftDownSizeFont;
    m_pButTerroHunt.m_buttonFont      = m_LeftDownSizeFont;
    m_pButHostageRescue.m_buttonFont  = m_LeftDownSizeFont;

    m_pButPraticeMission.ResizeToText();
    m_pButLoneWolf.ResizeToText();
    m_pButTerroHunt.ResizeToText();
    m_pButHostageRescue.ResizeToText();
}

defaultproperties
{
     CustomMissionGameType=3
     CustomMissionMap="CS_de_dust"
}
