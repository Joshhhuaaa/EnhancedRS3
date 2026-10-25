//============================================================================//
//  R6DescPistolAPArmy.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6DescPistolAPArmy extends R6PistolsDescription;

defaultproperties
{
     m_ARangePercent(0)=14
     m_ARangePercent(1)=14
     m_ARangePercent(2)=5
     m_ADamagePercent(0)=14
     m_ADamagePercent(1)=14
     m_ADamagePercent(2)=7
     m_AAccuracyPercent(0)=35
     m_AAccuracyPercent(1)=35
     m_AAccuracyPercent(2)=43
     m_ARecoilPercent(0)=19
     m_ARecoilPercent(1)=37
     m_ARecoilPercent(2)=78
     m_ARecoveryPercent(0)=90
     m_ARecoveryPercent(1)=90
     m_ARecoveryPercent(2)=88
     m_WeaponTags(0)="NORMAL"
     m_WeaponTags(1)="CMAG"
     m_WeaponTags(2)="SILENCED"
     m_WeaponClasses(0)="R63rdWeapons.NormalPistolAPArmy"
     m_WeaponClasses(1)="R63rdWeapons.CMagPistolAPArmy"
     m_WeaponClasses(2)="R63rdWeapons.SilencedPistolAPArmy"
     m_MyGadgets(0)=Class'R6Description.R6DescMAGPistolHigh'
     m_MyGadgets(1)=Class'R6Description.R6DescSilencerPistol'
     m_Bullets(0)=Class'R6Description.R6Desc57x28mmFMJ'
     m_MagTag="R63RDMAGPISTOL"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
     m_2dMenuRegion=(X=387,Y=53,W=64,H=53)
     m_NameID="PISTOLAPARMY"
}
