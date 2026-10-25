//=============================================================================
//  R6MenuInGameEscSinglePlayerNavBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/14 * Created by Alexandre Dionne
//=============================================================================


class R6MenuInGameEscSinglePlayerNavBar extends UWindowDialogClientWindow;

var R6MenuMPInGameHelpBar      m_HelpTextBar;
var R6WindowButton             m_ExitButton, m_MainMenuButton, m_OptionsButton, m_AbortButton, m_ContinueButton;

var Texture                    m_TExitButton, m_TMainMenuButton, m_TOptionsButton, m_TAbortButton, m_TContinueButton;
var Texture                    m_TRetryTrainingButton;

var Region                     m_RExitButtonUp,     m_RExitButtonDown,     m_RExitButtonDisabled,     m_RExitButtonOver;
var Region                     m_RMainMenuButtonUp, m_RMainMenuButtonDown, m_RMainMenuButtonDisabled, m_RMainMenuButtonOver;
var Region                     m_ROptionsButtonUp,  m_ROptionsButtonDown,  m_ROptionsButtonDisabled,  m_ROptionsButtonOver;
var Region                     m_RAbortButtonUp,    m_RAbortButtonDown,    m_RAbortButtonDisabled,    m_RAbortButtonOver;
var Region                     m_RContinueButtonUp, m_RContinueButtonDown, m_RContinueButtonDisabled, m_RContinueButtonOver;
var Region                     m_RRetryTrainingButtonUp, m_RRetryTrainingButtonDown, m_RRetryTrainingButtonDisabled, m_RRetryTrainingButtonOver;

var FLOAT                      m_fHelpTextHeight, m_fButtonsYPos;
var FLOAT                      m_fExitXPos, m_fMainMenuXPos, m_fOptionsXPos, m_fAbortXPos, m_fContinueXPos;

var BOOL						m_bInTraining;

function Created()
{

    // Create Help Text Bar 
	m_HelpTextBar = R6MenuMPInGameHelpBar(CreateWindow(class'R6MenuMPInGameHelpBar', 1, 0, WinWidth - 2, m_fHelpTextHeight, self));
	m_HelpTextBar.m_szDefaultText = Localize("ESCMENUS","ESCRESUME","R6Menu");

    m_ExitButton        = R6WindowButton(CreateControl( class'R6WindowButton', m_fExitXPos, m_fButtonsYPos, m_RExitButtonUp.W, m_RExitButtonUp.H, self));
    m_ExitButton.UpTexture          =   m_TExitButton;
    m_ExitButton.OverTexture        =   m_TExitButton;
    m_ExitButton.DownTexture        =   m_TExitButton;
    m_ExitButton.DisabledTexture    =   m_TExitButton;      
    m_ExitButton.UpRegion           =   m_RExitButtonUp;
    m_ExitButton.OverRegion         =   m_RExitButtonOver;    
    m_ExitButton.DownRegion         =   m_RExitButtonDown;   
    m_ExitButton.DisabledRegion     =   m_RExitButtonDisabled;    
    m_ExitButton.bUseRegion         =   true;
    m_ExitButton.ToolTipString      =   Localize("ESCMENUS","QUIT","R6Menu");
    m_ExitButton.m_iDrawStyle       =   5; //Alpha

    m_MainMenuButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_fMainMenuXPos, m_fButtonsYPos, m_RMainMenuButtonUp.W, m_RMainMenuButtonUp.H, self));
    m_MainMenuButton.UpTexture          =   m_TMainMenuButton;
    m_MainMenuButton.OverTexture        =   m_TMainMenuButton;
    m_MainMenuButton.DownTexture        =   m_TMainMenuButton;
    m_MainMenuButton.DisabledTexture    =   m_TMainMenuButton;        
    m_MainMenuButton.UpRegion           =   m_RMainMenuButtonUp;
    m_MainMenuButton.OverRegion         =   m_RMainMenuButtonOver;    
    m_MainMenuButton.DownRegion         =   m_RMainMenuButtonDown;   
    m_MainMenuButton.DisabledRegion     =   m_RMainMenuButtonDisabled;    
    m_MainMenuButton.bUseRegion         =   true;
    m_MainMenuButton.ToolTipString      =   Localize("ESCMENUS","MAIN","R6Menu");
    m_MainMenuButton.m_iDrawStyle       =   5; //Alpha


    m_OptionsButton     = R6WindowButton(CreateControl( class'R6WindowButton', m_fOptionsXPos, m_fButtonsYPos, m_ROptionsButtonUp.W, m_ROptionsButtonUp.H, self));
    m_OptionsButton.UpTexture          =   m_TOptionsButton;
    m_OptionsButton.OverTexture        =   m_TOptionsButton;    
    m_OptionsButton.DownTexture        =   m_TOptionsButton;
    m_OptionsButton.DisabledTexture    =   m_TOptionsButton;   
    m_OptionsButton.UpRegion           =   m_ROptionsButtonUp;
    m_OptionsButton.OverRegion         =   m_ROptionsButtonOver;    
    m_OptionsButton.DownRegion         =   m_ROptionsButtonDown;   
    m_OptionsButton.DisabledRegion     =   m_ROptionsButtonDisabled;    
    m_OptionsButton.bUseRegion         =   true;
    m_OptionsButton.ToolTipString      =   Localize("ESCMENUS","ESCOPTIONS","R6Menu");
    m_OptionsButton.m_iDrawStyle       =   5; //Alpha


    m_AbortButton       = R6WindowButton(CreateControl( class'R6WindowButton', m_fAbortXPos, m_fButtonsYPos, m_RAbortButtonUp.W, m_RAbortButtonUp.H, self));
    m_AbortButton.UpTexture          =   m_TAbortButton;
    m_AbortButton.OverTexture        =   m_TAbortButton;
    m_AbortButton.DownTexture        =   m_TAbortButton;
    m_AbortButton.DisabledTexture    =   m_TAbortButton;
    m_AbortButton.UpRegion           =   m_RAbortButtonUp;
    m_AbortButton.OverRegion         =   m_RAbortButtonOver;    
    m_AbortButton.DownRegion         =   m_RAbortButtonDown;   
    m_AbortButton.DisabledRegion     =   m_RAbortButtonDisabled;    
    m_AbortButton.bUseRegion         =   true;
    m_AbortButton.ToolTipString      =   Localize("ESCMENUS","ESCABORT_ACTION","R6Menu");
    m_AbortButton.m_iDrawStyle       =   5; //Alpha


    m_ContinueButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_fContinueXPos, m_fButtonsYPos, m_RContinueButtonUp.W, m_RContinueButtonUp.H, self));
    m_ContinueButton.UpTexture          =   m_TContinueButton;
    m_ContinueButton.OverTexture        =   m_TContinueButton;
    m_ContinueButton.DownTexture        =   m_TContinueButton;
    m_ContinueButton.DisabledTexture    =   m_TContinueButton;    
    m_ContinueButton.UpRegion           =   m_RContinueButtonUp;
    m_ContinueButton.OverRegion         =   m_RContinueButtonOver;    
    m_ContinueButton.DownRegion         =   m_RContinueButtonDown;   
    m_ContinueButton.DisabledRegion     =   m_RContinueButtonDisabled;    
    m_ContinueButton.bUseRegion         =   true;
    m_ContinueButton.ToolTipString      =   Localize("ESCMENUS","ESCABORT_PLANNING","R6Menu");
    m_ContinueButton.m_iDrawStyle       =   5; //Alpha

}

//===============================================================================================
// SetTrainingNavbar: If you are in training, use thoses settings instead of what's you have in created
//===============================================================================================
function SetTrainingNavbar()
{
	m_bInTraining = true;

    m_ContinueButton.UpTexture          =   m_TRetryTrainingButton;
    m_ContinueButton.OverTexture        =   m_TRetryTrainingButton;
    m_ContinueButton.DownTexture        =   m_TRetryTrainingButton;
    m_ContinueButton.DisabledTexture    =   m_TRetryTrainingButton;    
    m_ContinueButton.UpRegion           =   m_RRetryTrainingButtonUp;
    m_ContinueButton.OverRegion         =   m_RRetryTrainingButtonOver;    
    m_ContinueButton.DownRegion         =   m_RRetryTrainingButtonDown;   
    m_ContinueButton.DisabledRegion     =   m_RRetryTrainingButtonDisabled;
    m_ContinueButton.ToolTipString      =   Localize("ESCMENUS","ESCQUIT_TRAINING","R6Menu");
    m_ContinueButton.SetSize(m_RRetryTrainingButtonUp.W,m_RRetryTrainingButtonUp.H);

	m_AbortButton.ToolTipString         =   Localize("ESCMENUS","ESCABORT_TRAINING","R6Menu");
}

function Notify(UWindowDialogControl C, byte E)
{
    if( E == DE_Click )
    {
        switch(C)
        {
        case m_ExitButton:             
            R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP","PopUpTitle_QUIT","R6Menu"),Localize("ESCMENUS","QuitConfirm","R6Menu"),EPopUpID_LeaveInGameToQuit);
            break;
        case m_MainMenuButton:            
            R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP","PopUpTitle_QuitToMain","R6Menu"),Localize("ESCMENUS","MAINCONFIRM","R6Menu"),EPopUpID_LeaveInGameToMain);
            break;
        case m_OptionsButton:
            Root.ChangeCurrentWidget(OptionsWidgetID);            
            break;
        case m_AbortButton:
			if (m_bInTraining)
	            R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP","PopUpTitle_ESCABORT_TRAINING","R6Menu"),Localize("ESCMENUS","ABORTCONFIRM_TRAINING","R6Menu"), EPopUpID_AbortMissionRetryAction);
			else
	            R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP","PopUpTitle_ESCABORT_ACTION","R6Menu"),Localize("ESCMENUS","ABORTCONFIRM_ACTION","R6Menu"), EPopUpID_AbortMissionRetryAction);            
            break;
        case m_ContinueButton:
			if (m_bInTraining)
			{               
                R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP","PopUpTitle_ESCQUIT_TRAINING","R6Menu"),Localize("ESCMENUS","QUITCONFIRM_TRAINING","R6Menu"), EPopUpID_QuitTraining);
			}
			else
			{
	            R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP","PopUpTitle_ESCABORT_PLANNING","R6Menu"),Localize("ESCMENUS","ABORTCONFIRM_PLAN","R6Menu"), EPopUpID_AbortMissionRetryPlan);
			}
            break;
        }
    }

}

defaultproperties
{
     m_fHelpTextHeight=20.000000
     m_fButtonsYPos=22.000000
     m_fExitXPos=32.000000
     m_fMainMenuXPos=110.000000
     m_fOptionsXPos=194.000000
     m_fAbortXPos=267.000000
     m_fContinueXPos=346.000000
     m_TExitButton=Texture'R6MenuTextures.Gui_02'
     m_TMainMenuButton=Texture'R6MenuTextures.Gui_02'
     m_TOptionsButton=Texture'R6MenuTextures.Gui_02'
     m_TAbortButton=Texture'R6MenuTextures.Gui_01'
     m_TContinueButton=Texture'R6MenuTextures.Gui_01'
     m_TRetryTrainingButton=Texture'R6MenuTextures.Gui_02'
     m_RExitButtonUp=(X=75,W=35,H=30)
     m_RExitButtonDown=(X=75,Y=60,W=35,H=30)
     m_RExitButtonDisabled=(X=75,Y=90,W=35,H=30)
     m_RExitButtonOver=(X=75,Y=30,W=35,H=30)
     m_RMainMenuButtonUp=(X=111,W=36,H=30)
     m_RMainMenuButtonDown=(X=111,Y=60,W=36,H=30)
     m_RMainMenuButtonDisabled=(X=111,Y=90,W=36,H=30)
     m_RMainMenuButtonOver=(X=111,Y=30,W=36,H=30)
     m_ROptionsButtonUp=(X=148,W=30,H=30)
     m_ROptionsButtonDown=(X=148,Y=60,W=30,H=30)
     m_ROptionsButtonDisabled=(X=148,Y=90,W=30,H=30)
     m_ROptionsButtonOver=(X=148,Y=30,W=30,H=30)
     m_RAbortButtonUp=(X=93,W=32,H=30)
     m_RAbortButtonDown=(X=93,Y=60,W=32,H=30)
     m_RAbortButtonDisabled=(X=93,Y=90,W=32,H=30)
     m_RAbortButtonOver=(X=93,Y=30,W=32,H=30)
     m_RContinueButtonUp=(X=125,W=30,H=30)
     m_RContinueButtonDown=(X=125,Y=60,W=30,H=30)
     m_RContinueButtonDisabled=(X=125,Y=90,W=30,H=30)
     m_RContinueButtonOver=(X=125,Y=30,W=30,H=30)
     m_RRetryTrainingButtonUp=(Y=120,W=33,H=30)
     m_RRetryTrainingButtonDown=(Y=180,W=33,H=30)
     m_RRetryTrainingButtonDisabled=(Y=210,W=33,H=30)
     m_RRetryTrainingButtonOver=(Y=150,W=33,H=30)
}
