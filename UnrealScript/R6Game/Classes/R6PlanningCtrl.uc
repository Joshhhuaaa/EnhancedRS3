//=============================================================================
//  R6PlanningCtrl.uc : (top-view camera of the planning)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/08 * Created by Chaouky Garram
//    2002/02/02 * Taken over and rewritten by Joel Tremblay
//=============================================================================

class R6PlanningCtrl extends PlayerController
    native;

var INT                     m_iCurrentTeam;     // editing which team
var R6PlanningInfo          m_pTeamInfo[3];     // the team's planning
var R6FileManagerPlanning   m_pFileManager;     // to load/save planning
var R6CameraDirection       m_pCameraDirIcon;   // Icon to show where the camera is looking at.
var Actor                   m_pOldHitActor;     // not change floor when an actor is selected twice.

var Texture                 m_pIconTex[12];      // List of the ActionType icon texture

//  camera movement parameters
var Vector      m_vCurrentCameraPos;
var Vector      m_vCamPos;          // Camera Location for zoom
var Vector      m_vCamPosNoRot;     // Camera position Without any rotation.
var Vector      m_vCamDesiredPos;   // Camera will reach this direction.
var Rotator     m_rCamRot;          // Camera Rotation

var FLOAT       m_fLastMouseX;      // mouse last move location to find the sniping direction
var FLOAT       m_fLastMouseY;      // mouse last move location to find the sniping direction

var FLOAT       m_fZoom;            // Zoom
var FLOAT       m_fZoomDelta;       // Modification request on the zoom
var FLOAT       m_fZoomRate;        // Zoom speed
var FLOAT       m_fZoomMin;         // Minimum Zoom of the camera
var FLOAT       m_fZoomMax;
var FLOAT       m_fZoomFactor;      // to adapt camera speeds with current zoom

var FLOAT       m_fCameraAngle;     // Change the camera Angle
var FLOAT       m_fAngleRate;         
var FLOAT       m_fAngleMax;        // max distance on X to calculate the angle  min is obviously 0

var FLOAT       m_fRotateDelta;    // Modification request on the rotation
var FLOAT       m_fRotateRate;     // Speed of the rotation

var Vector      m_vCamDelta;        // Modification request on camera deplacement
var FLOAT       m_fCamRate;         // 

var actor       m_CamSpot;         // camera spot if 3d view is on without action point


var (R6Planning) const FLOAT m_fCastingHeight;      // Height between the ground and the ActionPoint casted

var INT                      m_3DWindowPositionX;       // region send by the planning widget to set the 3d window size.
var INT                      m_3DWindowPositionY;       // region send by the planning widget to set the 3d window size.
var INT                      m_3DWindowPositionW;       // region send by the planning widget to set the 3d window size.
var INT                      m_3DWindowPositionH;       // region send by the planning widget to set the 3d window size.
var BOOL                     m_bRender3DView;          // 3D view is activated
var BOOL                     m_bMove3DView;
var BOOL                     m_bActionPointSelected;     // to drag drop selected point.
var BOOL                     m_bCanMoveFirstPoint;     // When dragging the first point, it must be dropped on an insertion zone
var BOOL                     m_bClickToFindLocation;   // Next click is to set an action
var BOOL                     m_bClickedOnRange;        // When clicked on range icon, set to true
var BOOL                     m_bSetSnipeDirection;     // mouse is moving to set the Sniping direction
var BOOL                     m_bPlayMode;              // Play mode has been activated
var BOOL                     m_bLockCamera;

var Vector                   m_vMinLocation;        // Minimum location X,Y of the camera(Restriction from the map)
var Vector                   m_vMaxLocation;

var INT                      m_iLevelDisplay;    // Current floor displayed

var(Debug) bool              bShowLog;        // Show debug info
//#ifdefDEBUG
var        FLOAT             m_fDebugRangeScale;
//#endif

var bool                     m_bFirstTick;

var Sound                    m_PlanningBadClickSnd;
var Sound                    m_PlanningGoodClickSnd;
var Sound                    m_PlanningRemoveSnd;


const R6InputKey_ActionPopup   = 1024;
const R6InputKey_PathFlagPopup = 1026;

native(2013) final function BOOL GetClickResult(FLOAT X, FLOAT Y, out Vector HitLocation, out actor HitActor, out INT iChangeLevelTo);
//Get a 3d point where z = 0 using the X Y coordinates
native(2016) final function Vector GetXYPoint(FLOAT X, FLOAT Y, FLOAT Height);
// returns true if did not hit world geometry, excluding doors and windows.
native(2017) final function BOOL PlanningTrace(vector vTraceEnd, vector vTraceStart);

function PostBeginPlay()
{
    local ZoneInfo pZone;
    local INT       iCurrentPlanning;
    local INT       iCurrentInsertionNumber;
	local R6InsertionZone anInsertionZone;
    local R6IORotatingDoor aDoor;
    local R6IOSlidingWindow aWindow;
    local R6ReferenceIcons pSpawnedIcon;
    local R6ReferenceIcons          RefIco;  
    local R6AbstractInsertionZone NavPoint;
    local R6AbstractExtractionZone ExtZone;

    #ifdefDEBUG if(bShowLog) log("-->"$self$"->Spawned()"); #endif
    SetFOVAngle(m_fZoom * 90);
    //FovAngle = m_fZoom * 90;

    if(m_pCameraDirIcon == none)
    {
        m_pCameraDirIcon = spawn(class'R6CameraDirection',self);
    }

    if(m_pFileManager == none) 
    {
        m_pFileManager = new(None) class'R6FileManagerPlanning';         
    }

    iCurrentInsertionNumber = MaxInt;
    foreach AllActors( class 'R6InsertionZone', anInsertionZone )
    {
		if(anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag))
        {
            if(anInsertionZone.m_iInsertionNumber < iCurrentInsertionNumber)
            {
                iCurrentInsertionNumber = anInsertionZone.m_iInsertionNumber;
                SetFloorToDraw(anInsertionZone.m_iPlanningFloor_0);
                m_iLevelDisplay = anInsertionZone.m_iPlanningFloor_0;
                m_vCamPosNoRot = anInsertionZone.location;
                m_vCamDesiredPos = anInsertionZone.location;
            }
            break;
        }
    }
    foreach AllActors( class'R6IORotatingDoor', aDoor)
    {
        //Reset display properties to all doors for in-game map
        aDoor.m_eDisplayFlag=DF_ShowOnlyIn3DView;

        if(aDoor.m_bTreatDoorAsWindow == false)
        {
            if(aDoor.m_bIsDoorLocked == true )
            {
                pSpawnedIcon = Spawn(class'R6DoorLockedIcon',,, aDoor.m_vCenterOfDoor);
            }
            else
            {
                pSpawnedIcon = Spawn(class'R6DoorIcon',,, aDoor.m_vCenterOfDoor);
            }

            pSpawnedIcon.m_u8SpritePlanningAngle = aDoor.Rotation.Yaw / 255;
            pSpawnedIcon.m_iPlanningFloor_0 = aDoor.m_iPlanningFloor_0;
            pSpawnedIcon.m_iPlanningFloor_1 = aDoor.m_iPlanningFloor_1;

            if(aDoor.m_bIsOpeningClockWise == false)
            {
                pSpawnedIcon.SetDrawScale3D(vect(1,-1,1));
            }
        }
    }

    foreach AllActors( class 'R6ReferenceIcons', RefIco)
    {
        RefIco.bHidden = false;
    }

    foreach AllActors( class 'R6AbstractInsertionZone', NavPoint )
    {
        if(NavPoint.isAvailableInGameType( R6AbstractGameInfo(Level.Game).m_szGameTypeFlag ))
            NavPoint.bHidden = false;
    }
    foreach AllActors( class 'R6AbstractExtractionZone', ExtZone )
    {
        if(ExtZone.isAvailableInGameType( R6AbstractGameInfo(Level.Game).m_szGameTypeFlag ))
            ExtZone.bHidden = false;
    }
    
    m_CamSpot = Level.GetCamSpot( Level.Game.m_szGameTypeFlag );

    //We dont't need to render 3d when are in the menus
    Level.m_bAllow3DRendering = False;
}

function Set3DViewPosition(INT NewX, INT NewY, INT NewH, INT NewW)
{
    #ifdefDEBUG if(bShowLog) log("3DPos = "$NewX$","$NewY$","$NewW$","$NewH); #endif
    m_3DWindowPositionX = NewX;
    m_3DWindowPositionY = NewY;
    m_3DWindowPositionW = NewW;
    m_3DWindowPositionH = NewH;
}

function SetPlanningInfo()
{
    #ifdefDEBUG if (bShowLog) log("Setting Planning Info from Master to PlanningController"); #endif

    m_pTeamInfo[0] = R6PlanningInfo(Player.Console.Master.m_StartGameInfo.m_TeamInfo[0].m_pPlanning);
    m_pTeamInfo[1] = R6PlanningInfo(Player.Console.Master.m_StartGameInfo.m_TeamInfo[1].m_pPlanning);
    m_pTeamInfo[2] = R6PlanningInfo(Player.Console.Master.m_StartGameInfo.m_TeamInfo[2].m_pPlanning);

    //Set the Team Manager as the planning controller here, for GetLevel in native funcitons
    m_pTeamInfo[0].m_pTeamManager = self;
    m_pTeamInfo[1].m_pTeamManager = self;
    m_pTeamInfo[2].m_pTeamManager = self;

    //Initial starting point.  If not changed by the planning.
    m_pTeamInfo[0].m_iStartingPointNumber = Player.Console.Master.m_StartGameInfo.m_TeamInfo[0].m_iSpawningPointNumber;
    m_pTeamInfo[1].m_iStartingPointNumber = Player.Console.Master.m_StartGameInfo.m_TeamInfo[1].m_iSpawningPointNumber;
    m_pTeamInfo[2].m_iStartingPointNumber = Player.Console.Master.m_StartGameInfo.m_TeamInfo[2].m_iSpawningPointNumber;

    //Set the team color
    m_pTeamInfo[0].m_TeamColor = WindowConsole(Player.Console).Root.Colors.TeamColorLight[0];
    m_pTeamInfo[1].m_TeamColor = WindowConsole(Player.Console).Root.Colors.TeamColorLight[1];
    m_pTeamInfo[2].m_TeamColor = WindowConsole(Player.Console).Root.Colors.TeamColorLight[2];
}

//function called after a planning has been loaded to spawn the reference icons and pathflags
function InitNewPlanning(INT iSelectedTeam)
{
    m_iCurrentTeam = iSelectedTeam;
    m_pTeamInfo[0].InitPlanning(0,self);
    m_pTeamInfo[1].InitPlanning(1,self);
    m_pTeamInfo[2].InitPlanning(2,self);
    if(m_iCurrentTeam == 0)
        SwitchToRedTeam(true);
    else if(m_iCurrentTeam == 1)
        SwitchToGreenTeam(true);
    else if(m_iCurrentTeam == 2)
        SwitchToGoldTeam(true);
}

event Destroyed()
{
    //log("Planning Controller "$self$" Destroyed!");
    m_pTeamInfo[0].RemovePointsRefsToCtrl();
    m_pTeamInfo[0].m_pTeamManager = none;
    m_pTeamInfo[1].RemovePointsRefsToCtrl();
    m_pTeamInfo[1].m_pTeamManager = none;
    m_pTeamInfo[2].RemovePointsRefsToCtrl();
    m_pTeamInfo[2].m_pTeamManager = none;
    Super.Destroyed();
}


// Update the camera location & rotation changed by the menu
event PlayerTick( float fDeltaTime )
{
    local Vector    vAxisX;
    local Vector    vAxisY;
    local Vector    vAxisZ;
    local Vector    vHitLocation;
    local FLOAT     fMovementX;
    local FLOAT     fMovementY;
    local FLOAT     fAngle;
    local INT       iCurrentPlanning;
    local R6ActionPoint pCurrentPoint;
    
    Super.PlayerTick(fDeltaTime);

    //Planning info's tick is not called, it's not an actor.
    if(WindowConsole(Player.Console).Root.PlanningShouldDrawPath())
    {
        m_pTeamInfo[0].Tick(fDeltaTime);
        m_pTeamInfo[1].Tick(fDeltaTime);
        m_pTeamInfo[2].Tick(fDeltaTime);
    }

    // Zoom
    if(m_fZoomDelta!=0.0)
    {
        m_fZoom += m_fZoomDelta * fDeltaTime;
        m_fZoom = FClamp(m_fZoom, m_fZoomMin, m_fZoomMax);
        m_fZoomFactor = m_fZoom * 12;

        FovAngle = m_fZoom * 90;
    }

    //Camera angle.
    if(m_fCameraAngle!=0) 
    {
        //log("Before Pitch : "$m_rCamRot.Pitch$" X: "$m_vCamPos.X$" Z: "$m_vCamPos.Z);
        m_vCamPos.X = FClamp(m_vCamPos.X + (m_fCameraAngle * m_fZoomFactor * fDeltaTime), m_fAngleMax + 5000, 1);
        fAngle = sin(acos(m_vCamPos.X / m_fAngleMax));
        m_vCamPos.Z = 15000 * fAngle;

        fAngle = atan(m_vCamPos.Z / m_vCamPos.X);
        fAngle /= (PI*0.5);
        m_rCamRot.Pitch = 65536 - INT(abs(fAngle) * 16384);
        //log("after Pitch : "$m_rCamRot.Pitch$" X: "$m_vCamPos.X$" Z: "$m_vCamPos.Z);
    }


    // Rotate
    if(m_fRotateDelta!=0.0)
    {
        m_rCamRot.Yaw += m_fRotateDelta * fDeltaTime;
    }

    GetAxes(m_rCamRot,vAxisX,vAxisY,vAxisZ);
    vAxisY.Z = 0;
    vAxisY = Normal(vAxisY);
    vAxisZ.Z = 0;
    vAxisZ = Normal(vAxisZ);

    //While Play mode activated, camera movement is prohibited
    if((m_bPlayMode == TRUE) && (m_bLockCamera == TRUE))
    {
        m_vCamPosNoRot = R6PlanningPawn(Pawn).m_ArrowInPlanningView.Location;
        m_vCamDesiredPos = m_vCamPosNoRot;
    }
    else
    {
        fMovementX = m_vCamDelta.Y * fDeltaTime * m_fZoomFactor;
        fMovementY = m_vCamDelta.X * fDeltaTime * m_fZoomFactor;
    
        //Limit the camera movements.
        if((m_vCamDesiredPos == m_vCamPosNoRot) || (fMovementX != 0) || (fMovementY != 0))
        {
            m_vCamPosNoRot.X = FClamp((m_vCamPosNoRot.X + (fMovementX * vAxisY.Y) + (fMovementY * vAxisY.X)), Level.R6PlanningMinVector.X, Level.R6PlanningMaxVector.X);
            m_vCamPosNoRot.Y = FClamp((m_vCamPosNoRot.Y + (fMovementX * vAxisZ.Y) + (fMovementY * vAxisZ.X)), Level.R6PlanningMinVector.Y, Level.R6PlanningMaxVector.Y);
            m_vCamDesiredPos = m_vCamPosNoRot;
        }
        else //Move Camera To
        {
            m_vCamPosNoRot.X = FClamp((m_vCamPosNoRot.X + ((m_vCamDesiredPos.X - m_vCamPosNoRot.X) * fDeltaTime)), Level.R6PlanningMinVector.X, Level.R6PlanningMaxVector.X);
            m_vCamPosNoRot.Y = FClamp((m_vCamPosNoRot.Y + ((m_vCamDesiredPos.Y - m_vCamPosNoRot.Y) * fDeltaTime)), Level.R6PlanningMinVector.Y, Level.R6PlanningMaxVector.Y);
            if( VSize(m_vCamDesiredPos - m_vCamPosNoRot) < 20)
            {
                m_vCamDesiredPos = m_vCamPosNoRot;
            }
        }
    }
    
    if(m_bSetSnipeDirection == true)
    {
        vHitLocation = GetXYPoint(m_fLastMouseX, m_fLastMouseY, GetCurrentPoint().Location.Z);
        m_pTeamInfo[m_iCurrentTeam].AjustSnipeDirection(vHitLocation);
    }
    
    m_vCurrentCameraPos.X = m_vCamPosNoRot.X + (m_vCamPos.X * vAxisY.Y);
    m_vCurrentCameraPos.Y = m_vCamPosNoRot.Y + (m_vCamPos.X * vAxisZ.Y);
    m_vCurrentCameraPos.Z = m_vCamPos.Z;
    
    // R6-3DVIEWPORT
    if(m_bRender3DView == true)
    {
        if(m_bPlayMode == TRUE)
        {
            m_pCameraDirIcon.bHidden = true;
            R6PlanningPawn(Pawn).m_ArrowInPlanningView.RenderLevelFromMe(m_3DWindowPositionX, m_3DWindowPositionY, m_3DWindowPositionW, m_3DWindowPositionH);
        }
        else
        {
            pCurrentPoint = GetCurrentPoint();
            if(pCurrentPoint != none)
            {
                pCurrentPoint.RenderLevelFromMe(m_3DWindowPositionX, m_3DWindowPositionY, m_3DWindowPositionW, m_3DWindowPositionH);
                
                m_pCameraDirIcon.bHidden = false;
                m_pCameraDirIcon.SetLocation(pCurrentPoint.Location);
                m_pCameraDirIcon.SetPlanningRotation(pCurrentPoint.Rotation);
                m_pCameraDirIcon.m_iPlanningFloor_0 = pCurrentPoint.m_iPlanningFloor_0;
                m_pCameraDirIcon.m_iPlanningFloor_1 = pCurrentPoint.m_iPlanningFloor_1;
            }
            else
            {
                m_pCameraDirIcon.bHidden = true;
                if(m_CamSpot != none)
                {
                    m_CamSpot.RenderLevelFromMe(m_3DWindowPositionX, m_3DWindowPositionY, m_3DWindowPositionW, m_3DWindowPositionH);
                    return;
                }
                RenderLevelFromMe(m_3DWindowPositionX, m_3DWindowPositionY, m_3DWindowPositionW, m_3DWindowPositionH);
            }
        }
    }

}

state PlayerWalking
{
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		if((pawn == none) || (WindowConsole(Player.Console).Root.PlanningShouldProcessKey() == false))
			return;

        //Rotating using the Peek keys
        if(m_bRotateCW == m_bRotateCCW)
        {
            m_fRotateDelta = 0;
        }
        else if(m_bRotateCW == 1)
        {
            m_fRotateDelta = m_fRotateRate;
        }
        else if(m_bRotateCCW == 1)
        {
            m_fRotateDelta = -m_fRotateRate;
        }

        //Moving the camera with the buttons
        if(m_bMoveLeft == m_bMoveRight) 
        {
            m_vCamDelta.X = 0;
        }
        else if(m_bMoveRight == 1) //right
        {
            m_vCamDelta.X = m_fCamRate;
        }
        else if(m_bMoveLeft == 1) //left
        {
            m_vCamDelta.X = -m_fCamRate;
        }

        if(m_bMoveUp == m_bMoveDown)
        {
            m_vCamDelta.Y = 0;
        }
        else if(m_bMoveUp == 1)
        {
            m_vCamDelta.Y = m_fCamRate;
        }
        else if(m_bMoveDown == 1)
        {
            m_vCamDelta.Y = -m_fCamRate;
        }

        if(m_bAngleUp == m_bAngleDown)
        {
            m_fCameraAngle = 0;
        }
        else if(m_bAngleUp == 1)
        {
            m_fCameraAngle = m_fAngleRate;
        }
        else if(m_bAngleDown == 1)
        {
            m_fCameraAngle = -m_fAngleRate;
        }

        //Zoom stuff
        if(m_bZoomIn == m_bZoomOut)
        {
            m_fZoomDelta = 0;
        }
        else if(m_bZoomIn == 1)
        {
            m_fZoomDelta = -m_fZoomRate;
        }
        else if(m_bZoomOut == 1)
        {
            m_fZoomDelta = m_fZoomRate;
        }

        if(m_bLevelUp == 1)
        {
            if(m_bGoLevelUp == 1)
            {
                m_bGoLevelUp = 0;
                if( !((m_bPlayMode == true) && (m_bLockCamera == TRUE)))
                {
                    ChangeLevelDisplay(1);
                    m_vCamDesiredPos = m_vCamPosNoRot;
                }
            }
        }
        if(m_bLevelDown == 1)
        {
            if(m_bGoLevelDown == 1)
            {
                m_bGoLevelDown = 0;
                if( !((m_bPlayMode == true) && (m_bLockCamera == TRUE)))
                {
                    ChangeLevelDisplay(-1);
                    m_vCamDesiredPos = m_vCamPosNoRot;
                }
            }
        }
    }
}

//=======================================================================================//
//                          INPUT exec() functions (controls)                            //
//=======================================================================================//
exec function DeleteWaypoint()
{
    if((m_bPlayMode == FALSE) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey())
    {
        DeleteOneNode();
    }
}

exec function PrevWaypoint()
{
    if((m_bPlayMode == FALSE) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey())
    {
        GotoPrevNode();
    }
}

exec function NextWaypoint()
{
    if((m_bPlayMode == FALSE) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey())
    {
        GotoNextNode();
    }
}

exec function FirstWaypoint()
{
    if((m_bPlayMode == FALSE) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey())
    {
        GotoFirstNode();
    }
}

exec function LastWaypoint()
{
    if((m_bPlayMode == FALSE) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey())
    {
        GotoLastNode();
    }
}

exec function SwitchToRedTeam(optional BOOL bForceFunction)
{
    if((bForceFunction == true) || (m_bPlayMode == FALSE) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey() 
        && (m_bSetSnipeDirection == false) && (m_bClickToFindLocation == false))
    {
        m_iCurrentTeam = 0;
        m_pTeamInfo[0].SelectTeam(true);
        m_pTeamInfo[1].SelectTeam(false);
        m_pTeamInfo[2].SelectTeam(false);
        m_pTeamInfo[0].SetPathDisplay(true);
        MoveCamOver();
        WindowConsole(Player.Console).Root.UpdateMenus(0);
    }
}
exec function SwitchToGreenTeam(optional BOOL bForceFunction)
{
    if((bForceFunction == true) || (m_bPlayMode == FALSE) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey() 
        && (m_bSetSnipeDirection == false) && (m_bClickToFindLocation == false))
    {
        m_iCurrentTeam = 1;
        m_pTeamInfo[0].SelectTeam(false);
        m_pTeamInfo[1].SelectTeam(true);
        m_pTeamInfo[2].SelectTeam(false);
        m_pTeamInfo[1].SetPathDisplay(true);
        MoveCamOver();
        WindowConsole(Player.Console).Root.UpdateMenus(1);
    }
}
exec function SwitchToGoldTeam(optional BOOL bForceFunction)
{
    if((bForceFunction == true) || (m_bPlayMode == FALSE) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()
        && (m_bSetSnipeDirection == false) && (m_bClickToFindLocation == false))
    {
        m_iCurrentTeam = 2;
        m_pTeamInfo[0].SelectTeam(false);
        m_pTeamInfo[1].SelectTeam(false);
        m_pTeamInfo[2].SelectTeam(true);
        m_pTeamInfo[2].SetPathDisplay(true);
        MoveCamOver();
        WindowConsole(Player.Console).Root.UpdateMenus(2);
    }
}
exec function ViewRedTeam()
{
    if(WindowConsole(Player.Console).Root.PlanningShouldProcessKey() && (m_iCurrentTeam != 0))
    {
        m_pTeamInfo[0].SetPathDisplay(!m_pTeamInfo[0].m_bDisplayPath);
        WindowConsole(Player.Console).Root.UpdateMenus(3);

    }
}
exec function ViewGreenTeam()
{
    if(WindowConsole(Player.Console).Root.PlanningShouldProcessKey() && (m_iCurrentTeam != 1))
    {
        m_pTeamInfo[1].SetPathDisplay(!m_pTeamInfo[1].m_bDisplayPath);
        WindowConsole(Player.Console).Root.UpdateMenus(4);
    }
}
exec function ViewGoldTeam()
{
    if(WindowConsole(Player.Console).Root.PlanningShouldProcessKey() && (m_iCurrentTeam != 2))
    {
        m_pTeamInfo[2].SetPathDisplay(!m_pTeamInfo[2].m_bDisplayPath);
        WindowConsole(Player.Console).Root.UpdateMenus(5);
    }
}

#ifdefDEBUG
exec function Coords()
{
    log("Camera looking at coordinates :"$m_vCamPosNoRot);
}
#endif


//=======================================================================================//


// Setup the new Location & Rotation
event PlayerCalcView(out Actor aViewActor, out Vector vCameraLocation, out Rotator rCameraRotation )
{
    // Rotation
    rCameraRotation = m_rCamRot;
    
    // Location
//    vCameraLocation = m_vCamPos;
    vCameraLocation = m_vCurrentCameraPos;
}

// Empty this function, it change the FOV ... we don't change the FOV here
function FixFOV()
{}

// Empty this function, it change the FOV ... we don't change the FOV here
function AdjustView(float DeltaTime )
{}

function Toggle3DView()
{
    m_pCameraDirIcon.bHidden = m_bRender3DView;
    m_bRender3DView = !m_bRender3DView;
}
function TurnOff3DView()
{
    m_bRender3DView = false;
    m_pCameraDirIcon.bHidden = true;
}

function TurnOn3DMove(FLOAT X, FLOAT Y)
{
    m_bMove3DView = !m_bMove3DView;
    if(m_bMove3DView && (GetCurrentPoint() != none))
    {
        GetCurrentPoint().Init3DView( X, Y);
    }
}

function TurnOff3DMove()
{
    m_bMove3DView = false;
}

function Ajust3DRotation(FLOAT X, FLOAT Y)
{
    if(GetCurrentPoint() != none)
    {
        GetCurrentPoint().RotateView( X, Y);
    }
}

// Toggle the floor display
function ChangeLevelDisplay(int iStep)
{
    if(iStep > 0)
    {
        if(m_iLevelDisplay < Level.R6PlanningMaxLevel)
        {
            m_iLevelDisplay += iStep;
            SetFloorToDraw(m_iLevelDisplay);
        }
    }
    else
    {
        if(m_iLevelDisplay > Level.R6PlanningMinLevel)
        {
            m_iLevelDisplay += iStep;
            SetFloorToDraw(m_iLevelDisplay);
        }
    }
}

//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function LMouseDown( FLOAT X, FLOAT Y)
{
    local Actor pHitActor;
    local Vector vHitLocation;
    local Vector vHitNormal;
    local Vector vSpawnOffset;
    local R6ActionPoint FirstActionPoint;
    local INT iChangeLevelTo;
    local R6Ladder aHitActorLadder;
    local R6ActionPoint pCurrentPoint;

    if(m_bPlayMode == TRUE)
    {
        //do nothing while in playmode
        return;
    }

    if(m_bSetSnipeDirection == true)
    {
        //Stop selecting the snipe direction
        m_bSetSnipeDirection = false;
        WindowConsole(Player.Console).Root.m_bUseAimIcon = false;
        return;
    }

    pCurrentPoint = GetCurrentPoint();
    if(GetClickResult( X, Y, vHitLocation, pHitActor, iChangeLevelTo ) == TRUE) 
    {
        if(m_bClickToFindLocation == true)
        {
            if(m_bClickedOnRange == false)
            {
                //Add a grenade on range icon only
                if((pHitActor != none) && pHitActor.IsA('R6PlanningRangeGrenade'))
                {
                    m_bClickedOnRange = true;
                    pHitActor.bHidden = true;
                    LMouseDown( X, Y );
                    pHitActor.bHidden = false;
                }
                else if((pHitActor != none) && pHitActor.IsA('R6CameraDirection'))
                {
                    pHitActor.bHidden = true;
                    LMouseDown( X, Y );
                    pHitActor.bHidden = false;
                }
                else
                {
                    PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
                }
            }
            else
            {
                if((pHitActor != none) && !(pHitActor.IsA('StaticMeshActor') && (pHitActor.m_bIsWalkable == TRUE)) && !pHitActor.IsA('TerrainInfo') )
                {
                    pHitActor.bHidden = true;
                    LMouseDown( X, Y );
                    pHitActor.bHidden = false;
                }
                else if(m_pTeamInfo[m_iCurrentTeam].SetGrenadeLocation(vHitLocation))
                {
                    pCurrentPoint.bHidden = false;
                    m_bClickToFindLocation = false;
                    WindowConsole(Player.Console).Root.m_bUseAimIcon = false;
                    PlaySound(m_PlanningGoodClickSnd, SLOT_Menu);
                }
                else
                {
                    PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
                }
            }
            return;
        }

        // Select an ActionPoint
        if(pHitActor != none)
        {
            if(pHitActor.IsA('R6ActionPoint') )
            {
                #ifdefDEBUG if(bShowLog) Log("--> Found action point : "$pHitActor); #endif
                if(R6ActionPoint(pHitActor).m_iRainbowTeamName == m_iCurrentTeam)
                {
                    m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor));
                    m_bCanMoveFirstPoint = false;
                    m_bActionPointSelected = true;
                }
            }
            else if(pHitActor.IsA('R6PathFlag'))
            {
                //Do Nothing
                return;
            }
            else if((pHitActor.IsA('R6PlanningBreach')) ||
                    (pHitActor.IsA('R6PlanningGrenade')))
            {
                m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor.owner));
                return;
            }
            else if(pHitActor.IsA('StaticMeshActor')) // static mesh actor
            {
                #ifdefDEBUG if(bShowLog) log("Hit StaticMeshActor : "$pHitActor$" : "$vHitLocation); #endif

                if(pHitActor.m_bIsWalkable == TRUE)
                {
                    CastActionPointAt(vHitLocation, m_iLevelDisplay, iChangeLevelTo, X, Y);
                }
                else
                {
                    PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
                }
            }
            else if(pHitActor.IsA('R6Ladder'))
            {
                #ifdefDEBUG if(bShowLog) log("Hit R6Ladder : "$pHitActor); #endif
                aHitActorLadder = R6Ladder(pHitActor);
                if(aHitActorLadder.m_iPlanningFloor_0 == aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0)
                {
                    //Ladder does not change floors.
                    pHitActor.bHidden = true;
                    LMouseDown( X, Y );
                    pHitActor.bHidden = false;
                }
                else
                {
                    if( !((m_bPlayMode == true) && (m_bLockCamera == TRUE)))
                    {
                        ChangeLevelDisplay(aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0 - aHitActorLadder.m_iPlanningFloor_0);
                        m_vCamDesiredPos = m_vCamPosNoRot;
                    }

                    if(aHitActorLadder.m_bIsTopOfLadder == true)
                    {
                        vSpawnOffset = vector(aHitActorLadder.m_pOtherFloor.Rotation) * -100.0;
                        vHitLocation = aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset;
                    }
                    else
                    {
                        vSpawnOffset = vector(aHitActorLadder.m_pOtherFloor.Rotation) * 100.0;
                        Trace(vHitLocation, vHitNormal, aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset + vect(0,0,-100), aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset, true, vect(0,0,0));
                    }
                    
                    //Cast a point or something!
                    CastActionPointAt(vHitLocation, aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0, aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0, X, Y);
                }
            }
            else if(pHitActor.IsA('R6InsertionZone'))
            {
                #ifdefDEBUG if(bShowLog) log("Clicked on InsertionZone: "$pHitActor$" : "$m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode); #endif

                if(m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == -1)
                {
                    //Spawn the player Start, 
                    m_pTeamInfo[m_iCurrentTeam].m_bPlacedFirstPoint = true;
                }

                //Find the 3D point
                pHitActor.bHidden = true;
                LMouseDown(X, Y);
                pHitActor.bHidden = false;
    
                //check if it's the first point
                if(m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == -1)
                {
                  if(m_pTeamInfo[m_iCurrentTeam].m_NodeList.Length > 0)
                  {
                    pCurrentPoint = R6ActionPoint(m_pTeamInfo[m_iCurrentTeam].m_NodeList[0]);

                    //Spawn the player Start, 
                    m_pTeamInfo[m_iCurrentTeam].m_iStartingPointNumber = R6InsertionZone(pHitActor).m_iInsertionNumber;
                    m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(pCurrentPoint);
                    pCurrentPoint.SetRotation(pHitActor.Rotation);
                    pCurrentPoint.m_u8SpritePlanningAngle = pCurrentPoint.Rotation.Yaw / 255;
                  }
                  else
                    m_pTeamInfo[m_iCurrentTeam].m_bPlacedFirstPoint = false;

                    #ifdefDEBUG if (bShowLog) log("Team "$m_pTeamInfo[m_iCurrentTeam]$" use Starting Point : "$m_pTeamInfo[m_iCurrentTeam].m_iStartingPointNumber$" first action point is : "$m_pTeamInfo[m_iCurrentTeam].m_NodeList[0]); #endif
                }
            }
            else if(pHitActor.IsA('TerrainInfo'))
            {
                CastActionPointAt(vHitLocation, iChangeLevelTo, iChangeLevelTo, X, Y);
            }
        }
        else
        {
            CastActionPointAt(vHitLocation, m_iLevelDisplay, iChangeLevelTo, X, Y);
        }
    }
    else
    {
        PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
    }
}

function RMouseUp( FLOAT X, FLOAT Y)
{
}

function LMouseUp( FLOAT X, FLOAT Y)
{
    local Actor pHitActor;
    local Vector vHitLocation;
    local INT iChangeLevelTo;

    if((m_bActionPointSelected == true) && (WindowConsole(Player.Console).Root.m_bUseDragIcon == true))
    {
        m_pTeamInfo[m_iCurrentTeam].GetPoint().bHidden=true;
        if(GetClickResult( X, Y, vHitLocation, pHitActor, iChangeLevelTo) == TRUE) 
        {
            if(pHitActor != none) 
            {
                //do not drag an action point on any of these
                if(!((pHitActor.IsA('R6ActionPoint')) ||
                     (pHitActor.IsA('R6PathFlag')) ||
                     (pHitActor.IsA('R6PlanningBreach')) ||                    
                     (pHitActor.IsA('R6PlanningGrenade')) ||
                     (pHitActor.IsA('R6Ladder'))))
                {
                    //Drag on other object here
                    if(pHitActor.IsA('StaticMeshActor'))
                    {
                        if(pHitActor.m_bIsWalkable == TRUE)
                        {
                            MoveActionPointTo(vHitLocation, m_iLevelDisplay, iChangeLevelTo);
                        }
                    }
                    else if (pHitActor.IsA('TerrainInfo'))
                    {
                        if(pHitActor.m_bIsWalkable == TRUE)
                        {
                            MoveActionPointTo(vHitLocation, iChangeLevelTo, iChangeLevelTo);
                        }
                    }
                    else
                    {
                        if(pHitActor.IsA('R6InsertionZone'))
                        {
                            m_bCanMoveFirstPoint = true;
                        }
                        pHitActor.bHidden = true;
                        LMouseUp( X, Y );
                        pHitActor.bHidden = false;
                    }
                }
            }
            else
            {
                MoveActionPointTo(vHitLocation, m_iLevelDisplay, iChangeLevelTo);
            }
        }
        else
        {
            PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
        }
        m_pTeamInfo[m_iCurrentTeam].GetPoint().bHidden=false;
    }
    //reset mouse cursor
    WindowConsole(Player.Console).Root.m_bUseDragIcon = false;
    m_bActionPointSelected = false;
}

function RMouseDown( FLOAT X, FLOAT Y)
{
    local Actor pHitActor;
    local Actor pHitActorBackup;
    local Vector vHitLocation;
    local Vector vHitNormal;
    local Vector vSpawnOffset;
    local R6ActionPoint FirstActionPoint;
    local INT iChangeLevelTo;
    local R6Ladder aHitActorLadder;
    local R6ActionPoint pCurrentPoint;

    if(m_bPlayMode == TRUE)
    {
        //do nothing while in playmode
        return;
    }

    if((m_bSetSnipeDirection == true) || (m_bClickToFindLocation == true))
    {
        CancelActionPointAction();
        return;
    }

    pCurrentPoint = GetCurrentPoint();

    if(GetClickResult( X, Y, vHitLocation, pHitActor, iChangeLevelTo) == TRUE) 
    {
        if(pHitActor != none) 
        {
            if(pHitActor.IsA('R6ActionPoint') )
            {
                #ifdefDEBUG if(bShowLog) Log("--> Found action point : "$pHitActor); #endif
                if(R6ActionPoint(pHitActor).m_iRainbowTeamName == m_iCurrentTeam)
                {
                    m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor));
                    WindowConsole(Player.Console).Root.KeyType(R6InputKey_ActionPopup, X, Y);
                }
            }
            else if(pHitActor.IsA('R6PathFlag')) // Display menu of PathFlag
            {
                if(R6ActionPoint(pHitActor.owner).m_iRainbowTeamName == m_iCurrentTeam)
                {
                    m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor.Owner));
                    WindowConsole(Player.Console).Root.KeyType(R6InputKey_PathFlagPopup, X, Y);
                }
            }
            else if((pHitActor.IsA('R6PlanningBreach')) ||
                    (pHitActor.IsA('R6PlanningGrenade')))
            {
                m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor.owner));
                return;
            }
            else if(pHitActor.IsA('StaticMeshActor')) // static mesh actor
            {
                #ifdefDEBUG if(bShowLog) log("Hit StaticMeshActor : "$pHitActor$" : "$vHitLocation); #endif

                if(pHitActor.m_bIsWalkable == TRUE)
                {
                    if(CastActionPointAt(vHitLocation, m_iLevelDisplay, iChangeLevelTo, X, Y))
                    {
                        WindowConsole(Player.Console).Root.KeyType(R6InputKey_ActionPopup, X, Y);
                    }
                }
                else
                {
                    PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
                }
            }
            else if(pHitActor.IsA('R6Ladder'))
            {
                #ifdefDEBUG if(bShowLog) log("Hit R6Ladder : "$pHitActor); #endif
                aHitActorLadder = R6Ladder(pHitActor);
                if(aHitActorLadder.m_iPlanningFloor_0 == aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_1)
                {
                    //Ladder does not change floors.
                    pHitActor.bHidden = true;
                    RMouseDown( X, Y );
                    pHitActor.bHidden = false;
                }
                else
                {
                    if( !((m_bPlayMode == true) && (m_bLockCamera == TRUE)))
                    {
                        ChangeLevelDisplay(aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0 - aHitActorLadder.m_iPlanningFloor_0);
                        m_vCamDesiredPos = m_vCamPosNoRot;
                    }

                    if(aHitActorLadder.m_bIsTopOfLadder == true)
                    {
                        vSpawnOffset = vector(aHitActorLadder.m_pOtherFloor.Rotation) * -100.0;
                        vHitLocation = aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset;
                    }
                    else
                    {
                        vSpawnOffset = vector(aHitActorLadder.m_pOtherFloor.Rotation) * 100.0;
                        Trace(vHitLocation, vHitNormal, aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset + vect(0,0,-100), aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset, true, vect(0,0,0));
                    }
                    
                    //Cast a point or something!
                    if(CastActionPointAt(vHitLocation, aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0, aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0, X, Y))
                    {
                        WindowConsole(Player.Console).Root.KeyType(R6InputKey_ActionPopup, X, Y);
                    }
                }
            }
            else if(pHitActor.IsA('R6InsertionZone')) // Display menu of ActionPoint
            {
                #ifdefDEBUG if(bShowLog) log("Right-Clicked on InsertionZone: "$pHitActor); #endif

                //check if it's the first point
                if(m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == -1)
                {
                    //Spawn the player Start, 
                    m_pTeamInfo[m_iCurrentTeam].m_bPlacedFirstPoint = true;
                }

                //Find the 3D point
                pHitActor.bHidden = true;
                LMouseDown(X, Y);
                pHitActor.bHidden = false;

                if(m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == -1)
                {
                    pCurrentPoint = R6ActionPoint(m_pTeamInfo[m_iCurrentTeam].m_NodeList[0]);
                    
                    m_pTeamInfo[m_iCurrentTeam].m_iStartingPointNumber = R6InsertionZone(pHitActor).m_iInsertionNumber;
                    m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(m_pTeamInfo[m_iCurrentTeam].m_NodeList[0]));
                    pCurrentPoint.SetRotation(pHitActor.Rotation);
                    pCurrentPoint.m_u8SpritePlanningAngle = pCurrentPoint.Rotation.Yaw / 255;

                    #ifdefDEBUG if (bShowLog) log("Team "$m_pTeamInfo[m_iCurrentTeam]$" use Starting Point : "$m_pTeamInfo[m_iCurrentTeam].m_iStartingPointNumber$" first action point is : "$m_pTeamInfo[m_iCurrentTeam].m_NodeList[0]); #endif
                }

                WindowConsole(Player.Console).Root.KeyType(R6InputKey_ActionPopup, X, Y);
            }
            else if(pHitActor.IsA('TerrainInfo'))
            {
                if(CastActionPointAt(vHitLocation, iChangeLevelTo, iChangeLevelTo, X, Y))
                {
                    WindowConsole(Player.Console).Root.KeyType(R6InputKey_ActionPopup, X, Y);
                }
            }
        }
        else  // Spawn ActionPoint and display its menu
        {
            if(CastActionPointAt(vHitLocation, m_iLevelDisplay, iChangeLevelTo, X, Y))
            {
                WindowConsole(Player.Console).Root.KeyType(R6InputKey_ActionPopup, X, Y);
            }
        }
    }
    else
    {
        PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
    }
}

function MouseMove( FLOAT X, FLOAT Y)
{
    local vector vHitLocation;
    if(m_bSetSnipeDirection == true)
    {
        m_fLastMouseX = X;
        m_fLastMouseY = Y;
        
        vHitLocation = GetXYPoint(X, Y, GetCurrentPoint().Location.Z);
        m_pTeamInfo[m_iCurrentTeam].AjustSnipeDirection(vHitLocation);
    }

    if( m_bActionPointSelected == true)
    {
        WindowConsole(Player.Console).Root.m_bUseDragIcon = true;
    }
    else
    {
        WindowConsole(Player.Console).Root.m_bUseDragIcon = false;
    }
}

// Cancel setting an action point Action.  (setting grenade or snipe direction.
function CancelActionPointAction()
{
    local R6ActionPoint pCurrentPoint;

    if((m_bSetSnipeDirection == true) || (m_bClickToFindLocation == true))
    {
        pCurrentPoint = GetCurrentPoint();
        //Cancel de grenade.
        pCurrentPoint.m_eAction = PACT_None;
        pCurrentPoint.m_pActionIcon.Destroy();
        pCurrentPoint.m_pActionIcon = none;

        pCurrentPoint.bHidden = false;
        
        //Stop finding grenade location
        m_bClickToFindLocation = false;
        //Stop selecting the snipe direction
        m_bSetSnipeDirection = false;
        WindowConsole(Player.Console).Root.m_bUseAimIcon = false;
        return;
    }
}

//-----------------------------------------------------------//
//                   ActionPoint functions                   //
//-----------------------------------------------------------//
function ResetAllID()
{
    m_pTeamInfo[0].ResetID(); 
    m_pTeamInfo[1].ResetID();
    m_pTeamInfo[2].ResetID();
   
}

function ResetIDs()
{
    m_pTeamInfo[m_iCurrentTeam].ResetID();
}

function Texture GetActionTypeTexture(EPlanActionType eActionType, optional INT iMilestone)
{
    switch(eActionType)
    {
    case PACTTYP_GoCodeA:
        return m_pIconTex[0];
        break;
    case PACTTYP_GoCodeB:
        return m_pIconTex[1];
        break;
    case PACTTYP_GoCodeC:
        return m_pIconTex[2];
        break;
    case PACTTYP_Milestone:
        return m_pIconTex[2 + iMilestone];
        break;
    }
    return none;    
}

function MoveActionPointTo(vector vHitLocation, INT iFirstFloor, INT iSecondFloor)
{
    local R6ActionPoint pCurrentActionPoint;
    local vector vBackupLocation;

    if((m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == 0) && (m_bCanMoveFirstPoint == false))
    {
        //Do not place the first point outside of an insertion zone.
        PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
        return;
    }
    vHitLocation.Z += m_fCastingHeight;

    pCurrentActionPoint = GetCurrentPoint();
    vBackupLocation = pCurrentActionPoint.Location;
    pCurrentActionPoint.SetLocation(vHitLocation);

    if(m_pTeamInfo[m_iCurrentTeam].MoveCurrentPoint() == true)
    {
        pCurrentActionPoint.m_eAction = PACT_None;
        if(pCurrentActionPoint.m_pActionIcon != none)
        {
            pCurrentActionPoint.m_pActionIcon.Destroy();
            pCurrentActionPoint.m_pActionIcon = none;
        }

        m_pTeamInfo[m_iCurrentTeam].SetPointRotation();

        if(iFirstFloor < iSecondFloor)
        {
            pCurrentActionPoint.m_iPlanningFloor_0 = iFirstFloor;
            pCurrentActionPoint.m_iPlanningFloor_1 = iSecondFloor;
        }
        else
        {
            pCurrentActionPoint.m_iPlanningFloor_0 = iSecondFloor;
            pCurrentActionPoint.m_iPlanningFloor_1 = iFirstFloor;
        }
        pCurrentActionPoint.FindDoor();
        PlaySound(m_PlanningGoodClickSnd, SLOT_Menu);
    }
    else
    {
        // Reset Location
        PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
        pCurrentActionPoint.SetLocation(vBackupLocation);
        m_pTeamInfo[m_iCurrentTeam].MoveCurrentPoint(); //reset the path and the pathflags
    }
}

// Spawn an ActionPoint at the X, Y screen location
// Return true if the ActionPoint is spawned
function bool CastActionPointAt(vector vLocation, INT iFirstFloor, INT iSecondFloor, INT X, INT Y)
{
    local BOOL bResult;
    local BOOL bReturnValue;
    local R6ActionPoint             pNewActionPoint;
    local R6PlanningInfo            pTeamInfo;
    local R6InsertionZone           pInsertionZone;
    
    #ifdefDEBUG if(bShowLog) Log("-->CastActionPointAt"); #endif

    bReturnValue = true;
    pTeamInfo = m_pTeamInfo[m_iCurrentTeam];
    
    if(pTeamInfo.m_bPlacedFirstPoint == false)
    {
        //Log this message in the Menu?!?!?
        Log("-->First ActionPoint must be on an InsertionZone!");
        bReturnValue = false;        
    }
    if(pTeamInfo.m_NodeList.length > 500)
    {
        //Log this message in the Menu?!?!?
        Log("-->too Many points in planning!");
        bReturnValue = false;        
    }

    if (bReturnValue)
    {
        vLocation.Z += m_fCastingHeight;

        bResult = FindSpot( vLocation, vect(42,42,62) );

        if(bResult == true)
        {
            pNewActionPoint = Spawn(class'R6Game.R6ActionPoint',,,vLocation);
            if(pNewActionPoint != none)
            {
                pNewActionPoint.m_pPlanningCtrl = self;
                if(iFirstFloor <= iSecondFloor)
                {
                    pNewActionPoint.m_iPlanningFloor_0 = iFirstFloor;
                    pNewActionPoint.m_iPlanningFloor_1 = iSecondFloor;
                }
                else
                {
                    pNewActionPoint.m_iPlanningFloor_0 = iSecondFloor;
                    pNewActionPoint.m_iPlanningFloor_1 = iFirstFloor;
                }
            
                if(pTeamInfo.m_iCurrentNode == -1)
                {
                    pNewActionPoint.SetFirstPointTexture();
                }
            
                pNewActionPoint.FindDoor();
            
                #ifdefDEBUG if(bShowLog) Log("-->Spawning R6ActionPoint :"$pNewActionPoint$" at location : "$vLocation$" Floor0 "$pNewActionPoint.m_iPlanningFloor_0$" Floor1 "$pNewActionPoint.m_iPlanningFloor_1); #endif
            
                if((pTeamInfo.m_iCurrentNode != -1) && (pTeamInfo.m_iCurrentNode != pTeamInfo.m_NodeList.length -1))
                {
                    if(m_pTeamInfo[m_iCurrentTeam].InsertPoint(pNewActionPoint) == true)
                    {
                        pNewActionPoint.m_iRainbowTeamName=m_iCurrentTeam;
                        //If point is on the far edge of the screen move camera over the action point
                        if((X < 100) || (X > 544) || (Y < 54) || (Y > 326))
                        {
                            MoveCamOver();
                        }
                    }
                    else
                    {
                        log("Could not Insert point at location");
                        bReturnValue = false;
                    }
                }
                else
                {
                    if(m_pTeamInfo[m_iCurrentTeam].AddPoint(pNewActionPoint) == true)
                    {
                        pNewActionPoint.m_iRainbowTeamName=m_iCurrentTeam;
                        //If point is on the far edge of the screen move camera over the action point
                        if((X < 100) || (X > 544) || (Y < 54) || (Y > 326))
                        {
                            MoveCamOver();
                        }
                    }
                    else
                    {
                        log("Could not add point at location");
                        bReturnValue = false;
                    }
                }
            }
            else
            {
                bReturnValue = false;
                log("Could not spawn action point");
            }
        }
        else
        {
            bReturnValue = false;
            log("Could not find place to spawn action point");
        }
    }    

    if (bReturnValue)
        PlaySound(m_PlanningGoodClickSnd, SLOT_Menu);
    else
        PlaySound(m_PlanningBadClickSnd, SLOT_Menu);

    return bReturnValue;
}

function DeleteOneNode()
{
    CancelActionPointAction();

    // Delete the current ActionPoint
    if (m_pTeamInfo[m_iCurrentTeam].DeleteNode())
    {
        PlaySound(m_PlanningRemoveSnd, SLOT_Menu);
    }
    else
    {
        PlaySound(m_PlanningBadClickSnd, SLOT_Menu);
    }

    if(GetCurrentPoint() != none)
    {
        m_iLevelDisplay = GetCurrentPoint().m_iPlanningFloor_0;
        SetFloorToDraw(m_iLevelDisplay);
    }
}

function DeleteAllNode()
{
    CancelActionPointAction();

    // Delete all the action point
    m_pTeamInfo[m_iCurrentTeam].DeleteAllNode();

    PositionCameraOnInsertionZone();
}

function PositionCameraOnInsertionZone()
{
    local R6InsertionZone anInsertionZone;

    //Relocate camera at the insertion zone.
    foreach AllActors( class 'R6InsertionZone', anInsertionZone )
    {
		if( (anInsertionZone.m_iInsertionNumber == 0) && (anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag)))
        {
            SetFloorToDraw(anInsertionZone.m_iPlanningFloor_0);
            m_iLevelDisplay = anInsertionZone.m_iPlanningFloor_0;
            m_vCamDesiredPos = anInsertionZone.location;
            m_vCamDesiredPos.Z = 0;
            break;
        }
    }
}

function DeleteEverySingleNode()
{
    CancelActionPointAction();

    // Delete all points for every team
    m_pTeamInfo[0].DeleteAllNode();
    m_pTeamInfo[1].DeleteAllNode();
    m_pTeamInfo[2].DeleteAllNode();

    PositionCameraOnInsertionZone();
}

//Waypoints movement to a specific team.
function GotoFirstNode()
{
    CancelActionPointAction();

    //Cancel grenade/snipe selection
    m_pTeamInfo[m_iCurrentTeam].SetToStartNode();
    MoveCamOver();
}
function GotoLastNode()
{
    CancelActionPointAction();

    //Cancel grenade/snipe selection
    m_pTeamInfo[m_iCurrentTeam].SetToEndNode();
    MoveCamOver();
}
function GotoNextNode()
{
    CancelActionPointAction();

    //Cancel grenade/snipe selection
    m_pTeamInfo[m_iCurrentTeam].SetToNextNode();
    MoveCamOver();
}
function GotoPrevNode()
{
    CancelActionPointAction();

    //Cancel grenade/snipe selection
    m_pTeamInfo[m_iCurrentTeam].SetToPrevNode();
    MoveCamOver();
}
function GotoNode()
{
    CancelActionPointAction();

    //Cancel grenade/snipe selection
    MoveCamOver();
}

function R6ActionPoint GetCurrentPoint()
{
    return m_pTeamInfo[m_iCurrentTeam].GetPoint();
}

function EPlanActionType GetCurrentActionType()
{
    return m_pTeamInfo[m_iCurrentTeam].GetActionType();
}

function EMovementMode GetMovementMode()
{
    return m_pTeamInfo[m_iCurrentTeam].GetMovementMode();
}

// Locate the camera over the current ActionPoint
function MoveCamOver()
{
    if(GetCurrentPoint() != none)
    {
        // Reset the camera position
        m_vCamDesiredPos.X = GetCurrentPoint().Location.X;
        m_vCamDesiredPos.Y = GetCurrentPoint().Location.Y;

        m_iLevelDisplay = GetCurrentPoint().m_iPlanningFloor_0;
        SetFloorToDraw(m_iLevelDisplay);
    }
}

function StartPlayingPlanning()
{
    m_bPlayMode = TRUE;
    R6PlanningPawn(Pawn).FollowPlanning(m_pTeamInfo[m_iCurrentTeam]);
}

function StopPlayingPlanning()
{
    m_bPlayMode = FALSE;
    R6PlanningPawn(Pawn).StopFollowingPlanning();
}


auto state PlayerWaiting
{
	function EndState(){}
    function BeginState(){}
}

#ifdefDEBUG
exec function dbgDrawPath()
{
    m_pTeamInfo[0].bDisplayDbgInfo = true;
    m_pTeamInfo[1].bDisplayDbgInfo = true;
    m_pTeamInfo[2].bDisplayDbgInfo = true;
}

exec function DesignRange(FLOAT fNewScale)
{
    m_fDebugRangeScale = fNewScale;
}
#endif

defaultproperties
{
     m_bFirstTick=True
     m_fZoom=0.250000
     m_fZoomRate=0.200000
     m_fZoomMin=0.050000
     m_fZoomMax=0.400000
     m_fZoomFactor=2.000000
     m_fAngleRate=4000.000000
     m_fAngleMax=-25000.000000
     m_fRotateRate=6000.000000
     m_fCamRate=1000.000000
     m_fCastingHeight=100.000000
     m_fDebugRangeScale=1.000000
     m_pIconTex(0)=Texture'R6Planning.Icons.PlanIcon_Alpha'
     m_pIconTex(1)=Texture'R6Planning.Icons.PlanIcon_Bravo'
     m_pIconTex(2)=Texture'R6Planning.Icons.PlanIcon_Charlie'
     m_pIconTex(3)=Texture'R6Planning.Icons.PlanIcon_Milestone1'
     m_pIconTex(4)=Texture'R6Planning.Icons.PlanIcon_Milestone2'
     m_pIconTex(5)=Texture'R6Planning.Icons.PlanIcon_Milestone3'
     m_pIconTex(6)=Texture'R6Planning.Icons.PlanIcon_Milestone4'
     m_pIconTex(7)=Texture'R6Planning.Icons.PlanIcon_Milestone5'
     m_pIconTex(8)=Texture'R6Planning.Icons.PlanIcon_Milestone6'
     m_pIconTex(9)=Texture'R6Planning.Icons.PlanIcon_Milestone7'
     m_pIconTex(10)=Texture'R6Planning.Icons.PlanIcon_Milestone8'
     m_pIconTex(11)=Texture'R6Planning.Icons.PlanIcon_Milestone9'
     m_PlanningBadClickSnd=Sound'SFX_Menus.Play_Planning_BadClick'
     m_PlanningGoodClickSnd=Sound'SFX_Menus.Play_Planning_GoodClick'
     m_vCurrentCameraPos=(X=1.000000,Z=15000.000000)
     m_vCamPos=(X=1.000000,Z=15000.000000)
     m_rCamRot=(Pitch=49153)
     bBehindView=True
     InputClass=Class'R6Game.R6PlanningPlayerInput'
     RemoteRole=ROLE_None
}
