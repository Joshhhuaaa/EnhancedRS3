class MP2FreeBackupAdvGame extends MP2AdversarialTeamGame
    config;

const CMaxRainbowAIForFreeBackup = 24;

var MP2FreeBackUpObjDeathmatch m_objFreeBackupDeathmatch;
var array<MP2FreeBackupInsertionZone> m_FreeBackupInsertionZone;
var array<MP2FreeBackupInsertionZone> m_FBHighPriorityInsertionZone;

function InitObjectives()
{
    local Class<MP2FreeBackUpObjDeathmatch> m_objFreeBackupDeathmatchClass;
    local int iLength;

    if(m_bAddObjDeathmatch)
    {
        m_objFreeBackupDeathmatchClass = Class<MP2FreeBackUpObjDeathmatch>(DynamicLoadObject("MP2Game.MP2FreeBackUpObjDeathmatch", Class'Core.Class'));
        m_objFreeBackupDeathmatch = new (none) m_objFreeBackupDeathmatchClass;
        m_objFreeBackupDeathmatch.m_bTeamDeathmatch = true;
        iLength = m_missionMgr.m_aMissionObjectives.Length;
        m_missionMgr.m_aMissionObjectives[iLength] = m_objFreeBackupDeathmatch;
        iLength++;
    }
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

simulated function FirstPassReset()
{
    if(m_FreeBackupInsertionZone.Length > 0)
    {
        m_FreeBackupInsertionZone.Remove(0, m_FreeBackupInsertionZone.Length);
    }
    if(m_FBHighPriorityInsertionZone.Length > 0)
    {
        m_FBHighPriorityInsertionZone.Remove(0, m_FBHighPriorityInsertionZone.Length);
    }
    super(R6GameInfo).FirstPassReset();
}

function bool CanSwitchTeamMember()
{
    return false;
}

function int GetNbOfFreeBackupToSpawn()
{
    return m_iNbOfRainbowAIToSpawn;
}

function SetTeamKillerPenalty(Pawn DeadPawn, Pawn KillerPawn)
{
    local R6PlayerController pControllerDead, pControllerKiller;

    if(Level.IsGameTypeCooperative(m_szGameTypeFlag))
    {
        return;
    }
    pControllerKiller = R6PlayerController(R6Pawn(KillerPawn).Controller);
    if((pControllerKiller == none) || !Level.IsGameTypeMultiplayer(m_szGameTypeFlag))
    {
        return;
    }
    pControllerDead = R6PlayerController(R6Pawn(DeadPawn).Controller);
    if((DeadPawn.m_ePawnType == PAWN_Hostage) && KillerPawn != DeadPawn)
    {
        pControllerKiller.m_ePenaltyForKillingAPawn = DeadPawn.m_ePawnType;
        pControllerKiller.m_bHasAPenalty = true;
    }
    else
    {
        if(((m_bTKPenalty && KillerPawn.IsFriend(DeadPawn)) && KillerPawn != DeadPawn) && !pControllerDead.m_bAlreadyPoppedTKPopUpBox)
        {
            if(pControllerDead != none)
            {
                pControllerDead.m_TeamKiller = pControllerKiller;
                pControllerDead.TKPopUpBox(pControllerKiller.PlayerReplicationInfo.PlayerName);
                pControllerDead.m_bAlreadyPoppedTKPopUpBox = true;
            }
            pControllerKiller.m_ePenaltyForKillingAPawn = DeadPawn.m_ePawnType;
        }
    }
}

function DeployFreeBackup()
{
    local R6RainbowTeam newTeam;
    local int iMembers;
    local R6RainbowStartInfo Info;

    iMembers = GetNbOfFreeBackupToSpawn();
    Info = Spawn(Class'Engine.R6RainbowStartInfo');
    Info.m_ArmorName = "MP2Characters.MP2NeutralFighter";
    Info.m_CharacterName = Localize("Game", "NeutralFighter", "IronWrathGameInfo");
    Info.m_WeaponName[0] = "R63rdWeapons.NormalSubMP5A4";
    Info.m_WeaponName[1] = "R63rdWeapons.NormalPistol92FS";
    Info.m_BulletType[0] = "R6Weapons.Ammo9mmParabellumNormalFMJ";
    Info.m_BulletType[1] = "R6Weapons.Ammo9mmParabellumNormalFMJ";
    Info.m_WeaponGadgetName[0] = "R6Weapons.R6FlashBangGadget";
    Info.m_WeaponGadgetName[1] = "R6Weapons.R6FragGrenadeGadget";
    Info.m_iOperativeID = 100;
    Info.m_bIsMale = true;
    Info.m_iHealth = 0;
    Info.m_FaceTexture = DefaultFaceTexture;
    Info.m_FaceCoords = DefaultFaceCoords;
    CreateMPFreeBackup(Info, iMembers);
}

function CreateMPFreeBackup(R6RainbowStartInfo Info, int iMemberCount)
{
    local int i;

    for(i = 0; i < iMemberCount; i++)
    {
        CreateFreeBackup(Info);
    }
    Info.Destroy();
}

function CreateFreeBackup(R6RainbowStartInfo RainbowToCreate)
{
    local MP2RainbowAI rainbowAI;
    local Vector vOriginStart, vStart;
    local Class<MP2Rainbow> rainbowPawnClass;
    local MP2Rainbow Rainbow;
    local Rotator rStartingPointRot;
    local NavigationPoint StartingPoint;
    local int i;
    local MP2FreeBackupInsertionZone FBInsertionZone;

    if(Level.NetMode == NM_Client)
    {
        return;
    }
    FBInsertionZone = MP2FreeBackupInsertionZone(MP2FreeBackupAdvGame(Level.Game).GetFreeBackupInsertionZoneFromTable());
    if(FBInsertionZone == none)
    {
        return;
    }
    StartingPoint = FBInsertionZone;
    vOriginStart = StartingPoint.Location;
    rStartingPointRot = StartingPoint.Rotation;
    rStartingPointRot.Roll = 0;
    vStart = vOriginStart;
    if(RainbowToCreate == none)
    {
        log((string(self) $ " CreateTeamMember() : RainbowToCreate is none ... ") $ RainbowToCreate.m_ArmorName);
        return;
    }
    rainbowPawnClass = Class<MP2Rainbow>(DynamicLoadObject(RainbowToCreate.m_ArmorName, Class'Core.Class'));
    if(rainbowPawnClass == none)
    {
        log(string(self) $ " CreateTeamMember() : rainbowPawnClass is none ... ");
        return;
    }
    rainbowPawnClass.default.bIsFemale = !RainbowToCreate.m_bIsMale;
    rainbowPawnClass.default.m_iTeam = 7;
    Rainbow = Spawn(rainbowPawnClass,,, vStart, rStartingPointRot, false);
    if(Rainbow != none)
    {
        Rainbow.m_szPrimaryWeapon = RainbowToCreate.m_WeaponName[0];
        Rainbow.m_szPrimaryGadget = RainbowToCreate.m_WeaponGadgetName[0];
        Rainbow.m_szPrimaryBulletType = RainbowToCreate.m_BulletType[0];
        Rainbow.m_szSecondaryWeapon = RainbowToCreate.m_WeaponName[1];
        Rainbow.m_szSecondaryGadget = RainbowToCreate.m_WeaponGadgetName[1];
        Rainbow.m_szSecondaryBulletType = RainbowToCreate.m_BulletType[1];
        Rainbow.m_szPrimaryItem = RainbowToCreate.m_GadgetName[0];
        Rainbow.m_szSecondaryItem = RainbowToCreate.m_GadgetName[1];
        Rainbow.m_szSpecialityID = RainbowToCreate.m_szSpecialityID;
        Rainbow.m_FaceTexture = RainbowToCreate.m_FaceTexture;
        Rainbow.m_FaceCoords = RainbowToCreate.m_FaceCoords;
        Rainbow.m_fSkillAssault = RainbowToCreate.m_fSkillAssault;
        Rainbow.m_fSkillDemolitions = RainbowToCreate.m_fSkillDemolitions;
        Rainbow.m_fSkillElectronics = RainbowToCreate.m_fSkillElectronics;
        Rainbow.m_fSkillSniper = RainbowToCreate.m_fSkillSniper;
        Rainbow.m_fSkillStealth = RainbowToCreate.m_fSkillStealth;
        Rainbow.m_fSkillSelfControl = RainbowToCreate.m_fSkillSelfControl;
        Rainbow.m_fSkillLeadership = RainbowToCreate.m_fSkillLeadership;
        Rainbow.m_fSkillObservation = RainbowToCreate.m_fSkillObservation;
        Rainbow.m_eHealth = HEALTH_Healthy;
        if(((FBInsertionZone.m_iSkinIndex != -1) && FBInsertionZone.m_iSkinIndex < 6) && FBInsertionZone.m_iSkinIndex >= 0)
        {
            Rainbow.m_iOperativeID = RainbowToCreate.m_iOperativeID + FBInsertionZone.m_iSkinIndex;
        }
        else
        {
            Rainbow.m_iOperativeID = RainbowToCreate.m_iOperativeID + Rand(6);
        }
    }
    else
    {
        // Joshua - Empty in the shipped bytecode, most likely a debug log compiled out
    }
    Rainbow.m_vStartLocation = vStart;
    Rainbow.m_CharacterName = RainbowToCreate.m_CharacterName;
    rainbowAI = MP2RainbowAI(R6AbstractGameInfo(Level.Game).GetRainbowAIFromTable());
    rainbowAI.Possess(Rainbow);
    Rainbow.Controller = rainbowAI;
    rainbowAI.Focus = none;
    rainbowAI.m_TeamLeader = none;
    rainbowAI.FreeBackupSetMemberTeamID(Rainbow, 7);
    rainbowAI.SetRotation(StartingPoint.Rotation);
    rainbowAI.m_TeamManager = none;
    Rainbow.m_iID = -1;
    Rainbow.m_iPermanentID = Rainbow.m_iID;
    Rainbow.GiveDefaultWeapon();
    SetNeutralFighterFaceTexture(Rainbow);
    rainbowAI.NextState = 'None';
    rainbowAI.GotoState('FreeBackupWait');
}

function Actor GetFreeBackupInsertionZoneFromTable()
{
    local int i;
    local MP2FreeBackupInsertionZone NavPoint;

    if((Level.NetMode == NM_Standalone) || Level.NetMode == NM_Client)
    {
        return none;
    }
    if(m_FBHighPriorityInsertionZone.Length == 0)
    {
        if(m_FreeBackupInsertionZone.Length == 0)
        {
            return none;
        }
        i = Rand(m_FreeBackupInsertionZone.Length);
        NavPoint = m_FreeBackupInsertionZone[i];
        m_FreeBackupInsertionZone.Remove(i, 1);
    }
    else
    {
        i = Rand(m_FBHighPriorityInsertionZone.Length);
        NavPoint = m_FBHighPriorityInsertionZone[i];
        m_FBHighPriorityInsertionZone.Remove(i, 1);
    }
    return NavPoint;
}

function SetNeutralFighterFaceTexture(MP2Rainbow aNeutralFighter)
{
    local string sFaceTexture;

    switch(aNeutralFighter.m_iOperativeID)
    {
        case 100:
            sFaceTexture = "MP2Characters_T.NeutralFighter.NFHead1";
            break;
        case 101:
            sFaceTexture = "MP2Characters_T.NeutralFighter.NFHead2";
            break;
        case 102:
            sFaceTexture = "MP2Characters_T.NeutralFighter.NFHead3";
            break;
        case 103:
            sFaceTexture = "MP2Characters_T.NeutralFighter.NFHead4";
            break;
        case 104:
            sFaceTexture = "MP2Characters_T.NeutralFighter.NFHead5";
            break;
        case 105:
            sFaceTexture = "MP2Characters_T.NeutralFighter.NFHead6";
            break;
        default:
            sFaceTexture = "MP2Characters_T.NeutralFighter.NFHead1";
    }
    if(sFaceTexture != "")
    {
        aNeutralFighter.SetSkin(Texture(DynamicLoadObject(sFaceTexture, Class'Engine.Texture')), 1);
    }
}

function CreateBackupRainbowAIForFreeBackup()
{
    local MP2RainbowAI rainbowAI;
    local int i;
    local MP2FreeBackupInsertionZone NavPoint;

    for(i = 0; i < 24; i++)
    {
        rainbowAI = Spawn(Class'MP2Game.MP2RainbowAI');
        rainbowAI.bStasis = true;
        m_RainbowAIBackup[m_RainbowAIBackup.Length] = rainbowAI;
    }
    foreach AllActors(Class'MP2Game.MP2FreeBackupInsertionZone', NavPoint)
    {
        if(NavPoint.IsAvailableInGameType(m_szGameTypeFlag))
        {
            if(NavPoint.m_bHighPriority == true)
            {
                m_FBHighPriorityInsertionZone[m_FBHighPriorityInsertionZone.Length] = NavPoint;
            }
            else
            {
                m_FreeBackupInsertionZone[m_FreeBackupInsertionZone.Length] = NavPoint;
            }
        }
    }
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;

    if(m_bGameOver)
    {
        return;
    }
    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    if(m_objFreeBackupDeathmatch.m_bCompleted)
    {
        if(m_objFreeBackupDeathmatch.m_iWinningTeam == 2)
        {
            BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
            BroadcastMissionObjMsg("", "", "GreenNeutralizedRed", none, int(GetGameMsgLifeTime()));
            AddTeamWonRound(c_iAlphaTeam);
        }
        else
        {
            if(m_objFreeBackupDeathmatch.m_iWinningTeam == 3)
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

function SetPawnTeamFriendlies(Pawn aPawn)
{
    local int iFriendlyTeams, iEnemyTeams;

    aPawn.m_iFriendlyTeams = 0;
    aPawn.m_iEnemyTeams = 0;
    iFriendlyTeams = aPawn.m_iFriendlyTeams;
    iEnemyTeams = aPawn.m_iEnemyTeams;
    switch(aPawn.m_iTeam)
    {
        case 7:
            aPawn.m_iFriendlyTeams = 0;
            aPawn.m_iEnemyTeams = 0;
            iFriendlyTeams = aPawn.m_iFriendlyTeams;
            iEnemyTeams = aPawn.m_iEnemyTeams;
            break;
        case 2:
            aPawn.m_iFriendlyTeams = GetTeamNumBit(2);
            aPawn.m_iEnemyTeams = GetTeamNumBit(3);
            iFriendlyTeams = aPawn.m_iFriendlyTeams;
            iEnemyTeams = aPawn.m_iEnemyTeams;
            break;
        case 3:
            aPawn.m_iFriendlyTeams = GetTeamNumBit(3);
            aPawn.m_iEnemyTeams = GetTeamNumBit(c_iTeamNumAlpha);
            iFriendlyTeams = aPawn.m_iFriendlyTeams;
            iEnemyTeams = aPawn.m_iEnemyTeams;
            break;
    }
}

state PostBetweenRoundTime
{
    function PostBetweenRoundTimeDone()
    {
        if(m_FBHighPriorityInsertionZone.Length > 0)
        {
            m_FBHighPriorityInsertionZone.Remove(0, m_FBHighPriorityInsertionZone.Length);
        }
        if(m_FreeBackupInsertionZone.Length > 0)
        {
            m_FreeBackupInsertionZone.Remove(0, m_FreeBackupInsertionZone.Length);
        }
        super.PostBetweenRoundTimeDone();
    }
}

auto state InBetweenRoundMenu
{
    function BeginState()
    {
        super.BeginState();
    }

    function EndState()
    {
        local int iNbOfPlayer;
        local Controller P;

        if(Level.m_iNbOfFreeBackupToSpawn != 0)
        {
            m_iNbOfRainbowAIToSpawn = Level.m_iNbOfFreeBackupToSpawn;
        }
        else
        {

            for(P = Level.ControllerList; P != none; P = P.nextController)
            {
                if(P.IsA('PlayerController') && P.PlayerReplicationInfo != none)
                {
                    ++iNbOfPlayer;
                }
            }
            m_iNbOfRainbowAIToSpawn = iNbOfPlayer * Level.m_iNbOfFBToSpawnBasedOnNbPlayers;
        }
        CreateBackupRainbowAIForFreeBackup();
        DeployFreeBackup();
        super.EndState();
    }
}

defaultproperties
{
    m_iUbiComGameMode=8
    m_szGameTypeFlag="RGM_FreeBackupAdvMode"
}
