class MP2Desc46x30mmFMJ extends R6BulletDescription;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2TextureMenuEquipment.utx PACKAGE=MP2TextureMenuEquipment

defaultproperties
{
    m_SubsonicClassName="MP2Weapons.Ammo46x30mmSubsonicFMJ"
    m_2DMenuTexture=Texture'MP2TextureMenuEquipment.MP2Weapons'
    m_2dMenuRegion=(X=258,Y=34,W=64,H=34)
    m_NameID="46x30MMFMJ"
    m_NameTag="FMJ"
    m_ClassName="MP2Weapons.ammo46x30mmNormalFMJ"
}
