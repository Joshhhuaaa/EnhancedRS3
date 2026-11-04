class R61stLMGM240G extends R61stLMGWeapon;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\R61stItalianLMG_UKX.ukx PACKAGE=R61stItalianLMG_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R61stItalianWeapons_SM.usx PACKAGE=R61stItalianWeapons_SM
#exec OBJ LOAD FILE=..\StaticMeshes\R61stWeapons_SM.usx PACKAGE=R61stWeapons_SM

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stItalianLMG_UKX.R61stLMGM240GA');
    super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stItalianWeapons_SM.LMGs.R61stLMGM240GFrame');
    AttachToBone(m_smGun, 'TagFrame');
    m_Bullets[0].SetDrawType(DT_None);
    m_Bullets[1].SetRelativeLocation(vect(-1.0, 0.0, 0.0));
    m_Bullets[2].SetRelativeLocation(vect(-1.0, 0.0, 0.0));
    m_Bullets[3].SetRelativeLocation(vect(-1.0, 0.0, 0.0));
    m_Bullets[4].SetRelativeLocation(vect(-1.0, 0.0, 0.0));
    m_Bullets[5].SetRelativeLocation(vect(-1.0, 0.0, 0.0));
    m_Bullets[6].SetRelativeLocation(vect(-1.0, 0.0, 0.0));
    m_Bullets[7].SetDrawType(DT_None);
}

defaultproperties
{
    m_RWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_RWing'
    m_2Wing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_2Wing'
    m_LWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_LWing'
    Mesh=SkeletalMesh'R61stItalianLMG_UKX.R61stLMGM240G'
}
