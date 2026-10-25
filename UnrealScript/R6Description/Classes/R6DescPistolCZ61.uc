//============================================================================//
//  R6DescPistolCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistolCZ61 extends R6MachinePistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=6
     m_ARangePercent(1)=6
     m_ADamagePercent(0)=6
     m_ADamagePercent(1)=6
     m_AAccuracyPercent(0)=21
     m_AAccuracyPercent(1)=21
     m_ARecoilPercent(0)=85
     m_ARecoilPercent(1)=87
     m_ARecoveryPercent(0)=86
     m_ARecoveryPercent(1)=86
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistolCZ61"
     m_WeaponClasses(1)="R63rdWeapons.CMagPistolCZ61"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGCZ61High'
     m_Bullets(0)=Class'R6Description.R6Desc765mmAutoFMJ'
     m_Bullets(1)=Class'R6Description.R6Desc765mmAutoJHP'
     m_MagTag="R63RDMAGCZ61"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=64,Y=231,W=64,H=53)
     m_NameID="PISTOLCZ61"
}
