//============================================================================//
//  R6DescSubMP510A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubMP510A2 extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=10
     m_ARangePercent(1)=10
     m_ARangePercent(2)=7
     m_ADamagePercent(0)=39
     m_ADamagePercent(1)=39
     m_ADamagePercent(2)=19
     m_AAccuracyPercent(0)=43
     m_AAccuracyPercent(1)=43
     m_AAccuracyPercent(2)=53
     m_ARecoilPercent(0)=44
     m_ARecoilPercent(1)=64
     m_ARecoilPercent(2)=82
     m_ARecoveryPercent(0)=94
     m_ARecoveryPercent(1)=89
     m_ARecoveryPercent(2)=91
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubMP510A2"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubMP510A2"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubMP510A2"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG9mmMP5'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc10mmAutoFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc10mmAutoJHP'
     m_MagTag="R63RDMAG10MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=258,Y=308)
     m_NameID="SUBMP510A2"
}
