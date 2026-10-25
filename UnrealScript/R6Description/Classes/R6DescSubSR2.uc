//============================================================================//
//  R6DescSubSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubSR2 extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=12
     m_ARangePercent(1)=12
     m_ARangePercent(2)=6
     m_ADamagePercent(0)=20
     m_ADamagePercent(1)=20
     m_ADamagePercent(2)=10
     m_AAccuracyPercent(0)=35
     m_AAccuracyPercent(1)=35
     m_AAccuracyPercent(2)=44
     m_ARecoilPercent(0)=59
     m_ARecoilPercent(1)=68
     m_ARecoilPercent(2)=86
     m_ARecoveryPercent(0)=99
     m_ARecoveryPercent(1)=98
     m_ARecoveryPercent(2)=97
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubSR2"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubSR2"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubSR2"
     m_MyGadgets(0)=Class'R6Description.R6DescMAG9mmHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc9x21mmRFMJ'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_NameID="SUBSR2"
}
