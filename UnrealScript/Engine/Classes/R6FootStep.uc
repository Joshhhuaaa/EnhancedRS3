//============================================================================//
// Class            R6Footstep.uc 
// Created By       Cyrille Lauzon
// Date             2002/02/07
// Description      R6 base class for footstep decals.
//----------------------------------------------------------------------------//
// Modification History
//                  2002/10/09 - Rewritten by Jean-Francois Dube
//============================================================================//
class R6FootStep extends Actor
    abstract
    native;

// Normal footsteps
var(Rainbow) Texture    m_DecalLeftFootTexture;
var(Rainbow) Texture    m_DecalRightFootTexture;
var(Rainbow) Texture    m_DecalLeftFootTextureDirty;
var(Rainbow) Texture    m_DecalRightFootTextureDirty;
var(Rainbow) FLOAT      m_fDuration;

// Dirty footsteps
var(Rainbow) FLOAT      m_fDurationDirty;
var(Rainbow) FLOAT      m_fDirtyTime;

var          FLOAT      m_fFootStepDuration;
var          FLOAT      m_fFootStepCurrentTime;
var          Texture    m_DecalFootTexture;

defaultproperties
{
     m_fDurationDirty=10.000000
     RemoteRole=ROLE_None
     DrawType=DT_None
     bHidden=True
     m_fSoundRadiusSaturation=150.000000
     Texture=None
}
