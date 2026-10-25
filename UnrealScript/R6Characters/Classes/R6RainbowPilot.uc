//=============================================================================
//  R6RainbowPilot.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/15 * Created by Rima Brek
//=============================================================================
class R6RainbowPilot extends R6RainbowPawn;

simulated event PostBeginPlay()
{
    m_bUseSpecialSkin = true;
    Super.PostBeginPlay();
}

simulated function SetRainbowFaceTexture()
{
	#ifdefDEBUG if(bShowLog) log(self$" SetRainbowFaceTexture() : bIsFemale ="$bIsFemale$" m_iOperativeID="$m_iOperativeID);	#endif

	if(bIsFemale)
	{		
		SetFemaleParameters();
	
		// set female face texture
		Skins[1] = Texture(DynamicLoadObject("R6Characters_t.Rainbow.R6RPilotHeadF", class'Texture'));
		
		// scale helmet for female operatives
		if(m_Helmet != none)
			m_Helmet.DrawScale=1.0;

		// scale nightvision for female operatives
		if(m_NightVision != none)
			m_NightVision.DrawScale=1.1;
	}
}

simulated function AttachNightVision()
{
	Super.AttachNightVision();
	m_NightVision.SetRelativeLocation(vect(-1,-1,0));
}

defaultproperties
{
     m_bScaleGasMaskForFemale=False
     m_GasMaskClass=Class'R6Engine.R6PilotGasMask'
     m_NightVisionClass=Class'R6Engine.R6PilotNightVision'
     m_eArmorType=ARMOR_Medium
     m_HelmetClass=Class'R6Characters.R6RPilotHelmet'
     Mesh=SkeletalMesh'R6Rainbow_UKX.PilotMesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel247
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
         Name="KarmaParamsSkel247"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel247'
     Skins(0)=Texture'R6Characters_T.Rainbow.R6RPilot'
     Skins(5)=Texture'R61stWeapons_T.Hands.R61stHandsGreen'
}
