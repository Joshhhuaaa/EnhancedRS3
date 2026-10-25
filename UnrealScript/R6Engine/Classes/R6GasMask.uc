//=============================================================================
//  R6GasMask.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/14 * Created by Rima Brek
//============================================================================= 
class R6GasMask extends StaticMeshActor;

#exec NEW StaticMesh File="models\R6GasMask.ASE" Name="R6GasMask"

defaultproperties
{
     RemoteRole=ROLE_None
     bStatic=False
     bWorldGeometry=False
     m_bDeleteOnReset=True
     m_bDrawFromBase=True
     bShadowCast=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bEdShouldSnap=False
     DrawScale=1.100000
     StaticMesh=StaticMesh'R6Engine.R6GasMask'
     Skins(0)=Texture'R6Characters_T.Rainbow.R6GasMask'
     DrawScale3D=(X=-1.000000,Y=-1.000000)
}
