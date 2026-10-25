//===============================================================================
//  [R61stHBSSAJ.uc] Heart Beat Sensor Stand Alone Jammer
//===============================================================================

class R61stHBSSAJ extends R6AbstractFirstPersonWeapon;

simulated function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stItems_UKX.R61stItemAttachementA');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stHBSSAJ');
    AttachToBone(m_smGun, 'TagFrame'); 
    
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stItems_UKX.R61stItemAttachement'
}
