class SilencedAssaultType89F extends AssaultType89F;

#exec OBJ LOAD FILE=..\Sounds\CommonAssaultRiffles.uax PACKAGE=CommonAssaultRiffles
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Assault_Type89F_Reloads.uax PACKAGE=Assault_Type89F_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Assault_Type89F_Silenced.uax PACKAGE=Assault_Type89F_Silenced

defaultproperties
{
    m_iClipCapacity=30
    m_iNbOfClips=6
    m_iNbOfExtraClips=3
    m_fMuzzleVelocity=30000.0
    m_MuzzleScale=0.230531
    m_fFireSoundRadius=300.0
    m_fRateOfFire=0.08
    m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=0.53564996,fShuffleAccuracy=2.683655,fWalkingAccuracy=4.0254827,fWalkingFastAccuracy=16.605116,fRunningAccuracy=16.605116,fReticuleTime=1.151125,fAccuracyChange=3.0952296,fWeaponJump=0.93292683)
    m_szReticuleClass="RIFLE"
    m_bIsSilenced=true
    m_fFireAnimRate=1.25
    m_fFPBlend=0.75
    m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
    m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
    m_ReloadSnd=Sound'Assault_Type89F_Reloads.Play_Type89F_Reload'
    m_ReloadEmptySnd=Sound'Assault_Type89F_Reloads.Play_Type89F_ReloadEmpty'
    m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
    m_SingleFireStereoSnd=Sound'Assault_Type89F_Silenced.Play_Type89FSil_SingleShots'
    m_BurstFireStereoSnd=Sound'Assault_Type89F_Silenced.Play_Type89FSil_TripleShots'
    m_FullAutoStereoSnd=Sound'Assault_Type89F_Silenced.Play_Type89FSil_AutoShots'
    m_FullAutoEndStereoSnd=Sound'Assault_Type89F_Silenced.Stop_Type89FSil_AutoShots_Go'
    m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
    m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
