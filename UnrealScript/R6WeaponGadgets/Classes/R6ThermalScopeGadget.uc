//=============================================================================
//  R6ThermalScopeGadget.uc : This is the base Class scopes
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6ThermalScopeGadget extends R6AbstractGadget;

var Actor m_FPThermalScopeModel;

simulated event Destroyed()
{
    Super.Destroyed();
    DestroyFPGadget();
}

function ActivateGadget(BOOL bActivate, OPTIONAL BOOL bControllerInBehindView)
{
    R6Pawn(m_OwnerCharacter).ToggleHeatVision();
}


simulated function UpdateAttachment( R6EngineWeapon weapOwner )
{
    local vector vTagLocation;
    local rotator rTagRotator;    

    Super.UpdateAttachment( weapOwner );
    
    m_GadgetShortName = Localize(m_NameID, "ID_SHORTNAME", "R6WeaponGadgets");

    SetBase( weapOwner, weapOwner.Location );

    //Use Muzzle tag for the silencer.
    weapOwner.GetTagInformations( "TagScope", vTagLocation, rTagRotator );
    SetRelativeLocation(vTagLocation);
    SetRelativeRotation(rTagRotator);
}

simulated function AttachFPGadget()
{
    if((m_WeaponOwner == none) || (R6AbstractWeapon(m_WeaponOwner).m_FPWeapon == none))
    {
        return;
    }

    if (m_FPThermalScopeModel == none)
    {
        m_FPThermalScopeModel = Spawn(Class'R6WeaponGadgets.R61stThermalScope');
    }
    
    if (m_FPThermalScopeModel != none)
    {
        R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.AttachToBone(m_FPThermalScopeModel, 'TagThermal');
    }

}

simulated function DestroyFPGadget()
{
    local Actor aFPGadget;

    aFPGadget = m_FPThermalScopeModel;
    m_FPThermalScopeModel = none;

    if (aFPGadget != none)
        aFPGadget.Destroy();
}

defaultproperties
{
     m_NameID="ThermalScope"
     DrawType=DT_StaticMesh
     m_bDrawFromBase=True
     StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdThermalScope'
}
