class MP21stSubMP7PDW extends R6AbstractFirstPersonWeapon;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stSub_UKX.ukx PACKAGE=MP21stSub_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP21stWeapons_SM.usx PACKAGE=MP21stWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stSub_UKX.R61stSubMp7PDWA');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'MP21stWeapons_SM.SubGuns.R61stSubMp7PDWFrame');
    m_smGun.DrawScale = 1.1;
    AttachToBone(m_smGun, 'TagFrame');
}

simulated function SwitchFPMesh()
{
    m_smGun.SetStaticMesh(StaticMesh'MP21stWeapons_SM.SubGuns.R61stSubMp7PDWForScopeFrame');
}

defaultproperties
{
    DrawScale=1.1
    Mesh=SkeletalMesh'MP21stSub_UKX.R61stSubMp7PDW'
}
