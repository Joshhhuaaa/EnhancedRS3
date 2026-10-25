//============================================================================//
//  R6DescPistolDesertEagle50.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistolDesertEagle50 extends R6PistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=20
     m_ARangePercent(1)=20
     m_ARangePercent(2)=10
     m_ADamagePercent(0)=70
     m_ADamagePercent(1)=70
     m_ADamagePercent(2)=34
     m_AAccuracyPercent(0)=36
     m_AAccuracyPercent(1)=36
     m_AAccuracyPercent(2)=44
     m_ARecoilPercent(0)=1
     m_ARecoilPercent(1)=7
     m_ARecoilPercent(2)=54
     m_ARecoveryPercent(0)=81
     m_ARecoveryPercent(1)=80
     m_ARecoveryPercent(2)=78
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistolDesertEagle50"
     m_WeaponClasses(1)="R63rdWeapons.CMagPistolDesertEagle50"
     m_WeaponClasses(2)="R63rdWeapons.SilencedPistolDesertEagle50"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGPistolHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerPistol'
     m_Bullets(0)=Class'R6Description.R6Desc50calPistolFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc50calPistolJHP'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=387,Y=106,W=64,H=53)
     m_NameID="PISTOLDESERTEAGLE50"
}
