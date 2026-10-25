//============================================================================//
//  R6DescSniperPSG1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSniperPSG1 extends R6SniperDescription;

defaultproperties
{
     m_ARangePercent(0)=49
     m_ARangePercent(1)=19
     m_ADamagePercent(0)=98
     m_ADamagePercent(1)=54
     m_AAccuracyPercent(0)=83
     m_AAccuracyPercent(1)=95
     m_ARecoilPercent(0)=16
     m_ARecoilPercent(1)=85
     m_ARecoveryPercent(0)=42
     m_ARecoveryPercent(1)=35
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSniperPSG1"
     m_WeaponClasses(1)="R63rdWeapons.SilencedSniperPSG1"
     m_MyGadgets(0)=Class'R6Description.R6DescSilencerSnipers'
     m_MyGadgets(1)=Class'R6Description.R6DescThermalScope'
     m_Bullets(0)=Class'R6Description.R6Desc762mmNATOFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc762mmNATOJHP'
     m_MagTag="R63RDMAG762MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(Y=231)
     m_NameID="SNIPERPSG1"
}
