//=============================================================================
//  R6DZonePath.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================

class R6DZonePath extends R6DeploymentZone
	placeable
    native;

enum EInformTeam
{
    INFO_EnterPath,
    INFO_ReachNode,
    INFO_FinishWaiting,
    INFO_Engage,
    INFO_ExitPath,
    INFO_Dead
};

var(R6DZone)    autoconstruct   Array<R6DZonePathNode>  m_aNode;
var(R6DZone)    BOOL    m_bCycle;
var(R6DZone)    BOOL    m_bSelectNodeInEditor;

// Terro team variable
var(R6DZone)    BOOL    m_bActAsGroup;
var(Debug)      BOOL    bShowLog;

//============================================================================
// GetNodeIndex - 
//============================================================================
function INT GetNodeIndex( R6DZonePathNode node )
{
    local INT i;

    for(i=0; i<m_aNode.Length; i++)
    {
        if(m_aNode[i] == node )
        {
            return i;
        }
    }

    return -1;
}

//============================================================================
// GetNextNode - 
//============================================================================
function R6DZonePathNode GetNextNode( R6DZonePathNode node )
{
    local INT index;

    index = GetNodeIndex( node );
    if(index!=-1)
    {
        index++;
        if( index>=m_aNode.Length )
        {
            index=0;
        }
        return m_aNode[index];
    }

    return None;
}

//============================================================================
// GetPreviousNode - 
//============================================================================
function R6DZonePathNode GetPreviousNode( R6DZonePathNode node )
{
    local INT index;

    index = GetNodeIndex( node );
    if(index!=-1)
    {
        if(index==0)
        {
            index = m_aNode.Length;
        }
        index--;
        return m_aNode[index];
    }

    return None;
}

//============================================================================
// FindNearestNodeInPath - 
//============================================================================
function R6DZonePathNode FindNearestNode( Actor pawn )
{
    local R6DZonePathNode best;
    local R6DZonePathNode r6node;
    local FLOAT fBestDistSqr;
    local FLOAT fDistSqr;
	local vector vDist;
    local INT i;
 
	// look for nearest pathnode
    for(i=0; i<m_aNode.Length; i++)
    {
        r6node = m_aNode[i];

        // Calculate distance to pawn
        vDist = pawn.Location - r6node.Location;
		fDistSqr = vDist.x * vDist.x + vDist.y * vDist.y;   

        // Check if nearer thant nearest
		if ((fDistSqr < fBestDistSqr) || (i == 0))
		{
			fBestDistSqr = fDistSqr;
			best = r6node;
		}
    }            

    return best;
}

//============================================================================
// BOOL IsLeader - 
//============================================================================
function BOOL IsLeader( R6Terrorist terro )
{
    // If not a group, every terrorist is a leader
    if(!m_bActAsGroup)
        return TRUE;

    // Called to clean the list from dead terrorist
    HaveTerrorist();

    // The leader is the first terrorist in the list
    if(m_aTerrorist[0] == terro)
        return TRUE;
    else
        return FALSE;
}

//============================================================================
// R6Terrorist GetLeader - 
//============================================================================
function R6Terrorist GetLeader()
{
    return m_aTerrorist[0];
}

function vector GetRandomPointToNode( R6DZonePathNode node )
{
    local rotator       r;
    local INT           iDistance;
    local vector        vDestination;

    r.Yaw     = Rand(32767)*2;
    iDistance = Rand(node.m_fRadius);
    vDestination = node.Location + vector(r)*iDistance;
    //if(bShowLog) log( "Go to " $ node $ " (" $ node.Location $ "), choose point " $ vDestination );

    return vDestination;
}

//============================================================================
// GetNextNodeForTerro - 
//============================================================================
function SetNextNodeForTerro( R6TerroristAI terro )
{
    local INT index;
    local R6DZonePathNode nextNode;

    // if no current, current is the closet one
    if(terro.m_CurrentNode == None)
    {
        terro.m_CurrentNode = FindNearestNode( terro.m_pawn );
    }

    // If path is not a cycling path and current node is the first or the last, reverse order
    if( !m_bCycle )
    {
        index = GetNodeIndex( terro.m_CurrentNode );
        if( (index == 0) )
        {
            terro.m_pawn.m_bPatrolForward = true;
        }
        if( index == (m_aNode.Length-1) )
        {
            terro.m_pawn.m_bPatrolForward = false;
        }
    }

    // Get the next node
    if(terro.m_pawn.m_bPatrolForward)
    {
        nextNode = GetNextNode( terro.m_CurrentNode );
    }
    else
    {
        nextNode = GetPreviousNode( terro.m_CurrentNode );
    }

    terro.m_CurrentNode = nextNode;
}
/*
function GetTerroIndex()
{

}
*/

//============================================================================
// BOOL IsAllTerroWaiting - 
//============================================================================
function BOOL IsAllTerroWaiting()
{
    local INT i;
    for(i=0; i<m_aTerrorist.Length; i++)
    {
        if( m_aTerrorist[i].m_controller==None || !m_aTerrorist[i].m_controller.m_bWaiting )
            return false;
    }
    return true;
}

//============================================================================
// GoToNextNode - 
//============================================================================
function GoToNextNode( R6TerroristAI terroAI )
{
    local R6TerroristAI leaderAI;
    local INT i;
    local vector vGoal;

    // If act as a group, be sure all terrorist are ready for the next action
    if(m_bActAsGroup && !IsAllTerroWaiting())
    {
        if(bShowLog) log("Not all terro waiting");
        return;
    }
    
    // Find the next node
    SetNextNodeForTerro( terroAI );
    vGoal = GetRandomPointToNode( terroAI.m_CurrentNode );

    // Send order to terrorist(s)
    if(m_bActAsGroup)
    {
        OrderTerroListFromDistanceTo( terroAI.m_CurrentNode.Location );

        // Send order to terro of group
        for(i=0; i<m_aTerrorist.Length; i++)
        {
            // Set the current node of all terrorist in group
            m_aTerrorist[i].m_controller.m_CurrentNode = terroAI.m_CurrentNode;

            if(i==0)
            {
                m_aTerrorist[i].m_controller.GotoNode( vGoal );
            }
            else if((i%3)==1)
            {
                m_aTerrorist[i].m_controller.FollowLeader( m_aTerrorist[(i-1)], vect(75,75,0) );
            }
            else if((i%3)==2)
            {
                m_aTerrorist[i].m_controller.FollowLeader( m_aTerrorist[(i-1)], vect(-25,-150,0) );
            }
            else if((i%3)==0)
            {
                m_aTerrorist[i].m_controller.FollowLeader( m_aTerrorist[(i-1)], vect(25,75,0) );
            }
        }
    }
    else
    {
        terroAI.GotoNode( vGoal );
    }
}

//============================================================================
// StartWaiting - 
//============================================================================
function StartWaiting( R6TerroristAI terroAI )
{
    local INT iWaitingTime;
    local INT iFacingTime;
    local Rotator rDirection;
    local Rotator rRefDir;
    local INT i;
    local INT iYawOffset;

    // If act as a group, be sure all terrorist are ready for the next action
    if(m_bActAsGroup && !IsAllTerroWaiting())
    {
        if(bShowLog) log("Not all terro waiting");
        return;
    }

    // Get facing time and direction
    if( terroAI.m_CurrentNode.m_bWait )    
    {
        iWaitingTime = terroAI.GetWaitingTime();
        iFacingTime = terroAI.GetFacingTime();
    }
    else
    {
        iWaitingTime = 0;
        iFacingTime = 0;
    }
    if(terroAI.m_CurrentNode.bDirectional)
    {
        rRefDir = terroAI.m_CurrentNode.Rotation; 
    }
    else
    {
        rRefDir = m_aTerrorist[0].Rotation;
    }

    // Send order to terrorist(s)
    if(m_bActAsGroup)
    {
        iYawOffset = 8192; // 45 degrees
        
        // Send order to terro of group
        for(i=0; i<m_aTerrorist.Length; i++)
        {
            rDirection = rRefDir;
            // If not the first, add an offset
            if(i!=0)
            {
                if(i%2!=0)
                {
                    rDirection.Yaw -= iYawOffset * ((i+1)/2);
                }
                else
                {
                    rDirection.Yaw += iYawOffset * ((i+1)/2);
                }
                    
            }
            m_aTerrorist[i].m_controller.WaitAtNode( iWaitingTime, iFacingTime, rDirection );
        }
    }
    else
    {
        terroAI.WaitAtNode( iWaitingTime, iFacingTime, rRefDir );
    }
}

//============================================================================
// InformTerroTeam - 
//============================================================================
function InformTerroTeam( EInformTeam eInfo, R6TerroristAI terroAI )
{
    local INT i;
    
    if(bShowLog) log("Received message " $ eInfo $ " from " $ terroAI.name );
    //local INT iIndex = GetTerroIndex( terroAI );

    switch(eInfo)
    {
        case INFO_ReachNode:
            StartWaiting( terroAI );
            break;
        case INFO_FinishWaiting:
            GoToNextNode( terroAI );
            break;
        case INFO_ExitPath:
            break;
        case INFO_Dead:
            // Call HaveTerrorist to remove the dead from the list
            HaveTerrorist();
            // Send order to terro of group
            for(i=0; i<m_aTerrorist.Length; i++)
            {
                m_aTerrorist[i].m_controller.GotoPointAndSearch( terroAI.Pawn.Location, PACE_Run, false, 30 );
            }
            break;
        default:
            break;
    }
}

defaultproperties
{
     m_bSelectNodeInEditor=True
}
