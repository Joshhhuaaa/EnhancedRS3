//=============================================================================
//  R6PawnReplicationInfo.uc : replicates weapon's infos
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/11 * Created by Serge Doré
//=============================================================================

class R6PawnReplicationInfo extends Actor
    native;

var Controller  m_ControllerOwner;          // REPLICATED: Owner
var BYTE        m_PawnType;                 // REPLICATED: Pawn Type
var BOOL        m_bSex;                     // REPLICATED: Sex of the player
var BOOL        m_bDoNotPlayFullAutoSound;  // Assure that the sound will not be played when the player is dead.

var Sound       m_TriggerSnd[4];
var Sound       m_SingleFireStereoSnd[4];
var Sound       m_SingleFireEndStereoSnd[4];
var Sound       m_BurstFireStereoSnd[4];
var Sound       m_FullAutoStereoSnd[4];
var Sound       m_FullAutoEndStereoSnd[4];
var Sound       m_EmptyMagSnd[4];
var Sound       m_ReloadEmptySnd[4];
var Sound       m_ReloadSnd[4];
var Sound       m_ShellSingleFireSnd[4];
var Sound       m_ShellBurstFireSnd[4];
var Sound       m_ShellFullAutoSnd[4];
var Sound       m_ShellEndFullAutoSnd[4];

replication
{
    reliable if (Role == ROLE_Authority)
        m_ControllerOwner, m_PawnType, m_bSex;
}

simulated function ResetOriginalData()
{
    #ifdefDEBUG if ( m_bResetSystemLog ) LogResetSystem( false );   #endif
    Super.ResetOriginalData();
    m_bDoNotPlayFullAutoSound = false;
}

// only set on the client side
simulated function AssignSound(class<R6EngineWeapon> WeaponClass, BYTE u8CurrentWepon)
{
    // passive gadgets are not R6AbstractWeapon types
    if(WeaponClass != none)
    {			
        m_TriggerSnd[u8CurrentWepon] = WeaponClass.default.m_TriggerSnd;
        m_SingleFireStereoSnd[u8CurrentWepon] = WeaponClass.default.m_SingleFireStereoSnd;
        m_SingleFireEndStereoSnd[u8CurrentWepon] = WeaponClass.default.m_SingleFireEndStereoSnd;
        m_BurstFireStereoSnd[u8CurrentWepon] = WeaponClass.default.m_BurstFireStereoSnd;
        m_FullAutoStereoSnd[u8CurrentWepon] = WeaponClass.default.m_FullAutoStereoSnd;
        m_FullAutoEndStereoSnd[u8CurrentWepon] = WeaponClass.default.m_FullAutoEndStereoSnd;
        m_ReloadSnd[u8CurrentWepon] = WeaponClass.default.m_ReloadSnd;
        m_ReloadEmptySnd[u8CurrentWepon] = WeaponClass.default.m_ReloadEmptySnd;
        m_EmptyMagSnd[u8CurrentWepon] = WeaponClass.default.m_EmptyMagSnd;
        m_ShellSingleFireSnd[u8CurrentWepon] = WeaponClass.default.m_ShellSingleFireSnd;
        m_ShellBurstFireSnd[u8CurrentWepon] = WeaponClass.default.m_ShellBurstFireSnd;
        m_ShellFullAutoSnd[u8CurrentWepon] = WeaponClass.default.m_ShellFullAutoSnd;
        m_ShellEndFullAutoSnd[u8CurrentWepon] = WeaponClass.default.m_ShellEndFullAutoSnd;

	    AddAndFindBankInSound(WeaponClass.default.m_EquipSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_UnEquipSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_ReloadSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_ReloadEmptySnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_ChangeROFSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_SingleFireStereoSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_SingleFireEndStereoSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_BurstFireStereoSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_FullAutoStereoSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_FullAutoEndStereoSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_EmptyMagSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_TriggerSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_ShellSingleFireSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_ShellBurstFireSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_ShellFullAutoSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_ShellEndFullAutoSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_SniperZoomFirstSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_SniperZoomSecondSnd, LBS_Gun);
	    AddAndFindBankInSound(WeaponClass.default.m_CommonWeaponZoomSnd, LBS_Gun);  
	    AddAndFindBankInSound(WeaponClass.default.m_BipodSnd, LBS_Gun);
    }

}

defaultproperties
{
     m_PawnType=1
     RemoteRole=ROLE_AutonomousProxy
     DrawType=DT_None
     bHidden=True
     bAlwaysRelevant=True
     bSkipActorPropertyReplication=True
     NetUpdateFrequency=5.000000
}
