//============================================================================//
//  R6DescSubTMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubTMP extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=11
     m_ARangePercent(1)=11
     m_ARangePercent(2)=7
     m_ADamagePercent(0)=15
     m_ADamagePercent(1)=15
     m_ADamagePercent(2)=8
     m_AAccuracyPercent(0)=31
     m_AAccuracyPercent(1)=31
     m_AAccuracyPercent(2)=46
     m_ARecoilPercent(0)=75
     m_ARecoilPercent(1)=78
     m_ARecoilPercent(2)=87
     m_ARecoveryPercent(0)=99
     m_ARecoveryPercent(1)=98
     m_ARecoveryPercent(2)=95
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubTMP"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubTMP"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubTMP"
     m_MyGadgets(0)=Class'R6Description.R6DescMAG9mmHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc9mmParabellumJHP'
     m_MagTag="R63RDMAG9MMSTRAIGHT"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(Y=154)
     m_NameID="SUBTMP"
}
