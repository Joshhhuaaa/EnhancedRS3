//=============================================================================
//  R6WindowListArea.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowListArea extends R6WindowTextListBox;


var class<R6WindowArea> m_AreaClass;



function BeforePaint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	local UWindowListBoxItem OverItem;
    
	m_VertSB.SetRange(0, Items.CountShown(), int(WinHeight/m_fItemHeight));

    Super.BeforePaint(C, fMouseX, fMouseY);
}


function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	local FLOAT y;
	local UWindowList CurItem;
	local INT i;
	
	CurItem = Items.Next;
    
	while((CurItem != None) && (i < m_VertSB.Pos))
	{
        ++i;
        R6WindowListAreaItem(CurItem).SetBack();
		CurItem = CurItem.Next;
	}
    
	while((CurItem != None) && (i < (m_VertSB.Pos + m_VertSB.MaxVisible)))
	{
        DrawItem(C, CurItem, 0, y, WinWidth - m_VertSB.WinWidth, m_fItemHeight);
        y = y + m_fItemHeight;
		CurItem = CurItem.Next;
	}
}

defaultproperties
{
     m_AreaClass=Class'R6Window.R6WindowArea'
     m_fItemHeight=50.000000
     ListClass=Class'R6Window.R6WindowListAreaItem'
}
