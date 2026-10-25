//=============================================================================
// UWindowSBLeftButton - Scrollbar left button
//=============================================================================
class UWindowSBLeftButton extends UWindowButton;

var float NextClickTime;
var bool  m_bHideSBWhenDisable;

function Created()
{
	bNoKeyboard = True;
	Super.Created();
    LookAndFeel.SB_SetupLeftButton(Self);
}

/*
function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.SB_SetupLeftButton(Self);
}
*/


function Paint(Canvas C, float X, float Y) 
{
    if ( bDisabled && m_bHideSBWhenDisable  )
            return;

    Super.Paint(C, X, Y);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);
	if(bDisabled)
		return;
	UWindowHScrollBar(ParentWindow).Scroll(-UWindowHScrollBar(ParentWindow).ScrollAmount);
	NextClickTime = GetTime() + 0.5;
}

function Tick(float Delta)
{
	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < GetTime()))
	{
		UWindowHScrollBar(ParentWindow).Scroll(-UWindowHScrollBar(ParentWindow).ScrollAmount);
		NextClickTime = GetTime() + 0.1;
	}

	if(!bMouseDown)
	{
		NextClickTime = 0;
	}
}

function MouseLeave()
{
	Super.MouseLeave();

	UWindowHScrollBar(OwnerWindow).MouseLeave();
}

function MouseEnter()
{
	Super.MouseEnter();

	UWindowHScrollBar(OwnerWindow).MouseEnter();
}

defaultproperties
{
}
