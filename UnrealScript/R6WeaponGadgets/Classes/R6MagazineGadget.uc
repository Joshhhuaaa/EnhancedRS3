//=============================================================================
//  R6MuzzleGadget.uc : This is the base Class for all Silencer.
//                        this class uses the Subgun silencer.  
//                        For other meshes overload this one
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/3/20 * Created by Serge Dore
//=============================================================================
class R6MagazineGadget extends R6AbstractGadget;

simulated function UpdateAttachment( R6EngineWeapon weapOwner )
{
    local vector vTagLocation;
    local rotator rTagRotator;    

    Super.UpdateAttachment( weapOwner );

    SetBase( none );
    SetBase( weapOwner, weapOwner.Location );
    
    //Use Muzzle tag for the silencer.
    weapOwner.GetTagInformations( "TagMagazine", vTagLocation, rTagRotator );
    SetRelativeLocation(vTagLocation);
    SetRelativeRotation(rTagRotator);
}

defaultproperties
{
     m_eGadgetType=GAD_Magazine
     m_NameID="CMag"
     m_bDrawFromBase=True
}
