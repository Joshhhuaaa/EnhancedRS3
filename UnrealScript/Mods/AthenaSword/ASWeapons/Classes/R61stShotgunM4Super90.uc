class R61stShotgunM4Super90 extends R6AbstractFirstPersonWeapon;

#exec OBJ LOAD FILE=..\Animations\R61stShotgun_UKX.ukx PACKAGE=R61stShotgun_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R61stItalianWeapons_SM.usx PACKAGE=R61stItalianWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stShotgun_UKX.R61stShotgunM1A');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stItalianWeapons_SM.Shotguns.R61stShotgunM4Super90Frame');
    AttachToBone(m_smGun, 'TagFrame');
}

defaultproperties
{
    Mesh=SkeletalMesh'R61stShotgun_UKX.R61stShotgunM1'
}
