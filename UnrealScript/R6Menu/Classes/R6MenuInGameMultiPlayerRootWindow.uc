//=============================================================================
//  R6MenuInGameRootMultiPlayerRootWindow.uc : This ingame root menu should provide us with
//                              uwindow support in the multiplayer game
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameMultiPlayerRootWindow extends R6WindowRootWindow;

const C_iESC_POP_UP_HEIGHT				= 30;

//WIDGET KEY AVAILABILITY
const C_iWKA_NONE						= 0x00;
const C_iWKA_INBETROUND					= 0x01;
const C_iWKA_PRERECMESSAGES				= 0x02;
const C_iWKA_DRAWINGTOOL				= 0x04;
const C_iWKA_TOGGLE_STATS				= 0x08;
const C_iWKA_MENUCOUNTDOWN				= 0x10;
const C_iWKA_ESC						= 0x20;

const C_iWKA_INGAME						= 0x1F;
const C_iWKA_ALL						= 0x3F;

var		R6MenuInGameWritableMapWidget	m_InGameWritableMapWidget;
var     R6MenuMPJoinTeamWidget          m_pJoinTeamWidget;
var     R6MenuMPInterWidget             m_pIntermissionMenuWidget;
var     R6MenuMPInGameEsc               m_pInGameEscMenu;
var     R6MenuMPInGameRecMessages       m_pRecMessagesMenuWidget;
var     R6MenuMPInGameMsgOffensive      m_pOffensiveMenuWidget;
var     R6MenuMPInGameMsgDefensive      m_pDefensiveMenuWidget;
var     R6MenuMPInGameMsgReply          m_pReplyMenuWidget;
var     R6MenuMPInGameMsgStatus         m_pStatusMenuWidget;
var		R6MenuMPInGameVote				m_pVoteWidget;
var     R6MPGameMenuCom                 m_R6GameMenuCom;
var     R6MenuOptionsWidget				m_pOptionsWidget;
var		R6MenuMPCountDown				m_pCountDownWidget;
var		R6MenuInGameOperativeSelectorWidget m_InGameOperativeSelectorWidget;

var     Region                          m_RJoinWidget;
var     Region                          m_RInterWidget;              // the border region 
var     Region							m_REscPopUp;

var     BOOL                            bShowLog;
var     BOOL                            m_bActiveBar;                // active the bar for IN-GAME widget (server option, gear menu, etc)
var		BOOL							m_bActiveVoteMenu;
var     BOOL                            m_bCanDisplayOperativeSelector;

var     Actor.EGameModeInfo				m_eCurrentGameMode;
var     string							m_szCurrentGameType;

var     string							m_szGameModeLoc[2];			 // string of game mode loc
var		string							m_szCurrentGameModeLoc;

var     BOOL                            m_bPreventMenuSwitch;       //When this is true we don't allow widget change
var     Sound                           m_sndOpenDrawingTool;
var     Sound                           m_sndCloseDrawingTool;

var		BOOL							m_bMenuInvalid;				// true when gamemenucom is none or the playercontroller
var		BOOL							m_bPlayerDidASelection;		// true, player did a selection
var		BOOL							m_bJoinTeamWidget;			// force the welcome screen
var		BOOL							m_bTrapKey;					// trap key , engine will not receive the key

function Created()
{

    
    //create the interface between menu and server 
	super(UWindowRootWindow).Created();
	m_R6GameMenuCom = R6MPGameMenuCom(new Root.MenuClassDefines.ClassGameMenuCom);
    m_R6GameMenuCom.m_pCurrentRoot = self;
    m_R6GameMenuCom.PostBeginPlay();
    R6Console(Root.console).master.m_MenuCommunication = m_R6GameMenuCom;
  

    m_eRootId = RootID_R6MenuInGameMulti; 

    // Create Widgets -- display on popup frame
	m_InGameWritableMapWidget = R6MenuInGameWritableMapWidget(CreateWindow(Root.MenuClassDefines.ClassWritableMapWidget, 0.0, 0.0, 640.0, 480.0));
    m_InGameWritableMapWidget.HideWindow();

	m_pJoinTeamWidget = R6MenuMPJoinTeamWidget(CreateWindow(Root.MenuClassDefines.ClassJoinTeamWidget, 0.0, 0.0, 640.0, 480.0));
    m_pJoinTeamWidget.HideWindow();

	m_pIntermissionMenuWidget = R6MenuMPInterWidget(CreateWindow(Root.MenuClassDefines.ClassInterWidget, 0.0, 0.0, 640.0, 480.0));
    m_pIntermissionMenuWidget.HideWindow();

	m_pRecMessagesMenuWidget = R6MenuMPInGameRecMessages(CreateWindow(Root.MenuClassDefines.ClassInGameRecMessages, 0.0, 0.0, 640.0, 480.0));
    m_pRecMessagesMenuWidget.HideWindow();

	m_pOffensiveMenuWidget = R6MenuMPInGameMsgOffensive(CreateWindow(Root.MenuClassDefines.ClassInGameMsgOffensive, 0.0, 0.0, 640.0, 480.0));
    m_pOffensiveMenuWidget.HideWindow();

	m_pDefensiveMenuWidget = R6MenuMPInGameMsgDefensive(CreateWindow(Root.MenuClassDefines.ClassInGameMsgDefensive, 0.0, 0.0, 640.0, 480.0));
    m_pDefensiveMenuWidget.HideWindow();

	m_pReplyMenuWidget = R6MenuMPInGameMsgReply(CreateWindow(Root.MenuClassDefines.ClassInGameMsgReply, 0.0, 0.0, 640.0, 480.0));
    m_pReplyMenuWidget.HideWindow();

	m_pStatusMenuWidget = R6MenuMPInGameMsgStatus(CreateWindow(Root.MenuClassDefines.ClassInGameMsgStatus, 0.0, 0.0, 640.0, 480.0));
    m_pStatusMenuWidget.HideWindow();

	m_pVoteWidget = R6MenuMPInGameVote(CreateWindow(Root.MenuClassDefines.ClassInGameVote, 0.0, 0.0, 640.0, 480.0));
    m_pVoteWidget.HideWindow();

	m_pInGameEscMenu = R6MenuMPInGameEsc(CreateWindow(Root.MenuClassDefines.ClassInGameEsc, 0.0, 0.0, 640.0, 480.0));
    m_pInGameEscMenu.HideWindow();

	m_pOptionsWidget = R6MenuOptionsWidget(CreateWindow(Root.MenuClassDefines.ClassOptionsWidget, 0.0, 0.0, 640.0, 480.0));
	m_pOptionsWidget.HideWindow();

	m_pCountDownWidget = R6MenuMPCountDown(CreateWindow(Root.MenuClassDefines.ClassCountDown, 0.0, 0.0, 640.0, 480.0));
	m_pCountDownWidget.HideWindow();

	m_InGameOperativeSelectorWidget = R6MenuInGameOperativeSelectorWidget(CreateWindow(Root.MenuClassDefines.ClassInGameOperativeSelectorWidget, 0.0, 0.0, 640.0, 480.0));
    m_InGameOperativeSelectorWidget.HideWindow();

	m_szGameModeLoc[0] = Caps(Localize("MultiPlayer","GameMode_Adversarial","R6Menu"));
	m_szGameModeLoc[1] = Caps(Localize("MultiPlayer","GameMode_Cooperative","R6Menu"));

	FillListOfKeyAvailability();
}

//=============================================================================================
// FillListOfKeyAvailability: Fill the list of key availability
//							  Each widget (pop-up by a key) is define here
//=============================================================================================
function FillListOfKeyAvailability()
{
	AddKeyInList( GetPlayerOwner().GetKey("Talk"), C_iWKA_ALL);
	AddKeyInList( GetPlayerOwner().GetKey("TeamTalk"), C_iWKA_ALL);
	AddKeyInList( GetPlayerOwner().GetKey("ToggleGameStats"), C_iWKA_TOGGLE_STATS);
	AddKeyInList( GetPlayerOwner().GetKey("DrawingTool"), C_iWKA_DRAWINGTOOL);
	AddKeyInList( GetPlayerOwner().GetKey("VotingMenu"), C_iWKA_PRERECMESSAGES);
	AddKeyInList( GetPlayerOwner().GetKey("PreRecMessages"), C_iWKA_PRERECMESSAGES);
	AddKeyInList( GetPlayerOwner().GetKey("PrimaryWeapon"), C_iWKA_MENUCOUNTDOWN);
	AddKeyInList( GetPlayerOwner().GetKey("SecondaryWeapon"), C_iWKA_MENUCOUNTDOWN);
	AddKeyInList( GetPlayerOwner().GetKey("GadgetOne"), C_iWKA_MENUCOUNTDOWN);
	AddKeyInList( GetPlayerOwner().GetKey("GadgetTwo"), C_iWKA_MENUCOUNTDOWN);
	AddKeyInList( GetPlayerOwner().GetKey("RaisePosture"), C_iWKA_MENUCOUNTDOWN);
	AddKeyInList( GetPlayerOwner().GetKey("LowerPosture"), C_iWKA_MENUCOUNTDOWN);
	AddKeyInList( GetPlayerOwner().GetKey("ChangeRateOfFire"), C_iWKA_MENUCOUNTDOWN);
	AddKeyInList( GetPlayerOwner().GetKey("Reload"), C_iWKA_MENUCOUNTDOWN);
	AddKeyInList( Console.EInputKey.IK_Escape, C_iWKA_ESC);
}


//=============================================================================================
// ChangeCurrentWidget: Change the current widget
//=============================================================================================
function ChangeCurrentWidget( eGameWidgetID widgetID )
{    
    switch( widgetID )
	{
        case InGameMpWID_RecMessages:
        case InGameMpWID_MsgOffensive:
        case InGameMpWID_MsgDefensive:
        case InGameMpWID_MsgReply:
        case InGameMpWID_MsgStatus:
		case InGameMPWID_Vote:
		case InGameMPWID_TeamJoin:        
		case InGameMPWID_Intermission:		
 		case InGameMPWID_Writable:
		case InGameID_OperativeSelector:
		case PreviousWidgetID: // only happen when options is called 
		case WidgetID_None:
			ChangeWidget( widgetID, true, false);
			break;
		case InGameMPWID_CountDown:
		case InGameMPWID_InterEndRound: // this is call by the engine
			ChangeWidget( widgetID, true, true);
			break;
		case OptionsWidgetID:
			ChangeWidget( widgetID, false, false);
			break;
		case InGameMPWID_EscMenu:
			if ( Console.IsInState('UWindowCanPlay'))
			{
				if (m_bPlayerDidASelection) // if player choose a team or already play
				{
					ChangeWidget( WidgetID_None, true, false);
				}
				else // close stats page and pop esc menu
				{
					ChangeWidget( WidgetID_None, false, false);
					ChangeWidget( widgetID, false, false);
				}
			}
			else
			{
				ChangeWidget( widgetID, false, false);
			}
			break;
		default:
			break;
    }
}

//=============================================================================================
// ChangeWidget: Change widget according what`s you already have in your window list
//=============================================================================================
function ChangeWidget( eGameWidgetID widgetID, BOOL _bClearPrevWInHistory, BOOL _bCloseAll)
{
	local StWidget pStNewWidget;
	local name ConsoleState;
	local INT iNbOfShowWindow, i;

    if(m_bPreventMenuSwitch) //This is to see the stats when loading next map
        return;

	iNbOfShowWindow = m_pListOfActiveWidget.Length; // number of window on the screen
	ConsoleState = 'UWindow';						// by default, the uwindow console is pop-up

	if (_bCloseAll)
	{
		CloseAllWindow();
		iNbOfShowWindow = 0;
	}

	// if we clear the prev window in the list
	ManagePrevWInHistory( _bClearPrevWInHistory, iNbOfShowWindow);

	// assign the new current widget
	m_eCurWidgetInUse = widgetID;
	pStNewWidget.m_eGameWidgetID = widgetID;

	GetPopUpFrame(iNbOfShowWindow).m_bBGClientArea = true; // always a BG for the client

#ifdefDEBUG
	if (bShowLog)
	{	
		log("m_eCurWidgetInUse next (widgetID): "$GetGameWidgetID(widgetID));
		log("m_bActiveBar: "$m_bActiveBar);
	}
#endif

    switch( widgetID )
	{
		case InGameMPWID_TeamJoin:        
			UpdateCurrentGameMode();

			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow( Localize("MPInGame","TeamSelect","R6Menu"), 
															   R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RJoinWidget.X, m_RJoinWidget.Y, m_RJoinWidget.W, m_RJoinWidget.H);
			pStNewWidget.m_pWidget	   = m_pJoinTeamWidget;	

//			m_bActiveBar = true; // force the active bar -- fix bug temporary with bad server state
			m_pJoinTeamWidget.SetMenuToDisplay( m_szCurrentGameType);
			m_iWidgetKA = C_iWKA_TOGGLE_STATS | C_iWKA_ESC;
			break;
		case InGameMPWID_Intermission: // this is call by the player
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow( m_szCurrentGameModeLoc, 
															   R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RInterWidget.X, m_RInterWidget.Y, m_RInterWidget.W, m_RInterWidget.H);
			pStNewWidget.m_pPopUpFrame.m_bBGClientArea = false;
			pStNewWidget.m_pWidget	   = m_pIntermissionMenuWidget;

			m_pIntermissionMenuWidget.SetInterWidgetMenu( m_szCurrentGameType, m_bActiveBar);
			m_iWidgetKA = C_iWKA_TOGGLE_STATS | C_iWKA_ESC | C_iWKA_DRAWINGTOOL;

			if ((GetPlayerOwner().Pawn != None) && (GetPlayerOwner().Pawn.IsAlive()))
				m_bActiveBar = false;

			if ((!m_bActiveBar) && (m_bPlayerDidASelection)) // if the navbar is there, console state still the same
				ConsoleState = 'UWindowCanPlay';
			break;
		case InGameMPWID_InterEndRound: // this is call by the engine
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame .ModifyPopUpFrameWindow( m_szCurrentGameModeLoc, 
																R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RInterWidget.X, m_RInterWidget.Y, m_RInterWidget.W, m_RInterWidget.H);
			pStNewWidget.m_pPopUpFrame.m_bBGClientArea = false;
			pStNewWidget.m_pWidget	   = m_pIntermissionMenuWidget;

			m_bActiveBar = true; // force the active bar -- fix bug temporary with bad server state
			m_pIntermissionMenuWidget.SetInterWidgetMenu( m_szCurrentGameType, m_bActiveBar);
			m_iWidgetKA = C_iWKA_ESC | C_iWKA_DRAWINGTOOL;
			break;
 		case InGameMPWID_Writable:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pWidget	   = m_InGameWritableMapWidget;
			m_iWidgetKA = C_iWKA_DRAWINGTOOL | C_iWKA_ESC;
			break;
		case InGameMPWID_EscMenu:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow( Localize("ESCMENUS","ESCMENU","R6Menu"), C_iESC_POP_UP_HEIGHT, m_REscPopUp.X, m_REscPopUp.Y, m_REscPopUp.W, m_REscPopUp.H);
			pStNewWidget.m_pWidget	   = m_pInGameEscMenu;
			m_iWidgetKA = C_iWKA_ESC;
			break;
		case OptionsWidgetID:
			pStNewWidget.m_pWidget  = m_pOptionsWidget;
			m_pOptionsWidget.RefreshOptions();
			m_iWidgetKA = C_iWKA_ALL;
			break;
        case InGameMpWID_RecMessages:
			pStNewWidget.m_pWidget	   = m_pRecMessagesMenuWidget;
			m_iWidgetKA = C_iWKA_PRERECMESSAGES | C_iWKA_ESC;
			ConsoleState = 'UWindowCanPlay';
            break;
        case InGameMpWID_MsgOffensive:
			pStNewWidget.m_pWidget	   = m_pOffensiveMenuWidget;
			m_iWidgetKA = C_iWKA_PRERECMESSAGES | C_iWKA_ESC;
			ConsoleState = 'UWindowCanPlay';
            break;
        case InGameMpWID_MsgDefensive:
			pStNewWidget.m_pWidget	   = m_pDefensiveMenuWidget;
			m_iWidgetKA = C_iWKA_PRERECMESSAGES | C_iWKA_ESC;
			ConsoleState = 'UWindowCanPlay';
            break;
        case InGameMpWID_MsgReply:
			pStNewWidget.m_pWidget	   = m_pReplyMenuWidget;
			m_iWidgetKA = C_iWKA_PRERECMESSAGES | C_iWKA_ESC;
			ConsoleState = 'UWindowCanPlay';
            break;
        case InGameMpWID_MsgStatus:
			pStNewWidget.m_pWidget	   = m_pStatusMenuWidget;
			m_iWidgetKA = C_iWKA_PRERECMESSAGES | C_iWKA_ESC;
			ConsoleState = 'UWindowCanPlay';
			break;
		case InGameMPWID_Vote:
			pStNewWidget.m_pWidget	   = m_pVoteWidget;
			m_iWidgetKA = C_iWKA_PRERECMESSAGES | C_iWKA_ESC;
			ConsoleState = 'UWindowCanPlay';
			break;
		case InGameMPWID_CountDown:
			pStNewWidget.m_pWidget = m_pCountDownWidget;
			m_iWidgetKA = C_iWKA_MENUCOUNTDOWN;
			break;
		case InGameID_OperativeSelector:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow( Localize("OPERATIVESELECTOR","Title_ID","R6Menu"), C_iESC_POP_UP_HEIGHT, 217, 33, 206, 397);
			pStNewWidget.m_pWidget     = m_InGameOperativeSelectorWidget;
			break;
		case WidgetID_None:
			m_iWidgetKA = C_iWKA_ALL;
		case PreviousWidgetID: // only happen when options is called 
			if(iNbOfShowWindow != 0)
			{
				pStNewWidget = m_pListOfActiveWidget[iNbOfShowWindow - 1];
				m_iWidgetKA = pStNewWidget.iWidgetKA;

				iNbOfShowWindow -= 1; // because we add the item in the list after, but this item already exist
			}   		
			break;
		default:
			break;
    }

    if (pStNewWidget.m_pWidget != None) // new widget to display
	{
		if (!Console.IsInState(ConsoleState)) // if we are not in the good console state
		{
			CloseAllWindow();

		    Console.bUWindowActive = true;

  			if(Console.Root != None)
	    			Console.Root.bWindowVisible = True;

			CheckConsoleTypingState( ConsoleState);
		}

		if (ConsoleState == 'UWindow')
		{
			Console.ViewportOwner.bSuspendPrecaching = True;
			Console.ViewportOwner.bShowWindowsMouse = True;
		}

		if (pStNewWidget.m_pPopUpFrame != None)
	        pStNewWidget.m_pPopUpFrame.ShowWindow();

        pStNewWidget.m_pWidget.ShowWindow();
		pStNewWidget.iWidgetKA = m_iWidgetKA;
		m_eCurWidgetInUse = pStNewWidget.m_eGameWidgetID;

		// add the element to the list
		m_pListOfActiveWidget[iNbOfShowWindow] = pStNewWidget;

		// special cases
		if (m_eCurWidgetInUse == InGameMPWID_CountDown)
		{
			Console.ViewportOwner.bShowWindowsMouse = False;			
		}
	}
	else // no more widget to display 
    {
        // CloseUWindow()
	    Console.bUWindowActive = False;
	    Console.ViewportOwner.bShowWindowsMouse = False;


        bWindowVisible = False;


		CheckConsoleTypingState('Game');

	    //Console.ViewportOwner.bSuspendPrecaching = False;
    }
}

function UpdateCurrentGameMode()
{
	m_szCurrentGameType = m_R6GameMenuCom.GetGameType();

	if ( GetLevel().IsGameTypeAdversarial( m_szCurrentGameType))
	{
		m_eCurrentGameMode = GetLevel().EGameModeInfo.GMI_Adversarial;
		m_szCurrentGameModeLoc = m_szGameModeLoc[0];
	}
	else if (GetLevel().IsGameTypeCooperative( m_szCurrentGameType))
	{
		m_eCurrentGameMode = GetLevel().EGameModeInfo.GMI_Cooperative;
		m_szCurrentGameModeLoc = m_szGameModeLoc[1];
	}
	else
		log("szGameType:"@m_szCurrentGameType@"in R6MenuInGameMultiPlayerRootWindow not VALID");
}

//=====================================================================================================
//=====================================================================================================
function SimplePopUp( string _szTitle, string _szText, ePopUpID _ePopUpID, optional INT _iButtonsType, OPTIONAL BOOL bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
	if (OwnerWindow == None)
		Super.SimplePopUp( _szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, Self);
	else
		Super.SimplePopUp( _szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, OwnerWindow);

	if (m_eCurWidgetInUse == InGameMPWID_Writable)
	{
		ChangeCurrentWidget( WidgetID_None);
	}
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{
	Super.PopUpBoxDone( Result, _ePopUpID );

    if ( Result == MR_OK )
    {
        switch ( _ePopUpID )
        {     
			case EPopUpID_TKPenalty:
				m_R6GameMenuCom.TKPopUpDone(true);
				break;
			case EPopUpID_LeaveInGameToMultiMenu:
	            m_R6GameMenuCom.DisconnectClient( GetLevel() );
				R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_MultiPlayerMenu);
				break;
			case EPopUpID_LeaveInGameToMain:
                GetPlayerOwner().StopAllMusic();
	            m_R6GameMenuCom.DisconnectClient( GetLevel() );
				R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_MainMenu);
				break;
			case EPopUpID_LeaveInGameToQuit :
#ifdefMPDEMO
                R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_QuitGame);
#endif
#ifndefMPDEMO
                GetPlayerOwner().StopAllMusic();
                Root.DoQuitGame();
#endif
	            break;
			default:
				break;
		}
	}
	else if ( Result == MR_Cancel)
	{
        switch ( _ePopUpID )
        {     
			case EPopUpID_TKPenalty:
				m_R6GameMenuCom.TKPopUpDone(false);
				break;
			default:
				break;
		}
	}

	if (m_eCurWidgetInUse == WidgetID_None)
    {
	    Console.bUWindowActive = False;
	    Console.ViewportOwner.bShowWindowsMouse = False;

        bWindowVisible = False;

	    //Console.GotoState('Game');
	    //Console.ViewportOwner.bSuspendPrecaching = False;
		m_bActiveBar = true;
		ChangeWidget(WidgetID_None, false, false);
    }

	m_pInGameEscMenu.m_bEscAvailable = true;
}

function CloseSimplePopUpBox()
{
	if (m_pSimplePopUp != None)
	    m_pSimplePopUp.Close();
}

//=====================================================================================
// VoteMenuOn: Active the vote menu on/off (only if the player press on the specific key)
//=====================================================================================
function VoteMenu( string _szPlayerNameToKick, bool _ActiveMenu)
{
	m_bActiveVoteMenu = _ActiveMenu;
	m_pVoteWidget.m_szPlayerNameToKick = _szPlayerNameToKick;
	m_pVoteWidget.m_bFirstTimePaint	   = false; // refresh parameters
}


function NotifyBeforeLevelChange()
{
    if(bShowLog) log("R6MenuInGameMultiPlayerRootWindow::NotifyBeforeLevelChange()");

    if (m_R6GameMenuCom!=none)
    {
		if(bShowLog) R6Console(Root.console).ConsoleCommand("OBJ REFS CLASS=R6MPGameMenuCom NAME="$m_R6GameMenuCom);

        m_R6GameMenuCom.m_pCurrentRoot=none;
    }
    R6Console(Root.console).master.m_MenuCommunication = none;
    m_R6GameMenuCom=none;

    CheckConsoleTypingState('UWindow');

    Super.NotifyBeforeLevelChange();
}

function NotifyAfterLevelChange()
{
    if(bShowLog)
    {
        log("R6MenuInGameMultiPlayerRootWindow::NotifyAfterLevelChange()");
    }
    m_R6GameMenuCom = R6MPGameMenuCom(new Root.MenuClassDefines.ClassGameMenuCom);
    m_R6GameMenuCom.m_pCurrentRoot = self;
    m_R6GameMenuCom.PostBeginPlay();
    R6Console(Root.Console).Master.m_MenuCommunication = m_R6GameMenuCom;
    m_bJoinTeamWidget = true;
    m_bPlayerDidASelection = false;
    m_bPreventMenuSwitch = false;
    ChangeWidget(WidgetID_None, true, true);
    m_pIntermissionMenuWidget.SetNavBarInActive(false);
    super(UWindowWindow).NotifyAfterLevelChange();
}

function MoveMouse(float X, float Y)
{
	local UWindowWindow NewMouseWindow;
	local float tx, ty;

	MouseX = X;
	MouseY = Y;

    if(!bMouseCapture)
		NewMouseWindow = FindWindowUnder(X*m_fWindowScaleX, Y*m_fWindowScaleY);
	else
		NewMouseWindow = MouseWindow;

	if(NewMouseWindow != MouseWindow)
	{
		MouseWindow.MouseLeave();
		NewMouseWindow.MouseEnter();
		MouseWindow = NewMouseWindow;
	}

	if(MouseX != OldMouseX || MouseY != OldMouseY)
	{
		OldMouseX = MouseX;
		OldMouseY = MouseY;

		MouseWindow.GetMouseXY(tx, ty);     
		MouseWindow.MouseMove(tx, ty);
	}
    
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
		C.Style = ERenderStyle.STY_Alpha;

		C.SetPos( MouseX - MouseWindow.Cursor.HotX, MouseY - MouseWindow.Cursor.HotY );	
      
        // Draw the mouse cursor
        if( MouseWindow.Cursor.Tex != None )
        {
            MouseTex = MouseWindow.Cursor.Tex;
            C.DrawTile( MouseTex, MouseTex.USize, MouseTex.VSize, 0, 0, MouseTex.USize, MouseTex.VSize );
        }

		C.Style = ERenderStyle.STY_Normal;
    }
}

function Tick(float Delta)
{
	if (m_bJoinTeamWidget)
	{
		if (IsGameMenuComInitialized())
		{
//			m_R6GameMenuCom.SetStatMenuState(m_R6GameMenuCom.eClientMenuState.CMS_Initial);
			m_bJoinTeamWidget = false;
		}
	}
}

function Paint(Canvas C, float X, float Y)
{
	local string szTemp;
	local FLOAT W, H;

	if (m_bJoinTeamWidget)
	{
		// DrawBackGround
		C.Style = ERenderStyle.STY_Alpha;

		C.SetDrawColor( Root.Colors.Black.R, Root.Colors.Black.G, Root.Colors.Black.B);        

		DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, 0, 0, 10, 10, Texture'UWindow.WhiteTexture' );
		//

		szTemp = Localize("MP", "WaitingForServer", "R6Engine");

		C.Font = Root.Fonts[F_FirstMenuButton];
		C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);        

		TextSize( C, szTemp, W, H);
		W = ((WinWidth - W) * 0.5);
		H = ((WinHeight - H) * 0.5);

		C.SetPos( W, H);
		C.DrawText( szTemp);
	}
}

function BOOL IsGameMenuComInitialized()
{
	if ((m_R6GameMenuCom != None) && (m_R6GameMenuCom.IsInitialisationCompleted()))
		return true;

	return false;
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	// this is temporary until we find why the gamemenucom is invalid before/between changing map
	if ( Msg != WM_Paint)
	{
		if ( (!IsGameMenuComInitialized()) || 
			 (GetPlayerOwner() == None) || 
			 (GetLevel() == None) ||
			 (Console == None) )
		{
			if (GetSimplePopUpID() == EPopUpID_DownLoadingInProgress)
			{
				// process key if we are downloading file
				Super.WindowEvent( Msg, C, X*m_fWindowScaleX, Y*m_fWindowScaleY, Key );	
			}

			m_bMenuInvalid = true;
			m_pIntermissionMenuWidget.SetNavBarInActive( true, true);
			return;
		}
		else
		{
			if (m_bMenuInvalid)
			{
				m_bMenuInvalid = false;
				m_pIntermissionMenuWidget.SetNavBarInActive( false, true);
			}
		}
	}
	// end of temporary

    switch( Msg )
    {
    case WM_Paint:
		if (m_bScaleWindowToRoot)
		{
			C.UseVirtualSize(true, 640, 480);//, m_fWindowScaleX, m_fWindowScaleY);
			m_fWindowScaleX = C.GetVirtualSizeX() / C.SizeX;
			m_fWindowScaleY = C.GetVirtualSizeY() / C.SizeY;
			Super.WindowEvent(Msg, C, X, Y, Key);
			C.UseVirtualSize(false);
		}
		else
		{
			if ((WinWidth != C.SizeX) || ( WinHeight != C.SizeY))
			{
				SetResolution( C.SizeX, C.SizeY);
			}

			m_fWindowScaleX = 1;
			m_fWindowScaleY = 1;
	        Super.WindowEvent(Msg, C, X, Y, Key);
		}
        break;
    
    case WM_KeyDown:        
		if (m_eCurWidgetInUse != OptionsWidgetID)
		{
			if (!ProcessKeyDown( Key))
				break;
		}

        Super.WindowEvent( Msg, C, X*m_fWindowScaleX, Y*m_fWindowScaleY, Key );
        break;

    case WM_KeyUp:                        
		if (!ProcessKeyUp( Key))
			break;

        Super.WindowEvent( Msg, C, X*m_fWindowScaleX, Y*m_fWindowScaleY, Key );
        break;

    case WM_LMouseDown:
    case WM_LMouseUp:
    case WM_MMouseDown:
    case WM_MMouseUp:
    case WM_RMouseDown:
    case WM_RMouseUp:
        Super.WindowEvent( Msg, C, X*m_fWindowScaleX, Y*m_fWindowScaleY, Key );
        break;

    default:
        Super.WindowEvent( Msg, C, X*m_fWindowScaleX, Y*m_fWindowScaleY, Key );
		break;
    }
}

function BOOL ProcessKeyDown( int Key)
{
	local eGameWidgetID eNextWidgetIDUp, eNextWidgetIDDown;
	local INT i, iNbOfKeys;
	local BOOL bProcessWChange;
	local BOOL bProcessKeyToAllMenu, bIsInBetweenRound;;
    local PlayerController PC;
    

    PC = GetPlayerOwner();

	if (m_iLastKeyDown != -1) // this interrupt multiple key press
	{        
		return true; // the key is down, wait for a release
	}

	bProcessKeyToAllMenu = true;
	iNbOfKeys = m_pListOfKeyAvailability.Length;

	m_bTrapKey = true;

	// try to find the key and his availability
	for ( i = 0; i < iNbOfKeys; i++)
	{
		if (m_pListOfKeyAvailability[i].iKey == Key)
		{
			if ( (m_pListOfKeyAvailability[i].iWidgetKA & m_iWidgetKA) > 0) 
			{
				if (m_eCurWidgetInUse == InGameMPWID_CountDown)
				{
					m_bTrapKey = false;
				}

				break; // key is available
			}
			else
			{
#ifdefDEBUG
				if(bShowLog)log( "ProcessKeyDown returning Key is not available for this mode");
#endif
				return bProcessKeyToAllMenu; // process the key
			}
		}
	}

	bIsInBetweenRound = m_R6GameMenuCom.IsInBetweenRoundMenu();

	switch( Key)
	{
		case PC.GetKey("Talk"):
			Console.Talk();
			break;
		case PC.GetKey("TeamTalk"):
			Console.TeamTalk();
			break;
		case PC.GetKey("ToggleGameStats"):            
            R6Console(Root.console).bCancelFire = false;

			eNextWidgetIDUp   = InGameMPWID_Intermission;

			if (m_bPlayerDidASelection)
			{
				if (m_R6GameMenuCom.m_GameRepInfo.IsInAGameState())
				{
					eNextWidgetIDDown = WidgetID_None;
					bProcessWChange = true;
				}
			}
			else
			{
				eNextWidgetIDDown = InGameMPWID_TeamJoin;
				bProcessWChange = true;
			}
			break;
		case PC.GetKey("DrawingTool"):
			if ((R6GameReplicationInfo(PC.GameReplicationInfo).m_bIsWritableMapAllowed) && (m_R6GameMenuCom.IsAPlayerSelection()))
			{
				if ( ((PC.Pawn != None) && (PC.Pawn.IsAlive())) || (bIsInBetweenRound) )
				{
					eNextWidgetIDUp   = InGameMPWID_Writable;
					eNextWidgetIDDown = WidgetID_None;

					if(m_eCurWidgetInUse == InGameMPWID_Writable)
					{
						if (bIsInBetweenRound)
							eNextWidgetIDDown = m_ePrevWidgetInUse;

						if (PC.Pawn != none )
							PC.Pawn.PlaySound(m_sndCloseDrawingTool, SLOT_Menu);
					}
					else
					{
						if (bIsInBetweenRound)
							m_ePrevWidgetInUse = m_eCurWidgetInUse;
						else if (m_eCurWidgetInUse != WidgetID_None)
							break;

						if (PC.Pawn != none )
							PC.Pawn.PlaySound(m_sndOpenDrawingTool, SLOT_Menu);
					}

					bProcessWChange = true;
				}
			}
			break;
		case Console.EInputKey.IK_Escape:            
			eNextWidgetIDUp   = InGameMPWID_EscMenu;
			eNextWidgetIDDown = WidgetID_None;
			bProcessWChange = true;

			if (m_eCurWidgetInUse == InGameMPWID_EscMenu)
			{
				if (R6MenuMPInGameEsc(m_pListOfActiveWidget[m_pListOfActiveWidget.Length - 1].m_pWidget).m_bEscAvailable)
					bProcessKeyToAllMenu = false;
				else
					bProcessWChange = false;
			}
			else if (m_eCurWidgetInUse == InGameMPWID_Writable)
			{
				if (bIsInBetweenRound)
					eNextWidgetIDUp = m_ePrevWidgetInUse;
				else
					eNextWidgetIDUp = WidgetID_None;
			}
				
			break;
		case PC.GetKey("VotingMenu"):
			if (m_bActiveVoteMenu)
			{
                R6Console(Root.console).bCancelFire = false;
				eNextWidgetIDUp   = InGameMPWID_Vote;
				eNextWidgetIDDown = WidgetID_None;
				bProcessWChange = true;
			}
			break;
		case PC.GetKey("PreRecMessages"):
            if ((m_szCurrentGameType != "RGM_DeathmatchMode") && 
				!PC.isInState('Dead') && !PC.bOnlySpectator)
            {
                R6Console(Root.console).bCancelFire = false;
				eNextWidgetIDUp   = InGameMpWID_RecMessages;
				eNextWidgetIDDown = WidgetID_None;
				bProcessWChange = true;
            }
			break;
        case PC.GetKey("OperativeSelector"):
            if (GetLevel().IsGameTypeCooperative(m_R6GameMenuCom.GetGameType()) && 
                m_eCurWidgetInUse == WidgetID_None &&
                !PC.bOnlySpectator &&
                m_bCanDisplayOperativeSelector)
			{
				m_bCanDisplayOperativeSelector = false;
                eNextWidgetIDUp = InGameID_OperativeSelector;
                eNextWidgetIDDown = WidgetID_None;
                bProcessWChange = true;
			}
            break;
		default:
			break;
	}

	if (bProcessWChange)
	{
		if ( m_eCurWidgetInUse == eNextWidgetIDUp)
		{
			ChangeCurrentWidget( eNextWidgetIDDown ); // release the menu
			m_iLastKeyDown = -1;
		}
		else
		{
			ChangeCurrentWidget( eNextWidgetIDUp);		
			m_iLastKeyDown = Key;
		}
	}

    
	return bProcessKeyToAllMenu; // true --> continue to process the key to the menus
}

function BOOL ProcessKeyUp( int Key)
{
	if ( (m_iLastKeyDown != -1) && (m_iLastKeyDown == Key) )
	{
		m_iLastKeyDown = -1; // the key was press but is now release
	}

    if (Key == GetPlayerOwner().GetKey("OperativeSelector"))
    {
        if (m_eCurWidgetInUse == InGameID_OperativeSelector)
        {
            ChangeCurrentWidget( WidgetID_None );
        }

        m_bCanDisplayOperativeSelector = true;
       
        return false;
    }

	return true; // continue to process the key to the menus
}

//===================================================================
// TrapKey: Menu trap the key
//===================================================================
function BOOL TrapKey( BOOL _bIncludeMouseMove)
{
	if (_bIncludeMouseMove)
	{
		if (m_eCurWidgetInUse == InGameMPWID_CountDown)
		{
			return false;
		}
	}

	return m_bTrapKey;
}

//=============================================================================================
// UpdateTimeInBetRound:  Get the time between round pop-up and update the time
//=============================================================================================
function UpdateTimeInBetRound( INT _iNewTime, OPTIONAL string _StringInstead)
{
	local INT i, iNbOfWindow;

	iNbOfWindow = m_pListOfActiveWidget.Length;

	for (i = 0; i < iNbOfWindow; i++)
	{
		if ( (m_pListOfActiveWidget[i].m_eGameWidgetID == InGameMPWID_InterEndRound) ||
			 (m_pListOfActiveWidget[i].m_eGameWidgetID == InGameMPWID_Intermission) )
		{
            m_pListOfActiveWidget[i].m_pPopUpFrame.UpdateTimeInTextLabel(_iNewTime, _StringInstead);
			break;
		}
	}
}

//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile( BOOL _bServerProfile)
{
	if (!_bServerProfile)
		m_pOptionsWidget.MenuOptionsLoadProfile();
}

defaultproperties
{
     m_bCanDisplayOperativeSelector=True
     m_bJoinTeamWidget=True
     m_bTrapKey=True
     m_sndOpenDrawingTool=Sound'Common_Multiplayer.Play_DrawingTool_Open'
     m_sndCloseDrawingTool=Sound'Common_Multiplayer.Play_DrawingTool_Close'
     m_RJoinWidget=(X=25,Y=40,W=590,H=370)
     m_RInterWidget=(X=25,Y=80,W=590,H=370)
     m_REscPopUp=(X=115,Y=200,W=410,H=170)
     LookAndFeelClass="R6Menu.R6MenuRSLookAndFeel"
}
