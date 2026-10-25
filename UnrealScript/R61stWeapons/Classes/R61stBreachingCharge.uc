//=============================================================================
//  R61stBreachingCharge.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/05 * Created by Rima Brek
//=============================================================================
class R61stBreachingCharge extends R6AbstractFirstPersonWeapon;

simulated function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stItems_UKX.R61stItemAttachementA');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stBreachingCharge');
    AttachToBone(m_smGun, 'TagFrame');
    
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stItems_UKX.R61stItemAttachement'
}
