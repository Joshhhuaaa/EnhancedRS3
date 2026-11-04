class R6MObjCaptureTheEnemy extends R6MissionObjectiveBase
    editinlinenew;

var Actor.EPawnType m_ePawnTypeDead;
var() int m_iNeutralizePercentage;
var int m_iKillerTeamID;
var int m_iNeutralized;

function Reset()
{
    super.Reset();
    m_iKillerTeamID = default.m_iKillerTeamID;
    m_ePawnTypeDead = default.m_ePawnTypeDead;
}

function Init()
{
}

function PawnKilled(Pawn killed)
{
    PawnSecure(killed);
}

function PawnSecure(Pawn secured)
{
    local R6Pawn aPawn;
    local int iTotal;

    if(secured.m_ePawnType != m_ePawnTypeDead)
    {
        return;
    }
    m_iNeutralized = 0;
    iTotal = 0;
    foreach m_mgr.DynamicActors(Class'R6Engine.R6Pawn', aPawn)
    {
        if(aPawn.m_ePawnType != m_ePawnTypeDead)
        {
            continue;
        }
        if(aPawn.IsA('R6Rainbow') && aPawn.m_iTeam != m_iKillerTeamID)
        {
            iTotal += 1;
            if(R6Rainbow(aPawn).m_bIsUnderArrest || !aPawn.IsAlive())
            {
                m_iNeutralized += 1;
            }
        }
    }
    if((m_iNeutralized == iTotal) && iTotal > 0)
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, false);
    }
}

defaultproperties
{
    m_ePawnTypeDead=PAWN_Rainbow
    m_iKillerTeamID=-1
    m_bIfCompletedMissionIsSuccessfull=true
    m_szDescription="Capture all the enemy Rainbows"
    m_szDescriptionInMenu="CaptureTheEnemy"
}
