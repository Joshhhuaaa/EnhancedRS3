class MP2LimitSeatsAdvGame extends MP2AdversarialTeamGame
    config;

var MP2MObjRescuePrisoner m_objRescuePrisoner;
var R6MObjAcceptableHostageLossesByRainbow m_objPrisonerLossesByAlpha;
var R6MObjAcceptableHostageLossesByRainbow m_objPrisonerLossesByBravo;
var string m_szMP2Localization;

function CheckForPrisoner(R6MissionObjectiveBase mo, int iMinNum)
{
    local int iTotalA, iTotalB;
    local R6Hostage aHostage;

    foreach DynamicActors(Class'R6Engine.R6Hostage', aHostage)
    {
        if(aHostage.m_iPrisonierTeam == 5)
        {
            iTotalA++;
        }
        else
        {
            if(aHostage.m_iPrisonierTeam == 6)
            {
                iTotalB++;
            }
        }
    }
    if(iTotalA < iMinNum)
    {
        log((("WARNING: there is not enough (" $ string(iMinNum)) $ ") Prisoner for team A spawned to complete this objective: ") $ mo.getDescription());
    }
    if(iTotalB < iMinNum)
    {
        log((("WARNING: there is not enough (" $ string(iMinNum)) $ ") Prisoner for team B spawned to complete this objective: ") $ mo.getDescription());
    }
}

function InitObjectives()
{
    local R6Hostage hostage;
    local int iLength, iTotalPrisoner, iTotalPrisonerA, iTotalPrisonerB, iTeam;

    local Controller P;

    m_bFriendlyFire = false;
    foreach DynamicActors(Class'R6Engine.R6Hostage', hostage)
    {
        hostage.m_controller.m_bForceToStayHere = true;
        hostage.m_ePersonality = HPERSO_Coward;
        hostage.m_iPrisonierTeam = hostage.m_DZone.m_iPrisonerTeam + 5;
        SetPawnTeamFriendliesForHostage(hostage);
        if(hostage.m_iPrisonierTeam == 5)
        {
            iTotalPrisonerA++;
        }
        else
        {
            iTotalPrisonerB++;
        }
        iTotalPrisoner++;
    }
    if((iTotalPrisonerA == 0) && m_missionMgr.m_bEnableCheckForErrors)
    {
        log("WARNING: there is no Prisoner for Team A in the game type: " $ string(self));
    }
    if((iTotalPrisonerB == 0) && m_missionMgr.m_bEnableCheckForErrors)
    {
        log("WARNING: there is no Prisoner for Team B in the game type: " $ string(self));
    }
    m_objRescuePrisoner = new (none) Class<MP2MObjRescuePrisoner>(DynamicLoadObject("MP2Game.MP2MObjRescuePrisoner", Class'Core.Class'));
    m_objRescuePrisoner.m_szDescriptionInMenu = m_objRescuePrisoner.GetDescriptionBasedOnNbOfHostages(Level);
    iLength = m_missionMgr.m_aMissionObjectives.Length;
    m_missionMgr.m_aMissionObjectives[iLength] = m_objRescuePrisoner;
    iLength++;
    m_objPrisonerLossesByAlpha = new (none) Class'R6Game.R6MObjAcceptableHostageLossesByRainbow';
    m_missionMgr.m_aMissionObjectives[iLength] = m_objPrisonerLossesByAlpha;
    iLength++;
    m_objPrisonerLossesByBravo = new (none) Class'R6Game.R6MObjAcceptableHostageLossesByRainbow';
    m_missionMgr.m_aMissionObjectives[iLength] = m_objPrisonerLossesByBravo;
    iLength++;
    m_objRescuePrisoner.m_bIfFailedMissionIsAborted = true;
    m_objRescuePrisoner.m_bIfCompletedMissionIsSuccessfull = true;
    m_objRescuePrisoner.m_bCheckPawnKilled = true;
    InitObjHostageLossesByTeamID(m_objPrisonerLossesByAlpha, 2, 0);
    InitObjHostageLossesByTeamID(m_objPrisonerLossesByBravo, 3, 0);
    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    Level.m_bUseDefaultMoralityRules = false;

    for(P = Level.ControllerList; P != none; P = P.nextController)
    {
        if(!P.IsA('PlayerController'))
        {
            continue;
        }
        MP2PlayerController(P).m_iNbPrisonersSaved = 0;
    }
    super(R6AdversarialTeamGame).InitObjectives();
}

function InitObjHostageLossesByTeamID(R6MObjAcceptableHostageLossesByRainbow obj, int iTeamId, int iAcceptableLost)
{
    local string szTeamName;

    obj.m_iKillerTeamID = iTeamId;
    obj.m_bMoralityObjective = false;
    obj.m_bIfFailedMissionIsAborted = true;
    obj.m_iAcceptableLost = iAcceptableLost;
    obj.m_bVisibleInMenu = false;
    if(iTeamId == 2)
    {
        szTeamName = "Alpha";
    }
    else
    {
        if(iTeamId == 3)
        {
            szTeamName = "Bravo";
        }
        else
        {
            szTeamName = "Unknow";
        }
    }
    obj.m_szDescription = "HostageLossesByTeamID by " $ szTeamName;
    obj.m_szDescriptionInMenu = "AvoidHostageCasualities";
}

function PawnKilled(Pawn killedPawn)
{
    if(m_bGameOver)
    {
        return;
    }
    super(R6GameInfo).PawnKilled(killedPawn);
    EnteredExtractionZone(killedPawn);
}

function EnteredExtractionZone(Actor anActor)
{
    local int i, iTotalRescuedA, iTotalRescuedB, iTotalAliveA, iTotalAliveB, iTotalLeftA,
	    iTotalLeftB, iTotalHostageA, iTotalHostageB;

    local bool bSendMsg;
    local R6Pawn aPawn;
    local R6Hostage hostage;
    local Controller P;

    if(m_bGameOver)
    {
        return;
    }
    aPawn = R6Pawn(anActor);
    if((aPawn == none) && aPawn.m_ePawnType != PAWN_Hostage)
    {
        return;
    }
    foreach DynamicActors(Class'R6Engine.R6Hostage', hostage)
    {
        if((hostage.m_bExtracted && hostage.IsAlive()) && !hostage.m_bFeedbackExtracted)
        {
            hostage.m_bFeedbackExtracted = true;
            bSendMsg = true;
        }
        if(hostage.m_iPrisonierTeam == 5)
        {
            if(hostage.IsAlive())
            {
                iTotalAliveA++;
                if(hostage.m_bExtracted)
                {
                    iTotalRescuedA += 1;
                }
            }
            ++iTotalHostageA;
        }
        else
        {
            if(hostage.m_iPrisonierTeam == 6)
            {
                if(hostage.IsAlive())
                {
                    iTotalAliveB++;
                    if(hostage.m_bExtracted)
                    {
                        iTotalRescuedB += 1;
                    }
                }
                ++iTotalHostageB;
            }
        }
    }
    if(bSendMsg)
    {
        if(R6Hostage(anActor).m_iPrisonierTeam == 5)
        {
            if(iTotalHostageA == iTotalRescuedA)
            {
                if(bShowLog)
                {
                    log(" ** Game: All Prisoners for Team A Have Been Rescued");
                }
                BroadcastMissionObjMsg(m_szMP2Localization, "", "AllPrisonersForTeamAHaveBeenRescued");
            }
            else
            {
                if(bShowLog)
                {
                    log(" ** Game: A Prisoner Has Been Rescued By Team A");
                }
                BroadcastMissionObjMsg(m_szMP2Localization, "", "PrisonerHasBeenRescuedByTeamA");
            }
        }
        else
        {
            if(iTotalHostageB == iTotalRescuedB)
            {
                if(bShowLog)
                {
                    log(" ** Game: All Prisoners for Team B Have Been Rescued");
                }
                BroadcastMissionObjMsg(m_szMP2Localization, "", "AllPrisonersForTeamBHaveBeenRescued");
            }
            else
            {
                if(bShowLog)
                {
                    log(" ** Game: A Prisoner Has Been Rescued By Team B");
                }
                BroadcastMissionObjMsg(m_szMP2Localization, "", "PrisonerHasBeenRescuedByTeamB");
            }
        }
    }

    for(P = Level.ControllerList; P != none; P = P.nextController)
    {
        if(!P.IsA('PlayerController'))
        {
            continue;
        }
        if(MP2PlayerController(P).m_TeamSelection == PTS_Alpha)
        {
            MP2PlayerController(P).m_iNbPrisonersSaved = iTotalRescuedA;
        }
        else
        {
            if(MP2PlayerController(P).m_TeamSelection == PTS_Bravo)
            {
                MP2PlayerController(P).m_iNbPrisonersSaved = iTotalRescuedB;
            }
        }
    }
    super(R6GameInfo).EnteredExtractionZone(aPawn);
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local int iWinnerTeam;

    if(m_bGameOver)
    {
        return;
    }
    if(m_objDeathmatch.m_bFailed)
    {
        if(bShowLog)
        {
            log("** Game : it's a draw");
        }
        BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));
    }
    else
    {
        if(m_objPrisonerLossesByAlpha.m_bFailed)
        {
            if(bShowLog)
            {
                log("** Game : bravo win, because alpha eleminated too much hostage");
            }
            BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
            BroadcastMissionObjMsg(m_szMP2Localization, "", "GreenEleminatedAPrisoner", none, int(GetGameMsgLifeTime()));
            AddTeamWonRound(c_iBravoTeam);
        }
        else
        {
            if(m_objPrisonerLossesByBravo.m_bFailed)
            {
                if(bShowLog)
                {
                    log("** Game : alpha win, because bravo eleminated too much hostage");
                }
                BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
                BroadcastMissionObjMsg(m_szMP2Localization, "", "RedEleminatedAPrisoner", none, int(GetGameMsgLifeTime()));
                AddTeamWonRound(c_iAlphaTeam);
            }
            else
            {
                if(m_objRescuePrisoner.m_bFailed)
                {
                    if(bShowLog)
                    {
                        log("** Game : it's a draw");
                    }
                    BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));
                }
                else
                {
                    if(m_objDeathmatch.m_bCompleted)
                    {
                        iWinnerTeam = GetWinnerTeamDependingOnNbPrisonersRescued();
                        if(iWinnerTeam == 2)
                        {
                            if(bShowLog)
                            {
                                log("** Game : alpha rescued all prisoner");
                            }
                            BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
                            BroadcastMissionObjMsg(m_szMP2Localization, "", "GreenSavedTooManyPrisoners", none, int(GetGameMsgLifeTime()));
                            AddTeamWonRound(c_iAlphaTeam);
                        }
                        else
                        {
                            if(iWinnerTeam == 3)
                            {
                                if(bShowLog)
                                {
                                    log("** Game : Bravo rescued all prisoner");
                                }
                                BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
                                BroadcastMissionObjMsg(m_szMP2Localization, "", "RedSavedTooManyPrisoners", none, int(GetGameMsgLifeTime()));
                                AddTeamWonRound(c_iBravoTeam);
                            }
                            else
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
                        }
                    }
                    else
                    {
                        if(m_objRescuePrisoner.m_bCompleted)
                        {
                            if(m_objRescuePrisoner.m_iWinningTeam == 2)
                            {
                                if(bShowLog)
                                {
                                    log("** Game : alpha rescued all prisoner");
                                }
                                BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
                                AddTeamWonRound(c_iAlphaTeam);
                            }
                            else
                            {
                                if(m_objRescuePrisoner.m_iWinningTeam == 3)
                                {
                                    if(bShowLog)
                                    {
                                        log("** Game : Bravo rescued all prisoner");
                                    }
                                    BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
                                    AddTeamWonRound(c_iBravoTeam);
                                }
                            }
                        }
                        else
                        {
                            iWinnerTeam = GetWinnerTeamDependingOnNbPrisonersRescued();
                            if(iWinnerTeam == 2)
                            {
                                if(bShowLog)
                                {
                                    log("** Game : alpha rescued all prisoner");
                                }
                                BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
                                BroadcastMissionObjMsg(m_szMP2Localization, "", "GreenSavedTooManyPrisoners", none, int(GetGameMsgLifeTime()));
                                AddTeamWonRound(c_iAlphaTeam);
                            }
                            else
                            {
                                if(iWinnerTeam == 3)
                                {
                                    if(bShowLog)
                                    {
                                        log("** Game : Bravo rescued all prisoner");
                                    }
                                    BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
                                    BroadcastMissionObjMsg(m_szMP2Localization, "", "RedSavedTooManyPrisoners", none, int(GetGameMsgLifeTime()));
                                    AddTeamWonRound(c_iBravoTeam);
                                }
                                else
                                {
                                    if(bShowLog)
                                    {
                                        log("** Game : it's a draw");
                                    }
                                    BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    super(R6AdversarialTeamGame).EndGame(Winner, Reason);
}

function int GetWinnerTeamDependingOnNbPrisonersRescued()
{
    local int iTotalRescuedA, iTotalRescuedB;
    local R6Hostage hostage;

    iTotalRescuedA = 0;
    iTotalRescuedB = 0;
    foreach DynamicActors(Class'R6Engine.R6Hostage', hostage)
    {
        if(hostage.m_iPrisonierTeam == 5)
        {
            if(hostage.IsAlive())
            {
                if(hostage.m_bExtracted)
                {
                    iTotalRescuedA += 1;
                }
            }
        }
        else
        {
            if(hostage.m_iPrisonierTeam == 6)
            {
                if(hostage.IsAlive())
                {
                    if(hostage.m_bExtracted)
                    {
                        iTotalRescuedB += 1;
                    }
                }
            }
        }
    }
    if(iTotalRescuedA > iTotalRescuedB)
    {
        return 2;
    }
    else
    {
        if(iTotalRescuedB > iTotalRescuedA)
        {
            return 3;
        }
        else
        {
            return -1;
        }
    }
}

function SetPawnTeamFriendlies(Pawn aPawn)
{
    if(R6Hostage(aPawn) != none)
    {
        return;
    }
    switch(aPawn.m_iTeam)
    {
        case 1:
            aPawn.m_iFriendlyTeams = GetTeamNumBit(1);
            aPawn.m_iEnemyTeams = GetTeamNumBit(2);
            aPawn.m_iEnemyTeams += (GetTeamNumBit(3));
            break;
        case 2:
            aPawn.m_iFriendlyTeams = GetTeamNumBit(2);
            aPawn.m_iEnemyTeams = GetTeamNumBit(3);
            aPawn.m_iEnemyTeams += (GetTeamNumBit(1));
            R6Pawn(aPawn).m_bCanFireFriends = false;
            R6Pawn(aPawn).m_bCanFireNeutrals = true;
            break;
        case 3:
            aPawn.m_iFriendlyTeams = GetTeamNumBit(3);
            aPawn.m_iEnemyTeams = GetTeamNumBit(2);
            aPawn.m_iEnemyTeams += (GetTeamNumBit(c_iTeamNumTerrorist));
            aPawn.m_iEnemyTeams += (GetTeamNumBit(0));
            R6Pawn(aPawn).m_bCanFireFriends = false;
            R6Pawn(aPawn).m_bCanFireNeutrals = true;
            break;
        default:
            log((("warning: SetPawnTeamFriendlies team not supported for " $ string(aPawn.Name)) $ " team=") $ string(aPawn.m_iTeam));
            break;
    }
}

function SetPawnTeamFriendliesForHostage(R6Hostage hostage)
{
    switch(hostage.m_iPrisonierTeam)
    {
        case 0:
            hostage.m_iFriendlyTeams = 0;
            hostage.m_iEnemyTeams = GetTeamNumBit(1);
            hostage.m_iEnemyTeams += (GetTeamNumBit(3));
            break;
        case 5:
            hostage.m_iFriendlyTeams = 0;
            hostage.m_iFriendlyTeams += (GetTeamNumBit(2));
            hostage.m_iEnemyTeams = GetTeamNumBit(1);
            hostage.m_iEnemyTeams += (GetTeamNumBit(3));
            hostage.m_iEnemyTeams += (GetTeamNumBit(6));
            break;
        case 6:
            hostage.m_iFriendlyTeams = 0;
            hostage.m_iFriendlyTeams += (GetTeamNumBit(3));
            hostage.m_iEnemyTeams = GetTeamNumBit(1);
            hostage.m_iEnemyTeams += (GetTeamNumBit(2));
            hostage.m_iEnemyTeams += (GetTeamNumBit(5));
            break;
        default:
            log((("warning: SetPawnTeamFriendlies team not supported for " $ string(hostage.Name)) $ " team=") $ string(hostage.m_iTeam));
            break;
    }
}

auto state InBetweenRoundMenu
{
    function EndState()
    {
        SpawnAIandInitGoInGame();
        super.EndState();
    }
}

defaultproperties
{
    m_szMP2Localization="IronWrathMissionObjectives"
    m_iUbiComGameMode=6
    m_bFeedbackHostageExtracted=false
    m_szGameTypeFlag="RGM_LimitSeatsAdvMode"
}
