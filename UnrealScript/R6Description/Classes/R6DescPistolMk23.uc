//============================================================================//
//  R6DescPistolMk23.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistolMk23 extends R6PistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=10
     m_ARangePercent(1)=10
     m_ARangePercent(2)=8
     m_ADamagePercent(0)=19
     m_ADamagePercent(1)=19
     m_ADamagePercent(2)=19
     m_AAccuracyPercent(0)=35
     m_AAccuracyPercent(1)=35
     m_AAccuracyPercent(2)=42
     m_ARecoilPercent(0)=53
     m_ARecoilPercent(1)=62
     m_ARecoilPercent(2)=62
     m_ARecoveryPercent(0)=88
     m_ARecoveryPercent(1)=86
     m_ARecoveryPercent(2)=85
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistolMk23"
     m_WeaponClasses(1)="R63rdWeapons.CMagPistolMk23"
     m_WeaponClasses(2)="R63rdWeapons.SilencedPistolMk23"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGPistolHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerPistol'
     m_Bullets(0)=Class'R6Description.R6Desc45calAutoFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc45calAutoJHP'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=387,Y=159,W=64,H=53)
     m_NameID="PISTOLMK23"
}
