//============================================================================//
//  R6DescSubM12S.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubM12S extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=11
     m_ARangePercent(1)=11
     m_ARangePercent(2)=7
     m_ADamagePercent(0)=25
     m_ADamagePercent(1)=25
     m_ADamagePercent(2)=13
     m_AAccuracyPercent(0)=39
     m_AAccuracyPercent(1)=39
     m_AAccuracyPercent(2)=45
     m_ARecoilPercent(0)=70
     m_ARecoilPercent(1)=77
     m_ARecoilPercent(2)=90
     m_ARecoveryPercent(0)=93
     m_ARecoveryPercent(1)=90
     m_ARecoveryPercent(2)=91
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubM12S"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubM12S"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubM12S"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG9mmUMP'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc9mmParabellumJHP'
     m_MagTag="R63RDMAG9MMSTRAIGHT"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=129,Y=308)
     m_NameID="SUBM12S"
}
