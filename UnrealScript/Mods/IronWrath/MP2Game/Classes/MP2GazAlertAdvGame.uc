class MP2GazAlertAdvGame extends MP2AdversarialTeamGame
    config;

function PawnKilled(Pawn killedPawn)
{
    if(m_bGameOver)
    {
        return;
    }
    super(R6GameInfo).PawnKilled(killedPawn);
}

function InitObjectives()
{
    local Controller P;
    local MP2PlayerController PlayerController;

    for(P = Level.ControllerList; P != none; P = P.nextController)
    {
        PlayerController = MP2PlayerController(P);
        PlayerController.m_fOxygeneLevel = Level.m_fOxygeneTopLevel;
    }
    Level.m_bUseDefaultMoralityRules = false;
    super(R6AdversarialTeamGame).InitObjectives();
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;

    if(m_bGameOver)
    {
        return;
    }
    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    if(m_objDeathmatch.m_bCompleted)
    {
        if(m_objDeathmatch.m_iWinningTeam == 2)
        {
            BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
            BroadcastMissionObjMsg("", "", "GreenNeutralizedRed", none, int(GetGameMsgLifeTime()));
            AddTeamWonRound(c_iAlphaTeam);
        }
        else
        {
            if(m_objDeathmatch.m_iWinningTeam == 3)
            {
                BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
                BroadcastMissionObjMsg("", "", "RedNeutralizedGreen", none, int(GetGameMsgLifeTime()));
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
        BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));
    }
    super(R6AdversarialTeamGame).EndGame(Winner, Reason);
}

defaultproperties
{
    m_iUbiComGameMode=7
    m_szGameTypeFlag="RGM_GazAlertAdvMode"
}
