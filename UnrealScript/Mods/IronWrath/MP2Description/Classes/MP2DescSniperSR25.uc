class MP2DescSniperSR25 extends R6SniperDescription;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2TextureMenuEquipment.utx PACKAGE=MP2TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=49
    m_ARangePercent[1]=8
    m_ADamagePercent[0]=98
    m_ADamagePercent[1]=20
    m_AAccuracyPercent[0]=76
    m_AAccuracyPercent[1]=88
    m_ARecoilPercent[0]=35
    m_ARecoilPercent[1]=90
    m_ARecoveryPercent[0]=59
    m_ARecoveryPercent[1]=51
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="SILENCED"
    m_WeaponClasses[0]="MP23rdWeapons.NormalSniperSR25"
    m_WeaponClasses[1]="MP23rdWeapons.SilencedSniperSR25"
    m_MyGadgets[0]=Class'R6Description.R6DescSilencerSnipers'
    m_MyGadgets[1]=Class'R6Description.R6DescThermalScope'
    m_Bullets[0]=Class'R6Description.R6Desc762mmNATOFMJ'
    m_Bullets[1]=Class'R6Description.R6Desc762mmNATOJHP'
    m_MagTag="R63RDMAG762MM"
    m_2DMenuTexture=Texture'MP2TextureMenuEquipment.MP2Weapons'
    m_2dMenuRegion=(X=129,Y=77,W=129,H=77)
    m_NameID="SNIPERSR25"
}
