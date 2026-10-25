//=============================================================================
//  R6ReconGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/14 * Created by Aristomenis Kolokathis
//=============================================================================

class R6ReconGame extends R6CoOpMode;


function InitObjectives()
{
    local int index;
    local R6MObjNeutralizeTerrorist missionObjTerro;
    local R6MObjGroupMission        groupMission;
    local R6MObjRecon               reconObj;

    // Group Mission
    m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjGroupMission';
    groupMission = R6MObjGroupMission(m_missionMgr.m_aMissionObjectives[index]);
    groupMission.m_bIfCompletedMissionIsSuccessfull = true;
    groupMission.m_szDescription = "Go to extraction zone and don't get caugh";
    groupMission.m_szDescriptionInMenu = "GotoExtractionInReconMode";

    // recon
    groupMission.m_aSubMissionObjectives[index] = new(none) class'R6Game.R6MObjRecon';
    groupMission.m_aSubMissionObjectives[index].m_bIfCompletedMissionIsSuccessfull = true;
    reconObj = R6MObjRecon(groupMission.m_aSubMissionObjectives[index]);
    reconObj.m_bVisibleInMenu = false;
    index++;

    // get from the insertion zone to the extraction zone
    groupMission.m_aSubMissionObjectives[index] = new(none) class'R6Game.R6MObjCompleteAllAndGoToExtraction';
    groupMission.m_aSubMissionObjectives[index].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjTerro.m_bVisibleInMenu = false;
    index++;

    Super.InitObjectives();
}

defaultproperties
{
     m_szGameTypeFlag="RGM_ReconMode"
}
