//=============================================================================
//  R6PlanningInfo.uc : Team info about the planning
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//
//  TODO: PACT_OpenDoor
//
//=============================================================================

class R6PlanningInfo extends R6AbstractPlanningInfo
    native
    transient;

native(1411) final function bool AddToTeam( R6ActionPoint pNewPoint );
native(1412) final private function bool InsertToTeam( R6ActionPoint pNewPoint );
native(1413) final private function bool DeletePoint();
native(2007) final private function bool FindPathToNextPoint(R6ActionPoint pStartPoint, R6ActionPoint pPointToReach);

// Super Function
function Tick(FLOAT fDelta)
{
    local R6GameInfo Game;
    local INT           iCurrentActionPoint;

    if((m_iNbNode > 1) && (m_NodeList[0].InPlanningMode()))
    {
        for(iCurrentActionPoint = 1; iCurrentActionPoint < m_iNbNode; iCurrentActionPoint++)
        {
            R6ActionPoint(m_NodeList[iCurrentActionPoint]).DrawPath(bDisplayDbgInfo);
        }
    }
    if(bDisplayDbgInfo == true)
        bDisplayDbgInfo = false;
}

function InitPlanning(INT iTeamID, R6PlanningCtrl pPlanningCtrl)
{
    local INT iBackupLastNode;
    local INT iCurrentActionPoint;
    local INT iLoadedNumberOfNodes;
    local R6ActionPoint pCurrentPoint;    
    local R6ActionPoint pNextPoint;

    #ifdefDEBUG if(bShowLog) log("Init Planning for "$Self$" NB Nodes: "$m_iNbNode$" Current "$m_iCurrentNode); #endif
    
    if(m_iNbNode == 0)
    {
        return;
    }
    iBackupLastNode = m_iCurrentNode;

    iLoadedNumberOfNodes = m_iNbNode;
    for(iCurrentActionPoint = 0; iCurrentActionPoint < iLoadedNumberOfNodes; iCurrentActionPoint++)
    {
        pCurrentPoint = R6ActionPoint(m_NodeList[iCurrentActionPoint]);
        if(iCurrentActionPoint == 0) //Change the texture for the first point.
        {
            pCurrentPoint.SetFirstPointTexture();  //Change the sprite
            pCurrentPoint.UnselectPoint();         //Set the new texture
        }
        pCurrentPoint.m_pPlanningCtrl = pPlanningCtrl;
        pCurrentPoint.m_iRainbowTeamName = iTeamID;
        if(iCurrentActionPoint != iLoadedNumberOfNodes - 1)
        {
            pNextPoint = R6ActionPoint(m_NodeList[iCurrentActionPoint+1]);

            pNextPoint.prevActionPoint = pCurrentPoint;
            FindPathToNextPoint(pCurrentPoint, pNextPoint);

        }
        //Set color
        pCurrentPoint.SetDrawColor(m_TeamColor);

        if(iCurrentActionPoint != 0) // First point does not have a path flag
        {
            pCurrentPoint.prevActionPoint = R6ActionPoint(m_NodeList[iCurrentActionPoint-1]);
            //Set the path flag
            pCurrentPoint.InitMyPathFlag();
        }

        //Set the Reference Icon for the current point
        pCurrentPoint.ChangeActionType(pCurrentPoint.m_eActionType);
        pCurrentPoint.SetPointAction(pCurrentPoint.m_eAction,true);
    }

    ResetPointsOrientation();
    if(iBackupLastNode != -1)
    {
        //Select the last node
        SetAsCurrentNode(R6ActionPoint(m_NodeList[iBackupLastNode]));
    }
}

function ResetPointsOrientation()
{
    //Set all the points orientation and set the current node to the first one
    SetToStartNode();
    while(GetNextPoint() != None)
    {
        SetPointRotation();
        SetToNextNode();
    }
    SetPointRotation();
    SetToStartNode();
}

// Set On/Off the display of the team path
function SetPathDisplay(bool bDisplay)
{
    local INT iCurrentNode;
    local R6ActionPoint pCurrentPoint;

    m_bDisplayPath=bDisplay;
    if(m_iCurrentNode != -1)
    {
        iCurrentNode = 0;
        while(iCurrentNode < m_NodeList.Length)
        {
            pCurrentPoint = R6ActionPoint(m_NodeList[iCurrentNode]);
            pCurrentPoint.bHidden = !bDisplay;
            if(pCurrentPoint.m_pMyPathFlag != none)
            {
                pCurrentPoint.m_pMyPathFlag.bHidden = !bDisplay;
            }
            if(pCurrentPoint.m_pActionIcon != none)
            {
                pCurrentPoint.m_pActionIcon.bHidden = !bDisplay;
            }
            iCurrentNode++;
        }
    }
}

function SelectTeam(BOOL bIsSelected)
{
    local R6ActionPoint pCurrentPoint;
    pCurrentPoint = GetPoint();

    if(pCurrentPoint != none)
    {
        pCurrentPoint.m_PlanningColor = pCurrentPoint.m_CurrentColor;
        if(bIsSelected == true)
        {
            pCurrentPoint.SetTimer(0.5,true);
        }
        else
        {
            pCurrentPoint.SetTimer(0,false);
        }
    }
    else
    {
        //No points return to insertion zone.
        R6PlanningCtrl(m_pTeamManager).PositionCameraOnInsertionZone();
    }
}

//-----------------------------------------------------------------------------
//      Action Point Management function
//-----------------------------------------------------------------------------
function BOOL InsertPoint(R6ActionPoint pNewPoint)
{
    local R6ActionPoint BehindMe, FrontMe;

    BehindMe = GetPoint();
    FrontMe = GetNextPoint();

    if((FindPathToNextPoint(BehindMe, pNewPoint) == true) &&  // Set the path between the current point and the new point
       (FindPathToNextPoint(pNewPoint, FrontMe) == true))     // Set the path between the new point and the point in front.
    {
        // link the node the others, Next/Prev and PathFlags
        InsertToTeam(pNewPoint);
        ResetID();

        // refresh the location of the PathFlag behind & front
        FrontMe.m_pMyPathFlag.RefreshLocation();

        pNewPoint.m_eMovementMode = BehindMe.m_eMovementMode;
        pNewPoint.m_eMovementSpeed = BehindMe.m_eMovementSpeed;

        pNewPoint.SetDrawColor(m_TeamColor);
        pNewPoint.InitMyPathFlag();

        //Change the textures
        BehindMe.UnselectPoint();
        pNewPoint.SelectPoint();

        //Reset the orientation of the new point and the two it was inserted between.
        SetPointRotation();
        SetToNextNode();
        SetPointRotation();
        SetToNextNode();
        SetPointRotation();
        SetToPrevNode();

        #ifdefDEBUG if(bShowLog) Log(self$" Insert  BehindMe: "$BehindMe$"  FrontMe : "$FrontMe); #endif
    }
    else
    {
        pNewPoint.Destroy();
        pNewPoint = none;
        return false;
    }
    return true;
}

// And the node in the team and cast the path
function BOOL AddPoint(R6ActionPoint pNewPoint)
{
    local R6ActionPoint BehindMe; //Point behind the new current point

    if(m_iCurrentNode != -1)
    {
        BehindMe = GetPoint();
    }

    // Display the PathFlag behind & init my PathFlag
    if(BehindMe!=none)
    {
        if(FindPathToNextPoint(BehindMe, pNewPoint) == true)
        {
            AddToTeam(pNewPoint);
            ResetID();

            // link the node the others , Next and PathFlags
            pNewPoint.m_eMovementMode = BehindMe.m_eMovementMode;
            pNewPoint.m_eMovementSpeed = BehindMe.m_eMovementSpeed;

            pNewPoint.SetDrawColor(m_TeamColor);
            pNewPoint.InitMyPathFlag();

            //Set the Previous point orientation.
            SetPointRotation();
            SetToNextNode();
            SetPointRotation();
        }
        else
        {
            pNewPoint.Destroy();
            pNewPoint = none;
            return false;
        }
    }
    else
    {
        //First point to Add
        AddToTeam(pNewPoint);
        ResetID();
        pNewPoint.SetDrawColor(m_TeamColor);
        pNewPoint.SelectPoint();
    }
    return true;
}

function BOOL MoveCurrentPoint()
{
    local R6ActionPoint BehindMe, FrontMe, CurrentPoint;

    CurrentPoint = GetPoint();
    BehindMe = R6ActionPoint(CurrentPoint.prevActionPoint);
    FrontMe = GetNextPoint();

    if(BehindMe != none)
    {
        if(FindPathToNextPoint(BehindMe, CurrentPoint) == true)
        {
            CurrentPoint.InitMyPathFlag();
        }
        else 
        {
            return false;
        }
    }
    if(FrontMe != none)
    {
        if(FindPathToNextPoint(CurrentPoint, FrontMe) == true)
        {
            
            FrontMe.InitMyPathFlag();
        }
        else 
        {
            return false;
        }
    }
    return true;
}

function SetLastPointRotation()
{
    local vector vDirection;
    local R6InsertionZone anInsertionZone;
    local rotator        rFirstPointRotation;
    local R6ActionPoint pCurrentPoint;
    pCurrentPoint = GetPoint();

    //At least two points two points in the list.
    if(m_NodeList.Length > 1)
    {
        //Set the point orientation.
        if(pCurrentPoint.prevActionPoint.m_PathToNextPoint.Length != 0)
        {
            vDirection = pCurrentPoint.Location - pCurrentPoint.prevActionPoint.m_PathToNextPoint[pCurrentPoint.prevActionPoint.m_PathToNextPoint.Length-1].Location;
        }
        else
        {
            vDirection = pCurrentPoint.Location - pCurrentPoint.prevActionPoint.Location;
        }

        vDirection.Z = 0;
        vDirection = Normal(vDirection);
        pCurrentPoint.SetRotation(Rotator(vDirection));
        pCurrentPoint.m_u8SpritePlanningAngle = pCurrentPoint.Rotation.Yaw / 255;
    }
    else //Orientation of the first point.
    {
        foreach m_pTeamManager.AllActors( class 'R6InsertionZone', anInsertionZone )
        {
            if(anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(m_pTeamManager.Level.Game).m_szGameTypeFlag) && (anInsertionZone.m_iInsertionNumber == m_iStartingPointNumber))
                rFirstPointRotation = anInsertionZone.Rotation;
        }

        pCurrentPoint.SetRotation(rFirstPointRotation);
        pCurrentPoint.m_u8SpritePlanningAngle = pCurrentPoint.Rotation.Yaw / 255;
    }
}

function SetPointRotation()
{
    local vector vDirection;
    local R6ActionPoint pCurrentPoint;
    pCurrentPoint = GetPoint();

    //Reset the Action flag here, for retry action.
    pCurrentPoint.m_bActionCompleted=false;
	pCurrentPoint.m_bActionPointReached=false;

    if(GetNextPoint() != none)
    {
        //Set the point orientation.
        if(pCurrentPoint.m_PathToNextPoint.Length != 0)
        {
            vDirection = pCurrentPoint.m_PathToNextPoint[0].Location - pCurrentPoint.Location;
        }
        else
        {
            vDirection = GetNextPoint().Location - pCurrentPoint.Location;
        }

        vDirection.Z = 0;
        vDirection = Normal(vDirection);
        
        pCurrentPoint.SetRotation(Rotator(vDirection));
        pCurrentPoint.m_u8SpritePlanningAngle = pCurrentPoint.Rotation.Yaw / 255;
    }
    else
    {
        //Setting rotation for the last point
        SetLastPointRotation();
    }
}

function SetToPrevNode()
{
    // if current node is -1, there's no node in the list and if 0, it's the first point
    if(m_iCurrentNode > 0)
    {
        GetPoint().UnselectPoint();
        m_iCurrentNode--;
        GetPoint().SelectPoint();
    }
}

function SetToNextNode()
{
    //Need more than one point and not the last one
    if(m_iCurrentNode != m_NodeList.Length -1)
    {
        GetPoint().UnselectPoint();
        m_iCurrentNode++;
        GetPoint().SelectPoint();
    }
}

function SetToStartNode()
{
    if(m_iNbNode != 0)
    {
        if(m_iCurrentNode != -1)
            GetPoint().UnselectPoint();
        m_iCurrentNode = 0;
        GetPoint().SelectPoint();
        m_iCurrentPathIndex = -1;
    }
}

function SetToEndNode()
{
    if(m_iCurrentNode != -1)
    {
        GetPoint().UnselectPoint();
        m_iCurrentNode = m_NodeList.Length -1;
        GetPoint().SelectPoint();
    }
}

function RemovePointsRefsToCtrl()
{
    local R6ActionPoint pActionPoint;
    local INT           iCurrentNode;
    for(iCurrentNode = 0; iCurrentNode<m_NodeList.Length; iCurrentNode++)
    {
        pActionPoint=R6ActionPoint(m_NodeList[iCurrentNode]);
        pActionPoint.m_pPlanningCtrl = none;
    }
}

// Reset the ID of all the ActionPoint
function ResetID()
{
    local R6ActionPoint pNode;

    //If  current node is not -1, there is at least one action point in the list
    m_iNbMilestone = 0;
    for(m_iNbNode = 0; m_iNbNode<m_NodeList.Length; m_iNbNode++)
    {
        pNode=R6ActionPoint(m_NodeList[m_iNbNode]);
        pNode.m_iNodeID=m_iNbNode;
        if(pNode.m_eActionType==PACTTYP_Milestone)
        {
            m_iNbMilestone++;
            pNode.m_iMileStoneNum=m_iNbMilestone;
            pNode.SetMileStoneIcon(m_iNbMilestone);
        }
    }
}

function bool SetAsCurrentNode(R6ActionPoint pSelectedNode)
{
    if(m_iCurrentNode != -1)
    {
        GetPoint().UnselectPoint();
    }
    
    for(m_iCurrentNode = 0; m_iCurrentNode < m_NodeList.Length; m_iCurrentNode++)
    {
        if(GetPoint() == pSelectedNode)
        {
            GetPoint().SelectPoint();
            return true;
        }
    }
    m_iCurrentNode = 0;
    log("WARNING - Could not find current node in Planning Info!!");

    return false;
}

// Delete the current ActionPoint
function BOOL DeleteNode()
{
    local R6ActionPoint pCurrentPoint;
    local R6ReferenceIcons tempAI;
    local R6PathFlag tempPF;

    //No node to delete
    if(m_iCurrentNode == -1)
    {
        return false;
    }

    pCurrentPoint = GetPoint();
    if(!((m_iCurrentNode == 0) && (m_NodeList.Length > 1)))
    {
        //Delete the action icon of current point (if any)
        if(pCurrentPoint.m_pActionIcon != none)
        {
            tempAI = pCurrentPoint.m_pActionIcon;
            pCurrentPoint.m_pActionIcon = none;
            tempAI.Destroy();
            pCurrentPoint.m_vActionDirection = Vect(0,0,0);
        }
        if(pCurrentPoint.m_pMyPathFlag != none)
        {
            tempPF = pCurrentPoint.m_pMyPathFlag;
            pCurrentPoint.m_pMyPathFlag = none;
            tempPF.Destroy();
        }

        if(m_iCurrentNode == 0)
            m_bPlacedFirstPoint = false;

        //Delete the Action Point from list
        DeletePoint();
        ResetID();

        if(m_iCurrentNode == m_NodeList.Length)
        {
            //reset the current node number if it's the last node we are deleting
            m_iCurrentNode--;
            
            if(m_iCurrentNode == -1)
            {
                //no nodes in the list
                return true;
            }
            pCurrentPoint = GetPoint();
            pCurrentPoint.SelectPoint();
            //Reset the last Point's orientation
            SetPointRotation();
        }
        else
        {
            m_iCurrentNode--;

            pCurrentPoint = GetPoint();
            GetNextPoint().prevActionPoint = pCurrentPoint;

            FindPathToNextPoint(pCurrentPoint, GetNextPoint());
            GetNextPoint().m_pMyPathFlag.RefreshLocation();

            pCurrentPoint.SelectPoint();
            //Reset the two points' orientation
            SetPointRotation();
            SetToNextNode();
            SetPointRotation();
            SetToPrevNode();
        }

    }
    else
    {
        log("Cannot delete start location, when there's other points in the list");
        return false;
    }

    return true;
}

// Delete all ActionPoint in the Team
function DeleteAllNode()
{
    //No node to delete

    m_iCurrentNode = m_NodeList.Length -1;
    while(m_iCurrentNode != -1)
    {
        DeleteNode();
    }
    m_bPlacedFirstPoint = false;
}

// Set the Action type of the current ActionPoint , grenades or sniping or other?!
function SetCurrentPointAction(EPlanAction eAction)
{
    if(GetPoint() == None) 
    {
        Log("WARNING: CurrentNode null");
        return;
    }

    //Set the action type
    GetPoint().SetPointAction(eAction);
}

function AjustSnipeDirection(vector vHitLocation)
{
    if(m_iCurrentNode != -1)
    {
        GetPoint().m_rActionRotation = R6PlanningSnipe(GetPoint().m_pActionIcon).SetDirectionRotator(vHitLocation);
    }
}

function GetSnipingCoordinates(out vector vLocation, out rotator rRotation)
{
	vLocation = GetPoint().Location;
	rRotation = GetPoint().m_rActionRotation;
}

function actor GetDoorToBreach()
{
	return GetPoint().pDoor;
}

function actor GetNextDoorToBreach(actor aPoint)
{
	local R6ActionPoint nextActionPoint;

	if(R6ActionPoint(aPoint) != none)
		return R6ActionPoint(aPoint).pDoor; 

	nextActionPoint = GetNextPoint();
	if(nextActionPoint != none)
		return nextActionPoint.pDoor;
}

function BOOL SetGrenadeLocation(vector vHitLocation)
{
    if(GetPoint() != none)
    {
        vHitLocation.Z += 100;
        return GetPoint().SetGrenade(vHitLocation);
    }
    return false;
}

function SetActionType(EPlanActionType eNewType)
{
    if(m_iCurrentNode != -1)
    {
        GetPoint().ChangeActionType(eNewType);
    }
}

function R6ActionPoint GetPoint()
{
    if(m_iCurrentNode != -1)
    {
        return R6ActionPoint(m_NodeList[m_iCurrentNode]);
    }
    return none;
}

function R6ActionPoint GetNextPoint()
{
    if((m_iCurrentNode != -1) && (m_iCurrentNode+1 != m_NodeList.length))
    {
        return R6ActionPoint(m_NodeList[m_iCurrentNode+1]);
    }
    return none;
}

function EPlanActionType GetActionType()
{
    if(m_iCurrentNode != -1)
    {
        return GetPoint().m_eActionType;
    }
    return m_eDefaultActionType;
}

function SetAction(EPlanAction eNewAction)
{
    if(m_iCurrentNode != -1)
    {
        GetPoint().m_eAction = eNewAction;
    }
}

function EPlanAction GetAction()// Abstract
{
    if(m_iCurrentNode != -1)
    {
        return GetPoint().m_eAction;
    }
    return m_eDefaultAction;
}

function EPlanAction NextActionPointHasAction(actor aPoint)
{
	local R6ActionPoint actionPoint, nextActionPoint;

	actionPoint = R6ActionPoint(aPoint);
	if(actionPoint == none)
	{
		// we are moving towards a regular pathnode
		nextActionPoint = GetNextPoint();
		if(nextActionPoint != none && (VSize(nextActionPoint.location - aPoint.location) < 300))
			return nextActionPoint.m_eAction; 
		else
			return PACT_None;
	}

	return actionPoint.m_eAction;
}

function SetMovementMode(EMovementMode eNewMode)
{
    if(m_iCurrentNode != -1)
    {
        #ifdefDEBUG if(bShowLog) log("New Movement Mode : "$eNewMode$" : "$GetPoint()); #endif
        GetPoint().m_eMovementMode = eNewMode;
        GetPoint().m_pMyPathFlag.SetModeDisplay(eNewMode);
    }
}

function EMovementMode GetMovementMode()// Abstract
{
    if(m_iCurrentNode != -1)
    {
        #ifdefDEBUG if(bShowLog) log("Get Movement Mode : "$GetPoint().m_eMovementMode$" : "$GetPoint()); #endif
        if(m_iCurrentPathIndex != -1)
            return GetNextPoint().m_eMovementMode;
        else
            return GetPoint().m_eMovementMode;
    }
    return m_eDefaultMode;
}

function SetMovementSpeed(EMovementSpeed eNewSpeed)
{
    if(m_iCurrentNode != -1)
    {
        #ifdefDEBUG if(bShowLog) log("New Movement Speed : "$eNewSpeed$" : "$GetPoint()); #endif
        GetPoint().m_eMovementSpeed = eNewSpeed;
    }
}

function EMovementSpeed GetMovementSpeed()// Abstract
{
    if(m_iCurrentNode != -1)
    {
        #ifdefDEBUG if(bShowLog) log("Get Movement Speed : "$GetPoint().m_eMovementSpeed$" : "$GetPoint()); #endif
        if(m_iCurrentPathIndex != -1)
            return GetNextPoint().m_eMovementSpeed;
        else
            return GetPoint().m_eMovementSpeed;
    }
    return m_eDefaultSpeed;
}

function actor GetFirstActionPoint()
{
    return GetPoint();
}

function SkipCurrentDestination()
{
    local R6ActionPoint pPrevPoint;
    local R6ActionPoint pCurrentPoint;
    local R6RainbowTeam pCurrentTeam;

    pCurrentPoint = GetPoint();
    pCurrentTeam = R6RainbowTeam(m_pTeamManager);

    //Node completed, get the next One
    if((m_iCurrentNode != -1) && (m_iCurrentNode != m_NodeList.Length -1))
    {
        if(m_iCurrentPathIndex == pCurrentPoint.m_PathToNextPoint.Length - 1)
        {
            pPrevPoint = pCurrentPoint;
            //The action is now completed.
            pCurrentPoint.m_bActionCompleted = true;

            m_iCurrentPathIndex = -1;
            m_iCurrentNode++;
        }
        else
        {
            m_iCurrentPathIndex++;
        }

        if(m_iCurrentPathIndex == -1)
        {
            //Reached a point, and changing the parameters to reach the new one 
            // Check if there is a new movement mode and notify
            if(pPrevPoint.m_eMovementMode != pCurrentPoint.m_eMovementMode)
                pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewMode, GOCODE_None);
            if(pPrevPoint.m_eMovementSpeed != pCurrentPoint.m_eMovementSpeed)
                pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewSpeed, GOCODE_None);
        }
        else if(m_iCurrentPathIndex == 0)
        {
            //Reached a point, and changing the parameters to reach the new one 
            // Check if there is a new movement mode and notify
            if(GetNextPoint().m_eMovementMode != pCurrentPoint.m_eMovementMode)
                pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewMode, GOCODE_None);
            if(GetNextPoint().m_eMovementSpeed != pCurrentPoint.m_eMovementSpeed)
                pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewSpeed, GOCODE_None);
        }

        #ifdefDEBUG if(bShowLog) Log("Skipping destination, Sending NODEMSG_NewNode; action point to reach "$pCurrentPoint$" : "$m_iCurrentPathIndex); #endif
        pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewNode, GOCODE_None);
    }
    else
    {
        //skipped to last node
        m_iCurrentNode=-1;
    }
}

function actor GetNextActionPoint()// Abstract
{
    local actor pPointToReturn;
    local R6ActionPoint pCurrentPoint;
    pCurrentPoint = GetPoint();

    //return none, for team without planning
    if((m_iCurrentNode != -1) && (m_iCurrentNode < m_NodeList.Length)) 
    {
        if((m_iCurrentPathIndex != -1) && (m_iCurrentPathIndex < pCurrentPoint.m_PathToNextPoint.Length))
        {
            pPointToReturn = pCurrentPoint.m_PathToNextPoint[m_iCurrentPathIndex];
        }
        else
        {
            pPointToReturn = pCurrentPoint;
        }
    }
    else 
    {
        pPointToReturn = none;
    }

    return pPointToReturn;
}

function actor PreviewNextActionPoint()
{
    local actor pPointToReturn;
    //return none, for team without planning
    if(m_iCurrentNode != -1)
    {
        if(m_iCurrentPathIndex + 1 < GetPoint().m_PathToNextPoint.Length)
        {
            pPointToReturn = GetPoint().m_PathToNextPoint[m_iCurrentPathIndex + 1];
        }
        else
        {
            pPointToReturn = GetNextPoint();
        }
    }

    #ifdefDEBUG if(bShowLog)log(self$" Preview next Point of #"$m_iCurrentNode$","$m_iCurrentPathIndex$" = "$pPointToReturn); #endif

    return pPointToReturn;
}

function SetToPreviousActionPoint()
{
	// if team has already reached current node (an action may remain) or is close enough to current node, do not go back to previous node	
	if(GetPoint().m_bActionPointReached || (VSize(R6RainbowTeam(m_pTeamManager).m_Team[0].location - GetPoint().location) < 200))
		return;

    if((m_iCurrentNode != -1) && !((m_iCurrentNode == 0) && (m_iCurrentPathIndex == -1)))
    {
        if(m_iCurrentPathIndex != -1)
        {
            m_iCurrentPathIndex -= 1;
        }
        else
        {
            m_iCurrentNode--;
            m_iCurrentPathIndex = GetPoint().m_PathToNextPoint.Length - 1;
        }
    }
    #ifdefDEBUG if(bShowLog) log(self$"Settin Previous Point #"$m_iCurrentNode$","$m_iCurrentPathIndex); #endif
}

function INT GetActionPointID()// Abstract
{
    if(m_iCurrentNode != -1)
    {
        return GetPoint().m_iNodeID;
    }
    return -1;
}

function INT GetNbActionPoint()// Abstract
{
    return m_iNbNode;
}

function Vector GetActionLocation()// Abstract
{
    if(m_iCurrentNode != -1)
    {
        return GetPoint().m_vActionDirection;
    }
    return vect(0,0,0);
}

// Message management between the TeamAI and PlayerController
function NotifyActionPoint(ENodeNotify eMsg, EGoCode eCode)// Abstract
{
    local R6ActionPoint pPrevPoint;
    local R6RainbowTeam pCurrentTeam;
    local R6ActionPoint pCurrentPoint;

    #ifdefDEBUG if(bShowLog) log("--> R6PlanningInfo Notify Action Point, msg: "$eMsg$" code : "$eCode$" TM: "$R6RainbowTeam(m_pTeamManager)$" CurrentNode"$m_iCurrentNode); #endif

    pCurrentTeam = R6RainbowTeam(m_pTeamManager);
    pCurrentPoint = GetPoint();
    if((pCurrentTeam!=None) && (m_iCurrentNode != -1))
    {
        switch(eMsg)
        {
        // not used this side
        case NODEMSG_NewAction:
            #ifdefDEBUG if(bShowLog) Log("NODEMSG_NewAction"); #endif
            return;

        // not used this side
        case NODEMSG_NewMode:
            #ifdefDEBUG if(bShowLog) Log("NODEMSG_NewMode"); #endif
            return;

        // come from player - the player called a GoCode
        case NODEMSG_GoCodeLaunched:
            #ifdefDEBUG if(bShowLog) Log("NODEMSG_GoCodeLaunched"); #endif
            
			// if team is waiting for ZULU, then ignore all other GoCodes that may be issued...
			if(pCurrentTeam.m_eGoCode == GOCODE_Zulu)
			{
				#ifdefDEBUG if(bShowLog) Log("Doing nothing on that gocode, team is waiting for ZULU..."); #endif
				return;
			}
			
            // Check if we want this GoCode
            if(m_eGoCodeState[eCode] == GOCODESTATE_Waiting)
            {
                m_eGoCodeState[eCode] = GOCODESTATE_None;
                if( pCurrentPoint.m_eAction != PACT_None )
                {
                    #ifdefDEBUG if(bShowLog) Log("NODEMSG_GoCodeLaunched throwing Grenade"); #endif
                    pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewAction, GOCODE_None);
                }
                else
                {
                    #ifdefDEBUG if(bShowLog) Log("NODEMSG_GoCodeLaunched, no action means node completed"); #endif
                    NotifyActionPoint( NODEMSG_ActionNodeCompleted, GOCODE_None);
                }
				pCurrentTeam.ResetTeamGoCode();
            }
            else if(m_eGoCodeState[eCode] == GOCODESTATE_Snipe)
            {
                #ifdefDEBUG if(bShowLog) Log("GoCodeLaunched stop sniping and call ReadNode()"); #endif
                m_eGoCodeState[eCode] = GOCODESTATE_None;
                pCurrentTeam.TeamSnipingOver();
				pCurrentTeam.ResetTeamGoCode();
            }
            else if(m_eGoCodeState[eCode] == GOCODESTATE_Breach)
            {
                #ifdefDEBUG if(bShowLog) Log("GoCodeLaunched blow the door and call ReadNode()"); #endif
                m_eGoCodeState[eCode] = GOCODESTATE_None;
                pCurrentTeam.BreachDoor();
				pCurrentTeam.ResetTeamGoCode();
            }
            else
            {
                #ifdefDEBUG if(bShowLog) Log("Doing nothing on that gocode."); #endif
            }
            return;

        // from team-manager or me
        case NODEMSG_ActionNodeCompleted:
            // prepare to move to the next node
            if(m_iCurrentNode != m_iNbNode-1) //Last node reached
            {
                #ifdefDEBUG if(bShowLog) Log("NODEMSG_ActionNodeCompleted"); #endif

                //The action is now completed.
                pCurrentPoint.m_bActionCompleted = true;

                //to change speed and ROE
                pPrevPoint = pCurrentPoint;

                //log("HERE :"$m_iCurrentPathIndex$" : "$pCurrentPoint.m_PathToNextPoint.Length);
                //Node completed, get the next One
                if(m_iCurrentPathIndex == pCurrentPoint.m_PathToNextPoint.Length - 1)
                {
                    m_iCurrentPathIndex = -1;
                    m_iCurrentNode++;
                    pCurrentPoint = GetPoint();
                }
                else
                {
                    m_iCurrentPathIndex++;
                }

                if(m_iCurrentPathIndex == -1)
                {
                    //Reached a point, and changing the parameters to reach the new one 
                    // Check if there is a new movement mode and notify
                    if(pPrevPoint.m_eMovementMode != pCurrentPoint.m_eMovementMode)
                    {
                        #ifdefDEBUG if(bShowLog) Log("Sending NODEMSG_NewMode To Point"); #endif
                        pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewMode, GOCODE_None);
                    }
                    if(pPrevPoint.m_eMovementSpeed != pCurrentPoint.m_eMovementSpeed)
                    {
                        #ifdefDEBUG if(bShowLog) Log("Sending NODEMSG_NewSpeed"); #endif
                        pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewSpeed, GOCODE_None);
                    }
                }
                else if(m_iCurrentPathIndex == 0)
                {
                    //Reached a point, and changing the parameters to reach the new one 
                    // Check if there is a new movement mode and notify
                    if(GetNextPoint().m_eMovementMode != pCurrentPoint.m_eMovementMode)
                    {
                        #ifdefDEBUG if(bShowLog) Log("Sending NODEMSG_NewMode to next path"); #endif
                        pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewMode, GOCODE_None);
                    }
                    if(GetNextPoint().m_eMovementSpeed != pCurrentPoint.m_eMovementSpeed)
                    {
                        #ifdefDEBUG if(bShowLog) Log("Sending NODEMSG_NewSpeed"); #endif
                        pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewSpeed, GOCODE_None);
                    }
                }
                // Notify the new node to reach
                #ifdefDEBUG if(bShowLog) Log("Sending NODEMSG_NewNode; action point to reach "$pCurrentPoint$" : "$m_iCurrentPathIndex); #endif
                pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewNode, GOCODE_None);
            }
            else
            {
                #ifdefDEBUG if(bShowLog) Log("EndNode reached Now we do what!"); #endif
                m_iCurrentNode=-1;
            }
            return;

        // from me
        case NODEMSG_WaitingGoCode:
            #ifdefDEBUG if(bShowLog) Log("NODEMSG_WaitingGoCode : "$eCode); #endif
            m_eGoCodeState[eCode] = GOCODESTATE_Waiting;
            pCurrentTeam.TeamNotifyActionPoint( NODEMSG_WaitingGoCode, eCode);
            return;

        case NODEMSG_SnipeUntilGoCode:
            #ifdefDEBUG if(bShowLog) Log("NODEMSG_SnipeUntilGoCode : "$eCode); #endif
            m_eGoCodeState[eCode] = GOCODESTATE_Snipe;
            pCurrentTeam.TeamNotifyActionPoint( NODEMSG_SnipeUntilGoCode, eCode);
            return;

        case NODEMSG_BreachDoorAtGoCode:
            #ifdefDEBUG if(bShowLog) Log("NODEMSG_BreachDoorAtGoCode : "$eCode); #endif
            m_eGoCodeState[eCode] = GOCODESTATE_Breach;
            pCurrentTeam.TeamNotifyActionPoint( NODEMSG_BreachDoorAtGoCode, eCode);
            return;

            // from team-manager // team AI only
        case NODEMSG_NodeReached:
            #ifdefDEBUG if(bShowLog) Log("NODEMSG_NodeReached call ReadNode()"); #endif
			pCurrentPoint.m_bActionPointReached = true;
            ReadNode();
            return;

        // from team-manager
        case NODEMSG_PlayerLeft:
            #ifdefDEBUG if(bShowLog) Log("NODEMSG_PlayerLeft"); #endif

            // The Player has left the Team, send the Team to the previous ActionPoint
            SetToPreviousActionPoint();

            pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewNode, GOCODE_None);
            return;
        }
    }
    else
    {
        #ifdefDEBUG if(bShowLog) Log(self$" "$m_TeamColor.R$" "$m_TeamColor.G$" "$m_TeamColor.B$" m_pTeamManager or pCurrentPoint invalid"); #endif
    }
}

// check if this team has reach this action point
function bool MemberReached(R6ActionPoint pTarget)
{
    local INT i;
	local vector vDiff;
	local FLOAT fZDiff;
    
    if(pTarget!=None)
    {
        if(m_pTeamManager!=None)
        {
            if(R6RainbowTeam(m_pTeamManager).m_bLeaderIsAPlayer)
            {
				vDiff = R6RainbowTeam(m_pTeamManager).m_TeamLeader.Location - pTarget.Location;
				fZDiff = vDiff.z;
				vDiff.z = 0;
                if((VSize(vDiff) < m_fReachRange) && (fZDiff < m_fZReachRange))
                {
                    return true;
                }
            }
        }
    }
    
    // DEBUG CODE
    /*if(pTarget!=None)
    {
        if((DEB_iStartTime + 5) < Level.TimeSeconds)
        {
            DEB_iStartTime = Level.TimeSeconds;
            if(bShowLog) Log("   MemberReached at "$Level.TimeSeconds);
            return true;
        }
    }*/
    return false;
}

// Read info in the node
function ReadNode()
{
    local R6PlayerController pMyPlayer;
    local actor NextPoint;
    local R6RainbowTeam pCurrentTeam;
    local R6ActionPoint pCurrentPoint;

    pCurrentPoint = GetPoint();
    pCurrentTeam = R6RainbowTeam(m_pTeamManager);

    if(pCurrentPoint.m_bActionCompleted != true)
    {
        switch(pCurrentPoint.m_eActionType)
        {
        case PACTTYP_Milestone:
            // Tell the player we have reach this Milestone
            ForEach m_pTeamManager.Level.AllActors(class'R6PlayerController',pMyPlayer)
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP_Milestone #"$pCurrentPoint.m_iMileStoneNum); #endif
                pMyPlayer.DisplayMilestoneMessage(pCurrentTeam.m_iRainbowTeamName, pCurrentPoint.m_iMileStoneNum);
            }

            //Keep going like normal once milestone has been dispatched
        case PACTTYP_Normal:
            // Send Action to the TeamManager
            if(pCurrentPoint.m_eAction != PACT_None)
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Normal eAction = "$pCurrentPoint.m_eAction); #endif
                pCurrentTeam.TeamNotifyActionPoint(NODEMSG_NewAction, GOCODE_None);
            }
            else
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Normal eAction = none"); #endif
                NotifyActionPoint( NODEMSG_ActionNodeCompleted, GOCODE_None);
            }
            break;
        
        case PACTTYP_GoCodeA:
            // Set my Team in standby to this GoCode
            if(pCurrentPoint.m_eAction == PACT_SnipeGoCode)
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Alpha snipe"); #endif
                NotifyActionPoint( NODEMSG_SnipeUntilGoCode, GOCODE_Alpha);
            }
            else if(pCurrentPoint.m_eAction == PACT_Breach)
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Alpha Breach"); #endif
                NotifyActionPoint( NODEMSG_BreachDoorAtGoCode, GOCODE_Alpha );
            }
            else
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Alpha Wait"); #endif
                NotifyActionPoint( NODEMSG_WaitingGoCode, GOCODE_Alpha);
            }
            break;
        case PACTTYP_GoCodeB:
            // Set my Team in standby to this GoCode
            if(pCurrentPoint.m_eAction == PACT_SnipeGoCode)
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Bravo Snipe"); #endif
                NotifyActionPoint( NODEMSG_SnipeUntilGoCode, GOCODE_Bravo);
            }
            else if(pCurrentPoint.m_eAction == PACT_Breach)
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Bravo Breach"); #endif
                NotifyActionPoint( NODEMSG_BreachDoorAtGoCode, GOCODE_Bravo );
            }
            else
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Bravo Wait"); #endif
                NotifyActionPoint( NODEMSG_WaitingGoCode, GOCODE_Bravo);
            }
            break;
        case PACTTYP_GoCodeC:
            // Set my Team in standby to this GoCode
            if(pCurrentPoint.m_eAction == PACT_SnipeGoCode)
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Charlie snipe"); #endif
                NotifyActionPoint( NODEMSG_SnipeUntilGoCode, GOCODE_Charlie);
            }
            else if(pCurrentPoint.m_eAction == PACT_Breach)
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Charlie Breach"); #endif
                NotifyActionPoint( NODEMSG_BreachDoorAtGoCode, GOCODE_Charlie );
            }
            else
            {
                #ifdefDEBUG if(bShowLog) log("PACTTYP Bravo Wait"); #endif
                NotifyActionPoint( NODEMSG_WaitingGoCode, GOCODE_Charlie);
            }
            break;
        }
    }
    else
    {
        #ifdefDEBUG if(bShowLog) log("Read node is not an action point, sending NODEMSG_ActionNodeCompleted"); #endif
        NotifyActionPoint( NODEMSG_ActionNodeCompleted, GOCODE_None);
    }
}

defaultproperties
{
}
