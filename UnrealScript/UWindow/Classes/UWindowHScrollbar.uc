//=============================================================================
// UWindowHScrollBar - A horizontal scrollbar
//=============================================================================
class UWindowHScrollBar extends UWindowDialogControl;

var UWindowSBLeftButton		LeftButton;
var UWindowSBRightButton	RightButton;
var bool					bDisabled;
var float					MinPos;
var float					MaxPos;
var float					MaxVisible;
var float					Pos;				// offset to WinTop
var float					ThumbStart, ThumbWidth;
var float					NextClickTime;
var float					DragX;
var bool					bDragging;
var float					ScrollAmount;
var bool                    m_bHideSBWhenDisable;


var COLOR                   m_SelectedColor;
var COLOR                   m_NormalColor;

var INT						m_iScrollBarID;				// the ID of the scroll bar

function Show(float P)
{
	if(P < 0) return;
	if(P > MaxPos + MaxVisible) return;

	while(P < Pos) 
		if(!Scroll(-1))
			break;
	while(P > Pos) //- Pos > MaxVisible - 1)  // some values are missed with this old code!!!
		if(!Scroll(1))
			break;
}

function bool Scroll(float Delta) 
{
	local float OldPos;
	
	OldPos = Pos;
	Pos = Pos + Delta;
	CheckRange();

    Notify(DE_Change);
    
	return Pos == OldPos + Delta;
}

function SetRange(float NewMinPos, float NewMaxPos, float NewMaxVisible, optional float NewScrollAmount)
{
	if(NewScrollAmount == 0)
		NewScrollAmount = 1;

	ScrollAmount = NewScrollAmount;
	MinPos = NewMinPos;
	MaxPos = NewMaxPos - NewMaxVisible;
	MaxVisible = NewMaxVisible;

	CheckRange();
    Notify(DE_Change);
}

function CheckRange() 
{
	if(Pos < MinPos)
	{
		Pos = MinPos;
	}
	else
	{
		if(Pos > MaxPos) Pos = MaxPos;
	}

	bDisabled = (MaxPos <= MinPos);
	LeftButton.bDisabled = bDisabled;
	RightButton.bDisabled = bDisabled;

	if(bDisabled)
	{
		Pos = 0;
	}
	else
	{
		// change some parameters here to flush reference to LookAndFeel (we have to take care of the size of the scroll bar)
                                                    // +2 is for visual effect small padding for the scroller
		ThumbStart = ((Pos - MinPos) * (WinWidth - (2*LookAndFeel.Size_ScrollbarButtonHeight+2))) / (MaxPos + MaxVisible - MinPos);
		ThumbWidth = (MaxVisible * (WinWidth - (2*LookAndFeel.Size_ScrollbarButtonHeight+2))) / (MaxPos + MaxVisible - MinPos);

		if(ThumbWidth < LookAndFeel.Size_MinScrollbarHeight) 
			ThumbWidth = LookAndFeel.Size_MinScrollbarHeight;
		
		if(ThumbWidth + ThumbStart > WinWidth - LookAndFeel.Size_ScrollbarButtonHeight -1)  // -1 is for visual effect small padding for the scroller
		{
			ThumbStart = WinWidth - LookAndFeel.Size_ScrollbarButtonHeight -1 - ThumbWidth; // -1 is for visual effect small padding for the scroller
		}
        else
		    ThumbStart = ThumbStart + LookAndFeel.Size_ScrollbarButtonHeight +1 ; // +1 is for visual effect small padding for the scroller
	}
}

function Created() 
{
	m_SelectedColor = Root.Colors.ButtonTextColor[2];
    m_NormalColor   = Root.Colors.White;


	LeftButton  = UWindowSBLeftButton(CreateWindow(class'UWindowSBLeftButton', 0, 0, LookAndFeel.Size_ScrollbarButtonHeight, LookAndFeel.Size_ScrollbarWidth));
	RightButton = UWindowSBRightButton(CreateWindow(class'UWindowSBRightButton', WinWidth - LookAndFeel.Size_ScrollbarButtonHeight, 0, LookAndFeel.Size_ScrollbarButtonHeight,  LookAndFeel.Size_ScrollbarWidth));
}


function Register(UWindowDialogClientWindow	W)
{    
	Super.Register(W);
    LeftButton.Register(W);
    RightButton.Register(W);   
}

function BeforePaint(Canvas C, float X, float Y)
{
	CheckRange();
}


function Paint(Canvas C, float X, float Y) 
{

    
    if ( bDisabled && m_bHideSBWhenDisable  )
            return;

	if ( MouseIsOver() || (LeftButton.MouseIsOver()) || (RightButton.MouseIsOver()) )
	{		
        SetBorderColor(m_SelectedColor);	
		//advice parent that the mouse is over the scroll bar
		AdviceParent(true);
	}
	else
	{
		if (m_BorderColor != m_NormalColor)
		{
			SetBorderColor(m_NormalColor);	
			AdviceParent(false);			
		}
	}

	LookAndFeel.SB_HDraw(Self, C);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	if(bDisabled) return;

	if(X < ThumbStart)
	{
		Scroll(-(MaxVisible-1));
		NextClickTime = GetTime() + 0.5;
		return;
	}
	if(X > ThumbStart + ThumbWidth)
	{
		Scroll(MaxVisible-1);
		NextClickTime = GetTime() + 0.5;
		return;
	}

	if((X >= ThumbStart) && (X <= ThumbStart + ThumbWidth))
	{
		DragX = X - ThumbStart;
		bDragging = True;
		Root.CaptureMouse();
		return;
	}
}

function Tick(float Delta) 
{
	local bool bLeft, bRight;
	local float X, Y;

	if(bDragging) return;

	bLeft = False;
	bRight = False;

	if(bMouseDown)
	{
		GetMouseXY(X, Y);
		bLeft = (X < ThumbStart);
		bRight = (X > ThumbStart + ThumbWidth);
	}
	
	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < GetTime())  && bLeft)
	{
		Scroll(-(MaxVisible-1));
		NextClickTime = GetTime() + 0.1;
	}

	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < GetTime())  && bRight)
	{
		Scroll(MaxVisible-1);
		NextClickTime = GetTime() + 0.1;
	}

	if(!bMouseDown || (!bLeft && !bRight))
	{
		NextClickTime = 0;
	}
}

function MouseMove(float X, float Y)
{
	if(bDragging && bMouseDown && !bDisabled)
	{
		while(X < (ThumbStart+DragX) && Pos > MinPos)
		{
			Scroll(-1);
		}

		while(X > (ThumbStart+DragX) && Pos < MaxPos)
		{
			Scroll(1);
		}	
	}
	else
	{
		bDragging = False;
	}
}

function MouseEnter()
{
	Super.MouseEnter();
	AdviceParent(true);
}

function MouseLeave()
{
	Super.MouseLeave();
	AdviceParent(false);
}

function AdviceParent( bool _bMouseEnter)
{
	if (_bMouseEnter)
		OwnerWindow.MouseEnter();
	else
		OwnerWindow.MouseLeave();
}

function SetHideWhenDisable( BOOL _bHideWhenDisable)
{
    m_bHideSBWhenDisable = _bHideWhenDisable;
    LeftButton.m_bHideSBWhenDisable = _bHideWhenDisable;
    RightButton.m_bHideSBWhenDisable = _bHideWhenDisable;
}

function SetBorderColor(Color c)
{
    m_BorderColor = c;
    LeftButton.m_BorderColor = c;
    RightButton.m_BorderColor = c;
}

defaultproperties
{
}
