//=============================================================================
//  R6HostageRescueAdvGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Aristomenis Kolokathis
//=============================================================================

class R6HostageRescueAdvGame extends R6AdversarialTeamGame;


var R6MObjRescueHostage                         m_objRescueHostage;
var R6MObjAcceptableHostageLossesByRainbow      m_objHostageLossesByAlpha;
var R6MObjAcceptableHostageLossesByRainbow      m_objHostageLossesByBravo;
var int                                         m_iIfDeadHostageMinNbToRescue; 


//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    local R6Hostage     hostage;
    local int           iLength, iTotalHostage;

    
    foreach DynamicActors( class'R6Hostage', hostage )
    {
        // forces the hostage to stay where he is
        hostage.m_controller.m_bForceToStayHere = true;
        hostage.m_ePersonality                  = HPERSO_Coward;
        iTotalHostage++;
    }

    if ( iTotalHostage == 0 && m_missionMgr.m_bEnableCheckForErrors)
    {
        log( "WARNING: there is no hostage in the game type: " $self );
    }

    // make sure we have at least 2 hostage to rescue if some are dead
    m_iIfDeadHostageMinNbToRescue = Clamp( iTotalHostage, 0, 2 );
    
    m_objRescueHostage = new(none) class'R6Game.R6MObjRescueHostage';
    m_objRescueHostage.m_szDescriptionInMenu = m_objRescueHostage.GetDescriptionBasedOnNbOfHostages( level );
    iLength = m_missionMgr.m_aMissionObjectives.Length;
    m_missionMgr.m_aMissionObjectives[iLength] = m_objRescueHostage;
    iLength++;

    m_objHostageLossesByAlpha = new(none) class'R6Game.R6MObjAcceptableHostageLossesByRainbow';
    m_missionMgr.m_aMissionObjectives[iLength] = m_objHostageLossesByAlpha;
    iLength++;

    m_objHostageLossesByBravo = new(none) class'R6Game.R6MObjAcceptableHostageLossesByRainbow';
    m_missionMgr.m_aMissionObjectives[iLength] = m_objHostageLossesByBravo;
    iLength++;

    // rescue all hostages
    m_objRescueHostage.m_iRescuePercentage                = 0;
    m_objRescueHostage.m_bRescueAllRemainingHostage       = true;
    m_objRescueHostage.m_bIfFailedMissionIsAborted        = true;
    m_objRescueHostage.m_bIfCompletedMissionIsSuccessfull = true;
    m_objRescueHostage.m_bCheckPawnKilled                 = true;

    // if a team kill all hostage... mission objective failed
    InitObjHostageLossesByTeamID( m_objHostageLossesByAlpha, c_iTeamNumAlpha, 100 );
    InitObjHostageLossesByTeamID( m_objHostageLossesByBravo, c_iTeamNumBravo, 100 );

    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    Level.m_bUseDefaultMoralityRules = false;
    Super.InitObjectives();
}

//------------------------------------------------------------------
// InitObjHostageLossesByTeamID
//	
//------------------------------------------------------------------
function InitObjHostageLossesByTeamID( R6MObjAcceptableHostageLossesByRainbow obj, int iTeamID, int iAcceptableLost )
{
    local string szTeamName;

    obj.m_iKillerTeamID             = iTeamID;
    obj.m_bMoralityObjective        = false;
    obj.m_bIfFailedMissionIsAborted = true;
    obj.m_iAcceptableLost           = iAcceptableLost;
    obj.m_bVisibleInMenu            = false;
    
    if (      iTeamID == c_iTeamNumAlpha )
        szTeamName = "Alpha";
    else if ( iTeamID == c_iTeamNumBravo )
        szTeamName = "Bravo";
    else
        szTeamName = "Unknow";

    // for debugging
    obj.m_szDescription       = "HostageLossesByTeamID by " $szTeamName;
    obj.m_szDescriptionInMenu = "AvoidHostageCasualities";
}       

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killedPawn )
{
    if ( m_bGameOver )
        return;
    
    Super.PawnKilled( killedPawn );

    EnteredExtractionZone( killedPawn );
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone( Actor anActor)
{
    local int       i;
    local int       iTotalRescued;
    local int       iTotalAlive;
    local int       iTotalHostage;
    local bool      bSendMsg;
    local R6Pawn    aPawn;
    local R6Hostage hostage;

    if ( m_bGameOver )
        return;
       
    aPawn = R6Pawn( anActor );

    if ( aPawn == none && aPawn.m_ePawnType != PAWN_Hostage )
        return;

    // look if we have already send the gamemsg for this hosatge
    foreach DynamicActors( class'R6Hostage', hostage )
    {
        // extracted, alive and the feedback was not sent
        if ( hostage.m_bExtracted && hostage.isAlive() && 
             !hostage.m_bFeedbackExtracted  )
        {
            hostage.m_bFeedbackExtracted = true;
            bSendMsg = true;
        }

        if ( hostage.IsAlive() )
        {
            ++iTotalAlive;
            if ( hostage.m_bExtracted )
                ++iTotalRescued;
        }

        iTotalHostage++;
    }    
    
    // we are sending the game msg
    if ( bSendMsg )
    {
        // is it the last msg
        if ( iTotalHostage == iTotalRescued ||  // all rescued
             (   iTotalAlive != iTotalHostage   // some are dead, so check if it's over
              && iTotalRescued >= m_iIfDeadHostageMinNbToRescue )   
           )
        {
            if ( bShowLog ) Log( " ** Game: All hostage has been rescued" );
            BroadcastMissionObjMsg( "", "", "AllHostagesHaveBeenRescued" );
        }
        else
        {
            if ( bShowLog ) Log( " ** Game: A hostage has been rescued" );
            BroadcastMissionObjMsg( "", "", "HostageHasBeenRescued" );
        }
    }
        
    Super.EnteredExtractionZone( aPawn );
}

//------------------------------------------------------------------
// EndGame
//	
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    if (m_bGameOver)    // this function has already been called
        return;
    
    if ( m_objDeathmatch.m_bFailed )                // all player are dead: draw
    {
        if ( bShowLog ) log( "** Game : it's a draw" );
        BroadcastGameMsg( "", "", "RoundIsADraw", m_sndRoundIsADraw, GetGameMsgLifeTime() );
    }
    else if ( m_objHostageLossesByAlpha.m_bFailed ) // Alpha killed too much Hostage: bravo win
    {
        if ( bShowLog ) log( "** Game : bravo win, because alpha eleminated too much hostage" );
        BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime() );
        BroadcastMissionObjMsg( "", "", "GreenEleminatedTooManyHostages", none, GetGameMsgLifeTime() );
        AddTeamWonRound( c_iBravoTeam );
    }
    else if ( m_objHostageLossesByBravo.m_bFailed ) // Bravo killed too much Hostage: alpha win
    {
        if ( bShowLog ) log( "** Game : alpha win, because bravo eleminated too much hostage" );
        BroadcastGameMsg(       "", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, GetGameMsgLifeTime() );
        BroadcastMissionObjMsg( "", "", "RedEleminatedTooManyHostages", none, GetGameMsgLifeTime() );
        AddTeamWonRound( c_iAlphaTeam );
    }
    else if ( m_objRescueHostage.m_bFailed ) // if all hostage are dead, but not eliminated completely by the same team
    {
        if ( bShowLog ) log( "** Game : it's a draw" );
        BroadcastGameMsg( "", "", "RoundIsADraw", m_sndRoundIsADraw, GetGameMsgLifeTime() );
    }
    else if ( m_objDeathmatch.m_bCompleted )        // a team was neutralized
    {
        if ( m_objDeathmatch.m_iWinningTeam == c_iTeamNumAlpha )
        {
            if ( bShowLog ) log( "** Game : alpha eleminated bravo" );
            BroadcastGameMsg(       "", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, GetGameMsgLifeTime() );
            BroadcastMissionObjMsg( "", "", "GreenNeutralizedRed", none, GetGameMsgLifeTime() );
            AddTeamWonRound( c_iAlphaTeam );
        }
        else if ( m_objDeathmatch.m_iWinningTeam == c_iTeamNumBravo )
        {
            if ( bShowLog ) log( "** Game : bravo eleminated alpha" );
            BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime() );
            BroadcastMissionObjMsg( "", "", "RedNeutralizedGreen", none, GetGameMsgLifeTime() );
            AddTeamWonRound( c_iBravoTeam );
        }
    }
    else if ( m_objRescueHostage.m_bCompleted  )    //  enough hostage were rescued 
    {
        if ( bShowLog ) log( "** Game : alpha rescued enough hostage" );
        BroadcastGameMsg(       "", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, GetGameMsgLifeTime() );
        BroadcastMissionObjMsg( "", "", "HostagesHaveBeenRescued", none, GetGameMsgLifeTime() );
        AddTeamWonRound( c_iAlphaTeam );
    }
    else
    {
        if ( bShowLog ) log( "** Game : bravo kept the hostage from Alpha" );
        BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime() );
        BroadcastMissionObjMsg( "", "", "HostagesWhereNotRescued", none, GetGameMsgLifeTime() );
        AddTeamWonRound( c_iBravoTeam );
    }

    Super.EndGame(Winner, Reason);
}


function SetPawnTeamFriendlies(Pawn aPawn)
{
    switch( aPawn.m_iTeam )
    {
    case c_iTeamNumHostage:           // hostage are not friend nor enemy with alpha 
        aPawn.m_iFriendlyTeams  = 0;  // so they won't run away/toward them
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumTerrorist );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumBravo );         // enemy with bravo
        break;

    case c_iTeamNumTerrorist: // terros DO NOT exist in these modes
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumTerrorist );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumBravo );
        break;

    case c_iTeamNumAlpha: // alpha team
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumBravo );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumTerrorist );
        break;

    case c_iTeamNumBravo: // bravo team
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumBravo );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumTerrorist );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumHostage );       //*** big difference! Bravo are enemies of Hostage
        break;

    default:
        log( "warning: SetPawnTeamFriendlies team not supported for " $aPawn.name$ " team=" $aPawn.m_iTeam );
        break;
    }
}

defaultproperties
{
     m_iUbiComGameMode=4
     m_bFeedbackHostageExtracted=False
     m_szGameTypeFlag="RGM_HostageRescueAdvMode"
}
