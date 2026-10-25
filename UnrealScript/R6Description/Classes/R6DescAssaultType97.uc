//============================================================================//
//  R6DescAssaultType97.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultType97 extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=39
     m_ARangePercent(1)=39
     m_ARangePercent(2)=19
     m_ADamagePercent(0)=53
     m_ADamagePercent(1)=53
     m_ADamagePercent(2)=26
     m_AAccuracyPercent(0)=41
     m_AAccuracyPercent(1)=41
     m_AAccuracyPercent(2)=53
     m_ARecoilPercent(0)=31
     m_ARecoilPercent(1)=55
     m_ARecoilPercent(2)=98
     m_ARecoveryPercent(0)=98
     m_ARecoveryPercent(1)=93
     m_ARecoveryPercent(2)=93
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultType97"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultType97"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultType97"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG556mm'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc556mmNATOFMJ'
     m_MagTag="R63RDMAG556MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(Y=385)
     m_NameID="ASSAULTTYPE97"
}
