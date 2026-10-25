//=============================================================================
//  R6IOObject : This should allow action moves on the door
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6IOObject extends R6IActionObject
    native;

#exec OBJ LOAD FILE=..\StaticMeshes\R6ActionObjects.usx PACKAGE=R6ActionObjects

// R6CIRCUMSTANTIALACTION
#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
// R6CIRCUMSTANTIALACTION

var(R6ActionObject) FLOAT m_fGainTimeWithElectronicsKit;  // 2 sec by default
var(R6ActionObject) BOOL  m_bToggleType;    //can this object be toggled on/off, or set only once while in-round?
var                 BOOL sm_bToggleType;    
var(R6ActionObject) BOOL  m_bIsActivated;   //state of the object
var                 BOOL sm_bIsActivated;   
var(R6ActionObject) R6Pawn.eDeviceAnimToPlay m_eAnimToPlay;
var                 FLOAT m_fLockObjectTime; // time the object started to be used. Only one pawn can interact with this object

var Sound			m_StartSnd;
var Sound			m_InterruptedSnd;
var Sound			m_CompletedSnd;



enum eDeviceCircumstantialAction
{
    DCA_None,
    DCA_DisarmBomb,
    DCA_ArmBomb,
	DCA_Device
};

enum eStateIOObejct
{
    SIO_Start,
    SIO_Interrupt,
    SIO_Complete
};

var eStateIOObejct  m_ObjectState;

replication
{
    reliable if (Role==ROLE_Authority)
        sm_bIsActivated, m_bIsActivated;

}

//------------------------------------------------------------------
// SaveOriginalData
//	
//------------------------------------------------------------------
simulated function SaveOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( true );
    Super.SaveOriginalData();

    sm_bIsActivated = m_bIsActivated;     
    sm_bToggleType  = m_bToggleType;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    m_bIsActivated = sm_bIsActivated;     
    m_bToggleType  = sm_bToggleType;
    m_fLockObjectTime = 0;
}

//------------------------------------------------------------------
// LockObjectUse
//	
//------------------------------------------------------------------
simulated function LockObjectUse( bool bIsInUse )
{
    if ( bIsInUse )
        m_fLockObjectTime = Level.TimeSeconds;        
    else
        m_fLockObjectTime = 0;
}

//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
simulated function R6CircumstantialActionProgressStart( R6AbstractCircumstantialActionQuery Query )
{
    m_fPlayerCAStartTime = Level.TimeSeconds;
	PerformSoundAction(SIO_Start);
    LockObjectUse( true );
}

//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//   Update the device planting progress                                     //
//   Should be affected by the skills of the pawn planting it                //
//===========================================================================//
simulated function INT  R6GetCircumstantialActionProgress( R6AbstractCircumstantialActionQuery Query, Pawn actingPawn )
{
    local FLOAT fPercentage;

    fPercentage = (Level.TimeSeconds - m_fPlayerCAStartTime) / (Query.fPlayerActionTimeRequired * (2.0 - R6Pawn(actingPawn).ArmorSkillEffect()));
	fPercentage *= 100;
	
    if ( fPercentage >= 100 )
        LockObjectUse( false );

	if ((fPercentage >= 100) && (m_ObjectState != SIO_Complete))
        PerformSoundAction(SIO_Complete);
	

    return fPercentage;
}

simulated function R6CircumstantialActionCancel()
{
    LockObjectUse( false );
    PerformSoundAction(SIO_Interrupt);
}


simulated function BOOL HasKit(R6Pawn aPawn)
{
    return false;
}

//------------------------------------------------------------------
// GetMaxTimeRequired
//	used to unlock an IOObject that was locked
//------------------------------------------------------------------
simulated function FLOAT GetMaxTimeRequired()
{
    return 0;
}

simulated function FLOAT GetTimeRequired(R6Pawn aPawn)
{
    return 0;
}

simulated function ToggleDevice(R6Pawn aPawn)
{
    local float fBackup;

    fBackup = m_fLockObjectTime;

    // for AI, removed the lock
    if ( !aPawn.m_bIsPlayer )  
        m_fLockObjectTime = 0;

	if ( CanToggle() )
    {
        LockObjectUse( false );
    }
    else
        fBackup = m_fLockObjectTime;
}

simulated function BOOL CanToggle()
{

    local bool bCanToggle;
    bCanToggle = ( (sm_bIsActivated == m_bIsActivated) || (m_bToggleType == true));

    // can toggle, but check if locked
    if ( bCanToggle && m_fLockObjectTime != 0 )
    {
        // backup situtation to remove the lock if the max time is expired
        if ( GetMaxTimeRequired() < Level.TimeSeconds - m_fLockObjectTime   )
            LockObjectUse( false );
        else
            return false; // is locked
    }

    return bCanToggle;
}

function PerformSoundAction(eStateIOObejct eState)
{
    m_ObjectState = eState;

	switch (eState)
	{
		case SIO_Start:
            if (bShowLog) log("****** PerformSoundAction SIO_Start");
			PlaySound(m_StartSnd, SLOT_SFX);
			break;
		case SIO_Interrupt:
            if (bShowLog) log("****** PerformSoundAction SIO_Interrupt");
			PlaySound(m_InterruptedSnd, SLOT_SFX);
			break;
		case SIO_Complete:
            if (bShowLog) log("****** PerformSoundAction SIO_Complete");
			PlaySound(m_CompletedSnd, SLOT_SFX);
			break;
	}
}

defaultproperties
{
     m_eAnimToPlay=BA_Keypad
     m_bToggleType=True
     m_fGainTimeWithElectronicsKit=2.000000
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_StaticMesh
     bUseCylinderCollision=True
     bDirectional=True
     CollisionRadius=32.000000
     CollisionHeight=55.000000
     m_fCircumstantialActionRange=105.000000
     NetPriority=2.700000
     StaticMesh=StaticMesh'R6ActionObjects.MpBomb.MpBomb'
}
