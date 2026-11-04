class R6DescAssaultOTs14 extends R6AssaultDescription;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=36
    m_ARangePercent[1]=36
    m_ARangePercent[2]=9
    m_ADamagePercent[0]=26
    m_ADamagePercent[1]=26
    m_ADamagePercent[2]=26
    m_AAccuracyPercent[0]=49
    m_AAccuracyPercent[1]=49
    m_AAccuracyPercent[2]=52
    m_ARecoilPercent[0]=71
    m_ARecoilPercent[1]=90
    m_ARecoilPercent[2]=84
    m_ARecoveryPercent[0]=94
    m_ARecoveryPercent[1]=81
    m_ARecoveryPercent[2]=87
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="CMAG"
    m_WeaponTags[2]="SILENCED"
    m_WeaponClasses[0]="ASWeapons.NormalAssaultOTs14"
    m_WeaponClasses[1]="ASWeapons.CMagAssaultOTs14"
    m_WeaponClasses[2]="ASWeapons.SilencedAssaultOTs14"
    m_MyGadgets[0]=Class'R6Description.R6DescDrumMAGAK'
    m_MyGadgets[1]=Class'R6Description.R6DescSilencerSubGuns'
    m_MyGadgets[2]=Class'R6Description.R6DescMiniScope'
    m_Bullets[0]=Class'R6Description.R6Desc9x39mmSP6FMJ'
    m_MagTag="R63RDMAGOTS14"
    m_2DMenuTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons'
    m_2dMenuRegion=(Y=154,W=129,H=77)
    m_NameID="ASSAULTOTS14"
}
