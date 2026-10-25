//=============================================================================
//  R6RHelmet.uc : rainbow helmet base class
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//		2001/10/03 * Created by Rima Brek
//=============================================================================
class R6RHelmet extends R6AbstractHelmet
	abstract;
   
#exec OBJ LOAD FILE=..\Textures\R6Characters_T.utx PACKAGE=R6Characters_T

defaultproperties
{
     RemoteRole=ROLE_None
     bStatic=False
     bWorldGeometry=False
     m_bDrawFromBase=True
     bShadowCast=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bEdShouldSnap=False
     DrawScale3D=(X=-1.000000,Y=-1.000000)
}
