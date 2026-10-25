//=============================================================================
//  R6LoneWolfGame.uc : Lone wolf game mode
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/12 * Created by Sébastien Lussier
//=============================================================================

class R6LoneWolfGame extends R6GameInfo;

var Sound m_sndTeamWipedOut;

function InitObjectives()
{
    local int index;
    local R6MObjNeutralizeTerrorist missionObjTerro;
    local R6MObjGroupMission        groupMission;
    local R6MObjGoToExtraction      missionObjGotoExtraction;
    local R6Rainbow                 aRainbow;

    // Group Mission
    m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjGroupMission';
    groupMission = R6MObjGroupMission(m_missionMgr.m_aMissionObjectives[index]);
    groupMission.m_bIfCompletedMissionIsSuccessfull = true;
    groupMission.m_szDescription       = "Get to the extraction zone or neutralize all terrorist";
    groupMission.m_szDescriptionInMenu = "GetToExtractionZone";

    // neutralize all terro
    groupMission.m_aSubMissionObjectives[index] = new(none) class'R6Game.R6MObjNeutralizeTerrorist';
    groupMission.m_aSubMissionObjectives[index].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjTerro = R6MObjNeutralizeTerrorist(groupMission.m_aSubMissionObjectives[index]);
    missionObjTerro.m_iNeutralizePercentage = 100;
    missionObjTerro.m_bVisibleInMenu = false;
    missionObjTerro.m_szFeedbackOnCompletion = "AllTerroristHaveBeenNeutralized"; 
    index++;

    // get from the insertion zone to the extraction zone
    missionObjGotoExtraction = new(none) class'R6Game.R6MObjGoToExtraction';
    groupMission.m_aSubMissionObjectives[index] = missionObjGotoExtraction;
    groupMission.m_aSubMissionObjectives[index].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjGotoExtraction.m_sndSoundFailure = m_sndTeamWipedOut;
    missionObjGotoExtraction.m_bVisibleInMenu = false;

    // get the human player pawn
    foreach DynamicActors( class'R6Rainbow', aRainbow )
    {
        missionObjGotoExtraction.SetPawnToExtract( aRainbow );
        break;
    }
    
    
    index++;

    Super.InitObjectives(); 
}

///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame( PlayerReplicationInfo Winner, string Reason ) 
{
    local R6GameReplicationInfo gameRepInfo;
    local R6MissionObjectiveBase obj;
    
    // This function has already been called
    if( m_bGameOver )
        return;

    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    if ( m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success )
    {
        BroadcastMissionObjMsg( "", "", "MissionSuccesfulObjectivesCompleted", Level.m_sndMissionComplete );
    }
    else
    {
        obj = m_missionMgr.GetMObjFailed();
        BroadcastMissionObjMsg( "", "", "MissionFailed" );
        if ( obj != none ) // no failure
            BroadcastMissionObjMsg( Level.GetMissionObjLocFile( obj ), "", 
                                    obj.GetDescriptionFailure(), obj.GetSoundFailure(), GetGameMsgLifeTime()); 

    }

    Super.EndGame( Winner, Reason );
}

defaultproperties
{
     m_sndTeamWipedOut=Sound'Voices_Control_MissionFailed.Play_TeamWipedOut'
     m_iMaxOperatives=1
     m_szDefaultActionPlan="_LONE_ACTION"
     m_szGameTypeFlag="RGM_LoneWolfMode"
}
