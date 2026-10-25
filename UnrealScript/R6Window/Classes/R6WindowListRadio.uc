//=============================================================================
//  R6WindowListRadio.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowListRadio extends UWindowListControl;

var FLOAT				m_fItemHeight;
var UWindowListBoxItem	m_SelectedItem;

var string				m_szDefaultHelpText;
var R6WindowListRadio   m_DoubleClickList;	// list to send items to on double-click


function BeforePaint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	local UWindowListBoxItem OverItem;
	local string szNewHelpText;

	szNewHelpText = m_szDefaultHelpText;
	if(m_SelectedItem != None)
	{
		OverItem = GetItemAt(fMouseX, fMouseY);
		if(OverItem == m_SelectedItem && OverItem.HelpText != "")
        {
			szNewHelpText = OverItem.HelpText;
        }
	}
	
	if(szNewHelpText != HelpText)
	{
		HelpText = szNewHelpText;
		Notify(DE_HelpChanged);
	}
}

function SetHelpText(string T)
{
	Super.SetHelpText(T);
	m_szDefaultHelpText = T;
}

function Sort()
{
	Items.Sort();
}

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	local FLOAT y;
	local UWindowList CurItem;
	local INT i;
	
	CurItem = Items.Next;

	for(y=0;(y < WinHeight) && (CurItem != None);CurItem = CurItem.Next)
	{
		if(CurItem.ShowThisItem())
		{
            DrawItem(C, CurItem, 0, y, WinWidth, m_fItemHeight);
			y = y + m_fItemHeight;
		}
	}
}

function UWindowListBoxItem GetItemAt(FLOAT fMouseX, FLOAT fMouseY)
{
	local FLOAT y;
	local UWindowList CurItem;
	local INT i;
	
	if(fMouseX < 0 || fMouseX > WinWidth)
		return None;

	CurItem = Items.Next;

	for(y=0;(y < WinHeight) && (CurItem != None);CurItem = CurItem.Next)
	{
		if(CurItem.ShowThisItem())
		{
			if(fMouseY >= y && fMouseY <= y + m_fItemHeight)
				return UWindowListBoxItem(CurItem);
			y = y + m_fItemHeight;
		}
	}

	return None;
}

function MakeSelectedVisible()
{
	local UWindowList CurItem;
	local INT i;
	
	if(m_SelectedItem == None)
		return;

	for(CurItem=Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
		if(CurItem == m_SelectedItem)
        {
			break;
        }
		if(CurItem.ShowThisItem())
        {
			i++;
        }
	}
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
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
}

function SetSelected(FLOAT X, FLOAT Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	SetSelectedItem(NewSelected);
}

function LMouseDown(FLOAT X, FLOAT Y)
{
	Super.LMouseDown(X, Y);

	SetSelected(X, Y);
}

function DoubleClick(FLOAT X, FLOAT Y)
{
	Super.DoubleClick(X, Y);

	if(GetItemAt(X, Y) == m_SelectedItem)
	{
		DoubleClickItem(m_SelectedItem);
	}	
}

function ReceiveDoubleClickItem(R6WindowListRadio L, UWindowListBoxItem I)
{
	I.Remove();
	Items.AppendItem(I);
	SetSelectedItem(I);
	L.m_SelectedItem = None;
	L.Notify(DE_Change);
	Notify(DE_Change);
}

function DoubleClickItem(UWindowListBoxItem I)
{
	if(m_DoubleClickList != None && I != None)
    {
		m_DoubleClickList.ReceiveDoubleClickItem(self, I);
    }
}

defaultproperties
{
     m_fItemHeight=10.000000
}
