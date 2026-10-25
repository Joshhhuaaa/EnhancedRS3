//=============================================================================
//  R6MenuAdvFilters.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/21 * Created by Yannick Joly
//=============================================================================
class R6MenuAdvFilters extends UWindowDialogClientWindow;

var R6WindowListRestKit					m_pListGen;

function Created()
{
	m_pListGen = R6WindowListRestKit(CreateWindow( class'R6WindowListRestKit', 0, 0, WinWidth, WinHeight, self));
	m_pListGen.m_fXItemOffset = 5;
	m_pListGen.bAlwaysBehind = true;
}

function AddButtonInList( BOOL _bSelected, string _szLoc, string _szTip, INT _iButtonID)
{
	local R6WindowListGeneralItem NewItem;
	local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight;
	local Font  ButtonFont;
	local INT	i;

	//create buttons
	fXOffset = 5;
	fYOffset = 7;
	fWidth = WinWidth - (2 * fXOffset); // - 15;
	fHeight = 15;
	ButtonFont = Root.Fonts[F_SmallTitle];

	NewItem = R6WindowListGeneralItem(m_pListGen.GetItemAtIndex( m_pListGen.Items.CountShown()));
	NewItem.m_pR6WindowButtonBox = R6WindowButtonBox( CreateControl( class'R6WindowButtonBox', fXOffset, 0, fWidth, fHeight, self)); 
	NewItem.m_pR6WindowButtonBox.m_TextFont		= ButtonFont;
	NewItem.m_pR6WindowButtonBox.m_vTextColor	= Root.Colors.White;
	NewItem.m_pR6WindowButtonBox.m_vBorder		= Root.Colors.White;
	NewItem.m_pR6WindowButtonBox.m_bSelected	= _bSelected;
	NewItem.m_pR6WindowButtonBox.m_szMiscText	= "";
	NewItem.m_pR6WindowButtonBox.m_AdviceWindow = self;
	NewItem.m_pR6WindowButtonBox.CreateTextAndBox( _szLoc, _szTip, 0, _iButtonID);
}

function Notify(UWindowDialogControl C, byte E)
{
	if (C.IsA('R6WindowButtonBox'))
	{
		if (E == DE_Click)
		{
			if (OwnerWindow != None)
			{
				R6MenuMPMenuTab(OwnerWindow).Notify( C, E);
			}
		}
	}
}

//=======================================================================================
// MouseWheelDown: advice scroll bar for mouse wheel down
//=======================================================================================
function MouseWheelDown(FLOAT X, FLOAT Y)
{
	if (m_pListGen != None)
	{
		m_pListGen.MouseWheelDown( X, Y);
	}
}

//=======================================================================================
// MouseWheelUp: advice scroll bar for mouse wheel up
//=======================================================================================
function MouseWheelUp(FLOAT X, FLOAT Y)
{
	if (m_pListGen != None)
	{
		m_pListGen.MouseWheelUp( X, Y);
	}
}

defaultproperties
{
}
