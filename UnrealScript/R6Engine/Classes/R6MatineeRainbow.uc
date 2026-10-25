//=============================================================================
//  R6MatineeRainbow.uc : A placeable Rainbow Class for Matinee. 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeRainbow extends R6Rainbow
    placeable
    native;

//Redeclare weapons that have new name so we let the parent class's variable
//uneditable. And it enables us to have a drop box in the editor.

var(R6Equipment)		 class<R6AbstractWeapon> m_PrimaryWeapon;
var(R6Equipment)		 class<R6AbstractWeapon> m_SecondaryWeapon;
var(R6Equipment)         class<R6AbstractGadget> m_PrimaryGadget;
var(R6Equipment)         class<R6AbstractGadget> m_SecondaryGadget;
//var(R6Equipment)       string	    	 m_PrimaryItem;
//var(R6Equipment)       string			 m_SecondaryItem;
var(R6Equipment)		 bool			 m_bActivateGadget;
var(R6Equipment)		 class<R6Rainbow>m_RainbowTemplate;
var(R6Equipment)		 bool			 m_bUseRainbowTemplate;


//Private Variables:
var		R6RainbowAI		 m_Controller;

var		R6MatineeAttach	 m_MatineeAttach;

//--------------------------------------
//PostBeginPlay
//Desc: Initialize the Rainbow
//--------------------------------------
event PostBeginPlay()
{	
	//Initialize the attachement object:
	m_MatineeAttach = New(None) class'R6MatineeAttach'; //class<R6MatineeAttach>(DynamicLoadObject("MatineeAttach", class'R6Engine.R6MatineeAttach'));

	//Dress and equip the Rainbow:
	if(m_RainbowTemplate!=none && m_bUseRainbowTemplate)
	{
		Skins = m_RainbowTemplate.Default.Skins;
		LinkMesh( m_RainbowTemplate.Default.Mesh );
		m_HelmetClass = m_RainbowTemplate.Default.m_HelmetClass;
	}
	
	super.PostBeginPlay();

	//Initialize the weapons variables:
	m_szPrimaryWeapon   = string(m_PrimaryWeapon);
	m_szPrimaryGadget   = string(m_PrimaryGadget);
	m_szSecondaryWeapon = string(m_SecondaryWeapon);
	m_szSecondaryGadget = string(m_SecondaryGadget);
	//m_szPrimaryItem     = m_PrimaryItem;
	//m_szSecondaryItem   = m_SecondaryItem;

	
	// Spawn the controller
	if(Controller!=None)
	{
		UnPossessed();
	}

	Controller = Spawn(ControllerClass);
	m_Controller = R6RainbowAI(Controller);
	    
	m_Controller.m_PaceMember=self;
	m_Controller.m_TeamLeader=self;
	m_Controller.Possess(self); 

	GiveDefaultWeapon();

	if(m_bActivateGadget == true)
    {
        m_bWeaponGadgetActivated = true;
        R6AbstractWeapon(EngineWeapon).m_SelectedWeaponGadget.ActivateGadget(TRUE);
    }

}

function SetMovementPhysics()
{ 
    //SetPhysics(Physics);
}


function SetAttachVar(Actor AttachActor, string StaticMeshTag, name PawnTag)
{
 	log("R6MatineeRainbow::SetAttachVar");
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
     m_bActivateGadget=True
     m_bUseRainbowTemplate=True
     Mesh=SkeletalMesh'R6Rainbow_UKX.LightMesh'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel21
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
         Name="KarmaParamsSkel21"
     End Object
     KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel21'
     Skins(5)=Texture'R61stWeapons_T.Hands.R61stHands'
}
