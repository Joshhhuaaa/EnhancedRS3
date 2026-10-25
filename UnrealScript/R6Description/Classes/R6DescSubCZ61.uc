//============================================================================//
//  R6DescSubCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubCZ61 extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=6
     m_ARangePercent(1)=6
     m_ARangePercent(2)=4
     m_ADamagePercent(0)=6
     m_ADamagePercent(1)=6
     m_ADamagePercent(2)=4
     m_AAccuracyPercent(0)=30
     m_AAccuracyPercent(1)=30
     m_AAccuracyPercent(2)=40
     m_ARecoilPercent(0)=85
     m_ARecoilPercent(1)=89
     m_ARecoilPercent(2)=91
     m_ARecoveryPercent(0)=100
     m_ARecoveryPercent(1)=99
     m_ARecoveryPercent(2)=97
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalSubCZ61"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubCZ61"
     m_WeaponClasses(2)="R63rdWeapons.SilencedSubCZ61"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGCZ61High2'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerSubGuns'
     m_Bullets(0)=Class'R6Description.R6Desc765mmAutoFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc765mmAutoJHP'
     m_MagTag="R63RDMAGCZ61"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(Y=77)
     m_NameID="SUBCZ61"
}
