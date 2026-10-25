//=============================================================================
//  R6RainbowHeavy.uc : Heavy Rainbow Pawn
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/06/08 * Created by Rima Brek
//
//============================================================================//
class R6RainbowHeavy extends R6RainbowPawn;

defaultproperties
{
     m_HelmetClass=Class'R6Characters.R6RHeavyHelmet'
     Mesh=SkeletalMesh'R6Rainbow_UKX.HeavyMesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel214
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
         Name="KarmaParamsSkel214"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel214'
     Skins(0)=Texture'R6Characters_T.Rainbow.R6RHeavy'
     Skins(1)=Texture'R6Characters_T.Rainbow.R6RHeavyMedHead'
     Skins(2)=FinalBlend'R6Characters_T.Rainbow.R6RGogglesFB'
     Skins(5)=Texture'R61stWeapons_T.Hands.R61stHands'
}
