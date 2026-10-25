//===============================================================================
//  [R61stAssaultM4] 
//===============================================================================

class R61stAssaultM4 extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stAssault_UKX.R61stAssaultM4A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultM4Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

simulated function SwitchFPMesh()
{
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultM4ForScopeFrame');
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stAssault_UKX.R61stAssaultM4'
}
