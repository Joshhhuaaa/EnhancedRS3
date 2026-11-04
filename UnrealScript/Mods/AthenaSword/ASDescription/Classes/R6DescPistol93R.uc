class R6DescPistol93R extends R6PistolsDescription;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=10
    m_ARangePercent[1]=10
    m_ARangePercent[2]=7
    m_ADamagePercent[0]=18
    m_ADamagePercent[1]=18
    m_ADamagePercent[2]=12
    m_AAccuracyPercent[0]=36
    m_AAccuracyPercent[1]=36
    m_AAccuracyPercent[2]=44
    m_ARecoilPercent[0]=37
    m_ARecoilPercent[1]=46
    m_ARecoilPercent[2]=66
    m_ARecoveryPercent[0]=89
    m_ARecoveryPercent[1]=88
    m_ARecoveryPercent[2]=86
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="CMAG"
    m_WeaponTags[2]="SILENCED"
    m_WeaponClasses[0]="ASWeapons.NormalPistol93R"
    m_WeaponClasses[1]="ASWeapons.CMagPistol93R"
    m_WeaponClasses[2]="ASWeapons.SilencedPistol93R"
    m_MyGadgets[0]=Class'R6Description.R6DescMAGPistolHigh'
    m_MyGadgets[1]=Class'R6Description.R6DescSilencerPistol'
    m_Bullets[0]=Class'R6Description.R6Desc9mmParabellumFMJ'
    m_Bullets[1]=Class'R6Description.R6Desc9mmParabellumJHP'
    m_MagTag="R63RDMAGPISTOL"
    m_2DMenuTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons'
    m_2dMenuRegion=(Y=231,W=64,H=53)
    m_NameID="PISTOL93R"
}
