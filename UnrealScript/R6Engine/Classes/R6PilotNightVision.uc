//=============================================================================
//  R6NightVision.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/21 * Created by Rima Brek
//============================================================================= 
class R6PilotNightVision extends R6NightVision;
 
#exec NEW StaticMesh File="models\R6RPilotNightVision.ASE" Name="R6RPilotNightVision"

defaultproperties
{
     DrawScale=1.200000
     StaticMesh=StaticMesh'R6Engine.R6RPilotNightVision'
     Skins(0)=Texture'R6Characters_T.Rainbow.R6RPilotNightVision'
}
