//=============================================================================
//  R6TerroristPawn.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Creation 
//=============================================================================
class R6TerroristPawn extends R6Terrorist;
 
/*
// Reloading Weapon Animations
#EXEC ANIM NOTIFY ANIM=R6TerroristAnims SEQ=CrouchReloadHandGun TIME=0.9  FUNCTION=ReloadingWeaponEnd
#EXEC ANIM NOTIFY ANIM=R6TerroristAnims SEQ=CrouchReloadSubGun  TIME=0.9  FUNCTION=ReloadingWeaponEnd
#EXEC ANIM NOTIFY ANIM=R6TerroristAnims SEQ=StandReloadSubGun   TIME=0.9  FUNCTION=ReloadingWeaponEnd
#EXEC ANIM NOTIFY ANIM=R6TerroristAnims SEQ=StandRollGrenade    TIME=0.6  FUNCTION=ReleaseGrenade
#EXEC ANIM NOTIFY ANIM=R6TerroristAnims SEQ=StandRollGrenade    TIME=0.9  FUNCTION=EndGrenade
#EXEC ANIM NOTIFY ANIM=R6TerroristAnims SEQ=StandThrowGrenade	TIME=0.65 FUNCTION=ReleaseGrenade
*/

#exec OBJ LOAD FILE=..\Animations\R6Terrorist_UKX.ukx PACKAGE=R6Terrorist_UKX

function PostBeginPlay()
{
    Super.PostBeginPlay();
    LinkSkelAnim(MeshAnimation'R6Terrorist_UKX.TerroristAnims');
}

defaultproperties
{
     m_FOVClass=Class'R6Characters.R6FieldOfView'
     Mesh=SkeletalMesh'R6Terrorist_UKX.Militant01Mesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel248
         KConvulseSpacing=(Max=2.200000)
         KSkeleton="terroskel"
         KStartEnabled=True
         bHighDetailOnly=False
         KLinearDamping=0.500000
         KAngularDamping=0.500000
         KBuoyancy=1.000000
         KVelDropBelowThreshold=50.000000
         KFriction=0.600000
         KRestitution=0.300000
         KImpactThreshold=150.000000
         Name="KarmaParamsSkel248"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel248'
     Skins(0)=Texture'R6Characters_T.terrorist.R6TMilitant4'
}
