//=============================================================================
//  R6AbstractGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6AbstractGadget extends Actor
    native
    nativereplication
    abstract;

var name    m_AttachmentName;
var R6EngineWeapon m_WeaponOwner;
var Pawn    m_OwnerCharacter;
var string  m_NameID;             // Weapon Name ID 
var string  m_GadgetName;
var string  m_GadgetShortName;
var R6AbstractWeapon.eGadgetType m_eGadgetType;

simulated event Destroyed()
{
    Super.Destroyed();
    m_WeaponOwner = none;
    m_OwnerCharacter = none;
}

simulated function InitGadget(R6EngineWeapon OwnerWeapon, Pawn OwnerCharacter)
{
    UpdateAttachment(OwnerWeapon);
    m_OwnerCharacter = OwnerCharacter;
    AttachFPGadget();
}

simulated function UpdateAttachment( R6EngineWeapon weapOwner )
{
    m_WeaponOwner = weapOwner;
}

simulated function AttachFPGadget();
simulated function DestroyFPGadget();

function ActivateGadget(BOOL bActivate, OPTIONAL BOOL bControllerInBehindView);

function vector GetGadgetMuzzleOffset() {return vect(0,0,0);}

function Toggle3rdBipod(BOOL bBipodOpen);

defaultproperties
{
     RemoteRole=ROLE_None
     DrawType=DT_None
     bSkipActorPropertyReplication=True
     m_bForceBaseReplication=True
     DrawScale3D=(X=-1.000000,Y=-1.000000)
}
