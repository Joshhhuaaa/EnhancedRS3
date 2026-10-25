//============================================================================//
//  R6DescPistolSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistolSR2 extends R6MachinePistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=12
     m_ARangePercent(1)=12
     m_ADamagePercent(0)=20
     m_ADamagePercent(1)=20
     m_AAccuracyPercent(0)=26
     m_AAccuracyPercent(1)=26
     m_ARecoilPercent(0)=59
     m_ARecoilPercent(1)=63
     m_ARecoveryPercent(0)=85
     m_ARecoveryPercent(1)=85
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistolSR2"
     m_WeaponClasses(1)="R63rdWeapons.CMagPistolSR2"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGPistolHigh'
     m_Bullets(0)=Class'R6Description.R6Desc9x21mmRFMJ'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=256,Y=231,W=64,H=53)
     m_NameID="PISTOLSR2"
}
