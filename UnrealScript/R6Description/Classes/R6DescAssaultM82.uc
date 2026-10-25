//============================================================================//
//  R6DescAssaultM82.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultM82 extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=39
     m_ARangePercent(1)=39
     m_ARangePercent(2)=19
     m_ADamagePercent(0)=57
     m_ADamagePercent(1)=57
     m_ADamagePercent(2)=28
     m_AAccuracyPercent(0)=55
     m_AAccuracyPercent(1)=55
     m_AAccuracyPercent(2)=68
     m_ARecoilPercent(0)=48
     m_ARecoilPercent(1)=63
     m_ARecoilPercent(2)=99
     m_ARecoveryPercent(0)=92
     m_ARecoveryPercent(1)=88
     m_ARecoveryPercent(2)=88
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultM82"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultM82"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultM82"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG556mm'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc556mmNATOFMJ'
     m_MagTag="R63RDMAG556MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(X=129,Y=308)
     m_NameID="ASSAULTM82"
}
