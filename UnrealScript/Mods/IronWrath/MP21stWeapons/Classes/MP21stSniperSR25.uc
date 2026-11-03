class MP21stSniperSR25 extends R61stSniperSSG3000;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stSniper_UKX.ukx PACKAGE=MP21stSniper_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP21stWeapons_SM.usx PACKAGE=MP21stWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stSniper_UKX.R61stSniperSR25A');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'MP21stWeapons_SM.SniperRifles.R61stSniperSR25Frame');
    AttachToBone(m_smGun, 'TagFrame');
}

defaultproperties
{
    Mesh=SkeletalMesh'MP21stSniper_UKX.R61stSniperSR25'
}
