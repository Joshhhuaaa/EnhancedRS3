//============================================================================//
//  R6WeaponGadgetMesh.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Class used to regoup the WeaponGadgets in the editor.
//
//============================================================================//

#exec OBJ LOAD FILE=..\StaticMeshes\R63rdWeapons_SM.usx PACKAGE=R63rdWeapons_SM

class R6WeaponGadgetMesh extends actor
    Abstract;

defaultproperties
{
     RemoteRole=ROLE_None
     DrawScale3D=(X=-1.000000,Y=-1.000000)
}
