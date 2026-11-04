class SilencedAssaultOTs14 extends AssaultOTs14;

#exec OBJ LOAD FILE=..\Sounds\CommonAssaultRiffles.uax PACKAGE=CommonAssaultRiffles
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_OTs_14_Reloads.uax PACKAGE=MP1_Assault_OTs_14_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_OTs_14_Silenced.uax PACKAGE=MP1_Assault_OTs_14_Silenced
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R63rdItalianWeapons_SM.usx PACKAGE=R63rdItalianWeapons_SM

defaultproperties
{
    m_iClipCapacity=20
    m_iNbOfClips=6
    m_iNbOfExtraClips=3
    m_fMuzzleVelocity=30000.0
    m_MuzzleScale=0.392531
    m_fFireSoundRadius=300.0
    m_fRateOfFire=0.08
    m_pBulletClass=Class'R6Weapons.ammo9x39mmSP6SubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.189378,fShuffleAccuracy=1.8338085,fWalkingAccuracy=2.7507129,fWalkingFastAccuracy=11.34669,fRunningAccuracy=11.34669,fReticuleTime=1.0163125,fAccuracyChange=5.5214725,fWeaponJump=4.044757)
    m_szReticuleClass="RIFLE"
    m_pFPHandsClass=Class'ASWeapons.R61stHandsAssaultOTs14Silenced'
    m_pFPWeaponClass=Class'ASWeapons.R61stAssaultOTs14Silenced'
    m_bIsSilenced=true
    m_fFireAnimRate=1.25
    m_fFPBlend=0.75
    m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
    m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
    m_ReloadSnd=Sound'MP1_Assault_OTs_14_Reloads.Play_Groza_Reload'
    m_ReloadEmptySnd=Sound'MP1_Assault_OTs_14_Reloads.Play_Groza_EmptyMag'
    m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
    m_SingleFireStereoSnd=Sound'MP1_Assault_OTs_14_Silenced.Play_GrozaSil_SingleShots'
    m_FullAutoStereoSnd=Sound'MP1_Assault_OTs_14_Silenced.Play_GrozaSil_AutoShots'
    m_FullAutoEndStereoSnd=Sound'MP1_Assault_OTs_14_Silenced.Stop_GrozaSil_AutoShots_Go'
    m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
    m_PawnWaitAnimLow="StandUZILow_nt"
    m_PawnWaitAnimHigh="StandUZIHigh_nt"
    m_PawnWaitAnimProne="ProneUZI_nt"
    m_PawnFiringAnim="StandFireUZI"
    m_PawnFiringAnimProne="ProneFireUZI"
    m_szMagazineClass="ASWeapons.R63rdMAGOTs14"
    StaticMesh=StaticMesh'R63rdItalianWeapons_SM.AssaultRifles.R63rdOTs14ForSilencer'
}
