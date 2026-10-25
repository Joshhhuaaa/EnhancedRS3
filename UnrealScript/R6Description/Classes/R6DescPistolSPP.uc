//============================================================================//
//  R6DescPistolSPP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistolSPP extends R6PistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=11
     m_ARangePercent(1)=7
     m_ADamagePercent(0)=15
     m_ADamagePercent(1)=12
     m_AAccuracyPercent(0)=21
     m_AAccuracyPercent(1)=31
     m_ARecoilPercent(0)=60
     m_ARecoilPercent(1)=74
     m_ARecoveryPercent(0)=87
     m_ARecoveryPercent(1)=85
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistolSPP"
     m_WeaponClasses(1)="R63rdWeapons.SilencedPistolSPP"
     m_MyGadgets(0)=Class'R6Description.R6DescSilencerPistol'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc9mmParabellumJHP'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=320,Y=231,W=64,H=53)
     m_NameID="PISTOLSPP"
}
