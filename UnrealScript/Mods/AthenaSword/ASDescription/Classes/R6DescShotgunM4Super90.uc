class R6DescShotgunM4Super90 extends R6ShotgunDescription;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=8
    m_ARangePercent[1]=8
    m_ADamagePercent[0]=100
    m_ADamagePercent[1]=100
    m_AAccuracyPercent[0]=1
    m_AAccuracyPercent[1]=1
    m_ARecoilPercent[0]=5
    m_ARecoilPercent[1]=5
    m_ARecoveryPercent[0]=89
    m_ARecoveryPercent[1]=89
    m_WeaponTags[0]="BUCK"
    m_WeaponTags[1]="SLUG"
    m_WeaponClasses[0]="ASWeapons.BuckShotgunM4Super90"
    m_WeaponClasses[1]="ASWeapons.SlugShotgunM4Super90"
    m_MyGadgets[0]=Class'R6Description.R6DescMiniScope'
    m_Bullets[0]=Class'R6Description.R6Desc12gaugeBuck'
    m_Bullets[1]=Class'R6Description.R6Desc12gaugeSlug'
    m_MagTag="SHOTGUNM1"
    m_2DMenuTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons'
    m_2dMenuRegion=(Y=77,W=129,H=77)
    m_NameID="SHOTGUNM4SUPER90"
}
