class R6HBSGadget extends R6Gadget
    native;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

var BOOL m_bHeartBeatOn;    // Heart Beat sensor activation.
var Sound m_sndActivation;
var Sound m_sndDesactivation;

native(2700) final function ToggleHeartBeatProperties(BOOL bTurnItOn);


replication
{

    // function client asks server to do
	unreliable if (Role < ROLE_Authority)
		ServerToggleHeartBeatProperties;

}

simulated event BOOL IsGoggles()
{
	return true;
}

function ServerToggleHeartBeatProperties(BOOL bActiveHeartBeat)
{
	
	if(bShowLog) log("HBS - ServerToggleHeartBeatProperties =" @ bActiveHeartBeat);

	m_bHeartBeatOn=bActiveHeartBeat;
}

// ----------------------------------------
// All This function do nothing in the HBS
function Fire( FLOAT fValue ) {}
function StopFire(optional BOOL bSoundOnly) {}
function AltFire( FLOAT fValue ) {}
function StopAltFire() {}
// ----------------------------------------

// Display the HeartBeat in the map.
function DisplayHeartBeat(BOOL bActivateHeartBeat)
{
    local R6Pawn PawnOwner;
    PawnOwner = R6Pawn(Owner);

    if (!PawnOwner.IsLocallyControlled())
		return;

    if (bShowLog) log("HBS - DisplayHeartBeat =" @ bActivateHeartBeat @ m_sndActivation @ m_sndDesactivation);
    m_bHeartBeatOn = bActivateHeartBeat;
	
	if (bActivateHeartBeat)
		PawnOwner.PlaySound( m_sndActivation, SLOT_SFX);
	else
		PawnOwner.PlaySound( m_sndDesactivation, SLOT_SFX);

    ServerToggleHeartBeatProperties(bActivateHeartBeat);	
    ToggleHeartBeatProperties(bActivateHeartBeat);
}

// When the player change the weapon we have to desactivate the HBS
simulated function RemoveFirstPersonWeapon()
{
    super.RemoveFirstPersonWeapon();
    DisplayHeartBeat(false);
    if (bShowLog) log("HBS - RemoveFirstPersonWeapon =" @ m_bHeartBeatOn);
}

// When we change player in the team we have to desactivate or reactivate the HBS
simulated function BOOL LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
    super.LoadFirstPersonWeapon(NetOwner, LocalPlayerController);

    if (bShowLog) log("HBS - LoadFirstPersonWeapon =" @ m_bHeartBeatOn);

    DisplayHeartBeat(m_bHeartBeatOn);
    return true;
}

// Turn off the heart beat sensor
simulated function DisableWeaponOrGadget()
{
    DisplayHeartBeat(false);
    if (bShowLog) log("HBS - DisableWeaponOrGadget =" @ m_bHeartBeatOn);
}

// On the raise weapon we turn on the HeartBeat. At the end of the animation we can see the heartBeat.


state PutWeaponDown
{
    simulated function BeginState()
    {
        if(m_FPHands != none)
        {
            m_FPHands.GotoState('PutWeaponDown');
            Pawn(Owner).controller.m_bLockWeaponActions = true;
        }
        DisplayHeartBeat(false);
        if(bShowLog) log("HBS - BeginState of PutWeaponDown for" @ self @ "=" @ m_bHeartBeatOn);
    }
}

state BringWeaponUp
{
    simulated function BeginState()
    {
        Super.BeginState();
        if(R6Pawn(Owner).m_bActivateNightVision == true)
            R6Pawn(Owner).ToggleNightVision();
    }
    simulated function EndState()
    {
        Pawn(Owner).controller.m_bLockWeaponActions = false;
    }

    function FirstPersonAnimOver()
    {
        GotoState('');

        DisplayHeartBeat(true);
        if(bShowLog) log("HBS - FirstPersonAnimOver of BringWeaponUp for" @ self @ "=" @ m_bHeartBeatOn);
    }
}

state RaiseWeapon
{
    function FirstPersonAnimOver()
    {
        if (bShowLog) log("HBS - FirstPersonAnimOver in RaiseWeapon for "$self);
        R6PlayerController(Pawn(Owner).controller).ServerWeaponUpAnimDone();
        GotoState('');
    }
    
    simulated function BeginState()
    {
        if(bShowLog) log("HBS - BeginState of RaiseWeapon for" @ self @ "=" @ m_bHeartBeatOn);
        Super.BeginState();
        if(R6Pawn(Owner).m_bActivateNightVision == true)
            R6Pawn(Owner).ToggleNightVision();
    }

    simulated function EndState()
    {
        if(bShowLog) log("HBS - EndState of RaiseWeapon for" @ self @ "=" @ m_bHeartBeatOn);
        Pawn(Owner).controller.m_bHideReticule = false;
        Pawn(Owner).controller.m_bLockWeaponActions = false;
        DisplayHeartBeat(true);
    }
}

state DiscardWeapon
{
    simulated function BeginState()
    {
		local Pawn aPawn;

        DisplayHeartBeat(false);
        if (bShowLog) log("HBS - BeginState of DiscardWeapon for" @ self @ "=" @ m_bHeartBeatOn);

        if(m_FPHands != none)
        {
			aPawn = Pawn(Owner);
			if(aPawn.controller != none)
            {
				aPawn.controller.m_bHideReticule = true;
				aPawn.controller.m_bLockWeaponActions = true;
			}
			m_FPHands.GotoState('DiscardWeapon');
        }
    }
    simulated function EndState()
    {
        if (bShowLog) log("IN:"@self@"::DiscardWeapon::EndState()");
    }
}

function StartLoopingAnims()
{
    if(m_FPHands != none)
    {
        m_FPHands.SetDrawType(DT_None);
        m_FPHands.GotoState('Waiting');
    }

    GotoState('');
}

state NormalFire
{
    simulated function BeginState()
    {
        GotoState('');
    }
}

defaultproperties
{
     m_sndActivation=Sound'Foley_HBSensor.Play_HBSensorAction1'
     m_sndDesactivation=Sound'Foley_HBSensor.Stop_HBSensorAction1'
     m_fMuzzleVelocity=1000.000000
     m_bHiddenWhenNotInUse=True
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripHBS'
     m_pFPWeaponClass=Class'R61stWeapons.R61stHBS'
     m_EquipSnd=Sound'Foley_HBSensor.Play_HBS_Equip'
     m_UnEquipSnd=Sound'Foley_HBSensor.Play_HBS_Unequip'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandHBS_nt"
     m_PawnWaitAnimHigh="StandHBS_nt"
     m_PawnWaitAnimProne="ProneHBS_nt"
     m_PawnFiringAnim="StandHBS"
     m_PawnFiringAnimProne="ProneHBS"
     m_AttachPoint="TagHBHand"
     m_HUDTexturePos=(W=32.000000,X=300.000000,Y=352.000000,Z=100.000000)
     m_NameID="HBSGadget"
     bCollideWorld=True
     DrawScale=1.100000
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensor'
}
