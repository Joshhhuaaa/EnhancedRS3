//=============================================================================
//  R6DemolitionsGadget.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/06 * Created by Rima Brek
//=============================================================================
class R6DemolitionsGadget extends R6Gadget
	native
	abstract;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

var		BOOL				m_bDetonated;
var		BOOL				m_bChargeInPosition;
var		BOOL				m_bCanPlaceCharge;
var		BOOL				m_bInstallingCharge;
var     BOOL                m_bCancelChargeInstallation;
var		vector				m_vLocation;

var		R6Reticule			m_ReticuleConfirm;
var		R6Reticule			m_ReticuleBlock;
var		R6Reticule			m_ReticuleDetonator;

var		StaticMesh			m_DetonatorStaticMesh;	// 1st person
var		Texture				m_DetonatorTexture;
var		StaticMesh			m_ChargeStaticMesh;		// 3rd person
var		name				m_ChargeAttachPoint;
var     name                m_DetonatorAttachPoint;

var		class<emitter>		m_pExplosionParticles;
var		string				m_szReticuleBlockClass;
var		string				m_szDetonatorReticuleClass;

var		R6Grenade       	BulletActor;

var     BOOL                m_bRaiseWeapon;
var     BOOL                m_bHide;
var     BOOL                m_bDetonator;

replication
{
    //variables the server replicate to the client
    unreliable if (Role == ROLE_Authority)
        BulletActor, m_bHide, m_bDetonator;
    unreliable if (Role == ROLE_Authority)
        ClientMyUnitIsDestroyed;
    //function the client replicate to the server
    unreliable if (Role < ROLE_Authority)
        ServerGotoSetExplosive,ServerCancelChargeInstallation;
}

event NbBulletChange();

function MyUnitIsDestroyed()
{
    if(m_iNbBulletsInWeapon == 0)
        m_bHide = true;
    else
        m_bHide = false;

    m_bDetonator = false;
    ClientMyUnitIsDestroyed();
}

simulated function ClientMyUnitIsDestroyed()
{
    m_bDetonated = false;
    m_bRaiseWeapon = false;
	m_bChargeInPosition = false;
    BulletActor.m_bDestroyedByImpact=true;

    if(IsInState('ChargeArmed'))
    {
        R6Pawn(Owner).m_bIsFiringState = false; // to cancel switch weapon

		if(m_FPHands != none)
        {
			m_FPHands.GotoState('DiscardWeapon');
        }

        if(m_iNbBulletsInWeapon<=0)
        {
		    GotoState('NoChargesLeft');
        }
	    else
        {
		    GotoState('GetNextCharge');
        }
    }
    else
    {
        if(m_iNbBulletsInWeapon > 0)
        {
/*
            m_AttachPoint = m_ChargeAttachPoint;
            SetStaticMesh(m_ChargeStaticMesh);
    		Pawn(owner).AttachToBone(self, m_AttachPoint);
*/
		    if(m_FPHands != none)
            {
                SetAmmoStaticMesh();
                SwitchToChargeHandAnimations();
            }
        }
/*
        else
        {
            HideAttachment();
        }
*/
    }
}

simulated function UpdateHands()
{
    if(m_bChargeInPosition == true)
    {
		m_FPWeapon.m_smGun.SetStaticMesh(m_DetonatorStaticMesh);
        SwitchToDetonatorHandAnimations();
    }
    else
    {
        SetAmmoStaticMesh();
        SwitchToChargeHandAnimations();
    }
}

event PostBeginPlay()
{
    Super.PostBeginPlay();

    SetGadgetStaticMesh();
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    SetGadgetStaticMesh();
}

simulated function ServerPlaceCharge(vector vLocation)
{
	local  rotator		rDesiredRotation;

    if(m_iNbBulletsInWeapon == 0)
        return;

    m_iNbBulletsInWeapon--;
    m_bDetonator = true;

	rDesiredRotation = Pawn(owner).GetViewRotation();
	rDesiredRotation.pitch = 0;
	rDesiredRotation.yaw += 32768;
    BulletActor = R6Grenade(Spawn(m_pBulletClass,self));
	if(bShowLog) log("R6DemolitionsGadget :: ServerPlaceCharge() "$BulletActor$" rDesiredRotation="$rDesiredRotation$" vLocation="$vLocation);
    BulletActor.SetLocation(vLocation + vect(0,0,10));		
	BulletActor.SetRotation(rDesiredRotation);
    BulletActor.m_Weapon = self;
	BulletActor.Instigator = Pawn(Owner);
    BulletActor.SetSpeed(0);

	// switch back to detonator static mesh
    m_AttachPoint = m_DetonatorAttachPoint;
	SetStaticMesh(default.StaticMesh);
	Pawn(owner).AttachToBone(self, m_AttachPoint);
}

function ServerPlaceChargeAnimation();
function PlaceChargeAnimation();
function Activate();
function SetAmmoStaticMesh();

function ServerDetonate()
{
    if (m_iNbBulletsInWeapon == 0)
        m_bHide = true;

    m_bDetonator = false;
    if(bShowLog) log(" Explode() BulletActor="$BulletActor);
    BulletActor.Explode();
    BulletActor.Destroy();
}

function Fire( FLOAT fValue )
{
    if (bShowLog) log("(R6DemolitionsGadget) WEAPON - R6Weapons.NoState::Fire(" $ fValue $ ") for weapon "$self);

    if(Pawn(Owner).controller.m_bLockWeaponActions == true)
        return;
    
    //Kill the timer for wait animations
    m_FPHands.StopTimer();
	if(m_bChargeInPosition)
	{
        m_bDetonated=false;
		GotoState('ChargeArmed');
	}
	else
	{
		GotoState('ChargeReady');
	}
}

function StopFire(optional BOOL bSoundOnly) {}
function AltFire( FLOAT fValue ) {}
function StopAltFire() {}

simulated function BOOL LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
    super.LoadFirstPersonWeapon(NetOwner, LocalPlayerController);

    //if(bShowlog)log("LoadFirstPersonWeapon : "$m_bChargeInPosition$" : "$m_bInstallingCharge$" : "$m_bRaiseWeapon);
    if(m_bChargeInPosition == true)
    {
        SwitchToDetonatorHandAnimations();
		// switch gadget in hand to the detonator...
		m_FPWeapon.m_smGun.SetStaticMesh(m_DetonatorStaticMesh);
    }
    return true;
}

//When changing charter, this is to start playing the wait animations.
function StartLoopingAnims()
{
    if(m_FPHands != none)
    {
        m_FPHands.SetDrawType(DT_Mesh);
        m_FPHands.GotoState('Waiting');
    }
    //GotoState('');
}


function SwitchToDetonatorHandAnimations()
{
	m_FPHands.UnLinkSkelAnim();
	m_FPHands.LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripDetonatorA');
}

function SwitchToChargeHandAnimations()
{
	m_FPHands.UnLinkSkelAnim();
	m_FPHands.LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripBreachA');
}

state RaiseWeapon
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
    function StopFire(optional BOOL bSoundOnly) {}
    function StopAltFire() {}
    function PlayReloading() {}

    simulated function EndState()
    {
        Pawn(Owner).controller.m_bHideReticule = false;
        Pawn(Owner).controller.m_bLockWeaponActions = false;
    }

    simulated function FirstPersonAnimOver()
    {
        if(bShowLog) log("FirstPersonAnimOver()  R6DemolitionsGadget"  );
        R6PlayerController(Pawn(Owner).controller).ServerWeaponUpAnimDone();

		if(m_bChargeInPosition)
        {
            m_bDetonated=false;
			GotoState('ChargeArmed');
        }
		else
			GotoState('ChargeReady');
    }

    simulated function BeginState()
    {
        if (bShowLog) log("WEAPON - BeginState of RaiseWeapon for "$self);

        Pawn(Owner).controller.m_bLockWeaponActions = true;

        if (m_FPHands != none)	
        {
            m_bRaiseWeapon=true;
            m_FPHands.GotoState('RaiseWeapon');
        }
    }
}

state ChargeReady
{
	function BeginState()	
	{
		Pawn(Owner).controller.m_bLockWeaponActions = FALSE;

        m_bRaiseWeapon = false;
		if(bShowLog) log(self$" entered state ChargeReady...");		
		// switch to charge static mesh
        m_AttachPoint = m_ChargeAttachPoint;
		SetStaticMesh(m_ChargeStaticMesh);
		Pawn(owner).AttachToBone(self, m_AttachPoint);
		
		m_bDetonated = FALSE;
        
		if((Pawn(Owner).Controller.bFire == 1) && (CanPlaceCharge() == true))
        {
			Fire(0);
        }
	}
    
	function EndState()		
	{		
		if(bShowLog) log(self$" exited state ChargeReady...");
        SetTimer(0, false);
	}

	// set timer for placing charge - check demolitions skill...
	function Timer()
	{
        local R6Pawn PawnOwner;
        local R6PlayerController PlayerCtrl;
        PawnOwner = R6Pawn(Owner);
        PlayerCtrl = R6PlayerController(PawnOwner.controller);

        if(!PawnOwner.m_bIsPlayer || PawnOwner.m_bPostureTransition || !m_bInstallingCharge)
			return;

		if(bShowLog) log(self$" state ChargeReady : Timer() has expired "$PlayerCtrl.m_bPlacedExplosive$" : "$PlayerCtrl.GetStateName());

        //Check here if the animation was started.  It might happend with network lag.
        if(PlayerCtrl.m_bPlacedExplosive)
        {
            ServerPlaceCharge(m_vLocation); 
		    m_bChargeInPosition = true;
		    m_bInstallingCharge = false;
            m_bRaiseWeapon = false;

		    // switch gadget in hand to the detonator...
		    m_FPWeapon.m_smGun.SetStaticMesh(m_DetonatorStaticMesh); 
		    GotoState('ChargeArmed');
        }
	}

	function Fire( FLOAT fValue ) 
	{
        local R6PlayerController PlayerCtrl;
        PlayerCtrl = R6PlayerController(R6Pawn(Owner).controller);

        if(m_bChargeInPosition || !m_bCanPlaceCharge || (PlayerCtrl.m_bLockWeaponActions == true))
			return;

        PlayerCtrl.DoZoom(true);
        PlayerCtrl.m_bLockWeaponActions = TRUE;
		m_bInstallingCharge = true;

		HideReticule();
        if(Level.NetMode == NM_Client)
            ServerGotoSetExplosive();
		PlayerCtrl.GotoState('PlayerSetExplosive');		
		PlaceChargeAnimation();

		// DROP! set location of remote charge (must be on ground)
        m_vLocation = PlayerCtrl.m_vDefaultLocation;
		if(bShowLog) log(self$" state ChargeReady : Remote Charge has been placed at m_vLocation = "$m_vLocation);


        if(m_FPHands != none)
			m_FPHands.GotoState('DiscardWeapon');
		SetTimer(0.1, true);  //check every 0.5 seconds if animation is over... // SetTimer(3, false);
	}
    
    function FirstPersonAnimOver()
    {
        if(m_bCancelChargeInstallation == true)
        {
            m_bCancelChargeInstallation = false;
            Pawn(Owner).controller.m_bLockWeaponActions = FALSE;
            SetTimer(0, false);
        }
    }
}

state ChargeArmed
{
	function BeginState()	
	{		
		if(bShowLog) log(self$" state ChargeArmed : beginState() "$m_bRaiseWeapon);	

		// set a dot reticule when holding detonator
		m_ReticuleInstance = m_ReticuleDetonator;
		Pawn(Owner).controller.m_bHideReticule = false;		
		
		if (m_FPHands != none)
		{
			// change to the detonator animations
			SwitchToDetonatorHandAnimations();
			if (!m_bRaiseWeapon)
            {
                m_bRaiseWeapon = true;
                m_FPHands.GotoState('RaiseWeapon');
            }
            else
                m_bRaiseWeapon = false;
		}
        else
        {
            m_bRaiseWeapon = false;
        }
	}
    
	function EndState()		
	{		
		if(bShowLog) log(self$" state ChargeArmed : endState() "$m_bDetonated$" : "$m_bChargeInPosition);		
	}

    function FirstPersonAnimOver()
    {
        if (bShowLog) log("First person anim over "$m_bRaiseWeapon);
        if (m_bRaiseWeapon)
        {
            Pawn(Owner).controller.m_bLockWeaponActions = FALSE;
            m_bRaiseWeapon = false;
            return;
        } 
        else if (m_bDetonated)
        {
            if(bShowLog) log(self$" state ChargeArmed : DETONATE CHARGE!!! # left :"$m_iNbBulletsInWeapon);
		    ServerDetonate(); 
		    m_bChargeInPosition = false;
		    SetStaticMesh(none);

            R6Pawn(Owner).m_bIsFiringState = false; // to cancel switch weapon

		    // if no charges remain
		    if(m_iNbBulletsInWeapon<=0)
			    GotoState('NoChargesLeft');
		    else
			    GotoState('GetNextCharge');
        }
    }


	function Fire(FLOAT fValue)
	{
        if (!m_bRaiseWeapon)
        {
            if(!m_bDetonated)
		    {
                Pawn(Owner).controller.m_bLockWeaponActions = true;
                R6Pawn(Owner).m_bIsFiringState = true; // to cancel switch weapon
    		    m_bDetonated = true;
                if (m_FPHands != none)
                {
                    m_FPHands.GotoState('FiringWeapon');
                    m_FPHands.FireSingleShot();
                }
                else
                    FirstPersonAnimOver();
		    }
		    else
			    if(bShowLog) log(self$" state ChargeArmed : DO NOTHING, charge has already exploded...");					
        }
	}
}

state GetNextCharge
{
	function Fire( FLOAT fValue );
	function StopFire(optional BOOL bSoundOnly) {}
	function AltFire( FLOAT fValue ) {}
	function StopAltFire() {}
    
    function BeginState()
	{
		if(bShowLog) log(self$" state GetNextCharge : beginState() ");			
	}
    
    function FirstPersonAnimOver()
    {
        m_AttachPoint = m_ChargeAttachPoint;
        SetAmmoStaticMesh();
		if(m_FPHands != none)
		{
			SwitchToChargeHandAnimations();
			m_FPHands.GotoState('RaiseWeapon');
		}
		GotoState('ChargeReady');
    }
}

state NoChargesLeft
{
	function BeginState()
	{
		if(bShowLog) log(self$" state NoChargesLeft : BeginState()...");
		Pawn(Owner).controller.m_bHideReticule = TRUE;
    }

	function Fire( FLOAT fValue );
	function StopFire(optional BOOL bSoundOnly) {}
	function AltFire( FLOAT fValue ) {}
	function StopAltFire() {}

    function FirstPersonAnimOver()
    {
		local R6PlayerController PController;
        Pawn(Owner).controller.m_bLockWeaponActions = FALSE;
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


state DiscardWeapon
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
    function StopFire(optional BOOL bSoundOnly) {}
    function StopAltFire() {}
    function PlayReloading() {}

    simulated function BeginState()
    {
        m_bRaiseWeapon=false;
        if(m_FPHands != none)
        {
            if (bShowLog) log("***** DiscardWeapon for" @ Self @ m_bDetonator @ m_iNbBulletsInWeapon @"******");
            if(Pawn(Owner).controller != none)
            {
                Pawn(Owner).controller.m_bHideReticule = true;
                Pawn(Owner).controller.m_bLockWeaponActions = TRUE;
            }
            if (m_bDetonator  || (m_iNbBulletsInWeapon > 0))
                m_FPHands.GotoState('DiscardWeapon');
            else
                FirstPersonAnimOver();
        }
    }
}
//When the action is over, use this state to bring the weapon up.
state BringWeaponUp
{
    simulated function BeginState()
    {
        if(bShowLog) log("WEAPON - "$self$" - BeginState of BringWeaponUp for "$self);
        if(m_FPHands != none)
        {
            if((m_iNbBulletsInWeapon == 0) && m_bDetonated )
            {
                GotoState('NoChargesLeft');
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
        
    simulated function FirstPersonAnimOver()
    {
        if(bShowLog) log("FirstPersonAnimOver()  R6DemolitionsGadget"  );
        R6PlayerController(Pawn(Owner).controller).ServerWeaponUpAnimDone();

		if(m_bChargeInPosition)
        {
            m_bDetonated=false;
			GotoState('ChargeArmed');
        }
		else
			GotoState('ChargeReady');
    }
    simulated function EndState()
    {
        Pawn(Owner).controller.m_bHideReticule = false;
        Pawn(Owner).controller.m_bLockWeaponActions = false;
        m_bRaiseWeapon = true;
    }
}
//Delete the first person weapon.  To keep only one in memory
simulated function RemoveFirstPersonWeapon()
{
    if(m_FPHands != none)
        m_FPHands.Destroy();
    m_FPHands = none;

	if(m_FPWeapon != none)
    {
        m_FPWeapon.DestroySM();
		m_FPWeapon.Destroy();
    }
	m_FPWeapon = none;

    if (m_MagazineGadget != none)
    {
        m_MagazineGadget.DestroyFPGadget();
        m_MagazineGadget = none;
    }

	DestroyReticules();
}

function HideReticule()
{
	m_ReticuleInstance = none;
}

function DestroyReticules()
{
    local R6Reticule aReticule;

    aReticule = m_ReticuleConfirm;
	m_ReticuleConfirm = none; 
    if(aReticule != none)
		aReticule.Destroy();

    aReticule = m_ReticuleBlock;
	m_ReticuleBlock = none;
    if(aReticule != none)
		aReticule.Destroy();

	aReticule = m_ReticuleDetonator;
	m_ReticuleDetonator = none;
    if(aReticule != none)
		aReticule.Destroy();

    m_ReticuleInstance = none;
}

simulated function R6SetReticule(optional Controller LocalPlayerController)
{
    local R6PlayerController PlayerCtrl;
    local class<Actor> ReticuleToSpawn;

    //Load the reticule only if the player is locally controlled and if it's a Rainbow
    if(Owner.IsA('R6Rainbow'))
    {
        // we only want to SPAWN reticule on the client, we don't need it on the server
        if ((m_szReticuleClass != "") && (m_ReticuleInstance == none))
        {
			ReticuleToSpawn = class'Actor'.static.GetModMgr().GetCurrentReticule(m_szReticuleClass);
			m_ReticuleConfirm = R6Reticule(Spawn(ReticuleToSpawn));
			ReticuleToSpawn = class'Actor'.static.GetModMgr().GetCurrentReticule(m_szReticuleBlockClass);
			m_ReticuleBlock = R6Reticule(Spawn(ReticuleToSpawn));
			ReticuleToSpawn = class'Actor'.static.GetModMgr().GetCurrentReticule(m_szDetonatorReticuleClass);
			m_ReticuleDetonator = R6Reticule(Spawn(ReticuleToSpawn));
			m_ReticuleInstance = m_ReticuleBlock;

            m_ReticuleConfirm.SetOwner(owner);
			m_ReticuleBlock.SetOwner(owner);
			m_ReticuleDetonator.SetOwner(owner);

			if (Level.NetMode == NM_Standalone)
			{
				m_ReticuleConfirm.m_bShowNames = GetGameOptions().HUDShowPlayersName;
				m_ReticuleBlock.m_bShowNames = GetGameOptions().HUDShowPlayersName;
				m_ReticuleDetonator.m_bShowNames = GetGameOptions().HUDShowPlayersName;
			}
			else
			{
                PlayerCtrl = R6PlayerController(LocalPlayerController);
                if(PlayerCtrl == none)
                    PlayerCtrl = R6PlayerController(R6Pawn(Owner).controller);
				m_ReticuleConfirm.m_bShowNames = R6GameReplicationInfo(PlayerCtrl.GameReplicationInfo).m_bShowNames;
				m_ReticuleBlock.m_bShowNames = m_ReticuleConfirm.m_bShowNames;
				m_ReticuleDetonator.m_bShowNames = m_ReticuleConfirm.m_bShowNames;
			}
        }
    }
}

// this must be redefined in each demolitions gadget class
simulated function bool CanPlaceCharge()
{
	local vector vFeetLocation;
	local vector vLookLocation;

    local R6Pawn PawnOwner;
    local R6PlayerController PlayerCtrl;
    PawnOwner = R6Pawn(Owner);
    PlayerCtrl = R6PlayerController(PawnOwner.controller);

	if((owner == none) || (PawnOwner.controller == none))
		return false;
	
	if(PawnOwner.m_bPostureTransition)
		return false;

    if(PlayerCtrl != none)
    {
	    vLookLocation = PlayerCtrl.m_vDefaultLocation;
	    if(vLookLocation == vect(0,0,0))
		    return false;
    }

    //Pawn is walking
    if(!PawnOwner.IsStationary() || PawnOwner.m_fPeeking != PawnOwner.C_fPeekMiddleMax )
        return false;

	vFeetLocation = owner.location;
	vFeetLocation.z -= PawnOwner.collisionHeight;

	if(VSize(vLookLocation - vFeetLocation) < 75)
		return true;

	return false;
}

function ServerGotoSetExplosive()
{
    R6Pawn(Owner).PlayWeaponSound(WSOUND_PlayFireSingleShot);
	R6PlayerController(Pawn(Owner).controller).GotoState('PlayerSetExplosive');
}

function ServerCancelChargeInstallation()
{
    if(bShowLog) log("Server Cancel Charge Installation : "$R6PlayerController(Pawn(Owner).Controller).GetStateName());

    R6Pawn(Owner).PlayWeaponSound(WSOUND_PlayFireEndSingleShot);

	if(R6Pawn(Owner).IsAlive())
	{
        R6Pawn(Owner).m_bToggleServerCancelPlacingCharge = !R6Pawn(Owner).m_bToggleServerCancelPlacingCharge;

		if(!(class'Actor'.static.GetModMgr().IsMissionPack() && Owner.IsA('R6Rainbow') && R6Rainbow(Owner).m_bIsSurrended)) //MPF_Milan
            R6PlayerController(Pawn(Owner).Controller).GotoState('PlayerWalking');
    }
}

simulated function CancelChargeInstallation()
{
    if(bShowLog) log("Cancel Charge Installation");

    SetTimer(0, false);
    m_bCancelChargeInstallation = true;
	m_bInstallingCharge = false;
	if(R6Pawn(Owner).IsAlive())
	{
		if(!(class'Actor'.static.GetModMgr().IsMissionPack() && Owner.IsA('R6Rainbow') && R6Rainbow(Owner).m_bIsSurrended)) ////MPF_Milan  
            R6PlayerController(Pawn(Owner).Controller).GotoState('PlayerWalking');
		m_FPHands.GotoState('RaiseWeapon');
	}
}

simulated function Tick(FLOAT fDeltaTime)
{
    if ((owner == none) || (self != R6Pawn(Owner).EngineWeapon))
        return;

	Super.Tick(fDeltaTime);

	if(m_bChargeInPosition || m_bDetonated)
		return;

	if(m_bInstallingCharge && (Pawn(Owner).Controller.bFire == 0))
    {
        if((Level.NetMode == NM_Client) || ((Level.NetMode == NM_ListenServer) && R6Pawn(Owner).IsLocallyControlled()))
            ServerCancelChargeInstallation();
		CancelChargeInstallation();
    }

	// don't display a reticule while installing a charge
	if(m_bInstallingCharge)
		return;

    // choose the appropriate reticule to display
	m_bCanPlaceCharge = CanPlaceCharge();
	if(m_bCanPlaceCharge)
		m_ReticuleInstance = m_ReticuleConfirm;
	else
		m_ReticuleInstance = m_ReticuleBlock;
}

simulated event HideAttachment()
{
    if (bShowLog) log("***** HideAttachment for" @ Self @ "****** : "$m_bHide);

    if(m_bHide == true)
        SetDrawType(DT_None);
    else
    {
        SetDrawType(DT_StaticMesh);
        bHidden=false;
    }
}

simulated event SetGadgetStaticMesh()
{
    if (bShowLog) log("***** SetGadgetStaticMesh for" @ Self @ "****** : "$m_bDetonator);

    if (m_bDetonator)
    {
        m_AttachPoint = m_DetonatorAttachPoint;
    	SetStaticMesh(default.StaticMesh);
    	Pawn(owner).AttachToBone(self, m_AttachPoint);
    }
    else
    {
        m_AttachPoint = m_ChargeAttachPoint;
	    SetStaticMesh(m_ChargeStaticMesh);
		Pawn(owner).AttachToBone(self, m_AttachPoint);
    }
}

function BOOL CanSwitchToWeapon()
{
    if (bShowLog) log("***** CanSwitchToWeapon for" @ Self @ m_bDetonator @ m_iNbBulletsInWeapon @ GetStateName()@"******");
    if ((m_bDetonator || (m_iNbBulletsInWeapon > 0)) && !IsInState('ChargeReady'))
        return true;
    else
        return false;
}


#ifdefDEBUG
simulated function ShowInfo()
{
    super.ShowInfo();
    
    log("DemoGadget Charge In position : "$m_bChargeInPosition);
    log("DemoGadget RaiseWeapon "$m_bRaiseWeapon);
}
#endif

defaultproperties
{
     m_DetonatorAttachPoint="TagDetonatorHand"
     m_szReticuleBlockClass="CROSS"
     m_szDetonatorReticuleClass="DOT"
     m_iClipCapacity=2
     m_szReticuleClass="GRENADE"
     m_bHiddenWhenNotInUse=True
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripC4'
     m_bDisplayHudInfo=True
     m_EquipSnd=Sound'Foley_HBSJammer.Play_HBSJ_Equip'
     m_UnEquipSnd=Sound'Foley_HBSJammer.Play_HBSJ_Unequip'
     m_NameID="DiffuseKit"
     bCollideWorld=True
}
