class R6MenuOptionsHud extends R6MenuOptionsTab;

// OPTION HUD FILTERS
var R6WindowButtonBox                   m_pHudWeaponName;

var R6WindowButtonBox                   m_pHudShowFPWeapon;

var R6WindowButtonBox                   m_pHudOtherTInfo;

var R6WindowButtonBox                   m_pHudCurTInfo;

var R6WindowButtonBox                   m_pHudCircumIcon;

var R6WindowButtonBox                   m_pHudWpInfo;

var R6WindowButtonBox                   m_pHudReticule;

var R6WindowButtonBox                   m_pHudShowTNames;

var R6WindowButtonBox                   m_pHudCharInfo;

var R6WindowButtonBox                   m_pHudShowRadar;

var R6WindowBitMap						m_pHudBGTex;

var R6WindowBitMap						m_pHudWeaponNameTex;

var R6WindowBitMap						m_pHudShowFPWeaponTex;

var R6WindowBitMap						m_pHudOtherTInfoTex;

var R6WindowBitMap						m_pHudCurTInfoTex;

var R6WindowBitMap						m_pHudCircumIconTex;

var R6WindowBitMap						m_pHudWpInfoTex;

var R6WindowBitMap						m_pHudReticuleTex;

var R6WindowBitMap						m_pHudCharInfoTex;	

var R6WindowBitMap						m_pHudShowTNamesTex;

var R6WindowBitMap						m_pHudShowRadarTex;

function InitPageOptions()
{
    local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
	    fSizeOfCounter;

    local Font ButtonFont;

    ButtonFont = Root.Fonts[5];
    fXOffset = 5.0;
    fYOffset = 5.0;
    fWidth = (WinWidth * 0.5) - (float(2) * fXOffset);
    fHeight = 15.0;
    fYStep = 17.0;
    m_pHudWeaponName = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudWeaponName.SetButtonBox(true);
    m_pHudWeaponName.CreateTextAndBox(Localize("Options", "Opt_HudWeapon", "R6Menu"), Localize("Tip", "Opt_HudWeapon", "R6Menu"), 0.0, 0);
    fYOffset += fYStep;
    m_pHudShowFPWeapon = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudShowFPWeapon.SetButtonBox(false);
    m_pHudShowFPWeapon.CreateTextAndBox(Localize("Options", "Opt_HudShowFPWeapon", "R6Menu"), Localize("Tip", "Opt_HudShowFPWeapon", "R6Menu"), 0.0, 1);
    fYOffset += fYStep;
    m_pHudOtherTInfo = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudOtherTInfo.SetButtonBox(true);
    m_pHudOtherTInfo.CreateTextAndBox(Localize("Options", "Opt_HudOtherTInfo", "R6Menu"), Localize("Tip", "Opt_HudOtherTInfo", "R6Menu"), 0.0, 2);
    fYOffset += fYStep;
    m_pHudCurTInfo = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudCurTInfo.SetButtonBox(true);
    m_pHudCurTInfo.CreateTextAndBox(Localize("Options", "Opt_HudCurTInfo", "R6Menu"), Localize("Tip", "Opt_HudCurTInfo", "R6Menu"), 0.0, 3);
    fYOffset += fYStep;
    m_pHudCircumIcon = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudCircumIcon.SetButtonBox(true);
    m_pHudCircumIcon.CreateTextAndBox(Localize("Options", "Opt_HudCircumIcon", "R6Menu"), Localize("Tip", "Opt_HudCircumIcon", "R6Menu"), 0.0, 4);
    fXOffset = (WinWidth * 0.5) + fXOffset;
    fYOffset = 5.0;
    m_pHudWpInfo = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudWpInfo.SetButtonBox(true);
    m_pHudWpInfo.CreateTextAndBox(Localize("Options", "Opt_HudWPInfo", "R6Menu"), Localize("Tip", "Opt_HudWPInfo", "R6Menu"), 0.0, 5);
    fYOffset += fYStep;
    m_pHudReticule = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudReticule.SetButtonBox(true);
    m_pHudReticule.CreateTextAndBox(Localize("Options", "Opt_HudCrossHair", "R6Menu"), Localize("Tip", "Opt_HudCrossHair", "R6Menu"), 0.0, 6);
    fYOffset += fYStep;
    m_pHudShowTNames = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudShowTNames.SetButtonBox(true);
    m_pHudShowTNames.CreateTextAndBox(Localize("Options", "Opt_HudShowTNames", "R6Menu"), Localize("Tip", "Opt_HudShowTNames", "R6Menu"), 0.0, 7);
    fYOffset += fYStep;
    m_pHudCharInfo = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudCharInfo.SetButtonBox(true);
    m_pHudCharInfo.CreateTextAndBox(Localize("Options", "Opt_HudCharInfo", "R6Menu"), Localize("Tip", "Opt_HudCharInfo", "R6Menu"), 0.0, 8);
    fYOffset += fYStep;
    m_pHudShowRadar = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudShowRadar.SetButtonBox(true);
    m_pHudShowRadar.CreateTextAndBox(Localize("Options", "Opt_HudShowRadar", "R6Menu"), Localize("Tip", "Opt_HudShowRadar", "R6Menu"), 0.0, 9);
    CreateHudOptionsTex();
    InitResetButton();
    UpdateOptionsInPage();
    m_bInitComplete = true;
}

function UpdateOptionsInEngine()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.HUDShowWeaponInfo = m_pHudWeaponName.m_bSelected;
    pGameOptions.HUDShowFPWeapon = m_pHudShowFPWeapon.m_bSelected;
    pGameOptions.HUDShowOtherTeamInfo = m_pHudOtherTInfo.m_bSelected;
    pGameOptions.HUDShowCurrentTeamInfo = m_pHudCurTInfo.m_bSelected;
    pGameOptions.HUDShowActionIcon = m_pHudCircumIcon.m_bSelected;
    pGameOptions.HUDShowWaypointInfo = m_pHudWpInfo.m_bSelected;
    pGameOptions.HUDShowReticule = m_pHudReticule.m_bSelected;
    pGameOptions.HUDShowCharacterInfo = m_pHudCharInfo.m_bSelected;
    pGameOptions.HUDShowPlayersName = m_pHudShowTNames.m_bSelected;
    pGameOptions.ShowRadar = m_pHudShowRadar.m_bSelected;
    UpdateHudOptionsTex();
}

function UpdateOptionsInPage()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    m_pHudWeaponName.SetButtonBox(pGameOptions.HUDShowWeaponInfo);
    m_pHudShowFPWeapon.SetButtonBox(pGameOptions.HUDShowFPWeapon);
    m_pHudOtherTInfo.SetButtonBox(pGameOptions.HUDShowOtherTeamInfo);
    m_pHudCurTInfo.SetButtonBox(pGameOptions.HUDShowCurrentTeamInfo);
    m_pHudCircumIcon.SetButtonBox(pGameOptions.HUDShowActionIcon);
    m_pHudWpInfo.SetButtonBox(pGameOptions.HUDShowWaypointInfo);
    m_pHudReticule.SetButtonBox(pGameOptions.HUDShowReticule);
    m_pHudCharInfo.SetButtonBox(pGameOptions.HUDShowCharacterInfo);
    m_pHudShowTNames.SetButtonBox(pGameOptions.HUDShowPlayersName);
    m_pHudShowRadar.SetButtonBox(pGameOptions.ShowRadar);
    UpdateHudOptionsTex();
}

function CreateHudOptionsTex()
{
	m_pHudBGTex				= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayBackground', true);
	m_pHudBGTex.bAlwaysBehind  = true;
	m_pHudBGTex.m_BorderColor  = Root.Colors.White;

	m_pHudWeaponNameTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayWeaponInfo');
	m_pHudShowFPWeaponTex	= CreateHudBitmapWindow( Texture'R6MenuTextures.Display1stPersonWeapon');
	m_pHudOtherTInfoTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayOtherTeamInfo');
	m_pHudCurTInfoTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayCurrentTeamInfo');
	m_pHudCircumIconTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayActionIcon');
	m_pHudWpInfoTex			= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayWaypointInfo');
	m_pHudReticuleTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayReticule');
	m_pHudCharInfoTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayCharacterInfo');
	m_pHudShowTNamesTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayTeammateNames');
	m_pHudShowRadarTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayMPRadar');
}

function R6WindowBitMap CreateHudBitmapWindow( Texture _Tex, optional BOOL _bDrawSimpleBorder)
{
	local R6WindowBitMap _NewR6WindowBitMap;

	_NewR6WindowBitMap   = R6WindowBitMap(CreateWindow(class'R6WindowBitMap', 77, 96, 262, 198, self));
	_NewR6WindowBitMap.T = _Tex;
	_NewR6WindowBitMap.R = NewRegion( 0, 0, 260, 196);
	_NewR6WindowBitMap.m_iDrawStyle  = ERenderStyle.STY_Alpha;
	_NewR6WindowBitMap.m_bDrawBorder = _bDrawSimpleBorder;
	_NewR6WindowBitMap.m_ImageX = 1;
	_NewR6WindowBitMap.m_ImageY = 1;

	return _NewR6WindowBitMap;
}

function UpdateHudOptionsTex()
{
	m_pHudWeaponNameTex.HideWindow();
	m_pHudShowFPWeaponTex.HideWindow(); 
	m_pHudOtherTInfoTex.HideWindow();	
	m_pHudCurTInfoTex.HideWindow();	
	m_pHudCircumIconTex.HideWindow();	
	m_pHudWpInfoTex.HideWindow();		
	m_pHudReticuleTex.HideWindow();	
	m_pHudCharInfoTex.HideWindow();	
	m_pHudShowTNamesTex.HideWindow();	
	m_pHudShowRadarTex.HideWindow();

	if (m_pHudWeaponName.m_bSelected)
		m_pHudWeaponNameTex.ShowWindow();

	if (m_pHudShowTNames.m_bSelected)
		m_pHudShowTNamesTex.ShowWindow();

	if (m_pHudShowFPWeapon.m_bSelected)
		m_pHudShowFPWeaponTex.ShowWindow();

	if (m_pHudOtherTInfo.m_bSelected)
		m_pHudOtherTInfoTex.ShowWindow();

	if (m_pHudCurTInfo.m_bSelected)
		m_pHudCurTInfoTex.ShowWindow();

	if (m_pHudCircumIcon.m_bSelected)
		m_pHudCircumIconTex.ShowWindow();

	if (m_pHudWpInfo.m_bSelected)
		m_pHudWpInfoTex.ShowWindow();

	if (m_pHudReticule.m_bSelected)
		m_pHudReticuleTex.ShowWindow();

	if (m_pHudCharInfo.m_bSelected)
		m_pHudCharInfoTex.ShowWindow();

	if (m_pHudShowRadar.m_bSelected)
		m_pHudShowRadarTex.ShowWindow();

}

function RestoreDefaultValue()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.ResetHudToDefault();
    UpdateOptionsInPage();
}

function Notify(UWindowDialogControl C, byte E)
{
    local R6MenuOptionsWidget OptionsWidget;
    local bool bUpdateGameOptions;
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    OptionsWidget = R6MenuOptionsWidget(OwnerWindow);
    if(E == DE_Click)
    {
        if(C.IsA('R6WindowButtonBox'))
        {
            if(R6WindowButtonBox(C).GetSelectStatus())
            {
                R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected;
                bUpdateGameOptions = true;
            }            
        }
        else
        {
            if(C.IsA('R6WindowButton'))
            {
                if(C == m_pGeneralButUse)
                {
                    Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), EPopUpID_OptionsResetDefault, 0, false, self);
                }
            }
        }
    }
    if(bUpdateGameOptions)
    {
        UpdateOptionsInEngine();
        pGameOptions.SaveConfig();
    }
}
