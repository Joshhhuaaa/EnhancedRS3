//============================================================================//
//  R6DescAssaultAK74.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultAK74 extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=37
     m_ARangePercent(1)=37
     m_ARangePercent(2)=17
     m_ADamagePercent(0)=53
     m_ADamagePercent(1)=53
     m_ADamagePercent(2)=26
     m_AAccuracyPercent(0)=64
     m_AAccuracyPercent(1)=64
     m_AAccuracyPercent(2)=78
     m_ARecoilPercent(0)=49
     m_ARecoilPercent(1)=64
     m_ARecoilPercent(2)=99
     m_ARecoveryPercent(0)=91
     m_ARecoveryPercent(1)=87
     m_ARecoveryPercent(2)=86
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultAK74"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultAK74"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultAK74"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescDrumMAGAK'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc545mm7N6FMJ'
     m_MagTag="R63RDMAGAK74"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(X=129)
     m_NameID="ASSAULTAK74"
}
