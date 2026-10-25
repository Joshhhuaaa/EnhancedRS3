//============================================================================//
//  R6DescLMG23E.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescLMG23E extends R6LMGDescription;

defaultproperties
{
     m_ARangePercent(0)=39
     m_ADamagePercent(0)=60
     m_AAccuracyPercent(0)=45
     m_ARecoilPercent(0)=75
     m_ARecoveryPercent(0)=66
     m_WeaponTags(0)="NORMAL"
     m_WeaponClasses(0)="R63rdWeapons.NormalLMG23E"
     m_MyGadgets(0)=Class'R6Description.R6DescWeaponGadgetNone'
     m_Bullets(0)=Class'R6Description.R6Desc556mmNATOFMJ'
     m_MagTag="R63RDMAGBOX556MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(X=258,Y=385)
     m_NameID="LMG23E"
}
