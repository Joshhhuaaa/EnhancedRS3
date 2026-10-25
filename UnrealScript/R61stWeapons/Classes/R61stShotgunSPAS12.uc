//===============================================================================
//  [R61stShotgunSPAS12] 
//===============================================================================

class R61stShotgunSPAS12 extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stShotgun_UKX.R61stShotgunSPAS12A');
    Super.PostBeginPlay();

    //Fire last is not fire but neutral  
    m_FireLast = m_Neutral;

    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunSPAS12Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
    if(m_smGun2 == none)
    {
        m_smGun2 = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunSPAS12Pump');
    AttachToBone(m_smGun2, 'TagPump'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stShotgun_UKX.R61stShotgunSPAS12'
}
