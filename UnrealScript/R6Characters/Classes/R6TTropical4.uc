//=============================================================================
//  R6TTropical4.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/11 * Created by Guillaume Borgia
//=============================================================================
class R6TTropical4 extends R6TTropical2;

defaultproperties
{
     m_eTerroType=TTYPE_T2T4
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel280
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
         Name="KarmaParamsSkel280"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel280'
     Skins(0)=Texture'R6Characters_T.terrorist.R6TTropical4'
}
