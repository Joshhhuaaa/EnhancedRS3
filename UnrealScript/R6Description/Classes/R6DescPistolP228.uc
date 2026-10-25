//============================================================================//
//  R6DescPistolP228.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistolP228 extends R6PistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=11
     m_ARangePercent(1)=11
     m_ARangePercent(2)=7
     m_ADamagePercent(0)=17
     m_ADamagePercent(1)=17
     m_ADamagePercent(2)=12
     m_AAccuracyPercent(0)=32
     m_AAccuracyPercent(1)=32
     m_AAccuracyPercent(2)=40
     m_ARecoilPercent(0)=33
     m_ARecoilPercent(1)=45
     m_ARecoilPercent(2)=63
     m_ARecoveryPercent(0)=90
     m_ARecoveryPercent(1)=89
     m_ARecoveryPercent(2)=87
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistolP228"
     m_WeaponClasses(1)="R63rdWeapons.CMagPistolP228"
     m_WeaponClasses(2)="R63rdWeapons.SilencedPistolP228"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGPistolHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerPistol'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc9mmParabellumJHP'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(Y=231,W=64,H=53)
     m_NameID="PISTOLP228"
}
