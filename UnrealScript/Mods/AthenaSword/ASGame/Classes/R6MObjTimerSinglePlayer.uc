class R6MObjTimerSinglePlayer extends R6MissionObjectiveBase
    config
    editinlinenew;

#exec OBJ LOAD FILE=..\Sounds\Voices_Control_MissionFailed.uax PACKAGE=Voices_Control_MissionFailed

var config float m_TimeRecruit;
var config float m_TimeVeteran;
var config float m_TimeElite;
var float m_fTimeLimit;

function TimerCallback(float fTime)
{
    if(R6MissionObjectiveMgr(m_mgr).m_eMissionObjectiveStatus != eMissionObjStatus_success)
    {
        if(m_bShowLog)
        {
            logX("failed: timer countdown is zero");
        }
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
    }
}

function Init()
{
    super.Init();
}

function InitTimer(R6MissionObjectiveMgr missionMgr)
{
    local LevelInfo lLevel;
    local R6MissionDescription mDesc;

    m_mgr = missionMgr;
    lLevel = missionMgr.Level;
    mDesc = missionMgr.GetMissionDescription();
    if(class'Actor'.static.GetModMgr().IsRavenShield())
    {
        LoadConfig("..\\maps\\" $ mDesc.m_missionIniFile);
    }
    else
    {
        LoadConfig((("..\\Mods\\" $ class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord) $ "\\maps\\") $ mDesc.m_missionIniFile);
    }
    switch(R6AbstractGameInfo(lLevel.Game).m_iDiffLevel)
    {
        case 1:
            lLevel.m_fTimeLimit = m_TimeRecruit;
            break;
        case 2:
            lLevel.m_fTimeLimit = m_TimeVeteran;
            break;
        case 3:
            lLevel.m_fTimeLimit = m_TimeElite;
            break;
        default:
            lLevel.m_fTimeLimit = m_TimeVeteran;
            break;
    }
    R6AbstractGameInfo(lLevel.Game).m_fEndingTime = lLevel.m_fTimeLimit + lLevel.TimeSeconds;
}

defaultproperties
{
    m_TimeRecruit=500.0
    m_TimeVeteran=400.0
    m_TimeElite=300.0
    m_bIfFailedMissionIsAborted=true
    m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed'
    m_szDescription="Timer countdown"
    m_szDescriptionInMenu="TimeLimit"
    m_szFeedbackOnFailure="TimeIsUp"
}
