//=============================================================================
//  R6AbstractPlanningInfo.uc : This is the abstract class for the R6PlanningInfo class.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    august 8th, 2001 * Created by Chaouky Garram
//=============================================================================
class R6AbstractPlanningInfo extends Object
    native;


enum EGoCodeState
{
    GOCODESTATE_None,
    GOCODESTATE_Waiting,
    GOCODESTATE_Snipe,
    GOCODESTATE_Breach,
    GOCODESTATE_Done
};

// Planning Data
var array<Actor>           m_NodeList;              // List of Node
var       INT              m_iCurrentNode;          // Index of current node
var       INT              m_iCurrentPathIndex;     // Current point in the path to the next point.
var       INT              m_iStartingPointNumber;  //Index of the starting location.

var       actor         m_pTeamManager;     // RainbowTeam having this "path"
var       EGoCodeState  m_eGoCodeState[4];  // State of GoCode of the [EGoCode] team
var       INT           m_iNbNode;          // Number of ActionPoint in the team path
var       INT           m_iNbMilestone;     // Number of Milestone in planning.
var       FLOAT         m_fReachRange;      // Distance (x,y) between the team and the node to be considerate as reach!
var		  FLOAT			m_fZReachRange;		// Distance in Z between the team and the node
var       BOOL          m_bDisplayPath;     // Is this path display? -USED IN MENU ONLY
var       BOOL          m_bPlanningOver;    // RainbowTeam has finished the planning
var       BOOL          m_bPlacedFirstPoint;// Placing first point in insertion zone (used only during Planning phase)

// Default value of ActionPoint
var const EMovementMode     m_eDefaultMode;
var const EMovementSpeed    m_eDefaultSpeed;
var const EPlanAction       m_eDefaultAction;
var const EPlanActionType   m_eDefaultActionType;

// Team Data
var Color                   m_TeamColor;    // Color of the team

// Debug Data
var       INT           DEB_iStartTime;
var(Debug)BOOL          bShowLog;

const R6InputKey_NewNode = 1025;

var BOOL bDisplayDbgInfo;

function ResetPointsOrientation()
{}

function NotifyActionPoint(ENodeNotify eMsg, EGoCode eCode)
{}

function EPlanAction GetAction()
{
    return PACT_None;
}

function EMovementMode GetMovementMode()
{
    return MOVE_Assault;
}

function EMovementSpeed GetMovementSpeed()
{
    return SPEED_Normal;
}

function SkipCurrentDestination();

function actor GetFirstActionPoint()
{
    return m_NodeList[0];
}

function actor GetNextActionPoint()
{
    return none;
}

function actor PreviewNextActionPoint()
{
    return none;
}

function EPlanAction NextActionPointHasAction(actor aPoint)
{
	return PACT_None;
}

function actor GetPreviousActor()
{
    return none;
}

function INT GetActionPointID()
{
    return 0;
}

function INT GetNbActionPoint()
{
    return 0;
}

function Vector GetActionLocation()
{
    return Vect(0,0,0);
}

function PlayerStart GetStartingPoint()
{
    return None;
}

function GetSnipingCoordinates(out vector vLocation, out rotator rRotation)
{
}

function actor GetDoorToBreach()
{
	return none;
}

function actor GetNextDoorToBreach(actor aPoint)
{
	return none;
}

function ResetID()
{
    //Defined in R6PlanningInfo
}

function DeleteAllNode();

defaultproperties
{
}
