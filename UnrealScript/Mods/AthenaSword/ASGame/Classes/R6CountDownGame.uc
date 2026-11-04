class R6CountDownGame extends R6StoryModeGame
    config;

var R6MObjTimerSinglePlayer m_objTimer;

function InitObjectives()
{
    local int Index, i;
    local bool bIsAlreadyTimed;
    local R6IOSelfDetonatingBomb AIt, pSelfDetonatingBomb;

    super.InitObjectives();
    foreach AllActors(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
    {
        pSelfDetonatingBomb = AIt;
    }

    for(i = 0; i < m_missionMgr.m_aMissionObjectives.Length; i++)
    {
        if(m_missionMgr.m_aMissionObjectives[i].IsA('R6MObjPreventBombDetonation'))
        {
            bIsAlreadyTimed = true;
            if(pSelfDetonatingBomb != none)
            {
                m_missionMgr.m_aMissionObjectives[i].m_bIfCompletedMissionIsSuccessfull = false;
                m_missionMgr.m_aMissionObjectives[i].m_bIfFailedMissionIsAborted = true;
            }
        }
    }
    if(bIsAlreadyTimed)
    {
        if(pSelfDetonatingBomb == none)
        {
            bIsAlreadyTimed = false;
        }
    }
    if(!bIsAlreadyTimed)
    {
        m_objTimer = new (none) Class'ASGame.R6MObjTimerSinglePlayer';
        m_objTimer.m_bIfFailedMissionIsAborted = true;
        m_objTimer.m_bIfCompletedMissionIsSuccessfull = false;
        Index = m_missionMgr.m_aMissionObjectives.Length;
        m_missionMgr.m_aMissionObjectives[Index] = m_objTimer;
        m_objTimer.Init();
    }
}

function UpdatePlayerCampaign()
{
}

function StartTimer()
{
    if(m_objTimer != none)
    {
        m_objTimer.InitTimer(m_missionMgr);
    }
}

event Tick(float fDeltaTime)
{
    local R6PlayerController PlayerController;
    local Controller C;

    if((((m_objTimer != none) && m_fEndingTime > float(0)) && Level.m_fTimeLimit > float(0)) && Level.TimeSeconds > m_fEndingTime)
    {
        if((!m_objTimer.m_bFailed && m_missionMgr.m_eMissionObjectiveStatus != eMissionObjStatus_success) && m_missionMgr.m_eMissionObjectiveStatus != eMissionObjStatus_failed)
        {

            for(C = Level.ControllerList; C != none; C = C.nextController)
            {
                PlayerController = R6PlayerController(C);
                if(PlayerController != none)
                {
                    PlayerController.ClientPlayVoices(none, m_objTimer.m_sndSoundFailure, SLOT_Speak, 5, true, 1.0);
                }
            }
            m_objTimer.TimerCallback(0.0);
            TimerCountdown();
        }
    }
    super(R6GameInfo).Tick(fDeltaTime);
}

function string GetIntelVideoName(R6MissionDescription Desc)
{
    return "generic_intel";
}

defaultproperties
{
    m_bUsingPlayerCampaign=false
    m_bUsingCampaignBriefing=false
    m_szDefaultActionPlan="_COUNTDOWN_ACTION"
    m_bUseClarkVoice=false
    m_bPlayIntroVideo=false
    m_bPlayOutroVideo=false
    m_szGameTypeFlag="RGM_CountDownMode"
}
