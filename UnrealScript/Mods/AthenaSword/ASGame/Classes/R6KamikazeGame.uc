class R6KamikazeGame extends R6AdversarialTeamGame
    config;

var config bool EnableBombManPrimaryWeapon;
var config bool EnableBombManSecondaryWeapon;
var config bool EnableBombManTertiaryWeapon;
var bool IsBombDetonated;
var bool IsBombDefused;
var R6MObjKillBombMan m_objKillBombMan;
var R6PlayerController m_bombManController;
var R6PlayerController m_previousBombMan;
var Sound m_sndBombMan;
var string m_szBombManSkin;

event PostBeginPlay()
{
    super.PostBeginPlay();
    LoadConfig("R6KamikazeGame.ini");
}

function InitObjectives()
{
    local int iLength;

    m_objKillBombMan = new (none) Class'ASGame.R6MObjKillBombMan';
    m_objKillBombMan.SetBombManPawn(none);
    iLength = m_missionMgr.m_aMissionObjectives.Length;
    m_missionMgr.m_aMissionObjectives[iLength] = m_objKillBombMan;
    iLength++;
    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    Level.m_bUseDefaultMoralityRules = false;
    super.InitObjectives();
}

function PawnKilled(Pawn killedPawn)
{
    if(m_bGameOver)
    {
        return;
    }
    if(R6Pawn(killedPawn) == m_bombManController.m_pawn)
    {
        BroadcastMissionObjMsg("", "", "BombManWasKilled");
    }
    super(R6GameInfo).PawnKilled(killedPawn);
}

function UnselectBombMan()
{
    if(m_bombManController != none)
    {
        m_bombManController.PlayerReplicationInfo.m_bIsBombMan = false;
        m_previousBombMan = m_bombManController;
        if((m_previousBombMan.m_pawn != none) && int(m_previousBombMan.m_pawn.m_bSuicideType) == 1)
        {
            m_previousBombMan = none;
        }
    }
    m_bombManController = none;
    IsBombDetonated = false;
    IsBombDefused = false;
}

function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
    local R6IOBomb ioBomb;
    local R6GameReplicationInfo gameRepInfo;

    if(m_bGameOver)
    {
        return;
    }
    super(R6AbstractGameInfo).IObjectInteract(aPawn, anInteractiveObject);
    ioBomb = R6IOBomb(anInteractiveObject);
    if((ioBomb.m_szIdentityID == "Detonator") && ioBomb.m_bIsActivated)
    {
        IsBombDetonated = true;
        EndGame(none, "");
    }
    else
    {
        if((ioBomb.m_szIdentityID == "DefusingKit") && !ioBomb.m_bIsActivated)
        {
            IsBombDefused = true;
            EndGame(none, "");
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
    if(m_objKillBombMan.m_bFailed)
    {
        BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
        AddTeamWonRound(c_iBravoTeam);
        UnselectBombMan();
    }
    else
    {
        if(IsBombDetonated)
        {
            BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
            BroadcastMissionObjMsg("", "", "BombHasBeenDetonated", none, int(GetGameMsgLifeTime()));
            AddTeamWonRound(c_iBravoTeam);
            UnselectBombMan();
        }
        else
        {
            if(IsBombDefused)
            {
                BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
                BroadcastMissionObjMsg("", "", "BombHasBeenDefused", none, int(GetGameMsgLifeTime()));
                AddTeamWonRound(c_iAlphaTeam);
                UnselectBombMan();
            }
            else
            {
                if(m_objDeathmatch.m_bFailed)
                {
                    BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));
                    UnselectBombMan();
                }
                else
                {
                    if(m_objDeathmatch.m_bCompleted)
                    {
                        if(m_objDeathmatch.m_iWinningTeam == 2)
                        {
                            BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
                            BroadcastMissionObjMsg("", "", "GreenNeutralizedRed", none, int(GetGameMsgLifeTime()));
                            AddTeamWonRound(c_iAlphaTeam);
                            UnselectBombMan();
                        }
                        else
                        {
                            if(m_objDeathmatch.m_iWinningTeam == 3)
                            {
                                BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
                                BroadcastMissionObjMsg("", "", "RedNeutralizedGreen", none, int(GetGameMsgLifeTime()));
                                AddTeamWonRound(c_iBravoTeam);
                                UnselectBombMan();
                            }
                        }
                    }
                    else
                    {
                        BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
                        BroadcastMissionObjMsg("", "", "BombHasExploded", none, int(GetGameMsgLifeTime()));
                        AddTeamWonRound(c_iBravoTeam);
                        UnselectBombMan();
                    }
                }
            }
        }
    }
    super.EndGame(Winner, Reason);
}

function bool CanAutoBalancePlayer(R6PlayerController pCtrl)
{
    if(pCtrl.PlayerReplicationInfo.m_bIsBombMan)
    {
        return false;
    }
    return true;
}

function R6SetPawnClassInMultiPlayer(Controller PlayerController)
{
    if(PlayerController == m_bombManController)
    {
        R6PlayerController(PlayerController).PawnClass = Class<Pawn>(DynamicLoadObject(m_szBombManSkin, Class'Core.Class'));
    }
    else
    {
        super(R6GameInfo).R6SetPawnClassInMultiPlayer(PlayerController);
    }
}

function RestartPlayer(Controller aPlayer)
{
    local R6PlayerController PController;

    super(R6GameInfo).RestartPlayer(aPlayer);
    if(aPlayer == m_bombManController)
    {
        m_objKillBombMan.SetBombManPawn(R6Pawn(m_bombManController.Pawn));
    }
    PController = R6PlayerController(aPlayer);
    if(IsPlayerInTeam(PController, c_iAlphaTeam))
    {
        PController.m_pawn.m_bCanArmBomb = false;
        PController.m_pawn.m_bCanDisarmBomb = true;
    }
    else
    {
        if(IsPlayerInTeam(PController, c_iBravoTeam))
        {
            PController.m_pawn.m_bCanArmBomb = true;
            PController.m_pawn.m_bCanDisarmBomb = false;
        }
    }
}

function bool IsPrimaryWeaponRestrictedToPawn(Pawn aPawn)
{
    if(m_bombManController != none)
    {
        if((m_bombManController.m_pawn == aPawn) && aPawn != none)
        {
            return !EnableBombManPrimaryWeapon;
        }
    }
    return false;
}

function bool IsSecondaryWeaponRestrictedToPawn(Pawn aPawn)
{
    if(m_bombManController != none)
    {
        if((m_bombManController.m_pawn == aPawn) && aPawn != none)
        {
            return !EnableBombManSecondaryWeapon;
        }
    }
    return false;
}

function bool IsTertiaryWeaponRestrictedToPawn(Pawn aPawn)
{
    if(m_bombManController != none)
    {
        if((m_bombManController.m_pawn == aPawn) && aPawn != none)
        {
            return !EnableBombManTertiaryWeapon;
        }
    }
    return false;
}

function bool IsTertiaryWeaponRestrictedForGamePlay(Pawn aPawn, string szWeaponName)
{
    if(m_bombManController != none)
    {
        if(((m_bombManController.m_pawn == aPawn) && aPawn != none) && szWeaponName == "R6Weapons.R6HBSGadget")
        {
            return true;
        }
    }
    return false;
}

function BroadcastGameTypeDescription()
{
    local Controller P;
    local R6PlayerController PlayerController;

    super(R6GameInfo).BroadcastGameTypeDescription();
    if(m_bombManController == none)
    {
        return;
    }
    if(m_bombManController.PlayerReplicationInfo == none)
    {
        return;
    }

    for(P = Level.ControllerList; P != none; P = P.nextController)
    {
        PlayerController = R6PlayerController(P);
        if((PlayerController != none) && PlayerController.m_TeamSelection == PTS_Alpha)
        {
            PlayerController.ClientMissionObjMsg("", m_bombManController.PlayerReplicationInfo.PlayerName, "PlayerIsTheBombMan");
        }
    }
}

simulated event AcceptInventory(Pawn PlayerPawn)
{
    local PlayerController.PlayerPrefInfo m_PlayerPrefs;
    local R6Pawn aPawn;
    local R6Rainbow aRainbow;
    local string szSecWeapon, caps_szSecGadget;

    aPawn = R6Pawn(PlayerPawn);
    if((aPawn != none) && aPawn.EngineWeapon == none)
    {
        m_PlayerPrefs = PlayerController(aPawn.Controller).m_PlayerPrefs;
        if((!IsPrimaryWeaponRestrictedToPawn(aPawn) && m_PlayerPrefs.m_WeaponName1 != "") && !IsPrimaryWeaponRestricted(m_PlayerPrefs.m_WeaponName1))
        {
            if(bShowLog)
            {
                log((("NOW GIVING " $ m_PlayerPrefs.m_WeaponName1) $ " to ") $ string(aPawn.Controller));
            }
            if((m_PlayerPrefs.m_WeaponGadgetName1 != "") && IsPrimaryGadgetRestricted(m_PlayerPrefs.m_WeaponGadgetName1))
            {
                aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_WeaponName1, 1, m_PlayerPrefs.m_BulletType1);
            }
            else
            {
                aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_WeaponName1, 1, m_PlayerPrefs.m_BulletType1, m_PlayerPrefs.m_WeaponGadgetName1);
            }
            if(bShowLog)
            {
                log("AcceptInventory PrimaryWeapon =" @ m_PlayerPrefs.m_WeaponName1);
            }
        }
        if(!IsSecondaryWeaponRestrictedToPawn(aPawn) && m_PlayerPrefs.m_WeaponName2 != "")
        {
            if(IsSecondaryWeaponRestricted(m_PlayerPrefs.m_WeaponName2))
            {
                szSecWeapon = "R63rdWeapons.NormalPistol92FS";
            }
            else
            {
                szSecWeapon = m_PlayerPrefs.m_WeaponName2;
            }
            if(bShowLog)
            {
                log((("NOW GIVING " $ szSecWeapon) $ " to ") $ string(aPawn.Controller));
            }
            if((m_PlayerPrefs.m_WeaponGadgetName2 != "") && IsSecondaryGadgetRestricted(m_PlayerPrefs.m_WeaponGadgetName2))
            {
                aPawn.ServerGivesWeaponToClient(szSecWeapon, 2, m_PlayerPrefs.m_BulletType2);
            }
            else
            {
                aPawn.ServerGivesWeaponToClient(szSecWeapon, 2, m_PlayerPrefs.m_BulletType2, m_PlayerPrefs.m_WeaponGadgetName2);
            }
            if(bShowLog)
            {
                log("AcceptInventory SecondaryWeapon = " $ szSecWeapon);
            }
        }
        if(((!IsTertiaryWeaponRestrictedToPawn(aPawn) && m_PlayerPrefs.m_GadgetName1 != "") && !IsTertiaryWeaponRestricted(m_PlayerPrefs.m_GadgetName1)) && !IsTertiaryWeaponRestrictedForGamePlay(aPawn, m_PlayerPrefs.m_GadgetName1))
        {
            if(aPawn.Controller == m_bombManController)
            {
                aPawn.ServerGivesWeaponToClient("R6Weapons.R6HBSGadget", 3);
            }
            else
            {
                aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_GadgetName1, 3);
            }
        }
        if(((!IsTertiaryWeaponRestrictedToPawn(aPawn) && m_PlayerPrefs.m_GadgetName2 != "") && !IsTertiaryWeaponRestricted(m_PlayerPrefs.m_GadgetName2)) && !IsTertiaryWeaponRestrictedForGamePlay(aPawn, m_PlayerPrefs.m_GadgetName2))
        {
            if(bShowLog)
            {
                log((" AND " $ m_PlayerPrefs.m_GadgetName2) $ "  (gadget 2)");
            }
            caps_szSecGadget = Caps(m_PlayerPrefs.m_GadgetName2);
            if(((caps_szSecGadget != "PRIMARYMAGS") && caps_szSecGadget != "SECONDARYMAGS") && caps_szSecGadget == Caps(m_PlayerPrefs.m_GadgetName1))
            {
                aPawn.ServerGivesWeaponToClient("DoubleGadget", 4);
            }
            else
            {
                if(aPawn.Controller == m_bombManController)
                {
                    aPawn.ServerGivesWeaponToClient("R6Weapons.None", 4);
                }
                else
                {
                    aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_GadgetName2, 4);
                }
            }
            if(bShowLog)
            {
                log("AcceptInventory GadgetTwo = " $ m_PlayerPrefs.m_GadgetName2);
            }
        }
        aRainbow = R6Rainbow(PlayerPawn);
        if(aRainbow != none)
        {
            aRainbow.m_szPrimaryWeapon = m_PlayerPrefs.m_WeaponName1;
            aRainbow.m_szSecondaryWeapon = szSecWeapon;
            aRainbow.m_szPrimaryItem = m_PlayerPrefs.m_GadgetName1;
            aRainbow.m_szSecondaryItem = m_PlayerPrefs.m_GadgetName2;
        }
        if(Level.NetMode == NM_ListenServer)
        {
            aPawn.ReceivedWeapons();
        }
    }
}

auto state InBetweenRoundMenu
{
    function EndState()
    {
        local Controller P;
        local int iTeamACount, iNewGen, i, iTotalBombMan;

        for(P = Level.ControllerList; P != none; P = P.nextController)
        {
            if(!P.IsA('PlayerController'))
            {
                continue;
            }
            if(((R6PlayerController(P).m_TeamSelection == PTS_Alpha) && P.PlayerReplicationInfo.m_bIsBombMan) && iTotalBombMan < 1)
            {
                if(R6PlayerController(P).m_bPenaltyBox)
                {
                    P.PlayerReplicationInfo.m_bIsBombMan = false;
                }
                else
                {
                    iTotalBombMan++;
                }
            }
            else
            {
                P.PlayerReplicationInfo.m_bIsBombMan = false;
            }
        }
        ProcessAutoBalanceTeam();
        m_bombManController = none;

        for(P = Level.ControllerList; P != none; P = P.nextController)
        {
            if(!P.IsA('PlayerController'))
            {
                continue;
            }
            if(R6PlayerController(P).m_TeamSelection == PTS_Alpha)
            {
                if((m_bombManController == none) && P.PlayerReplicationInfo.m_bIsBombMan)
                {
                    m_bombManController = R6PlayerController(P);
                }
                else
                {
                    if(!R6PlayerController(P).m_bPenaltyBox)
                    {
                        iTeamACount++;
                    }
                }
            }
        }
        if(m_bombManController == none)
        {
            iNewGen = Rand(iTeamACount);
            i = 0;
            P = Level.ControllerList;

            while(P != none)
            {
                if(P.IsA('PlayerController') && ((R6PlayerController(P).m_TeamSelection == PTS_Alpha) && !R6PlayerController(P).m_bPenaltyBox))
                {
                    if(i == iNewGen)
                    {
                        if(m_previousBombMan == R6PlayerController(P))
                        {
                            if(iTeamACount == 1)
                            {
                                m_bombManController = R6PlayerController(P);
                            }
                            else
                            {

                                while(iNewGen == i)
                                {
                                    iNewGen = Rand(iTeamACount);
                                }
                                i = 0;
                                P = Level.ControllerList;
                                continue;
                            }
                        }
                        else
                        {
                            m_bombManController = R6PlayerController(P);
                        }
                        if(m_bombManController != none)
                        {
                            P.PawnClass = Class<Pawn>(DynamicLoadObject(m_szBombManSkin, Class'Core.Class'));
                            m_bombManController.PlayerReplicationInfo.m_bIsBombMan = true;
                            break;
                        }
                    }
                    else
                    {
                        i++;
                    }
                }
                if(P != none)
                {
                    P = P.nextController;
                }
            }
        }
        m_previousBombMan = none;
        if(m_bombManController != none)
        {
            m_bombManController.SecondaryWeapon();
            m_bombManController.m_pawn.m_szPrimaryGadget = "R6Description.R6DescHBSGadget";
            m_bombManController.m_pawn.ServerGivesWeaponToClient("R6Weapons.R6HBSGadget", 3);
            m_bombManController.m_pawn.m_szSecondaryGadget = "R6Description.R6DescWeaponGadgetNone";
            m_bombManController.m_pawn.ServerGivesWeaponToClient("R6Weapons.none", 4);
        }
        super.EndState();
    }
}

defaultproperties
{
    EnableBombManSecondaryWeapon=true
    EnableBombManTertiaryWeapon=true
    m_szBombManSkin="R6Characters.R6RainbowPilot"
    m_iUbiComGameMode=9
    m_szGameTypeFlag="RGM_KamikazeMode"
}
