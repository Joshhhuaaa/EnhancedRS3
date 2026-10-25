//=============================================================================
//  R6MenuRootWindow.uc : (Root of all windows)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/25 * Created by Chaouky Garram
//	  2001/11/12 * Modified by Alexandre Dionne Support multi-Menus	
//=============================================================================
class R6MenuRootWindow extends R6WindowRootWindow;


#ifdefMPDEMO
#exec OBJ LOAD FILE=..\Sounds\Music.uax PACKAGE=Music
#endif

// Joshua - A group package here breaks the texture paths with retail UCC
//#exec OBJ LOAD FILE="..\textures\R6MenuBG.utx" Package="R6MenuBG.Backgrounds"
#exec OBJ LOAD FILE="..\textures\R6MenuBG.utx" Package="R6MenuBG"

// Don't remove: they are here only to make sure they are referenced (needed by cpp code)
var Texture m_BGTexture0;
var Texture m_BGTexture1;

var R6MenuWidget				m_CurrentWidget;
var R6MenuWidget                m_PreviousWidget;
 
#ifndefMPDEMO
var R6MenuIntelWidget			m_IntelWidget;
var R6MenuPlanningWidget		m_PlanningWidget;
var R6MenuExecuteWidget		    m_ExecuteWidget;
#endif

var R6MenuMainWidget			m_MainMenuWidget;

#ifndefMPDEMO
var R6MenuSinglePlayerWidget	m_SinglePlayerWidget;
var R6MenuCustomMissionWidget	m_CustomMissionWidget;
var R6MenuTrainingWidget        m_TrainingWidget;
#endif

#ifndefSPDEMO
var R6MenuMultiplayerWidget		m_MultiPlayerWidget;
#endif
var R6MenuOptionsWidget			m_OptionsWidget;
var R6MenuCreditsWidget			m_CreditsWidget;

#ifndefMPDEMO
var R6MenuGearWidget			m_GearRoomWidget;

var R6MenuCDKeyManager m_pMenuCDKeyManager;
#endif

#ifndefSPDEMO
var R6MenuMPCreateGameWidget    m_pMPCreateGameWidget;
var R6MenuUbiComWidget			m_pUbiComWidget;

var R6MenuUbiComModsWidget m_pUbiComModsWidget;
var R6MenuNonUbiWidget          m_pNonUbiWidget;
#endif
var R6MenuQuit                  m_pMenuQuit;

var R6FileManager				m_pFileManager;

/////////////////////////////////////////////////////////////////////////////////
var Array<R6Operative>          m_GameOperatives;
var bool                        m_bReloadPlan;      //Load default plan, this is to be able to retouch last plan
var bool                        m_bLoadingPlanning;
var bool                        m_bPlayerPlanInitialized; //this help us find out if we have to prompt the player with the loading default planing pop up
var bool                        m_bPlayerDoNotWant3DView;
var bool                        m_bPlayerWantLegend;
/////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////
//                                  POP UP
/////////////////////////////////////////////////////////////////////////////////////////
var R6WindowPopUpBox            m_PopUpSavePlan, m_PopUpLoadPlan; 

var EPopUpID        m_ePopUpID;  // ID of currently active pop up menu
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

var Sound m_MainMenuMusic;          // Music for the MainMenu

var bool                        bShowlog;

var bool m_bJoinServerProcess;		// true, we currently join a server

function Created()
{
    local R6WindowEditBox EditPopUpBox;
    local R6WindowTextListBox SavedPlanningListBox;
    local R6GameOptions pGameOptions;

    if(bShowLog)
    {
        log("R6MenuRootWindow Created()");
    }
    super(UWindowRootWindow).Created();
    R6Console(Console).InitializedGameService();
    m_pFileManager = new Class'Engine.R6FileManager';
    if(m_pFileManager == none)
    {
        log("m_pFileManager == NONE");
    }
    pGameOptions = class'Actor'.static.GetGameOptions();
    m_bPlayerDoNotWant3DView = pGameOptions.Hide3DView;
    m_eRootId = RootID_R6Menu;
    SetResolution(640.0, 480.0);
    m_IntelWidget = R6MenuIntelWidget(CreateWindow(MenuClassDefines.ClassIntelWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_IntelWidget.Close();
    m_PlanningWidget = R6MenuPlanningWidget(CreateWindow(MenuClassDefines.ClassPlanningWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_PlanningWidget.Close();
    m_ExecuteWidget = R6MenuExecuteWidget(CreateWindow(MenuClassDefines.ClassExecuteWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_ExecuteWidget.Close();
    m_SinglePlayerWidget = R6MenuSinglePlayerWidget(CreateWindow(MenuClassDefines.ClassSinglePlayerWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_SinglePlayerWidget.Close();
    m_CustomMissionWidget = R6MenuCustomMissionWidget(CreateWindow(MenuClassDefines.ClassCustomMissionWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_CustomMissionWidget.Close();
    m_TrainingWidget = R6MenuTrainingWidget(CreateWindow(MenuClassDefines.ClassTrainingWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_TrainingWidget.Close();
    HarmonizeMenuFonts();
    m_MultiPlayerWidget = R6MenuMultiPlayerWidget(CreateWindow(MenuClassDefines.ClassMultiPlayerWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_MultiPlayerWidget.Close();
    m_OptionsWidget = R6MenuOptionsWidget(CreateWindow(MenuClassDefines.ClassOptionsWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_OptionsWidget.Close();
    m_CreditsWidget = R6MenuCreditsWidget(CreateWindow(MenuClassDefines.ClassCreditsWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_CreditsWidget.Close();
    m_GearRoomWidget = R6MenuGearWidget(CreateWindow(MenuClassDefines.ClassGearWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_GearRoomWidget.Close();
    m_pMenuCDKeyManager = R6MenuCDKeyManager(CreateWindow(MenuClassDefines.ClassMenuCDKeyManager, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_pMenuCDKeyManager.Close();
    m_pMPCreateGameWidget = R6MenuMPCreateGameWidget(CreateWindow(MenuClassDefines.ClassMPCreateGameWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_pMPCreateGameWidget.Close();
    m_pUbiComWidget = R6MenuUbiComWidget(CreateWindow(MenuClassDefines.ClassUbiComWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_pUbiComWidget.Close();
    m_pUbiComModsWidget = R6MenuUbiComModsWidget(CreateWindow(Class'R6Menu.R6MenuUbiComModsWidget', WinLeft, WinTop, WinWidth, WinHeight, self));
    m_pUbiComModsWidget.Close();
    m_pNonUbiWidget = R6MenuNonUbiWidget(CreateWindow(MenuClassDefines.ClassNonUbiComWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_pNonUbiWidget.Close();
    m_pMenuQuit = R6MenuQuit(CreateWindow(MenuClassDefines.ClassQuitWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_pMenuQuit.Close();
    m_MainMenuWidget = R6MenuMainWidget(CreateWindow(MenuClassDefines.ClassMainWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
    m_MainMenuWidget.Close();
    AssignShowFirstWidget();
    m_CurrentWidget.SetMousePos(WinWidth * 0.5, WinHeight * 0.5);
    m_ePopUpID = EPopUpID_None;
    m_PopUpSavePlan = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0, 0.0, 640.0, 480.0));
    m_PopUpSavePlan.CreateStdPopUpWindow(Localize("POPUP", "PopUpTitle_SavePlan", "R6Menu"), 30.0, 188.0, 150.0, 264.0, 180.0);
    m_PopUpSavePlan.CreateClientWindow(Class'R6Menu.R6MenuSavePlan', false, true);
    m_PopUpSavePlan.m_ePopUpID = EPopUpID_SavePlanning;
    m_PopUpSavePlan.HideWindow();
    m_PopUpLoadPlan = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0, 0.0, 640.0, 480.0));
    m_PopUpLoadPlan.CreateStdPopUpWindow(Localize("POPUP", "PopUpTitle_Load", "R6Menu"), 30.0, 188.0, 150.0, 264.0, 180.0);
    m_PopUpLoadPlan.CreateClientWindow(Class'R6Menu.R6MenuLoadPlan', false, true);
    m_PopUpLoadPlan.m_ePopUpID = EPopUpID_LoadPlanning;
    m_PopUpLoadPlan.HideWindow();
    GUIScale = 1.0;
    if(!R6Console(Console).m_bStartedByGSClient)
    {
        GetPlayerOwner().PlayMusic(m_MainMenuMusic, true);
    }
}

function AssignShowFirstWidget()
{
#ifndefSPDEMO
	if ( R6Console(Console).m_bStartedByGSClient) // when the engine is "started" by Ubi.com
	{
		m_CurrentWidget = m_pUbiComWidget;
	}
    else if (R6Console(Console).m_bNonUbiMatchMaking)
    {
		m_CurrentWidget = m_pNonUbiWidget;
    }
    else if ( R6Console(Console).m_bNonUbiMatchMakingHost)
    {
		m_CurrentWidget = m_pMPCreateGameWidget;
		m_pMPCreateGameWidget.RefreshCreateGameMenu();
    }
	else
	{
		m_CurrentWidget = m_MainMenuWidget;
	}
#endif
#ifdefSPDEMO
    m_CurrentWidget = m_MainMenuWidget;
#endif

	m_CurrentWidget.ShowWindow();
}

function Set3dView(bool bSelected)
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.Hide3DView = bSelected;
    m_bPlayerDoNotWant3DView = bSelected;
}

function DrawMouse(Canvas C) 
{
	local FLOAT X, Y;
    local FLOAT fMouseClipX, fMouseClipY;
    local Texture MouseTex;
	
    if(Console.ViewportOwner.bWindowsMouseAvailable)
	{
		// Set the windows cursor...
		Console.ViewportOwner.SelectedCursor = MouseWindow.Cursor.WindowsCursor;
	}
	else
	{
		C.SetDrawColor(255,255,255);
		C.Style =5; //STY_Alpha

        // Draw the mouse cursor
        if( m_bUseAimIcon == true )
        {
	        C.SetPos(MouseX * GUIScale - AimCursor.HotX, MouseY * GUIScale - AimCursor.HotY);	
            MouseTex = AimCursor.tex;
        }
        else if( m_bUseDragIcon == true )
        {
	        C.SetPos(MouseX * GUIScale - DragCursor.HotX, MouseY * GUIScale - DragCursor.HotY);	
            MouseTex = DragCursor.tex;
        }
        else
        {
		    C.SetPos(MouseX * GUIScale - MouseWindow.Cursor.HotX, MouseY * GUIScale - MouseWindow.Cursor.HotY);	
            MouseTex = MouseWindow.Cursor.tex;
        }
        // Set the clipping of the mouse to not render the mouse over the laptop
        fMouseClipX = m_CurrentWidget.m_fRightMouseXClipping *GUIScale;
        fMouseClipY = m_CurrentWidget.m_fRightMouseYClipping *GUIScale;
        C.SetClip( fMouseClipX, fMouseClipY);

        if(MouseTex != none)
        {
            C.DrawTileClipped( MouseTex, MouseTex.USize, MouseTex.VSize, 0, 0, MouseTex.USize, MouseTex.VSize );
        }
		C.Style =1; 

	}
}

function ResetMenus( optional BOOL _bConnectionFailed)
{
    //This function is called when we return to main menu,
    //Add here any new widget that need to reset after we went
    //in the main menu

	if (_bConnectionFailed)
	{
#ifndefSPDEMO
		m_MultiPlayerWidget.ResetMultiplayerMenu();
        // TODO for NonUbiMatchMaking!!!!
#endif
	}
	else
	{
#ifndefMPDEMO
		m_IntelWidget.Reset();
		m_PlanningWidget.Reset();
		m_bPlayerPlanInitialized = false;   //This is for the gear menu plan pop up
#endif
	}
}

function UpdateMenus(INT iWhatToUpdate)
{
#ifndefMPDEMO

	// in some case (multiplayer error msg that re-create main root), when we switch between single/multi game, 
	// you have a valid OwnerCtrl in SetTeamActive() that call
	// this function before m_PlanningWidget was initialize in self Created(). Prevent access none only

	if (m_PlanningWidget != None)
    m_PlanningWidget.ResetTeams(iWhatToUpdate);
#endif
}

function MoveMouse(float X, float Y)
{
    if(m_CurrentWidget != None)
        m_CurrentWidget.SetMousePos( X, Y);

    Super.MoveMouse( Console.MouseX, Console.MouseY);
}

function ClosePopups()
{
#ifndefMPDEMO
    if(m_CurrentWidget == m_PlanningWidget)
    {
        m_PlanningWidget.Hide3DAndLegend();
    }
#endif
}

function BOOL IsInsidePlanning()
{
#ifdefDEBUG
	local BOOL bShowWidgetName;

	if (bShowWidgetName)
		log("IsInsidePlanning WidgetID was: "@GetGameWidgetID(m_ePrevWidgetInUse));
#endif

	return	(
			(m_ePrevWidgetInUse == IntelWidgetID) ||
			(m_ePrevWidgetInUse == GearRoomWidgetID) ||
			(m_ePrevWidgetInUse == PlanningWidgetID) ||
			(m_ePrevWidgetInUse == ExecuteWidgetID) ||
			(m_ePrevWidgetInUse == RetryCampaignPlanningID) ||
			(m_ePrevWidgetInUse == RetryCustomMissionPlanningID)
			);
}



function ChangeCurrentWidget( eGameWidgetID widgetID)
{
    local BOOL bDontQuitNow;

	m_bJoinServerProcess = false;

	if (widgetID == PreviousWidgetID)
	{
	    m_eCurWidgetInUse = m_ePrevWidgetInUse;
		m_ePrevWidgetInUse = WidgetID_None;
	}
	else
	{
		m_ePrevWidgetInUse = m_eCurWidgetInUse;
	    m_eCurWidgetInUse = widgetID;
        if(m_ePrevWidgetInUse == PlanningWidgetID)
        {
            if(R6PlanningCtrl(GetPlayerOwner())!=none)
                R6PlanningCtrl(GetPlayerOwner()).CancelActionPointAction();
        }
    }

	switch( widgetID)
	{
#ifndefMPDEMO
	case SinglePlayerWidgetID :
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_SinglePlayerWidget;
		m_CurrentWidget.ShowWindow();
		break;
    case TrainingWidgetID :
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_TrainingWidget;
		m_CurrentWidget.ShowWindow();
		break;
#endif
	case MainMenuWidgetID :
#ifndefSPDEMO
		if ( m_CurrentWidget == m_MultiPlayerWidget)
	        R6MenuMultiPlayerWidget(m_CurrentWidget).BackToMainMenu();
#endif
		
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_MainMenuWidget;
#ifdefMPDEMO
		GetPlayerOwner().PlaySound(Sound'Play_Theme_MusicSilence', SLOT_Music);
#endif
		m_CurrentWidget.ShowWindow();
        ResetMenus();
		break;
#ifndefMPDEMO
	case IntelWidgetID : //This should only be called from the navplanning
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_IntelWidget;
		m_CurrentWidget.ShowWindow();
		break;
    case RetryCustomMissionPlanningID:        
        ResetCustomMissionOperatives();
        m_bReloadPlan=true;
        m_bLoadingPlanning = true;
        m_bPlayerPlanInitialized = true;
        GotoPlanning();
        break;
	case PlanningWidgetID :             //This should only be called from the navplanning
        if(m_CurrentWidget != m_PlanningWidget)
        {
		    m_CurrentWidget.HideWindow();
            m_PreviousWidget = m_CurrentWidget;
		    m_CurrentWidget = m_PlanningWidget;
		    m_CurrentWidget.ShowWindow();
        }
		break;
    case ExecuteWidgetID:
        m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget  = m_ExecuteWidget;
		m_CurrentWidget.ShowWindow();
        break;
	case GearRoomWidgetID : //This should only be called from the navplanning
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_GearRoomWidget;
		m_CurrentWidget.ShowWindow();
		break;		
	case CustomMissionWidgetID :
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_CustomMissionWidget;
		m_CurrentWidget.ShowWindow();
		break;
#endif
	case MultiPlayerWidgetID :    
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
#ifndefSPDEMO // This case should never happens
		m_CurrentWidget = m_MultiPlayerWidget;
#endif
#ifdefMPDEMO
		GetPlayerOwner().PlaySound(Sound'Play_Theme_ServerMenuMusic', SLOT_Music);
#endif
		m_CurrentWidget.ShowWindow();
		break;	        
#ifndefSPDEMO
	case UbiComWidgetID :    
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_pUbiComWidget;
		m_CurrentWidget.ShowWindow();
		break;	        
    case UbiComModWidgetID:
		m_CurrentWidget.HideWindow();
		m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_pUbiComModsWidget;
		m_CurrentWidget.ShowWindow();
		break;
	case MultiPlayerError:
        if (R6Console(Console).m_bStartedByGSClient)
        {
            ChangeCurrentWidget(UbiComWidgetID);
            m_pUbiComWidget.PromptConnectionError();
        }
        else if (R6Console(Console).m_bNonUbiMatchMaking)
        {
            ChangeCurrentWidget(NonUbiWidgetID);
            m_pNonUbiWidget.PromptConnectionError();
        }
        else if ( R6Console(Console).m_bNonUbiMatchMakingHost)
        {
            // IMPOSSIBLE
        }
        else
        {
        ChangeCurrentWidget(MultiPlayerWidgetID);
        m_MultiPlayerWidget.PromptConnectionError();
        }
		break;	        
    case MultiPlayerErrorUbiCom:
        ChangeCurrentWidget(UbiComWidgetID);
        m_pUbiComWidget.PromptConnectionError();
		break;	   
#endif        
	case OptionsWidgetID :
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_OptionsWidget;
		m_OptionsWidget.RefreshOptions();
		m_CurrentWidget.ShowWindow();
		break;	
	case CreditsWidgetID :
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
        m_CurrentWidget = m_CreditsWidget;
		m_CurrentWidget.ShowWindow();
        break;
#ifndefSPDEMO
    case MPCreateGameWidgetID:
		m_CurrentWidget.HideWindow();
        m_PreviousWidget = m_CurrentWidget;
		m_CurrentWidget = m_pMPCreateGameWidget;
		m_pMPCreateGameWidget.RefreshCreateGameMenu();
		m_CurrentWidget.ShowWindow();
        break;
#endif
#ifndefMPDEMO
    case RetryCampaignPlanningID:        
        m_bReloadPlan=true; 
        m_bPlayerPlanInitialized = true;
        GotoCampaignPlanning(true);
        break;
    case CampaignPlanningID:     
        GotoCampaignPlanning(false);
        break;
#endif


    case MenuQuitID :
#ifdefMPDEMO
        bDontQuitNow = true;
#endif
#ifdefSPDEMO
        bDontQuitNow = true;
#endif
        if (bDontQuitNow)
        {
            m_CurrentWidget.HideWindow();
            m_PreviousWidget = m_CurrentWidget;
            m_CurrentWidget = m_pMenuQuit;
            m_CurrentWidget.ShowWindow();
        }
        else
        {
            Root.DoQuitGame();
        }
        break;

    case PreviousWidgetID:           //Used For back buttuo in options Widget
        if(m_PreviousWidget != None)
        {
            m_CurrentWidget.HideWindow();            
		    m_CurrentWidget = m_PreviousWidget;
            m_PreviousWidget   = None;
		    m_CurrentWidget.ShowWindow();
        }   		
        break;
	default :
		break;		
	}
}

function BOOL PlanningShouldProcessKey()
{
    if( (m_ePopUpID == EPopUpID_None) && 
        (m_eCurWidgetInUse == PlanningWidgetID))
        return true;

    return false;
}

function BOOL PlanningShouldDrawPath()
{
    if(m_eCurWidgetInUse == PlanningWidgetID)
        return true;

    return false;
}

function ResetCustomMissionOperatives()
{
    local R6Operative tmpOperative;
    local Class<R6Operative> tmpOperativeClass;
    local int iNbArrayElements, iNbTotalOperatives, i;
    local R6ModMgr pModManager;

    pModManager = class'Actor'.static.GetModMgr();
    m_GameOperatives.Remove(0, m_GameOperatives.Length);
    iNbArrayElements = R6Console(Console).m_CurrentCampaign.m_OperativeClassName.Length;

    for(i = 0; i < iNbArrayElements; i++)
    {
        tmpOperative = new (none) Class<R6Operative>(DynamicLoadObject(R6Console(Console).m_CurrentCampaign.m_OperativeClassName[i], Class'Core.Class'));
        m_GameOperatives[i] = tmpOperative;
    }
    iNbTotalOperatives = i;
    if(pModManager.m_pCurrentMod.m_bUseCustomOperatives == true)
    {

        for(i = 0; i < pModManager.GetPackageMgr().GetNbPackage(); i++)
        {

            for(tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, Class'R6Game.R6Operative')); tmpOperativeClass != none; tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetNextClassFromPackage()))
            {
                tmpOperative = new (none) tmpOperativeClass;
                if(tmpOperative != none)
                {
                    m_GameOperatives[iNbTotalOperatives] = tmpOperative;
                    iNbTotalOperatives++;
                }
            }
        }
    }
}

function KeyType(int iInputKey, float X, float Y)
{
    //Send the message to the current widget
    m_CurrentWidget.KeyType(iInputKey, X, Y);
}


function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
    if(bShowlog)
    {
        switch(Msg) 
        {
	    case WM_KeyDown:					
            log("R6MenuRoot::WindowEvent Msg= WM_KeyDown Key"@Key);
		    break;
	    case WM_KeyUp:		
            log("R6MenuRoot::WindowEvent Msg= WM_KeyUp Key"@Key);
		    break;
        case WM_KeyType:		
            log("R6MenuRoot::WindowEvent Msg= WM_KeyType Key"@Key);
		    break;
	    }

    }

	if (Msg != WM_Paint)
	{
		if ((Console.m_bInterruptConnectionProcess) || (R6Console(Console).m_bRenderMenuOneTime))// menus are re-create, wait...
			return;

		if (m_bJoinServerProcess)
		{
			if (Msg == WM_KeyDown)
			{
				if (Key == Root.Console.EInputKey.IK_Escape)
				{
					// user interrupt connection, advice console!
					Console.m_bInterruptConnectionProcess = true;		
					return;
				}
			}
		}
	}

	switch(Msg) {
	case WM_KeyDown:
		if(HotKeyDown(Key, X, Y))
			return;
		break;
	case WM_KeyUp:
		if(HotKeyUp(Key, X, Y))
			return;
		break;
	}

    
    if(Msg == WM_Paint || !WaitModal())
    {
        Super.WindowEvent(Msg, C, X, Y, Key);
    }	    
    else if(WaitModal())
    {
         ModalWindow.WindowEvent(Msg, C, X - ModalWindow.WinLeft, Y - ModalWindow.WinTop, Key);        
    }    
    
}


function GotoCampaignPlanning(bool _bRetrying)
{

#ifndefMPDEMO    
    local R6PlayerCampaign      PlayerCampaign;    
    local int                   iNbArrayElements,i;  
    local R6MissionDescription  CurrentMission;
    local R6Console             CurrentConsole;   
    
    //Init var
    CurrentConsole = R6Console(Console);
    PlayerCampaign = CurrentConsole.m_PlayerCampaign;
    iNbArrayElements=0;

    if(bShowlog)log("start GotoPlanning PlayerCampaign.m_FileName=" $PlayerCampaign.m_FileName );

    CurrentConsole.m_CurrentCampaign = new(none) class'R6Campaign'; 
    CurrentConsole.m_CurrentCampaign.InitCampaign( GetLevel(), PlayerCampaign.m_CampaignFileName, CurrentConsole );
    //set the mission he will play next
    CurrentMission = CurrentConsole.m_CurrentCampaign.m_missions[PlayerCampaign.m_iNoMission];

    
    CurrentConsole.master.m_StartGameInfo.m_CurrentMission = CurrentMission;
    if(bShowlog)log("m_CurrentCampaign"@CurrentConsole.m_CurrentCampaign);
    if(bShowlog)log("currentMission"@CurrentMission);


    //Set info for the game 
    CurrentConsole.master.m_StartGameInfo.m_MapName = CurrentMission.m_MapName;
    if(bShowlog)log("currentMission.m_MapName"@CurrentMission.m_MapName);        
    CurrentConsole.master.m_StartGameInfo.m_DifficultyLevel = PlayerCampaign.m_iDifficultyLevel;
    if(bShowlog)log("PlayerCampaign.m_iDifficultyLevel"@PlayerCampaign.m_iDifficultyLevel);
	CurrentConsole.master.m_StartGameInfo.m_GameMode = "R6Game.R6StoryModeGame";

    iNbArrayElements = PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives.Length;
    if(bShowlog)log("m_MissionOperatives.Length"@PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives.Length);  

    //Empty the game operatives
    m_GameOperatives.remove(0, m_GameOperatives.length); 

    for (i=0; i< iNbArrayElements; i++)
    {        
        m_GameOperatives[i] = PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives[i];
    }    
    
    if(bShowlog)log("end GotoPlanning");

    m_bLoadingPlanning = true;
    if(_bRetrying)    //No need to reload the map
        GotoPlanning();
    else    
        CurrentConsole.PreloadMapForPlanning();    
    
#endif	
    
}

function GotoPlanning()
{
#ifndefMPDEMO
    local Player                CurrentPlayer;
    local PlayerController      NewController;
    local R6IORotatingDoor      RotDoor;
    local R6DeploymentZone      DeployZone;
    
    if(m_bLoadingPlanning)
    {
        if(m_bReloadPlan)
        {   
            //All this should prevent us to reload the map each time we wan't to change the plan
            R6GameInfo(GetLevel().Game).RestartGameMgr();

            CurrentPlayer = GetPlayerOwner().Player;
            GetPlayerOwner().Destroy();
            NewController = GetLevel().Spawn(class'R6Game.R6PlanningCtrl');
            R6GameInfo(GetLevel().Game).SetController(NewController,CurrentPlayer);
            R6GameInfo(GetLevel().Game).bRestartLevel = false;
            R6GameInfo(GetLevel().Game).RestartPlayer(NewController);
            R6PlanningCtrl(NewController).SetPlanningInfo();
           
            NewController.SpawnDefaultHUD();            
            NewController.ChangeInputSet(1);
                        
            R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
   
            R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.LoadPlanning(
						"Backup", "Backup", "Backup", "", "Backup.pln",
                        console.master.m_StartGameInfo);        
            R6PlanningCtrl(GetPlayerOwner()).InitNewPlanning(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam);           

            m_GearRoomWidget.LoadRosterFromStartInfo();
            m_bReloadPlan = false;
        }
        else
        {
            m_GearRoomWidget.Reset();
        }

        m_bLoadingPlanning = false;
        ChangeCurrentWidget(IntelWidgetID);
    }    
#endif
}

function LaunchQuickPlay()
{
    local string szFileName;    
    
    // load default action planning
    szFileName = R6MissionDescription(R6Console(console).master.m_StartGameInfo.m_CurrentMission).m_ShortName;
    szFileName = szFileName $ R6AbstractGameInfo(GetLevel().Game).m_szDefaultActionPlan;
    
    if (LoadAPlanning( Caps(szFileName)))
    {
#ifndefMPDEMO                        
        // play
        if(m_GearRoomWidget.IsTeamConfigValid())
        {                  
            StopWidgetSound();
            m_PlanningWidget.m_PlanningBar.m_TimeLine.Reset();
            LeaveForGame(false, 0);				
        }    
        else
        {
            SimplePopUp(Localize("POPUP","INCOMPLETEPLANNING","R6Menu"),Localize("POPUP","INCOMPLETEPLANNINGPROBLEM","R6Menu"),EPopUpID_PlanningIncomplete, MessageBoxButtons.MB_OK);
        }
#endif
    }
   
}

function NotifyAfterLevelChange()
{    
    //Will go to planning when ever the level is loaded
    //this is usefull when we need to preload the map first
    GotoPlanning();
}

//==============================================================================
// PopUp The good menu
//==============================================================================
function PopUpMenu(OPTIONAL bool _bautoLoadPrompt)
{
    local int                           i,iMax;
    local R6WindowListBoxItem           NewItem;
    local string                        szFileName;


    switch ( m_ePopUpID )
    {
        case EPopUpID_SavePlanning:         
			FillListOfSavedPlan( R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan);
			m_PopUpSavePlan.ShowWindow();
	        // force the cursor on the edit box
	        R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pEditSaveNameBox.LMouseDown(0,0);
            break;
        case EPopUpID_LoadPlanning:      
            
            if(_bautoLoadPrompt)
            {                
                m_PopUpLoadPlan.ModifyPopUpFrameWindow( Localize("POPUP","PopUpTitle_Load","R6Menu"), 30, 165, 150, 310, 180);    
                m_PopUpLoadPlan.AddDisableDLG();
                m_bPlayerPlanInitialized = true;
            }             
            else    
            {
                m_PopUpLoadPlan.ModifyPopUpFrameWindow( Localize("POPUP","PopUpTitle_Load","R6Menu"), 30, 188, 150, 264, 180);    
                m_PopUpLoadPlan.RemoveDisableDLG();
            }
                
            
			FillListOfSavedPlan(R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan);
            m_PopUpLoadPlan.ShowWindow();
            break;                 
    }
}

function SimplePopUp( string _szTitle, string _szText, ePopUpID _ePopUpID, optional INT _iButtonsType, OPTIONAL BOOL bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
	if (OwnerWindow == None)
		Super.SimplePopUp( _szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, Self);
	else
		Super.SimplePopUp( _szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, OwnerWindow);
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
    local string szFileName;
    local R6WindowListBoxItem SelectedItem;
    local R6WindowTextListBox SavedPlanningListBox;
    local R6StartGameInfo StartGameInfo;
    local R6MissionDescription mission;
    local string szMapName, szGameTypeDirName, szEnglishGTDirectory;

    super.PopUpBoxDone(Result, _ePopUpID);
    if(Result == MR_OK)
    {
        switch(_ePopUpID)
        {
            case EPopUpID_SaveFileExist:
            case EPopUpID_SavePlanning:
                szFileName = R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pEditSaveNameBox.GetValue();
                if(szFileName != "")
                {
                    if(_ePopUpID == EPopUpID_SaveFileExist)
                    {
                        m_PopUpSavePlan.HideWindow();                        
                    }
                    else
                    {
                        if(IsSaveFileAlreadyExist(szFileName))
                        {
                            m_ePopUpID = EPopUpID_SavePlanning;
                            PopUpMenu();
                            SimplePopUp(Localize("POPUP", "SaveFileExist", "R6Menu"), Localize("POPUP", "SaveFileExistMsg", "R6Menu"), EPopUpID_SaveFileExist);
                            return;
                        }
                    }
                    R6PlanningCtrl(GetPlayerOwner()).ResetAllID();
                    m_GearRoomWidget.SetStartTeamInfoForSaving();
                    R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
                    StartGameInfo = Console.Master.m_StartGameInfo;
                    mission = R6MissionDescription(StartGameInfo.m_CurrentMission);
                    szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
                    if(szMapName == "")
                    {
                        szMapName = string(GetLevel().Outer.Name);
                    }
                    GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
                    if(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.SavePlanning(mission.m_MapName, szMapName, szEnglishGTDirectory, szGameTypeDirName, szFileName, StartGameInfo) == false)
                    {
                        SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), (szFileName @ ":") @ (Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), EPopUpID_FileWriteError, MessageBoxButtons.MB_OK);
                    }
                }
                break;
            case EPopUpID_LoadPlanning:
                SavedPlanningListBox = R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan;
                if(SavedPlanningListBox.m_SelectedItem != none)
                {
                    szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
                    if(szFileName == "")
                    {
                        break;
                    }
                    LoadAPlanning(szFileName);
                }
                break;
            case EPopUpID_SaveDelPlan:
                SavedPlanningListBox = R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan;
                if(SavedPlanningListBox.m_SelectedItem != none)
                {
                    szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
                    if(szFileName == "")
                    {
                        break;
                    }
                    if(DeleteAPlanning(szFileName))
                    {
                        FillListOfSavedPlan(R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan);
                    }
                }
                m_PopUpSavePlan.ShowWindow();
                return;
                break;
            case EPopUpID_LoadDelPlan:
                SavedPlanningListBox = R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan;
                if(SavedPlanningListBox.m_SelectedItem != none)
                {
                    szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
                    if(szFileName == "")
                    {
                        break;
                    }
                    if(DeleteAPlanning(szFileName))
                    {
                        FillListOfSavedPlan(R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan);
                    }
                }
                m_PopUpLoadPlan.ShowWindow();
                return;
                break;
            case EPopUpID_OverWriteCampaign:
                m_SinglePlayerWidget.TryCreatingCampaign();
                break;
            case EPopUpID_QuickPlay:
                LaunchQuickPlay();
                return;
                break;
            case EPopUpID_DeleteCampaign:
                m_SinglePlayerWidget.DeleteCurrentSelectedCampaign();
                break;
            case EPopUpID_LeavePlanningToMain:
                Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
                R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
                ChangeCurrentWidget(MainMenuWidgetID);
                break;
            case EPopUpID_DelAllWayPoints:
                R6PlanningCtrl(GetPlayerOwner()).DeleteAllNode();
                break;
            case EPopUpID_DelAllTeamsWayPoints:
                R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
                break;
            case EPopUpID_InvalidLoad:
            case EPopUpID_PlanningIncomplete:
            case EPopUpID_InvalidPassword:
            case EPopUp_ID_GSCoOpMaxError:
                break;
            case EPopUpID_PlanDeleteError:
                return;
                break;
        }
        
    }
    else
    {
        switch(_ePopUpID)
        {
            case EPopUpID_LoadDelPlan:
                m_PopUpLoadPlan.ShowWindow();
                return;
                break;
            case EPopUpID_SaveDelPlan:
                m_PopUpSavePlan.ShowWindow();
                return;
                break;
            case EPopUpID_SaveFileExist:
                m_ePopUpID = EPopUpID_SavePlanning;
                return;
                break;
            default:
                break;
        }
    }
    if((m_CurrentWidget == m_PlanningWidget) && !m_bPlayerDoNotWant3DView)
    {
        m_PlanningWidget.m_3DButton.m_bSelected = true;
        m_PlanningWidget.m_3DWindow.Toggle3DWindow();
        R6PlanningCtrl(GetPlayerOwner()).Toggle3DView();
    }
    if((m_CurrentWidget == m_PlanningWidget) && m_bPlayerWantLegend)
    {
        m_PlanningWidget.m_LegendWindow.ToggleLegend();
        m_PlanningWidget.m_LegendButton.m_bSelected = true;
    }
    if(_ePopUpID == EPopUpID_FileWriteErrorBackupPln)
    {
        m_GearRoomWidget.SetStartTeamInfo();
        R6Console(Console).LaunchR6Game();
    }
    m_ePopUpID = EPopUpID_None;
}

function StopPlayMode()
{
#ifndefMPDEMO
    m_PlanningWidget.m_PlanningBar.m_TimeLine.StopPlayMode();
#endif
}

//==============================================================================
// StopWidgetSound: stop the sound for the current widget
//==============================================================================
function StopWidgetSound()
{
#ifndefMPDEMO
	if (m_eCurWidgetInUse == IntelWidgetID)
	{
		m_IntelWidget.StopIntelWidgetSound();
	}
#endif
}

function SetServerOptions()
{
#ifndefSPDEMO
    if ((m_pMPCreateGameWidget != None) && (m_pMPCreateGameWidget.m_pCreateTabOptions != None))
        m_pMPCreateGameWidget.m_pCreateTabOptions.SetServerOptions();
#endif
}


//===========================================================================================
// FillListOfSavedPlan: Fill a list, R6WindowTextListBox, of saved plan
//===========================================================================================
function FillListOfSavedPlan( R6WindowTextListBox _pListOfSavedPlan)
{
	local R6WindowListBoxItem NewItem;
	local string szFileName;
	local INT i, iMax;
    local R6StartGameInfo               startGameInfo;
    local R6MissionDescription          mission;
    local string                        szMapName;	
    local string                        szGameTypeDirName;
    local string                        szEnglishGTDirectory;

	_pListOfSavedPlan.Clear();

    //Find the Menu name of the map
    startGameInfo = console.Master.m_StartGameInfo;
    mission = R6MissionDescription(startGameInfo.m_CurrentMission);

    GetLevel().GetGameTypeSaveDirectories( szGameTypeDirName, szEnglishGTDirectory );

    szMapName = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );
    if( szMapName == "" ) // failed to find the name, use the map filename
    {
        szMapName = string(GetLevel().Outer.Name);
    }

    //Get a list of the avalaible files. And fill the listbox
    iMax = R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.GetNumberOfFiles(szMapName,  szGameTypeDirName);            
                
    for(i=0; i<iMax; i++)
    {
        R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.GetFileName( i, szFilename);
        if(szFilename != "")
        {
			szFileName = Left( szFileName, InStr( szFileName, ".PLN"));
            NewItem = R6WindowListBoxItem(_pListOfSavedPlan.Items.Append(class'R6WindowListBoxItem'));
            NewItem.HelpText = szFilename;
        }
    }
}

//===========================================================================================
// IsSaveFileAlreadyExist: A file with the same name already exist?
//===========================================================================================
function BOOL IsSaveFileAlreadyExist( string _szFileName)
{   
	local string                        szPathAndFileName; 
    local string                        szGameTypeDirName;
    local R6StartGameInfo               startGameInfo;
    local string                        szMapName;
    local R6MissionDescription          mission;
    local string                        szEnglishGTDirectory;

    startGameInfo = console.Master.m_StartGameInfo;
    mission = R6MissionDescription(startGameInfo.m_CurrentMission);

    GetLevel().GetGameTypeSaveDirectories( szGameTypeDirName, szEnglishGTDirectory );

    szMapName = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );
    if( szMapName == "" ) // failed to find the name, use the map filename
    {
        szMapName = string(GetLevel().Outer.Name);
    }

    szPathAndFileName = "..\\save\\plan\\" $ szMapName $ "\\" $ szGameTypeDirName $ "\\" $ _szFileName $ ".PLN";

    if ( m_pFileManager.FindFile( szPathAndFileName ) )
		return true;

	return false;
}

//===========================================================================
// LoadAPlanning: load a planning -- the file load process...
//===========================================================================
function BOOL LoadAPlanning( string _szFileName)
{
#ifndefMPDEMO
    local string szLoadErrorMsg;
    local string szLoadErrorMsgMapName;
    local string szLoadErrorMsgGameType;
    local R6StartGameInfo               startGameInfo;
    local R6MissionDescription          mission;
    local string                        szMapName;	
    local string                        szGameTypeDirName;
    local string                        szEnglishGTDirectory;
    local INT                           iMission;
    local BOOL                          bFoundMission;

    //Empty the list before loading a new one.
    R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();

    //Find the menu name of the map
    startGameInfo = console.Master.m_StartGameInfo;
    mission = R6MissionDescription(startGameInfo.m_CurrentMission);

    szMapName = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );
    if( szMapName == "" ) // failed to find the name, use the map filename
    {
        szMapName = string(GetLevel().Outer.Name);
    }

    GetLevel().GetGameTypeSaveDirectories( szGameTypeDirName, szEnglishGTDirectory );

    if(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.LoadPlanning(
            mission.m_MapName,
            szMapName,
            szEnglishGTDirectory,
            szGameTypeDirName,
            _szFileName,
            startGameInfo,
            szLoadErrorMsgMapName,
            szLoadErrorMsgGameType) == true)
    {
        R6PlanningCtrl(GetPlayerOwner()).InitNewPlanning(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam);
        m_GearRoomWidget.LoadRosterFromStartInfo();
        m_bPlayerPlanInitialized = true;
		return true;
    }
    else
    {
        //Find the menu name of the map
        bFoundMission = false;
        iMission = 0;

        while ( iMission < R6Console(Root.console).m_aMissionDescriptions.length )
        {
            mission = R6Console(Root.console).m_aMissionDescriptions[iMission];
            if(Caps(mission.m_MapName) == Caps(szLoadErrorMsgMapName))
            {
                bFoundMission = true;
                iMission = R6Console(Root.console).m_aMissionDescriptions.length;
            }
            iMission++;
        }

        szMapName = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );
        if(( szMapName == "" ) || (bFoundMission == false))  // failed to find the name, use the map filename
        {
            szMapName = Localize("POPUP","LOADERRORMAPUNKNOWN","R6Menu");
        }
    
        if(GetLevel().FindSaveDirectoryNameFromEnglish( szGameTypeDirName, szLoadErrorMsgGameType ) == false)
        {
            szGameTypeDirName = Localize("POPUP","LOADERRORMAPUNKNOWN","R6Menu");
        }
        
        szLoadErrorMsg = Localize( "POPUP", "LOADERRORPROBLEM", "R6Menu") @ szMapName @ Localize( "POPUP", "LOADERRORPROBLEM2", "R6Menu") @ szGameTypeDirName;
        
        SimplePopUp(Localize("POPUP","LOADERROR","R6Menu"), _szFileName@szLoadErrorMsg, EPopUpID_InvalidLoad, MessageBoxButtons.MB_OK);
#endif
		return false;
#ifndefMPDEMO
    }
#endif
}

//===========================================================================
// DeleteAPlanning: Let's try to delete a USER plan
//===========================================================================
function BOOL DeleteAPlanning( string szFileName)
{
    local string                        szPathAndFileName; 
    local string                        ErrorMsg;
    local R6StartGameInfo               startGameInfo;
    local string                        szMapName;
    local string                        szGameTypeDirName;
    local string                        szEnglishGTDirectory;
    local R6MissionDescription          mission;
    local INT                           i;

    startGameInfo = console.Master.m_StartGameInfo;
    mission = R6MissionDescription(startGameInfo.m_CurrentMission);

    GetLevel().GetGameTypeSaveDirectories( szGameTypeDirName, szEnglishGTDirectory );

    szMapName = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );
    if( szMapName == "" ) // failed to find the name, use the map filename
    {
        szMapName = string(GetLevel().Outer.Name);
    }

    szPathAndFileName = "..\\save\\plan\\" $ szMapName $ "\\" $ szGameTypeDirName $ "\\" $ szFileName $ ".PLN";

    if ( m_pFileManager.DeleteFile( szPathAndFileName ) )
		return true;

	//We failed deleting the file it's probably because it is read-only
    //This is normal for planning delivered with the game
    
    ErrorMsg = Localize("POPUP","PLANDELETEERRORPROBLEM","R6Menu") @ ":" @ szFileName @ "\\n" @ Localize("POPUP","PLANDELETEERRORMSG","R6Menu");

    SimplePopUp(Localize("POPUP","PLANDELETEERROR","R6Menu"), ErrorMsg ,EPopUpID_PlanDeleteError, MessageBoxButtons.MB_OK);

    return false;

}

//===========================================================================
// ISPlanning Empty: Check if something is planned
//===========================================================================
function BOOL IsPlanningEmpty()
{
    local bool result;
    local R6PlanningInfo PlanningInfo;
    local int            i;    
    
    result = true;   
    
    for(i=0; i<3; i++)
    {        
        PlanningInfo = R6PlanningInfo(Console.Master.m_StartGameInfo.m_TeamInfo[i].m_pPlanning);    

        if( PlanningInfo.m_NodeList.Length > 0)
            result = false;
    }   


    return result;
}

//===========================================================================
// LeaveForGame: ready to start the game in single... after loadplanning process
//===========================================================================
function LeaveForGame( bool _ObserverMode, int _iTeamStart)
{
#ifndefMPDEMO
    local R6StartGameInfo           StartGameInfo;
    
    StartGameInfo = console.master.m_StartGameInfo;

    StartGameInfo.m_bIsPlaying = !_ObserverMode;
    StartGameInfo.m_iTeamStart = _iTeamStart;

    //Save a backup copy of the current planning
    m_GearRoomWidget.SetStartTeamInfoForSaving(); 

    R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
    if(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.SavePlanning("Backup", "Backup", "Backup", "", "Backup.pln", StartGameInfo) == false)
    {
        SimplePopUp(Localize("POPUP","FILEERROR","R6Menu"), "Backup.pln" @ ":" @ Localize("POPUP","FILEERRORPROBLEM","R6Menu"),EPopUpID_FileWriteError, MessageBoxButtons.MB_OK);
    }
    else
    {
        m_GearRoomWidget.SetStartTeamInfo(); //This must be called after SetStartTeamInfoForSaving        
        SimpleTextPopUp(Localize("POPUP","LAUNCHING","R6Menu"));
        PartialResetOriginalData();
        R6Console(console).LaunchR6Game(true);
        
    }
   
#endif    
}

function PartialResetOriginalData()
{
    local R6DecalManager aMgr;

    aMgr = GetLevel().m_DecalManager;
    GetLevel().m_DecalManager = none;
    if(aMgr != none)
    {
        aMgr.Destroy();
    }
    if(!GetLevel().bKNoInit)
    {
        GetLevel().m_DecalManager = GetLevel().Spawn(Class'Engine.R6DecalManager');
    }
}

#ifdefDEBUG
exec function SaveTrainingPlanning()
{
    local R6MissionDescription      missionDescription;
    local R6StartGameInfo           StartGameInfo;
    local string                    szMapName;
    local string                    szGameTypeDirName;
    local string                    szEnglishGTDirectory;

    StartGameInfo = console.master.m_StartGameInfo;
    missionDescription = R6MissionDescription(startGameInfo.m_CurrentMission);

    //Save a copy of the current planning like backup for training.
    m_GearRoomWidget.SetStartTeamInfo(); 

    szMapName = Localize( missionDescription.m_MapName, "ID_MENUNAME", missionDescription.LocalizationFile, true );
    if( szMapName == "" ) // failed to find the name, use the map filename
    {
        szMapName = StartGameInfo.m_MapName;
    }

    GetLevel().GetGameTypeSaveDirectories( szGameTypeDirName, szEnglishGTDirectory );
   
    R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.SavePlanning(
        missionDescription.m_MapName,
        szMapName,
        szEnglishGTDirectory,
        szGameTypeDirName, 
        missionDescription.m_ShortName$ "_MISSION_DEFAULT" , 
        StartGameInfo);

    log("Training planning was saved "$szMapName$"/"$szGameTypeDirName$"/"$missionDescription.m_ShortName$ "_MISSION_DEFAULT.Pln");
}
#endif


//===========================================================================================================
// Make sure that is one of these buttons needs to downsize it's font all buttons end up using the same font
//===========================================================================================================
function HarmonizeMenuFonts()
{    
    local   Font    buttonFont;
    local   Font    DownSizeFont;

    DownSizeFont    = Root.Fonts[F_VerySmallTitle];        
    buttonFont		= Root.Fonts[F_PrincipalButton];    

    m_SinglePlayerWidget.m_LeftButtonFont  = buttonFont;
    m_CustomMissionWidget.m_LeftButtonFont = buttonFont;
    m_TrainingWidget.m_LeftButtonFont      = buttonFont;

    m_SinglePlayerWidget.m_LeftDownSizeFont   = DownSizeFont;
    m_CustomMissionWidget.m_LeftDownSizeFont  = DownSizeFont;
    m_TrainingWidget.m_LeftDownSizeFont       = DownSizeFont;


    m_SinglePlayerWidget.CreateButtons();
    m_CustomMissionWidget.CreateButtons();
    m_TrainingWidget.CreateButtons();

	if( m_SinglePlayerWidget.ButtonsUsingDownSizeFont()   ||
	    m_CustomMissionWidget.ButtonsUsingDownSizeFont()  ||   
	    m_TrainingWidget.ButtonsUsingDownSizeFont()
      )
    {        
        m_SinglePlayerWidget.ForceFontDownSizing();
        m_CustomMissionWidget.ForceFontDownSizing();
        m_TrainingWidget.ForceFontDownSizing();

    }
    
}

//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile( BOOL _bServerProfile)
{
#ifndefSPDEMO
	if (_bServerProfile)
		m_pMPCreateGameWidget.MenuServerLoadProfile();
	else
#endif
		m_OptionsWidget.MenuOptionsLoadProfile();
}

//=================================================================================
// NotifyWindow: receive specific notify from pop-up window, etc
//=================================================================================
function NotifyWindow(UWindowWindow C, byte E)
{
	if (E == DE_DoubleClick)
	{

		if (C == R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan) // Load planning
		{
			m_PopUpLoadPlan.Result = MR_OK;
			m_PopUpLoadPlan.Close();
		}
		else if (C == R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan) // save planning
		{
			m_PopUpSavePlan.Result = MR_OK;
			m_PopUpSavePlan.Close();
		}
	}
}


function SetNewMODS( string _szNewBkgFolder, optional BOOL _bForceRefresh)
{
	// advice Intel to change is bkg
	if (_bForceRefresh)
	{
		// set in the root the new bkg texture
//	    m_TBackGround=Texture'R6MenuTextures.LaptopTileBG'
		// we have to change in Paint() of all class derivate from R6MenuLaptopWidget, m_TBackGround for a fct to GetTexture
		// from the root
	}

	Super.SetNewMODS( _szNewBkgFolder, _bForceRefresh);
}

//================================================
// InitBeaconService: 
//================================================
function InitBeaconService()
{
    if (R6Console(Console).m_LanServers==none)
    {
		R6Console(console).m_LanServers = new(none) class<R6LanServers>(Root.MenuClassDefines.ClassLanServer);
        R6Console(console).m_LanServers.Created();
    }

    if(R6Console(console).m_LanServers.m_ClientBeacon == none)
        R6Console(console).m_LanServers.m_ClientBeacon  = Console.ViewportOwner.Actor.Spawn( class'ClientBeaconReceiver' );
    R6Console(console).m_GameService.m_ClientBeacon = R6Console(console).m_LanServers.m_ClientBeacon;
}

// DestroyBeaconService: If you can play an another type of game in match making -- see with AK or YJ

defaultproperties
{
     m_BGTexture0=Texture'R6MenuBG.Backgrounds.GenericLoad0'
     m_BGTexture1=Texture'R6MenuBG.Backgrounds.GenericLoad1'
     m_MainMenuMusic=Sound'Music.Play_theme_Menu1'
     LookAndFeelClass="R6Menu.R6MenuRSLookAndFeel"
}
