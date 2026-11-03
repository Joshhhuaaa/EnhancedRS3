class MP21stLMGUltimax extends R61stLMGWeapon;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stLMG_UKX.ukx PACKAGE=MP21stLMG_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP21stWeapons_SM.usx PACKAGE=MP21stWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stLMG_UKX.R61stLMGUltimax100A');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'MP21stWeapons_SM.LMGs.R61stLMGUltimax100Frame');
    AttachToBone(m_smGun, 'TagFrame');
    m_Bullets[0].SetDrawType(DT_None);
    m_Bullets[1].SetDrawType(DT_None);
    m_Bullets[2].SetDrawType(DT_None);
    m_Bullets[3].SetDrawType(DT_None);
    m_Bullets[4].SetDrawType(DT_None);
    m_Bullets[5].SetDrawType(DT_None);
    m_Bullets[6].SetDrawType(DT_None);
    m_Bullets[7].SetDrawType(DT_None);
}

function ShowBullets()
{
}

function HideBullets()
{
}

defaultproperties
{
    Mesh=SkeletalMesh'MP21stLMG_UKX.R61stLMGUltimax100'
}
