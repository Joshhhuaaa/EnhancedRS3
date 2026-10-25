//=============================================================================
// UWindowDialogControl - a control which notifies a dialog control group
//=============================================================================
class UWindowDialogControl extends UWindowWindow;

var UWindowDialogClientWindow	NotifyWindow;
var string Text;
var int Font;
var color TextColor;
var TextAlign Align;
var float TextX, TextY;		// changed by BeforePaint functions
var bool bHasKeyboardFocus;
var bool bNoKeyboard;
var bool bAcceptExternalDragDrop;
var string HelpText;
var float MinWidth, MinHeight;	// minimum heights for layout control

var UWindowDialogControl	TabNext;
var UWindowDialogControl	TabPrev;


function Created()
{
	if(!bNoKeyboard)
	{
		SetAcceptsFocus();
	}
}

function KeyFocusEnter()
{
	bHasKeyboardFocus = True;
}

function KeyFocusExit()
{	
	bHasKeyboardFocus = False;
}

function SetHelpText(string NewHelpText)
{
	HelpText = NewHelpText;
}

function SetText(string NewText)
{
	Text = NewText;
}

function BeforePaint(Canvas C, float X, float Y)
{
  	C.Font = Root.Fonts[Font];
    if (C.Font == None)    
    {
//        log("Problem here, no Font select, use SetFont");
        C.Font = Root.Fonts[F_SmallTitle];
    }
}

function SetFont(int NewFont)
{
	Font = NewFont;
}

function SetTextColor(color NewColor)
{
	TextColor = NewColor;
}


function Register(UWindowDialogClientWindow	W)
{
	NotifyWindow = W;
	Notify(DE_Created);
}

function Notify(byte E)
{
	if(NotifyWindow != None)
	{
		NotifyWindow.Notify(Self, E);
	}
}

function bool ExternalDragOver(UWindowDialogControl ExternalControl, float X, float Y)
{
	return False;
}

function UWindowDialogControl CheckExternalDrag(float X, float Y)
{
	local float RootX, RootY;
	local float ExtX, ExtY;
	local UWindowWindow W;
	local UWindowDialogControl C;

	WindowToGlobal(X, Y, RootX, RootY);
	W = Root.FindWindowUnder(RootX, RootY);
	C = UWindowDialogControl(W);

	if(W != Self && C != None && C.bAcceptExternalDragDrop)
	{
		W.GlobalToWindow(RootX, RootY, ExtX, ExtY);
		if(C.ExternalDragOver(Self, ExtX, ExtY))
			return C;
	}

	return None;
}

function KeyDown(int Key, float X, float Y)
{
	local PlayerController P;
	local UWindowDialogControl N;

	P = Root.GetPlayerOwner();

	switch (Key)
	{
	case P.Player.Console.EInputKey.IK_Tab:
		
		if(TabNext != None)
		{
			N = TabNext;

			while(N != Self && !N.bWindowVisible)
				N = N.TabNext;

			N.ActivateWindow(0, False);
		}
		break;
	default:
		Super.KeyDown(Key, X, Y);
		break;
	}

}

function MouseMove(float X, float Y)
{
	Super.MouseMove(X, Y);
	Notify(DE_MouseMove);
}

function MouseEnter()
{
	Super.MouseEnter();
	Notify(DE_MouseEnter);
}

function MouseLeave()
{
	Super.MouseLeave();
	Notify(DE_MouseLeave);
}

defaultproperties
{
     bNoKeyboard=True
}
