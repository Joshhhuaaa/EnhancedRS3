//============================================================================//
// Class            R6MatineeAttach.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Information on Attachement for R6PlayAnimSequence
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/21	    Cyrille Lauzon: Creation
//============================================================================//

class R6MatineeAttach extends Object
	native
	notplaceable;

var				Actor		m_AttachActor;

var				string		m_StaticMeshTag;
var				name		m_PawnTag;


var				name		m_BoneName;
var				R6Pawn		m_AttachPawn;

var				bool		m_bInitialized;

//The <docking> position
var				vector		m_InteractionPos;
var				rotator		m_InteractionRot;

//The <offset> position
var			vector			m_OffsetPos;
var			rotator			m_OffsetRot;

native(2907) final function GetBoneInformation();
native(2908) final function TestLocation();

function InitAttach()
{
	local vector MeshPos;
	local rotator MeshRot;
	
	if(m_PawnTag!='' && m_AttachActor!=none)
	{
		//Get the bone name
		GetBoneInformation();
		
		m_AttachActor.GetTagInformations(m_StaticMeshTag, MeshPos, MeshRot);
		m_InteractionPos = m_AttachActor.Location + MeshPos;
		m_InteractionRot = m_AttachActor.Rotation + MeshRot;

		m_bInitialized=true;
	}
	else
	{
		m_bInitialized=false;
	}
}

function MatineeAttach()
{
	if(m_bInitialized == true)
	{
		m_AttachPawn.AttachToBone(m_AttachActor, m_BoneName);
		m_AttachActor.SetRelativeLocation(m_OffsetPos);
		m_AttachActor.SetRelativeRotation(m_OffsetRot);
	}
}

function MatineeDetach()
{
	local vector  location;
	local rotator rotation;

	if(m_bInitialized==true)
	{
		m_AttachPawn.DetachFromBone(m_AttachActor);		
	}
}

defaultproperties
{
}
