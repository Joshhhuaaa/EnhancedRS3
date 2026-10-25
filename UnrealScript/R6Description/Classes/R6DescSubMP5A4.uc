//============================================================================//
//  R6DescSubMP5A4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubMP5A4 extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=11
     m_ARangePercent(1)=11
     m_ARangePercent(2)=7
     m_ADamagePercent(0)=21
     m_ADamagePercent(1)=21
     m_ADamagePercent(2)=10
     m_AAccuracyPercent(0)=44
     m_AAccuracyPercent(1)=44
     m_AAccuracyPercent(2)=53
     m_ARecoilPercent(0)=75
     m_ARecoilPercent(1)=83
     m_ARecoilPercent(2)=91
     m_ARecoveryPercent(0)=95
     m_ARecoveryPercent(1)=92
     m_ARecoveryPercent(2)=92
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubMP5A4"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubMP5A4"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubMP5A4"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG9mmMP5'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc9mmParabellumJHP'
     m_MagTag="R63RDMAG9MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(Y=385)
     m_NameID="SUBMP5A4"
}
