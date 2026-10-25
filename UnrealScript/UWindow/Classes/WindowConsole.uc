	//=============================================================================
// WindowConsole - console replacer to implement UWindow UI System
//=============================================================================
class WindowConsole extends Console;

// Constants.
const MaxLines=64;
const TextMsgSize=128;

// Variables.
var viewport Viewport;
var int Scrollback, NumLines, TopLine, TextLines;
var float MsgTime, MsgTickTime;
var string MsgText[64];
var float MsgTick[64];
var int ConsoleLines;
var bool bNoStuff, bTyping;
var bool bShowLog;

// ---------


var UWindowRootWindow	Root;
var() config string		RootWindow;

var float				OldClipX;
var float				OldClipY;
var bool				bCreatedRoot;
var float				MouseX;
var float				MouseY;

var class<UWindowConsoleWindow> ConsoleClass;
var config float		MouseScale;
var config bool			bShowConsole;
var bool				bBlackout;
var bool				bUWindowType;

var bool				bUWindowActive;
var bool				bLocked;
var bool				bLevelChange;
var string				OldLevel;

//#ifndef R6CODE
//var config EInputKey	UWindowKey;
//#endif // #ifndef R6CODE

//ORIGINAL UNREAL CONSOLE var UWindowConsoleWindow ConsoleWindow; 

// R6CODE
var name ConsoleState;   
var string szStoreIP;           // String used to store IP of host server
//function class<object> GetRestKitDescName(string WeaponNameTag);
function GetRestKitDescName(GameReplicationInfo _GRI, R6ServerInfo  pServerOptions);
// R6CODE END

function ResetUWindow()
{
    if(bShowLog)log("WindowConsole::ResetUWindow");

	if(Root != None)
		Root.Close();
	Root = None;
	bCreatedRoot = False;
//ORIGINAL UNREAL CONSOLE	ConsoleWindow = None;
	bShowConsole = False;
	CloseUWindow();
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	local byte k;
	k = Key;
    if(bShowLog)log("WindowConsole state \" KeyEvent eAction"@Action@"Key"@Key);
	switch(Action)
	{
	case IST_Press:
        if (k == ViewportOwner.Actor.GetKey("Console"))
        {
			if (bLocked)
				return true;

			LaunchUWindow();
			if(!bShowConsole)
				ShowConsole();
			return true;
        }
        
		switch(k)
		{
		case EInputKey.IK_Escape:
			if (bLocked)
				return true;

			LaunchUWindow();
			return true;
		}
		break;
	}

	return False; 
	//!! because of ConsoleKey
	//!! return Super.KeyEvent(Key, Action, Delta);
}

function ShowConsole()
{
	bShowConsole = true;
//ORIGINAL UNREAL CONSOLE	if(bCreatedRoot)
//ORIGINAL UNREAL CONSOLE		ConsoleWindow.ShowWindow();
}

function HideConsole()
{
	ConsoleLines = 0;
	bShowConsole = false;
//ORIGINAL UNREAL CONSOLE	if (ConsoleWindow != None)
//ORIGINAL UNREAL CONSOLE		ConsoleWindow.HideWindow();
}

/*
event Tick( float Delta )
{
	Super.Tick(Delta);

	if(bLevelChange && Root != None && string(ViewportOwner.Actor.Level) != OldLevel)
	{
		OldLevel = string(ViewportOwner.Actor.Level);
		// if this is Entry, we could be falling through to another level...
		if(ViewportOwner.Actor.Level != ViewportOwner.Actor.GetEntryLevel())
			bLevelChange = False;
		Root.NotifyAfterLevelChange();
	}
}
*/

state UWindowCanPlay
{
    function BeginState()
    {
        if(bShowLog)log("UWindowCanPlay::BeginState");
        ConsoleState = GetStateName();
    }
    
    event Tick( float Delta )
	{
		Global.Tick(Delta);
		if(Root != None)
			Root.DoTick(Delta);
	}

	function PostRender( canvas Canvas )
	{
        if(bShowLog)log("UWindowCanPlay::PostRender");

		if(Root != None)
			Root.bUWindowActive = True;
		RenderUWindow( Canvas );
	}

	function bool KeyType( EInputKey Key )
	{
        if(bShowLog)log("WindowConsole state UWindowCanPlay KeyType Key"@Key);
		if (Root != None)
			Root.WindowEvent(WM_KeyType, None, MouseX, MouseY, Key);
		return True;
	}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local byte k;
		k = Key;
        if(bShowLog)log("WindowConsole state UWindowCanPlay KeyEvent eAction"@Action@"Key"@Key);
		switch (Action)
		{
		
        case IST_Release:
			if(Root != None)
				Root.WindowEvent(WM_KeyUp, None, MouseX, MouseY, k);
			break;

        case IST_Press:
            if (k == ViewportOwner.Actor.GetKey("Console"))
            {
                if (bLocked)
                    return true;

                Type();
                return true;

            }

            switch (k)
			{
			case EInputKey.IK_F9:	// Screenshot
				return Global.KeyEvent(Key, Action, Delta);
				break;
//			case EInputKey.IK_Escape:
//				if(Root != None)
//					Root.CloseActiveWindow();
//				break;
			default:
				if(Root != None)
					Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
				break;
			}
			break;
		default:
			break;
		}

        if (k >= EInputKey.IK_0 && k<= EInputKey.IK_9)
            return true;
        else 
            return false;

	}
}

state UWindow
{

	event Tick( float Delta )
	{
		Global.Tick(Delta);
		if(Root != None)
			Root.DoTick(Delta);
	}

	function PostRender( canvas Canvas )
	{
        if(bShowLog)log("Window Console state UWindow::PostRender");

		if(Root != None)
			Root.bUWindowActive = True;
		RenderUWindow( Canvas );
	}

	function bool KeyType( EInputKey Key )
	{
        if(bShowLog)log("WindowConsole state UWindow KeyType Key"@Key);
		if (Root != None)
			Root.WindowEvent(WM_KeyType, None, MouseX, MouseY, Key);
		return True;
	}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local byte k;
		k = Key;
        if(bShowLog)log("WindowConsole state UWindow KeyEvent eAction"@Action@"Key"@Key);
		switch (Action)
		{
		case IST_Release:
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
				if (bShowConsole)
				{
					HideConsole();
				}
				else
				{
					if(Root.bAllowConsole)
						ShowConsole();
					else
						Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
				}
				break;
            }

            switch (k)
			{
			case EInputKey.IK_F9:	// Screenshot
				return Global.KeyEvent(Key, Action, Delta);
				break;
			case EInputKey.IK_Escape:
				if(Root != None)
					Root.CloseActiveWindow();
				break;
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
			switch (Key)
			{
			case IK_MouseX:
				MouseX = MouseX + (MouseScale * Delta);
				break;
			case IK_MouseY:
				MouseY = MouseY - (MouseScale * Delta);
				break;					
			}
		default:
			break;
		}

		return true;
	}

Begin:
}

function ToggleUWindow()
{
}

function LaunchUWindow()
{	

    if(bShowLog)log("WindowConsole::LaunchUWindow");

    ViewportOwner.bSuspendPrecaching = True;
	bUWindowActive = True;    
	ViewportOwner.bShowWindowsMouse = True;

	if(Root != None)
		Root.bWindowVisible = True;

	GotoState('UWindow');
}

function CloseUWindow()
{
 
    if(bShowLog)log("WindowConsole::CloseUWindow");

	bUWindowActive = False;
	ViewportOwner.bShowWindowsMouse = False;   

	if(Root != None)
		Root.bWindowVisible = False;

	GotoState('Game');
	ViewportOwner.bSuspendPrecaching = False;
}

function CreateRootWindow(Canvas Canvas)
{
	local int i;

    if(bShowLog)log("WindowConsole::CreateRootWindow");

	if(Canvas != None)
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;
	}
	else
	{
		OldClipX = 0;
		OldClipY = 0;
	}
	
	// R6CODE log("Creating root window: "$RootWindow);
	
	Root = New(None) class<UWindowRootWindow>(DynamicLoadObject(RootWindow, class'Class'));

    // R6CODE log( Root );
    
	Root.BeginPlay();
	Root.WinTop = 0;
	Root.WinLeft = 0;

	if(Canvas != None)
	{
		Root.WinWidth = Canvas.ClipX / Root.GUIScale;
		Root.WinHeight = Canvas.ClipY / Root.GUIScale;
		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;
	}
	else
	{
		Root.WinWidth = 0;
		Root.WinHeight = 0;
		Root.RealWidth = 0;
		Root.RealHeight = 0;
	}

	Root.ClippingRegion.X = 0;
	Root.ClippingRegion.Y = 0;
	Root.ClippingRegion.W = Root.WinWidth;
	Root.ClippingRegion.H = Root.WinHeight;

	Root.Console = Self;

	Root.bUWindowActive = bUWindowActive;
    if(bShowLog)log("CreateRootWindow Setting Root.bUWindowActive="@Root.bUWindowActive);

	Root.Created();
	bCreatedRoot = True;

	// Create the console window.
//ORIGINAL UNREAL CONSOLE	ConsoleWindow = UWindowConsoleWindow(Root.CreateWindow(ConsoleClass, 100, 100, 200, 200));
	if(!bShowConsole)
		HideConsole();

//ORIGINAL UNREAL CONSOLE	UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(" ");
//ORIGINAL UNREAL CONSOLE	for (I=0; I<4; I++)
//ORIGINAL UNREAL CONSOLE		UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(MsgText[I]);
}

function RenderUWindow( canvas Canvas )
{
	local UWindowWindow NewFocusWindow;
	local R6GameOptions pGameOptions;

    if(bShowLog)log("WindowConsole::RenderUWindow state"@ GetStateName());

	pGameOptions = class'Actor'.static.GetGameOptions();

	Canvas.bNoSmooth = False;
	Canvas.Z = 1;
	Canvas.Style = 1;	
	Canvas.SetDrawColor(255, 255,255);
    
    // R6CODE
    MouseScale = Clamp(pGameOptions.MouseSensitivity, 10, 100) / 32.0f;

	if(ViewportOwner.bWindowsMouseAvailable && Root != None)
	{
		MouseX = ViewportOwner.WindowsMouseX/Root.GUIScale;
		MouseY = ViewportOwner.WindowsMouseY/Root.GUIScale;
	}

	if(!bCreatedRoot) 
		CreateRootWindow(Canvas);
	
	Root.bWindowVisible = True;
	Root.bUWindowActive = bUWindowActive;
    if(bShowLog)log("RenderUWindow Setting"@Root@".bUWindowActive="@Root.bUWindowActive);

	// this is to keep the good values of canvas for the root 
	if(Canvas.ClipX != Canvas.SizeX || Canvas.ClipY != Canvas.SizeY)
	{
		Canvas.ClipX = Canvas.SizeX;
		Canvas.ClipY = Canvas.SizeY;
	}

	if(Canvas.ClipX != OldClipX || Canvas.ClipY != OldClipY)
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;
		
		Root.WinTop = 0;
		Root.WinLeft = 0;
		Root.WinWidth = Canvas.ClipX / Root.GUIScale;
		Root.WinHeight = Canvas.ClipY / Root.GUIScale;

		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;

		Root.ClippingRegion.X = 0;
		Root.ClippingRegion.Y = 0;
		Root.ClippingRegion.W = Root.WinWidth;
		Root.ClippingRegion.H = Root.WinHeight;

		Root.Resized();
	}

	//if(MouseX > Root.WinWidth) MouseX = Root.WinWidth;
	//if(MouseY > Root.WinHeight) MouseY = Root.WinHeight;
    if(MouseX > Canvas.SizeX) MouseX    = Canvas.SizeX;
    if(MouseY > Canvas.SizeY) MouseY     = Canvas.SizeY;
	if(MouseX < 0) MouseX = 0;
	if(MouseY < 0) MouseY = 0;


	// Check for keyboard focus
	NewFocusWindow = Root.CheckKeyFocusWindow();

	if(NewFocusWindow != Root.KeyFocusWindow)
	{
		Root.KeyFocusWindow.KeyFocusExit();		
		Root.KeyFocusWindow = NewFocusWindow;
		Root.KeyFocusWindow.KeyFocusEnter();
	}

    if(bShowLog)log("WindowConsole::RenderUWindow root"@root);
    
	Root.ApplyResolutionOnWindowsPos(MouseX, MouseY);
	Root.MoveMouse(MouseX, MouseY);
	Root.WindowEvent(WM_Paint, Canvas, MouseX, MouseY, 0);
	if ((bUWindowActive) && ViewportOwner.bShowWindowsMouse)
		Root.DrawMouse(Canvas);
}

event Message( coerce string Msg, float MsgLife )
{
	Super.Message( Msg, MsgLife );

	if ( ViewportOwner.Actor == None )
		return;

//ORIGINAL UNREAL CONSOLE	if( (Msg!="") && (ConsoleWindow != None) )
//ORIGINAL UNREAL CONSOLE		UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(MsgText[TopLine]);
}

function UpdateHistory()
{
	// Update history buffer.
	History[HistoryCur++ % MaxHistory] = TypedStr;
	if( HistoryCur > HistoryBot )
		HistoryBot++;
	if( HistoryCur - HistoryTop >= MaxHistory )
		HistoryTop = HistoryCur - MaxHistory + 1;
}

function HistoryUp()
{
	if( HistoryCur > HistoryTop )
	{
		History[HistoryCur % MaxHistory] = TypedStr;
		TypedStr = History[--HistoryCur % MaxHistory];
	}
}

function HistoryDown()
{
	History[HistoryCur % MaxHistory] = TypedStr;
	if( HistoryCur < HistoryBot )
		TypedStr = History[++HistoryCur % MaxHistory];
	else
		TypedStr="";
}

function NotifyLevelChange()
{
    if(bShowLog)log("WindowConsole NotifyLevelChange");
    //Super.NotifyLevelChange();
	
	// rbrek - temporary fix (yjoly, adionne)
	if(GetStateName() == 'Typing' )
	{
		if(TypedStr!="")
		{
			TypedStr="";
			HistoryCur = HistoryTop;	
		}
		GotoState(ConsoleState);
	}

	bLevelChange = True;
	if(Root != None)
		Root.NotifyBeforeLevelChange();
}

function NotifyAfterLevelChange()
{
    if(bShowLog)log("WindowConsole NotifyAfterLevelChange");
	if(bLevelChange && Root != None)
	{	
	    bLevelChange = False;
		Root.NotifyAfterLevelChange();
	}
}

//===========================================================================================
// MenuLoadProfile: A profile was load
//===========================================================================================
function MenuLoadProfile( BOOL _bServerProfile)
{
	Root.MenuLoadProfile( _bServerProfile);
}

defaultproperties
{
     MouseScale=0.600000
     RootWindow="UWindow.UWindowRootWindow"
}
