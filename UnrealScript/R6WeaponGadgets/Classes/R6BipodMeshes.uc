//============================================================================//
//  R6BipodMeshes.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//

Class R6BipodMeshes extends R6WeaponGadgetMesh
    abstract;

var (R6Meshes) StaticMesh CloseSM;
var (R6Meshes) StaticMesh OpenSM;

defaultproperties
{
     DrawType=DT_StaticMesh
}
