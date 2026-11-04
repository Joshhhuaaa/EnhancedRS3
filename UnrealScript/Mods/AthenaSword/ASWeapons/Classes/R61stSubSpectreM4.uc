class R61stSubSpectreM4 extends R6AbstractFirstPersonWeapon;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\R61stItalianSub_UKX.ukx PACKAGE=R61stItalianSub_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R61stItalianWeapons_SM.usx PACKAGE=R61stItalianWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stItalianSub_UKX.R61stSubSpectreM4A');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stItalianWeapons_SM.SubGuns.R61stSubSpectreM4Frame');
    AttachToBone(m_smGun, 'TagFrame');
}

defaultproperties
{
    Mesh=SkeletalMesh'R61stItalianSub_UKX.R61stSubSpectreM4'
}
