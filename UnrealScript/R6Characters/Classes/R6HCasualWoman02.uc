//=============================================================================
//  R6HCasualWoman02.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/11 * Created by Guillaume Borgia
//=============================================================================
class R6HCasualWoman02 extends R6HCasualWoman01;

defaultproperties
{
     Mesh=SkeletalMesh'R6Hostage_UKX.Woman2Mesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel200
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
         Name="KarmaParamsSkel200"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel200'
     Skins(0)=Texture'R6Characters_T.hostage.R6HCasualWoman2'
}
