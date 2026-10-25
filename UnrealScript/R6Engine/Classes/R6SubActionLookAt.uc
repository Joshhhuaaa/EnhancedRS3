//============================================================================//
// Class            R6SubActionLookAt.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Makes the head of the Actor look at an other actor
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/19	    Cyrille Lauzon: Creation
//============================================================================//

#exec Texture Import File=Textures\R6SubActionLookAt.pcx Name=R6SubActionLookAtIcon Mips=Off

class R6SubActionLookAt extends MatSubAction
	native;

var(R6LookAt)	R6Pawn		m_AffectedPawn;
var(R6LookAt)	Actor		m_TargetActor;
var(R6LookAt)	bool		m_bAim;
var(R6LookAt)	bool		m_bNoBlend;

defaultproperties
{
     Icon=Texture'R6Engine.R6SubActionLookAtIcon'
     Desc="LookAtActor"
}
