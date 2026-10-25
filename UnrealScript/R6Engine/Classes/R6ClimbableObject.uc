//------------------------------------------------------------------
// R6ClimbableObject: an object that can be climbed by pawn.
//	An R6ClimbableObject as an orientation that shows the
//  direction of the climbing. They are meant to be used to climb
//  and then go on another box/level/new edge. I have not tested
//  the code when the R6ClimbableObject is placed alone. To use
//  those kind
//------------------------------------------------------------------
class R6ClimbableObject extends R6AbstractClimbableObj
    native
    ; //placeable; // R6CLIMBABLEOBJECT

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons

enum EClimbHeight 
{
    EClimbNone,
    EClimb64,
    EClimb96,
};

var              vector              m_vClimbDir;
var              R6ClimbablePoint    m_climbablePoint;
var              R6ClimbablePoint    m_insideClimbablePoint;
var(Collision)   EClimbHeight        m_eClimbHeight;

replication
{
    // data server sends to client
    unreliable if (bNetInitial && Role == ROLE_Authority)
        m_vClimbDir, m_climbablePoint, m_eClimbHeight;
}

enum eClimbableObjectCircumstantialAction
{
    COBJ_None,
    COBJ_Climb
};

function PostBeginPlay()
{
	Super.PostBeginPlay();
    m_vClimbDir = vector(Rotation);
    m_vClimbDir = normal(m_vClimbDir);
}

simulated function bool IsClimbableBy( R6pawn p, bool bCheckCylinderTranslation, bool bCheckRotation )
{
    local   rotator rPawnRot;
    local   float fFootZ;
    local   float fDistance2d;
    local   vector vStart, vDest;
    local   vector vPawnLocation;
   
    // if prone or if he's climbing
    if ( p.m_bIsProne || p.m_climbObject != none )
    {
        //log( p.name$ " 1- if prone or if he's climbing" );
        return false;
    }

    fFootZ = p.location.Z - p.CollisionHeight;
    // if the foot are not inbetween the location of ClimbObj and the floor
    if ( !(fFootZ <= location.Z && location.Z - CollisionHeight <= fFootZ) )
    {
        //log( p.name$ " 2- footZ" );
        return false;
    }

	rPawnRot = p.rotation;
	rPawnRot.pitch = 0;
    
    // check angle
	if ( bCheckRotation && vector(rPawnRot) dot m_vClimbDir < 0) 
    {
        //log( p.name$ " 3- rotation" );
        return false;
    }
    else
    {
        vPawnLocation = p.Location;
        vPawnLocation.Z = Location.Z;

        fDistance2d = VSize(vPawnLocation - Location ) - CollisionRadius - p.CollisionRadius;
        
        // check if minimum distance 
        if ( fDistance2d > m_fCircumstantialActionRange )
        {
            //log( p.name$ " 4- distance" );
            return false;
        }
        // check if enough space for the collision cylinder 
        else if ( bCheckCylinderTranslation )
        {
            // *1.9 instead of 2: more sensible to circumtantial action activation
            vDest = p.Location + vector( rPawnRot )*p.collisionRadius*1.9; 
            vDest.Z += CollisionHeight*2;

            vStart = p.Location;
            vStart.Z = vDest.Z;
            
            if ( !p.CheckCylinderTranslation( vStart, vDest, self ) )
            {
                //log( p.name$ " 5- CylinderTranslation" );
                return false;
            }
        }
    }
    
    return true;
}

event Bump( Actor Other )
{
    local r6pawn p;

    p = R6Pawn(Other);
    
    if ( p == none )
        return;

    
    if ( p.m_bIsPlayer )
        return; // human player, return. they use the circumstantial action.

    // log( p.name$ " bump" );
    
    if ( p.controller != none &&
         R6AIController(p.controller).CanClimbObject() &&
         IsClimbableBy( p, false, false )  && // don't check cylinder and don't check rotation
         !p.controller.IsInState( 'ClimbObject' ) ) // no already tring to climb
    {
        p.StartClimbObject( self );
    }
}

simulated event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    local R6Pawn p;
    p = r6pawn(playerController.pawn);
    
    Query.iHasAction = 1; 
  
    // not prone, in range and climbable?
    if( IsClimbableBy( p, true, true ) )
    {
        Query.iInRange = 1;
        p.PotentialClimbableObject( self );
    }
    else
    {
        Query.iInRange = 0;
        p.RemovePotentialClimbableObject( self );
    }

    Query.textureIcon = Texture'R6ActionIcons.ClimbObject';

    Query.iPlayerActionID      = eClimbableObjectCircumstantialAction.COBJ_Climb;
    Query.iTeamActionID        = eClimbableObjectCircumstantialAction.COBJ_None;
    Query.iTeamActionIDList[0] = eClimbableObjectCircumstantialAction.COBJ_None;
    Query.iTeamActionIDList[1] = eClimbableObjectCircumstantialAction.COBJ_None;
    Query.iTeamActionIDList[2] = eClimbableObjectCircumstantialAction.COBJ_None;
    Query.iTeamActionIDList[3] = eClimbableObjectCircumstantialAction.COBJ_None;
}

simulated function string R6GetCircumstantialActionString( INT iAction )
{
    switch( iAction )
    {
		case eClimbableObjectCircumstantialAction.COBJ_Climb:	return Localize("RDVOrder", "Order_Climb", "R6Menu");
    }

    return "";
}

event Attach( Actor pActor )
{
    local R6Pawn pPawn;

    pPawn = R6Pawn(pActor);
    if(pPawn!=none)
    {
        pPawn.AttachToClimbableObject(Self);
    }
}

event Detach( Actor pActor )
{
    local R6Pawn pPawn;

    pPawn = R6Pawn(pActor);
    if(pPawn!=none)
    {
        pPawn.DetachFromClimbableObject(Self);
    }
}

defaultproperties
{
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bDirectional=True
     bObsolete=True
     CollisionRadius=40.000000
     CollisionHeight=32.000000
     m_fCircumstantialActionRange=30.000000
}
