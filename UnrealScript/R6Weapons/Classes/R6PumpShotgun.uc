//============================================================================//
//  R6Shotgun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6PumpShotgun extends R6Shotgun
    Abstract;

simulated function BOOL GunIsFull()
{
    return m_iNbBulletsInWeapon >= m_iClipCapacity;
}

simulated function BOOL IsPumpShotGun()
{
    // This function is only used to check if the weapon has shells instead of magazines.
    // USAS is a shotgun, but must be excluded in this check
    return TRUE;
}

//Function called only on client, Add a shell before it's replicated.
//To fix a problem with reload animations and network lag.
function ClientAddShell()
{
    m_iNbBulletsInWeapon++;
	if(Level.NetMode == NM_Client) //only on clients, not listen or stand alone
	{
		m_iCurrentNbOfClips--;
	}
}

simulated function AddClips(INT iNbOfExtraClips)
{
    m_iCurrentNbOfClips += iNbOfExtraClips;

    if(Level.NetMode == NM_Client)  //only client call this on a server
    {
        ServerAddClips();
    }
}

function ServerPutBulletInShotgun()
{
    if (!GunIsFull())
    {
        m_iNbBulletsInWeapon++;

        if(!m_bUnlimitedClip)
        {
            m_iCurrentNbOfClips--;
        }

        if (m_ReloadSnd != None) // else at least, play the normal reload
        {
            Owner.PlaySound(m_ReloadSnd);
        }
    }
}


state Reloading
{
    function FirstPersonAnimOver()
    {
        //this event is called only in FirstPerson
        if (bShowLog) log("SHOTGUN - FPAOver");
        
        if(Pawn(Owner).Controller.bFire == 1)
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }
    
	simulated function ChangeClip()
	{
        if (bShowLog) log("SHOTGUN - ChangeClip");
        ServerPutBulletInShotgun();
    }

    function EndState()
    {
        local R6Pawn PawnOwner;
        local R6PlayerController PlayerCtrl;
        PawnOwner = R6Pawn(Owner);
        PlayerCtrl = R6PlayerController(PawnOwner.controller);

		if (bShowLog) log("SHOTGUN - Leaving State Reloading");
        // Reset the reloading flag!.
        PawnOwner.ServerSwitchReloadingWeapon(FALSE);
        if(PlayerCtrl != none)
        {
            PlayerCtrl.m_iPlayerCAProgress = 0;
            PlayerCtrl.m_bLockWeaponActions = FALSE;
            PlayerCtrl.m_bHideReticule = FALSE;
        }
    }
    simulated function BeginState()
    {
        local R6Pawn PawnOwner;
        local R6PlayerController PlayerCtrl;
        PawnOwner = R6Pawn(Owner);
        PlayerCtrl = R6PlayerController(PawnOwner.controller);
            
        if (bShowLog) log("SHOTGUN - Begin State Reloading! "$GetNbOfClips() );
		
        // We must have at least 1 bullet to be able to reload
        if ((GetNbOfClips() > 0) && !GunIsFull())
        {
            if(PlayerCtrl != none && !PlayerCtrl.m_bWantTriggerLag)
                ClientStartChangeClip();
            ServerStartChangeClip();

            if (PawnOwner.m_bIsPlayer)
            {
                if(PlayerCtrl != None && PlayerCtrl.bBehindView == FALSE)
                {
                    //No shells left in the gun
                    if(m_iNbBulletsInWeapon == 0)
                    {
                        m_FPHands.m_bReloadEmpty = true;
                    }

                    m_FPHands.GotoState('Reloading');
                    PlayerCtrl.m_iPlayerCAProgress = 0;
                    PlayerCtrl.m_bHideReticule = TRUE;
                    PlayerCtrl.m_bLockWeaponActions = TRUE;
                }
            }
        }
        else
        {
            GotoState('');
        }
    }

    function INT GetReloadProgress()
	{
		local name  anim;
		local FLOAT fFrame,fRate;
		
		m_FPHands.GetAnimParams(0, anim, fFrame, fRate);	
        if(anim != 'Reload_e')
        {
		    return fFrame*110;
        }
        else
        {
            return 0;
        }
	}

	event Tick(FLOAT fDeltaTime)
	{
        local R6PlayerController PlayerCtrl;
        PlayerCtrl = R6PlayerController(R6Pawn(Owner).controller);
        
        if((PlayerCtrl != none) && (PlayerCtrl.m_bUseFirstPersonWeapon == false))
		    PlayerCtrl.m_iPlayerCAProgress = GetReloadProgress();
	}
}

state NormalFire
{
    function Fire( float Value ){}  //do not allow to shoot until the gun is puped back
    function EndState()
    {
        Pawn(Owner).ServerFinishShotgunAnimation();
        Super.EndState();
    }
}

defaultproperties
{
     m_PawnReloadAnim="StandReloadEmptyShotGun"
     m_PawnReloadAnimTactical="StandReloadShotGun"
     m_PawnReloadAnimProne="ProneReloadEmptyShotGun"
     m_PawnReloadAnimProneTactical="ProneReloadShotGun"
}
