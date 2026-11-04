class R6DescSubSpectreM4 extends R6SubGunDescription;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=10
    m_ARangePercent[1]=10
    m_ARangePercent[2]=7
    m_ADamagePercent[0]=16
    m_ADamagePercent[1]=16
    m_ADamagePercent[2]=16
    m_AAccuracyPercent[0]=36
    m_AAccuracyPercent[1]=36
    m_AAccuracyPercent[2]=46
    m_ARecoilPercent[0]=85
    m_ARecoilPercent[1]=88
    m_ARecoilPercent[2]=94
    m_ARecoveryPercent[0]=94
    m_ARecoveryPercent[1]=92
    m_ARecoveryPercent[2]=91
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="CMAG"
    m_WeaponTags[2]="SILENCED"
    m_WeaponClasses[0]="ASWeapons.NormalSubSpectreM4"
    m_WeaponClasses[1]="ASWeapons.CMagSubSpectreM4"
    m_WeaponClasses[2]="ASWeapons.SilencedSubSpectreM4"
    m_MyGadgets[0]=Class'R6Description.R6DescMiniScope'
    m_MyGadgets[1]=Class'R6Description.R6DescCMAG9mmMP5'
    m_MyGadgets[2]=Class'R6Description.R6DescSilencerSubGuns'
    m_Bullets[0]=Class'R6Description.R6Desc9mmParabellumFMJ'
    m_Bullets[1]=Class'R6Description.R6Desc9mmParabellumJHP'
    m_MagTag="R63RDMAGSPECTREM4"
    m_2DMenuTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons'
    m_NameID="SUBSPECTREM4"
}
