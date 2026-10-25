//=============================================================================
//  R6ScopeGadget.uc : This is the base Class scopes
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/1/31 * Created by Joel Tremblay
//=============================================================================
class R6ScopeGadget extends R6AbstractGadget;


simulated function UpdateAttachment( R6EngineWeapon weapOwner )
{
    local vector vTagLocation;
    local rotator rTagRotator;    

    Super.UpdateAttachment( weapOwner );
    
    SetBase( none );
    SetBase( weapOwner, weapOwner.Location );

    //Use Muzzle tag for the silencer.
    weapOwner.GetTagInformations( "TagScope", vTagLocation, rTagRotator );
    SetRelativeLocation(vTagLocation);
    SetRelativeRotation(rTagRotator);
}

defaultproperties
{
     m_eGadgetType=GAD_SniperRifleScope
     DrawType=DT_StaticMesh
     m_bDrawFromBase=True
     StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdDefaultScope'
}
