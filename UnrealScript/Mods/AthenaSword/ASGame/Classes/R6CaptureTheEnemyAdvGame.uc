class R6CaptureTheEnemyAdvGame extends R6AdversarialTeamGame
    config;

function InitObjectives()
{
    local R6MObjCaptureTheEnemy missionObjEnemyCapturedByAlpha, missionObjEnemyCapturedByBravo;

    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    m_missionMgr.m_aMissionObjectives[0] = new (none) Class'ASGame.R6MObjCaptureTheEnemy';
    m_missionMgr.m_aMissionObjectives[0].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjEnemyCapturedByAlpha = R6MObjCaptureTheEnemy(m_missionMgr.m_aMissionObjectives[0]);
    missionObjEnemyCapturedByAlpha.m_iKillerTeamID = 2;
    missionObjEnemyCapturedByAlpha.m_bVisibleInMenu = true;
    missionObjEnemyCapturedByAlpha.m_szFeedbackOnCompletion = "EnemyCaptured";
    m_missionMgr.m_aMissionObjectives[1] = new (none) Class'ASGame.R6MObjCaptureTheEnemy';
    m_missionMgr.m_aMissionObjectives[1].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjEnemyCapturedByBravo = R6MObjCaptureTheEnemy(m_missionMgr.m_aMissionObjectives[1]);
    missionObjEnemyCapturedByBravo.m_iKillerTeamID = 3;
    missionObjEnemyCapturedByBravo.m_bVisibleInMenu = true;
    missionObjEnemyCapturedByBravo.m_szFeedbackOnCompletion = "EnemyCaptured";
    Level.m_bUseDefaultMoralityRules = false;
    m_bAddObjDeathmatch = false;
    super.InitObjectives();
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;
    local int iNeutralized;
    local R6Pawn aPawn;
    local float fTotal;

    if(m_bGameOver)
    {
        return;
    }
    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    if(m_missionMgr.m_aMissionObjectives[0].m_bCompleted)
    {
        BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound);
        BroadcastMissionObjMsg("", "", "RedTeamCaptured");
        AddTeamWonRound(c_iAlphaTeam);
    }
    else
    {
        if(m_missionMgr.m_aMissionObjectives[1].m_bCompleted)
        {
            BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound);
            BroadcastMissionObjMsg("", "", "GreenTeamCaptured");
            AddTeamWonRound(c_iBravoTeam);
        }
        else
        {
            if(R6MObjCaptureTheEnemy(m_missionMgr.m_aMissionObjectives[0]).m_iNeutralized < R6MObjCaptureTheEnemy(m_missionMgr.m_aMissionObjectives[1]).m_iNeutralized)
            {
                BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound);
                BroadcastMissionObjMsg("", "", "RedTeamCapturedMore");
                AddTeamWonRound(c_iBravoTeam);
            }
            else
            {
                if(R6MObjCaptureTheEnemy(m_missionMgr.m_aMissionObjectives[0]).m_iNeutralized > R6MObjCaptureTheEnemy(m_missionMgr.m_aMissionObjectives[1]).m_iNeutralized)
                {
                    BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound);
                    BroadcastMissionObjMsg("", "", "GreenTeamCapturedMore");
                    AddTeamWonRound(c_iAlphaTeam);
                }
                else
                {
                    if(bShowLog)
                    {
                        log("** Game : it's a draw");
                    }
                    BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw);
                }
            }
        }
    }
    super.EndGame(Winner, Reason);
}

defaultproperties
{
    m_iUbiComGameMode=8
    m_bIsRadarAllowed=false
    m_szGameTypeFlag="RGM_CaptureTheEnemyAdvMode"
}
