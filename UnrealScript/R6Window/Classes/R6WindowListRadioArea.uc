//=============================================================================
//  R6WindowListRadioArea.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowListRadioArea extends R6WindowTextListRadio;


var class<R6WindowArea> AreaClass;

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	local FLOAT y;
	local UWindowList CurItem;
	
	CurItem = Items.Next;
    
    for(CurItem = Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
        DrawItem(C, CurItem, 0, y, WinWidth, m_fItemHeight);
        y = y + m_fItemHeight;
	}
}

//**************************
function SetSelectedItem(UWindowListBoxItem NewSelected)
{
    local UWindowListBoxItem CurSelected;

    CurSelected = m_SelectedItem;

    // Update the selected button
    if(m_SelectedItem != NONE)
    {
        R6WindowListAreaItem(m_SelectedItem).m_Area.m_bSelected = false;
    }
    // start Super.SetSelectedItem( NewSelected);
	if(NewSelected != None && m_SelectedItem != NewSelected)
	{
		if(m_SelectedItem != None)
        {
			m_SelectedItem.bSelected = False;
        }

		m_SelectedItem = NewSelected;

		if(m_SelectedItem != None)
        {
			m_SelectedItem.bSelected = True;
        }
		
		Notify(DE_Click);
	}

    // end
    if(m_SelectedItem != NONE)
    {
        R6WindowListAreaItem(m_SelectedItem).m_Area.m_bSelected = true;
    }
}

function SetDefaultButton(UWindowList Item)
{
    if(Item != NONE)
    {
        if(m_SelectedItem == NONE)
        {
            SetSelectedItem(UWindowListBoxItem(Item));
        }
    }
}

defaultproperties
{
     m_fItemHeight=50.000000
     ListClass=Class'R6Window.R6WindowListAreaItem'
}
