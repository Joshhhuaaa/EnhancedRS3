//=============================================================================
//  R6MatineeHostage.uc : A placeable Hostage Class for Matinee. 
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeHostage extends R6Hostage
    placeable
    native;

#exec OBJ LOAD FILE=..\Animations\R6Hostage_UKX.ukx PACKAGE=R6Hostage_UKX

//Equipment:
var(R6Equipment)		 class<R6Hostage>m_HostageTemplate;
var(R6Equipment)		 bool			 m_bUseHostageTemplate;

//Private Variables:
var		R6MatineeAttach	 m_MatineeAttach;

event PostBeginPlay()
{

	//Initialize the attachement object:
	m_MatineeAttach = New(None) class'R6MatineeAttach'; //class<R6MatineeAttach>(DynamicLoadObject("MatineeAttach", class'R6Engine.R6MatineeAttach'));
	
	//Dress and equip the Hostage:
	if(m_HostageTemplate!=none && m_bUseHostageTemplate)
	{
		Skins = m_HostageTemplate.Default.Skins;
 		LinkMesh( m_HostageTemplate.Default.Mesh );
	}

	super.PostBeginPlay();
	
	// Spawn the controller
	if(Controller!=None)
	{
		UnPossessed();
	}
	Controller = Spawn(ControllerClass);
	Controller.Possess( Self );

	m_controller = R6HostageAI(controller);		
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
     m_bUseHostageTemplate=True
     CollisionHeight=85.000000
     Mesh=SkeletalMesh'R6Hostage_UKX.CasualManMesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel18
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
         Name="KarmaParamsSkel18"
     End Object
     KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel18'
}
