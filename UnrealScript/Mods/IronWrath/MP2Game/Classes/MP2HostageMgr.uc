class MP2HostageMgr extends R6HostageMgr;

function PostBeginPlay()
{
    log("fatim zahra log PostBeginPlay 1");
    m_noReactionName = 'HostageMgrNone';
    InitSndEventInfo();
    InitThreatDefinition();
    if(!(Level.Game.m_szGameTypeFlag == "RGM_LimitSeatsAdvMode"))
    {
        if(!Level.m_bIsClassicMission)
        {
            InitReaction();
        }
        else
        {
            InitReactionForClassicMissionCivilian();
        }
    }
    else
    {
        log("fatim zahra log MP2HostageMgr 0");
        InitReactionForLimitSeats();
    }
    InsertAnimInfo('Blinded', ANIM_eBlinded);
    InsertAnimInfo('CrouchToProne', ANIM_eCrouchToProne, eGroupAnim_transition);
    InsertAnimInfo('CrouchToScaredStand', ANIM_eCrouchToScaredStand, eGroupAnim_transition);
    InsertAnimInfo('CrouchWait01', ANIM_eCrouchWait01, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('CrouchWait02', ANIM_eCrouchWait02, eGroupAnim_wait);
    InsertAnimInfo('FoetusToCrouch', ANIM_eFoetusToCrouch, eGroupAnim_transition);
    InsertAnimInfo('FoetusToKneel', ANIM_eFoetusToKneel, eGroupAnim_transition);
    InsertAnimInfo('FoetusToProne', ANIM_eFoetusToProne, eGroupAnim_transition);
    InsertAnimInfo('FoetusToStand', ANIM_eFoetusToStand, eGroupAnim_transition);
    InsertAnimInfo('FoetusWait01', ANIM_eFoetusWait01, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('FoetusWait02', ANIM_eFoetusWait02, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('Foetus_nt', ANIM_eFoetus_nt);
    InsertAnimInfo('Gazed', ANIM_eGazed);
    InsertAnimInfo('KneelFreeze', ANIM_eKneelFreeze,, ePlayType_Random);
    InsertAnimInfo('KneelReact01', ANIM_eKneelReact01, eGroupAnim_reaction, ePlayType_Random);
    InsertAnimInfo('KneelReact02', ANIM_eKneelReact02, eGroupAnim_reaction, ePlayType_Random);
    InsertAnimInfo('KneelReact03', ANIM_eKneelReact03, eGroupAnim_reaction, ePlayType_Random);
    InsertAnimInfo('KneelToCrouch', ANIM_eKneelToCrouch, eGroupAnim_transition);
    InsertAnimInfo('KneelToFoetus', ANIM_eKneelToFoetus, eGroupAnim_transition);
    InsertAnimInfo('KneelToProne', ANIM_eKneelToProne, eGroupAnim_transition);
    InsertAnimInfo('KneelToStand', ANIM_eKneelToStand, eGroupAnim_transition);
    InsertAnimInfo('KneelWait01', ANIM_eKneelWait01, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('KneelWait02', ANIM_eKneelWait02, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('KneelWait03', ANIM_eKneelWait03, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('Kneel_nt', ANIM_eKneel_nt);
    InsertAnimInfo('ScaredStandWait01', ANIM_eScaredStandWait01, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('ScaredStandWait02', ANIM_eScaredStandWait02, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('StandHandUpFreeze', ANIM_eStandHandUpFreeze,, ePlayType_Random);
    InsertAnimInfo('StandHandUpReact01', ANIM_eStandHandUpReact01, eGroupAnim_reaction, ePlayType_Random);
    InsertAnimInfo('StandHandUpReact02', ANIM_eStandHandUpReact02, eGroupAnim_reaction, ePlayType_Random);
    InsertAnimInfo('StandHandUpReact03', ANIM_eStandHandUpReact03, eGroupAnim_reaction, ePlayType_Random);
    InsertAnimInfo('StandHandUpToDown', ANIM_eStandHandUpToDown, eGroupAnim_transition);
    InsertAnimInfo('StandHandDownToUp', ANIM_eStandHandDownToUp, eGroupAnim_transition);
    InsertAnimInfo('StandHandUpWait01', ANIM_eStandHandUpWait01, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('StandToFoetus', ANIM_eStandToFoetus, eGroupAnim_transition);
    InsertAnimInfo('StandToKneel', ANIM_eStandToKneel, eGroupAnim_transition);
    InsertAnimInfo('StandWaitCough', ANIM_eStandWaitCough, eGroupAnim_wait);
    InsertAnimInfo('StandWaitShiftWeight', ANIM_eStandWaitShiftWeight, eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo('ProneToCrouch', ANIM_eProneToCrouch, eGroupAnim_transition);
    InsertAnimInfo('ProneWaitBreathe', ANIM_eProneWaitBreathe, eGroupAnim_wait);
    ValidAnimInfo();
}

function InitReactionForLimitSeats()
{
    local R6Hostage hostageDbg;
    local R6HostageAI hostageAIDbg;
    local int i;

    log("fatim zahra log InitReactionForLimitSeats");
    InsertReaction(c_ThreatGroup_Civ, 1, 33, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 1, 66, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 1, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 2, 25, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 2, 50, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 2, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 3, 50, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 3, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 4, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, c_ThreatLevel_Surrender, 50, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, c_ThreatLevel_Surrender, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_Civ, 6, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstGuarded, 1, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstGuarded, 2, 40, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstGuarded, 2, 60, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstGuarded, 2, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstGuarded, 3, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstEscorted, 1, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstFreed, 1, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstFreed, 2, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstFreed, 3, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstFreed, 4, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstBait, 1, 100, m_noReactionName);
    InsertReaction(c_ThreatGroup_HstBait, 2, 100, m_noReactionName);
    assert(m_iReactionIndex == 24);
}
