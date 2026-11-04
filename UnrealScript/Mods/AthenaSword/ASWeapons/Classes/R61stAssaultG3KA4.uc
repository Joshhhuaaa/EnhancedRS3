class R61stAssaultG3KA4 extends R6AbstractFirstPersonWeapon;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\R61stItalianAssault_UKX.ukx PACKAGE=R61stItalianAssault_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R61stItalianWeapons_SM.usx PACKAGE=R61stItalianWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stItalianAssault_UKX.R61stAssaultG3KA4A');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stItalianWeapons_SM.AssaultRifles.R61stAssaultG3KA4Frame');
    AttachToBone(m_smGun, 'TagFrame');
}

defaultproperties
{
    Mesh=SkeletalMesh'R61stItalianAssault_UKX.R61stAssaultG3KA4'
}
