//=============================================================================
//  R6HostagePawn.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Creation
//=============================================================================
class R6HostagePawn extends R6Hostage;

#exec OBJ LOAD FILE=..\Animations\R6Hostage_UKX.ukx PACKAGE=R6Hostage_UKX

/*
#EXEC ANIM NOTIFY ANIM=R6HostageAnims SEQ=CrouchToScaredStand			TIME=0.01 FUNCTION=AnimNotify_CrouchToScaredStandBegin
#EXEC ANIM NOTIFY ANIM=R6HostageAnims SEQ=CrouchToScaredStand			TIME=0.99 FUNCTION=AnimNotify_CrouchToScaredStandEnd
*/

simulated event PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R6Hostage_UKX.HostageAnims');
	Super.PostBeginPlay();
}

defaultproperties
{
     m_FOVClass=Class'R6Characters.R6FieldOfView'
     Mesh=SkeletalMesh'R6Hostage_UKX.NightWatchMesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel196
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
         Name="KarmaParamsSkel196"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel196'
     Skins(0)=Texture'R6Characters_T.hostage.R6Hostage'
}
