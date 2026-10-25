//============================================================================//
//  R6DescAssaultM4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultM4 extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=39
     m_ARangePercent(1)=39
     m_ARangePercent(2)=19
     m_ADamagePercent(0)=56
     m_ADamagePercent(1)=56
     m_ADamagePercent(2)=28
     m_AAccuracyPercent(0)=49
     m_AAccuracyPercent(1)=49
     m_AAccuracyPercent(2)=59
     m_ARecoilPercent(0)=47
     m_ARecoilPercent(1)=66
     m_ARecoilPercent(2)=99
     m_ARecoveryPercent(0)=96
     m_ARecoveryPercent(1)=92
     m_ARecoveryPercent(2)=92
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultM4"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultM4"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultM4"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG556mm'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc556mmNATOFMJ'
     m_MagTag="R63RDMAG556MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(Y=308)
     m_NameID="ASSAULTM4"
}
