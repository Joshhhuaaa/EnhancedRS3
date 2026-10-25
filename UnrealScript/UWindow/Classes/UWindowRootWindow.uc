//=============================================================================
// UWindowRootWindow - the root window.
//=============================================================================
class UWindowRootWindow extends UWindowWindow;

//#exec TEXTURE IMPORT NAME=MouseCursor FILE=Textures\MouseCursor.dds GROUP="Icons" MIPS=OFF ALPHA=1 MASKED=1
#exec TEXTURE IMPORT NAME=MouseMove FILE=Textures\MouseMove.bmp GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseDiag1 FILE=Textures\MouseDiag1.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseDiag2 FILE=Textures\MouseDiag2.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseNS FILE=Textures\MouseNS.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseWE FILE=Textures\MouseWE.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseHand FILE=Textures\MouseHand.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseHSplit FILE=Textures\MouseHSplit.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseVSplit FILE=Textures\MouseVSplit.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
//#exec TEXTURE IMPORT NAME=MouseWait FILE=Textures\MouseWait.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
//R6Code
#exec OBJ LOAD FILE=..\Textures\R6MenuTextures.utx PACKAGE=R6MenuTextures
#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning
#exec OBJ LOAD FILE=..\Textures\R6Font.utx PACKAGE=R6Font
//End R6Code

//!! Japanese text (experimental).
//#exec OBJ LOAD FILE=..\Textures\Japanese.utx

var UWindowWindow		MouseWindow;		// The window the mouse is over
var bool				bMouseCapture;
var float				MouseX, MouseY;
var float				OldMouseX, OldMouseY;
var WindowConsole		Console;
var UWindowWindow		FocusedWindow;
var UWindowWindow		KeyFocusWindow;		// window with keyboard focus
var MouseCursor			NormalCursor, MoveCursor, DiagCursor1, HandCursor, HSplitCursor, VSplitCursor, DiagCursor2, NSCursor, WECursor, WaitCursor;
var UWindowHotkeyWindowList	HotkeyWindows;

//var config float		GUIScale;
var  FLOAT		        GUIScale; //Alex- This is to prevent set res call to ovewrite this value in config file


var float				RealWidth, RealHeight;
var Font				Fonts[30];
var UWindowLookAndFeel	LooksAndFeels[20];
var config string		LookAndFeelClass;
var bool				bRequestQuit;
var float				QuitTime;
var bool				bAllowConsole;
//R6Code
var BOOL                m_bUseAimIcon;
var BOOL                m_bUseDragIcon;
var MouseCursor			AimCursor;
var MouseCursor			DragCursor;
var R6GameColors        Colors;
var UWindowMenuClassDefines  MenuClassDefines;
var UWindowWindow          m_NotifyMsgWindow;

var FLOAT				m_fWindowScaleX,
						m_fWindowScaleY;
var BOOL				m_bScaleWindowToRoot;

//End R6Code

var enum eRootID
{
    RootID_UWindow,
    RootID_R6Menu,
    RootID_R6MenuInGame,
    RootID_R6MenuInGameMulti
} m_eRootId;

//Mainly to provide the R6Console the ability to change the current Widget
enum eGameWidgetID
{
    WidgetID_None,    
    InGameID_EscMenu,
    InGameID_Debriefing,
	InGameID_TrainingInstruction,
    TrainingWidgetID,
    SinglePlayerWidgetID,
    CampaignPlanningID,
	MainMenuWidgetID,       
	IntelWidgetID,    
	PlanningWidgetID,
    RetryCampaignPlanningID,
    RetryCustomMissionPlanningID,
	GearRoomWidgetID,
    ExecuteWidgetID,
	CustomMissionWidgetID,
	MultiPlayerWidgetID,
	OptionsWidgetID,
    PreviousWidgetID,	
	CreditsWidgetID,
    MPCreateGameWidgetID,    
    UbiComWidgetID,
    UbiComModWidgetID,
    NonUbiWidgetID,
	InGameMPWID_Writable,
    InGameMPWID_TeamJoin,
    InGameMPWID_Intermission,
    InGameMPWID_InterEndRound,
    InGameMPWID_EscMenu,
    InGameMpWID_RecMessages,
    InGameMpWID_MsgOffensive,
    InGameMpWID_MsgDefensive,
    InGameMpWID_MsgReply,
    InGameMpWID_MsgStatus,
	InGameMPWID_Vote,
    InGameMPWID_CountDown,
    InGameID_OperativeSelector,
    MultiPlayerError,
    MultiPlayerErrorUbiCom,
    MenuQuitID    
};


var eGameWidgetID       m_eCurWidgetInUse;           // Current widget ID display on screen
var eGameWidgetID       m_ePrevWidgetInUse;          // Previous widget ID display on screen

var BOOL				m_bWidgetResolutionFix;		 // this is set in root by a widget to tell to the options if resolution is fix or not

function ChangeCurrentWidget( eGameWidgetID widgetID ); 
function ResetMenus( optional BOOL _bConnectionFailed);
function UpdateMenus(INT iWhatToUpdate);
function ChangeInstructionWidget( Actor pISV, BOOL bShow, INT iBox, INT iParagraph );
function StopPlayMode();
function BOOL PlanningShouldProcessKey();
function BOOL PlanningShouldDrawPath();
#ifdefDEBUG
exec function SaveTrainingPlanning();
#endif

// SimplePopUp fct
function ePopUpID GetSimplePopUpID();
function SimplePopUp( string _szTitle, string _szText, ePopUpID _ePopUpID, optional INT _iButtonsType, OPTIONAL BOOL bAddDisableDlg, optional UWindowWindow OwnerWindow);
function ModifyPopUpInsideText( array<string> _ANewText);

function BOOL GetMapNameLocalisation( string _szMapName, OUT string _szMapNameLoc, optional BOOL _bReturnInitName);

function BeginPlay() 
{
	Root = Self;
	MouseWindow = Self;
	KeyFocusWindow = Self;
}

function UWindowLookAndFeel GetLookAndFeel(String LFClassName)
{
	local int i;
	local class<UWindowLookAndFeel> LFClass;

	LFClass = class<UWindowLookAndFeel>(DynamicLoadObject(LFClassName, class'Class'));

	for(i=0;i<20;i++)
	{
		if(LooksAndFeels[i] == None)
		{
			LooksAndFeels[i] = new LFClass;
			LooksAndFeels[i].Setup();
			return LooksAndFeels[i];
		}

		if(LooksAndFeels[i].Class == LFClass)
			return LooksAndFeels[i];
	}
	Log("Out of LookAndFeel array space!!");
	return None;
}


function Created() 
{
    m_eRootId = RootID_UWindow;

	LookAndFeel = GetLookAndFeel(LookAndFeelClass);
	SetupFonts();

	NormalCursor.tex = Texture'R6MenuTextures.MouseCursor';
	NormalCursor.HotX = 0;
	NormalCursor.HotY = 0;
	NormalCursor.WindowsCursor = Console.ViewportOwner.IDC_ARROW;

	MoveCursor.tex = Texture'MouseMove';
	MoveCursor.HotX = 8;
	MoveCursor.HotY = 8;
	MoveCursor.WindowsCursor = Console.ViewportOwner.IDC_SIZEALL;
	
	DiagCursor1.tex = Texture'MouseDiag1';
	DiagCursor1.HotX = 8;
	DiagCursor1.HotY = 8;
	DiagCursor1.WindowsCursor = Console.ViewportOwner.IDC_SIZENWSE;
	
	HandCursor.tex = Texture'MouseHand';
	HandCursor.HotX = 11;
	HandCursor.HotY = 1;
	HandCursor.WindowsCursor = Console.ViewportOwner.IDC_ARROW;

	HSplitCursor.tex = Texture'MouseHSplit';
	HSplitCursor.HotX = 9;
	HSplitCursor.HotY = 9;
	HSplitCursor.WindowsCursor = Console.ViewportOwner.IDC_SIZEWE;

	VSplitCursor.tex = Texture'MouseVSplit';
	VSplitCursor.HotX = 9;
	VSplitCursor.HotY = 9;
	VSplitCursor.WindowsCursor = Console.ViewportOwner.IDC_SIZENS;

	DiagCursor2.tex = Texture'MouseDiag2';
	DiagCursor2.HotX = 7;
	DiagCursor2.HotY = 7;
	DiagCursor2.WindowsCursor = Console.ViewportOwner.IDC_SIZENESW;

	NSCursor.tex = Texture'MouseNS';
	NSCursor.HotX = 3;
	NSCursor.HotY = 7;
	NSCursor.WindowsCursor = Console.ViewportOwner.IDC_SIZENS;

	WECursor.tex = Texture'MouseWE';
	WECursor.HotX = 7;
	WECursor.HotY = 3;
	WECursor.WindowsCursor = Console.ViewportOwner.IDC_SIZEWE;

	WaitCursor.tex = Texture'R6MenuTextures.MouseWait';
	WECursor.HotX = 6;
	WECursor.HotY = 9;
	WECursor.WindowsCursor = Console.ViewportOwner.IDC_WAIT;     

//R6Code
    AimCursor.Tex=Texture'R6Planning.Cursors.PlanCursor_Aim';
    AimCursor.HotX=16;
    AimCursor.HotY=16;

    DragCursor.Tex=Texture'R6Planning.Cursors.PlanCursor_Drag';
    DragCursor.HotX=5;
    DragCursor.HotY=5;

    Colors = new(None) class'R6GameColors';
	MenuClassDefines = new(None) class'UWindowMenuClassDefines'; 
	MenuClassDefines.Created();
//End R6Code

	HotkeyWindows = New class'UWindowHotkeyWindowList';
	HotkeyWindows.Last = HotkeyWindows;
	HotkeyWindows.Next = None;
	HotkeyWindows.Sentinel = HotkeyWindows;

	Cursor = NormalCursor;
}

function MoveMouse(float X, float Y)
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
	local float X, Y;

	if(Console.ViewportOwner.bWindowsMouseAvailable)
	{
		// Set the windows cursor...
		Console.ViewportOwner.SelectedCursor = MouseWindow.Cursor.WindowsCursor;
	}
	else
	{
		C.SetDrawColor(255,255,255);

		C.SetPos(MouseX * GUIScale - MouseWindow.Cursor.HotX, MouseY * GUIScale - MouseWindow.Cursor.HotY);
		C.DrawIcon(MouseWindow.Cursor.tex, 1.0);
	}



	/* DEBUG - show which window mouse is over

	MouseWindow.GetMouseXY(X, Y);
	C.Font = Fonts[F_Normal];

	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.SetPos(MouseX * GUIScale - MouseWindow.Cursor.HotX, MouseY * GUIScale - MouseWindow.Cursor.HotY);
	C.DrawText( GetPlayerOwner().GetItemName(string(MouseWindow))$" "$int(MouseX * GUIScale)$", "$int(MouseY * GUIScale)$" ("$int(X)$", "$int(Y)$")");

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 0;
	C.SetPos(-1 + MouseX * GUIScale - MouseWindow.Cursor.HotX, -1 + MouseY * GUIScale - MouseWindow.Cursor.HotY);
	C.DrawText( GetPlayerOwner().GetItemName(string(MouseWindow))$" "$int(MouseX * GUIScale)$", "$int(MouseY * GUIScale)$" ("$int(X)$", "$int(Y)$")");

	*/
}

function bool CheckCaptureMouseUp()
{
	local float X, Y;

	if(bMouseCapture) {
		MouseWindow.GetMouseXY(X, Y);
		MouseWindow.LMouseUp(X, Y);
		bMouseCapture = False;
		return True;
	}
	return False;
}

function bool CheckCaptureMouseDown()
{
	local float X, Y;

	if(bMouseCapture) {
		MouseWindow.GetMouseXY(X, Y);
		MouseWindow.LMouseDown(X, Y);
		bMouseCapture = False;
		return True;
	}
	return False;
}


function CancelCapture()
{
	bMouseCapture = False;
}


function CaptureMouse(optional UWindowWindow W)
{
	bMouseCapture = True;
	if(W != None)
		MouseWindow = W;
	//Log(MouseWindow.Class$": Captured Mouse");
}

function Texture GetLookAndFeelTexture()
{
	Return LookAndFeel.Active;
}

function bool IsActive()
{
	Return True;
}

function AddHotkeyWindow(UWindowWindow W)
{
	UWindowHotkeyWindowList(HotkeyWindows.Insert(class'UWindowHotkeyWindowList')).Window = W;
}

function RemoveHotkeyWindow(UWindowWindow W)
{
	local UWindowHotkeyWindowList L;

	L = HotkeyWindows.FindWindow(W);
	if(L != None)
	{
		L.Remove();
	}
}

function BOOL IsAHotKeyWindow(UWindowWindow W)
{
	local UWindowHotkeyWindowList L;

	L = HotkeyWindows.FindWindow(W);

	if (L != None)
		return true;

	return false;
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	switch(Msg) {
	case WM_KeyDown:
		if(HotKeyDown(Key, X, Y))
			return;
		break;
	case WM_KeyUp:
		if(HotKeyUp(Key, X, Y))
			return;
		break;
    case WM_LMouseDown:
//    case WM_LMouseUp:
    case WM_MMouseDown:
//    case WM_MMouseUp:
    case WM_RMouseDown:
//    case WM_RMouseUp:
		if (MouseUpDown(Key, X, Y))
			return;
		break;
	}

	Super.WindowEvent(Msg, C, X, Y, Key);
}


function bool HotKeyDown(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList l;

	l = UWindowHotkeyWindowList(HotkeyWindows.Next);
	while(l != None) 
	{
		if(l.Window != Self && l.Window.HotKeyDown(Key, X, Y)) return True;
		l = UWindowHotkeyWindowList(l.Next);
	}

	return False;
}

function bool HotKeyUp(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList l;

	l = UWindowHotkeyWindowList(HotkeyWindows.Next);
	while(l != None) 
	{
		if(l.Window != Self && l.Window.HotKeyUp(Key, X, Y)) return True;
		l = UWindowHotkeyWindowList(l.Next);
	}

	return False;
}

function bool MouseUpDown(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList l;

	l = UWindowHotkeyWindowList(HotkeyWindows.Next);
	while(l != None) 
	{
		if(l.Window != Self && l.Window.MouseUpDown(Key, X, Y)) return True;
		l = UWindowHotkeyWindowList(l.Next);
	}

	return False;
}

function CloseActiveWindow()
{
	if(ActiveWindow != None)
		ActiveWindow.EscClose();
	else
		Console.CloseUWindow();
}

function Resized()
{
	ResolutionChanged(WinWidth, WinHeight);
}

function SetScale(float NewScale)
{
	WinWidth = RealWidth / NewScale;
	WinHeight = RealHeight / NewScale;

	GUIScale = NewScale;

	ClippingRegion.X = 0;
	ClippingRegion.Y = 0;
	ClippingRegion.W = WinWidth;
	ClippingRegion.H = WinHeight;

	SetupFonts();

	Resized();
}

function SetResolution( FLOAT _NewWidth, FLOAT _NewHeight)
{
	WinWidth = _NewWidth;
	WinHeight = _NewHeight;

	ClippingRegion.X = 0;
	ClippingRegion.Y = 0;
	ClippingRegion.W = WinWidth;
	ClippingRegion.H = WinHeight;

	Resized();
}

function SetupFonts()
{
	//!! Japanese text (experimental).
	/*if( true )
	{
		Fonts[F_Normal]    = Font(DynamicLoadObject("Japanese.Japanese", class'Font'));
		Fonts[F_Bold]      = Font(DynamicLoadObject("Japanese.Japanese", class'Font'));
		Fonts[F_Large]     = Font(DynamicLoadObject("Japanese.Japanese", class'Font'));
		Fonts[F_LargeBold] = Font(DynamicLoadObject("Japanese.Japanese", class'Font'));
		return;
	}*/    

    // News fonts system
    Fonts[F_MenuMainTitle]   = font'R6Font.Rainbow6_36pt';
    Fonts[F_SmallTitle]      = font'R6Font.Rainbow6_14pt';
    Fonts[F_VerySmallTitle]  = font'R6Font.Rainbow6_12pt';
    Fonts[F_TabMainTitle]    = font'R6Font.Rainbow6_15pt';
    Fonts[F_PopUpTitle]      = font'R6Font.Rainbow6_15pt';
    Fonts[F_IntelTitle]      = font'R6Font.OcraExt_14pt';

    Fonts[F_ListItemSmall]   = font'R6Font.Arial_10pt';
    Fonts[F_ListItemBig]     = font'R6Font.Rainbow6_14pt';
    Fonts[F_HelpWindow]      = font'R6Font.Rainbow6_12pt';

    Fonts[F_FirstMenuButton] = font'R6Font.Rainbow6_36pt';
    Fonts[F_MainButton]      = font'R6Font.Rainbow6_17pt';
    Fonts[F_PrincipalButton] = font'R6Font.Rainbow6_17pt';
//    Fonts[F_SmallButton]     = font'R6Font.Rainbow6_14pt';
    Fonts[F_CheckBoxButton]  = font'R6Font.Rainbow6_12pt';

// to remove 

    Fonts[F_Normal]      = font'R6Font.Rainbow6_12pt'; // this one prevent access none everywhere take care to remove that for the moment YJ

}

function ChangeLookAndFeel(string NewLookAndFeel)
{
	LookAndFeelClass = NewLookAndFeel;
	SaveConfig();

	// Completely restart UWindow system on the next paint
	Console.ResetUWindow();
}

function HideWindow()
{
}

function SetMousePos(float X, float Y)
{
	Console.MouseX = X;
	Console.MouseY = Y;
}

function QuitGame()
{
	bRequestQuit = True;
	QuitTime = 0;
	NotifyQuitUnreal();
}

function DoQuitGame()
{
	SaveConfig();
	//Console.SaveConfig();
	//Console.ViewportOwner.Actor.SaveConfig();
	Console.ViewportOwner.Actor.ConsoleCommand("exit");
}

function Tick(float Delta)
{
	if(bRequestQuit)
	{
		// Give everything time to close itself down (ie sockets).
		if(QuitTime > 0.25)
			DoQuitGame();
		QuitTime += Delta;
	}

	Super.Tick(Delta);
}

//ifdef R6CODE
// MPF Yannick
function SetNewMODS( string _szNewBkgFolder, optional BOOL _bForceRefresh) {}
function SetLoadRandomBackgroundImage( string _szFolder) {}

function PaintBackground( Canvas C, UWindowWindow _WidgetWindow) {}

//===================================================================
// DrawBackGroundEffect: draw a background fullscreen -- need for pop-up 
//===================================================================
function DrawBackGroundEffect( Canvas C, Color _BGColor)
{
	local float OrgX, OrgY, ClipX, ClipY;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	// bypass current window origin and clipping by parameters of the root
	C.SetOrigin( 0, 0);
	C.SetClip( C.SizeX, C.SizeY);

    C.SetDrawColor( _BGColor.R, _BGColor.G, _BGColor.B, _BGColor.A);

	C.SetPos( 0, 0);
	C.DrawTile( Texture'UWindow.WhiteTexture', C.SizeX, C.SizeY, 0, 0, 10, 10);

	// restore current window parameters
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
}
//endif

//===================================================================
// TrapKey: Menu trap the key
//===================================================================
function BOOL TrapKey( BOOL _bIncludeMouseMove)
{
	return true;
}

#ifdefDEBUG
function string GetGameWidgetID( eGameWidgetID _eGameWidgetID)
{
	local string szResult;

	switch(_eGameWidgetID)
	{
		case WidgetID_None:							szResult = "WidgetID_None"; break;
		case InGameID_EscMenu:						szResult = "InGameID_EscMenu"; break;
		case InGameID_Debriefing:					szResult = "InGameID_Debriefing"; break;
		case InGameID_TrainingInstruction:			szResult = "InGameID_TrainingInstruction";	break;
		case SinglePlayerWidgetID:					szResult = "SinglePlayerWidgetID";	break;
        case TrainingWidgetID:                      szResult = "TrainingWidgetID";	break;
		case CampaignPlanningID:					szResult = "CampaignPlanningID"; break;
		case MainMenuWidgetID:						szResult = "MainMenuWidgetID"; break;
		case IntelWidgetID:							szResult = "IntelWidgetID";	break;
		case PlanningWidgetID:						szResult = "PlanningWidgetID";	break;
		case RetryCampaignPlanningID:				szResult = "RetryCampaignPlanningID"; break;
		case RetryCustomMissionPlanningID:			szResult = "RetryCustomMissionPlanningID";	break;
		case GearRoomWidgetID:						szResult = "GearRoomWidgetID";	break;
		case ExecuteWidgetID:						szResult = "ExecuteWidgetID"; break;
		case CustomMissionWidgetID:					szResult = "CustomMissionWidgetID";	break;
		case MultiPlayerWidgetID:					szResult = "MultiPlayerWidgetID"; break;
		case OptionsWidgetID:						szResult = "OptionsWidgetID"; break;
		case PreviousWidgetID:						szResult = "PreviousWidgetID"; break;
		case CreditsWidgetID:						szResult = "CreditsWidgetID"; break;
		case MPCreateGameWidgetID:					szResult = "MPCreateGameWidgetID"; break;
		case UbiComWidgetID:						szResult = "UbiComWidgetID"; break;
		case NonUbiWidgetID:						szResult = "UbiComWidgetID"; break;
		case InGameMPWID_Writable:					szResult = "InGameMPWID_Writable";	break;
		case InGameMPWID_TeamJoin:					szResult = "InGameMPWID_TeamJoin";	break;
		case InGameMPWID_Intermission:				szResult = "InGameMPWID_Intermission"; break;
		case InGameMPWID_InterEndRound:				szResult = "InGameMPWID_InterEndRound";	break;
		case InGameMPWID_EscMenu:					szResult = "InGameMPWID_EscMenu"; break;
		case InGameMpWID_RecMessages:				szResult = "InGameMpWID_RecMessages"; break;
		case InGameMpWID_MsgOffensive:				szResult = "InGameMpWID_MsgOffensive"; break;
		case InGameMpWID_MsgDefensive:				szResult = "InGameMpWID_MsgDefensive"; break;
		case InGameMpWID_MsgReply:					szResult = "InGameMpWID_MsgReply"; break;
		case InGameMpWID_MsgStatus:					szResult = "InGameMpWID_MsgStatus";	break;
		case InGameMPWID_Vote:						szResult = "InGameMPWID_Vote"; break;
		case InGameMPWID_CountDown:					szResult = "InGameMPWID_CountDown"; break;
		case InGameID_OperativeSelector:			szResult = "InGameID_OperativeSelector"; break;
		case MultiPlayerError:						szResult = "MultiPlayerError"; break;
		case MultiPlayerErrorUbiCom:				szResult = "MultiPlayerErrorUbiCom"; break;
		case MenuQuitID:							szResult = "MenuQuitID"; break;
		default:
			szResult = "WIDGET ID NOT DEFINE IN GetGameWidgetID()";
			break;
	}

	return szResult;
}
#endif

function RegisterMsgWindow( UWindowWindow _NotifyMsgWindow )
{
	m_NotifyMsgWindow = _NotifyMsgWindow;
}

function UnRegisterMsgWindow()
{
	m_NotifyMsgWindow = None;
}

function ProcessGSMsg( string _szMsg )
{
	if ( m_NotifyMsgWindow != None )
		m_NotifyMsgWindow.ProcessGSMsg( _szMsg );
}

defaultproperties
{
     bAllowConsole=True
     GUIScale=1.000000
     m_fWindowScaleX=1.000000
     m_fWindowScaleY=1.000000
}
