//=============================================================================
//  R6IORotatingDoor : This should allow action moves on the door
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/10 * Created by Alexandre Dionne
//    2001/11/26 * Merged with interactive objects - Jean-Francois Dube
//  Note: if you make R6IORotatingDoor native then you will need to take care so
//  that the names in eDoorCircumstantialAction do not conflict with other enums
//=============================================================================

class R6IORotatingDoor extends R6IActionObject
	native
	placeable;

// R6CIRCUMSTANTIALACTION
#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning
// R6CIRCUMSTANTIALACTION

var()       R6Door      m_DoorActorA;   
var()       R6Door      m_DoorActorB;

var  array<R6AbstractBullet> m_BreachAttached;      // breach attached to the door (if any)

var()       BOOL        m_bTreatDoorAsWindow;       // should be set to true for shudders and windows that behave like doors.
var()		FLOAT		m_fWindowWidth;				// this field is only used when m_bTreatDoorAsWindow==true
var(Debug)  BOOL		bShowLog;
var			BOOL		m_bInProcessOfClosing;
var			BOOL		m_bInProcessOfOpening;
var			BOOL		m_bUseWheel;

var()		BOOL		m_bForceNoFormation;		// force ROOM_None (no formation/single file) on either side of door

var (R6Damage)  INT     m_iLockHP;                  // lock HP to open door with bullets or explosions.
var             INT     m_iCurrentLockHP;           // Current Lock Hit Points

enum eDoorCircumstantialAction
{
    CA_None,
        
    // Closed door
    CA_Open,
    CA_OpenAndClear,
    CA_OpenAndGrenade,
    CA_OpenGrenadeAndClear,

    // Open door
    CA_Close,
    CA_Clear,
    CA_Grenade,
    CA_GrenadeAndClear,
	
	// Grenade
	CA_GrenadeFrag,
	CA_GrenadeGas,
	CA_GrenadeFlash,
	CA_GrenadeSmoke,

    // Locked door
    CA_Unlock,

    // Use only for the sound
    CA_Lock,
    CA_LockPickStop
};

//-----------------------------------------------------------------------------
// Audio.
var(R6DoorSounds) sound      m_OpeningSound;		    // When start opening.
var(R6DoorSounds) sound      m_OpeningWheelSound;	    // When start opening with the wheel.
var(R6DoorSounds) sound      m_ClosingSound;		    // When start closing.
var(R6DoorSounds) sound      m_ClosingWheelSound;		// When start closing with the wheel.
var(R6DoorSounds) sound      m_LockSound;	            // Try to open when the door is lock.
var(R6DoorSounds) sound      m_UnlockSound;	            // When the door is unlock stat the sound.
var(R6DoorSounds) sound      m_MoveAmbientSound;	    // Optional ambient sound when moving.
var(R6DoorSounds) sound      m_MoveAmbientSoundStop;	// Stop optional ambient sound closing door.
var(R6DoorSounds) sound      m_LockPickSound;	        // Use lock pick when the door is lock
var(R6DoorSounds) sound      m_LockPickSoundStop;	    // Stop unlocking the door.
var(R6DoorSounds) sound      m_ExplosionSound;			// Explosion sound.

//-----------------------------------------------------------------------------
// Editables.
var(R6DoorProperties) BOOL	m_bIsOpeningClockWise;	//Is the door opening Clockwise
var(R6DoorProperties) INT   m_iMaxOpeningDeg;	    //Determine how many degrees the door can open (In degrees)
var(R6DoorProperties) BOOL  m_bIsDoorLocked;	    //Is the door Locked
var                   BOOL sm_bIsDoorLocked;
var(R6DoorProperties) INT	m_iInitialOpeningDeg;	//Opening of the door at level creation (In degrees)
var(R6DoorProperties) FLOAT m_fUnlockBaseTime;      // Base time required for opening the door, will be affected by skills

//-----------------------------------------------------------------------------
// Internal
var INT		m_iYawInit;				//Start Yaw point of the door when it's closed
var INT		m_iYawMax;				//End Yaw point of the door when it's fully opened
var vector	m_vNormal;				//The normal at the begining of the action
var vector  m_vCenterOfDoor;        //Center of the door (Location is the pivot point)
var vector	m_vDoorADir2D;          //The direction toward DoorA (direction toward DoorB is -m_vDoorADir2D
var BOOL    m_bIsDoorClosed;        //Is the door open or not
var INT     m_iMaxOpening;          //Determine how many degrees the door can open (In degrees)
var INT     m_iInitialOpening;      //Opening of the door at level creation (In degrees)
var	INT		m_iCurrentOpening;

native(1511) final function bool WillOpenOnTouch( R6Pawn r6pawn );
native(2018) final function AddBreach(R6AbstractBullet BreachAttached);
native(2019) final function RemoveBreach(R6AbstractBullet BreachAttached);

replication
{
    // function client asks server to do
    unreliable if (bNetInitial && (Role == ROLE_Authority))
        m_iInitialOpeningDeg, m_bIsDoorLocked, m_iMaxOpeningDeg, m_bIsOpeningClockWise, 
        m_DoorActorA,m_DoorActorB;
    unreliable if (Role == ROLE_Authority)
        m_bIsDoorClosed, m_bInProcessOfClosing, m_bInProcessOfOpening, m_iYawMax, m_iYawInit, m_iMaxOpening, m_iInitialOpening;
}

//------------------------------------------------------------------
// SaveOriginalData
//	
//------------------------------------------------------------------
simulated function SaveOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( true );
    Super.SaveOriginalData();

    sm_bIsDoorLocked    = m_bIsDoorLocked;
    sm_rotation         = rotation;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	local rotator rNewRotation;
    local rotator rTempRotation;
    local bool bCA;
    local bool bBA;
    local bool bBP;

    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    m_bBulletGoThrough   = false;
    m_bHidePortal        = true;
    m_bUseWheel          = false;
    m_bIsDoorLocked      = sm_bIsDoorLocked;
    
    m_fPlayerCAStartTime = 0;
    SetDoorProcessStates(false, false);
    m_iCurrentLockHP     = m_iLockHP;

    //Initialization of the door parameters	
	m_iInitialOpening = m_iInitialOpeningDeg * 65536 / 360;
	m_iMaxOpening = m_iMaxOpeningDeg * 65536 / 360;

	m_iMaxOpening = Clamp(m_iMaxOpening,0,65535);
	m_iInitialOpening = Clamp(m_iInitialOpening,0,m_iMaxOpening);

    // Set initial rotation
	rTempRotation = sm_Rotation;
	rTempRotation.Yaw = sm_Rotation.Yaw & 65535;
    bCA = bCollideActors;
    bBA = bBlockActors;
    bBP = bBlockPlayers;
    SetCollision( false, false, false );
	SetRotation(rTempRotation);
    SetCollision( bCA, bBA, bBP );

    DesiredRotation      = rTempRotation;
    bRotateToDesired     = false;

	// Get the initial position of door
	#ifdefDEBUG if(bShowLog) log(self$" ResetOriginalData: Rotation.Yaw="$Rotation.Yaw); #endif
	
	m_iYawInit = Rotation.Yaw; 

    // Center of door
	rNewRotation.Yaw = m_iYawInit;
    m_vCenterOfDoor = Location - 64*vector(rNewRotation);

	//Determine the Normal of the door
	m_vNormal = vector(rNewRotation) cross vect(0,0,1);

    // DoorA direction
    if(m_DoorActorA != none)
		m_vDoorADir2D = m_DoorActorA.Location - m_vCenterOfDoor;
    m_vDoorADir2D.Z = 0;
    m_vDoorADir2D = Normal(m_vDoorADir2D);

	rNewRotation = Rotation;

	//Determine rotation bounderies and Initial opening of the door
	if(m_bIsOpeningClockWise)
	{
		m_iYawMax = m_iYawInit + m_iMaxOpening;		
		rNewRotation.Yaw = (Rotation.Yaw ) + Clamp(m_iInitialOpening,0,m_iMaxOpening);	
	}		
	else
	{
		m_iYawMax = m_iYawInit - m_iMaxOpening;		
		rNewRotation.Yaw = (Rotation.Yaw ) - Clamp(m_iInitialOpening,0,m_iMaxOpening);
	}
	m_iYawMax = m_iYawMax & 65535;

	#ifdefDEBUG if(bShowLog) log(self$" m_iYawInit="$m_iYawInit$" m_iYawMax="$m_iYawMax$" m_iMaxOpening="$m_iMaxOpening);    #endif
	#ifdefDEBUG if(bShowLog) log(self$" rNewRotation="$rNewRotation$" m_iInitialOpening="$m_iInitialOpening);  #endif
    desiredRotation = rNewRotation;

    // door is partially opened
	if(rNewRotation.Yaw != m_iYawInit)
	{        
        m_bUseWheel = true;
		SetDoorState(false);
        m_bHidePortal = m_bIsDoorClosed;
		// rbrek 4 feb 2003
		// set the door's rotation to its desired initial opening (rather than wait for server to replicate the rotation)
		// on slow connections (MODEM) a door that is initially set to open appears closed on the client, whereas it is open on the server
		if(Level.NetMode == NM_Client)
			SetRotation(rNewRotation);
        ClientSetDoor(rNewRotation, true);
	}
    else
        SetDoorState(true);
    
    m_BreachAttached.Remove( 0, m_BreachAttached.Length );
}

#ifdefDEBUG
//------------------------------------------------------------------
// dbgLogActor
//	
//------------------------------------------------------------------
simulated function dbgLogActor( bool bVerbose )
{
    Super.dbgLogActor( bVerbose );

    log("Name= " $name );
    log("  m_bHidePortal    = " $m_bHidePortal );
    log("  m_bUseWheel      = " $m_bUseWheel );
    log("  m_bIsDoorClosed  = " $m_bIsDoorClosed );
    log("  m_bIsDoorLocked  = " $m_bIsDoorLocked );
    log("  sm_rotation      = " $sm_rotation );
    log("  desiredRotation  = " $desiredRotation );
    log("  bRotateToDesired = " $bRotateToDesired );
    log("  m_fPlayerCAStartTime= " $m_fPlayerCAStartTime );
	log("  m_bInProcessOfClosing= " $m_bInProcessOfClosing );
	log("  m_bInProcessOfOpening= " $m_bInProcessOfOpening );
    log("  m_iCurrentLockHP = " $m_iCurrentLockHP );
    log("  m_iInitialOpeningDeg= " $m_iInitialOpeningDeg );
	log("  m_iInitialOpening= " $m_iInitialOpening );
    log("  m_iMaxOpeningDeg = " $m_iMaxOpeningDeg  );
	log("  m_iMaxOpening    = " $m_iMaxOpening  );
    log("  rotation.yaw     = " $rotation );
	log("  m_iYawInit       = " $m_iYawInit  );
	log("  m_vNormal        = " $m_vNormal  );
	log("  m_bIsOpeningClockWise= " $m_bIsOpeningClockWise );
	log("  m_iYawMax        = " $m_iYawMax  );
    log("  m_bUseWheel      = " $m_bUseWheel );
	log("  m_bIsDoorClosed  = " $m_bIsDoorClosed );
    log("  m_bHidePortal    = " $m_bHidePortal );
}
#endif

function PostBeginPlay()
{
    Super.PostBeginPlay();
    //This flag must be false on doors.  To shoot through door, it has to be done in the marerial properties.
    m_bBulletGoThrough = false;
}

//This function should always be defined in subclass
function bool startAction(FLOAT fDeltaMouse, Actor actionInstigator)
{	
	return true;		
}

function SetDoorProcessStates(bool bOpening, bool bClosing)
{
	m_bInProcessOfOpening = bOpening;
	m_bInProcessOfClosing = bClosing;

    if(bOpening || bClosing)
        Enable('Tick');
}

function bool updateAction(FLOAT fDeltaMouse, Actor actionInstigator)
{
	local rotator rNewRotation;
	local rotator rRotation;
    local FLOAT fDoorMouvement;
	local INT iMaxDoorMove;	
	local FLOAT fTempSide;
	local INT iNewOpening;

    SetDoorProcessStates(false, false);

    // if a fDeltaMouse is zero, do nothing...
    if(fDeltaMouse == 0.f)
        return false;

    RotationRate.Yaw = default.RotationRate.Yaw;

    if(!m_bIsOpeningClockWise)
        fDeltaMouse *= -1f;

    fDoorMouvement = fDeltaMouse;

	//Determine how much to open the door based on
	//the mouse movement scaled
	fDoorMouvement = fDoorMouvement * m_iMaxOpening / m_fMaxMouseMove;
	
	//Scale the door movement depending of it's mass
	if(Default.Mass != 0 && Mass != 0)
	{
		fDoorMouvement = fDoorMouvement * Default.Mass / Mass;
	}
	
	rNewRotation = rotation;
	rRotation = rotation;

	if(m_bIsOpeningClockWise)
	{
		iNewOpening = m_iCurrentOpening + fDoorMouvement;
		iNewOpening = Clamp(iNewOpening,0,m_iMaxOpening);	
		rNewRotation.Yaw = m_iYawInit + iNewOpening;	
	}
	else
	{
		iNewOpening = m_iCurrentOpening - fDoorMouvement;
		iNewOpening = Clamp(iNewOpening,0,m_iMaxOpening);	
		rNewRotation.Yaw = m_iYawInit - iNewOpening;
	}

    if ((!m_bUseWheel && (rRotation.yaw == m_iYawInit)) && (rNewRotation.Yaw != m_iYawInit))
    {
        if (m_OpeningWheelSound != none)
            PlaySound(m_OpeningWheelSound, SLOT_SFX);
        AmbientSound = m_MoveAmbientSound;
        AmbientSoundStop = m_MoveAmbientSoundStop;
        m_bUseWheel = true;
    }

    ClientSetDoor(rNewRotation);
	return true;		
}

simulated function R6CircumstantialActionCancel()
{
	performDoorAction(eDoorCircumstantialAction.CA_LockPickStop);
}

//==============================================================================//
// RBrek - 1 sept 2001                                                          //
// To perform a full opening/closing of a door.                                 //
// either stQuery.iTeamActionID or stQuery.iPlayerActionID should be passed...  //
// TODO : replace SetRotation with use of bRotateToDesired                      //
//==============================================================================//
function performDoorAction(INT iActionID)
{
    if(iActionID == eDoorCircumstantialAction.CA_Close)
    {
        closeDoor( none );
    }
    else if(iActionID == eDoorCircumstantialAction.CA_Open)
    {
        openDoor( none );
    }
    else if(iActionID == eDoorCircumstantialAction.CA_Unlock)
    {
        UnLockDoor();
        PlaySound(m_UnlockSound, SLOT_SFX);
    }
    else if(iActionID == eDoorCircumstantialAction.CA_Lock) 
    {
        PlaySound(m_LockSound, SLOT_SFX);
    }
    else if(iActionID == eDoorCircumstantialAction.CA_LockPickStop) 
    {
        PlaySound(m_LockPickSoundStop, SLOT_SFX);
    }
}

function ClientSetDoor(rotator rNewRotation, optional bool bForce)
{
    // the following condition would be the case for certain MP games (dedicated servers)
    if(bForce || desiredRotation != rNewRotation)
    {
        Enable('Tick');
        bRotateToDesired = true;
		desiredRotation = rNewRotation;
    }
}


simulated event bool EncroachingOn( actor Other )
{
	local R6Pawn P;
    local R6AIController ai;

    #ifdefDEBUG if(bShowLog) log(Other.name $ " encroach door " $ name ); #endif

	P = R6Pawn(other);
    
    if(P != none && P.IsAlive())
	{
		if(!P.m_bIsPlayer)
        {
            ai = R6AIController(P.Controller);
			ai.m_BumpedBy = self;
			ai.GotoBumpBackUpState(ai.GetStateName());
        }
		return true;
	}	
	return false;
}

function openDoor( Pawn opener, OPTIONAL INT iRotationRate )
{
    local rotator rNewRotation;

    if ( iRotationRate == 0 )
    {
        iRotationRate = default.RotationRate.Yaw;    
    }

    RotationRate.Yaw = iRotationRate;

    if ( opener != none )
    {
        Instigator = opener;
    }

    if ( Instigator != none )
        Instigator.R6MakeNoise( SNDTYPE_Door );
    
    #ifdefDEBUG if(bShowLog) log("opening door"); #endif

    rNewRotation = rotation;

    if( m_iYawInit < m_iYawMax )
    {
        if(rotation.yaw > m_iYawMax)    
            rNewRotation.yaw -= 65536; 
    }
    else
    {
        if(rotation.yaw > m_iYawInit)
            rNewRotation.yaw -= 65536;
    }

    if ((!m_bUseWheel) && (rNewRotation.Yaw == m_iYawInit))
    {
        if (m_OpeningSound != None)
        {
            PlaySound(m_OpeningSound, SLOT_SFX);
        } 
        AmbientSound = m_MoveAmbientSound;
        AmbientSoundStop = m_MoveAmbientSoundStop;
        m_bUseWheel = true;
    }
 
    rNewRotation.yaw = m_iYawMax;
    bRotateToDesired = true;
    desiredRotation = rNewRotation;
    SetDoorProcessStates(true, false);
    ClientSetDoor(rNewRotation);
}

simulated function closeDoor( r6pawn pawn , OPTIONAL INT iRotationRate)
{
    local rotator rNewRotation;
    if ( iRotationRate == 0 )
    {
        iRotationRate = default.RotationRate.Yaw;    
    }

    RotationRate.Yaw = iRotationRate;

    if ( pawn != none  )
        Instigator = pawn;

    if ( Instigator != none )
        Instigator.R6MakeNoise( SNDTYPE_Door );
        
    #ifdefDEBUG if(bShowLog) log("closing door"); #endif
    rNewRotation = rotation;
    rNewRotation.yaw = m_iYawInit;
    bRotateToDesired = true;
    desiredRotation = rNewRotation;
    SetDoorProcessStates(false, true);
    ClientSetDoor(rNewRotation);
}

function bool DoorOpenTowardsActor(actor aActor)
{   
    // what side is this pawn on...?
    if(vector(aActor.Rotation) dot m_vNormal > 0)
    {
        // clockwise opens away....
        if(m_bIsOpeningClockWise)
            return false;
        else 
            return true;
    }
    else
    {
        // counterclockwise opens away...
        if(m_bIsOpeningClockWise)
            return true;
        else
            return false;
    }
}

function INT R6TakeDamage(INT iKillValue, INT iStunValue, Pawn instigatedBy, vector vHitLocation, 
                           vector vMomentum, INT iPenetrationFactor, optional int iBulletGroup)
{
    local FLOAT fPercentage;
    local FLOAT fBulletDamMultiplier;
    local INT i;

    if((Level.NetMode == NM_Standalone) || (Role == ROLE_Authority))
    {
        if(iBulletGroup == -1)// a door was hit by a bullet
        {
            if( m_iHitPoints < 2500 )
            {
                fBulletDamMultiplier = 0.05 * iPenetrationFactor;
            }
            else
            {
                fBulletDamMultiplier = 0.005 * iPenetrationFactor;
            }
            //log("Door Hit By bullet HP : "$m_iHitPoints$" Mult "$fBulletDamMultiplier);
            
            if((m_iCurrentLockHP != 0) && HitLock(vHitLocation))
            {
                m_iCurrentLockHP = max(m_iCurrentLockHP - max(iKillValue * fBulletDamMultiplier * 10, 400), 0);

                //log("Lock "$m_iCurrentLockHP);
                if((m_iYawInit != Rotation.Yaw) || (m_iCurrentLockHP == 0))
                {
                    UnLockDoor();
                    OpenDoorWhenHit(vHitLocation, vMomentum, 2048 * iPenetrationFactor, false);
                }
            }
            else //door without lock or lock is destroyed
            {
                m_iCurrentHitPoints = max(m_iCurrentHitPoints - (iKillValue * fBulletDamMultiplier), 0);
                // open the door.
                //log("Door "$m_iCurrentHitPoints$" Init: "$m_iYawInit$" Yaw: "$Rotation.Yaw$" Lock: "$m_iCurrentLockHP);
                if((m_iYawInit != Rotation.Yaw) || (m_iCurrentLockHP == 0))
                { 
                    OpenDoorWhenHit(vHitLocation,vMomentum, 2048 * iPenetrationFactor, false);
                }
            }
        }
        else
        {
            #ifdefDEBUG if (bShowLog) log("m_iCurrentHitPoints = "$m_iCurrentHitPoints$" Damage: " $ iKillValue); #endif
            m_iCurrentHitPoints = max(m_iCurrentHitPoints - iKillValue, 0);
            m_iCurrentLockHP = max(m_iCurrentLockHP - iKillValue, 0);

            //If door is not destroyed and lock is then open the door
            //if door had no hitpoints(undestructible) open it
            if(m_iCurrentLockHP == 0)
            {
                UnLockDoor();
                //log("Explosion "$vHitLocation$" Momentum "$vMomentum);
                OpenDoorWhenHit(vHitLocation, vMomentum, 0, true);
            }
        }
       
        // Compute the percentage
        fPercentage = m_iCurrentHitPoints * 100 / m_iHitPoints;  
        
        #ifdefDEBUG if (bShowLog) log("New Hit Point = " $ m_iCurrentHitPoints $" Percentage: " $ fPercentage $" Lock HP : "$m_iCurrentLockHP$" : "$iKillValue$" : "$fBulletDamMultiplier*iKillValue); #endif
        SetNewDamageState(fPercentage);
        
        if( m_bBroken )
        {
			// Play sound explosion
            PlaySound(m_ExplosionSound, SLOT_SFX);

			// Notify the game that the interactive object was destroyed
            R6AbstractGameInfo(Level.Game).IObjectDestroyed(instigatedBy, Self);

            // Make noise for AI
            Instigator = instigatedBy;
            R6MakeNoise2( m_fAIBreakNoiseRadius, NOISE_Threat, PAWN_All );

            while(m_BreachAttached.Length != 0)
            {
                if(m_BreachAttached[0] == none)
                    m_BreachAttached.Remove( 0, 1 );
                else
                    m_BreachAttached[0].DoorExploded();
            }
        }
    }
    
    return m_iCurrentHitPoints;
}

function BOOL HitLock(vector vHitVector)
{
    local vector  vTemp2;
    local vector  vTemp3;

    //Check only if the height is ok
    vTemp2 = vHitVector;
    vTemp3 = Location;

    // lock is located 8 cm under the door center.
    if((vTemp2.Z - vTemp3.Z > -8 ) || (vTemp2.Z - vTemp3.Z < -24 ))
        return false;

    vTemp2.Z = 0;
    vTemp3.Z = 0;

    //Not on the side of the door, it's not opening. 
    if(VSize(vTemp2 - vTemp3) < 112)
        return false;
    
    return true;
}

function OpenDoorWhenHit(vector vHitLocation, vector vBulletDirection, INT YawVariation, BOOL bExplosion)
{
    local rotator rBulletAsRotator;
    local vector  vTemp2;
    local vector  vTemp3;
    local INT     iYawDifference;
    local BOOL    bShootTurnCCW;

    //First, check if the door can be open if hit from this point.
    vTemp2 = vHitLocation;
    vTemp2.Z = 0;
    vTemp3 = Location;
    vTemp3.Z = 0;

    //Not on the side of the door, it's not opening.
    if((VSize(vTemp2 - vTemp3) < 96) && !bExplosion)
        return;

    rBulletAsRotator = Rotator(vBulletDirection);
    if(rBulletAsRotator.Yaw < 0)
        rBulletAsRotator.Yaw += 65536;

    iYawDifference = rBulletAsRotator.Yaw - Rotation.Yaw;
    if(iYawDifference < 0)
        iYawDifference += 65536;

    //Bullet makes the door turn Counter Clockwise
    if(iYawDifference < 32768)
    {
        YawVariation = -YawVariation;
        bShootTurnCCW=true;
    }

    desiredRotation.yaw += YawVariation;
    rotationRate.Yaw = 65000;

    if(bExplosion == false)
    {
        #ifdefDEBUG if(bShowLog) log("CW : "$m_bIsOpeningClockWise$" Shoot="$bShootTurnCCW$" Door.Yaw="$Rotation.Yaw$" YInit="$m_iYawInit$" YMax="$m_iYawMax$" YVar="$YawVariation$" DesY="$desiredRotation.yaw); #endif
        if(m_bIsOpeningClockWise)
        {
            if(m_bInProcessOfClosing == true)
            {
                if(bShootTurnCCW == false)//open the door
                {
                    SetDoorProcessStates(m_bInProcessOfOpening, false);
                    desiredRotation.yaw = Rotation.Yaw;
                }
            }
            else if(m_bInProcessOfOpening == true)
            {
                if(bShootTurnCCW == true)//close the door
                {
                    //stop the door from closing
                    SetDoorProcessStates(false, false);
                    desiredRotation.yaw = Rotation.Yaw;
                }
            }


            //If we're not shooting a closed or open door 
            if(!(((bShootTurnCCW == true) && (m_iYawInit == Rotation.Yaw)) || 
                 ((bShootTurnCCW == false) && (m_iYawMax == Rotation.Yaw))))
            {
                if(m_iYawInit > m_iYawMax)
                {
                    if((desiredRotation.yaw > m_iYawMax) && (desiredRotation.yaw < m_iYawInit))
                    {
                        //door open CW, and moving CW
                        if(YawVariation > 0)
                            desiredRotation.yaw = m_iYawMax;
                        else
                            desiredRotation.yaw = m_iYawInit;
                    }
                }
                else
                {
                    if(desiredRotation.yaw > m_iYawMax)
                    {
                        desiredRotation.yaw = m_iYawMax;
                    }
                    else if (desiredRotation.yaw < m_iYawInit)
                    {
                        desiredRotation.yaw = m_iYawInit;
                    }
                }
            }
            else
            {
                //Do not change the desired rotation
                if(bShootTurnCCW == true)
                    desiredRotation.yaw = m_iYawInit;
                else
                    desiredRotation.yaw = m_iYawMax;
            }
        }
        else
        {
            if(m_bInProcessOfClosing == true)
            {
                if(bShootTurnCCW == true)//open the door
                {
                    SetDoorProcessStates(m_bInProcessOfOpening, false);
                    desiredRotation.yaw = Rotation.Yaw;
                }
            }
            else if(m_bInProcessOfOpening == true)
            {
                if(bShootTurnCCW == false)//close the door
                {
                    //stop the door from closing
                    SetDoorProcessStates(false, false);
                    desiredRotation.yaw = Rotation.Yaw;
                }
            }

            if(!(((bShootTurnCCW == false) && (m_iYawInit == Rotation.Yaw)) || 
                 ((bShootTurnCCW == true) && (m_iYawMax == Rotation.Yaw))))
            {
                if(m_iYawInit < m_iYawMax)
                {
                    //Ajust the value between 0 and 65536
                    if(desiredRotation.yaw > 65536)
                        desiredRotation.yaw -= 65536;

                    if((desiredRotation.yaw < m_iYawMax) && (desiredRotation.yaw > m_iYawInit))
                    {
                        //door open CW, and moving CW
                        if(YawVariation < 0)
                            desiredRotation.yaw = m_iYawMax;
                        else
                            desiredRotation.yaw = m_iYawInit;
                    }
                }
                else
                {
                    if(desiredRotation.yaw < m_iYawMax) 
                    {
                        desiredRotation.yaw = m_iYawMax;
                    }
                    else if (desiredRotation.yaw > m_iYawInit)
                    {
                        desiredRotation.yaw = m_iYawInit;
                    }
                }
            }
            else
            {
                //Do not change the desired rotation
                if(bShootTurnCCW == false)
                    desiredRotation.yaw = m_iYawInit;
                else
                    desiredRotation.yaw = m_iYawMax;
            }
        }
    }
    else
    {
        //Explosion cancel all opening or closing.
        SetDoorProcessStates(false, false);
        if(Rotation.Yaw == m_iYawInit)
        {
            if((m_bIsOpeningClockWise && (iYawDifference > 32768)) ||
               (!m_bIsOpeningClockWise && (iYawDifference < 32768)))
            {
                openDoor( none, 65000 );
            }
            else
            {
                if(m_bIsOpeningClockWise)
                {
                    if(m_iYawInit > m_iYawMax)
                       desiredRotation.yaw = ((m_iYawMax + m_iYawInit) / 2) + 32768;
                    else
                       desiredRotation.yaw = (m_iYawMax + m_iYawInit) / 2;
                }
                else
                {
                    if(m_iYawInit < m_iYawMax)
                        desiredRotation.yaw = ((m_iYawMax + m_iYawInit) / 2) + 32768;
                    else
                        desiredRotation.yaw = (m_iYawMax + m_iYawInit) / 2;
                }
            }
        }
        else if(Rotation.Yaw == m_iYawMax)
        {
            if((m_bIsOpeningClockWise && (iYawDifference < 32768)) ||
               (!m_bIsOpeningClockWise && (iYawDifference > 32768)))
            {
                closeDoor( none, 65000 );
            }
            else
            {
                if(!m_bIsOpeningClockWise)
                {
                    if(m_iYawInit < m_iYawMax)
                       desiredRotation.yaw = ((m_iYawMax + m_iYawInit) / 2) + 32768;
                    else
                       desiredRotation.yaw = (m_iYawMax + m_iYawInit) / 2;
                }
                else
                {
                    if(m_iYawInit > m_iYawMax)
                        desiredRotation.yaw = ((m_iYawMax + m_iYawInit) / 2) + 32768;
                    else
                        desiredRotation.yaw = (m_iYawMax + m_iYawInit) / 2;
                }
            }
        }
        else
        {
            if((m_bIsOpeningClockWise && (iYawDifference < 32768)) ||
               (!m_bIsOpeningClockWise && (iYawDifference > 32768)))
            {
                closeDoor( none , 65000);
            }
            else
            {
                openDoor( none , 65000);
            }
        }
    }

    bRotateToDesired=true;
    Enable('Tick');

    if(desiredRotation.yaw > 65536) 
        desiredRotation.yaw -= 65536;
    else if(desiredRotation.yaw < 0) 
        desiredRotation.yaw += 65536;

    if ((Rotation.yaw == m_iYawInit) && (desiredRotation.yaw != m_iYawInit))
    {
        if (m_OpeningWheelSound != none)
            PlaySound(m_OpeningWheelSound, SLOT_SFX);
        AmbientSound = m_MoveAmbientSound;
        AmbientSoundStop = m_MoveAmbientSoundStop;
        m_bUseWheel = true;
    }

}

simulated event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    local BOOL		bDisplayOpenIcon;
	local vector	vDistance;
	local BOOL		bOpensTowardsPawn;

    Query.iHasAction = 1;

	// recalculate distance from player to door (want to use the center of the door, not the hinge, and not the location we are looking at)
	if(m_bIsDoorClosed) // open < 90 degrees
	{
		vDistance = m_vVisibleCenter - playerController.pawn.location;
		vDistance.z = 0.f;
		fDistance = VSize(vDistance);
	}
	
    // In range ?
    if( fDistance < m_fCircumstantialActionRange )           // ? Do they all have the same action range ?
    {
        Query.iInRange = 1;
    }
    else
    {
        Query.iInRange = 0;
    }

    // rbrek 28 feb 2002
	// this was added so that while a door is moving, the player has the icon to reverse the action
	// so if a player is caught behind a door that is blocked on them, they can push the door away.
	if(m_bInProcessOfClosing)
		bDisplayOpenIcon = true;
	else if(m_bInProcessOfOpening)
		bDisplayOpenIcon = false;
	else if(m_bIsDoorClosed)
		bDisplayOpenIcon = true;
	else
		bDisplayOpenIcon = false;
    
    // Set the icon and actions     
    if(!bDisplayOpenIcon)
	{
		if(m_bTreatDoorAsWindow)
			Query.textureIcon = Texture'R6ActionIcons.CloseWindow';                
		else
			Query.textureIcon = Texture'R6ActionIcons.CloseDoor';                
        Query.iPlayerActionID      = eDoorCircumstantialAction.CA_Close;
    }
    else
    {
        Query.bCanBeInterrupted = m_bIsDoorLocked;
		if(R6Rainbow(playerController.pawn).m_bHasLockPickKit)
			Query.fPlayerActionTimeRequired = m_fUnlockBaseTime / 2.0;
        else
			Query.fPlayerActionTimeRequired = m_fUnlockBaseTime;

		if( m_bIsDoorLocked )
		{
			Query.textureIcon = Texture'R6ActionIcons.UnlockDoor';	
			Query.iPlayerActionID      = eDoorCircumstantialAction.CA_Unlock;			
		}
        else
        {
			// select the appropriate icon
			bOpensTowardsPawn = DoorOpenTowardsActor(playerController.pawn);
			if(bOpensTowardsPawn)
			{
				if(m_bIsOpeningClockWise)
				{
					if(m_bTreatDoorAsWindow)
						Query.textureIcon = Texture'R6ActionIcons.OpenWin_T_CW';
					else
						Query.textureIcon = Texture'R6ActionIcons.OpenDoor_T_CW';
				}					
				else
				{
					if(m_bTreatDoorAsWindow)
						Query.textureIcon = Texture'R6ActionIcons.OpenWin_T_CCW';
					else
						Query.textureIcon = Texture'R6ActionIcons.OpenDoor_T_CCW';
				}
			}
			else
			{
				if(m_bIsOpeningClockWise)
				{
					if(m_bTreatDoorAsWindow)
						Query.textureIcon = Texture'R6ActionIcons.OpenWin_A_CW';
					else
						Query.textureIcon = Texture'R6ActionIcons.OpenDoor_A_CW';
				}
				else
				{
					if(m_bTreatDoorAsWindow)
						Query.textureIcon = Texture'R6ActionIcons.OpenWin_A_CCW';
					else
						Query.textureIcon = Texture'R6ActionIcons.OpenDoor_A_CCW';
				}
			} 
            Query.iPlayerActionID      = eDoorCircumstantialAction.CA_Open;
        }
    }

	if(m_bIsDoorClosed)
	{
        Query.iTeamActionID        = eDoorCircumstantialAction.CA_Open;
        Query.iTeamActionIDList[0] = eDoorCircumstantialAction.CA_Open;

		if(!m_bTreatDoorAsWindow)
        {
			Query.iTeamActionIDList[1] = eDoorCircumstantialAction.CA_OpenAndClear;
			Query.iTeamActionIDList[2] = eDoorCircumstantialAction.CA_OpenAndGrenade;
			Query.iTeamActionIDList[3] = eDoorCircumstantialAction.CA_OpenGrenadeAndClear;

			R6FillSubAction( Query, 0, eDoorCircumstantialAction.CA_None );
			R6FillSubAction( Query, 1, eDoorCircumstantialAction.CA_None );
			R6FillGrenadeSubAction( Query, 2, playerController );
			R6FillGrenadeSubAction( Query, 3, playerController );
		}
		else
		{
			Query.iTeamActionIDList[1] = eDoorCircumstantialAction.CA_None;
			Query.iTeamActionIDList[2] = eDoorCircumstantialAction.CA_None;
			Query.iTeamActionIDList[3] = eDoorCircumstantialAction.CA_None;
		}		
	}
	else
    {
		Query.iTeamActionID        = eDoorCircumstantialAction.CA_Close;        
        Query.iTeamActionIDList[0] = eDoorCircumstantialAction.CA_Close;
		
		if(!m_bTreatDoorAsWindow)
        {
			Query.iTeamActionIDList[1] = eDoorCircumstantialAction.CA_Clear;
			Query.iTeamActionIDList[2] = eDoorCircumstantialAction.CA_Grenade;
			Query.iTeamActionIDList[3] = eDoorCircumstantialAction.CA_GrenadeAndClear;

			R6FillSubAction( Query, 0, eDoorCircumstantialAction.CA_None );
			R6FillSubAction( Query, 1, eDoorCircumstantialAction.CA_None );
			R6FillGrenadeSubAction( Query, 2, playerController );
			R6FillGrenadeSubAction( Query, 3, playerController );
		}
		else
		{
			Query.iTeamActionIDList[1] = eDoorCircumstantialAction.CA_None;
			Query.iTeamActionIDList[2] = eDoorCircumstantialAction.CA_None;
			Query.iTeamActionIDList[3] = eDoorCircumstantialAction.CA_None;
		}
	}

	#ifdefDEBUG if(bShowLog) log(self$" m_bHidePortal="$m_bHidePortal$" rotation.yaw="$rotation.yaw$" m_iYawInit="$m_iYawInit$" m_iYawMax="$m_iYawMax);	 #endif
}    

function R6FillGrenadeSubAction( Out R6AbstractCircumstantialActionQuery Query, INT iSubMenu, PlayerController playerController )
{
    local INT i;
    local INT j;

    if (R6ActionCanBeExecuted(eDoorCircumstantialAction.CA_GrenadeFrag, playerController))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eDoorCircumstantialAction.CA_GrenadeFrag;
        i++;
    }

    if (R6ActionCanBeExecuted(eDoorCircumstantialAction.CA_GrenadeGas, playerController))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eDoorCircumstantialAction.CA_GrenadeGas;
        i++;
    }

    if (R6ActionCanBeExecuted(eDoorCircumstantialAction.CA_GrenadeFlash, playerController))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eDoorCircumstantialAction.CA_GrenadeFlash;
        i++;
    }

    if (R6ActionCanBeExecuted(eDoorCircumstantialAction.CA_GrenadeSmoke, playerController))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eDoorCircumstantialAction.CA_GrenadeSmoke;
		i++;
    }

    for(j = i ; j < 4; j++)
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + j] = eDoorCircumstantialAction.CA_None;
    }
}

//------------------------------------------------------------------
// SetBroken
//	
//------------------------------------------------------------------
function SetBroken()
{
    Super.SetBroken();
    
	SetDoorState(false);
	m_bHidePortal = false;
}

function bool ShouldBeBreached()
{
	if(m_bBroken)
		return false;

	if(m_bTreatDoorAsWindow)
		return false;
	
	// if door is not COMPLETELY closed, do not try to breach
	if(!m_bIsDoorClosed || (m_iCurrentOpening != 0))
		return false;

	return true;
}

event EndedRotation()
{
    bRotateToDesired = false;
}

event Tick(FLOAT FDelta)
{
	local INT   rDesYaw;

	if(m_bBroken)
	{
		Disable('Tick');
		return;
	}
	
	if(!m_bInProcessOfOpening && !m_bInProcessOfClosing && !bRotateToDesired)
		Disable('Tick');
	
    rDesYaw = desiredRotation.yaw;
	if(rDesYaw < 0)
		rDesYaw += 65536;
	else if(rDesYaw > 65536)
		rDesYaw -= 65536;

	if(rotation.yaw == rDesYaw)
	{
        if(m_bInProcessOfClosing || m_bInProcessOfOpening)
		{
            if (m_bInProcessOfClosing)
            {
                if (m_ClosingSound != None)
                {
                    PlaySound(m_ClosingSound, SLOT_SFX);
                }
                AmbientSound = none;
                m_bUseWheel = false;
            }
            SetDoorProcessStates(false, false);
		}

        if (( m_bUseWheel) && (desiredRotation.yaw == m_iYawInit))
        {
            if (m_ClosingWheelSound != none)
                PlaySound(m_ClosingWheelSound, SLOT_SFX);
            
            AmbientSound = none;
            m_bUseWheel = false;
        }
	}

	// rbrek 8 may 2002
    // when we allow the physics to take care of the rotation of the door (using bRotateToDesired)
    // the physics will set the yaw between 0 and 65535...
    // if opened more than 80%, consider the door open
	if(m_bIsOpeningClockWise)
		m_iCurrentOpening = (rotation.yaw - m_iYawInit) & 65535;
	else
		m_iCurrentOpening = (m_iYawInit - rotation.yaw) & 65535;		
	SetDoorState(m_iCurrentOpening < 16384);
    
	if(!m_bTreatDoorAsWindow)
        m_vVisibleCenter = Location - 64*vector(rotation);  
    else
        m_vVisibleCenter = Location - m_fWindowWidth*0.5*vector(rotation);  

    // set m_bHidePortal to true only when door is completely closed 
	m_bHidePortal = (m_iCurrentOpening == 0); 	
}

simulated function UnLockDoor()
{
    if ( !m_bIsDoorLocked ) // we won't change the cost if the door is not locked
        return;

    m_bIsDoorLocked = false;
    m_DoorActorA.ExtraCost = m_DoorActorA.default.ExtraCost;
	m_DoorActorB.ExtraCost = m_DoorActorB.default.ExtraCost;
}

simulated function SetDoorState(bool bIsClosed )
{	
	m_bIsDoorClosed = bIsClosed;
	
	if(m_bTreatDoorAsWindow)
		return;

	if(m_bIsDoorClosed)
	{
		if(m_bIsDoorLocked)
		{
			m_DoorActorA.ExtraCost = 1000;
			m_DoorActorB.ExtraCost = 1000;
		}
		else
		{
			m_DoorActorA.ExtraCost = m_DoorActorA.default.ExtraCost;
			m_DoorActorB.ExtraCost = m_DoorActorB.default.ExtraCost;
		}
	}
	else
	{
		m_DoorActorA.ExtraCost = 0;
		m_DoorActorB.ExtraCost = 0;		
	}
}

//===========================================================================//
// R6GetCircumstantialActionString()                                         //
//===========================================================================//
simulated function string R6GetCircumstantialActionString( INT iAction )
{
    switch( iAction )
    {
		case eDoorCircumstantialAction.CA_Close:                return Localize("RDVOrder", "Order_Close", "R6Menu");
		case eDoorCircumstantialAction.CA_Clear:                return Localize("RDVOrder", "Order_Clear", "R6Menu");
		case eDoorCircumstantialAction.CA_Grenade:              return Localize("RDVOrder", "Order_Grenade", "R6Menu");
		case eDoorCircumstantialAction.CA_GrenadeAndClear:      return Localize("RDVOrder", "Order_GrenadeClear", "R6Menu");
		case eDoorCircumstantialAction.CA_Open:                 return Localize("RDVOrder", "Order_Open", "R6Menu");
		case eDoorCircumstantialAction.CA_OpenAndClear:         return Localize("RDVOrder", "Order_OpenClear", "R6Menu");
		case eDoorCircumstantialAction.CA_OpenAndGrenade:       return Localize("RDVOrder", "Order_OpenGrenade", "R6Menu");
		case eDoorCircumstantialAction.CA_OpenGrenadeAndClear:  return Localize("RDVOrder", "Order_OpenGrenadeClear", "R6Menu");
		case eDoorCircumstantialAction.CA_GrenadeFrag:			return Localize("RDVOrder", "Order_FragGrenade", "R6Menu");
		case eDoorCircumstantialAction.CA_GrenadeGas:			return Localize("RDVOrder", "Order_GasGrenade", "R6Menu");
		case eDoorCircumstantialAction.CA_GrenadeFlash:			return Localize("RDVOrder", "Order_FlashGrenade", "R6Menu");
		case eDoorCircumstantialAction.CA_GrenadeSmoke:			return Localize("RDVOrder", "Order_SmokeGrenade", "R6Menu");	
    }

    return "";
}


//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
function R6CircumstantialActionProgressStart( R6AbstractCircumstantialActionQuery Query )
{
    m_fPlayerCAStartTime = Level.TimeSeconds;

	PlayLockPickSound();
}

function PlayLockPickSound()
{
    PlaySound(m_LockPickSound, SLOT_SFX);
}

//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//   Update the door unlocking progress (if it's locked)                     //
//   Should be affected by the skills of the pawn unlocking it               //
//===========================================================================//
function INT  R6GetCircumstantialActionProgress( R6AbstractCircumstantialActionQuery Query, Pawn actingPawn )
{
    local FLOAT fPercentage;

    if( m_bIsDoorLocked ) 
		fPercentage = (Level.TimeSeconds - m_fPlayerCAStartTime) / (Query.fPlayerActionTimeRequired * (2.0 - R6Pawn(actingPawn).ArmorSkillEffect()));
	else
        fPercentage = 1.0f;
	
    return fPercentage*100;
}


//===========================================================================//
// R6ActionCanBeExecuted()												     //
//	Check if the action specified can be executed. Useful to disable choice  //
//	in the rose des vents.													 //
//===========================================================================//
simulated function BOOL R6ActionCanBeExecuted( INT iAction, PlayerController playerController )
{
    local R6PlayerController pPlayerCtrl;

    if (iAction == eDoorCircumstantialAction.CA_None)
        return false;

    pPlayerCtrl = R6PlayerController(playerController);
    if( pPlayerCtrl == none || pPlayerCtrl.m_TeamManager == none )
        return false;

    switch(iAction)
    {
    case eDoorCircumstantialAction.CA_GrenadeFrag:
            return pPlayerCtrl.m_TeamManager.HaveRainbowWithGrenadeType( GT_GrenadeFrag );
            break;
    case eDoorCircumstantialAction.CA_GrenadeGas:
            return pPlayerCtrl.m_TeamManager.HaveRainbowWithGrenadeType( GT_GrenadeGas );
            break;
    case eDoorCircumstantialAction.CA_GrenadeFlash:
            return pPlayerCtrl.m_TeamManager.HaveRainbowWithGrenadeType( GT_GrenadeFlash );
            break;
    case eDoorCircumstantialAction.CA_GrenadeSmoke:
            return pPlayerCtrl.m_TeamManager.HaveRainbowWithGrenadeType( GT_GrenadeSmoke );
            break;
    }
    
    return true;
}


//============================================================================
// Bump - 
//============================================================================
event Bump( Actor other )
{
	local R6Pawn    pawn;
    local vector    vDoorDir;
    local rotator   rPawnRot;
    local vector    vPawnDir;

	pawn = R6Pawn(other);

    if ( pawn == none )
        return;

    // npc and if door is partially open
    if ( WillOpenOnTouch(pawn) ) 
    {
        openDoor( pawn );
        return;
    }

}

//============================================================================
// bool ActorIsOnSideA - 
//============================================================================
function bool ActorIsOnSideA( Actor aActor )
{
    local vector vActorDir2D;

    vActorDir2D = aActor.Location - m_vCenterOfDoor;
    vActorDir2D.Z = 0;
    vActorDir2D = Normal( vActorDir2D );

    return ((vActorDir2D dot m_vDoorADir2D) > 0);
}

function vector GetTarget( Actor aActor, float fDistanceFromDoor, OPTIONAL bool bBackup )
{
    local vector vTarget;

    if ( bBackup )
        fDistanceFromDoor *= -1;

    vTarget = m_vCenterOfDoor;

    if (ActorIsOnSideA(aActor))
        vTarget -= fDistanceFromDoor * m_vDoorADir2D;
    else
        vTarget += fDistanceFromDoor * m_vDoorADir2D;

    vTarget.Z = aActor.Location.Z;

    return vTarget;
}

defaultproperties
{
     m_iLockHP=1000
     m_iMaxOpeningDeg=90
     m_fUnlockBaseTime=5.000000
     m_iHitPoints=2000
     Physics=PHYS_MovingBrush
     m_eDisplayFlag=DF_ShowOnlyIn3DView
     m_bUseR6Availability=False
     m_bSkipHitDetection=True
     m_bUseDifferentVisibleCollide=True
     m_bUseOriginalRotationInPlanning=True
     m_bSpriteShowFlatInPlanning=True
     m_bOutlinedInPlanning=False
     m_fCircumstantialActionRange=132.000000
     NetPriority=2.700000
     RotationRate=(Yaw=20000)
}
