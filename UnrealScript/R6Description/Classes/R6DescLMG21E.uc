//============================================================================//
//  R6DescLMG21E.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescLMG21E extends R6LMGDescription;

defaultproperties
{
     m_ARangePercent(0)=49
     m_ADamagePercent(0)=99
     m_AAccuracyPercent(0)=54
     m_ARecoilPercent(0)=61
     m_ARecoveryPercent(0)=62
     m_WeaponTags(0)="NORMAL"
     m_WeaponClasses(0)="R63rdWeapons.NormalLMG21E"
     m_MyGadgets(0)=Class'R6Description.R6DescWeaponGadgetNone'
     m_Bullets(0)=Class'R6Description.R6Desc762mmNATOFMJ'
     m_MagTag="R63RDMAGBOX762MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
     m_2dMenuRegion=(X=129,Y=385)
     m_NameID="LMG21E"
}
