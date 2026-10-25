//=============================================================================
//  R6MatineeTerrorist.uc : A placeable Terrorist Class for Matinee. 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeTerrorist extends R6Terrorist
    placeable
    native;

var(R6Equipment)				class<R6AbstractWeapon> m_PrimaryWeapon;
//var(R6Equipment)				class<R6AbstractWeapon> m_GrenadeWeapon;
//var(R6Equipment)				class<R6AbstractGadget> m_Gadget;

var(R6Equipment)				class<R6Terrorist>m_TerroristTemplate;
var(R6Equipment)				bool			   m_bUseTerroristTemplate;

var								R6MatineeAttach	 m_MatineeAttach;

//--------------------------------------
//PostBeginPlay
//Desc: Initialize the Terrorist, taken from 
//		R6Terrorist.PostInitialize() The function is not directly
//		called because it may change. We only want to have a 
//		pawn that works, no other initializations. 
//--------------------------------------
event PostBeginPlay()
{
	//Initialize the attachement object:
	m_MatineeAttach = New(None) class'R6MatineeAttach'; //class<R6MatineeAttach>(DynamicLoadObject("MatineeAttach", class'R6Engine.R6MatineeAttach'));

	//Init Equipment and outfit:
	if(m_TerroristTemplate!=none && m_bUseTerroristTemplate)
	{
		Skins = m_TerroristTemplate.Default.Skins;
		LinkMesh( m_TerroristTemplate.Default.Mesh );
	}	
	m_szPrimaryWeapon = string(m_PrimaryWeapon);
//	m_szGrenadeWeapon = string(m_GrenadeWeapon);
//	m_szGadget		  = string(m_Gadget);

    CommonInit();    
   
	SetPhysics(Physics);
}


function SetAttachVar(Actor AttachActor, string StaticMeshTag, name PawnTag)
{
	m_MatineeAttach.m_AttachActor   = AttachActor;
	
	m_MatineeAttach.m_StaticMeshTag = StaticMeshTag;
	m_MatineeAttach.m_PawnTag		= PawnTag;

	m_MatineeAttach.m_AttachPawn	= self;
	
	m_MatineeAttach.InitAttach();
}

function MatineeAttach()
{
	m_MatineeAttach.MatineeAttach();
}

function MatineeDetach()
{
	m_MatineeAttach.MatineeDetach();
}

defaultproperties
{
     m_szPrimaryWeapon="R63rdWeapons.NormalSubMP5A4"
     Mesh=SkeletalMesh'R6Terrorist_UKX.Militant01Mesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel23
         KConvulseSpacing=(Max=2.200000)
         KSkeleton="terroskel"
         KStartEnabled=True
         bHighDetailOnly=False
         KLinearDamping=0.500000
         KAngularDamping=0.500000
         KBuoyancy=1.000000
         KVelDropBelowThreshold=50.000000
         KFriction=0.600000
         KRestitution=0.300000
         KImpactThreshold=150.000000
         Name="KarmaParamsSkel23"
     End Object
     KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel23'
}
