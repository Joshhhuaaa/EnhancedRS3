class R61stSniperSL82 extends R61stSniperSSG3000;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\R61stItalianSniper_UKX.ukx PACKAGE=R61stItalianSniper_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R61stItalianWeapons_SM.usx PACKAGE=R61stItalianWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stItalianSniper_UKX.R61stSniperSL8_2A');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stItalianWeapons_SM.SniperRifles.R61stSniperSL8_2Frame');
    AttachToBone(m_smGun, 'TagFrame');
}

defaultproperties
{
    Mesh=SkeletalMesh'R61stItalianSniper_UKX.SniperSL8'
}
