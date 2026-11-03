class MP2MObjRescuePrisoner extends R6MissionObjectiveBase
    editinlinenew;

#exec OBJ LOAD FILE=..\Sounds\Voices_Control_MissionFailed.uax PACKAGE=Voices_Control_MissionFailed

var int m_iWinningTeam;
var const int c_iTeamNumPrisonerAlpha;
var const int c_iTeamNumPrisonerBravo;
var() bool m_bCheckPawnKilled;

function Init()
{
    local int iTotal;
    local R6Hostage aHostage;

    if(R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors)
    {
        MP2LimitSeatsAdvGame(m_mgr.Level.Game).CheckForPrisoner(self, 1);
    }
}

function PawnKilled(Pawn killedPawn)
{
    local R6Hostage aHostage;
    local float fTotalDeathA, fTotalDeathB;
    local int i;

    fTotalDeathA = 0.0;
    fTotalDeathB = 0.0;
    if(!m_bCheckPawnKilled)
    {
        return;
    }
    if(killedPawn.m_ePawnType != PAWN_Hostage)
    {
        return;
    }
    foreach m_mgr.DynamicActors(Class'R6Engine.R6Hostage', aHostage)
    {
        if(!aHostage.IsAlive())
        {
            if(aHostage.m_iPrisonierTeam == c_iTeamNumPrisonerAlpha)
            {
                fTotalDeathA += float(1);
            }
            else
            {
                if(aHostage.m_iPrisonierTeam == c_iTeamNumPrisonerBravo)
                {
                    fTotalDeathB += float(1);
                }
            }
        }
    }
    if(fTotalDeathA != float(0))
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
    }
    else
    {
        if(fTotalDeathB != float(0))
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
        }
    }
    if(m_bShowLog)
    {
        logX("Prisoner Killed. failed");
    }
}

function EnteredExtractionZone(Pawn aPawn)
{
    local R6Hostage H, aHostage;
    local float fRescuedNumA, fRescuedNumB;
    local int iTotalA, iTotalB, i, iTotalAliveA, iTotalAliveB;

    if(aPawn.m_ePawnType != PAWN_Hostage)
    {
        return;
    }
    H = R6Hostage(aPawn);
    foreach m_mgr.DynamicActors(Class'R6Engine.R6Hostage', aHostage)
    {
        if(aHostage.m_iPrisonierTeam == c_iTeamNumPrisonerAlpha)
        {
            if(aHostage.IsAlive())
            {
                iTotalAliveA++;
                if(aHostage.m_bExtracted)
                {
                    fRescuedNumA += float(1);
                }
            }
            ++iTotalA;
        }
        else
        {
            if(aHostage.m_iPrisonierTeam == c_iTeamNumPrisonerBravo)
            {
                if(aHostage.IsAlive())
                {
                    iTotalAliveB++;
                    if(aHostage.m_bExtracted)
                    {
                        fRescuedNumB += float(1);
                    }
                }
                ++iTotalB;
            }
        }
    }
    if(fRescuedNumA == float(iTotalAliveA))
    {
        m_iWinningTeam = 2;
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
    }
    else
    {
        if(fRescuedNumB == float(iTotalAliveB))
        {
            m_iWinningTeam = 3;
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
        }
    }
    if(m_bShowLog)
    {
        logX("EnteredPrisonerExtZone. completed");
    }
}

function string GetDescriptionBasedOnNbOfHostages(LevelInfo Level)
{
    local R6Hostage aHostage;
    local int iTotal;

    foreach Level.DynamicActors(Class'R6Engine.R6Hostage', aHostage)
    {
        if(aHostage.IsAlive())
        {
            ++iTotal;
        }
    }
    switch(iTotal)
    {
        case 1:
            return "RescueAllPrisonersToExtractionZone";
        case 2:
            return "RescueAllPrisonersToExtractionZone";
        case 3:
            return "RescueAllPrisonersToExtractionZone";
        default:
            return "RescueAllPrisonersToExtractionZone";
    }
}

defaultproperties
{
    m_iWinningTeam=-1
    c_iTeamNumPrisonerAlpha=5
    c_iTeamNumPrisonerBravo=6
    m_bCheckPawnKilled=true
    m_bIfFailedMissionIsAborted=true
    m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_HostageKilled'
    m_szDescription="Rescue hostage"
    m_szDescriptionInMenu="RescueAllPrisonersToExtractionZone"
}
