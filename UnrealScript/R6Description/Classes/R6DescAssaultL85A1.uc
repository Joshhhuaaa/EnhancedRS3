//============================================================================//
//  R6DescAssaultL85A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultL85A1 extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=39
     m_ARangePercent(1)=39
     m_ARangePercent(2)=19
     m_ADamagePercent(0)=58
     m_ADamagePercent(1)=58
     m_ADamagePercent(2)=24
     m_AAccuracyPercent(0)=63
     m_AAccuracyPercent(1)=63
     m_AAccuracyPercent(2)=75
     m_ARecoilPercent(0)=53
     m_ARecoilPercent(1)=66
     m_ARecoilPercent(2)=100
     m_ARecoveryPercent(0)=90
     m_ARecoveryPercent(1)=86
     m_ARecoveryPercent(2)=86
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultL85A1"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultL85A1"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultL85A1"
     m_MyGadgets(0)=Class'R6Description.R6DescCMAG556mm'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc556mmNATOFMJ'
     m_MagTag="R63RDMAG556MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(Y=231)
     m_NameID="ASSAULTL85A1"
}
