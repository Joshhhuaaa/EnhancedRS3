//============================================================================//
//  R6BipodGadget.uc
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/29/04 * Created by Joel Tremblay
//=============================================================================

Class R6BipodGadget extends R6AbstractGadget;

var (R6Meshes) StaticMesh CloseSM;
var (R6Meshes) StaticMesh OpenSM;

simulated function Toggle3rdBipod(BOOL bBipodOpen)
{
    if(bBipodOpen == false)
    {
        SetStaticMesh(CloseSM);
    }
    else
    {
        SetStaticMesh(OpenSM);
    }
}

simulated function UpdateAttachment( R6EngineWeapon weapOwner )
{
    local vector vTagLocation;
    local rotator rTagRotator;    

    Super.UpdateAttachment( weapOwner );
    
    SetBase( none );
    SetBase( weapOwner, weapOwner.Location );

    //Use Muzzle tag for the silencer.
    weapOwner.GetTagInformations( "TagBipod", vTagLocation, rTagRotator );
    SetRelativeLocation(vTagLocation);
    SetRelativeRotation(rTagRotator);
}

defaultproperties
{
     m_eGadgetType=GAD_Bipod
     DrawType=DT_StaticMesh
     m_bDrawFromBase=True
}
