//============================================================================//
//  R6DescAssaultFNC.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultFNC extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=39
     m_ARangePercent(1)=39
     m_ARangePercent(2)=19
     m_ADamagePercent(0)=62
     m_ADamagePercent(1)=62
     m_ADamagePercent(2)=31
     m_AAccuracyPercent(0)=72
     m_AAccuracyPercent(1)=72
     m_AAccuracyPercent(2)=84
     m_ARecoilPercent(0)=57
     m_ARecoilPercent(1)=67
     m_ARecoilPercent(2)=100
     m_ARecoveryPercent(0)=86
     m_ARecoveryPercent(1)=82
     m_ARecoveryPercent(2)=82
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultFNC"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultFNC"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultFNC"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG556mm'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc556mmNATOFMJ'
     m_MagTag="R63RDMAG556MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(X=258,Y=77)
     m_NameID="ASSAULTFNC"
}
