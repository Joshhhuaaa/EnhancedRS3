class R6TerroristHuntAdvGame extends R6AdversarialTeamGame
    config;

function InitObjectives()
{
    local R6MObjNeutralizeMoreTerrorist missionObjTerroNeutralizedByAlpha, missionObjTerroNeutralizedByBravo;

    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    m_missionMgr.m_aMissionObjectives[0] = new (none) Class'ASGame.R6MObjNeutralizeMoreTerrorist';
    m_missionMgr.m_aMissionObjectives[0].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjTerroNeutralizedByAlpha = R6MObjNeutralizeMoreTerrorist(m_missionMgr.m_aMissionObjectives[0]);
    missionObjTerroNeutralizedByAlpha.m_iKillerTeamID = 2;
    missionObjTerroNeutralizedByAlpha.m_bVisibleInMenu = true;
    missionObjTerroNeutralizedByAlpha.m_szFeedbackOnCompletion = "MostTerroristsHaveBeenNeutralized";
    m_missionMgr.m_aMissionObjectives[1] = new (none) Class'ASGame.R6MObjNeutralizeMoreTerrorist';
    m_missionMgr.m_aMissionObjectives[1].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjTerroNeutralizedByBravo = R6MObjNeutralizeMoreTerrorist(m_missionMgr.m_aMissionObjectives[1]);
    missionObjTerroNeutralizedByBravo.m_iKillerTeamID = 3;
    missionObjTerroNeutralizedByBravo.m_bVisibleInMenu = true;
    missionObjTerroNeutralizedByBravo.m_szFeedbackOnCompletion = "MostTerroristsHaveBeenNeutralized";
    Level.m_bUseDefaultMoralityRules = false;
    super.InitObjectives();
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;

    if(m_bGameOver)
    {
        return;
    }
    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    if(m_missionMgr.m_aMissionObjectives[0].m_bCompleted)
    {
        BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound);
        BroadcastMissionObjMsg("", "", "MostTerroristsHaveBeenNeutralized");
        AddTeamWonRound(c_iAlphaTeam);
    }
    else
    {
        if(m_missionMgr.m_aMissionObjectives[1].m_bCompleted)
        {
            BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound);
            BroadcastMissionObjMsg("", "", "MostTerroristsHaveBeenNeutralized");
            AddTeamWonRound(c_iBravoTeam);
        }
        else
        {
            if(m_objDeathmatch.m_bCompleted)
            {
                if(m_objDeathmatch.m_iWinningTeam == 2)
                {
                    BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound);
                    BroadcastMissionObjMsg("", "", "RedNeutralized");
                    AddTeamWonRound(c_iAlphaTeam);
                }
                else
                {
                    if(m_objDeathmatch.m_iWinningTeam == 3)
                    {
                        BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound);
                        BroadcastMissionObjMsg("", "", "GreenNeutralized");
                        AddTeamWonRound(c_iBravoTeam);
                    }
                }
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
    super.EndGame(Winner, Reason);
}

defaultproperties
{
    m_iUbiComGameMode=6
    m_szGameTypeFlag="RGM_TerroristHuntAdvMode"
}
