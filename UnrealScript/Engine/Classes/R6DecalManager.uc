//============================================================================//
// Class            R6DecalManager.uc 
// Created By       Cyrille Lauzon
// Date             2001/01/18
// Description      Manages multiple lists of Decals
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6DecalManager extends Actor
	native;

enum eDecalType
{
	DECAL_Footstep,
	DECAL_Bullet,
    DECAL_BloodSplats,
    DECAL_BloodBaths,
    DECAL_GrenadeDecals
};

var(R6DecalManager) R6DecalGroup m_FootSteps;
var(R6DecalManager) R6DecalGroup m_WallHit;
var(R6DecalManager) R6DecalGroup m_BloodSplats;
var(R6DecalManager) R6DecalGroup m_BloodBaths;
var(R6DecalManager) R6DecalGroup m_GrenadeDecals;
var(R6DecalManager) bool		 m_bActive;


native(2900) final function AddDecal(vector position, rotator rotation, Texture decalTexture, eDecalType type, INT iFov, FLOAT fDuration, FLOAT fStartTime, FLOAT fMaxTraceDistance, optional FLOAT CullDistance);
native(2901) final function KillDecal();

simulated event Destroyed()
{
    if ( m_FootSteps != none ) {
        m_FootSteps.destroy();
        m_FootSteps = none;
    }

    if ( m_WallHit != none ) {
        m_WallHit.destroy();
        m_WallHit = none;
    }
    if ( m_BloodSplats != none ) {
        m_BloodSplats.destroy();
        m_BloodSplats = none;
    }

    if ( m_BloodBaths != none ) {
        m_BloodBaths.destroy();
        m_BloodBaths = none;
    }

    if ( m_GrenadeDecals != none ) {
        m_GrenadeDecals.destroy();
        m_GrenadeDecals = none;
    }
    
    Super.Destroyed();
}

defaultproperties
{
     m_bActive=True
     bHidden=True
}
