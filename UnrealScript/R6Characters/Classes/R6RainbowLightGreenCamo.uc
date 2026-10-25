//=============================================================================
//  R6RainbowLightGreenCamo.uc : Light Green Camouflage Rainbow Pawn
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/02 * Created by Rima Brek
//
//============================================================================//
class R6RainbowLightGreenCamo extends R6RainbowLight;

defaultproperties
{
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel231
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
         Name="KarmaParamsSkel231"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel231'
     Skins(0)=Texture'R6Characters_T.RainbowSkins.R6RLightGreenCamo'
     Skins(1)=Texture'R6Characters_T.Rainbow.R6RLightHead'
     Skins(2)=FinalBlend'R6Characters_T.Rainbow.R6RGogglesFB'
     Skins(5)=Texture'R61stWeapons_T.Hands.R61stHandsGreenCamo'
}
