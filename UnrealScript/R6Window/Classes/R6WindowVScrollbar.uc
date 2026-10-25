//=============================================================================
//  R6WindowVScrollBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowVScrollBar extends UWindowVScrollBar;

var class<UWindowSBUpButton>    m_UpButtonClass;
var class<UWindowSBDownButton>  m_DownButtonClass;

function SetRange(float NewMinPos, float NewMaxPos, float NewMaxVisible, optional float NewScrollAmount)
{
	if(NewScrollAmount == 0)
		NewScrollAmount = 1;

	ScrollAmount = NewScrollAmount;
	MaxPos = NewMaxPos - NewMaxVisible;
	MaxVisible = NewMaxVisible;
	MinPos = NewMinPos;

	CheckRange();
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
	DownButton.bDisabled = bDisabled;
	UpButton.bDisabled = bDisabled;
	
//	log(bDisabled);

	if(bDisabled)
	{
		Pos = 0;
		ThumbStart  = 0; // this is not display the scroller
		ThumbHeight = 0; // this is not display the scroller
	}
	else
	{                                                                   // +2 is for visual effect small padding for the scroller
		ThumbStart = ((Pos - MinPos) * (WinHeight - (2*LookAndFeel.Size_ScrollbarButtonHeight+2))) / (MaxPos + MaxVisible - MinPos);
		ThumbHeight = (MaxVisible * (WinHeight - (2*LookAndFeel.Size_ScrollbarButtonHeight+2))) / (MaxPos + MaxVisible - MinPos);
	

		if(ThumbHeight < LookAndFeel.Size_MinScrollbarHeight) 
			ThumbHeight = LookAndFeel.Size_MinScrollbarHeight;
		
		if(ThumbHeight + ThumbStart > WinHeight - LookAndFeel.Size_ScrollbarButtonHeight -1) // -1 is for visual effect small padding for the scroller
		{
			ThumbStart = WinHeight - LookAndFeel.Size_ScrollbarButtonHeight -1 - ThumbHeight;
		}
        else
		    ThumbStart = ThumbStart + LookAndFeel.Size_ScrollbarButtonHeight +1; // +1 is for visual effect small padding for the scroller
	}
}

defaultproperties
{
}
