class MP2VirusUploadAdvGame extends MP2AdversarialTeamGame
    config;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Voices_Control_MP2GameModes.uax PACKAGE=Voices_Control_MP2GameModes

var MP2PlayerController m_pilotController;
var Actor m_Floppy;
var Sound m_sndPilot;

function PawnKilled(Pawn killedPawn)
{
    local Vector NewLocation;
    local Controller P;

    if(m_bGameOver)
    {
        Level.m_bShowFloppy = false;
        return;
    }
    if(MP2Rainbow(killedPawn).m_bHasDataObject)
    {
        MP2Rainbow(killedPawn).m_bHasDataObject = false;
        if((MP2Rainbow(killedPawn).m_bIsClimbingLadder == true) && MP2Rainbow(killedPawn).m_Ladder != none)
        {
            NewLocation = MP2Rainbow(killedPawn).OnLadder.LadderList.Location - (float(70) * Vector(MP2Rainbow(killedPawn).OnLadder.LadderList.Rotation));
            m_Floppy.SetLocation(NewLocation);
        }
        else
        {
            NewLocation = killedPawn.Location;
            m_Floppy.SetLocation(NewLocation);
        }
        m_Floppy.SetPhysics(PHYS_Falling);
        R6IOFloppy(m_Floppy).StartFalling(NewLocation);
        m_Floppy.SetOwner(none);
        m_Floppy.SetCollisionSize(35.0, 55.0);
        Level.m_bShowFloppy = true;
    }
    super(R6GameInfo).PawnKilled(killedPawn);
}

function bool CanAutoBalancePlayer(R6PlayerController pCtrl)
{
    if(pCtrl.PlayerReplicationInfo.m_bHasTheFloppy)
    {
        return false;
    }
    return true;
}

function InitObjectives()
{
    local int iLength;
    local bool bDeviceExist;
    local MP2LapTop ioDevice;
    local R6MObjObjectInteraction objInteraction;

    AddSoundBankName("SFX_MdeGazAlrt");
    iLength = m_missionMgr.m_aMissionObjectives.Length;
    foreach AllActors(Class'MP2Game.MP2LapTop', ioDevice)
    {
        objInteraction = new (none) Class'R6Game.R6MObjObjectInteraction';
        objInteraction.m_r6IOObject = ioDevice;
        m_missionMgr.m_aMissionObjectives[iLength] = objInteraction;
        iLength++;
        objInteraction.m_bIfCompletedMissionIsSuccessfull = true;
        objInteraction.m_bIfDeviceIsActivatedObjectiveIsCompleted = false;
        objInteraction.m_bIfDeviceIsActivatedObjectiveIsFailed = false;
        objInteraction.m_bIfDeviceIsDeactivatedObjectiveIsCompleted = true;
        objInteraction.m_bIfDeviceIsDeactivatedObjectiveIsFailed = false;
        objInteraction.m_bIfDestroyedObjectiveIsCompleted = false;
        objInteraction.m_bIfDestroyedObjectiveIsFailed = false;
        bDeviceExist = true;
        if(bShowLog)
        {
            log("Device Added: " $ string(ioDevice));
        }
    }
    if(!bDeviceExist && m_missionMgr.m_bEnableCheckForErrors)
    {
        log("WARNING: there is no bomb in the game type: " $ string(self));
    }
    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    Level.m_bUseDefaultMoralityRules = false;
    super(R6AdversarialTeamGame).InitObjectives();
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;
    local MP2LapTop ioDevice;
    local R6IOFloppy ioFloppy;
    local bool bDeviceActivated;

    if(m_bGameOver)
    {
        return;
    }
    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    foreach AllActors(Class'MP2Game.R6IOFloppy', ioFloppy)
    {
        ioFloppy.Destroy();
    }
    bDeviceActivated = false;
    foreach AllActors(Class'MP2Game.MP2LapTop', ioDevice)
    {
        if(ioDevice.m_bIsActivated == false)
        {
            bDeviceActivated = true;
            break;
        }
    }
    if(bDeviceActivated)
    {
        if(bShowLog)
        {
            log("** Game : alpha win: Virus uploaded");
        }
        BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
        BroadcastMissionObjMsg("", "", "VirusUploaded", none, int(GetGameMsgLifeTime()));
        AddTeamWonRound(c_iAlphaTeam);
    }
    else
    {
        if(m_objDeathmatch.m_bFailed)
        {
            if(bShowLog)
            {
                log("** Game : alpha prevented virus uploading");
            }
            BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
            BroadcastMissionObjMsg("", "", "DataProtocted", none, int(GetGameMsgLifeTime()));
            AddTeamWonRound(c_iBravoTeam);
        }
        else
        {
            if(m_objDeathmatch.m_bCompleted)
            {
                if(m_objDeathmatch.m_iWinningTeam == 2)
                {
                    if(bShowLog)
                    {
                        log("** Game : alpha eleminated bravo");
                    }
                    BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
                    BroadcastMissionObjMsg("", "", "GreenNeutralizedRed", none, int(GetGameMsgLifeTime()));
                    AddTeamWonRound(c_iAlphaTeam);
                }
                else
                {
                    if(m_objDeathmatch.m_iWinningTeam == 3)
                    {
                        if(bShowLog)
                        {
                            log("** Game : bravo eleminated alpha");
                        }
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
                    log("** Game : alpha prevented virus uploading");
                }
                BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
                BroadcastMissionObjMsg("", "", "DataProtocted", none, int(GetGameMsgLifeTime()));
                AddTeamWonRound(c_iBravoTeam);
            }
        }
    }
    super(R6AdversarialTeamGame).EndGame(Winner, Reason);
}

function BroadcastGameTypeDescription()
{
    local Controller P;
    local MP2PlayerController PlayerController;

    super(R6GameInfo).BroadcastGameTypeDescription();
    if(m_pilotController == none)
    {
        return;
    }
    if(m_pilotController.PlayerReplicationInfo == none)
    {
        return;
    }
    m_pilotController.ClientPlaySound(m_sndPilot, SLOT_Speak);

    for(P = Level.ControllerList; P != none; P = P.nextController)
    {
        PlayerController = MP2PlayerController(P);
        if((PlayerController != none) && PlayerController.m_TeamSelection == PTS_Alpha)
        {
            PlayerController.ClientMissionObjMsg("", m_pilotController.PlayerReplicationInfo.PlayerName, "PlayerHasTheCD");
        }
    }
}

state PostBetweenRoundTime
{
    function EndState()
    {
        local Controller P;

        super.EndState();

        for(P = Level.ControllerList; P != none; P = P.nextController)
        {
            if(!P.IsA('PlayerController'))
            {
                continue;
            }
            P.PlayerReplicationInfo.m_bHasTheFloppy = false;
            MP2PlayerController(P).m_pawn.m_bHasDataObject = false;
            MP2PlayerController(P).m_fCompteurFrameDetection = -1.0;
        }
        if(m_pilotController != none)
        {
            m_pilotController.PlayerReplicationInfo.m_bHasTheFloppy = true;
            MP2Rainbow(m_pilotController.m_pawn).m_bHasDataObject = true;
            m_pilotController.m_fCompteurFrameDetection = 0.0;
        }
    }
}

auto state InBetweenRoundMenu
{
    function EndState()
    {
        local Controller P;
        local int iTeamACount, iNewGen, i, iTotalPilot;

        ProcessAutoBalanceTeam();
        if(m_Floppy != none)
        {
            m_Floppy.Destroy();
            Level.m_bShowFloppy = false;
        }
        m_pilotController = none;

        for(P = Level.ControllerList; P != none; P = P.nextController)
        {
            if(!P.IsA('PlayerController'))
            {
                continue;
            }
            if(MP2PlayerController(P).m_TeamSelection == PTS_Alpha)
            {
                iTeamACount++;
            }
            P.PlayerReplicationInfo.m_bHasTheFloppy = false;
            MP2PlayerController(P).m_fCompteurFrameDetection = -1.0;
        }
        if(m_pilotController == none)
        {
            iNewGen = Rand(iTeamACount);
            i = 0;
            P = Level.ControllerList;

            while(P != none)
            {
                if(P.IsA('PlayerController'))
                {
                    if(MP2PlayerController(P).m_TeamSelection == PTS_Alpha)
                    {
                        if(i == iNewGen)
                        {
                            if(bShowLog)
                            {
                                log("fatim zahra virus upload InBetweenRoundMenu: set new pilot");
                            }
                            m_pilotController = MP2PlayerController(P);
                            P.PlayerReplicationInfo.m_bHasTheFloppy = true;
                            m_pilotController.m_fCompteurFrameDetection = 0.0;
                            Level.m_fCompteurFrameDetection = 0.0;
                            m_Floppy = Spawn(Class'MP2Game.R6IOFloppy', m_pilotController,, m_pilotController.Location);
                            m_Floppy.SetOwner(m_pilotController);
                            m_Floppy.SetPhysics(PHYS_None);
                            m_Floppy.SetCollision(false, false, false);
                            Level.m_bShowFloppy = false;
                            break;
                        }
                        else
                        {
                            P.PlayerReplicationInfo.m_bHasTheFloppy = false;
                            m_pilotController.m_fCompteurFrameDetection = -1.0;
                            if(m_pilotController != none)
                            {
                                break;
                            }
                            i++;
                        }
                    }
                }
                if(P != none)
                {
                    P = P.nextController;
                }
            }
        }
        super.EndState();
    }
}

defaultproperties
{
    m_sndPilot=Sound'Voices_Control_MP2GameModes.Play_YouHaveTheDisk'
    m_iUbiComGameMode=8
    m_szGameTypeFlag="RGM_VirusUploadAdvMode"
}
