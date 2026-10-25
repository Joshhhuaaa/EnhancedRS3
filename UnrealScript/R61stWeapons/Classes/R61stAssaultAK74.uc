//===============================================================================
//  [R61stAssaultAK74] 
//===============================================================================

class R61stAssaultAK74 extends R61stAssaultAK47;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultAK74Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stAssault_UKX.R61stAssaultAK74'
}
