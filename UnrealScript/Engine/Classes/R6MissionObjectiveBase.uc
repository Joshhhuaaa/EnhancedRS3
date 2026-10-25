//=============================================================================
//  R6MissionObjectiveBase.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MissionObjectiveBase extends Object
	hidecategories(Object)
	editinlinenew
    abstract;

var   Actor   m_mgr;                         // reference to the manager

var() string  m_szDescription;               // debug description 
var() string  m_szDescriptionInMenu;         // in the menu and when completed..: keyword for the dictionnary
var() string  m_szDescriptionFailure;        // when failed.....: keyword for the dictionnary

var() string  m_szMissionObjLocalization;    // 

var   bool    m_bFailed;                            
var   bool    m_bCompleted;

var() bool    m_bVisibleInMenu;                   // if we want to see the description and the status in the menu
var() bool    m_bIfCompletedMissionIsSuccessfull; // if this mission objective is completed, the whole mission is a success and over
var() bool    m_bIfFailedMissionIsAborted;        // if this mission objective fails, the whole mission is a failure and over
var() bool    m_bMoralityObjective;               // if it's a morality rule
var   bool    m_bEndOfListOfObjectives;           // special case when this objective should be checked at the end of the list
var() bool    m_bShowLog;                         // debug show log
var   int     m_iCountdown;                         // timer countdown

var() Sound   m_sndSoundSuccess;                // when completed..: snd played
var() Sound   m_sndSoundFailure;                // when failed..: snd played

var() string  m_szFeedbackOnCompletion;
var   bool    m_bFeedbackOnCompletionSend;
var() string  m_szFeedbackOnFailure;
var   bool    m_bFeedbackOnFailureSend;
 
// all those MObj event are in the manager
function PawnKilled(            Pawn killedPawn );
function IObjectInteract(       Pawn aPawn,      Actor anInteractiveObject );
function IObjectDestroyed(      Pawn aPawn,      Actor anInteractiveObject );
function PawnSeen(              Pawn seen,       Pawn  witness );
function PawnHeard(             Pawn seen,       Pawn  witness );
function PawnSecure(            Pawn securedPawn );
function EnteredExtractionZone( Pawn pawn );
function ExitExtractionZone(    Pawn pawn );
function TimerCallback(         float fTime );
function ToggleLog(             bool bToggle ) { m_bShowLog = bToggle; }

function logMObj( string szText )
{
    log( "WARNING MissionObjective (" $self.name$ ")" $szText );
}

function logX( string szText )
{
    log( "" $self.name$ ": " $szText );
}

function Init();

function bool isVisibleInMenu()
{
    return m_bVisibleInMenu;
}

function bool isMissionCompletedOnSuccess()
{
    return m_bIfCompletedMissionIsSuccessfull;
}

function bool isMissionAbortedOnFailure()
{
    return m_bIfFailedMissionIsAborted;
}

function bool isCompleted()
{
    return m_bCompleted;
}

function bool isFailed()
{
    return m_bFailed;
}

function string getDescription()
{
    return m_szDescription;
}


//------------------------------------------------------------------
// SubMission functions
//	
//------------------------------------------------------------------
function int GetNumSubMission()
{
    return 0;
}

function R6MissionObjectiveBase GetSubMissionObjective( int index )
{
    return none;    
}

function string GetDescriptionFailure()
{
    return m_szDescriptionFailure;
}

function SetMObjMgr( Actor aMObjMgr )
{
    m_mgr = aMObjMgr;
}

function Sound GetSoundSuccess()
{
    return m_sndSoundSuccess;
}

function Sound GetSoundFailure()
{
    return m_sndSoundFailure;
}

function Reset()
{
    m_bFailed     = false;
    m_bCompleted  = false;
    m_bFeedbackOnCompletionSend = false;
    m_bFeedbackOnFailureSend    = false;
}

defaultproperties
{
     m_bVisibleInMenu=True
}
