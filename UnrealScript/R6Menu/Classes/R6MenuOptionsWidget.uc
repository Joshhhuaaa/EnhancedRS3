//=============================================================================
//  R6MenuOptionsWidget.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOptionsWidget extends R6MenuWidget;

enum eOptionsWindow
{
	OW_Game,
    OW_Sound,
    OW_Graphic,
    OW_Hud,
    OW_Multiplayer,
    OW_Controls,
	OW_MOD,
	OW_PatchService
};

struct stOptionsPage
{
    var UWindowWindow pOptionsPage;
    var R6WindowButtonOptions pAssociateButton;
    var string szPageTitle;
    var R6MenuOptionsWidget.eOptionsWindow ePageID;
};

var R6MenuOptionsWidget.eOptionsWindow m_eCurrentPageDisplay;


// Parameters for option window (where you can change options)
const C_fXSTARTPOS                     = 198;                   // the x start pos of option window
const C_fYSTARTPOS                     = 101;                   // the y start pos of option window
const C_fWINDOWWIDTH                   = 422;                   // the size of option window 
const C_fWINDOWHEIGHT                  = 321;                   // the height of option window 
const C_fHEIGHT_OF_LABELW              = 30;                    // the height of the label window over option window  
const C_iARBITRARY_COUNTER			   = 10;					// this is an arbitary const for popup counter

var R6WindowTextLabelCurved           m_pOptionsTextLabel;      // the text label of the window option   
var R6WindowTextLabel			      m_LMenuTitle;             // the title

var R6WindowSimpleFramedWindowExt     m_pOptionsBorder;         // the border of the option window

var R6MenuHelpWindow                  m_pHelpWindow;            // the help window (tooltip)

var R6WindowButtonOptions	          m_ButtonReturn;

var R6WindowButtonOptions             m_ButtonGame;
var R6WindowButtonOptions             m_ButtonSound;
var R6WindowButtonOptions             m_ButtonGraphic;
var R6WindowButtonOptions             m_ButtonHudFilter;
var R6WindowButtonOptions             m_ButtonMultiPlayer;
var R6WindowButtonOptions             m_ButtonControls;
var	R6WindowButtonOptions			  m_ButtonMODS;
var	R6WindowButtonOptions			  m_ButtonPatchService;

var BOOL							  m_bInGame;
//#endif

var String							  m_sDisplayLOGO;
var Font							  m_SmallButtonFont;

var array<stOptionsPage> m_AListOptionsPages;

function Created()
{
#ifndefSPDEMO
    if (R6MenuInGameMultiPlayerRootWindow(Root) != None ||
        R6MenuInGameRootWindow(Root) != None) 
#endif
#ifdefSPDEMO
    if (R6MenuInGameRootWindow(Root) != None) 
#endif
	{
		m_bInGame = true;
	}

	GetRegistryKey("SOFTWARE\\Red Storm Entertainment\\RAVENSHIELD", "DisplayLOGO", m_sDisplayLOGO);

    InitTitle();
	InitOptionsButtons();
    InitOptionsWindow();

    // create the help window
    m_pHelpWindow = R6MenuHelpWindow(CreateWindow(class'R6MenuHelpWindow', 150, 429, 340, 42, self)); //std param is set in help window    
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Root.PaintBackground( C, self);

	if (m_ButtonGraphic.m_bSelected)
	{
		C.Style = ERenderStyle.STY_Alpha;
		if (m_sDisplayLOGO ~= "New")
		// Draw New LOGO
		DrawStretchedTextureSegment( C, 544, 436, 64, 64,
									0, 0, 64, 64, Texture'R6MenuTextures.R6armpatch');
		else if (m_sDisplayLOGO ~= "None");
			// Draw Nothing
		else
			// Draw ATI LOGO
			DrawStretchedTextureSegment( C, 544, 436, 64, 64,
			0, 0, 64, 64, Texture'R6MenuTextures.ATI_Menus');
	}
}

function ShowWindow()
{
	// randomly update the background texture
	Root.SetLoadRandomBackgroundImage("Option");

	if (!m_bInGame)
	{
		m_ButtonMODS.bDisabled = (R6MenuRootWindow(Root).IsInsidePlanning() || (R6Console(Root.console).m_bStartedByGSClient)); // inside Intel/gear/planning/ menu
		if(m_ButtonMODS.bDisabled && m_eCurrentPageDisplay == OW_MOD)
			ManageOptionsSelection(eOptionsWindow.OW_Game); // go on game options, m_pOptionsMODS was desactivate
	}

	Super.ShowWindow();
}

function HideWindow()
{
	Super.HideWindow();

	// CLOSE THE R6WINDOWCOMBO CONTROL ON THE SCREEN, the focus is not loose when the window is hide
	// because the ListBox of the R6WindowComboControl is create from the root. Need to find a better solution
	Root.ActivateWindow(0, False); 
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) 
{
    m_pHelpWindow.ToolTip(strTip);
}

function ManageOptionsSelection(int _OptionsChoice)
{
    local R6MenuOptionsWidget.eOptionsWindow eCurrentPageDisplay;
    local int i;

    eCurrentPageDisplay = m_eCurrentPageDisplay;

    for(i = 0; i < m_AListOptionsPages.Length; i++)
    {
        m_AListOptionsPages[i].pAssociateButton.m_bSelected = false;
        if(int(m_AListOptionsPages[i].ePageID) == int(m_eCurrentPageDisplay))
        {
            m_AListOptionsPages[i].pOptionsPage.HideWindow();
        }
        if(int(m_AListOptionsPages[i].ePageID) == _OptionsChoice)
        {
            m_AListOptionsPages[i].pAssociateButton.m_bSelected = true;
            eCurrentPageDisplay = m_AListOptionsPages[i].ePageID;
            if(m_pOptionsTextLabel != none)
            {
                m_pOptionsTextLabel.SetNewText(m_AListOptionsPages[i].szPageTitle, true);
            }
            m_AListOptionsPages[i].pOptionsPage.ShowWindow();
        }
    }
    m_eCurrentPageDisplay = eCurrentPageDisplay;
}

//=============================================================================================
// UpdateOptions: Update the options that's are not change directly in R6MenuOptionsTab
//=============================================================================================
function UpdateOptions()
{
    local int i;
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();

    for(i = 0; i < m_AListOptionsPages.Length; i++)
    {
        R6MenuOptionsTab(m_AListOptionsPages[i].pOptionsPage).UpdateOptionsInEngine();
    }
    pGameOptions.m_bChangeResolution = m_bInGame && !Root.m_bWidgetResolutionFix;
    pGameOptions.SaveConfig();
    GetPlayerOwner().SetSoundOptions();
    GetPlayerOwner().UpdateOptions();
    if(m_bInGame)
    {
        R6HUD(GetPlayerOwner().myHUD).UpdateHudFilter();
        R6PlayerController(GetPlayerOwner()).UpdateTriggerLagInfo();
        if(!Root.m_bWidgetResolutionFix)
        {
            Root.SetResolution(float(pGameOptions.R6ScreenSizeX), float(pGameOptions.R6ScreenSizeY));
        }
    }
}

//=============================================================================================
// RefreshOptions: Refresh the options only when this window is activated
//=============================================================================================
function RefreshOptions()
{
    local int i;
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();

    for(i = 0; i < m_AListOptionsPages.Length; i++)
    {
        R6MenuOptionsTab(m_AListOptionsPages[i].pOptionsPage).UpdateOptionsInPage();
    }
}


//===========================================================================================
// MenuLoadProfile: A new profiles is load, refresh the options
//===========================================================================================
function MenuOptionsLoadProfile()
{
	RefreshOptions();
	UpdateOptions();
}








//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitTitle()
{
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 18, WinWidth - 8, 25, self));
	m_LMenuTitle.Text           = Localize("Options","Title","R6Menu");
	m_LMenuTitle.Align          = TA_Right;
	m_LMenuTitle.m_Font         = Root.Fonts[F_MenuMainTitle];	
	m_LMenuTitle.m_BGTexture    = None;
    m_LMenuTitle.m_bDrawBorders = False;
}

function InitOptionsWindow()
{
    class'Actor'.static.GetGameOptions().m_bChangeResolution = m_bInGame;
    m_pOptionsTextLabel = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 198.0, (101.0 - float(30)) + float(1), 422.0, 30.0, self));
    m_pOptionsTextLabel.bAlwaysBehind = true;
    m_pOptionsTextLabel.Align = TA_Center;
    m_pOptionsTextLabel.m_Font = Root.Fonts[5];
    m_pOptionsBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 198.0, 101.0, 422.0, 321.0, self));
    m_pOptionsBorder.bAlwaysBehind = true;
    m_pOptionsBorder.ActiveBorder(0, false);
    m_pOptionsBorder.SetBorderParam(1, 7.0, 0.0, 1.0, Root.Colors.White);
    m_pOptionsBorder.SetBorderParam(2, 1.0, 1.0, 1.0, Root.Colors.White);
    m_pOptionsBorder.SetBorderParam(3, 1.0, 1.0, 1.0, Root.Colors.White);
    m_pOptionsBorder.m_eCornerType = Bottom_Corners;
    m_pOptionsBorder.SetCornerColor(2, Root.Colors.White);
    m_pOptionsBorder.ActiveBackGround(true, Root.Colors.Black);
    CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsGame, m_ButtonGame, OW_Game, Localize("Options", "ButtonGame", "R6Menu"));
    CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsSound, m_ButtonSound, OW_Sound, Localize("Options", "ButtonSound", "R6Menu"));
    CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsGraphic, m_ButtonGraphic, OW_Graphic, Localize("Options", "ButtonGraphic", "R6Menu"));
    CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsHud, m_ButtonHudFilter, OW_Hud, Localize("Options", "ButtonHud", "R6Menu"));
    CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsMulti, m_ButtonMultiPlayer, OW_Multiplayer, Localize("Options", "ButtonMultiPlayer", "R6Menu"));
    CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsControls, m_ButtonControls, OW_Controls, Localize("Options", "ButtonControls", "R6Menu"));
    CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsMOD, m_ButtonMODS, OW_MOD, Localize("Options", "ButtonCustomGame", "R6Menu"));
    CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsPatchService, m_ButtonPatchService, OW_PatchService, Localize("Options", "ButtonPatchService", "R6Menu"));
    ManageOptionsSelection(eOptionsWindow.OW_Game);
}

function CreateAndAddPageOptionsToList(Class<UWindowWindow> _PageToCreate, R6WindowButtonOptions _pAssociateButton, R6MenuOptionsWidget.eOptionsWindow _ePageID, string _szTitle)
{
    local R6MenuOptionsTab NewOptionsPage;
    local stOptionsPage NewItem;

    NewOptionsPage = R6MenuOptionsTab(CreateWindow(_PageToCreate, 198.0 + m_pOptionsBorder.m_fVBorderOffset, 101.0, 422.0 - (float(2) * m_pOptionsBorder.m_fVBorderOffset), 321.0, self));
    NewOptionsPage.InitPageOptions();
    NewOptionsPage.HideWindow();
    NewItem.pOptionsPage = NewOptionsPage;
    NewItem.pAssociateButton = _pAssociateButton;
    NewItem.ePageID = _ePageID;
    NewItem.szPageTitle = _szTitle;
    m_AListOptionsPages[m_AListOptionsPages.Length] = NewItem;
}

function InitOptionsButtons()
{
    local Font ButtonFont;
    local float fXOffset, fYOffset, fWidth, fHeight, fYPos;

    ButtonFont = Root.Fonts[16];
    m_SmallButtonFont = Root.Fonts[5];
    m_ButtonReturn = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', 10.0, 425.0, 250.0, 25.0, self));
    m_ButtonReturn.ToolTipString = Localize("Tip", "ButtonReturn", "R6Menu");
    m_ButtonReturn.Text = Localize("Options", "ButtonReturn", "R6Menu");
    m_ButtonReturn.m_eButton_Action = Button_Return;
    m_ButtonReturn.Align = TA_Left;
    m_ButtonReturn.m_buttonFont = ButtonFont;
    m_ButtonReturn.CheckToDownSizeFont(Root.Fonts[6], 0.0);
    m_ButtonReturn.ResizeToText();
    fXOffset = 10.0;
    fYPos = 64.0;
    fYOffset = 26.0;
    fWidth = 189.0;
    fHeight = 25.0;
    m_ButtonGame = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonGame.ToolTipString = Localize("Tip", "ButtonGame", "R6Menu");
    m_ButtonGame.Text = Localize("Options", "ButtonGame", "R6Menu");
    m_ButtonGame.m_eButton_Action = Button_Game;
    m_ButtonGame.Align = TA_Left;
    m_ButtonGame.m_buttonFont = ButtonFont;
    m_ButtonGame.CheckToDownSizeFont(m_SmallButtonFont, 0.0);
    m_ButtonGame.ResizeToText();
    m_ButtonGame.m_bSelected = true;
    fYPos += fYOffset;
    m_ButtonSound = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonSound.ToolTipString = Localize("Tip", "ButtonSound", "R6Menu");
    m_ButtonSound.Text = Localize("Options", "ButtonSound", "R6Menu");
    m_ButtonSound.m_eButton_Action = Button_Sound;
    m_ButtonSound.Align = TA_Left;
    m_ButtonSound.m_buttonFont = ButtonFont;
    m_ButtonSound.CheckToDownSizeFont(m_SmallButtonFont, 0.0);
    m_ButtonSound.ResizeToText();
    fYPos += fYOffset;
    m_ButtonGraphic = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonGraphic.ToolTipString = Localize("Tip", "ButtonGraphic", "R6Menu");
    m_ButtonGraphic.Text = Localize("Options", "ButtonGraphic", "R6Menu");
    m_ButtonGraphic.m_eButton_Action = Button_Graphic;
    m_ButtonGraphic.Align = TA_Left;
    m_ButtonGraphic.m_buttonFont = ButtonFont;
    m_ButtonGraphic.CheckToDownSizeFont(m_SmallButtonFont, 0.0);
    m_ButtonGraphic.ResizeToText();
    fYPos += fYOffset;
    m_ButtonHudFilter = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonHudFilter.ToolTipString = Localize("Tip", "ButtonHud", "R6Menu");
    m_ButtonHudFilter.Text = Localize("Options", "ButtonHud", "R6Menu");
    m_ButtonHudFilter.m_eButton_Action = Button_Hud;
    m_ButtonHudFilter.Align = TA_Left;
    m_ButtonHudFilter.m_buttonFont = ButtonFont;
    m_ButtonHudFilter.CheckToDownSizeFont(m_SmallButtonFont, 0.0);
    m_ButtonHudFilter.ResizeToText();
    fYPos += fYOffset;
    m_ButtonMultiPlayer = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonMultiPlayer.ToolTipString = Localize("Tip", "ButtonMultiPlayer", "R6Menu");
    m_ButtonMultiPlayer.Text = Localize("Options", "ButtonMultiPlayer", "R6Menu");
    m_ButtonMultiPlayer.m_eButton_Action = Button_Multiplayer;
    m_ButtonMultiPlayer.Align = TA_Left;
    m_ButtonMultiPlayer.m_buttonFont = ButtonFont;
    m_ButtonMultiPlayer.CheckToDownSizeFont(m_SmallButtonFont, 0.0);
    m_ButtonMultiPlayer.ResizeToText();
    fYPos += fYOffset;
    m_ButtonControls = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonControls.ToolTipString = Localize("Tip", "ButtonControls", "R6Menu");
    m_ButtonControls.Text = Localize("Options", "ButtonControls", "R6Menu");
    m_ButtonControls.m_eButton_Action = Button_Controls;
    m_ButtonControls.Align = TA_Left;
    m_ButtonControls.m_buttonFont = ButtonFont;
    m_ButtonControls.CheckToDownSizeFont(m_SmallButtonFont, 0.0);
    m_ButtonControls.ResizeToText();
    fYPos += fYOffset;
    m_ButtonMODS = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonMODS.ToolTipString = Localize("Tip", "ButtonCustomGame", "R6Menu");
    m_ButtonMODS.Text = Localize("Options", "ButtonCustomGame", "R6Menu");
    m_ButtonMODS.m_eButton_Action = Button_MODS;
    m_ButtonMODS.Align = TA_Left;
    m_ButtonMODS.m_buttonFont = ButtonFont;
    m_ButtonMODS.CheckToDownSizeFont(m_SmallButtonFont, 0.0);
    m_ButtonMODS.ResizeToText();
    m_ButtonMODS.bDisabled = m_bInGame;
    fYPos += fYOffset;
    m_ButtonPatchService = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonPatchService.ToolTipString = Localize("Tip", "ButtonPatchService", "R6Menu");
    m_ButtonPatchService.Text = Localize("Options", "ButtonPatchService", "R6Menu");
    m_ButtonPatchService.m_eButton_Action = Button_PatchService;
    m_ButtonPatchService.Align = TA_Left;
    m_ButtonPatchService.m_buttonFont = ButtonFont;
    m_ButtonPatchService.CheckToDownSizeFont(m_SmallButtonFont, 0.0);
    m_ButtonPatchService.ResizeToText();
    ResizeAllOptionsButtons();
}

function ResizeAllOptionsButtons()
{
    if(((((((m_ButtonGame.IsFontDownSizingNeeded() || m_ButtonSound.IsFontDownSizingNeeded()) || m_ButtonGraphic.IsFontDownSizingNeeded()) || m_ButtonHudFilter.IsFontDownSizingNeeded()) || m_ButtonMultiPlayer.IsFontDownSizingNeeded()) || m_ButtonControls.IsFontDownSizingNeeded()) || m_ButtonMODS.IsFontDownSizingNeeded()) || m_ButtonPatchService.IsFontDownSizingNeeded())
    {
        m_ButtonGame.m_buttonFont = m_SmallButtonFont;
        m_ButtonSound.m_buttonFont = m_SmallButtonFont;
        m_ButtonGraphic.m_buttonFont = m_SmallButtonFont;
        m_ButtonHudFilter.m_buttonFont = m_SmallButtonFont;
        m_ButtonMultiPlayer.m_buttonFont = m_SmallButtonFont;
        m_ButtonControls.m_buttonFont = m_SmallButtonFont;
        m_ButtonMODS.m_buttonFont = m_SmallButtonFont;
        m_ButtonPatchService.m_buttonFont = m_SmallButtonFont;
        m_ButtonGame.ResizeToText();
        m_ButtonSound.ResizeToText();
        m_ButtonGraphic.ResizeToText();
        m_ButtonHudFilter.ResizeToText();
        m_ButtonMultiPlayer.ResizeToText();
        m_ButtonControls.ResizeToText();
        m_ButtonMODS.ResizeToText();
        m_ButtonPatchService.ResizeToText();
    }
}

defaultproperties
{
}
