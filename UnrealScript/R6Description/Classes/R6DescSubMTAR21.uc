//============================================================================//
//  R6DescSubMTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubMTAR21 extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=15
     m_ARangePercent(1)=15
     m_ARangePercent(2)=9
     m_ADamagePercent(0)=15
     m_ADamagePercent(1)=15
     m_ADamagePercent(2)=8
     m_AAccuracyPercent(0)=34
     m_AAccuracyPercent(1)=34
     m_AAccuracyPercent(2)=48
     m_ARecoilPercent(0)=81
     m_ARecoilPercent(1)=88
     m_ARecoilPercent(2)=91
     m_ARecoveryPercent(0)=93
     m_ARecoveryPercent(1)=90
     m_ARecoveryPercent(2)=90
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubMTAR21"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubMTAR21"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubMTAR21"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG9mmMTAR21'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc9mmParabellumJHP'
     m_MagTag="R63RDMAG556MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=129)
     m_NameID="SUBMTAR21"
}
