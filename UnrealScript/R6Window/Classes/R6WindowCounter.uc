//=============================================================================
//  R6WindowCounter.uc : This class permit to create a window with a - and + button
//                       and display the counter in the middle
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//  16/04/2002 Created by Yannick Joly
//=============================================================================
class R6WindowCounter extends UWindowDialogClientWindow;

enum eAssociateButCase
{
	EABC_Down,
	EABC_Up
};

const C_fBUTTONS_CHECK_TIME		= 1;

var R6WindowCounter				m_pAssociateButton;	// the associate button, perform and action with this button
var INT							m_iAssociateButCase;

var R6WindowButton              m_pSubButton;       // the substract button
var R6WindowButton              m_pPlusButton;      // the adding button

var R6WindowTextLabel           m_pTextInfo;        // display the info text
var R6WindowTextLabel           m_pNbOfCounter;     // display the number of the counter

var FLOAT						m_fTimeCheckBut;	// timer
var FLOAT						m_fTimeToWait;		// the time to wait, by default C_fBUTTONS_CHECK_TIME

var INT                         m_iStepCounter;     // the -/+ step that each time you press the button
var INT                         m_iCounter;         // the Counter
var INT                         m_iMinCounter;      // The minimum for the counter
var INT                         m_iMaxCounter;      // The maximum for the counter
var INT                         m_iButtonID;

var bool                        m_bAdviceParent;    // advice the parent window (for tool tip effect and stuff like that)
var BOOL						m_bNotAcceptClick;	// this is a fake button.
var BOOL						m_bUnlimitedCounterOnZero; // this counter is unlimited when the value is 0
var BOOL						m_bButPressed;		// the +/- buttons are pressed

//===============================================================
// created the two box with the text window in middle, if you want to
// change some parameters (like the text window width), you can derivate or 
// create a new fct with member variable....
//===============================================================

//===============================================================
// Create the text label window
//===============================================================
function CreateLabelText( FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    m_pTextInfo = R6WindowTextLabel(CreateWindow( class'R6WindowTextLabel', _fX, _fY, _fWidth, _fHeight, self));
    m_pTextInfo.bAlwaysBehind = true;
}


//===============================================================
// Set the text label param
//===============================================================
function SetLabelText( string _szText, Font _TextFont, Color _vTextColor)
{
    if (m_pTextInfo != None)
    {
        m_pTextInfo.Text                = _szText;
        m_pTextInfo.m_Font              = _TextFont;
        m_pTextInfo.TextColor           = _vTextColor;
        m_pTextInfo.m_bDrawBorders      = false;
        m_pTextInfo.Align               = TA_Left;
        m_pTextInfo.m_BGTexture         = None;
    }
}


//===============================================================
// Create the two buttons (- and +) plus the text label in the center
//===============================================================
function CreateButtons( FLOAT _fX, FLOAT _fY, FLOAT _fSizeOfCounter)
{
    local Region        RDisableRegion, 
                        RNormalRegion;
    local FLOAT         fHeight,
                        fButtonWidth,
                        fButtonHeight;

    // init
	RNormalRegion.X		= 49;    // sub region
	RNormalRegion.Y		= 24;
	RNormalRegion.W		= 10;
	RNormalRegion.H		= 10;
	RDisableRegion.X	= 49;    // sub region
	RDisableRegion.Y	= 44;
	RDisableRegion.W	= 10;
	RDisableRegion.H	= 10;

    fButtonWidth        = R6WindowLookAndFeel(LookAndFeel).m_RButtonBackGround.W;
    fButtonHeight       = R6WindowLookAndFeel(LookAndFeel).m_RButtonBackGround.H;

    // find the center position depending the size of the window 
    // to place the buttons and the text in the middle
    fHeight = (WinHeight - fButtonHeight) / 2;   
    fHeight = FLOAT(INT(fHeight+0.5));

    // place the sub button always at 0 in X
	m_pSubButton = R6WindowButton(CreateControl( class'R6WindowButton', _fX, _fY, fButtonWidth, fButtonHeight));
    m_pSubButton.SetButtonBorderColor(Root.Colors.White);
    m_pSubButton.m_vButtonColor     = Root.Colors.White;
	m_pSubButton.m_bDrawBorders     = true;
	m_pSubButton.bUseRegion         = true;
//	m_pSubButton.DisabledTexture	= R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
//	m_pSubButton.DisabledRegion     = disabledReg;
	m_pSubButton.DownTexture		= R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.DownRegion         = RDisableRegion;
	m_pSubButton.OverTexture		= R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.OverRegion         = RNormalRegion;
	m_pSubButton.UpTexture		    = R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.UpRegion           = RNormalRegion;
	m_pSubButton.ImageX             = 2;
	m_pSubButton.ImageY             = 2;
	m_pSubButton.m_iDrawStyle       = ERenderStyle.STY_Alpha;
    m_pSubButton.m_eButtonType      = eCounterButton;

    // define the center counter 2 digits
    m_pNbOfCounter = R6WindowTextLabel(CreateWindow( class'R6WindowTextLabel', _fX + fButtonWidth, _fY, _fSizeOfCounter - (2 * fButtonWidth), fButtonHeight));
    m_pNbOfCounter.m_bDrawBorders      = false;
    m_pNbOfCounter.m_BGTextureRegion.X = 113;
    m_pNbOfCounter.m_BGTextureRegion.Y = 47;
    m_pNbOfCounter.m_BGTextureRegion.W = 2;
    m_pNbOfCounter.m_BGTextureRegion.H = 13;
    m_pNbOfCounter.m_fHBorderHeight    = 0;
    m_pNbOfCounter.Text                = string(m_iCounter);
	m_pNbOfCounter.Align               = TA_Center;
	m_pNbOfCounter.m_Font              = Root.Fonts[F_SmallTitle]; 
	m_pNbOfCounter.TextColor           = Root.Colors.BlueLight;	


    // place the plus button always at the end of the window in X
    RNormalRegion.X  = 59;  // plus region
    RDisableRegion.X = 59;  // plus region

	m_pPlusButton = R6WindowButton(CreateControl( class'R6WindowButton', _fX - fButtonWidth + _fSizeOfCounter, _fY, fButtonWidth, fButtonHeight));
    m_pPlusButton.SetButtonBorderColor(Root.Colors.White);
    m_pPlusButton.m_vButtonColor    = Root.Colors.White;
	m_pPlusButton.m_bDrawBorders    = true;
	m_pPlusButton.bUseRegion        = true;
//	m_pPlusButton.DisabledTexture	= R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
//	m_pPlusButton.DisabledRegion    = disabledReg;
	m_pPlusButton.DownTexture		= R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.DownRegion        = RDisableRegion;
	m_pPlusButton.OverTexture		= R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.OverRegion        = RNormalRegion;
	m_pPlusButton.UpTexture			= R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.UpRegion          = RNormalRegion;
	m_pPlusButton.ImageX            = 2;
	m_pPlusButton.ImageY            = 2;
	m_pPlusButton.m_iDrawStyle      = ERenderStyle.STY_Alpha;
    m_pPlusButton.m_eButtonType     = eCounterButton;
}


//===============================================================
// Set button tool tip string, the same tip for the two button!
//===============================================================
function SetButtonToolTip( string _szLeftToolTip, string _szRightToolTip)
{
    if (m_pSubButton != None)
        m_pSubButton.ToolTipString = _szLeftToolTip;

    if (m_pPlusButton != None)
        m_pPlusButton.ToolTipString = _szRightToolTip;
}


//===============================================================
// set the counter values, min max and default
//===============================================================
function SetDefaultValues( INT _iMin, INT _iMax, INT _iDefaultValue)
{
    m_iMinCounter = _iMin;
    m_iMaxCounter = _iMax;

	if (CheckValueForUnlimitedCounter( _iDefaultValue, true))
		return;

	m_iCounter = CheckValue( _iDefaultValue);
    m_pNbOfCounter.Text = string(m_iCounter); // because set counter is after created, update text here
}

function SetCounterValue( INT _iNewValue)
{
	if (CheckValueForUnlimitedCounter( _iNewValue, false))
		return;

	m_iCounter = CheckValue( _iNewValue);
	m_pNbOfCounter.SetNewText( string(m_iCounter), true); 
}

function BOOL CheckValueForUnlimitedCounter( INT _iValue, BOOL _bDefaultValue)
{
	if (m_bUnlimitedCounterOnZero)
	{
		if ((_iValue < m_iMinCounter) && (_iValue == 0))
		{
			m_iCounter = 0;

			if (_bDefaultValue)
			{
				m_pNbOfCounter.Text = "--";
			}
			else
			{
				m_pNbOfCounter.SetNewText( "--", true);
			}

			return true;
		}
	}

	return false;
}

function INT CheckValue( INT _iValue)
{
	if (_iValue > m_iMaxCounter)
		return m_iMaxCounter;
	else if (_iValue < m_iMinCounter)
		return m_iMinCounter;
	else
		return _iValue;
}

function BOOL CheckAddButton()
{
	if (m_bUnlimitedCounterOnZero)
	{
		if (m_iCounter == 0)
		{
			m_iCounter = m_iMinCounter;
			m_pNbOfCounter.SetNewText( string(m_iCounter), true);			
			return true;
		}
	}

	if(m_iCounter + m_iStepCounter <= m_iMaxCounter )
	{
		m_iCounter += m_iStepCounter;
        m_pNbOfCounter.SetNewText( string(m_iCounter), true);
		return true;
	}

	return false;
}

function BOOL CheckSubButton()
{
	local FLOAT bSubValue;

	bSubValue = m_iCounter - m_iStepCounter;

	if (m_bUnlimitedCounterOnZero)
	{
		if (bSubValue < m_iMinCounter)
		{
			m_iCounter = 0;
			m_pNbOfCounter.SetNewText( "--", true);			
			return true;
		}
	}

	if(bSubValue >= m_iMinCounter)
	{
		m_iCounter -= m_iStepCounter;
        m_pNbOfCounter.SetNewText( string(m_iCounter), true);
		return true;
	}

	return false;
}

//===============================================================
// advice parent window that you are on one of the button
//===============================================================
function SetAdviceParent( bool _bAdviceParent)
{
    m_bAdviceParent = _bAdviceParent;
}

//=============================================================
// Tick: check for mousedown on +/- buttons and simulate click on thoses buttons to +/- the counter
//=============================================================
function Tick( float deltaTime)
{
	local BOOL bButPressed;

	m_fTimeCheckBut += (deltaTime * m_fTimeCheckBut);

	if (m_fTimeCheckBut >= m_fTimeToWait)
	{
		m_fTimeCheckBut = 0.5;
		m_fTimeToWait   = C_fBUTTONS_CHECK_TIME;
			
		bButPressed   = m_bButPressed;
		m_bButPressed = false;

		m_bButPressed = IsMouseDown( m_pSubButton);
		m_bButPressed = (IsMouseDown( m_pPlusButton) || (m_bButPressed));

		if ((bButPressed) && (m_bButPressed))
		{
			m_fTimeToWait *= 0.5; // increase the speed of the -/+
		}
	}
}

//=============================================================
// IsMouseDown: Check if the +/- buttons are pressed ant the player keep the mouse cursor on it
//=============================================================
function BOOL IsMouseDown( UWindowDialogControl _pButton)
{
	if (_pButton != None)
	{
		if (_pButton.bMouseDown)
		{
			Notify( _pButton, DE_Click);
			return true;
		}
	}

	return false;
}

//===============================================================
// notify and notify parent if m_bAdviceParent is true
//===============================================================
function Notify(UWindowDialogControl C, byte E)
{
	if(E == DE_Click)
	{
		if (m_bNotAcceptClick)
			return;

		switch(C)
		{		
		case m_pPlusButton:	
			if(CheckAddButton())
			{
				if (m_pAssociateButton != None)
				{
					if (m_iAssociateButCase == eAssociateButCase.EABC_Up)
					{
						// we have to take count of the associate button, in the default case, the only one for now, decrease the
						// associate button for the same value is this one go under
						if ( m_iCounter	> m_pAssociateButton.m_iCounter)
						{
							m_pAssociateButton.m_iCounter = m_iCounter;
							m_pAssociateButton.m_pNbOfCounter.SetNewText( string(m_pAssociateButton.m_iCounter), true);
						}
					}
				}

                if (m_bAdviceParent)
                {
                    // we need to advice the parent too, this is not very good, we use the parent window
                    // (suppose that is a child of UWindowDialogClientWindow) and notify the button msg
                    // it's the responsability of the parent window to manage this new notify
//                    if ( OwnerWindow.IsA('R6MenuMPCreateGameTab'))
                    UWindowDialogClientWindow(ParentWindow).Notify( C, E);
                }
			}

			if (!m_bButPressed)
				m_fTimeCheckBut = 0.5;
			break;
		case m_pSubButton:
			if(CheckSubButton())
			{
				if (m_pAssociateButton != None)
				{
					if (m_iAssociateButCase == eAssociateButCase.EABC_Down)
					{
						// we have to take count of the associate button, in the default case, the only one for now, decrease the
						// associate button for the same value is this one go under
						if ( m_iCounter	< m_pAssociateButton.m_iCounter)
						{
							m_pAssociateButton.m_iCounter = m_iCounter;
							m_pAssociateButton.m_pNbOfCounter.SetNewText( string(m_pAssociateButton.m_iCounter), true);
						}
					}
				}                

                if (m_bAdviceParent)
                {
                    // we need to advice the parent too, this is not very good, we use the parent window
                    // (suppose that is a child of UWindowDialogClientWindow) and notify the button msg
                    // it's the responsability of the parent window to manage this new notify
//                    if ( OwnerWindow.IsA('R6MenuMPCreateGameTab'))
                    UWindowDialogClientWindow(ParentWindow).Notify( C, E);
                }
			}

			if (!m_bButPressed)
				m_fTimeCheckBut = 0.5;
			break;
		}
	}
    else if (E == DE_MouseEnter)
    {
     
        // change the color of the button and of the text
        m_pSubButton.SetButtonBorderColor(Root.Colors.BlueLight);
        m_pSubButton.m_vButtonColor = Root.Colors.BlueLight;
        m_pPlusButton.SetButtonBorderColor(Root.Colors.BlueLight);
        m_pPlusButton.m_vButtonColor = Root.Colors.BlueLight;

        if (m_pTextInfo != None)
        {
            m_pTextInfo.TextColor = Root.Colors.BlueLight; 
        }


        // we need to advice the parent too
        if (m_bAdviceParent)
        {
            ParentWindow.ToolTip(R6WindowButton(C).ToolTipString);
        }
     
    }
    else if (E == DE_MouseLeave)
    {
       // change the color of the button and of the text
        m_pSubButton.SetButtonBorderColor(Root.Colors.White);
        m_pSubButton.m_vButtonColor = Root.Colors.White;
        m_pPlusButton.SetButtonBorderColor(Root.Colors.White);
        m_pPlusButton.m_vButtonColor = Root.Colors.White;

        
        if (m_pTextInfo != None)
        {
            m_pTextInfo.TextColor = Root.Colors.White; 
        }

        // we need to advice the parent too
        if (m_bAdviceParent)
        {
            ParentWindow.ToolTip("");
        }
    }
}

defaultproperties
{
     m_iStepCounter=1
     m_iMaxCounter=99
}
