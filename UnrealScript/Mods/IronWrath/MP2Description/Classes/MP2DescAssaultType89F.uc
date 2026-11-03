class MP2DescAssaultType89F extends R6AssaultDescription;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2TextureMenuEquipment.utx PACKAGE=MP2TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=39
    m_ARangePercent[1]=39
    m_ARangePercent[2]=19
    m_ADamagePercent[0]=56
    m_ADamagePercent[1]=56
    m_ADamagePercent[2]=24
    m_AAccuracyPercent[0]=66
    m_AAccuracyPercent[1]=66
    m_AAccuracyPercent[2]=78
    m_ARecoilPercent[0]=52
    m_ARecoilPercent[1]=65
    m_ARecoilPercent[2]=99
    m_ARecoveryPercent[0]=90
    m_ARecoveryPercent[1]=86
    m_ARecoveryPercent[2]=85
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="CMAG"
    m_WeaponTags[2]="SILENCED"
    m_WeaponClasses[0]="MP23rdWeapons.NormalAssaultType89F"
    m_WeaponClasses[1]="MP23rdWeapons.CMagAssaultType89F"
    m_WeaponClasses[2]="MP23rdWeapons.SilencedAssaultType89F"
    m_MyGadgets[0]=Class'R6Description.R6DescCMAG556mm'
    m_MyGadgets[1]=Class'R6Description.R6DescSilencerSubGuns'
    m_Bullets[0]=Class'R6Description.R6Desc556mmNATOFMJ'
    m_MagTag="R63RDMAG556MM"
    m_2DMenuTexture=Texture'MP2TextureMenuEquipment.MP2Weapons'
    m_2dMenuRegion=(Y=154,W=129,H=77)
    m_NameID="ASSAULTTYPE89F"
}
