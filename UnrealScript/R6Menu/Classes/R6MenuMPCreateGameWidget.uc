//=============================================================================
//  R6MenuMultiPlayerWidget.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/04/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameWidget extends R6MenuWidget;

enum eCreateGameTabID
{
    TAB_Options,
	TAB_AdvancedOptions,
    TAB_Kit
};

// This enum is for Restriction Kit menu buttons
enum eRestrictionKit
{
    KIT_SubMachineGuns,
    KIT_Shotguns
};

const K_XSTARTPOS                     = 10;                      // the start pos of window LAN SERVER INFO and GameMode
const K_WINDOWWIDTH                   = 620;                     // the size of window LAN SERVER INFO and GameMode
const K_XTABOFFSET                    = 5;                       // the first tab offset in X
const K_TABWINDOW_WIDTH               = 550;                     // in relation with K_WINDOWWIDTH and K_XTABOFFSET
const K_YPOS_TABWINDOW_CURVED         = 87;                      // the R6WindowTextLabelCurved window
const K_YPOS_TABWINDOW                = 92;                      // the tab inside the R6WindowTextLabelCurved window
const K_YPOS_HELPTEXT_WINDOW          = 430;                     // the y pos of help text window

const K_HSIZE_TABWINDOWCURVED         = 30;                      // height of tab windowcurved
const K_HSIZE_TABWINDOW               = 25;                      // height of a tab (in relation with K_HSIZE_TABWINDOWCURVED)
const K_HSIZE_UNDER_TABWINDOW         = 300;                     // heigth of the window under the tab

var R6WindowTextLabel			      m_LMenuTitle; 

var R6WindowButton	                  m_ButtonMainMenu;
var R6WindowButton	                  m_ButtonOptions;

var R6WindowButtonMultiMenu           m_ButtonCancel;
var R6WindowButtonMultiMenu           m_ButtonLaunch;

var R6WindowTextLabelCurved           m_FirstTabWindow;          // First tab window (on a simple curved frame)

var R6MenuMPManageTab                 m_pFirstTabManager;        // creation of the tab manager for the first tab window

var R6MenuMPCreateGameTab             m_pCreateTabWindow;
var R6MenuMPCreateGameTabOptions      m_pCreateTabOptions;
var R6MenuMPCreateGameTabKitRest      m_pCreateTabKit;
var R6MenuMPCreateGameTabAdvOptions   m_pCreateTabAdvOptions;

var R6MenuHelpWindow                  m_pHelpTextWindow;
var R6WindowSimpleFramedWindowExt     m_pWindowBorder;

var R6WindowUbiLogIn                  m_pLoginWindow;
var BOOL                              m_bLoginInProgress;        // procedure to login to ubi.com in progress

function Created()
{

//    m_SvrManager = new class'R6ServerList'; //New(None) class<R6ServerList>(DynamicLoadObject("R6GameService.R6ServerList", class'Class'));

    InitText();   // init the text
    InitButton(); // init the necessary buttons

	m_FirstTabWindow = R6WindowTextLabelCurved(CreateWindow(class'R6WindowTextLabelCurved', K_XSTARTPOS, K_YPOS_TABWINDOW_CURVED, K_WINDOWWIDTH, K_HSIZE_TABWINDOWCURVED, self));
    m_FirstTabWindow.bAlwaysBehind = true;
	m_FirstTabWindow.Text = "";    
    m_FirstTabWindow.m_BGTexture = None; // no background

    m_pFirstTabManager = R6MenuMPManageTab(CreateWindow(class'R6MenuMPManageTab', K_XSTARTPOS + K_XTABOFFSET, K_YPOS_TABWINDOW, K_TABWINDOW_WIDTH , K_HSIZE_TABWINDOW, self));
    m_pFirstTabManager.AddTabInControl(Localize("MPCreateGame","Tab_Options","R6Menu"), Localize("Tip","Tab_Options","R6Menu"),
                                       eCreateGameTabID.TAB_Options);
    m_pFirstTabManager.AddTabInControl(Localize("MPCreateGame","Tab_AdvOptions","R6Menu"), Localize("Tip","Tab_AdvOptions","R6Menu"),
                                       eCreateGameTabID.TAB_AdvancedOptions);
    m_pFirstTabManager.AddTabInControl(Localize("MPCreateGame","Tab_Kit","R6Menu"), Localize("Tip","Tab_Kit","R6Menu"),
                                       eCreateGameTabID.TAB_Kit);

	m_pLoginWindow = R6WindowUbiLogIn(CreateWindow(Root.MenuClassDefines.ClassUbiLogIn, 0, 0, 640, 480, self, TRUE));
    m_pLoginWindow.m_GameService = R6Console(Root.console).m_GameService;
    m_pLoginWindow.PopUpBoxCreate();
    m_pLoginWindow.HideWindow();


    // create the help window
    m_pHelpTextWindow = R6MenuHelpWindow(CreateWindow(class'R6MenuHelpWindow', 150, 429, 340, 42, self)); //std param is set in help window    

    InitTabWindow();
}


/////////////////////////////////////////////////////////////////
// display the background
/////////////////////////////////////////////////////////////////
function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Root.PaintBackground( C, self);	

    if ( m_bLoginInProgress )
        m_pLoginWindow.Manager( self );

}

function ShowWindow()
{
	// randomly update the background texture
	R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.eGameWidgetID.MPCreateGameWidgetID, self);
    Root.SetLoadRandomBackgroundImage("CreateGame");

    if (!R6Console(Root.console).m_bStartedByGSClient &&
        (R6Console(Root.console).m_bNonUbiMatchMakingHost ||
        R6Console(Root.Console).m_bAutoLoginFirstPass))
    {
        R6Console(Root.Console).m_bAutoLoginFirstPass = FALSE;
        
        R6MenuRootWindow(Root).InitBeaconService();

        R6Console(Root.console).m_GameService.StartAutoLogin();
        
        if (!R6Console(Root.console).m_GameService.m_bAutoLoginInProgress)
        {
			R6Console(Root.console).szStoreGamePassWd = m_pCreateTabOptions.GetCreateGamePassword();
            m_pLoginWindow.StartLogInProcedure(OwnerWindow);
            m_bLoginInProgress = TRUE;                
        }
        else
        {
            // autologin in progress, m_pLoginWindow trap the result of autologin
            m_pLoginWindow.m_pSendMessageDest = self;
            m_bLoginInProgress = TRUE; 
        }
    }
    
	Super.ShowWindow();
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
    switch(eMessage)
    {
        case MWM_UBI_LOGIN_SUCCESS:
        case MWM_UBI_LOGIN_SKIPPED:
            m_bLoginInProgress = false;
            if(R6Console(Root.Console).m_bNonUbiMatchMakingHost)
            {
                Root.ChangeCurrentWidget(MPCreateGameWidgetID);
                R6MenuRootWindow(Root).InitBeaconService();                
            }
            else
            {
                R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess();
            }
            break;
        case MWM_UBI_LOGIN_FAIL:
            if(R6Console(Root.Console).m_bNonUbiMatchMakingHost)
            {
                m_bLoginInProgress = false;
            }
            break;
        default:
            break;
    }
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) 
{
    m_pHelpTextWindow.ToolTip(strTip);
}

/////////////////////////////////////////////////////////////////
// manage the tab selection (the call of the fct come from R6MenuMPManageTab
/////////////////////////////////////////////////////////////////
function ManageTabSelection( INT _MPTabChoiceID)
{
    switch(_MPTabChoiceID)
    {
        case eCreateGameTabID.TAB_Options:
            m_pCreateTabWindow.HideWindow();
            m_pCreateTabOptions.ShowWindow();
            m_pCreateTabWindow = m_pCreateTabOptions;
            break;
        case eCreateGameTabID.TAB_Kit:
            m_pCreateTabWindow.HideWindow();
            m_pCreateTabKit.ShowWindow();
            m_pCreateTabWindow = m_pCreateTabKit;
            break;
        case eCreateGameTabID.TAB_AdvancedOptions:
            m_pCreateTabWindow.HideWindow();
            m_pCreateTabAdvOptions.ShowWindow();
            m_pCreateTabWindow = m_pCreateTabAdvOptions;
            break;
        default:
            log("This tab was not supported (R6MenuMPCreateGameWidget)");
            break;
    }
}

function RefreshCreateGameMenu()
{
    m_pCreateTabOptions.RefreshServerOpt();
	m_pCreateTabAdvOptions.RefreshServerOpt(); 
}


function MenuServerLoadProfile()
{
	m_pCreateTabOptions.RefreshServerOpt( true);
	m_pCreateTabAdvOptions.RefreshServerOpt(); 
	m_pCreateTabKit.m_pMainRestriction.RefreshCreateGameKitRest();
}

//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitText()
{
    // define Title
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 18, WinWidth - 8, 25, self));
	m_LMenuTitle.Text = Localize("MPCreateGame","Title","R6Menu");
	m_LMenuTitle.Align = TA_Right;
	m_LMenuTitle.m_Font = Root.Fonts[F_MenuMainTitle];
	m_LMenuTitle.TextColor = Root.Colors.White;
	m_LMenuTitle.m_BGTexture = None;
	m_LMenuTitle.m_HBorderTexture = None;
	m_LMenuTitle.m_VBorderTexture = None;
}


function InitButton()
{
	local Font  buttonFont;
    local FLOAT fYOffset;

    fYOffset = 50;

	buttonFont		= Root.Fonts[F_MainButton];
	
    // define Main Menu Button
    m_ButtonMainMenu = R6WindowButton(CreateControl( class'R6WindowButton', K_XSTARTPOS, 425, 250, 25, self));
    m_ButtonMainMenu.ToolTipString      = Localize("Tip","ButtonMainMenu","R6Menu");
	m_ButtonMainMenu.Text               = Localize("SinglePlayer","ButtonMainMenu","R6Menu");	
	m_ButtonMainMenu.Align              = TA_LEFT;
	m_ButtonMainMenu.m_fFontSpacing     = 0;
	m_ButtonMainMenu.m_buttonFont       = Root.Fonts[F_MainButton];
	m_ButtonMainMenu.ResizeToText();
    m_ButtonMainMenu.bDisabled = R6Console(Root.console).m_bStartedByGSClient || R6Console(Root.console).m_bNonUbiMatchMakingHost;

    // define option Button
	m_ButtonOptions = R6WindowButton(CreateControl( class'R6WindowButton', K_XSTARTPOS, 447, 250, 25, self));
    m_ButtonOptions.ToolTipString       = Localize("Tip","ButtonOptions","R6Menu");
	m_ButtonOptions.Text                = Localize("SinglePlayer","ButtonOptions","R6Menu");	
	m_ButtonOptions.Align               = TA_LEFT;	
	m_ButtonOptions.m_fFontSpacing      = 0;
	m_ButtonOptions.m_buttonFont        = Root.Fonts[F_MainButton];
	m_ButtonOptions.ResizeToText();	
    
    // define CANCEL button
	m_ButtonCancel = R6WindowButtonMultiMenu(CreateWindow( class'R6WindowButtonMultiMenu', 10, fYOffset, 200, 25, self));
    m_ButtonCancel.Text = Localize("MPCreateGame","ButtonCancel","R6Menu");
    m_ButtonCancel.ToolTipString = Localize("Tip","ButtonCancel","R6Menu");
	m_ButtonCancel.m_eButton_Action = EButtonName.EBN_Cancel;
	m_ButtonCancel.Align = TA_Left;
	m_ButtonCancel.m_fFontSpacing =2;
	m_ButtonCancel.m_buttonFont = buttonFont;
	m_ButtonCancel.ResizeToText();
	
    // If started by ubi.com, cancel button returns user to gs client
    if ( R6Console(Root.console).m_bStartedByGSClient )
	    m_ButtonCancel.m_eButton_Action = EButtonName.EBN_CancelUbiCom;

    // define LAUNCH button
	m_ButtonLaunch = R6WindowButtonMultiMenu(CreateWindow( class'R6WindowButtonMultiMenu', 200, fYOffset, 106, 25, self));
    m_ButtonLaunch.Text = Localize("MPCreateGame","ButtonLaunch","R6Menu");
    m_ButtonLaunch.ToolTipString = Localize("Tip","ButtonLaunch","R6Menu");
	m_ButtonLaunch.m_eButton_Action = EButtonName.EBN_Launch;
	m_ButtonLaunch.Align = TA_Center;
	m_ButtonLaunch.m_fFontSpacing =2;
	m_ButtonLaunch.m_buttonFont = buttonFont;
	m_ButtonLaunch.ResizeToText();
}


function InitTabWindow()
{
    local FLOAT fWidth;
    local FLOAT fYPos;
    fWidth = 1;
    fYPos = K_YPOS_TABWINDOW_CURVED + K_HSIZE_TABWINDOWCURVED - 1; //why -1, because is the border offset from Labelcurved

    // create the border window under the tab
    m_pWindowBorder = R6WindowSimpleFramedWindowExt(CreateWindow(class'R6WindowSimpleFramedWindowExt', K_XSTARTPOS, fYPos, K_WINDOWWIDTH, K_HSIZE_UNDER_TABWINDOW, self));
    m_pWindowBorder.bAlwaysBehind = true;
    m_pWindowBorder.ActiveBorder( 0, false);                         // Top border
    m_pWindowBorder.SetBorderParam( 1, 7, 0, fWidth, Root.Colors.White);         // Bottom border
    m_pWindowBorder.SetBorderParam( 2, 1, 1, fWidth, Root.Colors.White);		 // Left border
    m_pWindowBorder.SetBorderParam( 3, 1, 1, fWidth, Root.Colors.White);		 // Rigth border
    
    m_pWindowBorder.m_eCornerType = Bottom_Corners;
    m_pWindowBorder.SetCornerColor( 2, Root.Colors.White);

	m_pWindowBorder.ActiveBackGround( true, Root.Colors.Black);                  // draw background
////////////////////
    // create one window under the second tab window
	m_pCreateTabOptions = R6MenuMPCreateGameTabOptions(CreateWindow(Root.MenuClassDefines.ClassMPCreateGameTabOpt, K_XSTARTPOS, fYPos, K_WINDOWWIDTH, K_HSIZE_UNDER_TABWINDOW, self));
    m_pCreateTabOptions.InitOptionsTab();

///////////////////    
    m_pCreateTabKit = R6MenuMPCreateGameTabKitRest(CreateWindow(class'R6MenuMPCreateGameTabKitRest', K_XSTARTPOS, fYPos, K_WINDOWWIDTH, K_HSIZE_UNDER_TABWINDOW, self));
    m_pCreateTabKit.InitKitTab();
    m_pCreateTabKit.HideWindow();

///////////////////    
	m_pCreateTabAdvOptions = R6MenuMPCreateGameTabAdvOptions(CreateWindow(Root.MenuClassDefines.ClassMPCreateGameTabAdvOpt, K_XSTARTPOS, fYPos, K_WINDOWWIDTH, K_HSIZE_UNDER_TABWINDOW, self));
    m_pCreateTabAdvOptions.InitAdvOptionsTab();
    m_pCreateTabAdvOptions.HideWindow();
    
///////////////////    

	m_pCreateTabOptions.AddLinkWindow(m_pCreateTabKit);
	m_pCreateTabOptions.AddLinkWindow(m_pCreateTabAdvOptions);

	m_pCreateTabKit.AddLinkWindow(m_pCreateTabOptions);
	m_pCreateTabKit.AddLinkWindow(m_pCreateTabAdvOptions);

	m_pCreateTabAdvOptions.AddLinkWindow(m_pCreateTabKit);
	m_pCreateTabAdvOptions.AddLinkWindow(m_pCreateTabOptions);

    // choose the one to display
    m_pCreateTabWindow = m_pCreateTabOptions;
}


//*********************************
//    END OF INIT CREATE FUNCTION
//*********************************

function Notify(UWindowDialogControl C, byte E)
{ 
    if( E == DE_Click )
    {
        switch(C)
        {
        case m_ButtonMainMenu:
            Root.ChangeCurrentWidget(MainMenuWidgetID);
            break;
        case m_ButtonOptions:
            Root.ChangeCurrentWidget(OptionsWidgetID);
            break;    
        }
    }    
}

defaultproperties
{
}
