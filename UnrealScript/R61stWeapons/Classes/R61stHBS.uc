//===============================================================================
//  [R61stHBS] 
//===============================================================================

class R61stHBS extends R6AbstractFirstPersonWeapon;

simulated function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stItems_UKX.R61stItemAttachementA');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stHBS');
    AttachToBone(m_smGun, 'TagFrame'); 
    
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stItems_UKX.R61stItemAttachement'
}
