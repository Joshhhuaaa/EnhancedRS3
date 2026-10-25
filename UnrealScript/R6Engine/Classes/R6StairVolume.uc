//=============================================================================
//  R6StairVolume.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//=============================================================================
class R6StairVolume extends PhysicsVolume
    native
	placeable;

var()	R6StairOrientation  m_pStairOrientation; 
var()   BOOL                m_bCreateIcon;
var()	BOOL				m_bRestrictedSpaceAtStairLimits;
var		vector              m_vOrientationNorm;
var		bool                m_bShowLog;
 
simulated function PostBeginPlay()
{
    if ( m_pStairOrientation == none )
        log( "WARNING: " $self$ " is missing m_pStairOrientation" );
    else
        m_vOrientationNorm = vector( m_pStairOrientation.Rotation );
}

simulated event PawnEnteredVolume(Pawn p)
{
	local R6Pawn thisPawn;
    
	thisPawn = R6Pawn(p);

    if(thisPawn == none)
        return;

    super.PawnEnteredVolume( p );

    if(!thisPawn.m_bIsClimbingStairs)
    {
        if( m_bShowLog ) log( "STAIR: enter" );

        thisPawn.m_bIsClimbingStairs = true;
        thisPawn.ClimbStairs(m_vOrientationNorm); 
    }
}

simulated event PawnLeavingVolume(Pawn p)
{  
	local R6Pawn thisPawn;
    local vector vDirection;

  	thisPawn = R6Pawn(p);
    if(thisPawn == none)
        return;

    super.PawnLeavingVolume( p );

    if( m_bShowLog ) log( "STAIR: leave" );

    
    if ( thisPawn.m_bIsClimbingStairs)
    {
        thisPawn.m_bIsClimbingStairs = false;
        thisPawn.EndClimbStairs();
    }
}

defaultproperties
{
     m_bCreateIcon=True
}
