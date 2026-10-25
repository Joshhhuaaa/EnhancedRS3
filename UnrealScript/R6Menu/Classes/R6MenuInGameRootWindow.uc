//=============================================================================
//  R6MenuInGameRootWindow.uc : This ingame root menu should provide us with
//                              uwindow support in the game
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameRootWindow extends R6WindowRootWindow;

var     R6MenuDebriefingWidget              m_DebriefingWidget;
var     R6MenuInGameInstructionWidget       m_pInstructionWidget;     
var     R6MenuOptionsWidget			        m_OptionsWidget; 
var     R6MenuInGameOperativeSelectorWidget m_InGameOperativeSelectorWidget;   

//For esc menu and temporarely for enf of games as well
var     R6MenuInGameEsc						m_EscMenuWidget;
var     Region								m_REscMenuWidget;              // the border region 
var		Region								m_REscTraining;
var     FLOAT								m_fTopLabelHeight;

var     INT									m_ESCMenuKey;

var     bool								m_bCanDisplayOperativeSelector;
var     BOOL								m_bInEscMenu;
var		BOOL								m_bInTraining;
var		BOOL								m_bInPopUp;


function Created()
{    
    Super.Created();    

    m_eRootId = RootID_R6MenuInGame;

   	// In training map?
	m_bInTraining = (Root.Console.Master.m_StartGameInfo.m_GameMode == "R6Game.R6TrainingMgr");

    // Create Widgets
    m_DebriefingWidget= R6MenuDebriefingWidget(CreateWindow(class'R6MenuDebriefingWidget', 0, 0, 640, 480));	
    m_DebriefingWidget.HideWindow();

    m_InGameOperativeSelectorWidget = R6MenuInGameOperativeSelectorWidget(CreateWindow(class'R6MenuInGameOperativeSelectorWidget', 0, 0, 640, 480));  
    m_InGameOperativeSelectorWidget.HideWindow();

    m_EscMenuWidget = R6MenuInGameEsc(CreateWindow(class'R6MenuInGameEsc', 0, 0, 640, 480, Self));	
    m_EscMenuWidget.HideWindow();

    m_OptionsWidget =  R6MenuOptionsWidget(CreateWindow(class'R6MenuOptionsWidget', 0, 0, 640, 480));	
	m_OptionsWidget.HideWindow();

    m_pInstructionWidget = R6MenuInGameInstructionWidget(CreateWindow(class'R6MenuInGameInstructionWidget', 0, 0, 640, 480, Self));
    m_pInstructionWidget.HideWindow();
}

//==============================================================================================================
// ChangeInstructionWidget: change the instruction widget -- only in training
//==============================================================================================================
function ChangeInstructionWidget(Actor pISV, BOOL bShow, INT iBox, INT iParagraph)
{
	local INT i, iNbOfWindow;
    local R6InstructionSoundVolume aISV;

    aISV = R6InstructionSoundVolume(pISV);
    if (bShow)
    {
        m_pInstructionWidget.ChangeText(aISV, iBox, iParagraph);

		iNbOfWindow = m_pListOfActiveWidget.Length;

		for (i = 0; i < iNbOfWindow; i++)
		{
			if (m_pListOfActiveWidget[i].m_eGameWidgetID == InGameID_TrainingInstruction)
			{
				return;
			}
		}

		ChangeCurrentWidget( InGameID_TrainingInstruction);
    }
    else
    {        
		ChangeCurrentWidget( WidgetID_None);
    }
}

 
function ChangeCurrentWidget( eGameWidgetID widgetID )
{       
    switch( widgetID )
	{
        case PreviousWidgetID: // only happen when options is called             
		case InGameID_TrainingInstruction:
		case InGameID_OperativeSelector:
	    case InGameID_Debriefing:		
		case WidgetID_None:
			ChangeWidget( widgetID, true, false);
			break;
		case InGameID_EscMenu:
        case OptionsWidgetID:
			ChangeWidget( widgetID, false, false);
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

	iNbOfShowWindow = m_pListOfActiveWidget.Length; // number of window on the screen
	ConsoleState = 'UWindow';						// by default, the uwindow console is pop-up
	m_bWidgetResolutionFix = false;
	
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
	pStNewWidget.m_WidgetConsoleState = ConsoleState;

	GetPopUpFrame(iNbOfShowWindow).m_bBGClientArea = true; // always a BG for the client

//	log("m_eCurWidgetInUse : "$GetGameWidgetID(m_eCurWidgetInUse));

    switch( widgetID )
	{
		case InGameID_TrainingInstruction:
			pStNewWidget.m_pWidget = m_pInstructionWidget;
			pStNewWidget.m_WidgetConsoleState = 'TrainingInstruction';
			ConsoleState = 'TrainingInstruction';
			break;
	    case InGameID_Debriefing:
            Root.Console.ViewportOwner.Actor.Level.m_bInGamePlanningActive = false;
            Root.Console.ViewportOwner.Actor.Level.SetPlanningMode( false );
	        pStNewWidget.m_pWidget = m_DebriefingWidget;
			m_bWidgetResolutionFix = true;
			break;
		case InGameID_OperativeSelector:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow( Localize("OPERATIVESELECTOR","Title_ID","R6Menu"), m_fTopLabelHeight, 17, 33, 606, 397);
			pStNewWidget.m_pWidget     = m_InGameOperativeSelectorWidget;
			break;
		case InGameID_EscMenu:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			if(m_bInTraining)
				pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow( Localize("ESCMENUS","ESCMENU","R6Menu"), m_fTopLabelHeight, m_REscTraining.X, m_REscTraining.Y, m_REscTraining.W, m_REscTraining.H);
			else
				pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow( Localize("ESCMENUS","ESCMENU","R6Menu"), m_fTopLabelHeight, m_REscMenuWidget.X, m_REscMenuWidget.Y, m_REscMenuWidget.W, m_REscMenuWidget.H);
			pStNewWidget.m_pWidget	   = m_EscMenuWidget;
			break;
		case OptionsWidgetID:
			if (IsWidgetIsInHistory( InGameID_Debriefing))
				m_bWidgetResolutionFix = true;

			pStNewWidget.m_pWidget  = m_OptionsWidget;
			m_OptionsWidget.RefreshOptions();
			break;
		case WidgetID_None:
		case PreviousWidgetID: // only happen when options is called 
			if(iNbOfShowWindow != 0)
			{
				pStNewWidget = m_pListOfActiveWidget[iNbOfShowWindow - 1];
				ConsoleState = pStNewWidget.m_WidgetConsoleState;

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
			if (ConsoleState == 'TrainingInstruction')
			{
				Console.ViewportOwner.bSuspendPrecaching = False;
				Console.ViewportOwner.bShowWindowsMouse = False;
			}
			else // uwindow state
			{
//				if (!Console.IsInState('TrainingInstruction'))
//					CloseAllWindow();

				Console.ViewportOwner.bSuspendPrecaching = True;
				Console.ViewportOwner.bShowWindowsMouse = True;
			}

		    Console.bUWindowActive = true;

  			if(Console.Root != None)
	    			Console.Root.bWindowVisible = True;

			CheckConsoleTypingState( ConsoleState);
		}

		if (pStNewWidget.m_pPopUpFrame != None)
	        pStNewWidget.m_pPopUpFrame.ShowWindow();

        pStNewWidget.m_pWidget.ShowWindow();
		m_eCurWidgetInUse = pStNewWidget.m_eGameWidgetID;

		// add the element to the list
		m_pListOfActiveWidget[iNbOfShowWindow] = pStNewWidget;
	}
	else // no more widget to display 
    {
	    Console.bUWindowActive = False;
	    Console.ViewportOwner.bShowWindowsMouse = False;

	    if( Console.Root != None)
		    Console.Root.bWindowVisible = False;

	    CheckConsoleTypingState( 'Game');

	    Console.ViewportOwner.bSuspendPrecaching = False;
    }
}

function MoveMouse( float X, float Y)
{
	local UWindowWindow NewMouseWindow;
	local float tx, ty;

	MouseX = X;
	MouseY = Y;

	if(!bMouseCapture)
		NewMouseWindow = FindWindowUnder(X, Y);
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

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{    
    local R6GameInfo GameInfo;

	Super.PopUpBoxDone( Result, _ePopUpID );

    if ( Result == MR_OK )
    {
        switch ( _ePopUpID )
        {     
        case EPopUpID_LeaveInGameToMain :
            Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
            Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
            Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
            R6Console(console).LeaveR6Game(R6Console(console).eLeaveGame.LG_MainMenu);
            break;
        case EPopUpID_LeaveInGameToQuit :
#ifdefMPDEMO
                R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_QuitGame);
                break;
#endif
#ifdefSPDEMO
                R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_QuitGame);
                break;
#endif

                GetPlayerOwner().StopAllMusic();
                Root.DoQuitGame();
            break;
        case EPopUpID_AbortMissionRetryAction :
            Console.Master.m_StartGameInfo.m_SkipPlanningPhase = true;
            Console.Master.m_StartGameInfo.m_ReloadPlanning = true;
            Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = true;
            m_bInEscMenu=false;
            GetPlayerOwner().StopAllMusic();
            R6Console(Root.Console).ResetR6Game();            
            break;
            
        case EPopUpID_QuitTraining:
            Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
            Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
            Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
            R6Console(console).LeaveR6Game(R6Console(console).eLeaveGame.LG_Trainning); //Leave for custom mission Menu                                
            break;
		case EPopUpID_AbortMissionRetryPlan:
            Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
            Console.Master.m_StartGameInfo.m_ReloadPlanning = true;
            Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
		    GameInfo = R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game);

            GetPlayerOwner().StopAllMusic();

            if(GameInfo.m_bUsingPlayerCampaign)
            {                
                R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_RetryPlanningCampaign);    
            }
            else
			{
                R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_RetryPlanningCustomMission);
			}
			break;
        }
        
    }
    
    m_bInPopUp = false;    
}


function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
    switch( Msg )
    {
    case WM_Paint:
		if ((WinWidth != C.SizeX) || ( WinHeight != C.SizeY))
		{
			SetResolution( C.SizeX, C.SizeY);
		}

        Super.WindowEvent(Msg, C, X, Y, Key);
        break;        
    case WM_KeyUp:
		if (!ProcessKeyUp(Key))
			break;

		Super.WindowEvent( Msg, C, X, Y, Key );
        break;
    case WM_KeyDown:
		if (!ProcessKeyDown(Key))
			break;

		Super.WindowEvent( Msg, C, X, Y, Key );
        break;
    default:
        Super.WindowEvent( Msg, C, X, Y, Key );
    }
}


function SimplePopUp( string _szTitle, string _szText, ePopUpID _ePopUpID, optional INT _iButtonsType, OPTIONAL BOOL bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
    m_bInPopUp = true;    
	
	if (OwnerWindow == None)
		Super.SimplePopUp( _szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, Self);
	else
		Super.SimplePopUp( _szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, OwnerWindow);	  
}

//=======================================================================================
// ProcessKeyDown: Process key down for menu, return true, the key is process to all the menus
//=======================================================================================
function BOOL ProcessKeyDown( int Key)
{

    if (m_eCurWidgetInUse == OptionsWidgetID)
	{
		return true;
	}

	if (Key == m_ESCMenuKey )
	{   

		if((m_bInPopUp == true) || m_iLastKeyDown == m_ESCMenuKey)
        {    
            return true;
        }

        
		if( (m_eCurWidgetInUse != InGameID_EscMenu) )
		{
			if( !R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bGameOver )
			{ 
                Root.Console.ViewportOwner.Actor.Level.m_bInGamePlanningActive = false;
                Root.Console.ViewportOwner.Actor.Level.SetPlanningMode( false );                
				m_iLastKeyDown = m_ESCMenuKey;
				ChangeCurrentWidget( InGameID_EscMenu );
				m_bInEscMenu=true;                
			}
		}
		else // m_eCurWidgetInUse == InGameID_EscMenu
		{
			m_bInEscMenu=false;         
			ChangeCurrentWidget( WidgetID_None );
		}
		return false;
	}


    if ((Key == GetPlayerOwner().GetKey("OperativeSelector")) && (m_eCurWidgetInUse == WidgetID_None))
    {
		if (m_bCanDisplayOperativeSelector)
		{
			m_bCanDisplayOperativeSelector = false;
			ChangeCurrentWidget(InGameID_OperativeSelector);
		}
		return false;
    }

	return true;
}

//=======================================================================================
// ProcessKeyUp: Process key up for menu, return true, the key is process to all the menus
//=======================================================================================
function BOOL ProcessKeyUp( int Key)
{

	if((m_iLastKeyDown != -1) && m_iLastKeyDown == m_ESCMenuKey)
	{
		m_iLastKeyDown = -1;
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

	return true;
}

//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile( BOOL _bServerProfile)
{
	if (!_bServerProfile)
		m_OptionsWidget.MenuOptionsLoadProfile();
}

defaultproperties
{
     m_ESCMenuKey=27
     m_bCanDisplayOperativeSelector=True
     m_fTopLabelHeight=30.000000
     m_REscMenuWidget=(X=115,Y=36,W=410,H=380)
     m_REscTraining=(X=115,Y=250,W=410,H=55)
     LookAndFeelClass="R6Menu.R6MenuRSLookAndFeel"
}
