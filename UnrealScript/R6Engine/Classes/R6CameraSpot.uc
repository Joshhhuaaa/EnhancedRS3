//=============================================================================
//  R6CameraSpot.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/05 * Created by Aristomenis Kolokathis
//=============================================================================
class R6CameraSpot extends actor
    placeable;

// not used currently
#exec Texture Import File=Textures\R6CameraSpot.pcx Name=S_CameraSpot Mips=Off MASKED=1

defaultproperties
{
     bStatic=True
     bHidden=True
     bCollideWhenPlacing=True
     bDirectional=True
     DrawScale=3.000000
     Texture=Texture'R6Engine.S_CameraSpot'
}
