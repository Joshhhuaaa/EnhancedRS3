//===============================================================================
//  [R61stHandsShotgunSPAS12]   
//===============================================================================

class R61stHandsShotgunSPAS12 extends R61stHandsShotgunM1;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsShotgunSPAS12A');
    Super.PostBeginPlay();
}

state Reloading
{
    function EndState()
    {
        //log("SHOTGUN SPAS12 - Leaving State Reloading");
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
                if((R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading == 1) && 
                   (R6AbstractWeapon(Owner).GetNbOfClips() != 0) && 
                   !R6AbstractWeapon(Owner).GunIsFull())
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
                if (m_bReloadEmpty == true)
                {
                    m_bReloadEmpty = false;

                    R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
                    if(Level.NetMode == NM_Client)
                    {
                        R6AbstractWeapon(Owner).ClientAddShell();
                    }

                    if((R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading == 1) && 
                       (R6AbstractWeapon(Owner).GetNbOfClips() != 0))
                    {
                        PlayAnim('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                        m_bReloadCycle=true;
                        return;
                    }
                }
                // returning to normal state
                m_bReloadCycle = false;
                LoopAnim('Wait_c');
                Gotostate('Waiting');
                R6AbstractWeapon(Owner).FirstPersonAnimOver();
            }
        }
    }

    simulated function BeginState()
    {
        //log("SPAS12 - Begin State Reloading");
        if(m_bReloadEmpty == true)
        {
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_ReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
            PlayAnim('ReloadEmpty', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
            m_bReloadEmpty = true;
        }
        else
        {
            PlayAnim('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
            m_bReloadCycle=true;
        }
    }
}

defaultproperties
{
}
