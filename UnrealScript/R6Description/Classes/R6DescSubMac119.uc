//============================================================================//
//  R6DescSubMac119.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubMac119 extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=11
     m_ARangePercent(1)=11
     m_ARangePercent(2)=7
     m_ADamagePercent(0)=15
     m_ADamagePercent(1)=15
     m_ADamagePercent(2)=8
     m_AAccuracyPercent(0)=13
     m_AAccuracyPercent(1)=13
     m_AAccuracyPercent(2)=27
     m_ARecoilPercent(0)=72
     m_ARecoilPercent(1)=76
     m_ARecoilPercent(2)=86
     m_ARecoveryPercent(0)=100
     m_ARecoveryPercent(1)=99
     m_ARecoveryPercent(2)=97
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubMac119"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubMac119"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubMac119"
     m_MyGadgets(0)=Class'R6Description.R6DescMAG9mmHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc9mmParabellumJHP'
     m_MagTag="R63RDMAG9MMSTRAIGHT"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=129,Y=77)
     m_NameID="SUBMAC119"
}
