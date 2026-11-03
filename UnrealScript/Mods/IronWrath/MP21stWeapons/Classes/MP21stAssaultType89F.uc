class MP21stAssaultType89F extends R6AbstractFirstPersonWeapon;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stAssault_UKX.ukx PACKAGE=MP21stAssault_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP21stWeapons_SM.usx PACKAGE=MP21stWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stAssault_UKX.R61stAssaultType89fA');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'MP21stWeapons_SM.AssaultRifles.R61stAssaultType89fFrame');
    AttachToBone(m_smGun, 'TagFrame');
}

defaultproperties
{
    Mesh=SkeletalMesh'MP21stAssault_UKX.ukx.R61stAssaultType89f'
}
