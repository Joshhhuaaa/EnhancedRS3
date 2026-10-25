//=============================================================================
//  R6WindowListRadioButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowListRadioButton extends R6WindowTextListRadio;

var FLOAT   m_fItemWidth;
var bool    m_bCanBeUnselected;// item can be unselected
var FLOAT   m_fItemVPadding;



function Created()
{
    Super.Created();
}

//When the window is resized.
function ChangeItemsSize(FLOAT iNewSize);

function Paint(Canvas C, FLOAT MouseX, FLOAT MouseY)
{
	local FLOAT x;
    local FLOAT y;
	local UWindowList CurItem;
	
    if(m_fItemWidth==0)
        m_fItemWidth = WinWidth;

    x = (WinWidth-m_fItemWidth)/2;
    for(CurItem = Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
        DrawItem(C, CurItem, x, y, m_fItemWidth, m_fItemHeight);
        y += m_fItemHeight + m_fItemVPadding;
        if(y >= WinHeight)
        {
            y = 0;
            x += WinWidth;
        }
	}
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local R6WindowListButtonItem pListButtonItem;
		
	pListButtonItem = R6WindowListButtonItem(Item);

    // Set the item location
    if(pListButtonItem.m_Button!=NONE)
    {
        pListButtonItem.m_Button.WinLeft = X;
        pListButtonItem.m_Button.WinTop = Y;
        pListButtonItem.m_Button.WinHeight = H;
    }
}

function UWindowListBoxItem GetItemAt(FLOAT fMouseX, FLOAT fMouseY)
{
	local FLOAT x;
    local FLOAT y;
	local UWindowList CurItem;
	local INT i;
    local INT j;
	
	if(fMouseX < 0 || fMouseX > WinWidth)
		return None;

    if(Items == NONE)
        return None;

	CurItem = Items.Next;

	for(x=0;(x < WinWidth ) && (CurItem != None);x += WinWidth)
    {
        if(fMouseX >= x && fMouseX <= x+WinWidth)
        {
            // search the item in the column
	        for(y=0;(y < WinHeight) && (CurItem != None);y += m_fItemHeight + m_fItemVPadding)
	        {
		        if(CurItem.ShowThisItem())
		        {
			        if(fMouseY >= y && fMouseY <= y + m_fItemHeight)
                    {
				        return UWindowListBoxItem(CurItem);
                    }
		        }
                if(CurItem != None)
                {
                    CurItem = CurItem.Next;
                }
	        }
        }
        else
        {
            // Go to the next column
            for(j=0;(CurItem != None) && (j<((WinHeight/(m_fItemHeight+m_fItemVPadding))));j++)
            {
                if(CurItem != None)
                {
                    CurItem = CurItem.Next;
                }
            }
        }
    }

	return None;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
    local UWindowListBoxItem CurSelected;

    CurSelected = m_SelectedItem;

    // Update the selected button
    if(m_SelectedItem != NONE)
    {
        R6WindowListButtonItem(m_SelectedItem).m_Button.m_bSelected = false;
    }

    Super.SetSelectedItem( NewSelected);

    if(m_bCanBeUnselected)
    {
        if(CurSelected == m_SelectedItem)
        {
            m_SelectedItem.bSelected = false;
            m_SelectedItem = None;
        }
    }
    if(m_SelectedItem != NONE)
    {
        R6WindowListButtonItem(m_SelectedItem).m_Button.m_bSelected = true;
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

function UWindowListBoxItem GetElement(int ButtonID)
{
	//This allow to retreive a button with is special ID
	local UWindowList CurItem;
	local bool		found;
	local int		i;

	if(ButtonID <0) return NONE;

	 if(Items == NONE)
        return None;

	CurItem = Items.Next;

	for(i= 0; (i < Items.Count()) && (found == false);i++)
	{
		if(R6WindowListButtonItem(CurItem).m_Button.m_iButtonID == ButtonID)	
			found = true;		
		else
			CurItem = CurItem.Next;
	}

	if(found)
		return UWindowListBoxItem(CurItem);
	else
		return NONE;
}

defaultproperties
{
     m_fItemHeight=50.000000
     ListClass=Class'R6Window.R6WindowListButtonItem'
}
