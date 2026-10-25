class R6HBSJammerGadget extends R6Gadget;

var BOOL    m_bHeartBeatJammerOn;   //  Heart Beat Jammer ativated.


replication
{

    // function client asks server to do
	unreliable if (Role < ROLE_Authority)
		ServerToggleHeartBeatJammerProperties;
}

// ----------------------------------------
// All This function do nothing in the HBS
function Fire( FLOAT fValue ) {}
function StopFire(optional BOOL bSoundOnly) {}
function AltFire( FLOAT fValue ) {}
function StopAltFire() {}
// ----------------------------------------


function ServerToggleHeartBeatJammerProperties(BOOL bGadgetOn)
{
	if(bShowLog) log("HBJ - ServerToggleHeartBeatJammerProperties is "$bGadgetOn);
 	R6Pawn(Owner).m_bHBJammerOn = bGadgetOn;
}


// When the player change the weapon we have to desactivate the HBS
simulated function RemoveFirstPersonWeapon()
{
    super.RemoveFirstPersonWeapon();
    TurnOnGadget(false);
}

// When we change player in the team we have to desactivate or reactivate the HBS
simulated function BOOL LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
    super.LoadFirstPersonWeapon(NetOwner, LocalPlayerController);
    TurnOnGadget(m_bHeartBeatJammerOn);
    return true;
}

simulated function TurnOnGadget(BOOL bGadgetOn)
{
	if ((R6Pawn(Owner) == none) || (!R6Pawn(Owner).IsLocallyControlled()))
		return;
    m_bHeartBeatJammerOn=bGadgetOn;
    ServerToggleHeartBeatJammerProperties(bGadgetOn);
}

// Turn off the heart beat sensor
simulated function DisableWeaponOrGadget()
{
    TurnOnGadget(false);
}

// On the raise weapon we turn on the HeartBeat. At the end of the animation we can see the heartBeat.


state PutWeaponDown
{
    simulated function BeginState()
    {
        if(m_FPHands != none)
        {
            m_FPHands.GotoState('PutWeaponDown');
        }
        TurnOnGadget(false);
        if(bShowLog) log("HBSJammer - BeginState of PutWeaponDown for" @ self @ "=" @ m_bHeartBeatJammerOn);
        Pawn(Owner).controller.m_bLockWeaponActions = true;
    }
}

state BringWeaponUp
{
    function FirstPersonAnimOver()
    {
        GotoState('');
        TurnOnGadget(true);
        if(bShowLog) log("HBSJammer - FirstPersonAnimOver of BringWeaponUp for" @ self @ "=" @ m_bHeartBeatJammerOn);
    }
    simulated function EndState()
    {
        Pawn(Owner).controller.m_bLockWeaponActions = false;
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
    function BeginState()
    {
        Pawn(Owner).controller.m_bLockWeaponActions = true;
        m_FPHands.GotoState('RaiseWeapon');
    }

    simulated function EndState()
    {
        Pawn(Owner).controller.m_bHideReticule = false;
        Pawn(Owner).controller.m_bLockWeaponActions = false;

        TurnOnGadget(true);
    }
}

state DiscardWeapon
{
    simulated function BeginState()
    {

        TurnOnGadget(false);
        if (bShowLog) log("HBSJammer - BeginState of DiscardWeapon for" @ self @ "=" @ m_bHeartBeatJammerOn);

        if(m_FPHands != none)
        {
            Pawn(Owner).controller.m_bLockWeaponActions = true;
            Pawn(Owner).controller.m_bHideReticule = true;

            m_FPHands.GotoState('DiscardWeapon');
        }
    }
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
     m_fMuzzleVelocity=1000.000000
     m_szReticuleClass="DOT"
     m_bHiddenWhenNotInUse=True
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripHBSJ'
     m_pFPWeaponClass=Class'R61stWeapons.R61stHBSJ'
     m_EquipSnd=Sound'Foley_HBSJammer.Play_HBSJ_Equip'
     m_UnEquipSnd=Sound'Foley_HBSJammer.Play_HBSJ_Unequip'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandHandGunLow_nt"
     m_PawnWaitAnimHigh="StandHandGunHigh_nt"
     m_PawnWaitAnimProne="ProneHandGun_nt"
     m_AttachPoint="TagHBSJammer"
     m_HUDTexturePos=(W=32.000000,X=400.000000,Y=384.000000,Z=100.000000)
     m_NameID="HBSJammerGadget"
     bCollideWorld=True
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensor_Jamer'
}
