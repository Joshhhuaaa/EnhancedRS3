//=============================================================================
//  R6WindowHScrollBar.uc : Horizontal scrollbar with possibility to add a text (for tooltip option)
//							This class is different than vertical scrollbar
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/27 * Created by Yannick Joly
//=============================================================================

class R6WindowHScrollBar extends UWindowDialogControl;

var R6WindowTextLabelExt				m_pSBText;

var UWindowHScrollBar					m_pScrollBar;

//================================================================
//	Create the horizontal scroll bar 
//================================================================
function CreateSB( INT _iScrollBarID, float _fX, float _fY, float _fWidth, float _fHeight, UWindowDialogClientWindow _DialogClientW)
{
	m_pScrollBar = UWindowHScrollBar( CreateWindow(class'UWindowHScrollBar', WinWidth - _fWidth, _fY, _fWidth, LookAndFeel.Size_ScrollbarWidth, self));
	m_pScrollBar.SetRange( 0, 10, 2);
	m_pScrollBar.Register( _DialogClientW);
	m_pScrollBar.m_iScrollBarID = _iScrollBarID;
}

//================================================================
//	SetScrollBarValue: Set the scroll bar value 
//================================================================
function SetScrollBarValue( FLOAT _fNewValue)
{
	local FLOAT fScrollValue;

	if (m_pScrollBar != None)
	{
		fScrollValue =  m_pScrollBar.MaxPos / ( m_pScrollBar.MaxPos + m_pScrollBar.MaxVisible);
		fScrollValue *= _fNewValue;

		m_pScrollBar.Pos = fScrollValue;
		m_pScrollBar.CheckRange();
	}
}

//================================================================
//	SetScrollBarRange: Set the scroll bar range
//================================================================
function SetScrollBarRange( FLOAT _fMin, FLOAT _fMax, FLOAT _fStep)
{
	if (m_pScrollBar != None)
	{
		m_pScrollBar.SetRange(_fMin, _fMax, _fStep);
	}
}

//================================================================
//	GetScrollBarValue: Get the scroll bar value
//================================================================
function FLOAT GetScrollBarValue()
{
	local FLOAT fRealValue;

	if (m_pScrollBar != None)
	{
		fRealValue =  ( m_pScrollBar.MaxPos + m_pScrollBar.MaxVisible) / m_pScrollBar.MaxPos;
		fRealValue *= m_pScrollBar.Pos;

		return fRealValue;
	}

	return 0;
}

//================================================================
//	Create an associate text to the scroll bar 
//================================================================
function CreateSBTextLabel( string _szText, string _szToolTip)
{
	if (m_pScrollBar != None)
	{
	    // create the text part
	    m_pSBText = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, WinWidth - m_pScrollBar.WinWidth, WinHeight, self));
	    m_pSBText.bAlwaysBehind = true;
	    m_pSBText.SetNoBorder(); 

	    // add text label
	    m_pSBText.m_Font = Root.Fonts[F_SmallTitle];  
	    m_pSBText.m_vTextColor = Root.Colors.White;

		m_pSBText.AddTextLabel( _szText, 0, 0, 150, TA_Left, false);
	}	

	ToolTipString = _szToolTip;
}

function MouseEnter()
{
	Super.MouseEnter();
	//we have to change the color of the text
	if (m_pSBText != None)
	{
		m_pSBText.ChangeColorLabel( Root.Colors.ButtonTextColor[2], 0);	
	}
}

function MouseLeave()
{
	Super.MouseLeave();
	//we have to change the color of the text
	if (m_pSBText != None)
	{
		m_pSBText.ChangeColorLabel( Root.Colors.White, 0);	
	}
}

defaultproperties
{
}
