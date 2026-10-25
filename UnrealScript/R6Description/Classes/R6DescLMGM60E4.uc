//============================================================================//
//  R6DescLMGM60E4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescLMGM60E4 extends R6LMGDescription;

defaultproperties
{
     m_ARangePercent(0)=49
     m_ADamagePercent(0)=100
     m_AAccuracyPercent(0)=47
     m_ARecoilPercent(0)=60
     m_ARecoveryPercent(0)=63
     m_WeaponTags(0)="NORMAL"
     m_WeaponClasses(0)="R63rdWeapons.NormalLMGM60E4"
     m_MyGadgets(0)=Class'R6Description.R6DescWeaponGadgetNone'
     m_Bullets(0)=Class'R6Description.R6Desc762mmNATOFMJ'
     m_MagTag="R63RDMAGBOX762MM"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=129)
     m_NameID="LMGM60E4"
}
