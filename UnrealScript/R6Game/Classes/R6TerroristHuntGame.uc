//=============================================================================
//  R6TerroristHuntGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/19 * Created by Aristomenis Kolokathis Co-Op version
//=============================================================================

class R6TerroristHuntGame extends R6CoOpMode;


//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    local R6MObjNeutralizeTerrorist missionObjTerro;

    // neutralize all terro
    m_missionMgr.m_aMissionObjectives[0] = new(none) class'R6Game.R6MObjNeutralizeTerrorist';
    m_missionMgr.m_aMissionObjectives[0].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjTerro = R6MObjNeutralizeTerrorist(m_missionMgr.m_aMissionObjectives[0]);
    missionObjTerro.m_iNeutralizePercentage = 100;
    missionObjTerro.m_bVisibleInMenu = true;
    missionObjTerro.m_szFeedbackOnCompletion = "AllTerroristHaveBeenNeutralized"; 

    Super.InitObjectives();
}

defaultproperties
{
     m_szDefaultActionPlan="_TERRORIST_ACTION"
     m_szGameTypeFlag="RGM_TerroristHuntMode"
}
