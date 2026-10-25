//===============================================================================
//  [R61stSubUMP] 
//===============================================================================

class R61stSubUMP extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stSub_UKX.R61stSubUMPA');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
     m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Subguns.R61stSubUMPFrame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

simulated function SwitchFPMesh()
{
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Subguns.R61stSubUMPForScopeFrame');
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSub_UKX.R61stSubUMP'
}
