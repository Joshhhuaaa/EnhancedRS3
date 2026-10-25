//=============================================================================
//  R6RPilotHelmet.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/24 * Created by Rima Brek
//=============================================================================
class R6RPilotHelmet extends R6RHelmet;

#exec NEW StaticMesh File="models\R6RPilotHelm.ASE" Name="R6RPilotHat" YAW=32768

defaultproperties
{
     DrawScale=1.100000
     StaticMesh=StaticMesh'R6Characters.R6RPilotHat'
     Skins(0)=FinalBlend'R6Characters_T.Rainbow.R6RPilotHelm_FB'
}
