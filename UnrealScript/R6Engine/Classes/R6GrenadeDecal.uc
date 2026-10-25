//============================================================================//
// Class            R6GrenadeDecal.uc 
// Created By       
// Date             
// Description      R6 base class for grenade splatch effects.
//----------------------------------------------------------------------------//
// Revision history:
// 2002/05/11       Jean-Francois Dube: Creation
//============================================================================//

class R6GrenadeDecal extends R6DecalsBase;

var texture m_GrenadeDecalTexture;

simulated function PostBeginPlay()
{
    local Rotator DecalRot;

    if(Level.NetMode != NM_DedicatedServer)
    {
        DecalRot.Pitch = 49152;
        DecalRot.Yaw = 0;
        DecalRot.Roll = Rand(65535);
        Level.m_DecalManager.AddDecal(Location, DecalRot, m_GrenadeDecalTexture, DECAL_GrenadeDecals, 1, 0, 0, 50);
    }

    Super.PostBeginPlay();
}

defaultproperties
{
     m_GrenadeDecalTexture=Texture'R6SFX_T.Grenade.GrenadeImpact'
     bHidden=True
     bNetOptional=True
     bNetInitialRotation=False
     LifeSpan=0.100000
     Texture=None
}
