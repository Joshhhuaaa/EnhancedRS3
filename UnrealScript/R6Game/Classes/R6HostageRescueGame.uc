//=============================================================================
//  R6HostageRescueGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Aristomenis Kolokathis
//=============================================================================
class R6HostageRescueGame extends R6CoOpMode;

function InitObjectives()
{
    local int index;
    local R6MObjNeutralizeTerrorist missionObjTerro;
    local R6MObjGroupMission        groupMission;
    local R6MObjRescueHostage       objRescueHostage;

    // Group Mission
    m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjGroupMission';
    groupMission = R6MObjGroupMission(m_missionMgr.m_aMissionObjectives[index]);
    groupMission.m_bIfCompletedMissionIsSuccessfull = true;
    groupMission.m_szDescription       = "Rescue all hostage to the extraction zone or neutralize all terrorist";
    
    // neutralize all terro
    missionObjTerro = new(none) class'R6Game.R6MObjNeutralizeTerrorist';
    groupMission.m_bIfCompletedMissionIsSuccessfull = true;
    missionObjTerro.m_bVisibleInMenu = false;
    missionObjTerro.m_szFeedbackOnCompletion = "AllTerroristHaveBeenNeutralized"; 
    groupMission.m_aSubMissionObjectives[index] = missionObjTerro;
    index++;

    // get rescue all hostage to the extraction zone
    objRescueHostage = new(none) class'R6Game.R6MObjRescueHostage';
    objRescueHostage.m_bIfCompletedMissionIsSuccessfull = true;
    objRescueHostage.m_bVisibleInMenu = true;
    objRescueHostage.m_szFeedbackOnCompletion = "AllHostagesHaveBeenRescued";
    groupMission.m_aSubMissionObjectives[index] = objRescueHostage;
    index++;

    // set the description based on the number of hostage in the map
    groupMission.m_szDescriptionInMenu = objRescueHostage.GetDescriptionBasedOnNbOfHostages( Level );

    Super.InitObjectives();
}

defaultproperties
{
     m_szDefaultActionPlan="_HOSTAGE_ACTION"
     m_szGameTypeFlag="RGM_HostageRescueMode"
}
