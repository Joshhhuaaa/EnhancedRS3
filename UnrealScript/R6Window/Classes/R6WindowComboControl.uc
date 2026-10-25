//=============================================================================
//  R6WindowComboControl.uc : A combo box with or without a text left of the combo box
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//    2002/07/23 * Modifications by Yannick Joly
//=============================================================================

class R6WindowComboControl extends UWindowComboControl;

var R6WindowTextLabel				m_pComboTextLabel;		// the text of the combo
var INT								m_iButtonID;

function Created()
{
	// create the text label of the combo
	m_pComboTextLabel = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 0, WinWidth, LookAndFeel.Size_ComboHeight, self));
	m_pComboTextLabel.SetProperties( "", TA_Left, Root.Fonts[F_SmallTitle], Root.Colors.White, false);

	// use an edit box -- but is not editable 
	EditBox = UWindowEditBox(CreateWindow(class'UWindowEditBox', 0, 0, WinWidth - LookAndFeel.Size_ComboButtonWidth +1, LookAndFeel.Size_ComboHeight, self)); 
	EditBox.NotifyOwner			= Self;
	EditBox.bTransient			= True;
	EditBox.bCanEdit			= false;
	EditBox.m_bDrawEditBorders  = True;
	EditBox.m_BorderColor		= Root.Colors.White;
	EditBox.Align				= TA_Center;
	EditBox.m_bUseNewPaint		= true;

	// create the down button -- need to be place at the good position
	Button = UWindowComboButton(CreateWindow(class'UWindowComboButton', WinWidth - LookAndFeel.Size_ComboButtonWidth, 0, LookAndFeel.Size_ComboButtonWidth, LookAndFeel.Size_ComboHeight, self)); 
	Button.Owner				= Self;
	Button.bAlwaysOnTop			= true;
	Button.m_bDrawButtonBorders = true;
	Button.m_BorderColor		= Root.Colors.White;
	Button.RegionScale = 1;

    // create the combo list
	List = UWindowComboList(Root.CreateWindow(ListClass, 0, 0, (Button.WinLeft + Button.WinWidth) - EditBox.WinLeft, 100, self)); 
	List.LookAndFeel = LookAndFeel;
	List.Owner = Self;	
    List.Setup();
	List.HBorder = 1; // overload value in lookandfeel 
	List.VBorder = 1; // overload value in lookandfeel

	List.HideWindow();
	bListVisible = False;


}

function BeforePaint(Canvas C, float X, float Y)
{
	List.bLeaveOnscreen = bListVisible && bLeaveOnscreen;
}

function Paint(Canvas C, float X, float Y)
{
	if (!m_bDisabled)
	{
		// verify if the mouse is over the edit box
		if (EditBox.m_bMouseOn)
		{
			m_pComboTextLabel.TextColor = Root.Colors.BlueLight;
			EditBox.m_BorderColor		= Root.Colors.BlueLight;
			Button.m_BorderColor		= Root.Colors.BlueLight;
            List.SetBorderColor(Root.Colors.BlueLight);
			ParentWindow.MouseEnter();
		}
		else
		{
			if (!bListVisible) // if the list is visible don't change previous color
			{
				if (m_pComboTextLabel.TextColor != Root.Colors.White )
				{
					m_pComboTextLabel.TextColor = Root.Colors.White;
					EditBox.m_BorderColor		= Root.Colors.White;
					Button.m_BorderColor		= Root.Colors.White;
                    List.SetBorderColor(Root.Colors.White);
					ParentWindow.MouseLeave();
				}
			}
		}
	}
}

//===========================================================================================
// AdjustEditBoxW: Adjust the edit box window in the combocontrol -- the edit box is place at the end of the combo control
//===========================================================================================
function AdjustEditBoxW( FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    Button.WinTop = _fY;

	EditBox.WinLeft   = (Button.WinLeft + 1) - _fWidth;  //+1 so they overlap
	EditBox.WinTop    = Button.WinTop;
	EditBox.WinWidth  = _fWidth;
	EditBox.WinHeight = _fHeight;
	EditBox.Font	  = F_SmallTitle;

	EditBoxWidth      = EditBox.WinWidth;
    List.WinWidth     = (Button.WinLeft + Button.WinWidth) - EditBox.WinLeft;
}

//===========================================================================================
// AdjustTextW: Adjust the text window in the combocontrol
//===========================================================================================
function AdjustTextW( string _szTitle, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
	m_pComboTextLabel.WinLeft   = _fX;
	m_pComboTextLabel.WinTop    = _fY;
	m_pComboTextLabel.WinWidth  = _fWidth;
	m_pComboTextLabel.WinHeight = _fHeight;

	m_pComboTextLabel.SetNewText(_szTitle, true);
}

//====================================================================
// SetEditBoxTip: set the tooltipstring, this string is return to the parent window when the mouse is over the edit box
//====================================================================
function SetEditBoxTip( string _szToolTip)
{
	EditBox.ToolTipString = _szToolTip;
}

//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetDisableButton( BOOL _bDisable)
{
	if (_bDisable)
	{
		EditBox.m_BorderColor		= Root.Colors.ButtonTextColor[1];
		Button.m_BorderColor		= Root.Colors.ButtonTextColor[1];
		Button.bDisabled			= true;
		m_pComboTextLabel.TextColor = Root.Colors.ButtonTextColor[1];

		m_bDisabled = true;
	}
}

defaultproperties
{
     ListClass=Class'R6Window.R6WindowComboList'
}
