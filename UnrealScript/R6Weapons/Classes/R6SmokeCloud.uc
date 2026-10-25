//=============================================================================
//  R6SmokeCloud.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/06 * Created by Guillaume Borgia
//=============================================================================
class R6SmokeCloud extends Actor
    native;

var R6Grenade m_grenade;
var FLOAT     m_fStartTime;
var FLOAT     m_fExpansionTime;       // Time needed to reach maximum radius
var FLOAT     m_fFinalRadius;
var FLOAT     m_fCurrentRadius;


//============================================================================
// SetCloud - 
//============================================================================
function SetCloud( R6Grenade aGrenade, FLOAT fExpansionTime, FLOAT fFinalRadius, FLOAT fDuration )
{
    m_grenade = aGrenade;
    m_fExpansionTime = fExpansionTime;
    m_fFinalRadius = fFinalRadius;
    LifeSpan = fDuration;

    m_fStartTime = Level.TimeSeconds;
    Instigator = none;
    SetTimer( 0.25f, true );
}

//============================================================================
// Timer - 
//============================================================================
event Timer()
{
    local FLOAT fElapsedTime;
    
    fElapsedTime = Level.TimeSeconds - m_fStartTime;

    if( m_grenade != none && m_grenade.Physics != PHYS_None)
        SetLocation( m_grenade.Location + vect(0,0,125) );

    if( fElapsedTime < m_fExpansionTime )
    {
        m_fCurrentRadius = fElapsedTime/m_fExpansionTime * m_fFinalRadius;
    }
    else
    {
        m_fCurrentRadius = m_fFinalRadius;
        SetTimer(0, false);
    }

    SetCollisionSize( m_fCurrentRadius, CollisionHeight );
}

defaultproperties
{
     RemoteRole=ROLE_None
     DrawType=DT_None
     m_bDeleteOnReset=True
     bCollideActors=True
     CollisionRadius=10.000000
     CollisionHeight=125.000000
}
