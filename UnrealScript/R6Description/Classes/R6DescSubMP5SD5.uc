//============================================================================//
//  R6DescSubMP5SD5.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescSubMP5SD5 extends R6SubGunDescription;

defaultproperties
{
     m_ARangePercent(0)=7
     m_ARangePercent(1)=7
     m_ADamagePercent(0)=8
     m_ADamagePercent(1)=8
     m_AAccuracyPercent(0)=47
     m_AAccuracyPercent(1)=47
     m_ARecoilPercent(0)=91
     m_ARecoilPercent(1)=94
     m_ARecoveryPercent(0)=93
     m_ARecoveryPercent(1)=90
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponClasses(0)="R63rdWeapons.SilencedSubMP5SD5"
     m_WeaponClasses(1)="R63rdWeapons.CMagSubMP5SD5"
     m_MyGadgets(0)=Class'R6Description.R6DescMiniScope'
     m_MyGadgets(1)=Class'R6Description.R6DescCMAG9mmMP5'
     m_Bullets(0)=Class'R6Description.R6Desc9mmParabellumFMJ'
     m_MagTag="R63RDMAG9MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=258,Y=385)
     m_NameID="SUBMP5SD5"
}
