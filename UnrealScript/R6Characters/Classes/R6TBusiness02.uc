//=============================================================================
//  R6TBusiness02.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/14 * Created by Guillaume Borgia
//=============================================================================
class R6TBusiness02 extends R6TerroristPawn;

defaultproperties
{
     m_eTerroType=TTYPE_B2T2
     Mesh=SkeletalMesh'R6Terrorist_UKX.Business02Mesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel250
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
         Name="KarmaParamsSkel250"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel250'
     Skins(0)=Texture'R6Characters_T.terrorist.R6TBusiness2'
}
