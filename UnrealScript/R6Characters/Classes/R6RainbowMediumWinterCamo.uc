//=============================================================================
//  R6RainbowMediumWinterCamo.uc : Medium Winter Camo Rainbow Pawn
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/21 * Created by Rima Brek
//
//============================================================================//
class R6RainbowMediumWinterCamo extends R6RainbowMediumWinter;

defaultproperties
{
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel246
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
         Name="KarmaParamsSkel246"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel246'
     Skins(0)=Texture'R6Characters_T.RainbowSkins.R6RMediumWinterCamo'
     Skins(1)=Texture'R6Characters_T.Rainbow.R6RMediumWinterHead'
     Skins(2)=FinalBlend'R6Characters_T.Rainbow.R6RGogglesFB'
     Skins(5)=Texture'R61stWeapons_T.Hands.R61stHandsWinter'
}
