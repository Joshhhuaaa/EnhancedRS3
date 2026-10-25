//=============================================================================
//  R6NoRules.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/24 * Created by Aristomenis Kolokathis 
//                      No rules for MultiPlayer
//=============================================================================

class R6NoRules extends R6MultiPlayerGameInfo;

function PlayerReadySelected(PlayerController _Controller)
{
    return;
}

auto state InMPWaitForPlayersMenu
{
    function BeginState()
    {
        m_bGameStarted=false;
    }
    
    function Tick(float DeltaTime)
    {
        local Controller P;


        if (Level.ControllerList == none) // nobody is here yet
            return;

        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if (P.IsA('PlayerController') && (P.PlayerReplicationInfo != None) &&
                (R6PlayerController(P).m_TeamSelection != PTS_UnSelected) &&
                (R6PlayerController(P).m_TeamSelection != PTS_Spectator)
               )
            {
                GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_CountDownStage);
                GotoState('InBetweenRoundMenu');
            }
        }
    }
}

auto state InBetweenRoundMenu
{
    function Tick(float DeltaTime)
    {

        local Controller P;

        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {

            if ( (P.pawn==none) && !R6PlayerController(P).IsPlayerPassiveSpectator())
            {
                LetPlayerPopIn(P);
                m_bGameStarted=true;
                GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_InGameState);
            }
        }
    }
}

function LetPlayerPopIn( Controller aPlayer )
{
    log("LetPlayerPopIn "$aPlayer);
    R6PlayerController(aPlayer).m_TeamSelection = PTS_Alpha;
    ResetPlayerTeam(aPlayer);
}

function ResetPlayerTeam( Controller aPlayer )	// set pawn's m_iTeam
{
    if (R6Pawn(aPlayer.pawn) == none)
    {
        RestartPlayer(APlayer);
        aPlayer.pawn.PlayerReplicationInfo = aPlayer.PlayerReplicationInfo;
    }
    AcceptInventory(APlayer.Pawn);
    R6AbstractGameInfo(Level.Game).SetPawnTeamFriendlies(aPlayer.pawn);
}

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
    if (m_bGameStarted)
    {
        GotoState('InBetweenRoundMenu');
    }
    return Super.Login(Portal, Options, Error);
}

defaultproperties
{
}
