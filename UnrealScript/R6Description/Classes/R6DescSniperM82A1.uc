//============================================================================//
//  R6DescSniperM82A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSniperM82A1 extends R6SniperDescription;

defaultproperties
{
     m_ARangePercent(0)=100
     m_ARangePercent(1)=57
     m_ADamagePercent(0)=100
     m_ADamagePercent(1)=100
     m_AAccuracyPercent(0)=89
     m_AAccuracyPercent(1)=100
     m_ARecoilPercent(0)=1
     m_ARecoilPercent(1)=82
     m_ARecoveryPercent(0)=9
     m_ARecoveryPercent(1)=1
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSniperM82A1"
     m_WeaponClasses(1)="R63rdWeapons.SilencedSniperM82A1"
     m_MyGadgets(0)=Class'R6Description.R6DescSilencerSnipers'
     m_MyGadgets(1)=Class'R6Description.R6DescThermalScope'
     m_Bullets(0)=Class'R6Description.R6Desc50calM33FMJ'
     m_Bullets(1)=Class'R6Description.R6Desc50calM33JHP'
     m_MagTag="R63RDMAGM82A1"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=258,Y=154)
     m_NameID="SNIPERM82A1"
}
