class R61stPistol93R extends R6AbstractFirstPersonWeapon;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\R61stItalianPistol_UKX.ukx PACKAGE=R61stItalianPistol_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R61stItalianWeapons_SM.usx PACKAGE=R61stItalianWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stItalianPistol_UKX.R61stPistol93RA');
    super.PostBeginPlay();
    m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stItalianWeapons_SM.Pistols.R61stPistol93RFrame');
    AttachToBone(m_smGun, 'TagFrame');
    m_smGun2 = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    m_smGun2.SetStaticMesh(StaticMesh'R61stItalianWeapons_SM.Pistols.R61stPistol93RSlide');
    AttachToBone(m_smGun2, 'TagSlide');
}

defaultproperties
{
    Mesh=SkeletalMesh'R61stItalianPistol_UKX.R61stPistol93R'
}
