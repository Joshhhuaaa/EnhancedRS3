//============================================================================//
//  R6DescAssaultFAMASG2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultFAMASG2 extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=39
     m_ARangePercent(1)=39
     m_ARangePercent(2)=19
     m_ADamagePercent(0)=56
     m_ADamagePercent(1)=56
     m_ADamagePercent(2)=28
     m_AAccuracyPercent(0)=60
     m_AAccuracyPercent(1)=60
     m_AAccuracyPercent(2)=73
     m_ARecoilPercent(0)=52
     m_ARecoilPercent(1)=66
     m_ARecoilPercent(2)=99
     m_ARecoveryPercent(0)=91
     m_ARecoveryPercent(1)=87
     m_ARecoveryPercent(2)=87
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultFAMASG2"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultFAMASG2"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultFAMASG2"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG556mm'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc556mmNATOFMJ'
     m_MagTag="R63RDMAG556MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(X=129,Y=77)
     m_NameID="ASSAULTFAMASG2"
}
