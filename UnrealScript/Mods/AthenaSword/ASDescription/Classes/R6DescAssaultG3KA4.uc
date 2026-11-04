class R6DescAssaultG3KA4 extends R6AssaultDescription;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=49
    m_ARangePercent[1]=49
    m_ARangePercent[2]=8
    m_ADamagePercent[0]=87
    m_ADamagePercent[1]=87
    m_ADamagePercent[2]=35
    m_AAccuracyPercent[0]=58
    m_AAccuracyPercent[1]=58
    m_AAccuracyPercent[2]=74
    m_ARecoilPercent[0]=33
    m_ARecoilPercent[1]=62
    m_ARecoilPercent[2]=89
    m_ARecoveryPercent[0]=89
    m_ARecoveryPercent[1]=79
    m_ARecoveryPercent[2]=83
    m_WeaponTags[0]="NORMAL"
    m_WeaponTags[1]="CMAG"
    m_WeaponTags[2]="SILENCED"
    m_WeaponClasses[0]="ASWeapons.NormalAssaultG3KA4"
    m_WeaponClasses[1]="ASWeapons.CMagAssaultG3KA4"
    m_WeaponClasses[2]="ASWeapons.SilencedAssaultG3KA4"
    m_MyGadgets[0]=Class'R6Description.R6DescMiniScope'
    m_MyGadgets[1]=Class'R6Description.R6DescCMAG762mm'
    m_MyGadgets[2]=Class'R6Description.R6DescSilencerSubGuns'
    m_Bullets[0]=Class'R6Description.R6Desc762mmNATOFMJ'
    m_MagTag="R63RDMAG762MM2"
    m_2DMenuTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons'
    m_2dMenuRegion=(X=129,Y=154,W=129,H=77)
    m_NameID="ASSAULTG3KA4"
}
