//=============================================================================
//  R6MenuMPCreateGameTabKitRest.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/11  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTabKitRest extends R6MenuMPCreateGameTab;

// RESTRICTION KIT
var R6MenuMPRestKitMain					m_pMainRestriction;

//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created()
{
	Super.Created();
}

function InitKitTab()
{
	m_pMainRestriction = R6MenuMPRestKitMain( CreateWindow(class'R6MenuMPRestKitMain', 0, 0, WinWidth, WinHeight, self));
	m_pMainRestriction.bAlwaysBehind = true;
	m_pMainRestriction.CreateKitRestriction();
}

//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
function SetServerOptions()
{
    local INT iCounter, jCounter;
    local R6ServerInfo _ServerSettings;

#ifdefDEBUG
	local BOOL bShowLog;

	if (bShowLog)
	{
		log("R6MenuMPCreateGameTabKitRest SetServerOptions!!!!!!!!!!!!!!!!");
	}
#endif    

    _ServerSettings = class'Actor'.static.GetServerOptions();

    _ServerSettings.ClearSettings();    // clear old settings for restriction kit!!!

    // Sub machine guns restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pSubMachinesGunsTab.m_ASubMachineGuns.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pSubMachinesGunsTab.m_pSubMachineGuns[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedSubMachineGuns[jCounter] = m_pMainRestriction.m_pSubMachinesGunsTab.m_ASubMachineGuns[iCounter];
            jCounter++;
        }
    }
    
    // Shotguns restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pShotgunsTab.m_AShotguns.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pShotgunsTab.m_pShotguns[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedShotGuns[jCounter] = m_pMainRestriction.m_pShotgunsTab.m_AShotguns[iCounter];
            jCounter++;
        }
    } 

    // Assault rifles restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pAssaultRifleTab.m_AAssaultRifle.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pAssaultRifleTab.m_pAssaultRifle[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedAssultRifles[jCounter] = m_pMainRestriction.m_pAssaultRifleTab.m_AAssaultRifle[iCounter];
            jCounter++;
        }
    } 
    
    // Machine Guns restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pMachineGunsTab.m_AMachineGuns.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pMachineGunsTab.m_pMachineGuns[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedMachineGuns[jCounter] = m_pMainRestriction.m_pMachineGunsTab.m_AMachineGuns[iCounter];
            jCounter++;
        }
    } 

    // Sniper rifles restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pSniperRifleTab.m_ASniperRifle.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pSniperRifleTab.m_pSniperRifle[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedSniperRifles[jCounter] = m_pMainRestriction.m_pSniperRifleTab.m_ASniperRifle[iCounter];
            jCounter++;
        }
    } 
    
    // Pistols restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pPistolTab.m_APistol.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pPistolTab.m_pPistol[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedPistols[jCounter] = m_pMainRestriction.m_pPistolTab.m_APistol[iCounter];
            jCounter++;
        }
    }  
    
    // Machine pistols restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pMachinePistolTab.m_AMachinePistol.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pMachinePistolTab.m_pMachinePistol[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedMachinePistols[jCounter] = m_pMainRestriction.m_pMachinePistolTab.m_AMachinePistol[iCounter];
            jCounter++;
        }
    } 
    
    // primary weapon restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pPriWpnGadgetTab.m_APriWpnGadget.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pPriWpnGadgetTab.m_pPriWpnGadget[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedPrimary[jCounter] = m_pMainRestriction.m_pPriWpnGadgetTab.m_pPriWpnGadget[iCounter].m_szMiscText;
            jCounter++;
        }
    } 
    
    // secondary weapon restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pSecWpnGadgetTab.m_ASecWpnGadget.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pSecWpnGadgetTab.m_pSecWpnGadget[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedSecondary[jCounter] = m_pMainRestriction.m_pSecWpnGadgetTab.m_pSecWpnGadget[iCounter].m_szMiscText;
            jCounter++;
        }
    } 
    
    // misceleaneous weapon restricted
    
    jCounter = 0;
    for ( iCounter = 0; iCounter < m_pMainRestriction.m_pMiscGadgetTab.m_AMiscGadget.Length; iCounter++ )
    {
        if ( m_pMainRestriction.m_pMiscGadgetTab.m_pMiscGadget[iCounter].m_bSelected )
        {
            _ServerSettings.RestrictedMiscGadgets[jCounter] = m_pMainRestriction.m_pMiscGadgetTab.m_pMiscGadget[iCounter].m_szMiscText;
            jCounter++;
        }
    }    
}

defaultproperties
{
}
