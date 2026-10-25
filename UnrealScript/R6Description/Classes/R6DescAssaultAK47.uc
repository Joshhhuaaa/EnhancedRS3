//============================================================================//
//  R6DescAssaultAK47.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultAK47 extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=37
     m_ARangePercent(1)=37
     m_ARangePercent(2)=15
     m_ADamagePercent(0)=80
     m_ADamagePercent(1)=80
     m_ADamagePercent(2)=40
     m_AAccuracyPercent(0)=56
     m_AAccuracyPercent(1)=56
     m_AAccuracyPercent(2)=72
     m_ARecoilPercent(0)=34
     m_ARecoilPercent(1)=57
     m_ARecoilPercent(2)=89
     m_ARecoveryPercent(0)=90
     m_ARecoveryPercent(1)=83
     m_ARecoveryPercent(2)=85
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultAK47"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultAK47"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultAK47"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescDrumMAGAK'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc762mmM43FMJ'
     m_MagTag="R63RDMAGAK47"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_NameID="ASSAULTAK47"
}
