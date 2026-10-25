//=============================================================================
//  R6PilotGasMask.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/13 * Created by Rima Brek
//============================================================================= 
class R6PilotGasMask extends R6GasMask;

#exec NEW StaticMesh File="models\R6RPilotGMask.ASE" Name="R6RPilotGMask"

defaultproperties
{
     StaticMesh=StaticMesh'R6Engine.R6RPilotGMask'
     Skins(0)=Texture'R6Characters_T.Rainbow.R6RPilotGMask'
}
