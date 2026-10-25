//============================================================================//
// Class            R6SFX 
// Created By       Carl Lavoie
// Date             09/08/2001
// Description      R6SFX is for all SFX in the game.
//		    This is a built-in Unreal class and it shouldn't be modified.
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6LimitedSFX extends R6SFX
	abstract;

simulated function PostBeginPlay()
{
    if(Level.m_aLimitedSFX[Level.m_iLimitedSFXCount] != none)
        Level.m_aLimitedSFX[Level.m_iLimitedSFXCount].Kill();

    Level.m_aLimitedSFX[Level.m_iLimitedSFXCount] = self;

    Level.m_iLimitedSFXCount++;
    if(Level.m_iLimitedSFXCount == 6)
        Level.m_iLimitedSFXCount = 0;
}

defaultproperties
{
}
