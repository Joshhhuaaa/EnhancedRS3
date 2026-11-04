class R6DescSniperSL82 extends R6SniperDescription;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=39
    m_ARangePercent[1]=4
    m_ADamagePercent[0]=56
    m_ADamagePercent[1]=8
    m_AAccuracyPercent[0]=71
    m_AAccuracyPercent[1]=80
    m_ARecoilPercent[0]=62
    m_ARecoilPercent[1]=100
    m_ARecoveryPercent[0]=62
    m_ARecoveryPercent[1]=55
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="SILENCED"
    m_WeaponClasses[0]="ASWeapons.NormalSniperSL82"
    m_WeaponClasses[1]="ASWeapons.SilencedSniperSL82"
    m_MyGadgets[0]=Class'R6Description.R6DescSilencerSnipers'
    m_MyGadgets[1]=Class'R6Description.R6DescThermalScope'
    m_Bullets[0]=Class'R6Description.R6Desc556mmNATOFMJ'
    m_Bullets[1]=Class'R6Description.R6Desc556mmNATOJHP'
    m_MagTag="R63RDMAGSL82"
    m_2DMenuTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons'
    m_2dMenuRegion=(X=128,Y=77,W=129,H=77)
    m_NameID="SNIPERSL82"
}
