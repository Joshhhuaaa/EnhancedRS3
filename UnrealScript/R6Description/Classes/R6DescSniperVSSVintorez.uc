//============================================================================//
//  R6DescSniperVSSVintorez.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSniperVSSVintorez extends R6SniperDescription;

defaultproperties
{
     m_ARangePercent(0)=9
     m_ADamagePercent(0)=25
     m_AAccuracyPercent(0)=54
     m_ARecoilPercent(0)=76
     m_ARecoveryPercent(0)=70
     m_WeaponTags(0)="NORMAL"
     m_WeaponClasses(0)="R63rdWeapons.SilencedSniperVSSVintorez"
     m_MyGadgets(0)=Class'R6Description.R6DescThermalScope'
     m_Bullets(0)=Class'R6Description.R6Desc9x39mmSP6FMJ'
     m_MagTag="R63RDMAGVINTOREZ"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=258,Y=231)
     m_NameID="SNIPERVSSVINTOREZ"
}
