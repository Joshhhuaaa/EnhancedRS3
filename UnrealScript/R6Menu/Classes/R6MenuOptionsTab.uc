//=============================================================================
//  R6MenuOptionsTab.uc : Manage the options window. Not a real tab... plus a page system
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11  * Create by Yannick Joly
//=============================================================================
class R6MenuOptionsTab extends UWindowDialogClientWindow;

const C_fSCROLLBAR_WIDTH				= 140;							// the size of the scroll bar in option menus
const C_fSCROLLBAR_HEIGHT				= 14;							// the height of the scroll bar in option menus
const C_fXPOS_SCROLLBAR					= 250;
const C_fXPOS_COMBOCONTROL				= 250;
const C_ICOMBOCONTROL_WIDTH             = 140;
var Region								SimpleBorderRegion;

var string m_szGeneralButLoc;

var string m_szGeneralButTip;
var R6WindowButton						m_pGeneralButUse;				// the button under the line, use for reset default button, activate mods...
var bool								m_bDrawLineOverButton;
var BOOL								m_bInitComplete;

var bool m_bInGame;

//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================
function Created()
{
	m_bInGame = R6MenuOptionsWidget(OwnerWindow).m_bInGame;
	m_szGeneralButLoc = Localize("Options", "ResetToDefault", "R6Menu");
	m_szGeneralButTip = Localize("Tip", "ResetToDefault", "R6Menu");
}



function InitPageOptions()
{
}

function Paint( Canvas C, FLOAT X, FLOAT Y)
{
	// draw the line over the reset defaut button
	if (m_bDrawLineOverButton)
	{
		C.SetDrawColor( 255, 255, 255);
	    DrawStretchedTextureSegment(C, 0, WinHeight - 15, WinWidth, SimpleBorderRegion.H , 
                                    SimpleBorderRegion.X, SimpleBorderRegion.Y, SimpleBorderRegion.W, SimpleBorderRegion.H, 
									R6MenuRSLookAndFeel(LookAndFeel).m_R6ScrollTexture);		
	}
}




// GENERAL
function InitResetButton()
{
	m_bDrawLineOverButton = true;

	m_pGeneralButUse = R6WindowButton(CreateControl(class'R6WindowButton', 0, WinHeight - 15, WinWidth, 15, self));
	m_pGeneralButUse.Text = m_szGeneralButLoc;
	m_pGeneralButUse.ToolTipString = m_szGeneralButTip;
	m_pGeneralButUse.Align		   = TA_Center;
	m_pGeneralButUse.m_iButtonID   = 0;
}

function UpdateOptionsInPage()
{
}

function UpdateOptionsInEngine()
{
}

function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
    if(Result == MR_OK)
    {
        switch(_ePopUpID)
        {
            case EPopUpID_OptionsResetDefault:
                RestoreDefaultValue();
                break;
        }
    }

    if(R6MenuInGameRootWindow(Root) != none)
    {
        R6MenuInGameRootWindow(Root).m_bInPopUp = false;
    }
}

//=============================================================================================
// RestoreDefaultValue: Restore the default value of the current window
//=============================================================================================
function RestoreDefaultValue()
{
}

/////////////////////////////////////////////////////////////////
// notify the parent window by using the appropriate parent function
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
}
//#endif

function R6WindowComboControl SetComboControlButton( Region _RDefaultW, string _szTitle, string _szTip)
{
	local R6WindowComboControl _pR6WindowComboControl;

	_pR6WindowComboControl = R6WindowComboControl(CreateControl(class'R6WindowComboControl', _RDefaultW.X, _RDefaultW.Y, _RDefaultW.W, LookAndFeel.Size_ComboHeight, self));
	_pR6WindowComboControl.AdjustTextW( _szTitle, 0, 0, _RDefaultW.W * 0.5 , LookAndFeel.Size_ComboHeight);
	_pR6WindowComboControl.AdjustEditBoxW( 0, C_ICOMBOCONTROL_WIDTH, LookAndFeel.Size_ComboHeight);
	_pR6WindowComboControl.SetEditBoxTip( _szTip);
//	_pR6WindowComboControl.SetValue( "", "");

	return 	_pR6WindowComboControl;
}

defaultproperties
{
     SimpleBorderRegion=(X=64,Y=56,W=1,H=1)
}
