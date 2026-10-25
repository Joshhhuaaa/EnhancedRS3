//=============================================================================
//  R6WindowListRestKit.uc : The list for restriction kit. This list is for the same type of button. Same
//							 width, same height, etc.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/18 * Created by Yannick Joly
//=============================================================================

class R6WindowListRestKit extends UWindowListControl;

var R6WindowVScrollbar	        m_VertSB;
var class<R6WindowVScrollBar>	m_SBClass;

var FLOAT				        m_fItemHeight;       // the size of each item
var FLOAT                       m_fSpaceBetItem;     // the space in between item
var FLOAT						m_fXItemOffset;		 // the item X offset pos
var FLOAT						m_fYOffset;			 // the first item start in m_fYOffset pos

function Created()
{
	Super.Created();
	m_VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, WinWidth-LookAndFeel.Size_ScrollbarWidth, 0, LookAndFeel.Size_ScrollbarWidth, WinHeight));
	m_VertSB.SetHideWhenDisable(true);
}

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	local UWindowList CurItem;
	local R6WindowLookAndFeel LAF;
	local FLOAT fItemHeight, fListHeight,fdrawWidth, y;
	local INT i;

	LAF = R6WindowLookAndFeel(LookAndFeel);
	CurItem = Items.Next; // Get first item

	if (CurItem == None)
		return; // no item to display

	fItemHeight = GetSizeOfAnItem(); // THIS SUPPOSE THAT ALL YOUR ITEM HAVE THE SAME HEIGHT IN THE LIST
	fListHeight = WinHeight - (2*LAF.m_SBHBorder.H) - m_fYOffset;

	// check the width of the list box
    fdrawWidth = WinWidth - (2 * m_fXItemOffset);

    if(m_VertSB != None)
    {
		m_VertSB.SetRange(0, Items.CountShown(), INT(fListHeight/fItemHeight)); 

		// check the width of the list box if the scroll bar is not hide
		if (!m_VertSB.isHidden())
		{
			fdrawWidth -= m_VertSB.WinWidth;
		}

        while ((CurItem != None) && (i < m_VertSB.Pos))
	    {
			// hide all the previous element in the list
			R6WindowListGeneralItem(CurItem).m_pR6WindowButtonBox.HideWindow();

			if(CurItem.ShowThisItem())
			{
				i++;
			}

		    CurItem = CurItem.Next;
	    }
    }

    for(y = LAF.m_SBHBorder.H + m_fYOffset; (y + fItemHeight <= fListHeight) && (CurItem != None); CurItem = CurItem.Next)
	{
		if(CurItem.ShowThisItem())
		{	
            DrawItem(C, CurItem, m_fXItemOffset, y, fdrawWidth, fItemHeight);
			
			y = y + fItemHeight;
		}
	}

	while (CurItem != None)
	{
		// hide all the next element in the list
		R6WindowListGeneralItem(CurItem).m_pR6WindowButtonBox.HideWindow();
		CurItem = CurItem.Next;
	}
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local R6WindowListGeneralItem pListGenItem;

	pListGenItem = R6WindowListGeneralItem(Item);

    // Set the item location
    pListGenItem.m_pR6WindowButtonBox.WinTop = WinTop + Y;

	if (pListGenItem.m_pR6WindowButtonBox.WinWidth != W)
	{
		pListGenItem.m_pR6WindowButtonBox.WinLeft = WinLeft + X;
		pListGenItem.m_pR6WindowButtonBox.WinHeight = H;

		pListGenItem.m_pR6WindowButtonBox.SetNewWidth(W);
	}

	pListGenItem.m_pR6WindowButtonBox.ShowWindow();
}

function FLOAT GetSizeOfAnItem() // UWindowList _pItem)
{
	local FLOAT fTotalItemHeigth;

	fTotalItemHeigth = m_fItemHeight + m_fSpaceBetItem;

	return fTotalItemHeigth;
}

//=======================================================================================
// MouseWheelDown: advice scroll bar for mouse wheel down
//=======================================================================================
function MouseWheelDown(FLOAT X, FLOAT Y)
{
	if (m_VertSB != None)
	{
		m_VertSB.MouseWheelDown( X, Y);
	}
}

//=======================================================================================
// MouseWheelUp: advice scroll bar for mouse wheel up
//=======================================================================================
function MouseWheelUp(FLOAT X, FLOAT Y)
{
	if (m_VertSB != None)
	{
		m_VertSB.MouseWheelUp( X, Y);
	}
}

defaultproperties
{
     m_fItemHeight=16.000000
     m_fSpaceBetItem=2.000000
     m_fYOffSet=2.000000
     m_SBClass=Class'R6Window.R6WindowVScrollbar'
     ListClass=Class'R6Window.R6WindowListGeneralItem'
}
