//============================================================================//
//  R6DescShotgunUSAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescShotgunUSAS12 extends R6ShotgunDescription;

defaultproperties
{
     m_ARangePercent(0)=8
     m_ARangePercent(1)=8
     m_ADamagePercent(0)=100
     m_ADamagePercent(1)=100
     m_AAccuracyPercent(0)=1
     m_AAccuracyPercent(1)=1
     m_ARecoilPercent(0)=46
     m_ARecoilPercent(1)=46
     m_ARecoveryPercent(0)=77
     m_ARecoveryPercent(1)=77
     m_WeaponTags(0)="BUCK"
     m_WeaponTags(1)="SLUG"
     m_WeaponClasses(0)="R63rdWeapons.BuckShotgunUSAS12"
     m_WeaponClasses(1)="R63rdWeapons.SlugShotgunUSAS12"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_Bullets(0)=Class'R6Description.R6Desc12gaugeBuck'
     m_Bullets(1)=Class'R6Description.R6Desc12gaugeSlug'
     m_MagTag="SHOTGUNUSAS12"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=258,Y=77)
     m_NameID="SHOTGUNUSAS12"
}
