//=============================================================================
//  R6ActionPoint.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6ActionPoint extends R6ActionPointAbstract
    native;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

var Texture                 m_pCurrentTexture;  // Current texture depending on the point properties
var Texture                 m_pSelected;
var EMovementMode           m_eMovementMode;    // Movement mode to reach the next ActionPoint
var EMovementSpeed          m_eMovementSpeed;   // Speed mode to reach the next ActionPoint
var EPlanAction             m_eAction;          // Action to do here
var EPlanActionType         m_eActionType;      // kind of ActionPoint
var INT                     m_iRainbowTeamName; // team owner
var INT                     m_iMileStoneNum;    // # of the milesstone for its team, valid if m_eActionType & PACTTYP_Milestone
var INT                     m_iNodeID;          // # of this node in its team path
var BOOL                    m_bActionCompleted;
var BOOL					m_bActionPointReached;
var BOOL                    m_bDoorInRange;
var R6IORotatingDoor        pDoor;
var color                   m_CurrentColor;     // Original color used when flashing

var R6PlanningCtrl          m_pPlanningCtrl;    // Pointer to the Planning controller
var R6PathFlag              m_pMyPathFlag;      // PathFlag in the planning
var R6ReferenceIcons        m_pActionIcon;      // exist only in the planning
var Vector                  m_vActionDirection; // Direction of the Action from the ActionPoint... ei: grenade direction
var rotator                 m_rActionRotation;  // Action Rotator, for sniping direction

// R6-3DVIEWPORT
var INT                     m_iInitialMousePosX;
var INT                     m_iInitialMousePosY;

// Debug
var bool                    bShowLog;

// Insert the node between two others nodes in the team and cast the PathFlag

function InitMyPathFlag()
{
    local R6PathFlag pPrevFlag;

    // spawn the PathFlag if it is not done
    if(m_pMyPathFlag==None)
    {
        m_pMyPathFlag = Spawn(class'R6PathFlag',self,,Location);
        if(bShowLog) Log("-->PathFlag spawned at Location "$m_pMyPathFlag.Location);
        m_pMyPathFlag.m_iPlanningFloor_0 = m_iPlanningFloor_0;
        m_pMyPathFlag.m_iPlanningFloor_1 = m_iPlanningFloor_1;

    }

    m_pMyPathFlag.SetModeDisplay(m_eMovementMode);
    m_pMyPathFlag.SetDrawColor(m_CurrentColor);

    // locate the PathFlag between both ActionPoint
    m_pMyPathFlag.RefreshLocation();
}

function DrawPath(BOOL bDisplayInfo)
{
    local INT iCurrentPoint;
    local Material pLineMaterial;
    local FLOAT fDashSize;

    if(bHidden == true) 
        return;

    switch (m_eMovementSpeed)
    {
    case SPEED_Blitz:
        fDashSize = 0.0f;
        break;
    case SPEED_Normal:
        fDashSize = 100.0f;
        break;
    case SPEED_Cautious:
        fDashSize = 50.0f;
        break;
    }

    if(prevActionPoint.m_PathToNextPoint.Length == 0)
    {
        if(CanIDrawLine( prevActionPoint, self, m_pPlanningCtrl.m_iLevelDisplay, bDisplayInfo))
        {
            DrawDashedLine(prevActionPoint.Location, Location, m_CurrentColor, fDashSize);
        }
    }
    else
    {
        if(CanIDrawLine( prevActionPoint, prevActionPoint.m_PathToNextPoint[0], m_pPlanningCtrl.m_iLevelDisplay, bDisplayInfo))
        {
            DrawDashedLine(prevActionPoint.Location, prevActionPoint.m_PathToNextPoint[0].Location, m_CurrentColor, fDashSize);
        }
        
        for(iCurrentPoint = 0; iCurrentPoint < prevActionPoint.m_PathToNextPoint.Length - 1; iCurrentPoint++)
        {
            if(CanIDrawLine( prevActionPoint.m_PathToNextPoint[iCurrentPoint], prevActionPoint.m_PathToNextPoint[iCurrentPoint+1], m_pPlanningCtrl.m_iLevelDisplay, bDisplayInfo))
            {
                DrawDashedLine(prevActionPoint.m_PathToNextPoint[iCurrentPoint].Location, prevActionPoint.m_PathToNextPoint[iCurrentPoint+1].Location, m_CurrentColor, fDashSize);
            }
        }

        if(CanIDrawLine( prevActionPoint.m_PathToNextPoint[iCurrentPoint], self, m_pPlanningCtrl.m_iLevelDisplay, bDisplayInfo))
        {
            DrawDashedLine(prevActionPoint.m_PathToNextPoint[iCurrentPoint].Location, Location, m_CurrentColor, fDashSize);

        }
    }
}

function BOOL CanIDrawLine(actor FromPoint, actor ToPoint, INT iDisplayingFloor, BOOL bDisplayInfo)
{
    local R6Stairs StairsFromPoint, StairsToPoint;

    StairsFromPoint = R6Stairs(FromPoint);
    StairsToPoint = R6Stairs(ToPoint);

    if(bDisplayInfo)
        log("Displaying line from "$FromPoint$" To :"$ToPoint$" : "$FromPoint.m_iPlanningFloor_0$" : "$FromPoint.m_iPlanningFloor_1$" : "$ToPoint.m_iPlanningFloor_0$" : "$ToPoint.m_iPlanningFloor_1);

    //From one stairs to an other
    if((StairsFromPoint != none) && (StairsToPoint != none))
    {
        //If it's a link between two top or bottom points
        if(StairsFromPoint.m_bIsTopOfStairs == StairsToPoint.m_bIsTopOfStairs)
        {
            //if linking two top points and displaying bottom floor, don't display
            if(((StairsFromPoint.m_bIsTopOfStairs == true) && (FromPoint.m_iPlanningFloor_1 != iDisplayingFloor)) ||
               ((StairsFromPoint.m_bIsTopOfStairs == false) && (FromPoint.m_iPlanningFloor_0 != iDisplayingFloor)))
            {
                return false;
            }
            return true;
        }
        else
        {
            if(((ToPoint.m_iPlanningFloor_0 == iDisplayingFloor) ||
                (ToPoint.m_iPlanningFloor_1 == iDisplayingFloor)) &&
               ((FromPoint.m_iPlanningFloor_0 == iDisplayingFloor) ||
                (FromPoint.m_iPlanningFloor_1 == iDisplayingFloor)))
            {
                return true;
            }
            return false;
        }
    }

    //One of the two points is a R6Stairs
    if((StairsFromPoint != none) || (StairsToPoint != none))
    {
        if(StairsFromPoint != none)
        {
            if((ToPoint.m_iPlanningFloor_0 == iDisplayingFloor) ||
               (ToPoint.m_iPlanningFloor_1 == iDisplayingFloor))
            {
                return true;
            }
        }
        else 
        {
            if((FromPoint.m_iPlanningFloor_0 == iDisplayingFloor) ||
               (FromPoint.m_iPlanningFloor_1 == iDisplayingFloor))
            {
                return true;
            }
        }
        return false;
    }

    if((FromPoint.m_iPlanningFloor_0 == iDisplayingFloor) &&
       (FromPoint.m_iPlanningFloor_1 == iDisplayingFloor))
    {
        return true;
    }

    if(((FromPoint.m_iPlanningFloor_0 <= iDisplayingFloor) &&
        (FromPoint.m_iPlanningFloor_1 >= iDisplayingFloor)) ||
       ((ToPoint.m_iPlanningFloor_0 <= iDisplayingFloor) &&
        (ToPoint.m_iPlanningFloor_1 >= iDisplayingFloor)))
    {
        return true;
    }

    return false;
}

function ChangeActionType(EPlanActionType eNewType)
{
    local BOOL bDoIReset;
    if((m_eActionType == PACTTYP_Milestone) || (eNewType == PACTTYP_Milestone))
    {
        bDoIReset = true;
    }

    m_eActionType = eNewType;

    if(m_eActionType == PACTTYP_Normal)
    {
        m_pCurrentTexture = default.m_pCurrentTexture;
        m_pSelected = default.m_pSelected;
        Texture = m_pSelected;
        m_bSpriteShowFlatInPlanning=true;
    }
    else if(m_eActionType == PACTTYP_Milestone)
    {
        if(m_pPlanningCtrl != none)
            m_pPlanningCtrl.ResetIDs();
        bDoIReset = false;
        Texture = m_pSelected;
        m_bSpriteShowFlatInPlanning=false;
    }
    else
    {
        if(m_pPlanningCtrl != none)
            m_pCurrentTexture = m_pPlanningCtrl.GetActionTypeTexture(m_eActionType);
        m_pSelected = m_pCurrentTexture;
        Texture = m_pSelected;
        m_bSpriteShowFlatInPlanning=false;
    }

    if(bDoIReset && (m_pPlanningCtrl != none))
    {
        m_pPlanningCtrl.ResetIDs();
    }
}

// Set the Action type of the current ActionPoint , grenades or sniping or other?!
function SetPointAction(EPlanAction eAction, optional BOOL bLoading)
{
    //Set the action type
    m_eAction = eAction;

    //Reset the icons of current setting (if any)
    if(m_pActionIcon != None)
    {
        m_pActionIcon.Destroy();
        m_pActionIcon = None;
    }
    if(bLoading)
    {
        FindDoor();
    }
        
    if(eAction == PACT_Frag)
    {
        if(bLoading == false)
        {
            m_pActionIcon = Spawn(class'R6PlanningRangeFragGrenade',self,,Location);
            m_pActionIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
            m_pActionIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;    
#ifdefDEBUG
            m_pActionIcon.SetDrawScale(m_pPlanningCtrl.m_fDebugRangeScale);
#endif
            bHidden = true;
        }
        else
        {
            SetGrenade(m_vActionDirection);
        }
    }
    else if((eAction == PACT_Flash) ||
            (eAction == PACT_Gas) ||
            (eAction == PACT_Smoke))
    {
        if(bLoading == false)
        {
            m_pActionIcon = Spawn(class'R6PlanningRangeGrenade',self,,Location);
            m_pActionIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
            m_pActionIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;    
#ifdefDEBUG
            m_pActionIcon.SetDrawScale(m_pPlanningCtrl.m_fDebugRangeScale);
#endif
            bHidden = true;
        }
        else
        {
            SetGrenade(m_vActionDirection);
        }
    }
    else if(eAction == PACT_SnipeGoCode)
    {
        m_pActionIcon = Spawn(class'R6PlanningSnipe',self,,Location);
        m_pActionIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
        m_pActionIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;    
        if(bLoading)
        {
            m_pActionIcon.m_u8SpritePlanningAngle = m_rActionRotation.Yaw / 255;
        }
    }
    else if(eAction == PACT_Breach)
    {
        if(pDoor != none) //For a weird bug that happend Once!!! 
        {
            m_pActionIcon = Spawn(class'R6PlanningBreach',self, ,pDoor.m_vCenterOfDoor);
            m_pActionIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
            m_pActionIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;    
            R6PlanningBreach(m_pActionIcon).SetSpriteAngle(pDoor.m_iYawInit, Location);
        }
        else
        {
            m_eAction = PACT_None;
        }
    }

}

function FindDoor()
{
    local vector                    vDistanceVect;
    local INT                       iPreviousDistance;
    local R6IORotatingDoor          pRotatingDoor;
    local R6Door                    pDoorTest;

    iPreviousDistance = 25000;

    m_bDoorInRange = false;
    foreach VisibleCollidingActors( class'R6Door', pDoorTest, 150, Location )
    {
        if (bShowLog) log("Found door "$pDoorTest.m_RotatingDoor$" for "$Self);        

        if(!pDoorTest.m_RotatingDoor.m_bTreatDoorAsWindow)
        {
            pRotatingDoor = pDoorTest.m_RotatingDoor;
            vDistanceVect = pDoorTest.Location - Location;
            vDistanceVect.Z = 0;  //2D only
            vDistanceVect *= vDistanceVect;

            if((vDistanceVect.X + vDistanceVect.Y) < iPreviousDistance)
            {
                m_bDoorInRange = true;
                pDoor = pRotatingDoor;
                iPreviousDistance = vDistanceVect.X + vDistanceVect.Y; 
            }
        }
    }
    if (bShowLog) log("Kept door : "$pDoor);
}

function SetMileStoneIcon(INT iMileStone)
{
    if(m_pPlanningCtrl != none)
    {
        if(m_eActionType != PACTTYP_Normal)
        {
            m_pCurrentTexture = m_pPlanningCtrl.GetActionTypeTexture(PACTTYP_Milestone, iMileStone);
            m_pSelected = m_pCurrentTexture;
            Texture = m_pSelected;
        }
        else
        {
            m_pCurrentTexture = default.m_pCurrentTexture;
            m_pSelected = default.m_pSelected;
            Texture = m_pSelected;
        }
    }
}

function BOOL SetGrenade(vector vHitLocation)
{
    local R6PlanningGrenade pGrenadeIcon;

    //Spawn the grenade
    pGrenadeIcon = Spawn(class'R6PlanningGrenade',self, ,vHitLocation);
    pGrenadeIcon.SetGrenadeType(m_eAction);
    pGrenadeIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
    pGrenadeIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;    

    m_pPlanningCtrl.Pawn.SetLocation(Location);
    if( m_pPlanningCtrl.PlanningTrace(Location, pGrenadeIcon.Location) == false)
    {
        //See if we can use a door to throw the grenade
        if(CanIThrowGrenadeThroughDoor(vHitLocation) == false)
        {
            pGrenadeIcon.Destroy();
            return false;
        }
    }

    //Destroy the range icon
    if(m_pActionIcon != none)
    {
        m_pActionIcon.Destroy();
    }
    m_vActionDirection=vHitLocation;
    m_pActionIcon = pGrenadeIcon;
    return true;
}

function BOOL CanIThrowGrenadeThroughDoor(vector vHitLocation)
{
    local R6IORotatingDoor          pRotatingDoor;
    local R6Door                    pDoorNav;

    foreach VisibleCollidingActors( class'R6IORotatingDoor', pRotatingDoor, 300, Location )
    {
        //Find if it's possible to throw a grenade through the door.
        //Check which R6Door we can see.
        if( m_pPlanningCtrl.PlanningTrace(Location, pRotatingDoor.m_DoorActorA.Location) == true)
        {
            pDoorNav = pRotatingDoor.m_DoorActorB;
        }
        else if( m_pPlanningCtrl.PlanningTrace(Location, pRotatingDoor.m_DoorActorB.Location) == true)
        {
            pDoorNav = pRotatingDoor.m_DoorActorA;
        }

        //from the other, check if we can reach the grenade
        if(pDoorNav != none)
        {
            if(m_pPlanningCtrl.PlanningTrace(vHitLocation, pDoorNav.Location) == true)
            {
                pDoor = pRotatingDoor;
                return true;
            }
        }
    }
    return false;
}

function SetFirstPointTexture()
{
    m_pCurrentTexture=Texture'R6Planning.Icons.PlanIcon_StartPoint';
}

function UnselectPoint()
{
    m_PlanningColor = m_CurrentColor;
    Texture = m_pCurrentTexture;
    SetTimer(0,false);
}

function SelectPoint()
{
    if(m_pCurrentTexture != m_pSelected)
    {
        Texture = m_pSelected;
    }
    SetTimer(0.5,true);
}

function Timer()
{
    if(m_PlanningColor != m_CurrentColor)
    {
        m_PlanningColor = m_CurrentColor;
    }
    else
    {
        m_PlanningColor.R = 255;
        m_PlanningColor.G = 255;
        m_PlanningColor.B = 255;
    }
}

// Set texture color 
function SetDrawColor(Color NewColor)
{
    m_CurrentColor = NewColor;
    m_PlanningColor = NewColor;
}

function Init3DView( FLOAT X, FLOAT Y)
{
    m_iInitialMousePosX = X;
    m_iInitialMousePosY = Y;
}

// Move the pNode ActionPoint at the screen coordinate X, Y
function RotateView( FLOAT X, FLOAT Y)
{
    // R6-3DVIEWPORT
    local FLOAT fDeltaX, fDeltaY;
    local rotator NodeRotation;
    
    if(bShowLog) Log("-->RotateView");

    fDeltaX = (m_iInitialMousePosX - X) / 640.0;
    fDeltaY = (m_iInitialMousePosY - Y) / 480.0;

    NodeRotation.Pitch = Rotation.Pitch + fDeltaY * 32768.0;
    NodeRotation.Yaw = Rotation.Yaw - fDeltaX * 65536.0;
    SetRotation(NodeRotation);
}


/*
    NavigationPoint info from UnProg

upstreamPaths[] is an array of reachspecs whose end point is the current
NavigationPoint.
Paths[] is an array of reachspecs whose starting point is the current
NavigationPoint.
PrunedPaths[] is an array of reachspecs which were pruned from the graph
because there were acceptable pairs of reachspecs which had the same start
and end points, without adding too much extra distance.  The PrunedPaths are
not used when traversing the navigation graph, but are sometimes used when
looking for adjacent NavigationPoints.
VisNoReachPaths[] is an array of NavigationPoints which are visible but not
reachable from this NavigationPoint.

Significance of Path Node line Color:
Blue means this path will support larger pawns ( as defined by MonsterPath()
in UnReach.Cpp).  Red paths only support smaller creatures, and are
guaranteed to work for at least Unreal I player sized pawns.  Blue paths are
always better, even for smaller creatures, because there is more margin for
error.
*/

defaultproperties
{
     m_eMovementSpeed=SPEED_Normal
     m_pCurrentTexture=Texture'R6Planning.Icons.PlanIcon_ActionPoint'
     m_pSelected=Texture'R6Planning.Icons.PlanIcon_SelectedPoint'
     m_eDisplayFlag=DF_ShowOnlyInPlanning
     bProjTarget=True
     m_bSpriteShowFlatInPlanning=True
     DrawScale=1.250000
     CollisionRadius=20.000000
     CollisionHeight=20.000000
}
