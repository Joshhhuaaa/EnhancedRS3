//=============================================================================
//  R6SilencerGadget.uc : This is the base Class for all Silencer.
//                        this class uses the Subgun silencer.  
//                        For other meshes overload this one
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/1/31 * Created by Joel Tremblay
//=============================================================================
class R6SilencerGadget extends R6AbstractGadget;

var Actor m_FPSilencerModel;
var class<Actor> m_pFPSilencerClass;

simulated event Destroyed()
{
    Super.Destroyed();
    DestroyFPGadget();
}

simulated function vector GetGadgetMuzzleOffset() 
{
    local vector vTagLocation;
    local rotator rTagRotator;
    GetTagInformations( "TAGSilencer", vTagLocation, rTagRotator, 1);

    return vTagLocation;
}


simulated function UpdateAttachment( R6EngineWeapon weapOwner )
{
    local vector vTagLocation;
    local rotator rTagRotator;

    Super.UpdateAttachment( weapOwner );

    m_GadgetShortName = Localize(m_NameID, "ID_SHORTNAME", "R6WeaponGadgets");

    SetBase( none );
    SetBase( weapOwner, weapOwner.Location );

    //Use Muzzle tag for the silencer.
    weapOwner.GetTagInformations( "TagMuzzle", vTagLocation, rTagRotator );
    SetRelativeLocation(vTagLocation);
    SetRelativeRotation(rTagRotator);
}

simulated function AttachFPGadget()
{
    local vector vTagLocation;
    local rotator rTagRotator;    

    if((m_WeaponOwner == none) || (R6AbstractWeapon(m_WeaponOwner).m_FPWeapon == none))
    {
        return;
    }

    if (m_FPSilencerModel == none)
    {
        m_FPSilencerModel = Spawn(m_pFPSilencerClass);
    }
    if (m_FPSilencerModel != none)
    {
        R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.AttachToBone(m_FPSilencerModel, 'TagMuzzle');
        m_FPSilencerModel.GetTagInformations( "TagMuzzle", vTagLocation, rTagRotator);
        m_WeaponOwner.m_FPFlashLocation = vTagLocation;
    }

}

simulated function DestroyFPGadget()
{
    local Actor aFPGadget;

    aFPGadget = m_FPSilencerModel;
    m_FPSilencerModel = none;

    if (aFPGadget != none)
        aFPGadget.Destroy();
}

defaultproperties
{
     m_eGadgetType=GAD_Silencer
     m_NameID="Silencer"
     m_bDrawFromBase=True
}
