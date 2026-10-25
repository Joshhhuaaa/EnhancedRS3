//============================================================================//
//  R6DescSubUMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubUMP extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=10
     m_ARangePercent(1)=10
     m_ARangePercent(2)=8
     m_ADamagePercent(0)=26
     m_ADamagePercent(1)=26
     m_ADamagePercent(2)=21
     m_AAccuracyPercent(0)=43
     m_AAccuracyPercent(1)=43
     m_AAccuracyPercent(2)=52
     m_ARecoilPercent(0)=66
     m_ARecoilPercent(1)=87
     m_ARecoilPercent(2)=78
     m_ARecoveryPercent(0)=96
     m_ARecoveryPercent(1)=85
     m_ARecoveryPercent(2)=92
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubUMP"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubUMP"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubUMP"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG9mmUMP'
     m_MyGadgets(2)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc45calAutoFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc45calAutoJHP'
     m_MagTag="R63RDMAG10MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=129,Y=154)
     m_NameID="SUBUMP"
}
