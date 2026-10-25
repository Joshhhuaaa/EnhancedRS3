//=============================================================================
//  R6MissionGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/14 * Created by Aristomenis Kolokathis
//=============================================================================

class R6MissionGame extends R6CoOpMode;

//------------------------------------------------------------------
// InitObjectives
//	 Story Mode Objective
//------------------------------------------------------------------
function InitObjectives()
{
    InitObjectivesOfStoryMode();
    Super.InitObjectives();
}

defaultproperties
{
     m_szGameTypeFlag="RGM_MissionMode"
}
