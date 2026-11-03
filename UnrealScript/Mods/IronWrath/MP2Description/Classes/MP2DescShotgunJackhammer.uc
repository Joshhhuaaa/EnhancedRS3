class MP2DescShotgunJackhammer extends R6ShotgunDescription;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2TextureMenuEquipment.utx PACKAGE=MP2TextureMenuEquipment

defaultproperties
{
    m_ARangePercent[0]=8
    m_ARangePercent[1]=8
    m_ADamagePercent[0]=100
    m_ADamagePercent[1]=100
    m_AAccuracyPercent[0]=1
    m_AAccuracyPercent[1]=1
    m_ARecoilPercent[0]=25
    m_ARecoilPercent[1]=25
    m_ARecoveryPercent[0]=88
    m_ARecoveryPercent[1]=88
    m_WeaponTags[0]="BUCK"
    m_WeaponTags[1]="SLUG"
    m_WeaponClasses[0]="MP23rdWeapons.BuckShotgunJackhammer"
    m_WeaponClasses[1]="MP23rdWeapons.SlugShotgunJackhammer"
    m_MyGadgets[0]=Class'R6Description.R6DescMiniScope'
    m_Bullets[0]=Class'R6Description.R6Desc12gaugeBuck'
    m_Bullets[1]=Class'R6Description.R6Desc12gaugeSlug'
    m_MagTag="R63rdMAGJACKHAMMER"
    m_2DMenuTexture=Texture'MP2TextureMenuEquipment.MP2Weapons'
    m_2dMenuRegion=(Y=77,W=129,H=77)
    m_NameID="SHOTGUNJACKHAMMER"
}
