class MP21stPistolModel17 extends R6AbstractFirstPersonWeapon;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stPistol_UKX.ukx PACKAGE=MP21stPistol_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP21stWeapons_SM.usx PACKAGE=MP21stWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stPistol_UKX.R61stPistolModel17A');
    super.PostBeginPlay();
    m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'MP21stWeapons_SM.Pistols.R61stPistolModel17Frame');
    AttachToBone(m_smGun, 'TagFrame');
    m_smGun2 = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    m_smGun2.SetStaticMesh(StaticMesh'MP21stWeapons_SM.Pistols.R61stPistolModel17Slide');
    AttachToBone(m_smGun2, 'TagSlide');
}

defaultproperties
{
    Mesh=SkeletalMesh'MP21stPistol_UKX.R61stPistolModel17'
}
