//=============================================================================
//  R6MenuMPRestKitSub.uc : Restriction kit tab menus
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/20/6  * Create by John Bennett
//=============================================================================
class R6MenuMPRestKitSub extends UWindowDialogClientWindow;

const K_HALFWINDOWWIDTH                 = 310;                    // the half size of window LAN SERVER INFO and GameMode see K_WINDOWWIDTH in MenuMultiplyerWidget
const K_X_BORDER_OFF                    = 5;
const K_BOX_HEIGHT                      = 16;
const K_MAX_WINDOWBUTTONBOX             = 20;
const K_Y_LIST_OFF                      = 23;
const K_Y_BUTTON_OFF                    = 4;
const K_X_BUTTON_OFF                    = 30;


var   Array<class>  m_ASubMachineGuns;       
var   Array<class>  m_AShotguns;       
var   Array<class>  m_AAssaultRifle;       
var   Array<class>  m_AMachineGuns;       
var   Array<class>  m_ASniperRifle;       
var   Array<class>  m_APistol;       
var   Array<class>  m_AMachinePistol;       
var   Array<class>  m_APriWpnGadget;       
var   Array<class>  m_ASecWpnGadget;     
var   Array<class>  m_AMiscGadget;     

var   Array<BYTE>	m_ASelected;

var R6WindowButton      m_pSelectAll;
var R6WindowButton      m_pUnSelectAll;

var R6WindowButtonBox   m_pSubMachineGuns[K_MAX_WINDOWBUTTONBOX];   // Sub machine guns
var R6WindowButtonBox   m_pShotguns[K_MAX_WINDOWBUTTONBOX];         // Shotguns
var R6WindowButtonBox   m_pAssaultRifle[K_MAX_WINDOWBUTTONBOX];     // Assault rifle
var R6WindowButtonBox   m_pMachineGuns[K_MAX_WINDOWBUTTONBOX];      // Machine guns
var R6WindowButtonBox   m_pSniperRifle[K_MAX_WINDOWBUTTONBOX];      // Sniper rifle
var R6WindowButtonBox   m_pPistol[K_MAX_WINDOWBUTTONBOX];           // Pistols
var R6WindowButtonBox   m_pMachinePistol[K_MAX_WINDOWBUTTONBOX];    // Machine pistols
var R6WindowButtonBox   m_pPriWpnGadget[K_MAX_WINDOWBUTTONBOX];     // Primary Weapon 
var R6WindowButtonBox   m_pSecWpnGadget[K_MAX_WINDOWBUTTONBOX];     // Secondary weapon
var R6WindowButtonBox   m_pMiscGadget[K_MAX_WINDOWBUTTONBOX];       // Misc

var R6WindowListRestKit	m_pRestKitButList;

var BOOL				m_bIsInGame;

function Created()
{
	// K_HALFWINDOWWIDTH - 1 for pop-up border
	m_pRestKitButList = R6WindowListRestKit(CreateWindow( class'R6WindowListRestKit', 0, K_Y_LIST_OFF, K_HALFWINDOWWIDTH - 1, WinHeight - K_Y_LIST_OFF, self));
	m_pRestKitButList.m_fXItemOffset = 5;
	m_pRestKitButList.bAlwaysBehind  = true;
}

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	// Draw a simple line over the list of buttons
	C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	DrawStretchedTextureSegment(C, 0, K_Y_LIST_OFF, K_HALFWINDOWWIDTH - 1, m_BorderTextureRegion.H,
								   m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
}

function InitSelectButtons( BOOL _bInGame)
{
    local FLOAT                         fXOffset, fYOffset, fYStep, fWidth, fHeight;
    local Font                          ButtonFont;
    local INT                           i;

	m_bIsInGame = _bInGame;

	//create buttons
	fYOffset = K_Y_BUTTON_OFF;
	fWidth   = 100;
	fXOffset = ( K_HALFWINDOWWIDTH / 2 - fWidth ) / 2;
	fHeight  = K_BOX_HEIGHT;
	ButtonFont = Root.Fonts[F_SmallTitle]; 

	m_pSelectAll = R6WindowButton(CreateControl(class'R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pSelectAll.m_vButtonColor     = Root.Colors.White;
	m_pSelectAll.SetButtonBorderColor(Root.Colors.White);
	m_pSelectAll.m_bDrawBorders     = TRUE;
	m_pSelectAll.Align  = TA_Center;
	m_pSelectAll.ImageX = 2;
	m_pSelectAll.ImageY = 2;
	m_pSelectAll.m_bDrawSimpleBorder = TRUE;
	m_pSelectAll.bStretched = TRUE;
	m_pSelectAll.SetText( Localize("MPCreateGame","Kit_SelectAll","R6Menu"));//Localize("MultiPlayer","PopUp_CrAcct","R6Menu") );
	m_pSelectAll.SetFont(F_Normal);
	m_pSelectAll.TextColor          = Root.Colors.White;	
    m_pSelectAll.ToolTipString = Localize("Tip","Kit_SelectAll","R6Menu");

	fXOffset = K_HALFWINDOWWIDTH / 2 + ( K_HALFWINDOWWIDTH / 2 - fWidth ) / 2;

	m_pUnSelectAll = R6WindowButton(CreateControl(class'R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pUnSelectAll.m_vButtonColor     = Root.Colors.White;
	m_pUnSelectAll.SetButtonBorderColor(Root.Colors.White);
	m_pUnSelectAll.m_bDrawBorders     = TRUE;
	m_pUnSelectAll.Align  = TA_Center;
	m_pUnSelectAll.ImageX = 2;
	m_pUnSelectAll.ImageY = 2;
	m_pUnSelectAll.m_bDrawSimpleBorder = TRUE;
	m_pUnSelectAll.bStretched = TRUE;
	m_pUnSelectAll.SetText( Localize("MPCreateGame","Kit_UnselectAll","R6Menu") );//Localize("MultiPlayer","PopUp_CrAcct","R6Menu") );
	m_pUnSelectAll.SetFont(F_Normal);
	m_pUnSelectAll.TextColor          = Root.Colors.White;	
    m_pUnSelectAll.ToolTipString = Localize("Tip","Kit_UnselectAll","R6Menu");
}

//=================================================================================================
//========================= SUB MACHINES GUNS =====================================================
//=================================================================================================
function InitSubMachineGunsTab( R6GameReplicationInfo _pR6GameRepInfo)
{
	local INT i;
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_ASubMachineGuns.remove( 0, m_ASubMachineGuns.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert All sub machine guns
	if (_pR6GameRepInfo == None)
		m_ASubMachineGuns = GetRestrictionKit( class'R6SubGunDescription', pServerOptions.RestrictedSubMachineGuns, _pR6GameRepInfo);
	else
		m_ASubMachineGuns = GetRestrictionKit( class'R6SubGunDescription', pServerOptions.RestrictedSubMachineGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szSubMachineGunsRes);

	CreateRestKitButtons( m_ASubMachineGuns, m_ASelected, "R6Weapons", m_pSubMachineGuns);

    // Clear remainder of list

    for ( i = m_ASubMachineGuns.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pSubMachineGuns[i] = None;
}

function UpdateSubMachineGunsTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_ASubMachineGuns = GetRestrictionKit( class'R6SubGunDescription', pServerOptions.RestrictedSubMachineGuns, _pR6GameRepInfo);
	else
		m_ASubMachineGuns = GetRestrictionKit( class'R6SubGunDescription', pServerOptions.RestrictedSubMachineGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szSubMachineGunsRes);

	UpdateRestKitButtonSel( m_ASelected, m_pSubMachineGuns);
}

//=================================================================================================
//========================= SHOT GUNS =====================================================
//=================================================================================================
function InitShotGunsTab( R6GameReplicationInfo _pR6GameRepInfo)
{
	local INT i;
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_AShotguns.remove( 0, m_AShotguns.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all shotguns
	if (_pR6GameRepInfo == None)
		m_AShotguns = GetRestrictionKit( class'R6ShotgunDescription', pServerOptions.RestrictedShotGuns, _pR6GameRepInfo);
	else
		m_AShotguns = GetRestrictionKit( class'R6ShotgunDescription', pServerOptions.RestrictedShotGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szShotGunRes);

	CreateRestKitButtons( m_AShotguns, m_ASelected, "R6Weapons", m_pShotguns);

    // Clear remainder of list

    for ( i = m_AShotguns.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pShotguns[i] = None;
}

function UpdateShotGunsTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_AShotguns = GetRestrictionKit( class'R6ShotgunDescription', pServerOptions.RestrictedShotGuns, _pR6GameRepInfo);
	else
		m_AShotguns = GetRestrictionKit( class'R6ShotgunDescription', pServerOptions.RestrictedShotGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szShotGunRes);

	UpdateRestKitButtonSel( m_ASelected, m_pShotguns);
}

//=================================================================================================
//========================= ASSAULT RIFLES =====================================================
//=================================================================================================
function InitAssaultRifleTab( R6GameReplicationInfo _pR6GameRepInfo)
{
	local INT i;
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_AAssaultRifle.remove( 0, m_AAssaultRifle.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all assault
	if (_pR6GameRepInfo == None)
		m_AAssaultRifle = GetRestrictionKit( class'R6AssaultDescription', pServerOptions.RestrictedAssultRifles, _pR6GameRepInfo);
	else
		m_AAssaultRifle = GetRestrictionKit( class'R6AssaultDescription', pServerOptions.RestrictedAssultRifles, _pR6GameRepInfo, _pR6GameRepInfo.m_szAssRifleRes);

	CreateRestKitButtons( m_AAssaultRifle, m_ASelected, "R6Weapons", m_pAssaultRifle);

    // Clear remainder of list

    for ( i = m_AAssaultRifle.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pAssaultRifle[i] = None;
}

function UpdateAssaultRifleTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_AAssaultRifle = GetRestrictionKit( class'R6AssaultDescription', pServerOptions.RestrictedAssultRifles, _pR6GameRepInfo);
	else
		m_AAssaultRifle = GetRestrictionKit( class'R6AssaultDescription', pServerOptions.RestrictedAssultRifles, _pR6GameRepInfo, _pR6GameRepInfo.m_szAssRifleRes);

	UpdateRestKitButtonSel( m_ASelected, m_pAssaultRifle);
}

//=================================================================================================
//========================= MACHINE GUNS =====================================================
//=================================================================================================
function InitMachineGunsTab( R6GameReplicationInfo _pR6GameRepInfo)
{
	local INT i;
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_AMachineGuns.remove( 0, m_AMachineGuns.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all machine guns
	if (_pR6GameRepInfo == None)
		m_AMachineGuns = GetRestrictionKit( class'R6LMGDescription', pServerOptions.RestrictedMachineGuns, _pR6GameRepInfo);
	else
		m_AMachineGuns = GetRestrictionKit( class'R6LMGDescription', pServerOptions.RestrictedMachineGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szMachGunRes);

	CreateRestKitButtons( m_AMachineGuns, m_ASelected, "R6Weapons", m_pMachineGuns);

    // Clear remainder of list

    for ( i = m_AMachineGuns.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pMachineGuns[i] = None;
}

function UpdateMachineGunsTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_AMachineGuns = GetRestrictionKit( class'R6LMGDescription', pServerOptions.RestrictedMachineGuns, _pR6GameRepInfo);
	else
		m_AMachineGuns = GetRestrictionKit( class'R6LMGDescription', pServerOptions.RestrictedMachineGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szMachGunRes);

	UpdateRestKitButtonSel( m_ASelected, m_pMachineGuns);
}

//=================================================================================================
//========================= SNIPER RIFLE =====================================================
//=================================================================================================
function InitSniperRifleTab( R6GameReplicationInfo _pR6GameRepInfo)
{
	local INT i;
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_ASniperRifle.remove( 0, m_ASniperRifle.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all sniper rifle
	if (_pR6GameRepInfo == None)
		m_ASniperRifle = GetRestrictionKit( class'R6SniperDescription', pServerOptions.RestrictedSniperRifles, _pR6GameRepInfo);
	else
		m_ASniperRifle = GetRestrictionKit( class'R6SniperDescription', pServerOptions.RestrictedSniperRifles, _pR6GameRepInfo, _pR6GameRepInfo.m_szSnipRifleRes);

	CreateRestKitButtons( m_ASniperRifle, m_ASelected, "R6Weapons", m_pSniperRifle);

    // Clear remainder of list

    for ( i = m_ASniperRifle.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pSniperRifle[i] = None;
}

function UpdateSniperRifleTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_ASniperRifle = GetRestrictionKit( class'R6SniperDescription', pServerOptions.RestrictedSniperRifles, _pR6GameRepInfo);
	else
		m_ASniperRifle = GetRestrictionKit( class'R6SniperDescription', pServerOptions.RestrictedSniperRifles, _pR6GameRepInfo, _pR6GameRepInfo.m_szSnipRifleRes);

	UpdateRestKitButtonSel( m_ASelected, m_pSniperRifle);
}

//=================================================================================================
//========================= PISTOLS =====================================================
//=================================================================================================
function InitPistolTab( R6GameReplicationInfo _pR6GameRepInfo)
{
	local INT i;
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_APistol.remove( 0, m_APistol.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all pistols
	if (_pR6GameRepInfo == None)
		m_APistol = GetRestrictionKit( class'R6PistolsDescription', pServerOptions.RestrictedPistols, _pR6GameRepInfo);
	else
		m_APistol = GetRestrictionKit( class'R6PistolsDescription', pServerOptions.RestrictedPistols, _pR6GameRepInfo, _pR6GameRepInfo.m_szPistolRes);

	CreateRestKitButtons( m_APistol, m_ASelected, "R6Weapons", m_pPistol);

	// give at less one secondary weapon
	m_pPistol[0].m_bSelected = false;
	m_pPistol[0].bDisabled = true;

    // Clear remainder of list

    for ( i = m_APistol.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pPistol[i] = None;
}

function UpdatePistolsTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_APistol = GetRestrictionKit( class'R6PistolsDescription', pServerOptions.RestrictedPistols, _pR6GameRepInfo);
	else
		m_APistol = GetRestrictionKit( class'R6PistolsDescription', pServerOptions.RestrictedPistols, _pR6GameRepInfo, _pR6GameRepInfo.m_szPistolRes);

	UpdateRestKitButtonSel( m_ASelected, m_pPistol);
}

//=================================================================================================
//========================= MACHINE PISTOLS =====================================================
//=================================================================================================
function InitMachinePistolTab( R6GameReplicationInfo _pR6GameRepInfo)
{
	local INT i;
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_AMachinePistol.remove( 0, m_AMachinePistol.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all machine pistoles
	if (_pR6GameRepInfo == None)
		m_AMachinePistol = GetRestrictionKit( class'R6MachinePistolsDescription', pServerOptions.RestrictedMachinePistols, _pR6GameRepInfo);
	else
		m_AMachinePistol = GetRestrictionKit( class'R6MachinePistolsDescription', pServerOptions.RestrictedMachinePistols, _pR6GameRepInfo, _pR6GameRepInfo.m_szMachPistolRes);

	CreateRestKitButtons( m_AMachinePistol, m_ASelected, "R6Weapons", m_pMachinePistol);

    // Clear remainder of list

    for ( i = m_AMachinePistol.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pMachinePistol[i] = None;
}

function UpdateMachinePistolTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_AMachinePistol = GetRestrictionKit( class'R6MachinePistolsDescription', pServerOptions.RestrictedMachinePistols, _pR6GameRepInfo);
	else
		m_AMachinePistol = GetRestrictionKit( class'R6MachinePistolsDescription', pServerOptions.RestrictedMachinePistols, _pR6GameRepInfo, _pR6GameRepInfo.m_szMachPistolRes);

	UpdateRestKitButtonSel( m_ASelected, m_pMachinePistol);
}

//=================================================================================================
//========================= PRIMARY WEAPON GADGETS =====================================================
//=================================================================================================
function InitPriWpnGadgetTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local FLOAT                         fXOffset, fYOffset, fYStep, fWidth, fHeight;
    local Font                          ButtonFont;
    local INT                           i,j,k;
    local class<R6WeaponGadgetDescription>   DescriptionClass;
    local BOOL                          bFound; // Gadget Name ID already found in list
    local R6ServerInfo					pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_APriWpnGadget.remove( 0, m_APriWpnGadget.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all primary weapon gadget
	if (_pR6GameRepInfo == None)
		m_APriWpnGadget = GetGadgetRestrictionKit( class'R6WeaponGadgetDescription', pServerOptions.RestrictedPrimary, _pR6GameRepInfo);
	else
		m_APriWpnGadget = GetGadgetRestrictionKit( class'R6WeaponGadgetDescription', pServerOptions.RestrictedPrimary, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgPrimaryRes);

	CreateRestKitButtons( m_APriWpnGadget, m_ASelected, "R6WeaponGadgets", m_pPriWpnGadget);

    // Clear remainder of list

    for ( i = m_APriWpnGadget.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pPriWpnGadget[i] = None;
}

function UpdatePriWpnGadgetTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_APriWpnGadget = GetGadgetRestrictionKit( class'R6WeaponGadgetDescription', pServerOptions.RestrictedPrimary, _pR6GameRepInfo);
	else
		m_APriWpnGadget = GetGadgetRestrictionKit( class'R6WeaponGadgetDescription', pServerOptions.RestrictedPrimary, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgPrimaryRes);

	UpdateRestKitButtonSel( m_ASelected, m_pPriWpnGadget);
}

//=================================================================================================
//========================= SECONDARY WEAPON GADGETS =====================================================
//=================================================================================================
function InitSecWpnGadgetTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local FLOAT                         fXOffset, fYOffset, fYStep, fWidth, fHeight;
    local Font                          ButtonFont;
    local INT                           i,j,k;
    local class<R6WeaponGadgetDescription>   DescriptionClass;
    local BOOL                          bFound; // Gadget Name ID already found in list
    local R6ServerInfo					pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();
    
    // Clear list

    m_ASecWpnGadget.remove( 0, m_ASecWpnGadget.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all secondary weapon gadget
	if (_pR6GameRepInfo == None)
		m_ASecWpnGadget = GetGadgetRestrictionKit( class'R6WeaponGadgetDescription', pServerOptions.RestrictedSecondary, _pR6GameRepInfo, , true);
	else
		m_ASecWpnGadget = GetGadgetRestrictionKit( class'R6WeaponGadgetDescription', pServerOptions.RestrictedSecondary, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgSecondayRes, true);

	CreateRestKitButtons( m_ASecWpnGadget, m_ASelected, "R6WeaponGadgets", m_pSecWpnGadget);

    // Clear remainder of list

    for ( i = m_ASecWpnGadget.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pSecWpnGadget[i] = None;
}

function UpdateSecWpnGadgetTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_ASecWpnGadget = GetGadgetRestrictionKit( class'R6WeaponGadgetDescription', pServerOptions.RestrictedSecondary, _pR6GameRepInfo, , true);
	else
		m_ASecWpnGadget = GetGadgetRestrictionKit( class'R6WeaponGadgetDescription', pServerOptions.RestrictedSecondary, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgSecondayRes, true);

	UpdateRestKitButtonSel( m_ASelected, m_pSecWpnGadget);
}

//=================================================================================================
//========================= MISC GADGETS =====================================================
//=================================================================================================
function InitMiscGadgetTab( R6GameReplicationInfo _pR6GameRepInfo)
{
	local INT i;
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    // Clear list

    m_AMiscGadget.remove( 0, m_AMiscGadget.Length );
	m_ASelected.remove( 0, m_ASelected.Length);

    //Insert all misc gadget
	if (_pR6GameRepInfo == None)
		m_AMiscGadget = GetGadgetRestrictionKit( class'R6GadgetDescription', pServerOptions.RestrictedMiscGadgets, _pR6GameRepInfo);
	else
		m_AMiscGadget = GetGadgetRestrictionKit( class'R6GadgetDescription', pServerOptions.RestrictedMiscGadgets, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgMiscRes);

	CreateRestKitButtons( m_AMiscGadget, m_ASelected, "R6Gadgets", m_pMiscGadget);

    // Clear remainder of list

    for ( i = m_AMiscGadget.length + 1; i < K_MAX_WINDOWBUTTONBOX; i++ )
        m_pMiscGadget[i] = None;
}

function UpdateMiscGadgetTab( R6GameReplicationInfo _pR6GameRepInfo)
{
    local R6ServerInfo pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

	m_ASelected.remove( 0, m_ASelected.Length);

	if (_pR6GameRepInfo == None)
		m_AMiscGadget = GetGadgetRestrictionKit( class'R6GadgetDescription', pServerOptions.RestrictedMiscGadgets, _pR6GameRepInfo);
	else
		m_AMiscGadget = GetGadgetRestrictionKit( class'R6GadgetDescription', pServerOptions.RestrictedMiscGadgets, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgMiscRes);

	UpdateRestKitButtonSel( m_ASelected, m_pMiscGadget);
}



function array<class> GetRestrictionKit( class pClassRestriction, array<class> _pInitialRest, R6GameReplicationInfo _pR6GameRepInfo, optional string _szInGameRestriction[32])
{
	local array<class>            m_AOfRestrictions;
    local class<R6Description>    DescriptionClass;
	local INT i, j, iNbOfRest;
	local BOOL bFindRes;
	
	// MPF - Eric
	local INT k;
	local R6Mod pCurrentMod;

	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod;

	if(pCurrentMod == None)
	{
		log("pCurrentMod == None");
		return m_AOfRestrictions;
	}

	for (k = 0; k < pCurrentMod.m_aDescriptionPackage.Length; k++)
	{
		DescriptionClass = class<R6Description>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[k]$".u", pClassRestriction));
		
		while( DescriptionClass != None )
		{
			bFindRes = false;
			
			if (DescriptionClass.Default.m_NameID != "NONE")
			{
#ifdefMPDEMO        
				if (
					// Pistols
					(DescriptionClass.Default.m_NameID == "PISTOL92FS") ||
					(DescriptionClass.Default.m_NameID == "PISTOLAPARMY") ||
					(DescriptionClass.Default.m_NameID == "PISTOLUSP") ||
					(DescriptionClass.Default.m_NameID == "PISTOLMK23") ||
					(DescriptionClass.Default.m_NameID == "PISTOLMAC119") ||
					// SubMachineGuns
					(DescriptionClass.Default.m_NameID == "SUBMP5SD5") ||
					(DescriptionClass.Default.m_NameID == "SUBP90") ||
					(DescriptionClass.Default.m_NameID == "SUBMP5A4") ||
					// Assault
					(DescriptionClass.Default.m_NameID == "ASSAULTG36K") ||
					(DescriptionClass.Default.m_NameID == "ASSAULTM14") ||
					(DescriptionClass.Default.m_NameID == "ASSAULTM16A2") ||
					(DescriptionClass.Default.m_NameID == "ASSAULTTAR21") ||
					// Sniper
					(DescriptionClass.Default.m_NameID == "SNIPERSSG3000") ||
					(DescriptionClass.Default.m_NameID == "SNIPERVSSVINTOREZ") ||
					// LMachGun
					(DescriptionClass.Default.m_NameID == "LMGRPD") ||
					// WeaponGadget
					(DescriptionClass.Default.m_NameID == "MINISCOPE") ||
					(DescriptionClass.Default.m_NameID == "SILENCER")
					)
				{
					bFindRes = true;
				}
#endif
#ifndefMPDEMO
                bFindRes = true;
#endif
			}
			
			if (bFindRes)
			{                
				m_AOfRestrictions[i]=DescriptionClass;
				
				i++;
			}
			
			DescriptionClass = class<R6Description>(GetNextClass());
		}
		
		iNbOfRest = i;
		
		FreePackageObjects();
	}

	// sort the restrictions kit
	m_AOfRestrictions = SortRestrictionKit( m_AOfRestrictions);

	for ( i = 0; i < iNbOfRest; i++)
	{
		m_ASelected[i] = 0;

		if (_pR6GameRepInfo == None)
		{
			// use info in server.ini
			for (j = 0; j < _pInitialRest.length; j++)
			{
				if ( _pInitialRest[j] == m_AOfRestrictions[i])
				{
					m_ASelected[i] = 1;						
					break;
				}
			}
		}
		// access info store in gamerepinfo to display appropriate kit rest menu selection
		else // if (_pR6GameRepInfo != None) 
		{
			for( j = 0; j < arraycount(_szInGameRestriction); j++ )
			{
				if ( _szInGameRestriction[j] == (class<R6Description>(m_AOfRestrictions[i])).Default.m_NameID )
				{
					m_ASelected[i] = 1;						
					break;
				}
			}
		}
	}

	return m_AOfRestrictions;
}


function array<class> GetGadgetRestrictionKit( class pClassRestriction, array<string> _pInitialRest, 
											   R6GameReplicationInfo _pR6GameRepInfo, optional string _szInGameRestriction[32], 
											   optional BOOL _bSecWeaponGadget)
{
	local array<class>            m_AOfRestrictions;
    local class<R6Description>    DescriptionClass;
	local INT i, j, k, iNbOfRest;
	local BOOL bFindRes;

	// MPF - Eric
	local INT l;
	local R6Mod pCurrentMod;

	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod;

	for (l = 0; l < pCurrentMod.m_aDescriptionPackage.Length; l++)
	{
		DescriptionClass = class<R6Description>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[l]$".u", pClassRestriction));
		
		while( DescriptionClass != None )
		{
			bFindRes = false;
			
			if (DescriptionClass.Default.m_NameID != "NONE")
			{
#ifdefMPDEMO
				if (!_bSecWeaponGadget)
				{
					if (DescriptionClass.Default.m_NameID == "MINISCOPE")
					{
						bFindRes = true;
					}
				}
				
				if ( 
					(DescriptionClass.Default.m_NameID == "SILENCER") ||
					(DescriptionClass.Default.m_NameID == "CLAYMOREGADGET") ||
					(DescriptionClass.Default.m_NameID == "FALSEHBGADGET") ||
					(DescriptionClass.Default.m_NameID == "FLASHBANGGADGET") ||
					(DescriptionClass.Default.m_NameID == "FRAGGRENADEGADGET") ||
					(DescriptionClass.Default.m_NameID == "GASMASK") ||
					(DescriptionClass.Default.m_NameID == "HBSGADGET") ||
					(DescriptionClass.Default.m_NameID == "HBSJAMMERGADGET") ||
					(DescriptionClass.Default.m_NameID == "HBSSAJAMMERGADGET") ||
					(DescriptionClass.Default.m_NameID == "PRIMARYMAGS") ||
					(DescriptionClass.Default.m_NameID == "REMOTECHARGEGADGET") ||
					(DescriptionClass.Default.m_NameID == "SECONDARYMAGS") ||
					(DescriptionClass.Default.m_NameID == "SMOKEGRENADEGADGET") ||
					(DescriptionClass.Default.m_NameID == "TEARGASGRENADEGADGET")
					)
				{
					bFindRes = true;
				}
#endif
#ifndefMPDEMO
				if (_bSecWeaponGadget)
				{
					if ( (class<R6WeaponGadgetDescription>(DescriptionClass)).Default.m_bSecGadgetWAvailable)
						bFindRes = true;
				}
				else
				{
					bFindRes = true;
				}
#endif
			}
			
			if (bFindRes)
			{           
				k = m_AOfRestrictions.length;
				// parse all the restricted previous find and check if this one is already in the array
				for ( j = 0; j < k; j++)
				{
					if (class<R6Description>(m_AOfRestrictions[j]).Default.m_NameID == DescriptionClass.Default.m_NameID) // already exist?
					{
						bFindRes = false;
						break;
					}
				}
				
				if (bFindRes)
				{
					m_AOfRestrictions[i]=DescriptionClass;
					
					i++;
				}
			}
			
			DescriptionClass = class<R6Description>(GetNextClass());
		}
		
		iNbOfRest = i;
		
		FreePackageObjects();
	}



	// sort the restrictions kit
	m_AOfRestrictions = SortRestrictionKit( m_AOfRestrictions);

	for ( i = 0; i < iNbOfRest; i++)
	{
		m_ASelected[i] = 0;

		if (_pR6GameRepInfo == None)
		{
			// use info in server.ini
			for (j = 0; j < _pInitialRest.length; j++)
			{
				if ( _pInitialRest[j] == class<R6Description>(m_AOfRestrictions[i]).Default.m_NameID )
				{
					m_ASelected[i] = 1;						
					break;
				}
			}
		}
		// access info store in gamerepinfo to display appropriate kit rest menu selection
		else // if (_pR6GameRepInfo != None) 
		{
			for( j = 0; j < arraycount(_szInGameRestriction); j++ )
			{
				if ( _szInGameRestriction[j] == class<R6Description>(m_AOfRestrictions[i]).Default.m_NameID )
				{
					m_ASelected[i] = 1;						
					break;
				}
			}
		}
	}

	return m_AOfRestrictions;
}

//=============================================================================
// Simple bubble sort to list restriction kit in alphabetical order of name 
//=============================================================================
function array<class> SortRestrictionKit( array<class> _pAToSort)
{
    local INT i;
    local INT j;
    local class sTemp;
    local BOOL  bSwap;

    for ( i = 0; i < _pAToSort.length - 1; i++)
    {
        for ( j = 0; j < _pAToSort.length - 1 - i; j++ )
        {
            bSwap = (class<R6Description>(_pAToSort[j])).Default.m_NameID > (class<R6Description>(_pAToSort[j+1])).Default.m_NameID;

            if ( bSwap )
            {
                sTemp = _pAToSort[j];
                _pAToSort[j] = _pAToSort[j + 1];
                _pAToSort[j + 1] = sTemp;
            }
        }
    }

	return _pAToSort;
}

function CreateRestKitButtons( Array<Class> pRestKitClass, Array<BYTE> pRestKitSelect, string _szLocFile, out R6WindowButtonBox _ButtonsBox[K_MAX_WINDOWBUTTONBOX])
{
	local R6WindowListGeneralItem NewItem;
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight;
    local Font  ButtonFont;
	local INT	i;
	
	// MPF - Eric
	local INT j;
	local String ButtonTag;

    //create buttons
    fXOffset = K_X_BORDER_OFF;
    fYOffset = K_Y_LIST_OFF;
    fWidth = (K_HALFWINDOWWIDTH) - (2 * fXOffset) - 15;
    fHeight = K_BOX_HEIGHT;
    ButtonFont = Root.Fonts[F_SmallTitle]; 

    for ( i = 0; i < pRestKitClass.length; i++ )
    {
		NewItem = R6WindowListGeneralItem(m_pRestKitButList.GetItemAtIndex( i));
		NewItem.m_pR6WindowButtonBox = R6WindowButtonBox( CreateControl( class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self)); 
        NewItem.m_pR6WindowButtonBox.m_TextFont		= ButtonFont;
        NewItem.m_pR6WindowButtonBox.m_vTextColor	= Root.Colors.White;
        NewItem.m_pR6WindowButtonBox.m_vBorder		= Root.Colors.White;
		NewItem.m_pR6WindowButtonBox.m_bSelected	= BOOL(pRestKitSelect[i]);
        NewItem.m_pR6WindowButtonBox.m_szMiscText	= (class<R6Description>(pRestKitClass[i])).Default.m_NameID;
		NewItem.m_pR6WindowButtonBox.m_AdviceWindow = m_pRestKitButList;
        NewItem.m_pR6WindowButtonBox.CreateTextAndBox( Localize( (class<R6Description>(pRestKitClass[i])).Default.m_NameID, "ID_NAME", _szLocFile), 
													   Localize("Tip","Kit_Restriction","R6Menu"), 0, i);

		_ButtonsBox[i] = NewItem.m_pR6WindowButtonBox; // keep the old struct
		
/* OLD CODE no scroll bar
        _ButtonsBox[i] = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
        _ButtonsBox[i].m_TextFont   = ButtonFont;
        _ButtonsBox[i].m_vTextColor = Root.Colors.White;
        _ButtonsBox[i].m_vBorder    = Root.Colors.White;
		_ButtonsBox[i].m_bSelected  = BOOL(pRestKitSelect[i]);
        _ButtonsBox[i].m_szMiscText = (class<R6Description>(pRestKitClass[i])).Default.m_NameID;
        _ButtonsBox[i].CreateTextAndBox( Localize( (class<R6Description>(pRestKitClass[i])).Default.m_NameID, "ID_NAME", _szLocFile), 
                                         Localize("Tip","Kit_Restriction","R6Menu"), 0, i);
        fYOffset += K_BOX_HEIGHT;
*/
    }
}

function UpdateRestKitButtonSel( Array<BYTE> pRestKitSelect, out R6WindowButtonBox _ButtonsBox[K_MAX_WINDOWBUTTONBOX])
{
	local INT i;

    for ( i = 0; i < pRestKitSelect.length; i++ )
    {
		if (_ButtonsBox[i] == None)
			break;

        _ButtonsBox[i].m_bSelected = BOOL(pRestKitSelect[i]);
	}
}


function SelectAllSubMachineGuns( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_ASubMachineGuns.length; i++ )
        m_pSubMachineGuns[i].m_bSelected = bSelected;
}

function SelectAllShotguns( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_AShotguns.length; i++ )
        m_pShotguns[i].m_bSelected = bSelected;
}
function SelectAllAssaultRifle( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_AAssaultRifle.length; i++ )
        m_pAssaultRifle[i].m_bSelected = bSelected;
}
function SelectAllMachineGuns( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_AMachineGuns.length; i++ )
        m_pMachineGuns[i].m_bSelected = bSelected;
}
function SelectAllSniperRifle( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_ASniperRifle.length; i++ )
        m_pSniperRifle[i].m_bSelected = bSelected;
}
function SelectAllPistol( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_APistol.length; i++ )
	{
		if (!m_pPistol[i].bDisabled)
	        m_pPistol[i].m_bSelected = bSelected;
	}
}
function SelectAllMachinePistol( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_AMachinePistol.length; i++ )
        m_pMachinePistol[i].m_bSelected = bSelected;
}
function SelectAllPriWpnGadget( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_APriWpnGadget.length; i++ )
        m_pPriWpnGadget[i].m_bSelected = bSelected;
}
function SelectAllSecWpnGadget( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_ASecWpnGadget.length; i++ )
        m_pSecWpnGadget[i].m_bSelected = bSelected;
}
function SelectAllMiscGadget( BOOL bSelected )
{
    local INT i;

    for ( i = 0; i < m_AMiscGadget.length; i++ )
        m_pMiscGadget[i].m_bSelected = bSelected;
}

//-------------------------------------------------------------------------
// Notify - Called when buttons are selected, options changed, etc.
//-------------------------------------------------------------------------

function Notify(UWindowDialogControl C, byte E)
{
    local bool bSelect;
    local R6MenuMPRestKitMain R6RestKit;

    if(m_bIsInGame)
    {
        if(!R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).Authority_Admin))
        {
            return;
        }
    }
    if(C.IsA('R6WindowButton'))
    {
        bSelect = C == m_pSelectAll;
        switch(E)
        {
            case 2:
                R6RestKit = R6MenuMPRestKitMain(OwnerWindow);
                if(self == R6RestKit.m_pSubMachinesGunsTab)
                {
                    SelectAllSubMachineGuns(bSelect);                    
                }
                else
                {
                    if(self == R6RestKit.m_pShotgunsTab)
                    {
                        SelectAllShotguns(bSelect);                        
                    }
                    else
                    {
                        if(self == R6RestKit.m_pAssaultRifleTab)
                        {
                            SelectAllAssaultRifle(bSelect);                            
                        }
                        else
                        {
                            if(self == R6RestKit.m_pMachineGunsTab)
                            {
                                SelectAllMachineGuns(bSelect);                                
                            }
                            else
                            {
                                if(self == R6RestKit.m_pSniperRifleTab)
                                {
                                    SelectAllSniperRifle(bSelect);                                    
                                }
                                else
                                {
                                    if(self == R6RestKit.m_pPistolTab)
                                    {
                                        SelectAllPistol(bSelect);                                        
                                    }
                                    else
                                    {
                                        if(self == R6RestKit.m_pMachinePistolTab)
                                        {
                                            SelectAllMachinePistol(bSelect);                                            
                                        }
                                        else
                                        {
                                            if(self == R6RestKit.m_pPriWpnGadgetTab)
                                            {
                                                SelectAllPriWpnGadget(bSelect);                                                
                                            }
                                            else
                                            {
                                                if(self == R6RestKit.m_pSecWpnGadgetTab)
                                                {
                                                    SelectAllSecWpnGadget(bSelect);                                                    
                                                }
                                                else
                                                {
                                                    if(self == R6RestKit.m_pMiscGadgetTab)
                                                    {
                                                        SelectAllMiscGadget(bSelect);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(!m_bIsInGame)
                {
                    R6MenuMPCreateGameTabKitRest(R6RestKit.OwnerWindow).SetServerOptions();
                }
                break;
            case 9:
                R6WindowButton(C).SetButtonBorderColor(Root.Colors.White);
                R6WindowButton(C).TextColor = Root.Colors.White;
                break;
            case 12:
                R6WindowButton(C).SetButtonBorderColor(Root.Colors.BlueLight);
                R6WindowButton(C).TextColor = Root.Colors.BlueLight;
                break;
            default:
        }        
    }
    else
    {
        if(C.IsA('R6WindowButtonBox'))
        {
            if(E == DE_Click)
            {
                if(R6WindowButtonBox(C).GetSelectStatus())
                {
                    R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected;
                    if(!m_bIsInGame)
                    {
                        R6RestKit = R6MenuMPRestKitMain(OwnerWindow);
                        R6MenuMPCreateGameTabKitRest(R6RestKit.OwnerWindow).SetServerOptions();
                    }
                }
            }
        }
    }
}

//=======================================================================================
// Refresh : Verify is the client is now an admin only in-game
//=======================================================================================
function RefreshSubKit( BOOL _bAdmin)
{
	if (_bAdmin)
	{
		m_pSelectAll.bDisabled = false;
		m_pUnSelectAll.bDisabled = false;
	}
	else
	{
		m_pSelectAll.bDisabled = true;
		m_pUnSelectAll.bDisabled = true;
	}
}

defaultproperties
{
}
