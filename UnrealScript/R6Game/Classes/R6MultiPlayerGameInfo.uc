//=============================================================================
//  R6MultiPlayerGameInfo.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Aristomenis Kolokathis 
//                      Base GameInfo class for MP Games
//=============================================================================


class R6MultiPlayerGameInfo extends R6GameInfo
    native;

const   K_VoteTime          = 90;   // how long a vote stays open

const    K_RefreshCheckPlayerReadyFreq = 1;   // frequency with wich we check to see if everybody is ready
var FLOAT m_fNextCheckPlayerReadyTime;    // place holder for time of next CheckPlayerReady

var FLOAT m_fLastUpdateTime;        // Time of lat update sent to ubi.com

var R6MObjTimer m_missionObjTimer;  // mission objective timer
var BOOL m_TeamSelectionLocked;

var Sound m_sndSoundTimeFailure;
//============================================================================
// PlayerController Login
//============================================================================
function int GetSpawnPointNum(string options);
function INT GetRainbowTeamColourIndex(INT eTeamName);


//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    local int index;

    // need a timer
    if ( Level.NetMode != NM_Standalone )
    {
        // create it and add it 
        index = m_missionMgr.m_aMissionObjectives.Length;    
        m_missionObjTimer = new(none) class'R6Game.R6MObjTimer';
        m_missionObjTimer.m_bVisibleInMenu = false;
        // set to a morality so the mission mode use the same data has in story mode
        m_missionObjTimer.m_bMoralityObjective = true; 
        m_missionMgr.m_aMissionObjectives[index] = m_missionObjTimer;
    }

    Super.InitObjectives();
}



function bool AtCapacity(bool bSpectator)
{
    if ( Level.NetMode == NM_Standalone )
        return false;

    return (NumPlayers>=MaxPlayers);
}

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local R6AbstractInsertionZone StartSpot;
	local actor CamSpot;
    local vector CamLoc;
    local rotator CamRot;

	local PlayerController NewPlayer;
    local R6PlayerController P;
	local string          InClass,InName, InPassword, InChecksum;
	local byte            InTeam;
	local INT iSpawnPointNum;
    local string szJoinMessage;
	local R6ModMgr pModManager;

//#ifdef R6PUNKBUSTER
	local INT _iPBEnabled;
//#endif R6PUNKBUSTER	

    if (Level.NetMode==NM_Standalone)
    {
        return Super.Login( Portal, Options, Error );
    }

    log("Login: received string: "$Options);


    // Make sure there is capacity. (This might have changed since the PreLogin call).
    if ( AtCapacity(false) )
    {
        Error=Localize("MPMiscMessages", "ServerIsFull", "R6GameInfo");

        return None;
    } 

    m_GameService.NativeUpdateServer();

	// Get URL options.
	InName     = Left(ParseOption ( Options, "Name"), 20);

    ReplaceText(InName, " ", "_");
    ReplaceText(InName, "~", "_");
    ReplaceText(InName, "?", "_");
    ReplaceText(InName, ",", "_");
    ReplaceText(InName, "#", "_");
    ReplaceText(InName, "/", "_");
    InName = RemoveInvalidChars(InName);

    // if default name, get the system user name
    if ( InName == "UbiPlayer" ) 
        InName     = Left(ParseOption ( Options, "UserName"), 20);


    foreach DynamicActors(class'R6PlayerController', P)
        P.ClientMPMiscMessage( "PlayerJoinedServer" , InName);

	InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
	InPassword = ParseOption ( Options, "Password" );
	InChecksum = ParseOption ( Options, "Checksum" );
//#ifdef R6PUNKBUSTER
	_iPBEnabled = GetIntOption( Options, "iPB", 0 ); // default to PB off;
//#endif R6PUNKBUSTER	
	
	iSpawnPointNum = GetSpawnPointNum(options);

	log( "Login:" @ InName );

    //find a place to put the PlayerController
    CamSpot = Level.GetCamSpot( m_szGameTypeFlag );
    if (CamSpot==none)
    {
        StartSpot = GetAStartSpot();
        if( StartSpot == None )
        {
            Error=Localize("MPMiscMessages", "FailedPlaceMessage", "R6GameInfo");
            return None;
        }
        else
        {
            CamLoc = StartSpot.Location;
            CamRot = StartSpot.Rotation;
            CamRot.Roll = 0;
        }
    }
    else
    {
        CamLoc = CamSpot.Location;
        CamRot = CamSpot.Rotation;
    }

	pModManager = class'Actor'.static.GetModMgr();
    bDelayedStart=true;
	if(pModManager.m_pCurrentMod.m_PlayerCtrlToSpawn != "")
		PlayerControllerClass = class<PlayerController>(DynamicLoadObject(pModManager.m_pCurrentMod.m_PlayerCtrlToSpawn, class'Class'));
	else
		PlayerControllerClass = class<PlayerController>(DynamicLoadObject("R6Engine.R6PlayerController", class'Class'));

    if (PlayerControllerClass!=none)
    {
        NewPlayer = spawn(PlayerControllerClass,,,CamLoc,CamRot);
        NewPlayer.ClientSetLocation(CamLoc, CamRot);
        NewPlayer.StartSpot = StartSpot;
        NewPlayer.m_fLoginTime = Level.TimeSeconds;		
    }

    // Handle spawn failure.
	if( NewPlayer == None )
	{
		log("Couldn't spawn player controller of class "$PlayerControllerClass);
        Error=Localize("MPMiscMessages", "FailedSpawnMessage", "R6GameInfo");
		return None;
	}

	// Init player's name
	if( InName=="" )
		InName=DefaultPlayerName;
	if( Level.NetMode!=NM_Standalone || 
        ((NewPlayer.PlayerReplicationInfo != none) && (NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName)))
		ChangeName( NewPlayer, InName, false, true );

	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;
    
    // Player controller goes to spectating mode on server
//	NewPlayer.GotoState('BaseSpectating');
    if (IsBetweenRoundTimeOver() && (m_szGameTypeFlag!="RGM_NoRulesMode"))
    {
        if (bShowLog)
        {
            log("In login for "$NewPlayer$" m_bGameStarted==true sending it to dead state");
            R6PlayerController(NewPlayer).LogSpecialValues();
        }
        NewPlayer.GotoState('Dead');
    }

	// Set the player's ID.  If the player has a Replication Info

	// Log it.
	if ( StatLog != None )
		StatLog.LogPlayerConnect(NewPlayer);
	NewPlayer.ReceivedSecretChecksum = !(InChecksum ~= "NoChecksum");

//#ifdef R6PUNKBUSTER
    // set this player's PB setting
    if (Viewport(NewPlayer.Player) != None)
    {
        if (NewPlayer.IsPBClientEnabled())
            NewPlayer.iPBEnabled = 1;
        else
            NewPlayer.iPBEnabled = 0;
    }
	else
	    NewPlayer.iPBEnabled = _iPBEnabled;
//#endif R6PUNKBUSTER

	NumPlayers++;

	// If we are a server, broadcast a welcome message.
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
		BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);



//    InClass = R6GetPawnType();

    if ((Level.NetMode!=NM_Standalone)&&(InClass == ""))
    {
        InClass = ParseOption( Options, "Class" );
    }
   
    if ( InClass != "" )
    {
		NewPlayer.PawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
    }

#ifdefDEBUG
    log("ServerInfo: "$InName$" Logged in at time "$Level.TimeSeconds);
#endif

    return NewPlayer;
}

function BOOL IsBetweenRoundTimeOver()
{
    return (m_bGameStarted==true || IsInState('PostBetweenRoundTime'));
}

event PostLogin( PlayerController NewPlayer )
{
    local R6PlayerController _NewPlayer;
    Super.PostLogin( NewPlayer );
     if (Level.NetMode==NM_Standalone)
         return;

     _NewPlayer = R6PlayerController(NewPlayer);
     if (_NewPlayer==none)
         return;

    if ((Viewport(_NewPlayer.Player)!=none) && (_NewPlayer.Player.Console!=none) && (_NewPlayer.m_GameService == none))
    {
        _NewPlayer.m_GameService = R6GSServers(_NewPlayer.Player.Console.SetGameServiceLinks(NewPlayer));
        _NewPlayer.ServerSetUbiID(_NewPlayer.m_GameService.m_szUserID);
    }

    // if game is in the middle of a vote session then inform player of this
    if (m_fEndVoteTime!=0)
    {
        if (m_PlayerKick!=none)
        {
            _NewPlayer.m_iVoteResult = _NewPlayer.K_EmptyBallot;
            _NewPlayer.ClientKickVoteMessage(m_PlayerKick.PlayerReplicationInfo, m_VoteInstigatorName);
        }
        else
        {
            _NewPlayer.m_iVoteResult = _NewPlayer.K_EmptyBallot;
            _NewPlayer.ClientNextMapVoteMessage(m_VoteInstigatorName);
        }
    }
    
}


function ResetPlayerTeam( Controller aPlayer )	// set pawn's m_iTeam
{
    if (R6Pawn(aPlayer.pawn) == none)
    {
        RestartPlayer(APlayer);
        aPlayer.pawn.PlayerReplicationInfo = aPlayer.PlayerReplicationInfo;
    }
    
    if ( PlayerController( aPlayer ) != none )
        DeployRainbowTeam( PlayerController(aPlayer) );

    AcceptInventory(APlayer.Pawn);
}

function bool CanAutoBalancePlayer( R6PlayerController pCtrl )
{
    return true;
}

//------------------------------------------------------------------
// ProcessAutoBalanceTeam
//	
//------------------------------------------------------------------
function ProcessAutoBalanceTeam()
{
    local int  iAlphaNb, iBravoNb;
    local bool _gameTypeTeamAdversarial;
    local Controller P;
    
    _gameTypeTeamAdversarial = Level.IsGameTypeTeamAdversarial( m_szGameTypeFlag );

    if (m_bAutoBalance && _gameTypeTeamAdversarial)
    {
        
        GetNbHumanPlayerInTeam(iAlphaNb, iBravoNb);

        if (iAlphaNb > iBravoNb+1)  // move some players from alpha to bravo team
        {
            if (bShowLog) log( "AutoBalance: Green to Red Team" );
            
            for (P=Level.ControllerList; P!=None && iAlphaNb > iBravoNb+1 ; P=P.NextController )
            {
                if (P.IsA('R6PlayerController') &&  (R6PlayerController(P).m_TeamSelection == PTS_Alpha) &&
                    CanAutoBalancePlayer( R6PlayerController(P) )  ) 
                {
                    if (bShowLog) log( "AutoBalance: " $P.PlayerReplicationInfo.playerName$ " to Red Team" );
                    iAlphaNb--;
                    iBravoNb++;
                    R6PlayerController(P).ServerTeamRequested(PTS_Bravo, true);
                }
            }
        }
        else if (iBravoNb > iAlphaNb+1) // move some players from bravo to alpha team
        {
            if (bShowLog) log( "AutoBalance: Red to Green Team" );

            for (P=Level.ControllerList; P!=None && iBravoNb > iAlphaNb+1; P=P.NextController )
            {
                if (P.IsA('R6PlayerController') &&  (R6PlayerController(P).m_TeamSelection == PTS_Bravo) )
                {
                    if (bShowLog) log( "AutoBalance: " $P.PlayerReplicationInfo.playerName$ " to Green Team" );
                    iAlphaNb++;
                    iBravoNb--;
                    R6PlayerController(P).ServerTeamRequested(PTS_Alpha, true);
                }
            }
        }
    }
}

function SetLockOnTeamSelection(BOOL _bLocked)
{
    m_TeamSelectionLocked=_bLocked;
}
function BOOL IsTeamSelectionLocked()
{
    return m_TeamSelectionLocked;
}

auto state InBetweenRoundMenu
{
    function BeginState()
    {
        local Controller P;
        local actor CamSpot;
        local R6PlayerController PC;

        local R6IOSelfDetonatingBomb AIt;

	   	foreach AllActors( class 'R6IOSelfDetonatingBomb', AIt )
		{
			AIt.m_bIsActivated = false;
		}        

#ifdefDEBUG
        log("ServerInfo: Server in state InBetweenRoundMenu time = "$Level.TimeSeconds);
#endif
        m_bGameStarted=false;
        // needed for all the coop game mode played in single player
        if ( Level.NetMode == NM_Standalone )
            GotoState('');
        else
        {
//#ifdef R6PUNKBUSTER
            Level.PBNotifyServerTravel();
//#endif //R6PUNKBUSTER
			//////////////////////////////////////
			if(m_bAIBkp && Level.IsGameTypeCooperative(m_szGameTypeFlag))
				CreateBackupRainbowAI();
			//////////////////////////////////////
            GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_PlayersConnectingStage);
            SpawnAIandInitGoInGame();
        }
        HandleVotesTick();
        if (m_fTimeBetRounds>0)
        {
            m_fRoundStartTime = Level.TimeSeconds + m_fTimeBetRounds;
            R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = m_fRoundStartTime - Level.TimeSeconds;
            R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime;
        }
        else
        {
            m_fRoundStartTime = 0;
            R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimeUnlimited = true;
            R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = 0;
            R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = 0;
        }

        m_fNextCheckPlayerReadyTime = Level.TimeSeconds + K_RefreshCheckPlayerReadyFreq;
        if ( bShowLog ) log( "GameInfo: begin InBetweenRoundMenu" );

        CamSpot = Level.GetCamSpot(m_szGameTypeFlag);
        if(CamSpot != none)
        {
            for(P=Level.ControllerList; P!=None; P=P.NextController)
            {
                PC = R6PlayerController(P);
                if(PC != none)
                {
                    PC.SetLocation(CamSpot.Location);
                    PC.ClientSetLocation(CamSpot.Location, CamSpot.Rotation);
                    PC.ClientStopFadeToBlack();
                }
            }
        }
    }

    // Precondition: We are in the time between rounds stage
    // Postcondition: Returns true if we are no longer waiting because of unlimited time between round
    //                Returns true if we do not have time between round
    // Modifies: nothing
    // depends on begin state of InBetweenRoundMenu
    function BOOL UnlimitedTBRPassed()
    {
        return (m_fRoundStartTime!=0);
    }


    function Tick(float DeltaTime)
    {
        local BOOL _bAllActivePlayersReady;
        local Controller _PlayerController;
        HandleVotesTick();


        _bAllActivePlayersReady = false;

        if ( (m_fNextCheckPlayerReadyTime < Level.TimeSeconds) && 
             ((Level.TimeSeconds < m_fRoundStartTime) ||  !UnlimitedTBRPassed()) )
        {
            _bAllActivePlayersReady = ProcessPlayerReadyStatus();
            m_fNextCheckPlayerReadyTime = Level.TimeSeconds + K_RefreshCheckPlayerReadyFreq;
            if (_bAllActivePlayersReady)
            {
                SetLockOnTeamSelection(true);
                m_fRoundStartTime = Level.TimeSeconds;
            }
        }
        
        
        // see if it's time to check if everybody is ready
        if (!R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused && 
            (!R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimeUnlimited || _bAllActivePlayersReady ||
            (m_fRoundStartTime>0)))
        {
            R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = m_fRoundStartTime - Level.TimeSeconds;
            R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime;
            if (Level.TimeSeconds < m_fRoundStartTime)
            {
                GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_CountDownStage);
            }
            else if (Level.TimeSeconds < m_fRoundStartTime+1)
            {
                GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_InPreGameState);  // force the closure of pop ups
            }
            else
            {
                GotoState('PostBetweenRoundTime');
                for (_PlayerController=Level.ControllerList; _PlayerController!=None; _PlayerController=_PlayerController.NextController )
                {
                    if (_PlayerController.IsA('R6PlayerController') &&
                        !R6PlayerController(_PlayerController).IsPlayerPassiveSpectator())
                    {
                        R6PlayerController(_PlayerController).GotoState('PauseController');
                        R6PlayerController(_PlayerController).ClientGotoState( 'PauseController', '' );
                    }
                }

            }
        }
        else
        {
            GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_CountDownStage);
        }
    }

    function PauseCountDown()
    {
        if (R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused == true)
            return;

        m_fPausedAtTime = Level.TimeSeconds;
        R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused = true;
    }

    function UnPauseCountDown()
    {
        local Controller _Player;
        
        if (R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused == false)
            return;

        for (_Player=Level.ControllerList; _Player!=None; _Player=_Player.NextController )
        {
            if ( _Player.IsA('R6PlayerController') && (R6PlayerController(_Player).m_bInAnOptionsPage==true) )
                return;
        }

        if (!R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimeUnlimited)
        {
            m_fRoundStartTime = R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime + Level.TimeSeconds;
            R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime;
        }

        R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused = false;
        m_fPausedAtTime = 0;
    }
    
    function EndState()
    {
        local int iAlphaNb, iBravoNb, i, j;
        local Controller P;
        local BOOL _gameTypeTeamAdversarial;
        local Array<R6PlayerController> R6PlayerControllerList;
        local Array<R6TerroristAI> R6TerroristAIList;
        local Array<R6RainbowAI> R6RainbowAIList;
        local R6Rainbow aRainbow;
        local R6Terrorist aTerrorist;
        local ZoneInfo aZoneInfo;

        _gameTypeTeamAdversarial = Level.IsGameTypeTeamAdversarial( m_szGameTypeFlag );

        
        if (bShowLog) log( "GameInfo: EndState InBetweenRoundMenu m_GameService = "$m_GameService$" m_iUbiComGameMode = "$m_iUbiComGameMode );

        R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimeUnlimited = false;

        // this is the mapping for the game modes between us and Ubi.com

        // if server autobalance team option is turned on and we have team adversarial type game
        ProcessAutoBalanceTeam();
        
        for (P=Level.ControllerList; P!=None; P=P.NextController )
		{
			if (P.IsA('R6PlayerController'))
			{
                if ( !R6PlayerController(P).IsPlayerPassiveSpectator())
                {
                    R6PlayerController(P).bOnlySpectator = false;
                    ResetPlayerTeam(P);
                    R6PlayerController(P).m_TeamManager.SetTeamColor(
                        GetRainbowTeamColourIndex(R6Pawn(P.pawn).m_iTeam));
                    
                    if ( R6PlayerController(P).m_TeamManager != none )
                    {
#ifdefDebug    
                        log("State InBetweenRoundMenu calling SetMemberTeamID of "$P.PlayerReplicationInfo.PlayerName$
                            " new TeamID=" $R6Pawn(P.Pawn).m_iTeam$
                            " current is "$P.PlayerReplicationInfo.TeamID );
#endif
                        R6PlayerController(P).m_TeamManager.SetMemberTeamID( R6Pawn(P.Pawn).m_iTeam );
                    }
                    else
                        R6AbstractGameInfo(Level.Game).SetPawnTeamFriendlies(P.pawn);
                    
        			P.PlayerReplicationInfo.SetWaitingPlayer(false);
#ifdefDebug
                    R6PlayerController(P).LogPlayerInfo();
#endif
                }
                else
                {
                    if (bShowLog)
                    {
	                    log("In InBetweenRoundMenu::EndState() sending PlayerController "$P$" to dead state");
		                R6PlayerController(P).LogSpecialValues();
			        }
				    P.GotoState('Dead');
                }
                
                if (P.Pawn != none)
                {
                    P.m_PawnRepInfo.m_PawnType = P.Pawn.m_ePawnType;
                    P.m_PawnRepInfo.m_bSex = P.Pawn.bIsFemale;
                }
				P.PlayerReplicationInfo.m_szKillersName = "";        // name of the player that killed me
                P.PlayerReplicationInfo.m_bJoinedTeamLate=false;
            }
        }
        
        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if (P.IsA('R6PlayerController'))
                R6PlayerControllerList[R6PlayerControllerList.Length] = R6PlayerController(P);
            else if (P.IsA('R6RainbowAI'))
                R6RainbowAIList[R6RainbowAIList.Length] = R6RainbowAI(P);
            else if (P.IsA('R6TerroristAI'))
                R6TerroristAIList[R6TerroristAIList.Length] = R6TerroristAI(P);
        }

        for (i=0; i<R6PlayerControllerList.Length; i++)
        {
            if ( bShowLog ) log("Nb Terrorist =" @ R6TerroristAIList.Length @ "Nb RainbowAI =" @ R6RainbowAIList.Length @ "Nb R6PlayerController =" @ R6PlayerControllerList.Length);
            for (j=0; j<R6TerroristAIList.Length; j++)
            {
                aTerrorist = R6Terrorist(R6TerroristAIList[j].Pawn);
                if (aTerrorist != none)
                {
                    R6PlayerControllerList[i].SetWeaponSound(R6TerroristAIList[j].m_PawnRepInfo, aTerrorist.m_szPrimaryWeapon, 0);
                    R6PlayerControllerList[i].SetWeaponSound(R6TerroristAIList[j].m_PawnRepInfo, aTerrorist.m_szGrenadeWeapon, 2);
                }
            }
            for (j=0; j<R6RainbowAIList.Length; j++)
            {
                aRainbow = R6Rainbow(R6RainbowAIList[j].Pawn);
                if (aRainbow != none)
                {
                    R6PlayerControllerList[i].SetWeaponSound(R6RainbowAIList[j].m_PawnRepInfo, aRainbow.m_szPrimaryWeapon, 0);
                    R6PlayerControllerList[i].SetWeaponSound(R6RainbowAIList[j].m_PawnRepInfo, aRainbow.m_szSecondaryWeapon, 1);
                    R6PlayerControllerList[i].SetWeaponSound(R6RainbowAIList[j].m_PawnRepInfo, aRainbow.m_szPrimaryItem, 2);
                    R6PlayerControllerList[i].SetWeaponSound(R6RainbowAIList[j].m_PawnRepInfo, aRainbow.m_szSecondaryItem, 3);
                }
            }
            for (j=0; j<R6PlayerControllerList.Length; j++)
            {
                aRainbow = R6Rainbow(R6PlayerControllerList[j].Pawn);
                if (aRainbow != none)
                {
                    R6PlayerControllerList[i].SetWeaponSound(R6PlayerControllerList[j].m_PawnRepInfo, aRainbow.m_szPrimaryWeapon, 0);
                    R6PlayerControllerList[i].SetWeaponSound(R6PlayerControllerList[j].m_PawnRepInfo, aRainbow.m_szSecondaryWeapon, 1);
                    R6PlayerControllerList[i].SetWeaponSound(R6PlayerControllerList[j].m_PawnRepInfo, aRainbow.m_szPrimaryItem, 2);
                    R6PlayerControllerList[i].SetWeaponSound(R6PlayerControllerList[j].m_PawnRepInfo, aRainbow.m_szSecondaryItem, 3);
                }
            }
            if (R6PlayerControllerList[i].Pawn != none)
                aZoneInfo = R6PlayerControllerList[i].Pawn.Region.Zone;
            else
                aZoneInfo = R6PlayerControllerList[i].Region.Zone;

            R6PlayerControllerList[i].ClientFinalizeLoading(aZoneInfo);
        }

        NotifyMatchStart();
        Level.NotifyMatchStart();

        // enable/disable stats
        GetNbHumanPlayerInTeam( iAlphaNb, iBravoNb );        
        if ( Level.IsGameTypeCooperative( m_szGameTypeFlag ) )
        {
            SetCompilingStats( iAlphaNb > 0 );
            SetRoundRestartedByJoinFlag(iAlphaNb < 1);
        }
        else if ( _gameTypeTeamAdversarial )
        {
            // compile stats if there's at least a player in each team
            SetCompilingStats(  (iAlphaNb > 0 && iBravoNb > 0) );
            SetRoundRestartedByJoinFlag((iAlphaNb == 0) || (iBravoNb == 0));
        }
        else
        {
            SetCompilingStats(  (iAlphaNb > 1) );
            SetRoundRestartedByJoinFlag((iAlphaNb < 2));
        }

        SubmissionSrvRoundStart();

        IncrementRoundsPlayed();
        SetGameTypeInLocal();
        BroadcastGameTypeDescription();
#ifdefDEBUG
        log("ServerInfo: ROUND STARTING Server leaving state InBetweenRoundMenu time = "$Level.TimeSeconds);
#endif
    }
}

// this pause occurs just after the InBetweenRound time, we can spawn all our pawns in this time frame
state PostBetweenRoundTime
{
    function BeginState()
    {
        local Controller P;

        m_bStopPostBetweenRoundCountdown = false;
        SetLockOnTeamSelection(false);
        if (Level.IsGameTypeCooperative(m_szGameTypeFlag))
        {
            ResetMatchStat();
        }
        m_fInGameStartTime = Level.TimeSeconds + K_InGamePauseTime;

//        if (class'Actor'.static.GetGameOptions().CountDownDelayTime != 0)
//            m_fInGameStartTime += class'Actor'.static.GetGameOptions().CountDownDelayTime;
//        else
//        {
//            if (Level.NetMode == NM_ListenServer)
//                m_fInGameStartTime += 10;
//        }


        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if ( P.IsA('R6PlayerController'))
            {
                R6PlayerController(P).CountDownPopUpBox();
            }
        }
        R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = K_InGamePauseTime;
        R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = K_InGamePauseTime;
        GameReplicationInfo.m_bInPostBetweenRoundTime = true;
    }

    function Tick(float DeltaTime)
    {
        local Controller P;

        if (m_bStopPostBetweenRoundCountdown)
            return;

        HandleVotesTick();

        R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = m_fInGameStartTime - Level.TimeSeconds;

        R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime;
        
        if (SubmissionNotifySendStartMatch())
            return;
        
        if (Level.TimeSeconds >= m_fInGameStartTime-1)
        {
            PostBetweenRoundTimeDone();
        }
    }

    function PostBetweenRoundTimeDone()
    {
        local Controller P;

		// removed MPF_Milan_15_09_2003 - local R6IOSelfDetonatingBomb AIt; // MPF_MIlan_8_4_2003 - see below
		
        m_bGameStarted=true;
        GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_InGameState);
        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if ( P.IsA('R6PlayerController') && !PlayerController(P).bOnlySpectator && 
                !R6PlayerController(P).IsPlayerPassiveSpectator())
            {
                if ( R6PlayerController(P).m_bPenaltyBox ) // only accessible by the server
                {
                    R6PlayerController(P).GotoState( 'PenaltyBox' );
                    R6PlayerController(P).ClientGotoState( 'PenaltyBox', '' );
                }
                else
                {
                    R6PlayerController(P).GotoState('PlayerWalking');
                    R6PlayerController(P).ClientGotoState('PlayerWalking', '');
                }
            }
        }
        
        /////////////////////////////////////////////////
        // remove any unused RainbowAI backup controllers
        if(m_RainbowAIBackup.Length > 0)
            m_RainbowAIBackup.Remove( 0, m_RainbowAIBackup.Length ); 
        /////////////////////////////////////////////////
        GotoState('');
    }
    
    function EndState()
    {
        local Controller P;
        //MPF_8_4_2003 - if there is a self detonating bomb, override their time limit with the server time limit
		local R6IOSelfDetonatingBomb AIt;
		
	/* MPF_MIlan_2003_9_15 - Moved below
        // MPF_Milan_8_4_2003 - activate self detonating bombs
   		if(Level.NetMode != NM_Client)
		   	foreach AllActors( class 'R6IOSelfDetonatingBomb', AIt )
			{
				AIt.m_fSelfDetonationTime = Level.m_fTimeLimit;
				AIt.StartTimer();
			}
		// end MPF_8_4_2003
	 End MPF_MIlan_2003_9_15 */
		
        GameReplicationInfo.m_bInPostBetweenRoundTime = false;
        m_fEndingTime = Level.TimeSeconds+Level.m_fTimeLimit;
        R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = Level.m_fTimeLimit;
        R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = Level.m_fTimeLimit;

        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if ( P.IsA('R6PlayerController'))
            {
                R6PlayerController(P).CountDownPopUpBoxDone();
            }
        }
        
        // MPF_MIlan_2003_9_15 - activate self detonating bombs
  		if(Level.NetMode != NM_Client)
		{
		   	foreach AllActors( class 'R6IOSelfDetonatingBomb', AIt )
			{
				AIt.m_fSelfDetonationTime = Level.m_fTimeLimit;
				//log("netmode="$Level.NetMode$" start timer"); //MP1DEBUG
				AIt.StartTimer();
        	}
		}
    }
}

function SetCompilingStats(BOOL bStatsSetting)
{
    Super.SetCompilingStats(bStatsSetting);
    InitScoreSubmission(bStatsSetting);
}

function Logout( Controller Exiting )
{
    local INT iIdx;

    if ( Level.NetMode != NM_Standalone )
    {
        UnPauseCountDown();

    #ifdefDEBUG
        if (PlayerController(Exiting)!=none)
            log("ServerInfo: "$Exiting.PlayerReplicationInfo.PlayerName$" Logging out at time "$Level.TimeSeconds);
    #endif
		if(Level.IsGameTypeCooperative(m_szGameTypeFlag) && (m_RainbowAIBackup.Length > 0))
		{
			if( !(Level.NetMode == NM_Standalone || Level.NetMode == NM_Client) )
			{
				if ((R6PlayerController(Exiting) != none) && (R6PlayerController(Exiting).m_TeamManager != none))
					m_RainbowAIBackup.Remove( 0, Min(m_RainbowAIBackup.Length, R6PlayerController(Exiting).m_TeamManager.m_iMemberCount) );
			}
		}
 
        NativeLogout(PlayerController(Exiting));
    }

    Super.Logout( Exiting );

}

function Tick(float Delta)
{
    local R6PlayerController playerController;
    local Controller C;

    Super.Tick(Delta);

    if (IsInState('InBetweenRoundMenu'))
        return;

    if(Level.NetMode != NM_Standalone)
    {
        HandleVotesTick();

        R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = R6GameInfo(Level.Game).m_fEndingTime - Level.TimeSeconds;

        R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTimeLastUpdate += Delta;
        if(R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTimeLastUpdate >= 10)
        {
            R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTimeLastUpdate = 0;
            R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime;
        }
    }

    // check for the timer countdown
    if (   m_missionObjTimer != none &&
         ( m_fEndingTime > 0)   && 
         ( Level.m_fTimeLimit>0 )                       && 
         ( Level.TimeSeconds > m_fEndingTime ) )
    {
        if ( !m_missionObjTimer.m_bFailed )
        {
            for (C=Level.ControllerList; C!=None; C=C.NextController )
            {
                playerController = R6PlayerController(C);
                if (playerController != none)
                {
                    playerController.ClientPlayVoices(none, m_sndSoundTimeFailure, SLOT_Speak, 5, true, 1);
                }
            }
            m_missionObjTimer.timerCallback( 0 );
            TimerCountdown();
        }
    }
}

function EndGame( PlayerReplicationInfo Winner, string Reason ) 
{
//log("EndGame cleaning out PlayerIDList");
//    m_GameService.CleanPlayerIDList(Level.ControllerList);
    ResetPlayerReady();
    Super.EndGame( Winner, Reason );
}

function ResetPlayerReady()
{
    local Controller P;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        if (R6PlayerController(P)!=none)
             R6PlayerController(P).PlayerReplicationInfo.m_bPlayerReady = false;
    }
}

//------------------------------------------------------------------
// GetNbHumanPlayerInTeam
//	
//------------------------------------------------------------------
function GetNbHumanPlayerInTeam( OUT int iAlphaNb, OUT int iBravoNb )
{
    local Controller P;
    iAlphaNb = 0;
    iBravoNb = 0;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        if (   R6PlayerController( P ) != None )
        {
            if ( R6PlayerController(P).m_TeamSelection == PTS_Alpha )
                ++iAlphaNb;

            if ( R6PlayerController(P).m_TeamSelection == PTS_Bravo )
                ++iBravoNb;
        }
    }
}

function IncrementRoundsPlayed()
{
    local Controller P;
    local R6PlayerController _aPlayerController;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        _aPlayerController = R6PlayerController(P);
        if ( (_aPlayerController != none) &&
             ((_aPlayerController.m_TeamSelection == PTS_Alpha ) ||
              (_aPlayerController.m_TeamSelection == PTS_Bravo )))
        {
            if (m_bCompilingStats)
            {
                _aPlayerController.PlayerReplicationInfo.m_iRoundsPlayed++;
            }
            _aPlayerController.ServerSetPlayerReadyStatus(true);   // force all active players to ready
            _aPlayerController.PlayerReplicationInfo.bIsSpectator = false;
        }
    }
}

function BOOL ProcessChangeMapVote(string InstigatorName)
{
    local Controller _itController;
    local R6PlayerController _playerController;
    // 1st make sure that a vote is not in progress

    if (m_fEndVoteTime!=0)
    {
        return false; // a vote is already in progress
    }
    // empty all ballots
    for (_itController=Level.ControllerList; _itController!=None; _itController=_itController.NextController )
    {
        _playerController = R6PlayerController(_itController);
        if (_playerController!=none)
        {
            _playerController.m_iVoteResult = R6PlayerController(_itController).K_EmptyBallot;
            _playerController.ClientNextMapVoteMessage(InstigatorName);
        }
    }
    m_fEndVoteTime = Level.TimeSeconds + K_VoteTime;    // voting open until
    return true;
}

function BOOL ProcessKickVote(PlayerController _KickPlayer, string InstigatorName)
{
    local Controller _itController;
    local R6PlayerController _playerController;
    // 1st make sure that a vote is not in progress

    if (m_fEndVoteTime!=0)
    {
        return false; // a vote is already in progress
    }
    // empty all ballots
    m_PlayerKick = _KickPlayer;
    m_VoteInstigatorName = InstigatorName;
    for (_itController=Level.ControllerList; _itController!=None; _itController=_itController.NextController )
    {
        _playerController = R6PlayerController(_itController);
        if (_playerController!=none)
        {
            _playerController.m_iVoteResult = R6PlayerController(_itController).K_EmptyBallot;
            _playerController.ClientKickVoteMessage(m_PlayerKick.PlayerReplicationInfo, InstigatorName);
        }
    }
    m_fEndVoteTime = Level.TimeSeconds + K_VoteTime;    // voting open until
    return true;
}

function HandleVotesTick()
{
    local int _iForVotes;
    local int _iAgainstVotes;
    local Controller _itController;
    local R6PlayerController _playerController;
    local string szResultString;
    local string szPlayerName;
    local bool _bResult;
    local bool bChangeMapVote;
    local R6GameReplicationInfo pGRI;

    // if no vote in progress or vote still in progress, then exit
    if ((m_fEndVoteTime == 0) || (m_fEndVoteTime > Level.TimeSeconds) || (NumPlayers == 0))
      return;

    // this is the end of vote period
    m_fEndVoteTime = 0; // reset timer.
    _iForVotes = 0;
    _iAgainstVotes = 0;

    for (_itController=Level.ControllerList; _itController!=None; _itController=_itController.NextController )
    {
        _playerController = R6PlayerController(_itController);
        if (_playerController != none)
        {
            switch(_playerController.m_iVoteResult)
            {
            case _playerController.K_VotedYes:
                _iForVotes++;
                break;
            case _playerController.K_EmptyBallot:
            case _playerController.K_VotedNo:
                _iAgainstVotes++;
                break;
            default:
                return;
            }
        }
    }

    // no player being kicked means this was a next map vote
    bChangeMapVote = (m_PlayerKick == none);

    if (_iForVotes > (_iForVotes+_iAgainstVotes)/2 )
    {
        _bResult = true;
        if (bChangeMapVote == true)
        {
            if (bShowLog) log("<<ChangeMap>> HandleVotesTick "$_iForVotes$" voted yes "$_iAgainstVotes$
                " considered as voted no -- VOTE PASSES");
            bChangeLevels = true;
            EndGame(none, "");
            AbortScoreSubmission();
            RestartGame();
        }
        else
        {
            if (bShowLog) log("<<KICK>> HandleVotesTick "$_iForVotes$" voted yes "$_iAgainstVotes$
                " considered as voted no -- VOTE PASSES");
            R6PlayerController(m_PlayerKick).ClientKickedOut();
            m_PlayerKick.SpecialDestroy();
        }
    }
    else
    {
        _bResult = false;
        if (bChangeMapVote == true)
            log("<<ChangeMap>> HandleVotesTick "$_iForVotes$" voted yes "$_iAgainstVotes$
                " considered as voted no -- VOTE FAILS");
        else if (bShowLog)
            log("<<KICK>> HandleVotesTick "$_iForVotes$" voted yes "$_iAgainstVotes$
                " considered as voted no -- VOTE FAILS");
    }

    if (bChangeMapVote == true)
    {
        for (_itController=Level.ControllerList; _itController!=None; _itController=_itController.NextController )
        {
            if (_itController.IsA('R6PlayerController'))
                R6PlayerController(_itController).ClientVoteResult(_bResult);
        }
    }
    else
    {
        szPlayerName = m_PlayerKick.PlayerReplicationInfo.PlayerName;
        for (_itController=Level.ControllerList; _itController!=None; _itController=_itController.NextController )
        {
            if (_itController.IsA('R6PlayerController'))
                R6PlayerController(_itController).ClientVoteResult(_bResult, szPlayerName);
        }
    }
    m_PlayerKick=none;
    m_VoteInstigatorName="";
}

function LogVoteInfo()
{
#ifdefDebug
    local int _iForKickVotes;
    local int _iAgainstKickVotes;
    local int _VoteNotReceived;
    local Controller _itController;
    local R6PlayerController _playerController;

    log("---   Vote Info Start   ---");
    log("Current time is "$Level.TimeSeconds);
    if (m_fEndKickVoteTime == 0)
    {
        log("No vote in progress");
        for (_itController=Level.ControllerList; _itController!=None; _itController=_itController.NextController )
        {
            _playerController = R6PlayerController(_itController);
            if (_playerController != none)
            {
                if ((_playerController.m_fLastVoteKickTime>0) && (Level.TimeSeconds < _playerController.m_fLastVoteKickTime + _playerController.K_KickFreqTime))
                    log(_playerController.PlayerReplicationInfo.PlayerName$" can't issue a vote request until time "$(_playerController.m_fLastVoteKickTime + _playerController.K_KickFreqTime));
                else
                    log(_playerController.PlayerReplicationInfo.PlayerName$" can issue a vote request");
            }
        }
    }
    else
    {
        log("Vote in progress, no other votes allowed");
        log("Voting to kick "$m_PlayerKick.PlayerReplicationInfo.PlayerName$" voting may go on until time "$m_fEndKickVoteTime);
        log("Current results are: ");


        for (_itController=Level.ControllerList; _itController!=None; _itController=_itController.NextController )
        {
            _playerController = R6PlayerController(_itController);
            if (_playerController != none)
            {
                switch(_playerController.m_iVoteResult)
                {
                case _playerController.K_VotedYes:
                    _iForKickVotes++;
                    log(_playerController.PlayerReplicationInfo.PlayerName$" voted YES");
                    break;
                case _playerController.K_EmptyBallot:
                    log(_playerController.PlayerReplicationInfo.PlayerName$" has not voted, counts as a NO");
                    _VoteNotReceived++;
                    break;

                case _playerController.K_VotedNo:
                    log(_playerController.PlayerReplicationInfo.PlayerName$" voted NO");
                    _iAgainstKickVotes++;
                    break;
                default:
                    return;
                }
            }
        }
        log(_iForKickVotes$" votes for YES");
        log(_iAgainstKickVotes$" votes for NO");
        log(_VoteNotReceived$" players not voted yet, counts as NO");
    }
    
    log("---   Vote Info End   ---");
#endif
}

defaultproperties
{
     m_bCompilingStats=False
}
