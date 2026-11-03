class MP2DescSubMP7PDW extends R6SubGunDescription;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2TextureMenuEquipment.utx PACKAGE=MP2TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=19
    m_ARangePercent[1]=19
    m_ARangePercent[2]=10
    m_ADamagePercent[0]=22
    m_ADamagePercent[1]=22
    m_ADamagePercent[2]=13
    m_AAccuracyPercent[0]=24
    m_AAccuracyPercent[1]=24
    m_AAccuracyPercent[2]=36
    m_ARecoilPercent[0]=63
    m_ARecoilPercent[1]=69
    m_ARecoilPercent[2]=98
    m_ARecoveryPercent[0]=100
    m_ARecoveryPercent[1]=98
    m_ARecoveryPercent[2]=99
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="CMAG"
    m_WeaponTags[2]="SILENCED"
    m_WeaponClasses[0]="MP23rdWeapons.NormalSubMP7PDW"
    m_WeaponClasses[1]="MP23rdWeapons.CMagSubMP7PDW"
    m_WeaponClasses[2]="MP23rdWeapons.SilencedSubMP7PDW"
    m_MyGadgets[0]=Class'R6Description.R6DescMiniScope'
    m_MyGadgets[1]=Class'R6Description.R6DescCMAG9mmMTAR21'
    m_MyGadgets[2]=Class'R6Description.R6DescSilencerSubGuns'
    m_Bullets[0]=Class'MP2Description.MP2Desc46x30mmFMJ'
    m_Bullets[1]=Class'MP2Description.MP2Desc46x30mmJHP'
    m_MagTag="R63RDMAGMP7"
    m_2DMenuTexture=Texture'MP2TextureMenuEquipment.MP2Weapons'
    m_NameID="SUBMP7PDW"
}
