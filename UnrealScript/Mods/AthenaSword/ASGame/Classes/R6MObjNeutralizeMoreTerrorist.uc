class R6MObjNeutralizeMoreTerrorist extends R6MissionObjectiveBase
    editinlinenew;

var Actor.EPawnType m_ePawnTypeKiller;
var Actor.EPawnType m_ePawnTypeDead;
var() int m_iNeutralizePercentage;
var int m_iKillerTeamID;

function Reset()
{
    super.Reset();
    m_iKillerTeamID = default.m_iKillerTeamID;
    m_ePawnTypeKiller = default.m_ePawnTypeKiller;
    m_ePawnTypeDead = default.m_ePawnTypeDead;
}

function Init()
{
}

function PawnKilled(Pawn killed)
{
    local int iNeutralized;
    local R6Pawn aPawn;
    local float fTotal;

    if(killed.m_ePawnType != m_ePawnTypeDead)
    {
        return;
    }
    if(m_iKillerTeamID != -1)
    {
        aPawn = R6Pawn(killed);
        if(aPawn.m_KilledBy.m_iTeam != m_iKillerTeamID)
        {
            return;
        }
    }
    foreach m_mgr.DynamicActors(Class'R6Engine.R6Pawn', aPawn)
    {
        if(aPawn.m_ePawnType != m_ePawnTypeDead)
        {
            continue;
        }
        fTotal += float(1);
        if(aPawn.IsAlive())
        {
            continue;
        }
        if(aPawn.m_KilledBy.m_ePawnType == m_ePawnTypeKiller)
        {
            if(aPawn.m_KilledBy.m_iTeam == m_iKillerTeamID)
            {
                iNeutralized += 1;
            }
        }
    }
    iNeutralized = int((float(iNeutralized) / fTotal) * 100.0);
    if(iNeutralized >= m_iNeutralizePercentage)
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, false);
    }
}

defaultproperties
{
    m_ePawnTypeKiller=PAWN_Rainbow
    m_ePawnTypeDead=PAWN_Terrorist
    m_iNeutralizePercentage=51
    m_iKillerTeamID=-1
    m_bIfCompletedMissionIsSuccessfull=true
    m_szDescription="Neutralize more terrorist"
    m_szDescriptionInMenu="NeutralizeAllTerrorist"
}
