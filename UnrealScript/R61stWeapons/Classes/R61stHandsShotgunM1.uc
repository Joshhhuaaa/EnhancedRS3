//===============================================================================
//  [R61stHandsShotgunM1]   
//===============================================================================

class R61stHandsShotgunM1 extends R61stHandsGripShotgun;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

var BOOL m_bReloadCycle;
var BOOL m_bPlayedEnd;     //To play Reload_e on reload empty 

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsShotgunM1A');
    Super.PostBeginPlay();
}


state Reloading
{
    function EndState()
    {
        //log("SHOTGUN M1 - Leaving State Reloading");
    }
    simulated event AnimEnd(int Channel)
    {
        //this event is called only in FirstPerson
        if(Channel == 0)
        {
            if(m_bReloadCycle == true)
            {
                R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
                if(Level.NetMode == NM_Client)
                {
                    R6AbstractWeapon(Owner).ClientAddShell();
                }

                //Owner is weapon, his owner is the pawn
                if( (R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading == 1) && 
                    (R6AbstractWeapon(Owner).GetNbOfClips() > 0) && 
                    (!R6AbstractWeapon(Owner).GunIsFull()))
                {
                    R6Pawn(Owner.Owner).ServerPlayReloadAnimAgain();
                    PlayAnim('Reload_c', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                }
                else
                {
                    PlayAnim('Reload_e', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                    m_bReloadCycle = false;
                }
            }
            else
            {
                if(m_bReloadEmpty == true)
                {
                    if(m_bPlayedEnd == false)
                    {
                        R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
                        if(Level.NetMode == NM_Client)
                        {
                            R6AbstractWeapon(Owner).ClientAddShell();
                        }

                        PlayAnim('Reload_e', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                        m_bPlayedEnd = true;
                    }
                    else
                    {
                        AssociatedWeapon.PlayAnim(AssociatedWeapon.m_ReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                        PlayAnim('ReloadEmpty', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                        m_bReloadEmpty = false;
                    }
                }
                else
                {
                    if( (R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading == 1) && 
                        (R6AbstractWeapon(Owner).GetNbOfClips() > 0) && 
                        (!R6AbstractWeapon(Owner).GunIsFull()))
                    {
                        PlayAnim('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                        m_bReloadCycle=true;                        
                    }
                    else
                    {
                        // returning to normal state
                        LoopAnim('Wait_c');
                        Gotostate('Waiting');
                        R6AbstractWeapon(Owner).FirstPersonAnimOver();
                    }
                }
            }
        }
    }

    simulated function BeginState()
    {
        //log("HANDS - Begin State Reloading");
        PlayAnim('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
        if(m_bReloadEmpty == false)
        {
            m_bReloadCycle=true;
        }
        else
        {
            m_bPlayedEnd = false;
        }
    }
}

defaultproperties
{
}
