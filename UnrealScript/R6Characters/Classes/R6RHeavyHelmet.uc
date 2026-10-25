//=============================================================================
//  R6RHeavyHelmet.uc : heavy rainbow helmet
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//
//=============================================================================
class R6RHeavyHelmet extends R6RHelmet;

#exec NEW StaticMesh File="models\R6RHeavyHelmOpen.ASE" Name="R6RHeavyHatOpen"
#exec NEW StaticMesh File="models\R6RHeavyHelm.ASE" Name="R6RHeavyHat"

function SetHelmetStaticMesh(bool bOpen)
{
	if(bOpen)
		SetStaticMesh(StaticMesh'R6RHeavyHatOpen');
	else
		SetStaticMesh(StaticMesh'R6RHeavyHat');
}

defaultproperties
{
     DrawScale=1.100000
     StaticMesh=StaticMesh'R6Characters.R6RHeavyHat'
     Skins(0)=Texture'R6Characters_T.Rainbow.R6RHeavyHelm'
     Skins(1)=FinalBlend'R6Characters_T.Rainbow.R6RVisor'
}
