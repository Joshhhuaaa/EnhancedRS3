//============================================================================//
//  R6DescPistol92FS.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistol92FS extends R6PistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=11
     m_ARangePercent(1)=11
     m_ARangePercent(2)=7
     m_ADamagePercent(0)=19
     m_ADamagePercent(1)=19
     m_ADamagePercent(2)=12
     m_AAccuracyPercent(0)=34
     m_AAccuracyPercent(1)=34
     m_AAccuracyPercent(2)=42
     m_ARecoilPercent(0)=34
     m_ARecoilPercent(1)=46
     m_ARecoilPercent(2)=67
     m_ARecoveryPercent(0)=89
     m_ARecoveryPercent(1)=88
     m_ARecoveryPercent(2)=86
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistol92FS"
     m_WeaponClasses(1)="R63rdWeapons.CMagPistol92FS"
     m_WeaponClasses(2)="R63rdWeapons.SilencedPistol92FS"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGPistolHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerPistol'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc9mmParabellumJHP'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=387,W=64,H=53)
     m_NameID="PISTOL92FS"
}
