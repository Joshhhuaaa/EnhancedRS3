class MP2DescPistolModel17 extends R6PistolsDescription;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2TextureMenuEquipment.utx PACKAGE=MP2TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=10
    m_ARangePercent[1]=10
    m_ARangePercent[2]=7
    m_ADamagePercent[0]=16
    m_ADamagePercent[1]=16
    m_ADamagePercent[2]=12
    m_AAccuracyPercent[0]=33
    m_AAccuracyPercent[1]=33
    m_AAccuracyPercent[2]=41
    m_ARecoilPercent[0]=25
    m_ARecoilPercent[1]=40
    m_ARecoilPercent[2]=58
    m_ARecoveryPercent[0]=90
    m_ARecoveryPercent[1]=89
    m_ARecoveryPercent[2]=87
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="CMAG"
    m_WeaponTags[2]="SILENCED"
    m_WeaponClasses[0]="MP23rdWeapons.NormalPistolModel17"
    m_WeaponClasses[1]="MP23rdWeapons.CMagPistolModel17"
    m_WeaponClasses[2]="MP23rdWeapons.SilencedPistolModel17"
    m_MyGadgets[0]=Class'R6Description.R6DescMAGPistolHigh'
    m_MyGadgets[1]=Class'R6Description.R6DescSilencerPistol'
    m_Bullets[0]=Class'R6Description.R6Desc9mmParabellumFMJ'
    m_Bullets[1]=Class'R6Description.R6Desc9mmParabellumJHP'
    m_MagTag="R63RDMAGPISTOL"
    m_2DMenuTexture=Texture'MP2TextureMenuEquipment.MP2Weapons'
    m_2dMenuRegion=(Y=231,W=64,H=53)
    m_NameID="PISTOLMODEL17"
}
