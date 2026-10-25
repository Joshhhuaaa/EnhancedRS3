//=============================================================================
//  R6SmokeGrenadeGadget.uc 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6SmokeGrenadeGadget extends R6GrenadeWeapon;

function ServerSetGrenade(Pawn.eGrenadeThrow eGrenade)
{
	local Pawn PawnTmp;

    if (Level.IsGameTypeTeamAdversarial(Level.Game.m_szGameTypeFlag) || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
    {
		PawnTmp = Pawn(Owner);
		if ((eGrenade != GRENADE_RemovePin) && (eGrenade != GRENADE_None) &&
			((PawnTmp.m_eHealth == HEALTH_Healthy) || (PawnTmp.m_eHealth == HEALTH_Wounded)) )
		{
            R6PlayerController(Pawn(Owner).controller).m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(R6Pawn(Owner), MCV_SmokeThrow);
		}
    }
    
    Super.ServerSetGrenade(eGrenade);
}

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.R6SmokeGrenade'
     m_pFPWeaponClass=Class'R61stWeapons.R61stGrenadeSmoke'
     m_EquipSnd=Sound'Foley_SmokeGrenade.Play_Smoke_Equip'
     m_UnEquipSnd=Sound'Foley_SmokeGrenade.Play_Smoke_Unequip'
     m_SingleFireStereoSnd=Sound'Grenade_Smoke.Play_SmokeGrenade_Expl'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_HUDTexturePos=(W=32.000000,X=200.000000,Y=384.000000,Z=100.000000)
     m_NameID="SmokeGrenadeGadget"
}
