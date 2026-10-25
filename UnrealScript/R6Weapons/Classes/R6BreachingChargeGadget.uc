//=============================================================================
//  R6BreachingChargeGadget : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/04 * Created by Rima Brek
//=============================================================================
class R6BreachingChargeGadget extends R6DemolitionsGadget;

var		R6IORotatingDoor	m_IORDoor;

replication
{
    //Values replicated to the server
    reliable if (Role < ROLE_Authority)
        ServerSetDoor;
}

function ServerDetonate()
{
    m_IORDoor.RemoveBreach(BulletActor);
    super.ServerDetonate();
}

simulated function PlaceChargeAnimation()
{
	//R6Pawn(Owner).PlayBreachDoorAnimation();
	ServerPlaceChargeAnimation();
}

function ServerPlaceChargeAnimation()
{
	R6Pawn(owner).SetNextPendingAction(PENDING_SetBreachingCharge);
}

function NPCPlaceCharge(actor aDoor)
{
	if(bShowLog) log(" NonPlayerPlaceCharge() aDoor="$aDoor);
	m_IORDoor = R6IORotatingDoor(aDoor);
	ServerPlaceCharge(m_IORDoor.location); 
	m_bChargeInPosition = true;	
	GotoState('ChargeArmed');
}

function NPCDetonateCharge()
{
	if(bShowLog) log(" NPCDetonateCharge() m_bChargeInPosition="$m_bChargeInPosition);
	if(m_bChargeInPosition)
	{
        m_IORDoor.RemoveBreach(BulletActor);
		Explode();
		m_bChargeInPosition = false;
	}
}

function bool CharacterOnOtherSide()
{
    local INT iDiffYaw;

    iDiffYaw = (m_IORDoor.Rotation.Yaw - Owner.Rotation.Yaw) & 65535;

    if(iDiffYaw < 32768)
    {
        return true;
    }
    return false;
}

simulated function ServerSetDoor(R6IORotatingDoor aDoor)
{
    m_IORDoor = aDoor;
}

simulated function ServerPlaceCharge(vector vLocation)
{
    BulletActor = R6Grenade(Spawn(m_pBulletClass,self));
	if(bShowLog) log("  ServerPlaceCharge was called for Breach... BulletActor="$BulletActor$" : "$m_IORDoor);

	if((BulletActor == none) || (m_IORDoor == none) || (m_iNbBulletsInWeapon == 0))
		return;
		
    BulletActor.m_Weapon = self;
	BulletActor.Instigator = Pawn(Owner);
    BulletActor.SetSpeed(0);

    //link the door to the bullet and the bullet to the door.
    BulletActor.SetOwner(m_IORDoor);
    BulletActor.SetBase(m_IORDoor, m_IORDoor.Location);

    m_IORDoor.AddBreach(BulletActor);
    
    BulletActor.bUnlit = m_IORDoor.bUnlit;
    BulletActor.bSpecialLit = m_IORDoor.bSpecialLit;

    if(m_IORDoor.m_bIsOpeningClockWise)
        BulletActor.SetRelativeLocation(vect(-64,2.5,0));
    else
        BulletActor.SetRelativeLocation(vect(-64,-2.5,0));

    if(CharacterOnOtherSide())
        BulletActor.SetRelativeRotation(rot(0,32768,0));
    else
        BulletActor.SetRelativeRotation(rot(0,0,0));

	// switch back to detonator static mesh
    m_AttachPoint = m_DetonatorAttachPoint;
	SetStaticMesh(default.StaticMesh);
	Pawn(owner).AttachToBone(self, m_AttachPoint);
	m_iNbBulletsInWeapon--;
    m_bDetonator = true;
}

function SetAmmoStaticMesh()
{
    m_FPWeapon.m_smGun.SetStaticMesh( StaticMesh'R61stWeapons_SM.Items.R61stBreachingCharge' );
}

function Explode()
{
	// set the properties for the door to breach?
	BulletActor.Explode();
    BulletActor.Destroy();	
}

function bool CanPlaceCharge()
{
	local vector vFeetLocation;
	local vector vLookLocation;
	local vector vHitLocation, vHitNormal; 
	local actor hitActor;

    local R6Pawn PawnOwner;
    PawnOwner = R6Pawn(Owner);

    if(PawnOwner.m_bIsProne || !PawnOwner.IsStationary() || PawnOwner.m_fPeeking != PawnOwner.C_fPeekMiddleMax )
        return false;
	
	// make sure pawn has touched an R6Door actor
	if((PawnOwner.m_Door == none) || (PawnOwner.m_Door2 == none))
		m_IORDoor = R6IORotatingDoor(PawnOwner.m_potentialActionActor);
	else if(VSize(PawnOwner.m_Door.m_RotatingDoor.Location - PawnOwner.Location) < VSize(PawnOwner.m_Door2.m_RotatingDoor.Location - PawnOwner.Location))
		m_IORDoor = PawnOwner.m_Door.m_RotatingDoor;
	else
		m_IORDoor = PawnOwner.m_Door2.m_RotatingDoor;
	if(m_IORDoor == none)
	{
		//if(bShowLog) log(owner$" is not close enough to a door in order to set a breaching charge...");
		return false;		
	}
	
	if(m_IORDoor.m_bInProcessOfClosing || m_IORDoor.m_bInProcessOfOpening)
		return false;

    if(!PawnOwner.m_bIsPlayer)
	{
	//	if(bShowLog) log(owner$" NPC can place breaching charge....m_v");
		m_vLocation = m_IORDoor.location;
		return true;
	}

	// make sure we are close enough to the door
	hitActor = PawnOwner.Trace(vHitLocation, vHitNormal, Owner.Location + 100*vector(owner.rotation), Owner.Location, true );

	if((hitActor == none) || !hitActor.IsA('R6IORotatingDoor'))
		return false;	

    if((R6IORotatingDoor(hitActor).m_bTreatDoorAsWindow) || (R6IORotatingDoor(hitActor).m_bBroken))
        return false;
    
	m_vLocation = m_IORDoor.location;

    if(!Pawnowner.IsLocallyControlled())
		return true;

	// make sure pawn is actually looking at door 	
	if(m_IORDoor == R6PlayerController(PawnOwner.Controller).m_CurrentCircumstantialAction.aQueryTarget)
		return true;	

	return false;
}

simulated function name GetFiringAnimName()
{
	if(Pawn(owner).bIsCrouched)
		return 'CrouchPlaceBreach';
	else
		return m_PawnFiringAnim;
}


simulated function Tick(FLOAT fDeltaTime)
{
    if(owner == none)
        return;

	if(m_bInstallingCharge && (m_IORDoor.m_bInProcessOfClosing || m_IORDoor.m_bInProcessOfOpening) || m_IORDoor.m_fNetDamagePercentage < 10.0)
    {
        if((Level.NetMode == NM_Client) || (Level.NetMode == NM_ListenServer && R6Pawn(Owner).IsLocallyControlled()))
            ServerCancelChargeInstallation();
		CancelChargeInstallation();
    }

	Super.Tick(fDeltaTime);
}

state ChargeReady
{
	// set timer for placing charge - check demolitions skill...
	function Timer()
	{
		if(!R6Pawn(owner).m_bIsPlayer || R6Pawn(owner).m_bPostureTransition || !m_bInstallingCharge)
			return;		// was probably cancelled...

		if(bShowLog) log(self$" state ChargeReady : Timer() has expired "$R6PlayerController(Pawn(Owner).controller).m_bPlacedExplosive);

        //Check here if the animation was started.  It might happend with network lag.
        if(R6PlayerController(Pawn(Owner).controller).m_bPlacedExplosive)
        {
            ServerSetDoor(m_IORDoor);
            ServerPlaceCharge(m_vLocation); 
		    m_bChargeInPosition = true;
		    m_bInstallingCharge = false;
            m_bRaiseWeapon = false;

		    // switch gadget in hand to the detonator...
		    m_FPWeapon.m_smGun.SetStaticMesh(m_DetonatorStaticMesh); 
		    GotoState('ChargeArmed');
        }
	}
}

defaultproperties
{
     m_DetonatorStaticMesh=StaticMesh'R61stWeapons_SM.Items.R61stBreachingDetonator'
     m_ChargeStaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdBreachingCharge'
     m_ChargeAttachPoint="TagC4Hand"
     m_iClipCapacity=3
     m_pBulletClass=Class'R6Weapons.R6BreachingChargeUnit'
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripBreach'
     m_pFPWeaponClass=Class'R61stWeapons.R61stBreachingCharge'
     m_SingleFireStereoSnd=Sound'Gadget_BreachingCharge.Play_BreachingChargePlacement'
     m_SingleFireEndStereoSnd=Sound'Gadget_BreachingCharge.Stop_BreachingCharge_Go'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandGrenade_nt"
     m_PawnWaitAnimHigh="StandGrenade_nt"
     m_PawnWaitAnimProne="ProneGrenade_nt"
     m_PawnFiringAnim="StandPlaceBreach"
     m_AttachPoint="TagC4Hand"
     m_HUDTexturePos=(W=32.000000,X=100.000000,Y=352.000000,Z=100.000000)
     m_NameID="BreachingChargeGadget"
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdBreachingDetonator'
}
