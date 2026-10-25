//=============================================================================
//  R6LadderVolume.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/07/11 * Created by Rima Brek
//=============================================================================
class R6LadderVolume extends LadderVolume
	native;

#exec OBJ LOAD FILE=..\Textures\R6Engine_T.utx PACKAGE=R6Engine_T
// R6CIRCUMSTANTIALACTION
#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
// R6CIRCUMSTANTIALACTION

var			 R6Ladder		m_TopLadder;
var			 R6Ladder		m_BottomLadder;

var			 R6LadderCollision	m_TopCollision;
var			 R6LadderCollision	m_BottomCollision;

const		 C_iMaxClimbers = 6;
var			 R6Pawn			m_Climber[C_iMaxClimbers];		// support up to 6 pawn on a ladder at once...

var(R6Sound) Sound          m_SlideSound;
var(R6Sound) Sound          m_SlideSoundStop;
var(R6Sound) Sound          m_HandSound;
var(R6Sound) Sound          m_FootSound;

var			 FLOAT			m_fBottomLadderActionRange;

var(Debug)   bool			bShowLog;

var() enum  eLadderEndDirection   // only for getting off at top of ladder...
{
    LDR_Forward,
    LDR_Right,
    LDR_Left
} m_eLadderEndDirection;

enum eLadderCircumstantialAction
{
    CAL_None,
    CAL_Climb,
};

// redefined PostBeginPlay() so that it is simulated 
// (will be executed on the client as well during a multiplayer game)
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PostNetBeginPlay();
}
 
simulated function PostNetBeginPlay()
{
	local Ladder L, M;
	local vector vDir;

	if(LadderList == None)
	{
		log("WARNING - no Ladder actors in LadderVolume "$self);
		return;
	}

	LookDir = vector(LadderList.Rotation);
    WallDir = rotator(LookDir);

	if(!bAutoPath)
	{
		ClimbDir = vect(0,0,0);
		for(L=LadderList; L!=None; L=L.LadderList)
        {
            for(M=LadderList; M!=None; M=M.LadderList)
            {
                if(M!=L)
				{
					vDir = Normal(M.Location - L.Location);
					if((vDir dot ClimbDir) < 0)
                    {
                        vDir *= -1;
                    }
					ClimbDir += vDir;

                    if(M.location.z > L.location.z)
                    {
                        m_TopLadder = R6Ladder(M);
                        m_BottomLadder = R6Ladder(L);
                    }
                    else
                    {
                        m_TopLadder = R6Ladder(L);
                        m_BottomLadder = R6Ladder(M);
                    }
				}
            }
        }

		ClimbDir = Normal(ClimbDir);
		if((ClimbDir Dot vect(0,0,1)) < 0)
        {
            ClimbDir *= -1;
        }
	}
    climbDir.x = 0;
    climbDir.y = 0;

	// rbrek 7 sept 2002
	// Spawn ladder collision actors to be used for controlling access to ladders.  While Player A is getting on a ladder
	// the appropriate R6LadderCollision actor will become blocking and therefore ensure that Player B can't get in the 
	// way of Player A while in the process of getting on the ladder.
	if(Level.NetMode != NM_Client)
	{
		if(m_TopCollision == none)
		{
			m_TopCollision = Spawn(class'R6LadderCollision', self,, m_TopLadder.location - vect(0,0,239), rot(0,0,0));
			m_TopCollision.SetCollision(false,false,false);
		}

		if(m_BottomCollision == none)
		{
			m_BottomCollision = Spawn(class'R6LadderCollision', self,, m_BottomLadder.location + vect(0,0,199), rot(0,0,0));
			m_BottomCollision.SetCollision(false,false,false);
		}
	}
}

function Destroyed()
{
	if(m_TopCollision != none)
	{
		m_TopCollision.Destroy();
		m_TopCollision = none;
	}

	if(m_BottomCollision != none)
	{
		m_BottomCollision.Destroy();
		m_BottomCollision = none;
	}
}

simulated function ResetOriginalData()
{
	local INT i;

	if(m_TopCollision != none)
		m_TopCollision.SetCollision(false,false,false);
	if(m_BottomCollision != none)
		m_BottomCollision.SetCollision(false,false,false);

	for(i=0; i<C_iMaxClimbers; i++)
		m_Climber[i] = none;
}

function EnableCollisions(R6Ladder ladder)
{
	if(ladder == m_TopLadder)
		m_TopCollision.SetCollision(true,true,true);
	else
		m_BottomCollision.SetCollision(true,true,true);
}

function DisableCollisions(R6Ladder ladder)
{
	if(ladder == m_TopLadder)
		m_TopCollision.SetCollision(false,false,false);
	else
		m_BottomCollision.SetCollision(false,false,false);
}

simulated event PawnEnteredVolume(Pawn p)
{
	local R6Pawn pawn;
	local rotator rPawnRot;

	pawn = R6Pawn(p);

	if ((pawn == none) || !pawn.bCanClimbLadders || (pawn.controller == None))
		return;

	if (p.IsPlayerPawn())                 // call to super.pawnenteredvolume()
		TriggerEvent(Event, p, p);

	rPawnRot = pawn.rotation;
	rPawnRot.pitch = 0;

	if(vector(rPawnRot) dot lookDir > 0.9)
    {
		if(pawn.m_bIsClimbingLadder)
			return;
        pawn.PotentialClimbLadder(self);
    }
    else
    {
        SetPotentialClimber();  // so that pawn can enter the volume without having the right orientation, and can then turn to face ladder...        
    }
}

simulated event PawnLeavingVolume(Pawn p)
{
	if (p.IsPlayerPawn())
		UntriggerEvent(Event, p, p);

    if(p.physics == PHYS_Ladder)
    {
        p.EndClimbLadder(self);
    }
    else
    {
        R6Pawn(p).RemovePotentialClimbLadder(self);
    }
}

simulated event SetPotentialClimber()
{
	GotoState('PotentialClimb');
}

state PotentialClimb
{  
	simulated function Tick(float fDeltaTime)
	{
		local rotator rPawnRot;
		local R6Pawn pawn;
		local bool bFound;

		ForEach TouchingActors(class'R6Pawn', pawn)
			if ( (pawn.controller != None) && (pawn.physics != PHYS_Ladder) )				
			{
                if(Encompasses(pawn))
                {
				    rPawnRot = pawn.rotation;
				    rPawnRot.pitch = 0;
				    if ( (vector(rPawnRot) Dot lookDir) > 0.9 )
                    {
						if(!pawn.m_bIsClimbingLadder)
						{
							pawn.PotentialClimbLadder(self);
						}
                    }
				    else
                        bFound = true;
                }
			}

		if ( !bFound )
			GotoState('');
	}
}

simulated function AddClimber(R6Pawn p)
{
	local INT i;

	if(bShowLog) log(self$" AddClimber : "$p);	
	for(i=0; i<C_iMaxClimbers; i++)
	{
		if(m_Climber[i] == p)
			break;

		if(m_Climber[i] == none)
		{
			m_Climber[i] = p;
			break;
		}
	}
}

simulated function RemoveClimber(R6Pawn p)
{
	local INT i;

	if(bShowLog) log(self$" Remove Climber : "$p);
	for(i=0; i<C_iMaxClimbers; i++)
	{
		if(m_Climber[i] == p)
		{
			m_Climber[i] = none;
			break;
		}
	}
}

function bool IsAvailable( Pawn p )
{
	local INT i;
	
	for(i=0; i<C_iMaxClimbers; i++)
	{
		if(m_Climber[i] != none)
		{
			if(!m_Climber[i].IsValidClimber())
			{
				m_Climber[i] = none;
				continue;
			}

			if(m_Climber[i] != p)
				return false;
		}
	}
	return true;
}

function bool TopOfLadderIsAccessible()
{
	local FLOAT		fTopZLimit;
	local INT		i;

	fTopZLimit = m_TopLadder.location.z - 240.f;
	for(i=0; i<C_iMaxClimbers; i++)
	{
		if(m_Climber[i] == none)
			continue;

		if(!m_Climber[i].IsValidClimber())
		{
			m_Climber[i] = none;
			continue;
		}

		if(m_Climber[i].location.z + m_Climber[i].CollisionHeight > fTopZLimit)
			return false;
	}	
	return true;
}

function bool BottomOfLadderIsAccessible()
{
	local FLOAT		fBottomZLimit;
	local INT		i;

	fBottomZLimit = m_BottomLadder.location.z + 200.f;
	for(i=0; i<C_iMaxClimbers; i++)
	{
		if(m_Climber[i] == none)
			continue;

		if(!m_Climber[i].IsValidClimber())
		{
			m_Climber[i] = none;
			continue;
		}

		if(m_Climber[i].location.z - m_Climber[i].CollisionHeight < fBottomZLimit)
			return false;
	}	
	return true;
}

function bool SpaceIsAvailableAtBottomOfLadder(optional bool bAvoidPlayerOnly)
{
	local R6Pawn pawn;
	local vector vDist;	
	
	ForEach TouchingActors(class'R6Pawn', pawn)
	{
		if(!pawn.IsAlive())
			continue;

		if(bAvoidPlayerOnly && !pawn.m_bIsPlayer)
			continue;
		
		if(abs(pawn.location.z - m_BottomLadder.location.z) > 100)
			continue;

		vDist = pawn.location - m_BottomLadder.location;
		vDist.z = 0;
		if(VSize(vDist) < 90)
			return false;
	}
	return true;
}

function bool IsAShortLadder()
{
	if((m_TopLadder.location.z - m_BottomLadder.location.z) < 340)
		return true;

	return false;
}

simulated event PhysicsChangedFor(Actor Other)
{
}

simulated event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{ 
	local  FLOAT	fXYDistance;
	local  vector	vLocation, vPawnLocation;
	local  FLOAT	fResult;
	local  FLOAT	fPawnFootZ;

	if(R6Pawn(playerController.pawn).m_bIsClimbingLadder || (IsAShortLadder() && !IsAvailable(playerController.pawn)))
	{
		Query.iHasAction = 0;
		return;
	}

	vLocation = Location;
	vLocation.z = 0;
	vPawnLocation = playerController.pawn.location;
	vPawnLocation.z = 0;

	fXYDistance = VSize(vLocation - vPawnLocation);
    Query.iHasAction = 1;
	
	fPawnFootZ = playerController.pawn.location.z - playerController.pawn.collisionHeight;
	if(playerController.pawn.location.z < location.z)
	{
		// player is at the bottom of the ladder
		if(fPawnFootZ > m_BottomLadder.location.z)
			Query.iInRange = 0;
		else
		{
			fResult = vector(playerController.pawn.rotation) dot vector(m_BottomLadder.rotation);
			if(fResult < 0.8)
				Query.iInRange = 0;
			else
			{
				if(fXYDistance < m_fBottomLadderActionRange)
				{
					Query.iInRange = 1;
					if(!BottomOfLadderIsAccessible())
					{
						Query.iHasAction = 0;
						return;
					}
				}	
				else
					Query.iInRange = 0;
			}
		}
	}
	else
	{	
		// player is at the top of the ladder
		if(fPawnFootZ > m_TopLadder.location.z)
			Query.iInRange = 0;
		else
		{
			fResult = vector(playerController.pawn.rotation) dot -vector(m_TopLadder.rotation);
			if(fResult < 0.9)
				Query.iInRange = 0;
			else
			{
				if(fXYDistance < m_fCircumstantialActionRange)
				{
					Query.iInRange = 1;
					if(!TopOfLadderIsAccessible())
					{
						Query.iHasAction = 0;
						return;
					}
					
					if(IsAShortLadder())
					{
						// check if some one is standing too close to the ladder (even if they are not climbing)
						if(!SpaceIsAvailableAtBottomOfLadder())
						{
							Query.iHasAction = 0;
							return;
						}
					}
				}
				else
					Query.iInRange = 0;
			}
		}
	}
	Query.textureIcon = Texture'R6ActionIcons.Climb';		
    
    Query.iPlayerActionID      = eLadderCircumstantialAction.CAL_Climb;
    Query.iTeamActionID        = eLadderCircumstantialAction.CAL_Climb;
    
    Query.iTeamActionIDList[0] = eLadderCircumstantialAction.CAL_Climb;
    Query.iTeamActionIDList[1] = eLadderCircumstantialAction.CAL_None;
    Query.iTeamActionIDList[2] = eLadderCircumstantialAction.CAL_None;
    Query.iTeamActionIDList[3] = eLadderCircumstantialAction.CAL_None;
}

simulated function string R6GetCircumstantialActionString( INT iAction )
{
    switch( iAction )
    {
        case eLadderCircumstantialAction.CAL_Climb:          
            return Localize("RDVOrder", "Order_Climb", "R6Menu");
    }
    
    return "";
}

defaultproperties
{
     m_fBottomLadderActionRange=30.000000
     bStatic=False
     m_fCircumstantialActionRange=110.000000
     NetPriority=2.700000
}
