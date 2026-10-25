//=============================================================================
//  R6MenuMPInGameEscNavBar.uc : The nav bar of the esc menu for multiplayer in game
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/05 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameEscNavBar extends R6MenuInGameEscSinglePlayerNavBar; 

var Texture                    m_TMPContinueButton;

var Region                     m_RMPContinueButtonUp, m_RMPContinueButtonDown, m_RMPContinueButtonDisabled, m_RMPContinueButtonOver;
var Region					   m_RPopUp;		// region of the popup

function Created()
{
	Super.Created();

	m_HelpTextBar.m_szDefaultText ="";

	m_AbortButton.ToolTipString			=   Localize("ESCMENUS","ESCABORTMP","R6Menu");
	m_ContinueButton.ToolTipString		=	Localize("ESCMENUS","ESCCONTINUE","R6Menu");

    m_ContinueButton.UpTexture          =   m_TMPContinueButton;
    m_ContinueButton.OverTexture        =   m_TMPContinueButton;
    m_ContinueButton.DownTexture        =   m_TMPContinueButton;
    m_ContinueButton.DisabledTexture    =   m_TMPContinueButton;

    m_ContinueButton.UpRegion           =   m_RMPContinueButtonUp;
    m_ContinueButton.OverRegion         =   m_RMPContinueButtonOver;    
    m_ContinueButton.DownRegion         =   m_RMPContinueButtonDown;   
    m_ContinueButton.DisabledRegion     =   m_RMPContinueButtonDisabled;    

    // MainMenu button is disable when the game was launch by Ubi.com
    if (R6Console(Root.Console).m_bStartedByGSClient)
    {
        m_MainMenuButton.bDisabled = true;
    }
    else if (R6Console(Root.Console).m_bNonUbiMatchMakingHost ||
             R6Console(Root.Console).m_bNonUbiMatchMaking)
    {
        m_MainMenuButton.bDisabled = true;
        m_AbortButton.bDisabled = true;
    }
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;

	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

    if( E == DE_Click )
    {
        switch(C)
        {
        case m_ExitButton:
			R6MenuMPInGameEsc(OwnerWindow).m_bEscAvailable = false;
			R6Root.m_RSimplePopUp = m_RPopUp;
			R6Root.SimplePopUp( Localize("ESCMENUS","QuitConfirmTitle","R6Menu"), Localize("ESCMENUS", "QuitConfirm", "R6Menu"), EPopUpID_LeaveInGameToQuit);
            break;
        case m_MainMenuButton:
			R6MenuMPInGameEsc(OwnerWindow).m_bEscAvailable = false;            
			R6Root.m_RSimplePopUp = m_RPopUp;
			R6Root.SimplePopUp( Localize("ESCMENUS","DisconnectConfirmTitle","R6Menu"), Localize("ESCMENUS", "DisconnectConfirm", "R6Menu"), EPopUpID_LeaveInGameToMain);
            break;
        case m_OptionsButton:
            R6Root.ChangeCurrentWidget(OptionsWidgetID);            
            break;
        case m_AbortButton:
			R6MenuMPInGameEsc(OwnerWindow).m_bEscAvailable = false;
			R6Root.m_RSimplePopUp = m_RPopUp;
			R6Root.SimplePopUp( Localize("ESCMENUS","DisconnectConfirmTitle","R6Menu"), Localize("ESCMENUS", "DisconnectConfirm", "R6Menu"), EPopUpID_LeaveInGameToMultiMenu);
            break;
        case m_ContinueButton:
			R6Root.ChangeCurrentWidget( WidgetID_None);
            break;
        }
    }
}

defaultproperties
{
     m_TMPContinueButton=Texture'R6MenuTextures.Gui_01'
     m_RMPContinueButtonUp=(X=203,Y=120,W=34,H=30)
     m_RMPContinueButtonDown=(X=203,Y=180,W=34,H=30)
     m_RMPContinueButtonDisabled=(X=203,Y=210,W=34,H=30)
     m_RMPContinueButtonOver=(X=203,Y=150,W=34,H=30)
     m_RPopUp=(X=150,Y=283,W=340,H=60)
     m_TAbortButton=Texture'R6MenuTextures.Gui_02'
     m_RAbortButtonUp=(X=213,W=34)
     m_RAbortButtonDown=(X=213,W=34)
     m_RAbortButtonDisabled=(X=213,W=34)
     m_RAbortButtonOver=(X=213,W=34)
}
