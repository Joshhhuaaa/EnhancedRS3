//=============================================================================
//  R6WindowPopUpBox.uc : This provides the simple frame for all the pop-up window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================

class R6WindowUbiLoginClient extends UWindowDialogClientWindow;

const K_EDIT_BOX_HEIGHT        = 15;
const K_EDIT_BOX_WIDTH         = 140;
const K_TEXT_HEIGHT            = 15;
const K_TEXT_WIDTH             = 130;
const K_VERTICAL_SPACER        = 2;
const K_BOTTON_WIDTH           = 95;
const K_LEFT_HOR_OFF           = 5;
const K_RIGHT_HOR_OFF          = 10;

var R6WindowEditControl  m_pUserName;       // username edit box
var R6WindowEditControl  m_pPassword;       // password edit box
var R6WindowButtonBox    m_pSavePassword;   // save password button box
var R6WindowButtonBox    m_pAutoLogIn;      // auto login button box
var R6WindowButton       m_pCrAccountBut;   // create account button (takes user to ubi.com website)
var R6WindowTextLabelExt m_pCrAccountText;  // create account text


function SetupClientWindow( float fWindowWidth )
{

    local FLOAT  fX;
    local FLOAT  fY;
    local FLOAT  fWidth;
    local FLOAT  fHeight;

    fX      = K_LEFT_HOR_OFF;
    fY      = K_VERTICAL_SPACER;
    fHeight = K_EDIT_BOX_HEIGHT;
    fWidth  = fWindowWidth - ( K_LEFT_HOR_OFF + K_RIGHT_HOR_OFF );

    // ubi.com account username edit control

	m_pUserName = R6WindowEditControl(CreateControl(class'R6WindowEditControl', fX, fY, fWidth, fHeight, self));
	m_pUserName.SetValue("");
	m_pUserName.CreateTextLabel( Localize("MultiPlayer","PopUp_LoginName","R6Menu"),
									   0, 0, fWidth * 0.5, fHeight);
	m_pUserName.SetEditBoxTip("");
    fWidth = 165;
	m_pUserName.ModifyEditBoxW( fWindowWidth - fWidth - K_RIGHT_HOR_OFF, 0, fWidth, fHeight);
	m_pUserName.EditBox.MaxLength = 15;

    fY += K_TEXT_HEIGHT + K_VERTICAL_SPACER;
    fWidth  = fWindowWidth - ( K_LEFT_HOR_OFF + K_RIGHT_HOR_OFF );

    // ubi.com account password edit control

	m_pPassword = R6WindowEditControl(CreateControl(class'R6WindowEditControl', fX, fY, fWidth, fHeight, self));
	m_pPassword.SetValue("");
	m_pPassword.CreateTextLabel( Localize("MultiPlayer","PopUp_UbiPassword","R6Menu"),
									   0, 0, fWidth * 0.5, fHeight);
	m_pPassword.SetEditBoxTip("");
    fWidth = 165;
	m_pPassword.ModifyEditBoxW( fWindowWidth - fWidth - K_RIGHT_HOR_OFF, 0, fWidth, fHeight);
	m_pPassword.EditBox.MaxLength = 20; // Max of 20 caracters
    m_pPassword.EditBox.bPassword = TRUE;

    fY += K_TEXT_HEIGHT + K_VERTICAL_SPACER;
    fWidth  = fWindowWidth - ( K_LEFT_HOR_OFF + K_RIGHT_HOR_OFF );

    // save password button box

    m_pSavePassword = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fX, fY, fWidth, fHeight, self, true ));
    m_pSavePassword.m_TextFont = Root.Fonts[F_SmallTitle];
    m_pSavePassword.m_vTextColor = Root.Colors.White;
    m_pSavePassword.m_vBorder = Root.Colors.White;
    m_pSavePassword.m_bSelected = false;
    m_pSavePassword.CreateTextAndBox( Localize("MultiPlayer","PopUp_RemPass","R6Menu"), 
                                      "", 0, 0);
    m_pSavePassword.SetButtonBox( TRUE );

    fY += K_TEXT_HEIGHT + K_VERTICAL_SPACER;

    // auto login button box

    m_pAutoLogIn = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fX, fY, fWidth, fHeight, self, true ));
    m_pAutoLogIn.m_TextFont = Root.Fonts[F_SmallTitle];
    m_pAutoLogIn.m_vTextColor = Root.Colors.White;
    m_pAutoLogIn.m_vBorder = Root.Colors.White;
    m_pAutoLogIn.m_bSelected = false;
    m_pAutoLogIn.CreateTextAndBox( Localize("MultiPlayer","PopUp_AutoLogin","R6Menu"), 
                                   "", 0, 0);
    m_pAutoLogIn.SetButtonBox( TRUE );

    fY += K_TEXT_HEIGHT + K_VERTICAL_SPACER;
    fWidth  = K_TEXT_WIDTH;

    // Text for create account button

    m_pCrAccountText = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', fX, fY, fWidth, fHeight, self));
    m_pCrAccountText.m_Font = Root.Fonts[F_SmallTitle]; 
    m_pCrAccountText.m_vTextColor = Root.Colors.White;
    m_pCrAccountText.AddTextLabel( Localize("MultiPlayer","PopUp_www","R6Menu"), 0, 0, 200, TA_Left, false);
    m_pCrAccountText.m_bTextCenterToWindow = true;

    fX = fWindowWidth - K_BOTTON_WIDTH - K_RIGHT_HOR_OFF;
    fWidth  = K_BOTTON_WIDTH;

    // Create account button

    m_pCrAccountBut = R6WindowButton(CreateControl(class'R6WindowButton', fX, fY, fWidth, fHeight, self, true));
    m_pCrAccountBut.m_vButtonColor     = Root.Colors.White;
    m_pCrAccountBut.SetButtonBorderColor(Root.Colors.White);
	m_pCrAccountBut.m_bDrawBorders     = TRUE;
    m_pCrAccountBut.Align  = TA_Center;
    m_pCrAccountBut.ImageX = 2;
    m_pCrAccountBut.ImageY = 2;
    m_pCrAccountBut.m_bDrawSimpleBorder = TRUE;
    m_pCrAccountBut.bStretched = TRUE;
    m_pCrAccountBut.SetText( Localize("MultiPlayer","PopUp_CrAcct","R6Menu") );
    m_pCrAccountBut.SetFont(F_Normal);
	m_pCrAccountBut.TextColor          = Root.Colors.White;	


}

//-------------------------------------------------------------------------
// ManageR6ButtonBoxNotify - Notify function for classes of
// type 'R6WindowButtonBox'
//-------------------------------------------------------------------------
function Notify(UWindowDialogControl C, byte E)
{

    switch (C)
    {
        case m_pCrAccountBut:
            if ( E == DE_Click )
            {
                R6Console(Root.Console).m_GameService.Initialize();
                Root.Console.ConsoleCommand("startminimized " @ R6Console(Root.Console).m_GameService.m_szUbiHomePage);
            }
            break;
        case m_pSavePassword:
        case m_pAutoLogIn:
	        if(E == DE_Click)
	        {
                if (R6WindowButtonBox(C).GetSelectStatus())
                {
                    R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected;
                }
            }
            m_pAutoLogIn.bDisabled = !m_pSavePassword.m_bSelected;
            if ( m_pAutoLogIn.bDisabled )
                m_pAutoLogIn.m_bSelected = FALSE;
            break;
    }

}

defaultproperties
{
}
