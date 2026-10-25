//=============================================================================
//  R6GrenadeWeapon.uc : "Weapon" used for throwing grenades
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/07/09 * Created by Sebastien Lussier
//    2001/11/07 * taken over by Joel Tremblay
//=============================================================================
class R6GrenadeWeapon extends R6Gadget
	native
    abstract;

var r6pawn.eGrenadeThrow    m_eThrow;
var BOOL                    m_bCanThrowGrenade;
var BOOL                    m_bFistPersonAnimFinish;
var BOOL                    m_bPinToRemove;
var BOOL                    m_bReadyToThrow;

replication
{
    reliable if (Role==ROLE_Authority)
        ClientThrowGrenade;

    reliable if (Role < ROLE_Authority)
        ServerSetGrenade;

    unreliable if (Role < ROLE_Authority)
        ServerSetThrow, ServerImReadyToThrow;
}

simulated function PostBeginPlay()
{
    local R6RainbowAI localRainbowAI;
    Super.PostBeginPlay();

    #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::PostBeginPlay"); #endif
    //Get the grenade display
    if(m_pBulletClass != none)  //some gadgets might throw interactive objects, the Bullet class is none.
    {
        SetStaticMesh(m_pBulletClass.Default.StaticMesh);
    }
    if (Pawn(Owner)!=none)
    {
        if(Pawn(Owner).controller != none)
        {
            localRainbowAI = R6RainbowAI(Pawn(Owner).controller);
            if ((localRainbowAI!=none) && 
                (localRainbowAI.m_TeamManager != none))
            {
                localRainbowAI.m_TeamManager.UpdateTeamGrenadeStatus();
            }
        }
    }
}
 
function ServerImReadyToThrow(BOOL bReady)
{
    #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::ServerImReadyToThrow"); #endif
    m_bReadyToThrow=bReady;
}

simulated function DropGrenade()
{
    local R6Grenade aGrenade;
    local vector    vStart;

    #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::DropGrenade"); #endif
    //Get grenade start location.
	if(R6Pawn(owner).m_bIsPlayer)
		vStart = R6Pawn(Owner).GetGrenadeStartLocation(m_eThrow);
	else
		vStart = R6Pawn(Owner).GetHandLocation();
	
	aGrenade = R6Grenade( Spawn( m_pBulletClass, Self,, vStart ) );
	aGrenade.Instigator = Pawn(Owner);
    aGrenade.SetSpeed(0);
}

simulated function StartFalling()
{
    #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::StartFalling"); #endif
    //don't drop any grenandes on the ground if the character has none left.
    if(m_iNbBulletsInWeapon != 0)
    {
        //Drop a live ammo
        if(m_bReadyToThrow==true)
        {
            bHidden=true;
            if(Level.NetMode != NM_Client)
                DropGrenade();
        }
        else
        {
            super.StartFalling();
        }
    }
}

function FLOAT GetExplosionDelay()
{
    #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::GetExplosionDelay"); #endif
	if(m_pBulletClass == none)
		return 2.f;
	else
		return m_pBulletClass.Default.m_fExplosionDelay;
}

function Fire( FLOAT fValue )
{
   #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::Fire"); #endif
    GotoState('StandByToThrow');
}

function ServerSetThrow(Pawn.eGrenadeThrow eThrow)
{
   #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::ServerSetThrow"); #endif
	m_eThrow = eThrow;
}

// FiringSpeed is used in UW as the rate parameter in playanim.
state StandByToThrow
{
    function BeginState()
    {
		local R6PlayerController PController;

		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::StandByToThrow::BeginState"); #endif
        R6Pawn(Owner).m_bIsFiringState = FALSE;
        if (bShowLog) log("**** IN  STANDBY TO THROW *******");

		if (m_iNbBulletsInWeapon==0)
		{
			if (bShowLog) log("**** No more Grenades, Autoswitch to Primary Weapon *******");

			// Auto switch to primary weapon!
			PController = R6PlayerController(Pawn(Owner).controller);
			if (PController!=none)
			{
				if(R6Pawn(Owner).m_WeaponsCarried[0] != None)
				    PController.PrimaryWeapon();
				else
				    PController.SecondaryWeapon();
            }
		}
    }   

    function Fire( FLOAT fValue )
    {
		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::StandByToThrow::Fire"); #endif
    // The grenade doesn't do nothing by pressing the fire button.
    // do something in the HUD!
        if (bShowLog) log("StandByToThrow =" @ m_bCanThrowGrenade);
        if ((m_iNbBulletsInWeapon > 0) && m_bCanThrowGrenade)
        {
            if(R6PlayerController(Pawn(Owner).controller) != none)
            {
                Pawn(Owner).controller.m_bLockWeaponActions = true;
                if(R6Pawn(Owner).IsPeeking() && !R6Pawn(Owner).m_bIsProne )
                {
                    if(R6PlayerController(Pawn(Owner).controller).m_bPeekLeft == 1)
                        m_eThrow = GRENADE_PeekLeftThrow;
                    else
                        m_eThrow = GRENADE_PeekRightThrow;
                }
                else
                    m_eThrow = GRENADE_Throw;
            }
			ServerSetThrow(m_eThrow);
            GotoState('ReadyToThrow');
        }
    }

    function AltFire( FLOAT fValue )
    {
 		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::StandByToThrow::AltFire"); #endif
        // The grenade doesn't do nothing by pressing the fire button.
        // do something in the HUD!
        if ((m_iNbBulletsInWeapon > 0) && m_bCanThrowGrenade)
        {
            if(R6PlayerController(Pawn(Owner).controller) != none)
            {
                Pawn(Owner).controller.m_bLockWeaponActions = true;
                if(R6Pawn(Owner).IsPeeking() && !R6Pawn(Owner).m_bIsProne )
                {
                    if(R6PlayerController(Pawn(Owner).controller).m_bPeekLeft == 1)
                        m_eThrow = GRENADE_PeekLeft;
                    else
                        m_eThrow = GRENADE_PeekRight;
                }
                else
				    m_eThrow = GRENADE_Roll;
            }
			ServerSetThrow(m_eThrow);
			GotoState('ReadyToThrow');
        }
    }
    function FirstPersonAnimOver()
    {
		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::StandByToThrow::FirstPersonAnimOver"); #endif
        Pawn(Owner).controller.m_bLockWeaponActions = false;
    }
}

function ServerSetGrenade(Pawn.eGrenadeThrow eGrenade)
{
    local R6Pawn PawnOwner;
 	#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::ServerSetGrenade"); #endif

    PawnOwner = R6Pawn(Owner);

    PawnOwner.m_ePlayerIsUsingHands = HANDS_None;
	PawnOwner.m_eGrenadeThrow = eGrenade;
	PawnOwner.m_eRepGrenadeThrow = eGrenade;	
	PawnOwner.PlayWeaponAnimation();
   	if (bShowLog) log("ServerSetGrenade");
}


state ReadyToThrow
{
    function Fire( FLOAT fValue ) {}
    function AltFire( FLOAT fValue ) {}
    function StopFire(optional BOOL bSoundOnly) {}
	function StopAltFire() {}

    function BeginState()
    {
 		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::ReadyToThrow::BeginState"); #endif

        if (bShowLog) log("**** IN  READY TO THROW *******");
        R6Pawn(Owner).m_bIsFiringState = TRUE;
        m_bFistPersonAnimFinish=true;
        ServerImReadyToThrow(true);
        m_bReadyToThrow=true;
        m_PawnWaitAnimLow='StandGrenade_nt';
        m_PawnWaitAnimHigh='StandGrenade_nt';
        m_PawnWaitAnimProne='ProneGrenade_nt';

        if (R6Pawn(Owner).m_bIsPlayer)
        {
            if(R6PlayerController(Pawn(Owner).controller).bBehindView == FALSE)
            {
                if(m_FPHands != none)
                {
                    m_bFistPersonAnimFinish=false;
                    m_FPHands.GotoState('FiringWeapon');
                    if(bShowLog) log("Calling Fire SingleShot");
                    m_FPHands.FireSingleShot();
                }
            }
        }
        
        if (m_bPinToRemove)
            ServerSetGrenade(GRENADE_RemovePin);
    }
    function FirstPersonAnimOver()
    {
  		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::ReadyToThrow::FirstPersonAnimOver"); #endif
        m_bFistPersonAnimFinish=true;
        if(bShowLog)log("ReadyToThrow = FirstPersonAnimFinish");
    }

    simulated function Tick(FLOAT fDeltaTime)
    {
        local R6Pawn PawnOwner;

  		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::ReadyToThrow::Tick"); #endif
        PawnOwner = R6Pawn(Owner);

        if ((PawnOwner.Controller != none) && (PawnOwner.Controller.bFire == 0) && (PawnOwner.Controller.bAltFire == 0) && (PawnOwner.m_bWeaponTransition == FALSE) && m_bFistPersonAnimFinish) 
        {            
            m_bCanThrowGrenade = false;
            m_bFistPersonAnimFinish = false;
            
            if (bShowLog) log("!!!!!!!!!!!!!!! THROW GRENADE!!!!!!!!!!!!!!!");
            
            ServerSetGrenade(m_eThrow);

            if (PawnOwner.m_bIsPlayer)
            {
                if(R6PlayerController(PawnOwner.controller).bBehindView == FALSE)
                {
                    if(m_FPHands != none)
                    {
                        m_bFistPersonAnimFinish=false;
                        if ((m_eThrow == GRENADE_Throw) || (m_eThrow == GRENADE_PeekLeftThrow) || (m_eThrow == GRENADE_PeekRightThrow))
                            m_FPHands.FireGrenadeThrow();
                        else
                            m_FPHands.FireGrenadeRoll();
                    }
                }
            }
            GotoState('WaitEndOfThrow');
        }
    }
}

state WaitEndOfThrow
{
    function Fire( FLOAT fValue ) {}
    function AltFire( FLOAT fValue ) {}
	function StopFire(optional BOOL bSoundOnly) {}
	function StopAltFire() {}

    function FirstPersonAnimOver()
    {
  		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::WaitEndOfThrow::FirstPersonAnimOver"); #endif
        m_bFistPersonAnimFinish = true;
        if(bShowLog) log("ReadyToThrow = FirstPersonAnimFinish");
    }

    simulated function Tick(FLOAT fDeltaTime)
    {
   		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::WaitEndOfThrow::Tick"); #endif
        if (m_bFistPersonAnimFinish && m_bCanThrowGrenade)
        {
            ServerSetGrenade(GRENADE_None);

            if (bShowLog) log("ClientThrowGrenade()" @ m_iNbBulletsInWeapon);
            if (m_iNbBulletsInWeapon == 0)
            {
                SetStaticMesh(none);
                m_PawnWaitAnimLow='StandNoGun_nt';
                m_PawnWaitAnimHigh='StandNoGun_nt';
                m_PawnWaitAnimProne='StandNoGun_nt';
                GotoState('NoGrenadeLeft');
            }
            else
            {
                if (m_FPHands != none)
                {
                    if(m_FPHands.IsInState('RaiseWeapon'))
                        m_FPHands.BeginState();
                    else
                        m_FPHands.GotoState('RaiseWeapon');
                }
            }
            GotoState('StandByToThrow');
        }
    }
    function BeginState()
    {
   		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::WaitEndOfThrow::BeginState"); #endif
        if (bShowLog) log("WEAPON - BeginState of WaitEndOfThrow for "$self);
    }
}



state NoGrenadeLeft
{
    function Fire( FLOAT fValue );
	function StopFire(optional BOOL bSoundOnly) {}
	function AltFire( FLOAT fValue ) {}
	function StopAltFire() {}

    function BeginState()
	{
   		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::NoGrenadeLeft::BeginState"); #endif
        R6Pawn(Owner).m_bIsFiringState = FALSE;
		if(bShowLog) log(self$" state NoChargesLeft : BeginState()...");
		Pawn(Owner).controller.m_bHideReticule = TRUE;
        Pawn(Owner).controller.m_bLockWeaponActions = FALSE;
	}
}

function DestroyReticules()
{
    local R6Reticule aReticule;
    #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::DestroyReticules"); #endif
    
    aReticule = m_ReticuleInstance;
    m_ReticuleInstance = none;

    if(aReticule != none)
		aReticule.Destroy();
}

function ThrowGrenade()
{
    local vector    vStart; 
    local rotator   rFiringDir; 

    local R6Grenade aGrenade;
    local R6RainbowAI localRainbowAI;

    local R6Pawn PawnOwner;

    #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::ThrowGrenade"); #endif
    PawnOwner = R6Pawn(Owner);
	
    //log("ThrowGrenade");
    if (m_iNbBulletsInWeapon > 0)
    {
        m_iNbBulletsInWeapon--;

        // if we ran out of grenades then send notification
        // for players RoseDesVents
        if ((m_iNbBulletsInWeapon==0) && (PawnOwner!=none))
        {
            SetStaticMesh(none);

            localRainbowAI = R6RainbowAI(PawnOwner.controller);
            if ((localRainbowAI!=none) && 
                (localRainbowAI.m_TeamManager != none))
            {
                localRainbowAI.m_TeamManager.UpdateTeamGrenadeStatus();
            }
        }

        //Get the firing direction vStart is used as temporary variable
        GetFiringDirection(vStart, rFiringDir);
        
		//Get grenade start location.
		if(PawnOwner.m_bIsPlayer)
			vStart = PawnOwner.GetGrenadeStartLocation(m_eThrow);
		else
		    vStart = PawnOwner.GetHandLocation();
		
	    aGrenade = R6Grenade( Spawn( m_pBulletClass, Self,, vStart,rFiringDir ) );
		aGrenade.Instigator = PawnOwner;

        m_bReadyToThrow=false;

        if(PawnOwner.m_bIsProne == true)
        {
            aGrenade.SetSpeed(m_fMuzzleVelocity*0.5);
        }
        else
        {
            aGrenade.SetSpeed(m_fMuzzleVelocity);
        }
        
        ClientThrowGrenade();
    }
}

function ClientThrowGrenade()
{
    #ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::ClientThrowGrenade"); #endif
    m_bCanThrowGrenade = true;
}

state RaiseWeapon
{
    function FirstPersonAnimOver()
    {
		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::RaiseWeapon::FirstPersonAnimOver"); #endif

        if(bShowLog) log("GRENADE - RaiseWeapon Calling SWUAD");
        R6PlayerController(Pawn(Owner).controller).ServerWeaponUpAnimDone();
        GotoState('StandByToThrow');

        //Values are set here to remove the parameters of R6WeaponShake.
        R6Pawn(Owner).m_fWeaponJump = m_stAccuracyValues.fWeaponJump;
    }

    simulated function EndState()
    {
		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::RaiseWeapon::EndState"); #endif

        if(bShowLog) log("GRENADE - Leaving state Raise Weapon");
        Pawn(Owner).controller.m_bHideReticule = false;
        Pawn(Owner).controller.m_bLockWeaponActions = false;
        m_bCanThrowGrenade=true;
    }

    simulated function BeginState()
    {
		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::RaiseWeapon::BeginState"); #endif

        if (bShowLog) log("WEAPON - BeginState of RaiseWeapon for "$self);
        Pawn(Owner).controller.m_bLockWeaponActions = true;

        if(m_FPHands != none)
        {
            if(m_FPHands.IsInState('RaiseWeapon'))
                m_FPHands.BeginState();
            else
                m_FPHands.GotoState('RaiseWeapon');
            m_FPWeapon.m_smGun.bHidden = FALSE;
        }
        else
        {
            FirstPersonAnimOver();
        }
    }

}

state DiscardWeapon
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
    function StopFire(optional BOOL bSoundOnly) {}
    function StopAltFire() {}
    function PlayReloading() {}

    simulated function BeginState()
    {
		local Pawn aPawn;

		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::DiscardWeapon::BeginState"); #endif
        if (bShowLog) log("IN:"@self@"::DiscardWeapon::BeginState()");

        if(m_FPHands != none)
        {
			aPawn = Pawn(Owner);
			if(aPawn.controller != none)
            {
				aPawn.controller.m_bLockWeaponActions = true;
				aPawn.controller.m_bHideReticule = true;
            }
			if (m_iNbBulletsInWeapon > 0)
                m_FPHands.GotoState('DiscardWeapon');
            else
                FirstPersonAnimOver();
        }
    }
    simulated function EndState()
    {
        if (bShowLog) log("IN:"@self@"::DiscardWeapon::EndState()");
    }
}

//When the character has to use his hands before doing an action
state PutWeaponDown
{
    simulated function BeginState()
    {
 		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::PutWeaponDown::BeginState"); #endif

        if(bShowLog) log("WEAPON - "$self$" - BeginState of PutWeaponDown for "$self);
        if(m_FPHands != none)
        {
            if(m_iNbBulletsInWeapon == 0)
            {
                GotoState('NoGrenadeLeft');
            }
            else
            {
			    if(m_FPHands.IsInState('FiringWeapon'))
			    {
				    GotoState('');
				    return;
			    }
                Pawn(Owner).controller.m_bLockWeaponActions = true;
			    m_FPHands.GotoState('PutWeaponDown');
            }
        }
    }
}

//When the action is over, use this state to bring the weapon up.
state BringWeaponUp
{
    simulated function BeginState()
    {
 		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::BringWeaponUp::BeginState"); #endif

        if(bShowLog) log("WEAPON - "$self$" - BeginState of BringWeaponUp for "$self);
        if(m_FPHands != none)
        {
            if(m_iNbBulletsInWeapon == 0)
            {
                GotoState('NoGrenadeLeft');
            }
            else
            {
                m_FPHands.GotoState('BringWeaponUp');
            }
        }
        else
        {
            FirstPersonAnimOver();
        }
    }
    function FirstPersonAnimOver()
    {
 		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::BringWeaponUp::FirstPersonAnimOver"); #endif

        if((Pawn(Owner).Controller != none) && (Pawn(Owner).Controller.bFire == 1))
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('StandByToThrow');
        }
    }
    simulated function EndState()
    {
 		#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::BringWeaponUp::EndState"); #endif

        m_bCanThrowGrenade=true;
        Pawn(Owner).controller.m_bHideReticule = false;
        Pawn(Owner).controller.m_bLockWeaponActions = false;
    }
}

//------------------------------------------------------------------
// GetSaveDistanceToThrow: return the save distance from the grenade
//	to be for avoiding any harm.
//------------------------------------------------------------------
function FLOAT GetSaveDistanceToThrow() 
{ 
 	#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::GetSaveDistanceToThrow"); #endif

    // if it's bigger than 30, it will cause a lot's of damage (ie: exception for the flashbang)
    if ( m_pBulletClass.default.m_fKillBlastRadius > 30 ) 
    {
        return m_pBulletClass.default.m_fExplosionRadius;
    }
    else
    {
        return 0;
    }
}

simulated function WeaponInitialization( Pawn pawnOwner )
{
 	#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::WeaponInitialization"); #endif

    Super.WeaponInitialization( pawnOwner );

    if(Level.NetMode == NM_DedicatedServer)
        return;
    
    if (m_iNbBulletsInWeapon == 0)
        HideAttachment();
}

simulated event HideAttachment()
{
 	#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::HideAttachment"); #endif

    Super.HideAttachment();
    if (bShowLog) log("***** HideAttachment for" @ Self @ "******");
    SetDrawType(DT_None);
}    

function BOOL CanSwitchToWeapon()
{
 	#ifdefDEBUG if(bShowLog) log("R6GrenadeWeapon::CanSwitchToWeapon"); #endif

    if (m_iNbBulletsInWeapon > 0)
        return true;
    else
        return false;
}

#ifdefDEBUG
simulated function ShowInfo()
{
    super.ShowInfo();
    
    log("m_bReadyToThrow : "$m_bReadyToThrow);
}
#endif

defaultproperties
{
     m_bCanThrowGrenade=True
     m_bPinToRemove=True
     m_iClipCapacity=3
     m_fMuzzleVelocity=1500.000000
     m_szReticuleClass="GRENADE"
     m_stWeaponCaps=(bSingle=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripGrenade'
     m_eWeaponType=WT_Grenade
     m_bDisplayHudInfo=True
     m_ReloadSnd=Sound'Foley_CommonGrenade.Play_Grenade_Degoupille'
     m_BurstFireStereoSnd=Sound'Foley_CommonGrenade.Play_Grenade_Throw'
     m_PawnWaitAnimLow="StandGrenade_nt"
     m_PawnWaitAnimHigh="StandGrenade_nt"
     m_PawnWaitAnimProne="ProneGrenade_nt"
     m_AttachPoint="TagGrenadeHand"
     bCollideWorld=True
}
