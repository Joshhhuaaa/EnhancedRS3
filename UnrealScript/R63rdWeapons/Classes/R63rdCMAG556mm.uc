//============================================================================//
//  R63rdCMAG556mm.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R63rdCMAG556mm extends R6MagazineGadget;

#exec OBJ LOAD FILE=..\StaticMeshes\R63rdWeapons_SM.usx PACKAGE=R63rdWeapons_SM

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdCMAG556mm'
}
