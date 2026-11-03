class MP2IntruderAdvGame extends MP2AdversarialTeamGame
    config;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Voices_Control_MP2GameModes.uax PACKAGE=Voices_Control_MP2GameModes

var MP2PlayerController m_intruderController;
var Sound m_sndIntruder;
var MP2MObjObjectsInteraction objsInteractionChbani;
var string m_szIntruderSkin;
var string m_szMP2Localization;

function InitObjectives()
{
    local int iLength;
    local bool bDeviceExist;
    local MP2IODevice ioDevice;
    local MP2MObjObjectsInteraction objsInteraction;

    iLength = m_missionMgr.m_aMissionObjectives.Length;
    objsInteraction = new (none) Class<MP2MObjObjectsInteraction>(DynamicLoadObject("MP2Game.MP2MObjObjectsInteraction", Class'Core.Class'));
    if(objsInteraction == none)
    {
        log("wa jma3 rassek a mhammed");
    }
    m_missionMgr.m_aMissionObjectives[iLength] = objsInteraction;
    iLength++;
    objsInteraction.m_bIfCompletedMissionIsSuccessfull = true;
    objsInteraction.m_bIfDeviceIsActivatedObjectiveIsCompleted = false;
    objsInteraction.m_bIfDeviceIsActivatedObjectiveIsFailed = false;
    objsInteraction.m_bIfDeviceIsDeactivatedObjectiveIsCompleted = true;
    objsInteraction.m_bIfDeviceIsDeactivatedObjectiveIsFailed = false;
    objsInteraction.m_bIfDestroyedObjectiveIsCompleted = false;
    objsInteraction.m_bIfDestroyedObjectiveIsFailed = false;
    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    Level.m_bUseDefaultMoralityRules = false;
    super(R6AdversarialTeamGame).InitObjectives();
}

function PawnKilled(Pawn killedPawn)
{
    if(m_bGameOver)
    {
        return;
    }
    super(R6GameInfo).PawnKilled(killedPawn);
}

function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
    local MP2IODevice ioDevice;
    local int iNbTerminals, iNbTerminalsDesactivated, iNbTerminalsLeft;
    local string sText;

    super(R6AbstractGameInfo).IObjectInteract(aPawn, anInteractiveObject);
    if(m_bGameOver)
    {
        return;
    }
    iNbTerminals = 0;
    iNbTerminalsDesactivated = 0;
    foreach AllActors(Class'R6Engine.MP2IODevice', ioDevice)
    {
        iNbTerminals++;
        if(ioDevice.m_bIsActivated == false)
        {
            iNbTerminalsDesactivated++;
        }
    }
    ioDevice = MP2IODevice(anInteractiveObject);
    if(ioDevice.m_bIsActivated == false)
    {
        ioDevice.SetNewDamageState(50.0);
        iNbTerminalsLeft = iNbTerminals - iNbTerminalsDesactivated;
        sText = (((Localize("Game", "Terminal", m_szMP2Localization)) $ " ") $ string(ioDevice.m_iTerminalIndex)) $ " ";
        BroadcastMissionObjMsg(m_szMP2Localization, sText, "IsDamaged", none, int(GetGameMsgLifeTime()));
        BroadcastMissionObjMsg(m_szMP2Localization, string(iNbTerminalsLeft), "TerminalsLeft", none, int(GetGameMsgLifeTime()));
    }
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;
    local MP2IODevice ioDevice;
    local bool bDeviceActivated;
    local int iNbTerminals, iNbTerminalsDesactivated, iNbTerminalsLeft;

    if(m_bGameOver)
    {
        return;
    }
    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    bDeviceActivated = false;
    iNbTerminals = 0;
    iNbTerminalsDesactivated = 0;
    foreach AllActors(Class'R6Engine.MP2IODevice', ioDevice)
    {
        iNbTerminals++;
        if(ioDevice.m_bIsActivated == false)
        {
            iNbTerminalsDesactivated++;
        }
    }
    if(iNbTerminalsDesactivated == iNbTerminals)
    {
        if(bShowLog)
        {
            log("** Game : alpha damaged all terminals");
        }
        BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
        BroadcastMissionObjMsg(m_szMP2Localization, "", "AllTerminalAreDamaged", none, int(GetGameMsgLifeTime()));
        AddTeamWonRound(c_iAlphaTeam);
    }
    else
    {
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
                iNbTerminalsLeft = iNbTerminals - iNbTerminalsDesactivated;
                if(bShowLog)
                {
                    log("** Game : red protected all terminals");
                }
                BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
                BroadcastMissionObjMsg(m_szMP2Localization, string(iNbTerminalsLeft), "TerminalsProtected", none, int(GetGameMsgLifeTime()));
                AddTeamWonRound(c_iBravoTeam);
            }
        }
    }
    super(R6AdversarialTeamGame).EndGame(Winner, Reason);
}

function R6SetPawnClassInMultiPlayer(Controller PlayerController)
{
    if(PlayerController == m_intruderController)
    {
        MP2PlayerController(PlayerController).PawnClass = Class<Pawn>(DynamicLoadObject(m_szIntruderSkin, Class'Core.Class'));
    }
    else
    {
        super(R6GameInfo).R6SetPawnClassInMultiPlayer(PlayerController);
    }
}

function BroadcastGameTypeDescription()
{
    local Controller P;
    local MP2PlayerController PlayerController;

    super(R6GameInfo).BroadcastGameTypeDescription();
    if(m_intruderController == none)
    {
        return;
    }
    if(m_intruderController.PlayerReplicationInfo == none)
    {
        return;
    }
    m_intruderController.ClientMissionObjMsg(m_szMP2Localization, "", "YouAretheIntruder");
    m_intruderController.ClientPlaySound(m_sndIntruder, SLOT_Speak);

    for(P = Level.ControllerList; P != none; P = P.nextController)
    {
        PlayerController = MP2PlayerController(P);
        if(((PlayerController != m_intruderController) && PlayerController != none) && PlayerController.m_TeamSelection == PTS_Alpha)
        {
            PlayerController.ClientMissionObjMsg(m_szMP2Localization, m_intruderController.PlayerReplicationInfo.PlayerName, "PlayerIsTheIntruder");
        }
    }
}

function bool CanAutoBalancePlayer(R6PlayerController pCtrl)
{
    if(pCtrl.PlayerReplicationInfo.m_bIsTheIntruder)
    {
        return false;
    }
    return true;
}

state PostBetweenRoundTime
{
    function EndState()
    {
        super.EndState();
        if(m_intruderController != none)
        {
            m_intruderController.m_pawn.m_bIsTheIntruder = true;
            m_intruderController.PlayerReplicationInfo.m_bIsTheIntruder = true;
            m_intruderController.PawnClass = Class<Pawn>(DynamicLoadObject(m_szIntruderSkin, Class'Core.Class'));
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
        m_intruderController = none;

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
            MP2PlayerController(P).m_pawn.m_bIsTheIntruder = false;
            P.PlayerReplicationInfo.m_bIsTheIntruder = false;
        }
        if(m_intruderController == none)
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
                                log("InBetweenRoundMenu: set new pilot");
                            }
                            P.PlayerReplicationInfo.m_bIsTheIntruder = true;
                            m_intruderController = MP2PlayerController(P);
                            m_intruderController.m_pawn.m_bIsTheIntruder = true;
                            P.PawnClass = Class<Pawn>(DynamicLoadObject(m_szIntruderSkin, Class'Core.Class'));
                            break;
                        }
                        else
                        {
                            P.PlayerReplicationInfo.m_bIsTheIntruder = false;
                            MP2PlayerController(P).m_pawn.m_bIsTheIntruder = false;
                            if(m_intruderController != none)
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
    m_sndIntruder=Sound'Voices_Control_MP2GameModes.Play_YouAreIntruder'
    m_szIntruderSkin="MP2Characters.MP2RainbowIntruder"
    m_szMP2Localization="IronWrathMissionObjectives"
    m_iUbiComGameMode=10
    m_szGameTypeFlag="RGM_IntruderAdvMode"
}
