//============================================================================//
// Class            R6BloodSplat.uc 
// Created By       
// Date             
// Description      R6 base class for blood splat effects.
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/24    Jean-Francois Dube: Creation
//============================================================================//

class R6BloodSplat extends R6DecalsBase;

var texture m_BloodSplatTexture;

simulated function PostBeginPlay()
{
    local Rotator DecalRot;

	if(Level.NetMode != NM_DedicatedServer)
    {
        DecalRot = Rotation;
        DecalRot.Roll = Rand(65535);
        Level.m_DecalManager.AddDecal(Location, DecalRot, m_BloodSplatTexture, DECAL_BloodSplats, 1, 0, 0, 300);
    }

    Super.PostBeginPlay();
}

defaultproperties
{
     m_BloodSplatTexture=Texture'Inventory_t.BloodSplats.BloodSplat'
     bHidden=True
     bNetOptional=True
     LifeSpan=0.100000
     Texture=None
}
