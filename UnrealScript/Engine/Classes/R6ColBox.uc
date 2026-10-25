//=============================================================================
//  R6ColBox.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6ColBox extends Actor
    notplaceable
    native;

var bool       m_bActive; // true when colliding, cannot be replaced by bCollideWorld/bCollideActor
var bool       m_bCheckForEdges;        // check for edges (not when peeking)
var bool       m_bCanStepUp;            // when prone, will try to step up/down
var bool       m_bCollisionDetected;    // true when collide with something for a tick. 
var float      m_fFeetColBoxRadius;    

//#ifdef R6CODE - pgaron 27 jan 2002
native(1503) final function EnableCollision( bool bEnable, OPTIONAL bool bCheckForEdges, OPTIONAL bool bCanStepUp ); 
//#endif

replication 
{
    // insure that data is rep from owner of this pawn to the server || server sends the data to the non owners of this pawn    
    reliable if ((bNetOwner && (Role<ROLE_Authority)) || (!bNetOwner && (Role==ROLE_Authority)))
        m_bActive;

    // data server sends to client
    reliable if (Role == ROLE_Authority )
        m_fFeetColBoxRadius;
}

function logC( string s )
{
 	local string time;
    local name baseName;

    if ( Base != none )
    {
        baseName = Base.name;
    }

    time = string(Level.TimeSeconds);
	time = Left(Time, InStr(Time, ".") + 3); // 2 digits after the dot

    log( "[" $time$ "] COL BOX ("$baseName$"): " $s );
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    Base.Trigger( Other, EventInstigator );
}

event UnTrigger( Actor Other, Pawn EventInstigator )
{
    Base.UnTrigger( Other, EventInstigator );
}


event HitWall( vector HitNormal, actor HitWall )
{
    // logC( "hitWall" );

    if ( Pawn(Base) != none )
        Pawn(Base).controller.HitWall( HitNormal, HitWall );
}

event Touch( Actor Other )
{
    // logC( "touching " $Other.name );

    if ( Base != none ) 
        Base.touch( Other );
}
event PostTouch( Actor Other )
{
    Base.PostTouch( Other );
}
event UnTouch( Actor Other )
{
    if ( Base != none ) 
        Base.UnTouch( Other );
}

event Bump( Actor Other )
{
    // logC( "bumped " $Other.name );

    if ( Pawn(Base) != none )
    {
        Pawn(Base).controller.NotifyBump( Other );
    }

}
      
event bool EncroachingOn( actor Other )
{
    // logC( "EncroachingOn: " $Other.name );

    return Base.EncroachingOn(Other);
}

event EncroachedBy( actor Other )
{
    // logC( "EncroachedBy: " $Other.name );

    Base.EncroachedBy(Other);
}

event BaseChange()
{
    // logC( "BaseChange" );
}

function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy, 
						   vector vHitLocation, vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
{
    // logC( "R6TakeDamage" );

    return Base.R6TakeDamage( iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);
}

event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    Query.aQueryTarget = Base;
    // redirect the call
    Base.R6QueryCircumstantialAction( fDistance, Query, playerController );
}

simulated event Destroyed()
{
    EnableCollision( false );
    
    Super.Destroyed();
}

simulated event bool GetReticuleInfo( Pawn ownerReticule, OUT string szName ) 
{
    return Base.GetReticuleInfo( ownerReticule, szName );
}

defaultproperties
{
     DrawType=DT_None
     bHidden=True
     m_bReticuleInfo=True
     bBlockActors=True
     bBlockPlayers=True
     CollisionRadius=10.000000
     CollisionHeight=10.000000
}
