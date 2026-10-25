//============================================================================//
//  R6DescAssaultM14.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultM14 extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=49
     m_ARangePercent(1)=49
     m_ARangePercent(2)=19
     m_ADamagePercent(0)=100
     m_ADamagePercent(1)=100
     m_ADamagePercent(2)=50
     m_AAccuracyPercent(0)=76
     m_AAccuracyPercent(1)=76
     m_AAccuracyPercent(2)=91
     m_ARecoilPercent(0)=40
     m_ARecoilPercent(1)=62
     m_ARecoilPercent(2)=92
     m_ARecoveryPercent(0)=83
     m_ARecoveryPercent(1)=73
     m_ARecoveryPercent(2)=78
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultM14"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultM14"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultM14"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG762mm'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc762mmNATOFMJ'
     m_MagTag="R63RDMAG762MM2"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(X=129,Y=231)
     m_NameID="ASSAULTM14"
}
