//=============================================================================
//  R6WindowButtonAndEditBox.uc : This class works like its parent class,
//                                with The addition of a text edit box.
//                                Regular Text .... Edit Box .... CheckBox
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/23 * Created by John Bennett
//=============================================================================

class R6WindowButtonAndEditBox extends R6WindowButtonBox;
                                // true if the player selected the button
var R6WindowEditControl                 m_pEditBox;
var string                              m_szEditTextHistory;

//*********************************
//      DISPLAY FUNCTIONS
//*********************************


function Paint( Canvas C, FLOAT X, FLOAT Y)
{
    Super.Paint( C, X, Y);

    // Check for changes in the Edit Box text, if the text has 
    // been modified, call the notify function

    if ( m_pEditBox != None )
    {
        if ( m_szEditTextHistory != m_pEditBox.GetValue() )
        {
            m_szEditTextHistory = m_pEditBox.GetValue();
            Notify( DE_Change );
        }

		// selected automatically the box if you edit something
		if (m_pEditBox.EditBox.m_CurrentlyEditing)
		{
			m_bSelected = (m_pEditBox.GetValue() != "");
		}
    }
 
}


//=============================================================================
// CreateEditBox: Create a box where text can be entered.  The box is 
// poistioned to the left of the chek box, so only a width needs to
// be passed
//=============================================================================

function CreateEditBox( float fWidth )
{
    local int fXpos;

    fXpos = m_fXBox - fWidth - 3;  // 5 is for the 5 pixes space between Edit box and check bix.

    m_pEditBox = R6WindowEditControl(CreateWindow(class'R6WindowEditControl', fXpos, 0, fWidth, WinHeight, self));
    m_pEditBox.SetValue( "");
//    m_pEditBox.ForceCaps(true);
}

//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetDisableButtonAndEditBox( BOOL _bDisable)
{
	m_pEditBox.EditBox.bCanEdit	= !_bDisable;
	bDisabled					= _bDisable;

	if (_bDisable)
		m_pEditBox.m_BorderColor    = Root.Colors.ButtonTextColor[1];
	else
		m_pEditBox.m_BorderColor    = Root.Colors.ButtonTextColor[0];
}

function SetEditBoxTip( string _szToolTip)
{
    if(m_pEditBox != None)
        m_pEditBox.SetEditBoxTip( _szToolTip);
}

defaultproperties
{
}
