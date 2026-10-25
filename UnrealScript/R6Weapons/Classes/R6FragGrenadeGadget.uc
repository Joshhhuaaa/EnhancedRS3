//=============================================================================
//  R6FragGrenadeGadget.uc 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6FragGrenadeGadget extends R6GrenadeWeapon;


function ServerSetGrenade(Pawn.eGrenadeThrow eGrenade)
{
	local Pawn PawnTmp;

    if (Level.IsGameTypeTeamAdversarial(Level.Game.m_szGameTypeFlag) || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
    {
		PawnTmp = Pawn(Owner);
        if ((eGrenade != GRENADE_RemovePin) && (eGrenade != GRENADE_None) &&
			((PawnTmp.m_eHealth == HEALTH_Healthy) || (PawnTmp.m_eHealth == HEALTH_Wounded)) )
		{
			R6PlayerController(PawnTmp.controller).m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(R6Pawn(Owner), MCV_FragThrow);
		}
    }
    
    Super.ServerSetGrenade(eGrenade);
}

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.R6FragGrenade'
     m_pFPWeaponClass=Class'R61stWeapons.R61stGrenadeHE'
     m_EquipSnd=Sound'Foley_FragGrenade.Play_Frag_Equip'
     m_UnEquipSnd=Sound'Foley_FragGrenade.Play_Frag_Unequip'
     m_SingleFireStereoSnd=Sound'Grenade_Frag.Play_random_Frag_Expl_Metal'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_HUDTexturePos=(W=32.000000,X=400.000000,Y=352.000000,Z=100.000000)
     m_NameID="FragGrenadeGadget"
}
