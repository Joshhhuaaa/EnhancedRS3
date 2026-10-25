//============================================================================//
// Class            R6SubActionAnimSequence.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Launches a sequence of animations.
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/19	    Cyrille Lauzon: Creation
//============================================================================//

#exec Texture Import File=Textures\R6SubActionAnimSequence.pcx Name=R6SubActionAnimSequenceIcon Mips=Off

class R6SubActionAnimSequence extends MatSubAction
	native;

var(R6Animation)	export	editinline	array<R6PlayAnim>	m_Sequences;
var(R6Animation)	R6Pawn									m_AffectedPawn;
var(R6Animation)	Actor									m_AffectedActor;
var(R6Animation)    bool                                    m_bUseRootMotion;


//Private variables:
var		int			m_CurIndex;
var		R6PlayAnim	m_CurSequence;
var		bool		m_bFirstTime;
var     bool		m_bResetAnimation;



//Events:
event Initialize()
{ 
	m_bFirstTime=true;

	if(m_AffectedPawn!=none && m_AffectedActor==none)
	{
		m_AffectedActor = m_AffectedPawn;
	}	

}

//Called at each time we change the animation sequence:
event SequenceChanged()
{
	m_AffectedActor.SetAttachVar(m_CurSequence.m_AttachActor, m_CurSequence.m_StaticMeshTag, 
							 	 m_CurSequence.m_PawnTag);
} 

event SequenceFinished()
{
    if (m_bUseRootMotion)
    {
        m_AffectedActor.bCollideWorld = true;
        m_AffectedActor.SetPhysics(PHYS_Walking);
    }
}

defaultproperties
{
     m_bUseRootMotion=True
     m_bFirstTime=True
     Icon=Texture'R6Engine.R6SubActionAnimSequenceIcon'
     Desc="PlayAnimation"
}
