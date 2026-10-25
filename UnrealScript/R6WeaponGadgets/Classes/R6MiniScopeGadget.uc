//=============================================================================
//  R6MiniScopeGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6MiniScopeGadget extends R6AbstractGadget;

var Actor m_FPMiniScopeModel;
var (R6Attachment) class<Actor> m_pFPMiniScopeClass;
var texture m_ScopeTexure;
var texture m_ScopeAdd;

simulated event Destroyed()
{
    Super.Destroyed();
    DestroyFPGadget();
}

function InitGadget(R6EngineWeapon OwnerWeapon, Pawn OwnerCharacter)
{
    OwnerWeapon.m_fMaxZoom = 3.5 ;
    OwnerWeapon.UseScopeStaticMesh();
    Super.InitGadget(OwnerWeapon, OwnerCharacter);
}


function ActivateGadget(BOOL bActivate, OPTIONAL BOOL bControllerInBehindView)
{}

simulated function UpdateAttachment( R6EngineWeapon weapOwner)
{
    local vector vTagLocation;
    local rotator rTagRotator;    

    Super.UpdateAttachment( weapOwner );

    m_GadgetShortName = Localize(m_NameID, "ID_SHORTNAME", "R6WeaponGadgets");

    SetBase( none );
    SetBase( weapOwner, weapOwner.Location );

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

    if ((m_FPMiniScopeModel == none) && (m_pFPMiniScopeClass != none))
    {
        m_FPMiniScopeModel = Spawn(m_pFPMiniScopeClass);
        m_FPMiniScopeModel.SetOwner(self);
        m_FPMiniScopeModel.RemoteRole=ROLE_None;
    }
    
    if (m_FPMiniScopeModel != none)
    {
        R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.AttachToBone(m_FPMiniScopeModel, 'TagScope');
        R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.SwitchFPMesh();
        R6AbstractWeapon(m_WeaponOwner).m_FPHands.SwitchFPAnim();
    }
    m_WeaponOwner.m_ScopeTexture = m_ScopeTexure;
    m_WeaponOwner.m_ScopeAdd = m_ScopeAdd;
}

simulated function DestroyFPGadget()
{
    local actor temp;
    if (m_FPMiniScopeModel != none)
    {
        temp = m_FPMiniScopeModel;
        m_FPMiniScopeModel=none;
        temp.Destroy();
    }
}

defaultproperties
{
     m_ScopeTexure=Texture'Inventory_t.Scope.ScopeBlurTex_3'
     m_ScopeAdd=Texture'Inventory_t.Scope.ScopeBlurTex_3add'
     m_pFPMiniScopeClass=Class'R6WeaponGadgets.R61stMiniScope'
     m_NameID="MiniScope"
     DrawType=DT_StaticMesh
     m_bDrawFromBase=True
     StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdMiniScope'
}
