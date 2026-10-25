//=============================================================================
//  R6MenuMPRestKitMain.uc : Display the server option depending if you are an admin or a client
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuMPRestKitMain extends UWindowDialogClientWindow;

const K_HALFWINDOWWIDTH                 = 310;                    // the half size of window LAN SERVER INFO and GameMode see K_WINDOWWIDTH in MenuMultiplyerWidget

var R6MenuButtonsDefines				m_pButtonsDef;

var R6MenuSimpleWindow                  m_pRestKitOptFakeW;       // fake window to hide all access buttons

// RESTRICTION KIT
var R6WindowTextLabelExt                m_pKitText; 

var R6WindowButtonBox                   m_pKitSubMachinesGuns;
var R6WindowButtonBox                   m_pKitShotGuns;
var R6WindowButtonBox                   m_pKitAssaultRifles;
var R6WindowButtonBox                   m_pKitMachinesGuns;
var R6WindowButtonBox                   m_pKitSniperRifles;
var R6WindowButtonBox                   m_pKitPistols;
var R6WindowButtonBox                   m_pKitMachinePistols;
var R6WindowButtonBox                   m_pKitPrimaryWeapon;
var R6WindowButtonBox                   m_pKitSecWeapon;
var R6WindowButtonBox                   m_pKitMisc;

var R6MenuMPRestKitSub					m_pSubMachinesGunsTab;
var R6MenuMPRestKitSub					m_pShotgunsTab;
var R6MenuMPRestKitSub					m_pAssaultRifleTab;
var R6MenuMPRestKitSub					m_pMachineGunsTab;
var R6MenuMPRestKitSub					m_pSniperRifleTab;
var R6MenuMPRestKitSub					m_pPistolTab;
var R6MenuMPRestKitSub					m_pMachinePistolTab;
var R6MenuMPRestKitSub					m_pPriWpnGadgetTab;
var R6MenuMPRestKitSub					m_pSecWpnGadgetTab;
var R6MenuMPRestKitSub					m_pMiscGadgetTab;
var R6MenuMPRestKitSub					m_pCurrentSubKit;

var Array<string>						m_SrvRestSubMachineGunsACopy;
var Array<string>						m_SrvRestShotGunsACopy;
var Array<string>						m_SrvRestAssultRiflesACopy;
var Array<string>						m_SrvRestMachineGunsACopy;
var Array<string>						m_SrvRestSniperRiflesACopy;
var Array<string>						m_SrvRestPistolsACopy;
var Array<string>						m_SrvRestMachinePistolsACopy;
var Array<string>						m_SrvRestPrimaryACopy;
var Array<string>						m_SrvRestSecondaryACopy;
var Array<string>						m_SrvRestMiscGadgetsACopy;

var string								m_ATextBoxLoc[2];

var BOOL								m_bUpdateInBetRound;
var BOOL								m_bUpdateGameProgress;
var BOOL								m_bImAnAdmin;			// if the client can change the settings

//=====================================================================================
// KIT TAB
//=====================================================================================
function CreateKitRestriction()
{
	local string szTemp;
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight;
    local Font ButtonFont;
	local BOOL bInGame;
    local R6GameReplicationInfo pGameRepInfo;

	GetR6GameReplicationInfo(pGameRepInfo);

    // it's a text label ext because you want to draw the line in the middle (small hack)
    m_pKitText = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, 2*K_HALFWINDOWWIDTH, WinHeight, self));
    m_pKitText.bAlwaysBehind = true;
    // draw middle line
    m_pKitText.ActiveBorder( 0, false);                                         // Top border
    m_pKitText.ActiveBorder( 1, false);                                         // Bottom border
    m_pKitText.SetBorderParam( 2, K_HALFWINDOWWIDTH, 1, 1, Root.Colors.White);  // Left border
    m_pKitText.ActiveBorder( 3, false);                                         // Rigth border

    // text part
    m_pKitText.m_Font = Root.Fonts[F_SmallTitle]; 
    m_pKitText.m_vTextColor = Root.Colors.White;

    fXOffset = 3;
    fYOffset = 5;
    fWidth = K_HALFWINDOWWIDTH;
    m_pKitText.AddTextLabel( Localize("MPCreateGame","Kit_PrimaryWeapon","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fYOffset = 125;
    m_pKitText.AddTextLabel( Localize("MPCreateGame","Kit_SecWeapon","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fYOffset = 200;
    m_pKitText.AddTextLabel( Localize("MPCreateGame","Kit_Gadgets","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);

    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //create buttons -- check text label offset for concordance 
    ButtonFont = Root.Fonts[F_SmallTitle];

    fXOffset = 5;
    fYOffset = 20; // fYOffset from Kit_PrimaryWeapon + is own initial fYOffset
    fWidth = K_HALFWINDOWWIDTH - fXOffset - 10; //10 substract small value to distance the check box from middle line
	fYStep = 15;
    fHeight = 15;

    m_ATextBoxLoc[0] = Localize("MultiPlayer","BoutonMsgBox","R6Menu");		  // EDIT
    m_ATextBoxLoc[1] = Localize("MultiPlayer","BoutonMsgBoxInGame","R6Menu"); // VIEW

	bInGame = false;
	if (pGameRepInfo != None)
		bInGame = true;


    // SUB MACHINES GUNS
    m_pKitSubMachinesGuns = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitSubMachinesGuns.m_TextFont = ButtonFont;
    m_pKitSubMachinesGuns.m_vTextColor = Root.Colors.White;
    m_pKitSubMachinesGuns.m_vBorder = Root.Colors.White;
    m_pKitSubMachinesGuns.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_SubMachGuns","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitSubMachinesGuns.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_SubMachGuns","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 0);

    fYOffset += fYStep;
    // SHOTGUNS
    m_pKitShotGuns = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitShotGuns.m_TextFont = ButtonFont;
    m_pKitShotGuns.m_vTextColor = Root.Colors.White;
    m_pKitShotGuns.m_vBorder = Root.Colors.White;
    m_pKitShotGuns.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_ShotGun","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitShotGuns.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_ShotGun","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 1);

#ifdefMPDEMO
	m_pKitShotGuns.bDisabled = true;
#endif

    fYOffset += fYStep;
    // ASSAULT RIFLES
    m_pKitAssaultRifles = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitAssaultRifles.m_TextFont = ButtonFont;
    m_pKitAssaultRifles.m_vTextColor = Root.Colors.White;
    m_pKitAssaultRifles.m_vBorder = Root.Colors.White;
    m_pKitAssaultRifles.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_Assault","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitAssaultRifles.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_Assault","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 2);

    fYOffset += fYStep;
    // MACHINES GUNS
    m_pKitMachinesGuns = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitMachinesGuns.m_TextFont = ButtonFont;
    m_pKitMachinesGuns.m_vTextColor = Root.Colors.White;
    m_pKitMachinesGuns.m_vBorder = Root.Colors.White;
    m_pKitMachinesGuns.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_MachGuns","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitMachinesGuns.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_MachGuns","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 3);

    fYOffset += fYStep;
    // SNIPER RIFLES
    m_pKitSniperRifles = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitSniperRifles.m_TextFont = ButtonFont;
    m_pKitSniperRifles.m_vTextColor = Root.Colors.White;
    m_pKitSniperRifles.m_vBorder = Root.Colors.White;
    m_pKitSniperRifles.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_Sniper","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitSniperRifles.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_Sniper","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 4);

    fYOffset = 140; // fYOffset from Kit_SecWeapon + is own initial fYOffset
    // PISTOLS
    m_pKitPistols = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitPistols.m_TextFont = ButtonFont;
    m_pKitPistols.m_vTextColor = Root.Colors.White;
    m_pKitPistols.m_vBorder = Root.Colors.White;
    m_pKitPistols.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_Pistols","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitPistols.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_Pistols","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 5);

    fYOffset += fYStep;
    // MACHINE PISTOLS
    m_pKitMachinePistols = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitMachinePistols.m_TextFont = ButtonFont;
    m_pKitMachinePistols.m_vTextColor = Root.Colors.White;
    m_pKitMachinePistols.m_vBorder = Root.Colors.White;
    m_pKitMachinePistols.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_MachPistols","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitMachinePistols.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_MachPistols","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 6);

    fYOffset = 215; // fYOffset from Kit_Gadgets + is own initial fYOffset
    // PRIMARY WEAPON
    m_pKitPrimaryWeapon = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitPrimaryWeapon.m_TextFont = ButtonFont;
    m_pKitPrimaryWeapon.m_vTextColor = Root.Colors.White;
    m_pKitPrimaryWeapon.m_vBorder = Root.Colors.White;
    m_pKitPrimaryWeapon.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_PrimaryWeaponMin","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitPrimaryWeapon.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_PrimaryWeaponMin","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 7);

    fYOffset += fYStep;
    // SECONDARY WEAPON
    m_pKitSecWeapon = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitSecWeapon.m_TextFont = ButtonFont;
    m_pKitSecWeapon.m_vTextColor = Root.Colors.White;
    m_pKitSecWeapon.m_vBorder = Root.Colors.White;
    m_pKitSecWeapon.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_SecWeaponMin","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitSecWeapon.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_SecWeaponMin","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 8);

    fYOffset += fYStep;
    // MISCELLANEOUS
    m_pKitMisc = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pKitMisc.m_TextFont = ButtonFont;
    m_pKitMisc.m_vTextColor = Root.Colors.White;
    m_pKitMisc.m_vBorder = Root.Colors.White;
    m_pKitMisc.m_eButtonType = BBT_ResKit;
	szTemp = Localize("Tip","Kit_Misc","R6Menu");
	if (pGameRepInfo != None)
		szTemp = "";
    m_pKitMisc.CreateTextAndMsgBox( Localize("MPCreateGame","Kit_Misc","R6Menu"), szTemp, m_ATextBoxLoc[0], 0, 9);

	InitRightPart();
}


function InitRightPart()
{
    local R6GameReplicationInfo pGameRepInfo;
    local float fXOffset, fYOffset, fWidth, fHeight;
    local BOOL bInGame;
    
    fXOffset = K_HALFWINDOWWIDTH;
    fYOffset = 0;
    fWidth   = K_HALFWINDOWWIDTH;
    fHeight  = WinHeight;

	GetR6GameReplicationInfo(pGameRepInfo);

	bInGame = false;
	if (pGameRepInfo != None)
		bInGame = true;

    m_pSubMachinesGunsTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pSubMachinesGunsTab.InitSelectButtons( bInGame );
    m_pSubMachinesGunsTab.InitSubMachineGunsTab( pGameRepInfo);
    m_pSubMachinesGunsTab.HideWindow();

    m_pShotgunsTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pShotgunsTab.InitSelectButtons( bInGame);
    m_pShotgunsTab.InitShotGunsTab( pGameRepInfo);
    m_pShotgunsTab.HideWindow();

    m_pAssaultRifleTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pAssaultRifleTab.InitSelectButtons( bInGame);
    m_pAssaultRifleTab.InitAssaultRifleTab( pGameRepInfo);
    m_pAssaultRifleTab.HideWindow();

    m_pMachineGunsTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pMachineGunsTab.InitSelectButtons( bInGame);
    m_pMachineGunsTab.InitMachineGunsTab( pGameRepInfo);
    m_pMachineGunsTab.HideWindow();

    m_pSniperRifleTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pSniperRifleTab.InitSelectButtons( bInGame);
    m_pSniperRifleTab.InitSniperRifleTab( pGameRepInfo);
    m_pSniperRifleTab.HideWindow();

    m_pPistolTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPistolTab.InitSelectButtons( bInGame);
    m_pPistolTab.InitPistolTab( pGameRepInfo);
    m_pPistolTab.HideWindow();

    m_pMachinePistolTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pMachinePistolTab.InitSelectButtons( bInGame);
    m_pMachinePistolTab.InitMachinePistolTab( pGameRepInfo);
    m_pMachinePistolTab.HideWindow();

    m_pPriWpnGadgetTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPriWpnGadgetTab.InitSelectButtons( bInGame);
    m_pPriWpnGadgetTab.InitPriWpnGadgetTab( pGameRepInfo);
    m_pPriWpnGadgetTab.HideWindow();

    m_pSecWpnGadgetTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pSecWpnGadgetTab.InitSelectButtons( bInGame);
    m_pSecWpnGadgetTab.InitSecWpnGadgetTab( pGameRepInfo);
    m_pSecWpnGadgetTab.HideWindow();

    m_pMiscGadgetTab = R6MenuMPRestKitSub(CreateWindow(class'R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pMiscGadgetTab.InitSelectButtons( bInGame);
    m_pMiscGadgetTab.InitMiscGadgetTab( pGameRepInfo);
    m_pMiscGadgetTab.HideWindow();

	m_pRestKitOptFakeW = R6MenuSimpleWindow(CreateWindow( class'R6MenuSimpleWindow', WinWidth * 0.5, 0, WinWidth * 0.5, WinHeight, self));
	m_pRestKitOptFakeW.bAlwaysOnTop = true;
	m_pRestKitOptFakeW.m_bDrawSimpleBorder = false;
	m_pRestKitOptFakeW.pAdviceParent = self;

	if (bInGame)
	{
		Refresh();

		// this is temp until we "polish" pop-up, for border standarization
		m_pSubMachinesGunsTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pShotgunsTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pAssaultRifleTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pMachineGunsTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pSniperRifleTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pPistolTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pMachinePistolTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pPriWpnGadgetTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pSecWpnGadgetTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		m_pMiscGadgetTab.m_pRestKitButList.m_VertSB.WinLeft -= 1;
		// end of temp
	}
	else
	{
		m_pRestKitOptFakeW.HideWindow();
        RefreshCreateGameKitRest();
        
        if ( m_pCurrentSubKit != none )
            m_pCurrentSubKit.HideWindow();
	}
}

function RefreshCreateGameKitRest()
{
	m_pSubMachinesGunsTab.UpdateSubMachineGunsTab( None);
	m_pShotgunsTab.UpdateShotGunsTab(None);
	m_pAssaultRifleTab.UpdateAssaultRifleTab(None);
	m_pMachineGunsTab.UpdateMachineGunsTab(None);
	m_pSniperRifleTab.UpdateSniperRifleTab(None);
	m_pPistolTab.UpdatePistolsTab(None);
	m_pMachinePistolTab.UpdateMachinePistolTab(None);
	m_pPriWpnGadgetTab.UpdatePriWpnGadgetTab(None);
	m_pSecWpnGadgetTab.UpdateSecWpnGadgetTab(None);
	m_pMiscGadgetTab.UpdateMiscGadgetTab(None);
}

//=======================================================================================
// Refresh : Verify is the client is now an admin only in-game
//=======================================================================================
function Refresh()
{
	local string szTextBox;

	if ( R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).Authority_Admin))
	{
#ifndefMPDEMO
        // we just became an administrator
        if (m_bImAnAdmin == false)
        {
		    m_bImAnAdmin = true;
            R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
        }
#endif
		szTextBox = m_ATextBoxLoc[0];
		m_pRestKitOptFakeW.HideWindow();
	}
	else
	{
		m_bImAnAdmin = false;
		szTextBox = m_ATextBoxLoc[1];
		m_pRestKitOptFakeW.ShowWindow();
    }	

#ifdefMPDemo
	m_bImAnAdmin = false;
	szTextBox = m_ATextBoxLoc[1];
	m_pRestKitOptFakeW.ShowWindow();
#endif

	m_pKitSubMachinesGuns.ModifyMsgBox(szTextBox);
	m_pKitShotGuns.ModifyMsgBox(szTextBox);
	m_pKitAssaultRifles.ModifyMsgBox(szTextBox);
	m_pKitMachinesGuns.ModifyMsgBox(szTextBox);
	m_pKitSniperRifles.ModifyMsgBox(szTextBox);
	m_pKitPistols.ModifyMsgBox(szTextBox);
	m_pKitMachinePistols.ModifyMsgBox(szTextBox);
	m_pKitPrimaryWeapon.ModifyMsgBox(szTextBox);
	m_pKitSecWeapon.ModifyMsgBox(szTextBox);
	m_pKitMisc.ModifyMsgBox(szTextBox);

	m_pSubMachinesGunsTab.RefreshSubKit( m_bImAnAdmin);
	m_pShotgunsTab.RefreshSubKit( m_bImAnAdmin);
	m_pAssaultRifleTab.RefreshSubKit( m_bImAnAdmin);
	m_pMachineGunsTab.RefreshSubKit( m_bImAnAdmin);
	m_pSniperRifleTab.RefreshSubKit( m_bImAnAdmin);
	m_pPistolTab.RefreshSubKit( m_bImAnAdmin);
	m_pMachinePistolTab.RefreshSubKit( m_bImAnAdmin);
	m_pPriWpnGadgetTab.RefreshSubKit( m_bImAnAdmin);
	m_pSecWpnGadgetTab.RefreshSubKit( m_bImAnAdmin);
	m_pMiscGadgetTab.RefreshSubKit( m_bImAnAdmin);
}

//=================================================================================
// RefreshKitRest: Refresh the kit restrictions according the value on the server side 
//=================================================================================
function RefreshKitRest()
{
	local R6GameReplicationInfo pGameRepInfo;
	local R6MenuInGameMultiPlayerRootWindow R6CurrentRoot;

	R6CurrentRoot = R6MenuInGameMultiPlayerRootWindow(Root);
	pGameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);

//	if (R6CurrentRoot.m_R6GameMenuCom.m_eStatMenuState == R6CurrentRoot.m_R6GameMenuCom.eClientMenuState.CMS_DisplayStat)
//	{
//		m_bUpdateInBetRound = false;
//		if (m_bUpdateGameProgress)
//			return;
//		else
//			m_bUpdateGameProgress = true;
//	}
//	else 
//	{
//		m_bUpdateGameProgress = false;
//		if (m_bUpdateInBetRound)
//			return;
//		else
//			m_bUpdateInBetRound = true;
//	}

	m_pSubMachinesGunsTab.UpdateSubMachineGunsTab( pGameRepInfo);
	m_pShotgunsTab.UpdateShotGunsTab(pGameRepInfo);
	m_pAssaultRifleTab.UpdateAssaultRifleTab(pGameRepInfo);
	m_pMachineGunsTab.UpdateMachineGunsTab(pGameRepInfo);
	m_pSniperRifleTab.UpdateSniperRifleTab(pGameRepInfo);
	m_pPistolTab.UpdatePistolsTab(pGameRepInfo);
	m_pMachinePistolTab.UpdateMachinePistolTab(pGameRepInfo);
	m_pPriWpnGadgetTab.UpdatePriWpnGadgetTab(pGameRepInfo);
	m_pSecWpnGadgetTab.UpdateSecWpnGadgetTab(pGameRepInfo);
	m_pMiscGadgetTab.UpdateMiscGadgetTab(pGameRepInfo);

	CopyStaticAToDynA( pGameRepInfo.m_szSubMachineGunsRes, m_SrvRestSubMachineGunsACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szShotGunRes,		   m_SrvRestShotGunsACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szAssRifleRes,	   m_SrvRestAssultRiflesACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szMachGunRes,		   m_SrvRestMachineGunsACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szSnipRifleRes,	   m_SrvRestSniperRiflesACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szPistolRes,		   m_SrvRestPistolsACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szMachPistolRes,	   m_SrvRestMachinePistolsACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szGadgPrimaryRes,	   m_SrvRestPrimaryACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szGadgSecondayRes,   m_SrvRestSecondaryACopy);
	CopyStaticAToDynA( pGameRepInfo.m_szGadgMiscRes,	   m_SrvRestMiscGadgetsACopy);
}

function CopyStaticAToDynA( string _ASrvRest[32], out array<string> _ASrvRestCopy)
{
	local INT i;

	_ASrvRestCopy.remove( 0, _ASrvRestCopy.Length);

	for ( i = 0; (_ASrvRest[i] != "") && (i < 32); i++ )
	{
		_ASrvRestCopy[i] = _ASrvRest[i];
	}
}

//=================================================================================
// SendNewRestrictionsKit: Send the new restrictions kit settings to the server, only the change values. 
//						   If no modification was made return false 
//=================================================================================
function BOOL SendNewRestrictionsKit()
{
	local R6GameReplicationInfo				R6GameRepInfo;
	local BOOL bSettingsChange;

	R6GameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);

	bSettingsChange = CompareARestKit( ERestKit_SubMachineGuns, m_SrvRestSubMachineGunsACopy, m_pSubMachinesGunsTab.m_ASubMachineGuns, m_pSubMachinesGunsTab.m_pSubMachineGuns);
	bSettingsChange = (CompareARestKit( ERestKit_Shotguns,		m_SrvRestShotGunsACopy,		m_pShotgunsTab.m_AShotguns, m_pShotgunsTab.m_pShotguns) || bSettingsChange);
	bSettingsChange = (CompareARestKit( ERestKit_AssaultRifle,	m_SrvRestAssultRiflesACopy, 	m_pAssaultRifleTab.m_AAssaultRifle, m_pAssaultRifleTab.m_pAssaultRifle) || bSettingsChange);
	bSettingsChange = (CompareARestKit( ERestKit_MachineGuns,	m_SrvRestMachineGunsACopy,	m_pMachineGunsTab.m_AMachineGuns, m_pMachineGunsTab.m_pMachineGuns) || bSettingsChange);
	bSettingsChange = (CompareARestKit( ERestKit_SniperRifle,	m_SrvRestSniperRiflesACopy,	m_pSniperRifleTab.m_ASniperRifle, m_pSniperRifleTab.m_pSniperRifle)	|| bSettingsChange);
	bSettingsChange = (CompareARestKit( ERestKit_Pistol,		m_SrvRestPistolsACopy,		m_pPistolTab.m_APistol, m_pPistolTab.m_pPistol)	|| bSettingsChange);
	bSettingsChange = (CompareARestKit( ERestKit_MachinePistol, m_SrvRestMachinePistolsACopy, m_pMachinePistolTab.m_AMachinePistol, m_pMachinePistolTab.m_pMachinePistol) || bSettingsChange);
	bSettingsChange = (CompareARestKit( ERestKit_PriWpnGadget,  m_SrvRestPrimaryACopy,		m_pPriWpnGadgetTab.m_APriWpnGadget, m_pPriWpnGadgetTab.m_pPriWpnGadget, true) || bSettingsChange);
	bSettingsChange = (CompareARestKit( ERestKit_SecWpnGadget,  m_SrvRestSecondaryACopy,		m_pSecWpnGadgetTab.m_ASecWpnGadget, m_pSecWpnGadgetTab.m_pSecWpnGadget, true) || bSettingsChange);
	bSettingsChange = (CompareARestKit( ERestKit_MiscGadget,    m_SrvRestMiscGadgetsACopy,	m_pMiscGadgetTab.m_AMiscGadget, m_pMiscGadgetTab.m_pMiscGadget, true) || bSettingsChange);
	
	log("SendNewRestrictionsKit --> bSettingsChange: "$bSettingsChange);
	return bSettingsChange;
}

function BOOL CompareARestKit(ERestKitID _eRestKitID, out array<string> _ANextSrvRestriction, array<class> _ACurServerRestKit, R6WindowButtonBox _pAButtonBox[20], optional BOOL _bStringArray)
{
	local Array<class> ARestToRemove, ARestToAdd;
	local Array<string> szAOldCopyOfSrvRest;
	local INT i, j, 
			  iTotOldMenuRest, iRestToRemove, iRestToAdd;
	local BOOL bSettingsChange, bFindRes;

	// assign the total item find for server list
	for ( i = 0; i < _ANextSrvRestriction.Length; i++ )
		szAOldCopyOfSrvRest[i] = _ANextSrvRestriction[i];

	iTotOldMenuRest = i;

	// reset the menu array
	_ANextSrvRestriction.remove( 0, _ANextSrvRestriction.Length);

	iRestToRemove = 0;
	iRestToAdd	  = 0;
	// get the menu settings
	for ( i = 0; i < 20; i++) // 20 is the max number of buttons
	{
		if (_pAButtonBox[i] == None)
			break;

		// if the rest kit button is selected
		if (_pAButtonBox[i].m_bSelected)
		{
			// this add the rest kit for the menu
			_ANextSrvRestriction[iRestToAdd] = (class<R6Description>(_ACurServerRestKit[i])).Default.m_NameID;

			bFindRes = false;
			
			// verify if the rest is already on the server side
			for ( j = 0; j < iTotOldMenuRest; j++)
			{
				if ( _ANextSrvRestriction[iRestToAdd] == szAOldCopyOfSrvRest[j])
				{
					szAOldCopyOfSrvRest.remove( j, 1); 
					iTotOldMenuRest--;
					bFindRes = true;
					break;
				}
			}

			iRestToAdd++;

			// it's a new rest for the server, add it
			if (!bFindRes)
			{
				bSettingsChange = true;

				if (_bStringArray)
					R6PlayerController(GetPlayerOwner()).ServerNewKitRestSettings( _eRestKitID, false, , _pAButtonBox[i].m_szMiscText);
				else
					R6PlayerController(GetPlayerOwner()).ServerNewKitRestSettings( _eRestKitID, false, _ACurServerRestKit[i]);
			}
		}
		else // remove the rest kit
		{
			ARestToRemove[iRestToRemove] = _ACurServerRestKit[i];
			iRestToRemove++;
		}
	}

	// we have to compare the rest on the srv and the menu for remove rest
	if (iTotOldMenuRest > 0)
	{
		for (i= 0 ; i < ARestToRemove.Length; i++)
		{
			bSettingsChange = true;
			if (_bStringArray)
				R6PlayerController(GetPlayerOwner()).ServerNewKitRestSettings( _eRestKitID, true, , (class<R6Description>(ARestToRemove[i])).Default.m_NameID);
			else
				R6PlayerController(GetPlayerOwner()).ServerNewKitRestSettings( _eRestKitID, true, ARestToRemove[i]);
		}
	}

	return bSettingsChange;
}


/////////////////////////////////////////////////////////////////
// notify the parent window by using the appropriate parent function
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
//    log("Notify from class: "$C);
//    log("Notify msg: "$E);

	if(E == DE_Click)
	{
        // Change Current Selected Button
        if ( C.IsA('R6WindowButtonBox'))
        {
            ManageR6ButtonBoxNotify(C);
        }
    }
}


/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonBoxNotify( UWindowDialogControl C)
{
    local R6GameReplicationInfo pGameRepInfo;

	if (m_pSubMachinesGunsTab != None)
	{     
		GetR6GameReplicationInfo(pGameRepInfo);

		if (m_pCurrentSubKit != None)
		{
			m_pCurrentSubKit.HideWindow();
		}

		switch ( R6WindowButtonBox(C) )
		{
			case m_pKitSubMachinesGuns:
				m_pCurrentSubKit = m_pSubMachinesGunsTab;
				break;
			case m_pKitShotGuns:
				m_pCurrentSubKit = m_pShotgunsTab;
				break;
			case m_pKitAssaultRifles:
				m_pCurrentSubKit = m_pAssaultRifleTab;
				break;
			case m_pKitMachinesGuns:
				m_pCurrentSubKit = m_pMachineGunsTab;
				break;
			case m_pKitSniperRifles:
				m_pCurrentSubKit = m_pSniperRifleTab;
				break;
			case m_pKitPistols:
				m_pCurrentSubKit = m_pPistolTab;
				break;
			case m_pKitMachinePistols:
				m_pCurrentSubKit = m_pMachinePistolTab;
				break;
			case m_pKitPrimaryWeapon:
				m_pCurrentSubKit = m_pPriWpnGadgetTab;
				break;
			case m_pKitSecWeapon:
				m_pCurrentSubKit = m_pSecWpnGadgetTab;
				break;
			case m_pKitMisc:
				m_pCurrentSubKit = m_pMiscGadgetTab;
				break;
		}
	}

	if (m_pCurrentSubKit != None)
	{
		m_pCurrentSubKit.ShowWindow();
	}
}

function GetR6GameReplicationInfo( out R6GameReplicationInfo pGameRepInfo)
{
    local R6MenuInGameMultiPlayerRootWindow R6Root;

    R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

    if( R6Root != None && 
        R6Root.m_R6GameMenuCom != None &&
        R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo) != None)
    {
		pGameRepInfo = R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo);
	}
	else
	{
		pGameRepInfo = None;
	}
}

function Tick( FLOAT _fDelta)
{
	if (m_pCurrentSubKit != None)
	{
		if (m_pRestKitOptFakeW.bWindowVisible)
		{
			if (m_pCurrentSubKit.m_pRestKitButList.m_VertSB.isHidden())
			{
				// increase the size of the fake window
				m_pRestKitOptFakeW.WinWidth = (WinWidth * 0.5);
			}
			else
			{
				// reduce the size of the fake window
				m_pRestKitOptFakeW.WinWidth = ((WinWidth * 0.5) - LookAndFeel.Size_ScrollbarWidth);
			}
		}
	}
}

function MouseWheelDown(FLOAT X, FLOAT Y)
{
	if ( m_pCurrentSubKit != None)
	{
		m_pCurrentSubKit.m_pRestKitButList.MouseWheelDown( X, Y);
	}
}

function MouseWheelUp(FLOAT X, FLOAT Y)
{
	if ( m_pCurrentSubKit != None)
	{
		m_pCurrentSubKit.m_pRestKitButList.MouseWheelUp( X, Y);
	}
}

defaultproperties
{
}
