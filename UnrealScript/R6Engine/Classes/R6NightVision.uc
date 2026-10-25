//=============================================================================
//  R6NightVision.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/21 * Created by Rima Brek
//============================================================================= 
class R6NightVision extends StaticMeshActor;

defaultproperties
{
     bStatic=False
     bWorldGeometry=False
     bSkipActorPropertyReplication=True
     m_bDeleteOnReset=True
     m_bDrawFromBase=True
     bShadowCast=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bEdShouldSnap=False
     DrawScale=1.100000
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdNightVision'
     DrawScale3D=(X=-1.000000,Y=-1.000000)
}
