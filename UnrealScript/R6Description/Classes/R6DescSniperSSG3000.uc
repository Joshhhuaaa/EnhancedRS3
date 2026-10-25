//============================================================================//
//  R6DescSniperSSG3000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSniperSSG3000 extends R6SniperDescription;

defaultproperties
{
     m_ARangePercent(0)=71
     m_ARangePercent(1)=27
     m_ADamagePercent(0)=78
     m_ADamagePercent(1)=39
     m_AAccuracyPercent(0)=80
     m_AAccuracyPercent(1)=92
     m_ARecoilPercent(0)=58
     m_ARecoilPercent(1)=93
     m_ARecoveryPercent(0)=52
     m_ARecoveryPercent(1)=42
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSniperSSG3000"
     m_WeaponClasses(1)="R63rdWeapons.SilencedSniperSSG3000"
     m_MyGadgets(0)=Class'R6Description.R6DescSilencerSnipers'
     m_MyGadgets(1)=Class'R6Description.R6DescThermalScope'
     m_Bullets(0)=Class'R6Description.R6Desc762mmNATOFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc762mmNATOJHP'
     m_MagTag="R63RDMAG762MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=129,Y=231)
     m_NameID="SNIPERSSG3000"
}
