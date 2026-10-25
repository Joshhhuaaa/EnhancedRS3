//============================================================================//
// Class            R6Console
// Date             20 April 2001
// Description
//
//  Revision history:
//    
//============================================================================//
class R6Console extends WindowConsole;

#exec OBJ LOAD FILE=..\Sounds\Music.uax PACKAGE=Music

// MPF not needed anymore var config string        Campaign

var BOOL   bResetLevel;
var BOOL   bLaunchWasCalled;
var BOOL   bLaunchMultiPlayer;
var BOOL   bReturnToMenu;
var BOOL   bCancelFire;

//R6CODE
var BOOL   m_bInGamePlanningKeyDown;

var string m_szLastError;       // String used to store error to be later displayed
//var string szStoreIP;           // String used to store IP of host server
var string szStoreGamePassWd;   // String used to store game password
const    K_CHECKTIME_INTERVAL = 3000;// Time interval for checking that ubi.com client is still alive (ms)
const    K_CHECKTIME_TIMEOUT  = 9000;// Time interval for checking that ubi.com client is still alive (ms)


var INT  m_iLastCheckTime;      // Time at which the last check was made to see if ubi.com client is still responding
var INT  m_iLastSuccCheckTime;  // Time at which the last check was made to see if ubi.com client is still responding

var bool m_bSkipAFrameAndStart;   // To render one last frame before leaving
var bool m_bRenderMenuOneTime;	// render the menu one time before processing key in the case of and connection interruption

var enum eLeaveGame
{
    LG_MainMenu,
    LG_NextLevel,
    LG_Trainning,
    LG_MultiPlayerMenu,
    LG_RetryPlanningCustomMission,
    LG_CustomMissionMenu,
    LG_RetryPlanningCampaign,    
    LG_QuitGame,
    LG_MultiPlayerError,
	LG_InitMod
} m_eNextStep;

//////////////////////////////////////////////////////////////////////////////////
//This Stuff Is single Player Game Specific and Might Need to be moved elsewhere
//This is needed to launch the game with the good operatives and 
/////////////////////////////////////////////////////////////////////////////////
var Array<R6Campaign>           m_aCampaigns;
var R6Campaign                  m_CurrentCampaign;
var R6PlayerCampaign            m_PlayerCampaign;
/////////////////////////////////////////////////////////////////////////////////

#ifndefSPDEMO
var R6GSServers                 m_GameService;             // Manages servers from game service
var R6LanServers                m_LanServers;              // Manages servers on the LAN
#endif

var R6PlayerCustomMission        m_playerCustomMission; // containt all the map unlock for each campaign
var Array<R6MissionDescription>  m_aMissionDescriptions;

var array<UWindowRootWindow.eGameWidgetID> m_AWIDList;     // widgets to restore after a mod change

var BOOL						m_bStartR6GameInProgress;  // currently create new menu and load sound bank fct StartR6Game

var Sound                       m_StopMainMenuMusic;

//------------------------------------------------------------------
// Inhereited
//------------------------------------------------------------------
event Message( coerce string Msg, float MsgLife)
{
    local PlayerController pController;

    if ( ViewportOwner == none )
    {
        return;
    }

    pController = ViewportOwner.Actor;
    pController.myHUD.Message( pController.PlayerReplicationInfo, Msg, 'Console' ); // r6code
}

function CreateRootWindow(Canvas Canvas)
{
    InitCampaignAndMissionDescription();

    Super.CreateRootWindow(Canvas);
 }

function InitCampaignAndMissionDescription()
{
    local R6FileManager pFileManager;
    local string        szCampaignName;
    local string        szCampaignPathName;
	local INT			iAdditionalModIndex;

    szCampaignName = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szCampaignIniFile;

    // check if we have a default campaign
    pFileManager = new(none) class'R6FileManager';
    szCampaignPathName = "..\\maps\\" $szCampaignName;
    if ( !pFileManager.FindFile( szCampaignPathName ) )
    {
        szCampaignName = ""; // fail, so take the one from .ini file
    }

	//empty the list.
	m_aMissionDescriptions.remove(0, m_aMissionDescriptions.length);

	if(!class'Actor'.static.GetModMgr().IsRavenShield() && (szCampaignName != "RavenShieldCampaign"))
	{
		LoadCampaignIni( "RavenShieldCampaign");
	}

	//mpf loadcampaign for additional campaings associated with the mod.
	iAdditionalModIndex = 0;
	while(class'Actor'.static.GetModMgr().m_pCurrentMod.GetExtraMods(iAdditionalModIndex) != none)
	{
		szCampaignName = class'Actor'.static.GetModMgr().m_pCurrentMod.GetExtraMods(iAdditionalModIndex).m_szCampaignIniFile;
		LoadCampaignIni( szCampaignName );
		iAdditionalModIndex++;
		szCampaignName = "";
	}

	// MPF: LoadCampaign of the current mod
	if ( szCampaignName == "" )
	{
		szCampaignName = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szCampaignIniFile;
	}
	LoadCampaignIni( szCampaignName );
}

// MPF: LoadCampaignIni 
function LoadCampaignIni( string szCampaign )
{
	local int i;
	local bool bFound;

	// load campaign dynamically
	for(i = 0; i<m_aCampaigns.length; i++)
	{
		if(m_aCampaigns[i].m_szCampaignFile == szCampaign)
		{
			m_CurrentCampaign = m_aCampaigns[i];
			bFound = true;
		}
	}

	if(bFound == false)
	{
		m_CurrentCampaign = new(none) class'R6Campaign'; 
		m_aCampaigns[i] = m_CurrentCampaign;
	}

    m_CurrentCampaign.InitCampaign( ViewportOwner.Actor.Level, szCampaign, self );

    UnlockMissions();    
}

function InitMod()
{
    local string szCampaign;
	local INT	 iAdditionalModIndex;

	//empty the mission description list.
	m_aMissionDescriptions.remove(0, m_aMissionDescriptions.length);

	if(!class'Actor'.static.GetModMgr().IsRavenShield())
	{
		LoadCampaignIni( "RavenShieldCampaign");
	}

	iAdditionalModIndex = 0;
	iAdditionalModIndex = 0;
	while(class'Actor'.static.GetModMgr().m_pCurrentMod.GetExtraMods(iAdditionalModIndex) != none)
	{
		szCampaign = class'Actor'.static.GetModMgr().m_pCurrentMod.GetExtraMods(iAdditionalModIndex).m_szCampaignIniFile;
		LoadCampaignIni( szCampaign );
		iAdditionalModIndex++;
	}

	szCampaign = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szCampaignIniFile;
	LoadCampaignIni( szCampaign );
	
	if ( m_PlayerCampaign != none ) 
        m_PlayerCampaign.m_bCampaignCompleted = 0;
    
    ConsoleCommand("LOADSERVER " $class'Actor'.static.GetModMgr().getServerIni()$ ".ini" );
}

event Initialized()
{   
    if(bShowLog)log("R6Console Initialized");
#ifndefSPDEMO
    m_PlayerCampaign                            = new(none) class'R6PlayerCampaign'; 
    m_PlayerCampaign.m_OperativesMissionDetails = new(none) class'R6MissionRoster';
#endif
    m_PlayerCustomMission                       = new(none) class'R6PlayerCustomMission';
    class'Actor'.static.GetGameManager().SetConsoleInGameMgr(self);
}

function InitializedGameService()
{
#ifndefSPDEMO
    // the game manager owns the GameService
    m_GameService = R6GSServers(class'Actor'.static.GetGameManager().GetGameMgrGameService());
    if (m_GameService == none)
    {
        log("m_GameService is none");
    }
#endif
}

function object SetGameServiceLinks(PlayerController _localPlayer)
{
#ifndefSPDEMO
    if (class'Actor'.static.GetGameManager().GetGameMgrGameService()!=none)
    {
        class'Actor'.static.GetGameManager().SetLocalPlayerCtrl(_localPlayer);
    }

    if (m_LanServers!=none)
    {
        m_LanServers.m_LocalPlayerController = _localPlayer;
    }

    return class'Actor'.static.GetGameManager().GetGameMgrGameService();
#endif
#ifdefSPDEMO
    return none;
#endif
}

event UserDisconnected()
{
#ifndefSPDEMO
    if(bShowLog) log("R6Console::UserDisconnected() Returning to menus due to Server disconnection!");    

//    m_bNonUbiMatchMaking = false;
//    m_bNonUbiMatchMakingHost = false;

    class'Actor'.static.GetGameManager().ConnectionInterrupted(true);
    SetGameServiceLinks(none);

    if (m_bNonUbiMatchMaking || m_bNonUbiMatchMakingHost)
        LeaveR6Game(LG_QuitGame); //quit the game 
    else
        LeaveR6Game(LG_MultiPlayerMenu); //Returning to multiplayer menu if this is called from ingame 
                    //Or else LeaveR6Game will ignore it
#endif
}

event ServerDisconnected()
{
#ifndefSPDEMO
    if(bShowLog) log("R6Console::ServerDisconnected() Returning to menus due to Server disconnection!");    

//    m_bNonUbiMatchMaking = false;
//    m_bNonUbiMatchMakingHost = false;
    LeaveR6Game(LG_MultiPlayerError);
    class'Actor'.static.GetGameManager().ConnectionInterrupted();
    SetGameServiceLinks(none);
#endif
}

event R6ConnectionFailed( string szError )
{
#ifndefSPDEMO
    if(bShowLog) log("R6Console::R6ConnectionFailed() " $ szError );

//    m_bNonUbiMatchMaking = false;
//    m_bNonUbiMatchMakingHost = false;
    m_szLastError = szError;

	// the menu are recreate, reset
	Root.ResetMenus( true);

    LeaveR6Game(LG_MultiPlayerError);
    class'Actor'.static.GetGameManager().ConnectionInterrupted();
    SetGameServiceLinks(none);
#endif
}

event R6ConnectionSuccess()
{
    if(bShowLog) log("R6Console::R6ConnectionSuccess()");    

//    m_bNonUbiMatchMaking = false;
//    m_bNonUbiMatchMakingHost = false;
    
    if(Root.m_eRootId != Root.eRootID.RootID_R6MenuInGameMulti)
        LaunchR6MultiPlayerGame();   
    
}

event R6ConnectionInterrupted()
{
    if(bShowLog) log("R6Console::R6ConnectionInterrupted()");

    if (m_bNonUbiMatchMaking == true)
        Root.DoQuitGame();

	class'Actor'.static.EnableLoadingScreen(true); // if the interruption was in-game, re-enable loading screen for next join
//	m_bInterruptConnectionProcess = false;

//    m_bNonUbiMatchMaking = false;
//    m_bNonUbiMatchMakingHost = false;

	// the menu are recreate, reset
	Root.ResetMenus( true);

    LeaveR6Game(LG_MultiPlayerMenu);//LG_MultiPlayerError);//Returning to multiplayer menu if this is called from ingame 
                    //Or else LeaveR6Game will ignore it
    class'Actor'.static.GetGameManager().ConnectionInterrupted();
    SetGameServiceLinks(none);
}

event R6ConnectionInProgress()
{
	if (Root.GetSimplePopUpID() == EPopUpID_None)
	{
		Root.SimplePopUp( Localize( "MultiPlayer", "PopUp_Downloading", "R6Menu"),
						  Localize( "PopUP", "PopUpEscCancel", "R6Menu"),
						  EPopUpID_DownLoadingInProgress, 
						  4);//UWindowBase.MessageBoxButtons.MB_Cancel);
	}
}

event R6ProgressMsg( string _Str1, string _Str2, FLOAT Seconds)
{
	local array<string> ATextMsg;

	// update menus
	ATextMsg[0] = _Str1;
	ATextMsg[1] = _Str2;

	Root.ModifyPopUpInsideText( ATextMsg);
}

event string GetStoreGamePwd()
{
    return szStoreGamePassWd;
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	if(bShowLog)log("ERROR!!!!!!!!!!!!!!!!!!! IN R6Console >> KeyEvent");
    return false;
}

function bool KeyType( EInputKey Key )
{
	if(bShowLog)log("ERROR!!!!!!!!!!!!!!!!!!! IN R6Console >> KeyType");
    return false;
}

function PostRender( canvas Canvas )
{
	if(bShowLog) log("ERROR!!!!!!!!!!!!!!!!!!! IN R6Console >> PostRender");
}

// A window is displayed, trapping all the input
state UWindow
{
    function BeginState()
    {
        ConsoleState = GetStateName();
    }

    function PostRender( canvas Canvas )
	{
        local INT i;

		if (m_bRenderMenuOneTime)
		{
			if (m_bInterruptConnectionProcess)
				m_bInterruptConnectionProcess = false;
			else
				m_bRenderMenuOneTime = false;
		}

        if(bReturnToMenu == true && Root != None)
        {   
            
            bReturnToMenu = false; 

			if (m_bInterruptConnectionProcess)
				m_bRenderMenuOneTime = true;

            //Force Menu Res       

            switch(m_eNextStep)
            {
			case LG_InitMod:
				for (i = 0; i < m_AWIDList.Length; i++)
					Root.ChangeCurrentWidget(m_AWIDList[i]);
				m_bChangeModInProgress = false;
				break;
            case LG_MainMenu:
                //Go to Next Level
                Root.ChangeCurrentWidget(MainMenuWidgetID);
                break;
            case LG_Trainning:
                Root.ChangeCurrentWidget(TrainingWidgetID);
                break;
            case LG_NextLevel:
                //Go to Next Level
                if(m_PlayerCampaign.m_bCampaignCompleted == 1)
                {
                    Root.ChangeCurrentWidget(CreditsWidgetID);
                    Canvas.m_bDisplayGameOutroVideo = true;
                }
                else
                    Root.ChangeCurrentWidget(CampaignPlanningID);
                break;
            case LG_MultiPlayerMenu:
                // Go to the ubi.com window
                if ( m_bStartedByGSClient )
                {
                    Root.ChangeCurrentWidget(UbiComWidgetID);
                    class'Actor'.static.GetGameManager().m_bReturnToGSClient = TRUE;
                }
                //Go to Multiplayer Menu
                else
                    Root.ChangeCurrentWidget(MultiPlayerWidgetID);
                break;
            case LG_RetryPlanningCustomMission:
                //Go to PlanningCustom Mission
                Root.ChangeCurrentWidget(RetryCustomMissionPlanningID);
                break;
            case LG_CustomMissionMenu:
                //Go to PlanningCustom Mission
                Root.ChangeCurrentWidget(CustomMissionWidgetID);
                break;
            case LG_RetryPlanningCampaign:
                Root.ChangeCurrentWidget(RetryCampaignPlanningID);           
                break;         
            case LG_QuitGame:
                Root.ChangeCurrentWidget(MenuQuitID);
                break;   
            case LG_MultiPlayerError:
                class'Actor'.static.GarbageCollect();
//                if ( m_bStartedByGSClient )
//                    Root.ChangeCurrentWidget(MultiPlayerErrorUbiCom);
//                else
                    Root.ChangeCurrentWidget(MultiPlayerError);
                break;   
            }            
        
        }
        
        if( (bLaunchWasCalled==true) && (m_bSkipAFrameAndStart == false))
        {            
            //This will advise the renderer  to switch to ingame res
            if ( bResetLevel )
            {
               ViewportOwner.Actor.Level.SetBankSound(BANK_UnloadGun);
               R6GameInfo(ViewportOwner.Actor.Level.Game).RestartGameMgr();
               StartR6Game( bResetLevel );
               Root.ChangeCurrentWidget(WidgetID_None);
               bResetLevel = false;
            }
            else
            {
                StartR6Game( bResetLevel );
            }
            
            bLaunchWasCalled=false;

        }
        else
        {
            m_bSkipAFrameAndStart = false;
            if(Root != None)
			    Root.bUWindowActive = True;
		    RenderUWindow( Canvas );            
                   
        }
	}

    function bool KeyEvent( EInputKey eKey, EInputAction eAction, FLOAT fDelta )
    {
        local byte k;
        k = eKey;        
        
        if(bShowLog)log("R6Console state Uwindow KeyEvent eAction"@eAction@"Key"@eKey);
        switch(eAction)
        {
		case IST_Release:
			switch (eKey)
			{
			case EInputKey.IK_LeftMouse:                
				if(Root != None) 
					Root.WindowEvent(WM_LMouseUp, None, MouseX, MouseY, k);
				return true;
			case EInputKey.IK_RightMouse:                
				if(Root != None)
					Root.WindowEvent(WM_RMouseUp, None, MouseX, MouseY, k);
				return true;
			case EInputKey.IK_MiddleMouse:                
				if(Root != None)
					Root.WindowEvent(WM_MMouseUp, None, MouseX, MouseY, k);
				return true;
			default:                
				if(Root != None)
					Root.WindowEvent(WM_KeyUp, None, MouseX, MouseY, k);

                if (ViewportOwner.Actor.InPlanningMode())
				{
    				return false;
				}
                else
				{
					if (Root !=None)
	                    return Root.TrapKey( false);
					else
						return true;
				}
				break;
			}
			break;
        case IST_Press:            
            if (k == ViewportOwner.Actor.GetKey("Console"))
            {
                if (bLocked)
                    return true;

                Type();
                return true;
            }
            
            switch(k)
            {
//				case EInputKey.IK_Escape:
//                    //Don't quit the menu, allow un-pause and quitting the console
//                   if( bPauseKeyActive )
//                   {
//                        CloseUWindow();
//                    }
//                    return true;				
			case EInputKey.IK_LeftMouse:                
				if(Root != None)                    
					Root.WindowEvent(WM_LMouseDown, None, MouseX, MouseY, k);                                            
				return true;
			case EInputKey.IK_RightMouse:                
				if(Root != None)
					Root.WindowEvent(WM_RMouseDown, None, MouseX, MouseY, k);
				return true;
			case EInputKey.IK_MiddleMouse:                
				if(Root != None)
					Root.WindowEvent(WM_MMouseDown, None, MouseX, MouseY, k);
				return true;
			case EInputKey.IK_MouseWheelDown:                
				if(Root != None)
					Root.WindowEvent(WM_MouseWheelDown, None, MouseX, MouseY, k);
				return true;
			case EInputKey.IK_MouseWheelUp:                
				if(Root != None)
					Root.WindowEvent(WM_MouseWheelUp, None, MouseX, MouseY, k);
				return true;
			default:                
				if(Root != None)
					Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);

                if (ViewportOwner.Actor.InPlanningMode())
				{
    				return false;
				}
                else
				{
					if (Root !=None)
	                    return Root.TrapKey( false);
					else
						return true;
				}
				break;
			}
			break;
		case IST_Axis:            
            switch (k)
		    {                
		    case EInputKey.IK_MouseX:
			    MouseX = MouseX + (MouseScale * fDelta);
			    break;
		    case EInputKey.IK_MouseY:
			    MouseY = MouseY - (MouseScale * fDelta);
			    break;					
		    }
            break;
		default:            
			break;
        }

        if (ViewportOwner.Actor.InPlanningMode())
		{
    		return false;
		}
        else
		{
			if (Root !=None)
	            return Root.TrapKey( true);
			else
				return true; // Trap all keys
		}

    }
    
}

state Typing
{
    function PostRender( canvas Canvas )
	{     
        if(Root != None)
			Root.bUWindowActive = True;        
		RenderUWindow( Canvas );            
        Super.PostRender(Canvas);
	}

    function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{        
		local string Temp;
		local string Temp1;
        local string FileName;
		local int i;

	    if(bShowLog)log("R6Console state Typing KeyEvent Action"@Action@"Key"@Key);

		if (Action== IST_Press)
		{
			bIgnoreKeys=false;
		}

        if((Action == IST_Press) && (Key == ViewportOwner.Actor.GetKey("Console")))
        {
            GotoState(ConsoleState);
            return true;
        }

		if( Key==IK_Escape )
		{
			if( TypedStr!="" )
			{
				TypedStr="";
				HistoryCur = HistoryTop;				
			}
			else
			{
				GotoState(ConsoleState);
			}            
		}		
		else if( Key==IK_Enter && Action== IST_Release)
		{
			if( TypedStr!="" )
			{
                if (Caps(Left(TypedStr, Len("WRITESERVER"))) == "WRITESERVER")
                {
                    FileName = "..\\" $ class'Actor'.static.GetModMgr().GetIniFilesDir() $ "\\";
                    FileName = FileName $ right(TypedStr, Len(TypedStr)-Len("WRITESERVER "));
                    if (Root.m_eCurWidgetInUse == Root.eGameWidgetID.MPCreateGameWidgetID)
                    {
                        Root.SetServerOptions();
                        class'Actor'.static.SaveServerOptions(FileName);
                        
                        Message(Localize("Errors","SaveSuccessful","R6Engine"), 6.0);
                        GotoState(ConsoleState);
                        return true;
                    }
                }

                // Hack
                if(Caps(Left(TypedStr, Len("SHOT"))) != "SHOT")
    				Message( TypedStr, 6.0 );// Print to console.

				History[HistoryTop] = TypedStr;
				HistoryTop = (HistoryTop+1) % MaxHistory;
				
				if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
					HistoryBot = (HistoryBot+1) % MaxHistory;

				HistoryCur = HistoryTop;

				// Make a local copy of the string.
				Temp=TypedStr;
				TypedStr="";

				// the TYPE command is not allowed
				Temp1 = Temp;
				while ((Len(Temp1) > 0) && (Left(Temp1, 1) == " "))
					Temp1 = Right(Temp1, Len(Temp1) - 1);
				if (Caps(Left(Temp1, Len("TYPE"))) == "TYPE")
					Message( Localize("Errors","Exec","R6Engine"), 6.0 );
				else if( !ConsoleCommand( Temp ) )
					Message( Localize("Errors","Exec","R6Engine"), 6.0 );
					
				Message( "", 6.0 );

                // Hack
                if(Caps(Left(Temp, Len("SHOT"))) == "SHOT")
                    GotoState(ConsoleState);
                else if(!bShowConsoleLog)
                    GotoState(ConsoleState);
			}
			else
				GotoState(ConsoleState);
			
		}
        else if (Action== IST_Release)
		{
			return true;
		}
		else if( Key==IK_Up )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryBot)
					HistoryCur = HistoryTop;
				else
				{
					HistoryCur--;
					if (HistoryCur<0)
						HistoryCur = MaxHistory-1;
				}
				
				TypedStr = History[HistoryCur];
			}			
		}
		else if( Key==IK_Down )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryTop)
					HistoryCur = HistoryBot;
				else
					HistoryCur = (HistoryCur+1) % MaxHistory;
					
				TypedStr = History[HistoryCur];
			}			            
		}
		else if( Key==IK_Backspace || Key==IK_Left )
		{
            m_bStringIsTooLong = false;

			if( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);			
		}
	
        return true;
	}    
    
}

state Game
{
    function BeginState()
    {
        if(bShowLog)log("R6Console  Game::BeginState");
        bCancelFire = true;
        ConsoleState = GetStateName();
    }

/*
    event Tick( float Delta )
	{        
		Global.Tick(Delta);
		if(Root != None)
			Root.DoTick(Delta);     
	}
*/

    function PostRender( canvas Canvas )
    {        
        if(Root != None)
        {
            Root.bUWindowActive = True;	     
            RenderUWindow( Canvas );            
        }
     
    }

    function EndState()
    {
        if(bShowLog)log("R6Console  Game::EndState");
        
        if(ViewportOwner.Actor != none)
        {
            if(R6PlayerController(ViewportOwner.Actor) != none)  
            {
                if(bCancelFire == true)
                    R6PlayerController(ViewportOwner.Actor).bFire = 0;
            }

            if(ViewportOwner.Actor.Level != none)
            {
                ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = false;
                ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = false;
            }            
             
        }       
    }
    
    function bool KeyEvent(EInputKey eKey, EInputAction eAction, FLOAT fDelta)
    {
        local byte k;
        local INT  i;

        k = eKey;   
        // Make sure that user is not typing in the console
        if(bShowLog)log("R6Console state Game KeyEvent eAction"@eAction@"Key"@eKey);

        if(!bTyping)
        {
            //=================================================================================================================================
            // In-game planning input handler, not in observer mode
            //=================================================================================================================================
            if(ViewportOwner.Actor != none && !ViewportOwner.Actor.IsInState('Dead'))
            {
                switch(eAction)
                {
		        case IST_Release:                    
                    if (k == ViewportOwner.Actor.GetKey("ToggleMap"))
                    {                        
                        m_bInGamePlanningKeyDown = false;
                        return true;
                    }
                    else if (k == ViewportOwner.Actor.GetKey("MapZoomIn"))
                    {                     
                        if(ViewportOwner.Actor.Level.m_bInGamePlanningActive)
                        {
                            ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = false;
                            return true;
                        }
                    }
                    else if (k == ViewportOwner.Actor.GetKey("MapZoomOut"))
                    {                     
                        if(ViewportOwner.Actor.Level.m_bInGamePlanningActive)
                        {
                            ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = false;
                            return true;
                        }
                    }
			        break;
                case IST_Press:                                
                    if (k == ViewportOwner.Actor.GetKey("ToggleMap"))
                    {                        
                        if(ViewportOwner.Actor.Level.m_bInGamePlanningActive == false)
                        {
                            ViewportOwner.Actor.Level.m_bInGamePlanningActive = true;
                            ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = false;
                            ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = false;
                            m_bInGamePlanningKeyDown = true;
                            return true;
                        }
                        else if(m_bInGamePlanningKeyDown == false)
                        {
                            ViewportOwner.Actor.Level.m_bInGamePlanningActive = false;
                            ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = false;
                            ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = false;
                            return true;
                        }
                    }
                    else if (k == ViewportOwner.Actor.GetKey("MapZoomIn"))
                    {                        
                        if(ViewportOwner.Actor.Level.m_bInGamePlanningActive)
                        {
                            ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = true;
                            return true;
                        }
                    }
                    else if (k == ViewportOwner.Actor.GetKey("MapZoomOut"))
                    {                     
                        if(ViewportOwner.Actor.Level.m_bInGamePlanningActive)
                        {
                            ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = true;
                            return true;
                        }
                    }
			        break;
		        }
            }

            //=================================================================================================================================
            // Normal input handler
            //=================================================================================================================================
            switch(eAction)
            {
		    case IST_Release:                
                if (k == ViewportOwner.Actor.GetKey("ShowCompleteHUD"))
                {
                    R6PlayerController(ViewportOwner.Actor).m_bShowCompleteHUD = false;
                    return true;
                }

			    switch (k)
			    {
			    case EInputKey.IK_LeftMouse:                    
				    if(Root != None) 
					    Root.WindowEvent(WM_LMouseUp, None, MouseX, MouseY, k);
				    break;
			    case EInputKey.IK_RightMouse:                    
				    if(Root != None)
					    Root.WindowEvent(WM_RMouseUp, None, MouseX, MouseY, k);
				    break;
			    case EInputKey.IK_MiddleMouse:                    
				    if(Root != None)
					    Root.WindowEvent(WM_MMouseUp, None, MouseX, MouseY, k);
				    break;
			    default:                                    
				    if(Root != None)
					    Root.WindowEvent(WM_KeyUp, None, MouseX, MouseY, k);
				    break;
			    }
			    break;                
            case IST_Press:                            
                if (k == ViewportOwner.Actor.GetKey("Console"))
                {
                    Type();
				    return true;
                }
                else if (k == ViewportOwner.Actor.GetKey("ShowCompleteHUD"))
                {                 
                    R6PlayerController(ViewportOwner.Actor).m_bShowCompleteHUD = true;
                    return true;
                }

                switch(k)
                {
			    case EInputKey.IK_LeftMouse:                                    
				    if(Root != None)
					    Root.WindowEvent(WM_LMouseDown, None, MouseX, MouseY, k);
				    break;
			    case EInputKey.IK_RightMouse:                                    
				    if(Root != None)
					    Root.WindowEvent(WM_RMouseDown, None, MouseX, MouseY, k);
				    break;
			    case EInputKey.IK_MiddleMouse:                                 
				    if(Root != None)
					    Root.WindowEvent(WM_MMouseDown, None, MouseX, MouseY, k);
				    break;
			    default:                                      
				    if(Root != None)                    
					    Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
				    break;
			    }            
			    break;
		    case IST_Axis:
                switch (k)
			    {
			    case EInputKey.IK_MouseX:
				    MouseX = MouseX + (MouseScale * fDelta);
				    break;
			    case EInputKey.IK_MouseY:
				    MouseY = MouseY - (MouseScale * fDelta);
				    break;					
			    }
                break;
            
		    default:                
			    break;
		    }
        }
        
        return false;
        //return Super.KeyEvent(eKey, eAction, fDelta);
    }
}

state TrainingInstruction extends UWindowCanPlay
{
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local byte k;
		k = Key;

        if(bShowLog)log("R6Console state TrainingInstruction KeyEvent eAction"@Action@"Key"@Key);

        switch(Action)
        {
			case IST_Release:
			    if ( (k == EInputKey.IK_Escape) || ( k == ViewportOwner.Actor.GetKey("Action")))
				{
					if(Root != None)
						Root.WindowEvent(WM_KeyUp, None, MouseX, MouseY, k);

					return true;
				}
				break;
			case IST_Press:
				if (k == ViewportOwner.Actor.GetKey("Console"))
				{
					if (bLocked)
						return true;

					Type();
					return true;
				}

				if( k == ViewportOwner.Actor.GetKey("Action"))
					return true;
		
				if(Root != None)
					Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
				break;
			default:
				break;
        }

		//Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
		return false;
	}
}

function LaunchInstructionMenu(R6InstructionSoundVolume pISV, BOOL bShow, INT iBox, INT iParagraph)
{
    Root.ChangeInstructionWidget(pISV, bShow, iBox, iParagraph);
}

event LaunchR6MainMenu()
{
	local UWindowMenuClassDefines pMenuDefGSServers;
    local INT i;
    
    if(bShowLog)log("R6Console LaunchR6MainMenu");
    
	bVisible = true;
    bUWindowActive = true;

	pMenuDefGSServers = new(none) class'UWindowMenuClassDefines';
	pMenuDefGSServers.Created();
	RootWindow      = pMenuDefGSServers.RegularRoot;
	
    CreateRootWindow(None); 
    LaunchUWindow();      
}

function NotifyLevelChange()
{
    if(bShowLog)log("R6Console NotifyLevelChange");

    Super.NotifyLevelChange();
    if( R6PlayerController(ViewportOwner.Actor) != None)
    {
        R6PlayerController(ViewportOwner.Actor).ClearReferences();
    }
}

function CleanAndChangeMod(array<UWindowRootWindow.eGameWidgetID> _AWIDListToUse)
{
	m_AWIDList = _AWIDListToUse;
	m_bChangeModInProgress = true;
	LeaveR6Game(LG_InitMod);
	R6GSServers(class'Actor'.static.GetGameManager().GetGameMgrGameService()).InitializeMod();
}

function LeaveR6Game(eLeaveGame _bwhatToDo)
{
    local Canvas    C;
    local BOOL      bCleanUp;
    local R6ServerInfo ServerInfo;

    
    if(bShowLog)log("R6Console LeaveR6Game");


    //Go Back to menu
    if(bReturnToMenu)
        return;

    bReturnToMenu   = true;    

    CleanSound(_bwhatToDo);

    master.m_MenuCommunication = None;
    CloseR6MainMenu(true);
    LaunchR6MainMenu();

    C = class'Actor'.static.GetCanvas();
    C.m_iNewResolutionX = 640;
    C.m_iNewResolutionY = 480;
    C.m_bChangeResRequested = true;
    c.m_bFading = false;
    
    // clear server info references
    ServerInfo = class'Actor'.static.GetServerOptions();
    ServerInfo.m_ServerMapList = none;
    ServerInfo.m_GameInfo = none;

    switch(_bwhatToDo)
    {  
    case LG_NextLevel: //Go to Next Level        
        m_eNextStep = LG_NextLevel;
        CleanPlanning();
        if(m_PlayerCampaign.m_bCampaignCompleted == 1)
        {
            bCleanUp = true;            
        }            
        break;
    case LG_MultiPlayerMenu: //Go to Multiplayer Menu        
        m_eNextStep = LG_MultiPlayerMenu;
        bCleanUp = true;
        break;
    case LG_RetryPlanningCustomMission: //Go back to planning phase Custom        
        CleanPlanning(); //Done in gameInfo
        master.m_StartGameInfo.m_ReloadPlanning = true;
        ViewportOwner.Actor.SetPlanningMode(TRUE);
        m_eNextStep = LG_RetryPlanningCustomMission;

		if( R6PlayerController(ViewportOwner.Actor) != None)
		{
			R6PlayerController(ViewportOwner.Actor).ClearReferences();
		}
        break;
    case LG_CustomMissionMenu:        
        CleanPlanning();        
        m_eNextStep = LG_CustomMissionMenu;
        bCleanUp = true;
        break;
    case LG_RetryPlanningCampaign:     //RETRY PLANNING IN CAMPAIGNMODE        
        CleanPlanning();
        master.m_StartGameInfo.m_ReloadPlanning = true;
        ViewportOwner.Actor.SetPlanningMode(TRUE);
        m_eNextStep = LG_RetryPlanningCampaign;        

		if( R6PlayerController(ViewportOwner.Actor) != None)
		{
			R6PlayerController(ViewportOwner.Actor).ClearReferences();
		}
        break;
    case LG_QuitGame: //Quit game        
         CleanPlanning();
         m_eNextStep = LG_QuitGame;     
         bCleanUp = true;
         break;
    case LG_MultiPlayerError: //Connection Lost return to multiplayer and pop message        
        m_eNextStep = LG_MultiPlayerError;
        bCleanUp = true;
        break;
    case LG_Trainning:
        CleanPlanning();
        m_eNextStep = LG_Trainning;
        bCleanUp = true;
        break;
	case LG_InitMod:
		CleanPlanning();
		m_eNextStep = LG_InitMod;
		bCleanUp = true;
		break;
    case LG_MainMenu:        
    default: //Go back to main menu
        CleanPlanning();
        m_eNextStep = LG_MainMenu;
        bCleanUp = true;
        break;
    }    


    if(bCleanUp)
    {
        if( (ViewportOwner.Actor != none) && (ViewportOwner.Actor.Level.NetMode == NM_Standalone))
        {
            if(ViewportOwner.Actor.Level != ViewportOwner.Actor.GetEntryLevel())
            {         
                master.m_StartGameInfo.m_MapName="Entry";
                PreloadMapForPlanning();                  
            }            
        }
        else
        {            
            ConsoleCommand("DISCONNECT"); 
        }            
    }       


    // We have left the game, if necessary, notify
    // ubi.com that we have left the server.
#ifndefSPDEMO
    class'Actor'.static.GetGameManager().ClientLeaveServer();
#endif
    //Fix resolution and Hud problems caused by the spawned r6hud
    ViewportOwner.Actor.SpawnDefaultHUD();

}

function CleanSound(eLeaveGame _bwhatToDo)
{
    ViewportOwner.Actor.StopAllSounds();
    ViewportOwner.Actor.ResetVolume_AllTypeSound();

#ifdefMPDEMO
    ViewportOwner.Actor.StopAllMusic();
#endif

    switch(_bwhatToDo)
    {
        case LG_RetryPlanningCustomMission: //Go back to planning phase Custom        
            ViewportOwner.Actor.FadeSound(0, 25, SLOT_Music);
        case LG_CustomMissionMenu:
        case LG_RetryPlanningCampaign:     //RETRY PLANNING IN CAMPAIGNMODE        
            // do nothing
            break;

        case LG_NextLevel:
            if (ViewportOwner.Actor.Level.NetMode != NM_Standalone)
                ViewportOwner.Actor.StopAllMusic();
            ViewportOwner.Actor.Level.SetBankSound(BANK_UnloadAll);
            ViewportOwner.Actor.Level.FinalizeLoading();    
            break;

        case LG_QuitGame:
        case LG_Trainning:
        case LG_MultiPlayerMenu:
		case LG_InitMod:
            ViewportOwner.Actor.StopAllMusic();
        case LG_MainMenu:        
        default:
            ViewportOwner.Actor.Level.SetBankSound(BANK_UnloadAll);
            ViewportOwner.Actor.Level.FinalizeLoading();    
            break;
    }
}

function CleanPlanning()
{
    if(ViewportOwner.Actor.Level.NetMode == NM_Standalone)
    {
		if ( (master == none) || (master.m_StartGameInfo == none))
			return;

        //Remove teamaster.m_StartGameInfom planning waypoints
        //Should not do this if we plan on using same map we played!
        master.m_StartGameInfo.m_TeamInfo[0].m_iNumberOfMembers=0;
        master.m_StartGameInfo.m_TeamInfo[1].m_iNumberOfMembers=0;
        master.m_StartGameInfo.m_TeamInfo[2].m_iNumberOfMembers=0;
		if(master.m_StartGameInfo.m_TeamInfo[0].m_pPlanning == none)
			return;

        master.m_StartGameInfo.m_TeamInfo[0].m_pPlanning.DeleteAllNode();
        master.m_StartGameInfo.m_TeamInfo[1].m_pPlanning.DeleteAllNode();
        master.m_StartGameInfo.m_TeamInfo[2].m_pPlanning.DeleteAllNode();
        master.m_StartGameInfo.m_TeamInfo[0].m_pPlanning.m_pTeamManager = none;
        master.m_StartGameInfo.m_TeamInfo[1].m_pPlanning.m_pTeamManager = none;
        master.m_StartGameInfo.m_TeamInfo[2].m_pPlanning.m_pTeamManager = none;
    }
}

function CloseR6MainMenu(optional BOOL bKeepInputSystem)
{    

    if(bShowLog)log("R6Console CloseR6MainMenu");

    if ((m_LanServers != none) && (m_LanServers.m_ClientBeacon != none))
    {
        m_LanServers.m_ClientBeacon.Destroy();
        m_LanServers.m_ClientBeacon = none;
    }
    if ((m_GameService != none) && (m_GameService.m_ClientBeacon != none))
    {
        m_GameService.m_ClientBeacon = none;
    }
    m_LanServers = none;

    bVisible = false;
    ResetUWindow();
    
    if(bKeepInputSystem == false)
    {
        // Set the input to the game setting.
        // 0 is the inGame input setting 
        // 1 is the Planning input setting
        ViewportOwner.Actor.ChangeInputSet(0);
        ViewportOwner.Actor.Level.m_bPlaySound = true;
    }
}

function PreloadMapForPlanning()
{
	local INT					iPlayerSpawnNumber;
            

    ConsoleCommand("Start "$master.m_StartGameInfo.m_MapName$"?SpawnNum="$iPlayerSpawnNumber);   

    // Set the input to the planning setting.
    // 0 is the InGame input setting 
    // 1 is the Planning input setting
    ViewportOwner.Actor.ChangeInputSet(1);
             
}

 
function CreateInGameMenus()
{
	local UWindowMenuClassDefines pMenuDefGSServers;

    log("R6Console CreateInGameMenus bLaunchMultiPlayer"@bLaunchMultiPlayer);

	pMenuDefGSServers = new(none) class'UWindowMenuClassDefines';
	pMenuDefGSServers.Created();

#ifndefMPDEMO    
    if(bLaunchMultiPlayer)
    {        
#endif
#ifndefSPDEMO
		RootWindow=pMenuDefGSServers.InGameMultiRoot;
	    bUWindowActive = True;
		CreateRootWindow(None); 
		LaunchUWindow();
#endif
#ifndefMPDEMO
    }        
    else
	{
		RootWindow=pMenuDefGSServers.InGameSingleRoot;
		CreateRootWindow(None); 
	}
#endif
}

function ResetR6Game()
{  
    if(bShowLog)log("R6Console ResetR6Game");
    bLaunchWasCalled = true; 
    bResetLevel = true;
}

function LaunchR6Game(OPTIONAL BOOL bSkipFrameAndStart_)
{
    if(bShowLog)log("R6Console LaunchR6Game");
    bLaunchWasCalled = true; 
    m_bSkipAFrameAndStart = bSkipFrameAndStart_; 
}

function LaunchR6MultiPlayerGame()
{     
    if(bShowLog)log("R6Console LaunchR6MultiPlayerGame");
    bLaunchWasCalled = true;
    bLaunchMultiPlayer = true;   
}

//=================================================================================
// LaunchTraining(): Launch training map and in-game menu, process is like single player map loading
//=================================================================================
function LaunchTraining()
{
    //For now, nothing more to do than preloading map.
    master.m_StartGameInfo.m_bIsPlaying = true;
    PreloadMapForPlanning();
}

function StartR6Game( OPTIONAL bool bResetLevel  )
{
	local R6PlayerController aPC;
    local R6GameInfo pGameInfo;
    

    if(bShowLog)log("R6Console StartR6Game bResetLevel="@bResetLevel);

    ViewportOwner.Actor.StopMusic(m_StopMainMenuMusic);

	m_bStartR6GameInProgress = true;
    
    if ( !bResetLevel )
    {
        class'Actor'.static.GetCanvas().m_iNewResolutionX = 0;
        class'Actor'.static.GetCanvas().m_iNewResolutionY = 0;
        class'Actor'.static.GetCanvas().m_bChangeResRequested = true;
    }

    //Remove Menu from memory
    if ( !bResetLevel )
        CloseR6MainMenu();
    
    //Load in game menus
   if ( !bResetLevel )
        CreateInGameMenus();  

    if(bLaunchMultiPlayer == false)
    {        
        //start spawning specific objects for the game selected
        //Spawn the Rainbow Team and the other pawns (terrorists, hostage, civilian) And change the controller.
		if( ViewportOwner.Actor.Level.Game.IsA('R6GameInfo') )
		{
            ViewportOwner.Actor.Level.Game.DeployCharacters(ViewportOwner.Actor);
		}
    }

    //Change the HUD
    pGameInfo = R6GameInfo(ViewportOwner.Actor.Level.Game);
    if ((pGameInfo != none) && (pGameInfo.m_HudClass != none))
        ViewportOwner.Actor.ClientSetHUD(R6GameInfo(ViewportOwner.Actor.Level.Game).m_HudClass ,none); //Second is scoreboard???
    else
        ViewportOwner.Actor.ClientSetHUD(class'Actor'.static.GetModMgr().GetDefaultHUD() ,none);

    // We flagged a lot of stuff to be destroyed, force garbage collection
    class'Actor'.static.GarbageCollect();

    // Init mission objectives, will look for pawn marked with special objectives flags...
	if( (ViewportOwner.Actor.Level.NetMode == NM_Standalone) && (ViewportOwner.Actor.Level.Game.IsA('R6AbstractGameInfo')) )
    {
        R6AbstractGameInfo(ViewportOwner.Actor.Level.Game).SpawnAIandInitGoInGame();
        ViewportOwner.Actor.Level.Game.m_bGameStarted = true;
    }

    // Set bMultiPlayerGameActive used by game service manager
    if ( bLaunchMultiPlayer )
    {
        class'Actor'.static.GetGameManager().m_bMultiPlayerGameActive = TRUE;

        //if ( !m_GameService.NativeGetMSClientInitialized() )
        //    m_GameService.InitializeMSClient();
    }
	else
	{
        // Add the sound for the gun use in the map.
    	aPC = R6PlayerController(ViewportOwner.Actor);
		if (aPC != none)
		{

            if (R6GameInfo(ViewportOwner.Actor.Level.Game).m_bUseClarkVoice)
            {
                // Set clark bank name
                aPC.AddSoundBankName(R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission).m_InGameVoiceClarkBankName);
                ViewportOwner.Actor.Level.m_sndPlayMissionIntro = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission).m_PlayMissionIntro;
                ViewportOwner.Actor.Level.m_sndPlayMissionExtro = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission).m_PlayMissionExtro;
            }

            ViewportOwner.Actor.ServerSendBankToLoad();

            aPC.ServerReadyToLoadWeaponSound();
		}
	}

    //log("Garbage collecter DONE!");    
    bLaunchMultiPlayer = false;
	m_bStartR6GameInProgress = false;
}

exec function unlock()
{
	local INT i, j;

	for ( i = 0; i < m_aCampaigns.Length; i++)
	{
		// for this campaign, unlock his map
		for(j = 0; j < m_aCampaigns[i].m_missions.Length; j++)
		{
			m_aCampaigns[i].m_missions[j].m_bIsLocked = false;
		}
	}
}


#ifdefDEBUG
exec function gg()
{
    GoToGame();
}

exec function GoToGame()
{
    master.m_StartGameInfo.m_SkipPlanningPhase = true;
    //Use default values in startgame
    
    PreloadMapForPlanning();

    LaunchR6Game();
}
#endif

function SendGoCode(EGoCode eGo)
{
    local INT i;
    
    for(i=0;i<3;i++)
    {
        Master.m_StartGameInfo.m_TeamInfo[i].m_pPlanning.NotifyActionPoint(NODEMSG_GoCodeLaunched, eGo);
    }
}


//==============================================================================
// GetSpawnNumber -  Helper function, returns the spawning point number.
//==============================================================================
function INT GetSpawnNumber()
{
    local R6StartGameInfo       StartGameInfo;

    StartGameInfo = master.m_StartGameInfo;
    if (StartGameInfo == none)
        return 0;

    if (!StartGameInfo.m_bIsPlaying)
        return 0;

    return StartGameInfo.m_TeamInfo[StartGameInfo.m_iTeamStart].m_iSpawningPointNumber;
}


//------------------------------------------------------------------
// GetCampaignFromString
//	
//------------------------------------------------------------------
function R6Campaign GetCampaignFromString( string szName )
{
    local INT  i, j;

    while ( i < m_aCampaigns.length )
    {
        if ( caps( m_aCampaigns[i].m_szCampaignFile ) == caps( szName ) )
        {
            return m_aCampaigns[i];
        }
        ++i;
    }

    return none;
}

//------------------------------------------------------------------
// UnlockMissions
//	- updated every time UpdateCurrentMapAvailable is changed
//------------------------------------------------------------------
function UnlockMissions()
{
    local INT  i, iMissionIndex, iMaxMissionIndex;
    local R6Campaign campaign;

    if ( m_playerCustomMission == none )
        return;

    for ( i = 0; i < m_playerCustomMission.m_aCampaignFileName.Length; i++)
    {
        campaign = GetCampaignFromString( m_playerCustomMission.m_aCampaignFileName[i] );

        // for this campaign, unlock his map
        if ( campaign != none )
        {
            // get the max mission to unlock
            iMaxMissionIndex = m_playerCustomMission.m_iNbMapUnlock[i];
            iMaxMissionIndex++; // start from 1 to max
                
            //if(bShowLog) log( " iMaxMissionIndex=" $iMaxMissionIndex$ " saved=" $m_playerCustomMission.m_iNbMapUnlock[i]$ " m_missions.length=" $campaign.m_missions.length );
            
            // check for limit
            iMaxMissionIndex = Clamp( iMaxMissionIndex, 0, campaign.m_missions.length );
            iMissionIndex = 0;
            
            // unlock map for that campaign
            while ( iMissionIndex < iMaxMissionIndex )
            {
                campaign.m_missions[ iMissionIndex ].m_bIsLocked = false;
                //log( "unlocked map= " $campaign.m_missions[ iMissionIndex ].m_mapName );
                ++iMissionIndex;
            }
        }
    }
}

//------------------------------------------------------------------
// UpdateCurrentMapAvailable
// 
//------------------------------------------------------------------
function BOOL UpdateCurrentMapAvailable(R6PlayerCampaign pCampaign, optional BOOL bCheckCampaignMission)
{
    local BOOL bFileChange;
    local BOOL bInTab;
    local INT  i,j;
    local string    szIniFile;
	local R6Campaign pCampaignMatch;

    // for all player campaign
    for (i=0; i< m_playerCustomMission.m_aCampaignFileName.Length; i++)
    {
        if (m_playerCustomMission.m_aCampaignFileName[i] == pCampaign.m_CampaignFileName)
        {
            bInTab = true;
            if (m_playerCustomMission.m_iNbMapUnlock[i] < pCampaign.m_iNoMission)
            {
                bFileChange = true;
                m_playerCustomMission.m_iNbMapUnlock[i] = pCampaign.m_iNoMission;
                
            }
            break;
        }
    }
	
    if (!bInTab && pCampaign.m_CampaignFileName != "")
    {
        m_playerCustomMission.m_aCampaignFileName[m_playerCustomMission.m_aCampaignFileName.Length] = pCampaign.m_CampaignFileName;
        m_playerCustomMission.m_iNbMapUnlock[m_playerCustomMission.m_iNbMapUnlock.Length] = pCampaign.m_iNoMission;
        bFileChange = true;
    }

	if(bCheckCampaignMission == true)
	{
		for(i = 0; i < m_aCampaigns.length; i++)
		{
			if(pCampaign.m_CampaignFileName == m_aCampaigns[i].m_szCampaignFile)
			{
				pCampaignMatch = m_aCampaigns[i];
				break;
			}
		}

		i=0;
		while ((pCampaignMatch != none) && (i < pCampaignMatch.missions.Length))
		{
			pCampaignMatch.missions[i] = caps( pCampaignMatch.missions[i] );
			szIniFile = pCampaignMatch.missions[i]$ ".INI";

			// Change the flag campaign mission
			j = 0;
			while ( j < m_aMissionDescriptions.Length )
			{
				if ( m_aMissionDescriptions[j].m_missionIniFile == szIniFile )
				{
					m_aMissionDescriptions[j].m_bCampaignMission = true;
					break;
				}
				j++;
			}
			i++;
		}
	}

    if ( bFileChange )
    {
        // a map has been unlocked, update mission descriptions
        UnlockMissions();
    }

    return bFileChange;
}

function BOOL MapAlreadyInList(string szIniFilename)
{
	local INT i;
	for(i=0; i < m_aMissionDescriptions.length; i++)
	{
		//log("comparing "$szIniFileName$" with "$m_aMissionDescriptions[i].m_missionIniFile);
		if( szIniFileName == m_aMissionDescriptions[i].m_missionIniFile )
		{
			return true;
		}
	}
	return false;
}
//------------------------------------------------------------------
// GetAllMissionDescriptions
//	
//------------------------------------------------------------------
function GetAllMissionDescriptions(string szCurrentMapDir)
{
    local int i, j, iFiles, iIniFiles, index;
    local R6FileManager         pIniFileManager;
    local string                szName,    szFilename;
    local string                szIniName, szIniFilename;
    local bool                  bMissionIsValid;
    local R6FileManager		    pFileManager;

	pIniFileManager = new(none) class'R6FileManager';
	pFileManager = new(none) class'R6FileManager';

	iIniFiles = pIniFileManager.GetNbFile(szCurrentMapDir, "ini");
	iFiles = pFileManager.GetNbFile(szCurrentMapDir, class'Actor'.static.GetMapNameExt() );

	if(bShowLog) log("Looking for maps In Dir : " $ szCurrentMapDir $ ", found : " $ iIniFiles $ " .ini files" $ " and " $ iFiles $ ".rsm");

	// loop on all .ini
	for ( i = 0; i < iIniFiles; i++ )
	{
		pIniFileManager.GetFileName( i, szIniFilename );

		if ( szIniFilename == "" )
			continue;

		bMissionIsValid = true;
		index = m_aMissionDescriptions.Length;

		if(MapAlreadyInList(szIniFilename))
			continue;

		m_aMissionDescriptions[ index ] = new(none) class'Engine.R6MissionDescription';
		m_aMissionDescriptions[ index ].Init( ViewportOwner.Actor.Level, szCurrentMapDir $ szIniFilename );

		// the it's a mission description ini file
		if ( m_aMissionDescriptions[ index ].m_mapName != "" )
		{
			// find the map
			for ( j = 0; j < iFiles; j++ )
			{
				bMissionIsValid = false;
				pFileManager.GetFileName( j, szFilename );

				if ( szFilename == "" )
					continue;

				szName = Left(szFilename, InStr(szFilename,"."));
				szName = caps( szName );

				if ( szName == caps(m_aMissionDescriptions[ index ].m_mapName) )
				{
					bMissionIsValid = true;
					break;
				}
			}
		} 
		else 
		{
			bMissionIsValid = false;
		}

		if ( !bMissionIsValid ) 
		{
			m_aMissionDescriptions.remove( index, 1 );
		}
    }

	UnlockMissions();
}


function GetRestKitDescName(GameReplicationInfo GameRepInfo, R6ServerInfo  pServerOptions)
{
    local int _iCount;
    local BOOL _bFound;
    local class<R6Description> WeaponClass;
    local R6GameReplicationInfo _GRI;

	// MPF - Eric
	local R6Mod	pCurrentMod;
	local INT	i;
	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod;
    
    _GRI = R6GameReplicationInfo(GameRepInfo);
	
	for (i = 0; i < pCurrentMod.m_aDescriptionPackage.Length; i++)
	{
		WeaponClass = class<R6Description>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[i]$".u", class'R6Description'));
		
		for (_iCount=0 ; (_iCount < ArrayCount(_GRI.m_szSubMachineGunsRes)) && (_GRI.m_szSubMachineGunsRes[_iCount]!=""); _iCount++)
		{
			_bFound = false;
			
			while ((WeaponClass != None) && (_bFound==false))
			{
				if (WeaponClass.Default.m_NameID == _GRI.m_szSubMachineGunsRes[_iCount])
				{
					pServerOptions.RestrictedSubMachineGuns[_iCount] = WeaponClass;
					_bFound=true;
				}
				WeaponClass = class<R6Description>(GetNextClass());
			}
			WeaponClass = class<R6Description>(RewindToFirstClass());
		}
		
		
		for (_iCount=0; (_iCount < ArrayCount(_GRI.m_szShotGunRes)) && (_GRI.m_szShotGunRes[_iCount]!="");  _iCount++)
		{
			_bFound = false;
			while ((WeaponClass != None) && (_bFound==false))
			{
				if (WeaponClass.Default.m_NameID == _GRI.m_szShotGunRes[_iCount])
				{
					pServerOptions.RestrictedShotGuns[_iCount] = WeaponClass;
					_bFound=true;
				}
				WeaponClass = class<R6Description>(GetNextClass());
			}  
			WeaponClass = class<R6Description>(RewindToFirstClass());
		}
		
		for (_iCount=0; (_iCount < ArrayCount(_GRI.m_szAssRifleRes)) && (_GRI.m_szAssRifleRes[_iCount]!="");  _iCount++)
		{
			_bFound = false;
			while ((WeaponClass != None) && (_bFound==false))
			{
				if (WeaponClass.Default.m_NameID == _GRI.m_szAssRifleRes[_iCount])
				{
					pServerOptions.RestrictedAssultRifles[_iCount] = WeaponClass;
					_bFound=true;
				}
				WeaponClass = class<R6Description>(GetNextClass());
			}  
			WeaponClass = class<R6Description>(RewindToFirstClass());
		}
		
		for (_iCount=0; (_iCount < ArrayCount(_GRI.m_szMachGunRes)) && (_GRI.m_szMachGunRes[_iCount]!="");  _iCount++)
		{
			_bFound = false;
			while ((WeaponClass != None) && (_bFound==false))
			{
				if (WeaponClass.Default.m_NameID == _GRI.m_szMachGunRes[_iCount])
				{
					pServerOptions.RestrictedMachineGuns[_iCount] = WeaponClass;
					_bFound=true;
				}
				WeaponClass = class<R6Description>(GetNextClass());
			}  
			WeaponClass = class<R6Description>(RewindToFirstClass());
		}
		
		for (_iCount=0; (_iCount < ArrayCount(_GRI.m_szSnipRifleRes)) && (_GRI.m_szSnipRifleRes[_iCount]!="");  _iCount++)
		{
			_bFound = false;
			while ((WeaponClass != None) && (_bFound==false))
			{
				if (WeaponClass.Default.m_NameID == _GRI.m_szSnipRifleRes[_iCount])
				{
					pServerOptions.RestrictedSniperRifles[_iCount] = WeaponClass;
					_bFound=true;
				}
				WeaponClass = class<R6Description>(GetNextClass());
			}  
			WeaponClass = class<R6Description>(RewindToFirstClass());
		}
		
		//Insert All Secondary Descriptions except None
		
		for (_iCount=0; (_iCount < ArrayCount(_GRI.m_szPistolRes)) && (_GRI.m_szPistolRes[_iCount]!=""); _iCount++)
		{
			_bFound = false;
			while ((WeaponClass != None) && (_bFound==false))
			{
				if (WeaponClass.Default.m_NameID == _GRI.m_szPistolRes[_iCount])
				{
					pServerOptions.RestrictedPistols[_iCount] = WeaponClass;
					_bFound=true;
				}
				WeaponClass = class<R6Description>(GetNextClass());
			}  
			WeaponClass = class<R6Description>(RewindToFirstClass());
		}
		
		for (_iCount=0; (_iCount < ArrayCount(_GRI.m_szMachPistolRes)) && (_GRI.m_szMachPistolRes[_iCount]!=""); _iCount++)
		{
			_bFound = false;
			while ((WeaponClass != None) && (_bFound==false))
			{
				if (WeaponClass.Default.m_NameID == _GRI.m_szMachPistolRes[_iCount])
				{
					pServerOptions.RestrictedMachinePistols[_iCount] = WeaponClass;
					_bFound=true;
				}
				WeaponClass = class<R6Description>(GetNextClass());
			}  
			WeaponClass = class<R6Description>(RewindToFirstClass());
		}
		
		FreePackageObjects();
	}
}

defaultproperties
{
     m_StopMainMenuMusic=Sound'Music.Play_theme_Musicsilence'
     RootWindow="R6Menu.R6MenuRootWindow"
}
