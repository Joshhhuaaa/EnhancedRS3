//============================================================================//
//  R6DescAssaultFAL.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescAssaultFAL extends R6AssaultDescription;

defaultproperties
{
     m_ARangePercent(0)=49
     m_ARangePercent(1)=49
     m_ARangePercent(2)=19
     m_ADamagePercent(0)=99
     m_ADamagePercent(1)=99
     m_ADamagePercent(2)=49
     m_AAccuracyPercent(0)=74
     m_AAccuracyPercent(1)=74
     m_AAccuracyPercent(2)=89
     m_ARecoilPercent(0)=33
     m_ARecoilPercent(1)=60
     m_ARecoilPercent(2)=91
     m_ARecoveryPercent(0)=85
     m_ARecoveryPercent(1)=76
     m_ARecoveryPercent(2)=80
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalAssaultFAL"
     m_WeaponClasses(1)="R63rdWeapons.CMagAssaultFAL"
     m_WeaponClasses(2)="R63rdWeapons.SilencedAssaultFAL"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG762mm'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc762mmNATOFMJ'
     m_MagTag="R63RDMAG762MM2"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(Y=77)
     m_NameID="ASSAULTFAL"
}
