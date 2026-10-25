//=============================================================================
//  R6RHelmet.uc : New rainbow helmet base class. Moved here to provide a 
//				   pointer for helmets in UnrealEd.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//		2002/15/03 * Created by Cyrille Lauzon
//=============================================================================
class R6AbstractHelmet extends StaticMeshActor
	abstract;

function SetHelmetStaticMesh(bool bOpen);

defaultproperties
{
}
