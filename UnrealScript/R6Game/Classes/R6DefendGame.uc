//=============================================================================
//  R6DefendGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/04 * Created by Aristomenis Kolokathis
//=============================================================================

class R6DefendGame extends R6CoOpMode;


//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    local int index;
    local R6MObjNeutralizeTerrorist missionObjTerro;
    local R6MObjRescueHostage       misionObjVIP;
    local R6Hostage                 h, huntedPawn;
    local R6TerroristAI             terroAI;

    // neutralize all terro
    m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjNeutralizeTerrorist';
    m_missionMgr.m_aMissionObjectives[index].m_bIfCompletedMissionIsSuccessfull = true;
    missionObjTerro = R6MObjNeutralizeTerrorist(m_missionMgr.m_aMissionObjectives[index]);
    missionObjTerro.m_iNeutralizePercentage = 100;
    missionObjTerro.m_bVisibleInMenu = true;
    missionObjTerro.m_szDescription       = "Neutralize all terro and protect the VIP at all cost";
    missionObjTerro.m_szDescriptionInMenu = "NeutralizeTerroAndDefendVIP";
    index++;

    // find the vip 
    foreach DynamicActors( class'R6Hostage', h )
	{
        m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjRescueHostage';
        misionObjVIP = R6MObjRescueHostage(m_missionMgr.m_aMissionObjectives[index]);
        misionObjVIP.m_bIfFailedMissionIsAborted = true;
        misionObjVIP.m_bVisibleInMenu = false;

        misionObjVIP.m_iRescuePercentage =  100;
        misionObjVIP.m_depZone = h.m_DZone;

        // not the first time here: problem
        if ( huntedPawn != none )
        {
            log( "Warning: there's more than one hostage in the game mode " $self.name );
            break; // this game mode only deal with one hostage
        }
        
        huntedPawn = h;
        index++;
    }

    // not the first time here: problem
    if ( huntedPawn == none && m_missionMgr.m_bEnableCheckForErrors )
    {
        log( "Warning: there is no hostage in the game mode " $self.name );
    }

    // add morality rules
    m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjAcceptableRainbowLosses';

    // Set the terro ai to hunt
    foreach DynamicActors( class'R6TerroristAI', terroAI )
	{
        terroAI.m_huntedPawn = huntedPawn;
        R6Terrorist(terroAI.pawn).m_eStrategy = STRATEGY_Hunt;
    }

    Level.m_bUseDefaultMoralityRules = false;
    Super.InitObjectives();
}


//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
    Super.SetPawnTeamFriendlies(aPawn);

    switch ( aPawn.m_iTeam )
    {
    case c_iTeamNumTerrorist:   // terrorist consider Hostage has enemy in this mode
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumHostage );
        break;
    }
}

defaultproperties
{
     m_szGameTypeFlag="RGM_DefendMode"
}
