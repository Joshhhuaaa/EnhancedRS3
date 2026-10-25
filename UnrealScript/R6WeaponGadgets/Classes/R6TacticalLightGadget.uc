//=============================================================================
//  R6TacticalLightGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6TacticalLightGadget extends R6AbstractGadget;

//var Actor m_TacticalBeam;         // Pointer to the tactical beam when the tactical light is activated;
//var (R6Attachment) class<Actor> m_pTacticalBeamClass;
var R6TacticalGlowLight m_GlowLight;

simulated event Destroyed()
{
    Super.Destroyed();
/*
    if (m_TacticalBeam != none)
    {
        m_TacticalBeam.destroy();
        m_TacticalBeam=none;
    }
*/
    if (m_GlowLight != none)
    {
        m_GlowLight.destroy();
        m_GlowLight=none;
    }
}

    
function ActivateGadget(BOOL bActivate, OPTIONAL BOOL bControllerInBehindView)
{
    local vector vTagLocation;
    local rotator rTagRotator; 
    local vector vGlowLightLocation;
    local rotator rGlowLightRotator;

    if (bActivate == true)
    {
        if ((bControllerInBehindView == TRUE) || (Level.NetMode != NM_Standalone))
        {
/*
            if (m_TacticalBeam == none)
            {
                m_TacticalBeam = Spawn(m_pTacticalBeamClass);
            }
*/

            if (m_GlowLight == none)
            {
                m_GlowLight = Spawn(class'Engine.R6TacticalGlowLight');
                m_GlowLight.SetOwner(m_WeaponOwner);
            }
            
            m_WeaponOwner.GetTagInformations( "TagGadget", vTagLocation, rTagRotator, m_OwnerCharacter.m_fAttachFactor);
/*
            m_TacticalBeam.SetBase( none );
            m_TacticalBeam.SetBase( m_WeaponOwner, m_WeaponOwner.Location );
            m_TacticalBeam.SetRelativeLocation(vTagLocation);
            m_TacticalBeam.SetRelativeRotation(rTagRotator);
*/
            m_GlowLight.SetBase( none );
            m_GlowLight.SetBase( m_WeaponOwner, m_WeaponOwner.Location );
            m_GlowLight.SetRelativeLocation(vTagLocation + vGlowLightLocation);
            m_GlowLight.SetRelativeRotation(rTagRotator + rGlowLightRotator);
        }
    }
    else
    {
/*
        if (m_TacticalBeam != none)
        {
            m_TacticalBeam.SetBase( none );
            m_TacticalBeam.Destroy();
            m_TacticalBeam = none;
        }
*/
        if (m_GlowLight != None)
        {
            m_GlowLight.SetBase( none );
            m_GlowLight.Destroy();
            m_GlowLight = none;        
        }
    }
}

simulated function UpdateAttachment( R6EngineWeapon weapOwner )
{
    local vector vTagLocation;
    local rotator rTagRotator;    

    Super.UpdateAttachment( weapOwner );

    SetBase( none );
    SetBase( weapOwner, weapOwner.Location );

    weapOwner.GetTagInformations( "TagGadget", vTagLocation, rTagRotator );
    SetRelativeLocation(vTagLocation);
    SetRelativeRotation(rTagRotator);
}

defaultproperties
{
     m_eGadgetType=GAD_Light
     DrawType=DT_StaticMesh
     m_bDrawFromBase=True
     StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdTACSubGuns'
}
