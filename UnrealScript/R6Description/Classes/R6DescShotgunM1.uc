//============================================================================//
//  R6DescShotgunM1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescShotgunM1 extends R6ShotgunDescription;

defaultproperties
{
     m_ARangePercent(0)=8
     m_ARangePercent(1)=8
     m_ADamagePercent(0)=100
     m_ADamagePercent(1)=100
     m_AAccuracyPercent(0)=1
     m_AAccuracyPercent(1)=1
     m_ARecoilPercent(0)=5
     m_ARecoilPercent(1)=5
     m_ARecoveryPercent(0)=91
     m_ARecoveryPercent(1)=91
     m_WeaponTags(0)="BUCK"
     m_WeaponTags(1)="SLUG"
     m_WeaponClasses(0)="R63rdWeapons.BuckShotgunM1"
     m_WeaponClasses(1)="R63rdWeapons.SlugShotgunM1"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_Bullets(0)=Class'R6Description.R6Desc12gaugeBuck'
     m_Bullets(1)=Class'R6Description.R6Desc12gaugeSlug'
     m_MagTag="SHOTGUNM1"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(Y=77)
     m_NameID="SHOTGUNM1"
}
