//=============================================================================
//  [R6HBSSAJammerGadget.uc] Heart Beat Sensor Stant Alone Jammer Gadget
//=============================================================================
class R6HBSSAJammerGadget extends R6DemolitionsGadget;

function Fire( FLOAT fValue )
{
    if(Pawn(Owner).controller.m_bLockWeaponActions == false)
        GotoState('ArmingCharge');
}


simulated function PlaceChargeAnimation()
{
	//R6Pawn(Owner).PlayClaymoreAnimation();
    ServerPlaceChargeAnimation();
}

function ServerPlaceChargeAnimation()
{
	R6Pawn(owner).SetNextPendingAction(PENDING_SetClaymore);
}

function SetAmmoStaticMesh()
{
    m_FPWeapon.m_smGun.SetStaticMesh( StaticMesh'R61stWeapons_SM.Items.R61stHBSSAJ' );
}

simulated function ServerPlaceCharge(vector vLocation)
{
	local  rotator		rDesiredRotation;
    local R6SAHeartBeatJammer aSAHeartBeatJammer;
    
    if(m_iNbBulletsInWeapon == 0)
        return;

	m_iNbBulletsInWeapon--;

    if (m_iNbBulletsInWeapon == 0)
        m_bHide = true;


	rDesiredRotation = Pawn(owner).GetViewRotation();
    if(bShowLog) log("aSAHeartBeatJammer :: ServerPlaceCharge() rDesiredRotation="$rDesiredRotation$" vLocation="$vLocation);
	rDesiredRotation.pitch = 0;
	rDesiredRotation.yaw += 32768;

    aSAHeartBeatJammer = Spawn( class'R6SAHeartBeatJammer' );
    aSAHeartBeatJammer.Instigator = none;
    aSAHeartBeatJammer.SetLocation(vLocation + vect(0,0,10));
	aSAHeartBeatJammer.SetRotation(rDesiredRotation);
    aSAHeartBeatJammer.SetSpeed(0);
}

state ArmingCharge
{
	function BeginState()	
	{
		if(bShowLog) log(self$" entered state ArmingCharge...");		
		// switch to charge static mesh
		SetStaticMesh(m_ChargeStaticMesh);
		Pawn(owner).AttachToBone(self, m_AttachPoint);
		
		m_bDetonated = FALSE;
		if(Pawn(Owner).Controller.bFire == 1)
			Fire(0);
	}

	function Timer()
	{
        local R6Pawn PawnOwner;
        PawnOwner = R6Pawn(Owner);

        if(!PawnOwner.m_bIsPlayer || PawnOwner.m_bPostureTransition || !m_bInstallingCharge)
    		return;		// was probably cancelled...

		if(bShowLog) log(self$" state ArmingCharge : Timer() has expired "$R6PlayerController(Pawn(Owner).controller).m_bPlacedExplosive);
        
        //Check here if the animation was started.  It might happend with network lag.
        if(R6PlayerController(Pawn(Owner).controller).m_bPlacedExplosive)
        {
		    ServerPlaceCharge(m_vLocation); 
		    m_bChargeInPosition = true;
		    m_bInstallingCharge = false;

            if (Level.NetMode == NM_Standalone || Level.NetMode == NM_ListenServer)
            {
                if(m_iNbBulletsInWeapon != 0)
                {
                    GotoState('GetNextCharge');
                }
                else
                {
                    GotoState('NoChargesLeft');
                }
            }
        }
    }

	function Fire( FLOAT fValue ) 
	{
        local R6PlayerController PlayerCtrl;
        PlayerCtrl = R6PlayerController(R6Pawn(Owner).controller);

        if(m_bChargeInPosition || !m_bCanPlaceCharge || (PlayerCtrl.m_bLockWeaponActions == true))
			return;
 
        if (m_SingleFireStereoSnd != None) 
        {
            Owner.PlaySound(m_SingleFireStereoSnd, SLOT_Guns);
        }
        PlayerCtrl.m_bLockWeaponActions = TRUE;
		// DROP! set location of remote charge (must be on ground)
		HideReticule();
		PlayerCtrl.GotoState('PlayerSetExplosive');		
		PlaceChargeAnimation();

		m_vLocation = PlayerCtrl.m_vDefaultLocation;

		SetTimer(0.1, true);  //check every 0.1 seconds if animation is over... // SetTimer(3, false);
        m_bInstallingCharge = true;
		if(m_FPHands != none)
			m_FPHands.GotoState('DiscardWeapon');
	}
    
    function FirstPersonAnimOver()
    {
        if(m_bCancelChargeInstallation == true)
        {
            m_bCancelChargeInstallation = false;
            Pawn(Owner).controller.m_bLockWeaponActions = FALSE;
        }
    }
}
state GetNextCharge
{
    function BeginState()
	{
		if(bShowLog) log(self$" state HBSAJ GetNextCharge : beginState() ");
		m_bChargeInPosition = false;
		m_bRaiseWeapon = false;
		SetTimer(0.1, true);  //check every 0.1 seconds if animation is over... // SetTimer(3, false);
        Pawn(Owner).controller.m_bLockWeaponActions = false;
        if(m_FPHands != none)
        {
			m_FPHands.GotoState('RaiseWeapon');
        }
        else
        {
            FirstPersonAnimOver();
        }

	}
    function FirstPersonAnimOver()
    {
		m_bRaiseWeapon = true;
    }

	function Timer()
    {
        if (!m_bRaiseWeapon)
            return;

        if (Pawn(Owner).Controller.bFire == 1)
            return;

        GotoState('ArmingCharge');
    }

}

state RaiseWeapon
{
    function FirstPersonAnimOver()
    {
        R6PlayerController(Pawn(Owner).controller).ServerWeaponUpAnimDone();
        GotoState('ArmingCharge');
    }

    simulated function BeginState()
    {

        if (bShowLog) log("WEAPON - BeginState of RaiseWeapon for "$self);
        if(m_FPHands != none)
        {
            m_FPHands.GotoState('RaiseWeapon');
            m_FPWeapon.m_smGun.bHidden = FALSE;
        }
        else
        {
            FirstPersonAnimOver();
        }
        Pawn(Owner).controller.m_bLockWeaponActions = true;
    }

    simulated function EndState()
    {
        Pawn(Owner).controller.m_bHideReticule = false;
        Pawn(Owner).controller.m_bLockWeaponActions = false;
    }

}
simulated event HideAttachment()
{
    GotoState('NoChargesLeft');
    Super.HideAttachment();
}

event NbBulletChange()
{
    if(m_iNbBulletsInWeapon > 0)
        GotoState('GetNextCharge');
    else
        GotoState('NoChargesLeft');
}


function BOOL CanSwitchToWeapon()
{
    if (m_iNbBulletsInWeapon > 0)
        return true;
    else
        return false;
}

state NoChargesLeft
{
	function BeginState()
	{
        local R6PlayerController PController;

		if(bShowLog) log(self$" HBSSAJammer state NoChargesLeft : BeginState()...");
		Pawn(Owner).controller.m_bHideReticule = TRUE;
        Pawn(Owner).controller.m_bLockWeaponActions = FALSE;

        PController = R6PlayerController(Pawn(Owner).controller);
        if(PController != none)
        {
            if(R6Pawn(Owner).m_WeaponsCarried[0] != none)
                PController.PrimaryWeapon();
            else
                PController.SecondaryWeapon();
        }
    }
}

defaultproperties
{
     m_ChargeStaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensorSA_Jamer'
     m_iClipCapacity=1
     m_fMuzzleVelocity=1000.000000
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripHBSSAJ'
     m_pFPWeaponClass=Class'R61stWeapons.R61stHBSSAJ'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandGrenade_nt"
     m_PawnWaitAnimHigh="StandGrenade_nt"
     m_PawnWaitAnimProne="ProneGrenade_nt"
     m_PawnFiringAnim="CrouchClaymore"
     m_PawnFiringAnimProne="ProneClaymore"
     m_AttachPoint="TagSAHBSensorJammer"
     m_HUDTexturePos=(W=32.000000,X=300.000000,Y=384.000000,Z=100.000000)
     m_NameID="HBSSAJammerGadget"
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensorSA_Jamer'
}
