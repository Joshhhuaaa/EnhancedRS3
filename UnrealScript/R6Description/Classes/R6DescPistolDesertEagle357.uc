//============================================================================//
//  R6DescPistolDesertEagle357.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistolDesertEagle357 extends R6PistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=15
     m_ARangePercent(1)=15
     m_ARangePercent(2)=8
     m_ADamagePercent(0)=34
     m_ADamagePercent(1)=34
     m_ADamagePercent(2)=17
     m_AAccuracyPercent(0)=37
     m_AAccuracyPercent(1)=37
     m_AAccuracyPercent(2)=44
     m_ARecoilPercent(0)=32
     m_ARecoilPercent(1)=45
     m_ARecoilPercent(2)=78
     m_ARecoveryPercent(0)=86
     m_ARecoveryPercent(1)=85
     m_ARecoveryPercent(2)=84
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistolDesertEagle357"
     m_WeaponClasses(1)="R63rdWeapons.CMagPistolDesertEagle357"
     m_WeaponClasses(2)="R63rdWeapons.SilencedPistolDesertEagle357"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGPistolHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerPistol'
     m_Bullets(0)=Class'R6Description.R6Desc357calMagnumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc357calMagnumJHP'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=387,Y=106,W=64,H=53)
     m_NameID="PISTOLDESERTEAGLE357"
}
