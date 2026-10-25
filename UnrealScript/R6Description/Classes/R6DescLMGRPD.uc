//============================================================================//
//  R6DescLMGRPD.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescLMGRPD extends R6LMGDescription;

defaultproperties
{
     m_ARangePercent(0)=37
     m_ADamagePercent(0)=77
     m_AAccuracyPercent(0)=41
     m_ARecoilPercent(0)=61
     m_ARecoveryPercent(0)=70
     m_WeaponTags(0)="NORMAL"
     m_WeaponClasses(0)="R63rdWeapons.NormalLMGRPD"
     m_MyGadgets(0)=Class'R6Description.R6DescWeaponGadgetNone'
     m_Bullets(0)=Class'R6Description.R6Desc762mmM43FMJ'
     m_MagTag="R63RDMAGRPD"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
     m_2dMenuRegion=(X=258)
     m_NameID="LMGRPD"
}
