//=============================================================================
//  R6Stairs.uc : use a Stairs class to mark the top and bottom of stairs
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/29 * Created by Rima Brek
//    2002/04/12   Recreated for a different purpose
//=============================================================================
class R6Stairs extends NavigationPoint
	native
	notplaceable;

#exec Texture Import File=Textures\S_StairsNavP.bmp Name=S_StairsNavP Mips=Off MASKED=1


var()     bool					m_bIsTopOfStairs;

defaultproperties
{
     bCollideWhenPlacing=False
     bDirectional=True
     Texture=Texture'R6Engine.S_StairsNavP'
}
