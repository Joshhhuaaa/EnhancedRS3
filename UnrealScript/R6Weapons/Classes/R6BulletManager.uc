//========================================================================================
//  R6BulletManager.uc :   Manage all bullets for one character.
//                         Bullets are spawned and managed here.
//                         There's one manager per character. 
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    06/07/2002 * Created by Joel Tremblay
//=============================================================================
class R6BulletManager extends R6AbstractBulletManager;

var INT     m_iCurrentBullet;
var INT     m_iBulletSpeed;
var INT     m_iBulletEnergy;

const           m_iNbBullets = 20;    // use this value instead of a hardcoded 20.
var R6Bullet    m_BulletArray[m_iNbBullets]; 
var INT     m_iNextBulletGroupID;

function InitBulletMgr(Pawn TheInstigator)
{
    //Init the bullet table.
    for(m_iCurrentBullet = 0; m_iCurrentBullet < m_iNbBullets; m_iCurrentBullet++)
    {
        m_BulletArray[m_iCurrentBullet] = Spawn(class'R6Bullet',,,,, true );
        m_BulletArray[m_iCurrentBullet].SetCollision(false, false, false);
        m_BulletArray[m_iCurrentBullet].Instigator = TheInstigator;
        m_BulletArray[m_iCurrentBullet].m_BulletManager = self;
    }
    m_iCurrentBullet = 0;
}

// bullet parameters are changed when changing weapon.  All bullets in the array will get the new parameters.
function SetBulletParameter( R6EngineWeapon aWeapon )
{
    local R6Weapons aR6Weapon;

    aR6Weapon = R6Weapons(aWeapon);

    if(aR6Weapon==none || aR6Weapon.m_pBulletClass==none)
        return;

    m_iBulletEnergy = aR6Weapon.m_pBulletClass.default.m_iEnergy;
    for(m_iCurrentBullet = 0; m_iCurrentBullet < m_iNbBullets; m_iCurrentBullet++)
    {
        m_BulletArray[m_iCurrentBullet].m_szBulletType          = aR6Weapon.m_pBulletClass.default.m_szBulletType;
        m_BulletArray[m_iCurrentBullet].m_iEnergy               = aR6Weapon.m_pBulletClass.default.m_iEnergy;
        m_BulletArray[m_iCurrentBullet].m_fKillStunTransfer     = aR6Weapon.m_pBulletClass.default.m_fKillStunTransfer;
        m_BulletArray[m_iCurrentBullet].m_fRangeConversionConst = aR6Weapon.m_pBulletClass.default.m_fRangeConversionConst;
        m_BulletArray[m_iCurrentBullet].m_fRange                = aR6Weapon.m_pBulletClass.default.m_fRange;
        m_BulletArray[m_iCurrentBullet].m_iPenetrationFactor    = aR6Weapon.m_pBulletClass.default.m_iPenetrationFactor;
    }
    m_iCurrentBullet = 0;
}

//TODO  Make a huge table and remove all AMMO* classes.

function SpawnBullet(vector vPosition, Rotator rRotation, float fBulletSpeed, BOOL bFirstInShell)
{
    //Reactivate the current bullet and give a direction
    if (bFirstInShell==true)
    {
        m_iNextBulletGroupID++;
    }

    m_BulletArray[m_iCurrentBullet].SetLocation(vPosition, true);
    m_BulletArray[m_iCurrentBullet].SetRotation(rRotation);
    m_BulletArray[m_iCurrentBullet].m_vSpawnedPosition = vPosition;
    m_BulletArray[m_iCurrentBullet].m_bBulletIsGone = TRUE;

    m_BulletArray[m_iCurrentBullet].SetSpeed(fBulletSpeed);
    m_BulletArray[m_iCurrentBullet].SetCollision(true, true, false);
    m_BulletArray[m_iCurrentBullet].SetPhysics(PHYS_Projectile);
    m_BulletArray[m_iCurrentBullet].bStasis = FALSE;
    m_BulletArray[m_iCurrentBullet].m_bBulletDeactivated = FALSE;

//    m_BulletArray[m_iCurrentBullet].m_bPlayBulletSound = bFirstInShell;
    m_BulletArray[m_iCurrentBullet].m_iBulletGroupID = m_iNextBulletGroupID;
    m_BulletArray[m_iCurrentBullet].m_AffectedActor = none;
    m_BulletArray[m_iCurrentBullet].m_iEnergy = m_iBulletEnergy;

    //Cycle through the list.
    m_iCurrentBullet++;
    if (m_iCurrentBullet == m_iNbBullets)
    {
        m_iCurrentBullet = 0;
    }

}

// returns true if actor has not been affected by the same bullet group
// also sets the bullet to the affected actor
function bool AffectActor(int BulletGroup, actor ActorAffected)
{
    local int iBulletIndex;
    local int iSaveBulletIndex;

    for (iBulletIndex = 0; iBulletIndex < m_iNbBullets; iBulletIndex++)
    {
        if (m_BulletArray[iBulletIndex].m_iBulletGroupID==BulletGroup)
        {
            if (m_BulletArray[iBulletIndex].m_AffectedActor == ActorAffected)
                return false;
            else if (m_BulletArray[iBulletIndex].m_AffectedActor == none)
                iSaveBulletIndex = iBulletIndex;
        }   
    }
    m_BulletArray[iSaveBulletIndex].m_AffectedActor = ActorAffected;
    return true;
}

simulated event Destroyed()
{
    local int i;
    local int iSaveBulletIndex;

    for (i = 0; i < m_iNbBullets; i++)
    {
        if(m_BulletArray[i] != none)
        {
            m_BulletArray[i].m_BulletManager = none;
            m_BulletArray[i].Destroy();
        }
    }            
}

defaultproperties
{
     RemoteRole=ROLE_None
     bHidden=True
}
