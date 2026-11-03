class MP21stShotgunJackhammer extends R6AbstractFirstPersonWeapon;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stShotgun_UKX.ukx PACKAGE=MP21stShotgun_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP21stWeapons_SM.usx PACKAGE=MP21stWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stShotgun_UKX.R61stShotgunJackhammerA');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'MP21stWeapons_SM.Shotguns.R61stShotgunJackhammerFrame');
    AttachToBone(m_smGun, 'TagFrame');
}

defaultproperties
{
    Mesh=SkeletalMesh'MP21stShotgun_UKX.R61stShotgunJackhammer'
}
