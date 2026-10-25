class R6BroadcastHandler extends BroadcastHandler;

var bool m_bShowLog;

function bool IsSpectator( R6PlayerController A )
{
    return A.PlayerReplicationInfo.bIsSpectator ||
        A.PlayerReplicationInfo.TeamID == INT(ePlayerTeamSelection.PTS_UnSelected) ||
        A.PlayerReplicationInfo.TeamID == INT(ePlayerTeamSelection.PTS_Spectator);
}

function bool IsATeamMember( R6PlayerController A )
{
    return A.m_TeamSelection == PTS_Alpha || A.m_TeamSelection == PTS_Bravo;
}

// A is supposed to be a team member
function bool IsSameTeam( R6PlayerController A, R6PlayerController B )
{
    if ( !IsATeamMember( B ) )
        return false;

    return ( A.PlayerReplicationInfo.TeamID == B.PlayerReplicationInfo.TeamID );
}


function bool IsPlayerDead( R6PlayerController A )
{
    return A.PlayerReplicationInfo.m_iHealth > 1;
}


function BroadcastTeam( Actor Sender, coerce string Msg, optional name Type )
{
    local R6PlayerController        aSender;
    local R6Pawn                    aSenderPawn;
    local PlayerReplicationInfo     senderPRI;
    local R6PlayerController        B;
    local bool bSend;
    local bool bGameTypeMsg;

   	if ( Pawn(Sender) != None )
		senderPRI = Pawn(Sender).PlayerReplicationInfo;
	else if ( Controller(Sender) != None )
		senderPRI = Controller(Sender).PlayerReplicationInfo;

    aSender = R6PlayerController(Sender);
    if ( aSender == none  )
    {
        log( "none = R6PlayerController(Sender)" );
        return;
    }

    // if not in a team, return
    if ( !IsATeamMember( aSender )  )
    {
        log( "!IsATeamMember( aSender )" );
        return;
    }

	// R6WritableMap - Modif
	// see if allowed (limit to prevent spamming)
	if ( Type!='Line' && !AllowsBroadcast(Sender, Len(Msg)) )
		return;

    aSenderPawn = R6Pawn(aSender.Pawn);
    if(aSenderPawn != none && aSenderPawn.m_TeamMemberRepInfo != none)
        aSenderPawn.m_TeamMemberRepInfo.m_BlinkCounter++;

    ForEach DynamicActors(class'R6PlayerController', B)
    {
        bSend = false;
        
        // same team
        if ( IsSameTeam( aSender, B ) )
        {
            // alive 
            if ( !IsPlayerDead( aSender ) )
            {
                bSend = true;
            }
            // if dead send to dead player
            else if ( IsPlayerDead( B ) )
            {
                bSend = true;
            }
        }

        if ( bSend )
            BroadcastText( senderPRI, B, Msg, Type);
    }
}

function DebugBroadcaster( R6PlayerController A, bool bSender )
{
    local string szName;

    if ( A.PlayerReplicationInfo != none )
    {
        szName = A.PlayerReplicationInfo.PlayerName;
    }

    log( "Broadcast: " $szName$ " bSender=" $bSender$ " spec=" $IsSpectator(A)$ " dead=" $IsPlayerDead(A)$ " team="$IsATeamMember(A)$ " teamID="$A.PlayerReplicationInfo.TeamID$ " health=" $A.PlayerReplicationInfo.m_iHealth );
}

function Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
	local R6PlayerController aSender;
    local R6Pawn aSenderPawn;
    local R6PlayerController B;
    local GameReplicationInfo _GRI;
	local PlayerReplicationInfo PRI;
    local bool bSend;
    local bool bGameTypeMsg;

    //log( "broadcast: sender=" $sender$ " type=" $type$ " msg=" $msg   );

    if ( Type == 'GameMsg' )
    {
        bGameTypeMsg = true;
    }
    else if ( Type == 'TeamSay' ) // the filter
    {
        //log( "broadcast teamsay... it's wrong to that here" );
        return;
    }

    aSender = R6PlayerController( Sender );

    if ( !bGameTypeMsg )
    {
        // if send is none and it's not a server msg, problem, return
        if (( aSender == none ) && (Type!='ServerMessage'))
        {
            // log( "R6PlayerController( Sender ) == none, is this wrong? Sender is "$Sender);
            return;
        }
	    
        // see if allowed (limit to prevent spamming)
	    if ( (Type!='Line') && (Type!='ServerMessage') &&
            !AllowsBroadcast(Sender, Len(Msg)) )
		    return;
    }

	if ( Pawn(Sender) != None )
		PRI = Pawn(Sender).PlayerReplicationInfo;
	else if ( Controller(Sender) != None )
		PRI = Controller(Sender).PlayerReplicationInfo;

    if ( Type != 'ServerMessage' && !bGameTypeMsg )
    {
        if ( m_bShowLog ) DebugBroadcaster( aSender, true );
    }

    // if there's a sender (otherwise it's the server)
    if ( aSender != none )
    {
        aSenderPawn = R6Pawn(aSender.Pawn);
        if(aSenderPawn != none && aSenderPawn.m_TeamMemberRepInfo != none)
            aSenderPawn.m_TeamMemberRepInfo.m_BlinkCounter++;
    }

	foreach DynamicActors(class'R6PlayerController', B)
    {
        if (_GRI == none )
        {
            _GRI = B.GameReplicationInfo;
        }
        bSend = false;

        if (Type == 'ServerMessage' || bGameTypeMsg )
        {
            bSend = true;
        }
        else 
        {
            if ( m_bShowLog ) DebugBroadcaster( B, false );
            
            // IMPORTANT: the same logic order (SPECTATOR, DEAD, ALIVE) is used in 
            //            R6PlayerController::GetPrefixToMsg

            if ( (_GRI.m_eCurrectServerState != _GRI.RSS_InPreGameState) &&
                (_GRI.m_eCurrectServerState != _GRI.RSS_InGameState) )
            {
                bSend = true;
            }
            else if ( IsSpectator( aSender ) )         // spectator can send to spectator AND dead player
            {
                if ( IsSpectator( B ) || IsPlayerDead( B ) )
                {
                    bSend = true;
                }
            }
            else if ( IsPlayerDead( aSender ) )  // dead player send to dead and spectator
            {
                if ( IsPlayerDead( B ) || IsSpectator( B ) )
                {
                    bSend = true;
                }
            }
            else if ( !IsPlayerDead( aSender ) )  // alive, send to all
            {
                bSend = true;
            }
        }
        
        if ( bSend )
            BroadcastText(PRI, B, Msg, Type);
    }
}

defaultproperties
{
}
