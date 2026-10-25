//=============================================================================
//  R6WindowEditControl.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowEditControl extends UWindowEditControl;

var R6WindowTextLabel				m_pTextLabel;

var bool							m_bUseSpecialPaint;	// use this special paint
var BOOL							m_bDisabled;		// true, the control is disable

function Created()
{
	if(!bNoKeyboard)
    {
		SetAcceptsFocus();
    }

	EditBox = UWindowEditBox(CreateWindow(class'R6WindowEditBox', 0, 0, WinWidth, WinHeight)); 
	EditBox.NotifyOwner = self;
	EditBoxWidth = WinWidth;

    SetEditTextColor(Root.Colors.BlueLight);
}

//=======================================================================================================
//=======================================================================================================
// DISPLAY
function BeforePaint(Canvas C, float X, float Y)
{
	if (!m_bUseSpecialPaint)
	{
		Super.BeforePaint(C, X, Y);
	}
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	if (m_bUseSpecialPaint)
	{
		if (m_bDisabled)
			return;

        if(m_pTextLabel != None)
        {
            // verify if the mouse is over the edit box
		    if (EditBox.m_bMouseOn)
		    {
			    m_pTextLabel.TextColor = Root.Colors.ButtonTextColor[2];
			    ParentWindow.MouseEnter();
		    }
		    else
		    {
			    if (m_pTextLabel.TextColor != Root.Colors.White )
			    {
				    m_pTextLabel.TextColor = Root.Colors.White;
				    ParentWindow.MouseLeave();
			    }
		    }
        }		
	}
	else
	{
		Super.Paint(C, X, Y);
	}
}


//=======================================================================================================
//=======================================================================================================

function ForceCaps( bool choice)
{

	if(R6WindowEditBox(EditBox) != None)
		R6WindowEditBox(EditBox).bCaps = choice;		
}

function ModifyEditBoxW( FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
	EditBox.WinLeft   = _fX;
	EditBox.WinTop    = _fY;
	EditBox.WinWidth  = _fWidth;
	EditBox.WinHeight = _fHeight;
	EditBox.Font	  = F_SmallTitle;
	
	EditBoxWidth      = EditBox.WinWidth;
	m_bUseSpecialPaint= true;
}

function CreateTextLabel( string _szTitle, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
	m_pTextLabel = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', _fX, _fY, _fWidth, _fHeight, self));
	m_pTextLabel.SetProperties( _szTitle, TA_Left, Root.Fonts[F_SmallTitle], Root.Colors.White, false);
}

//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetEditControlStatus( BOOL _bDisable)
{
	m_bDisabled = _bDisable;

	EditBox.bCanEdit	= !_bDisable;

	if (_bDisable)
		m_pTextLabel.TextColor = Root.Colors.ButtonTextColor[1]; // gray
	else
		m_pTextLabel.TextColor = Root.Colors.ButtonTextColor[0]; // white
}

//====================================================================
// SetEditBoxTip: set the tooltipstring, this string is return to the parent window when the mouse is over the edit box
//====================================================================
function SetEditBoxTip( string _szToolTip)
{
	EditBox.ToolTipString = _szToolTip;
}

defaultproperties
{
     m_bUseSpecialPaint=True
}
