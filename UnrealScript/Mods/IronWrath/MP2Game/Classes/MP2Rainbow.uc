class MP2Rainbow extends R6Rainbow
    native;

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons

var int m_iCustomDeviceAnim;
var Material m_aRepSkins[6];
var Material m_aOldSkins[6];
var array<Material> sm_aSkins;

replication
{
    reliable if(Role == ROLE_Authority)
        m_aRepSkins;

    reliable if(Role == ROLE_Authority)
        m_iCustomDeviceAnim;
}

simulated function PlayWaiting()
{
    if(m_bSlideEnd)
    {
        if(!(m_iTeam == 7))
        {
            return;
        }
    }
    if(m_bInitRainbow)
    {
        return;
    }
    if(Physics == PHYS_Falling)
    {
        PlayFalling();
        return;
    }
    if(m_bIsClimbingLadder)
    {
        AnimateStoppedOnLadder();
        return;
    }
    if(bIsCrouched)
    {
        PlayCrouchWaiting();
        return;
    }
    if(m_bIsProne)
    {
        PlayProneWaiting();
        return;
    }
    if(!m_bNightVisionAnimation)
    {
        m_ePlayerIsUsingHands = HANDS_None;
    }
    if(((m_fPeeking != 1000.0) || IsPeeking()) || int(m_u8CurrentYaw) != 0)
    {
        if(bIsCrouched != bWasCrouched)
        {
            m_bTweenFirstTimeOnly = true;
        }
        if(m_bTweenFirstTimeOnly)
        {
            PlayPeekingAnim(true);
            m_bTweenFirstTimeOnly = false;
            R6PlayAnim('StandWaitBreathe');
        }
        else
        {
            PlayAnim('StandWaitBreathe');
        }
        return;
    }
    if((m_bIsPlayer || m_TrackActor != none) || m_bIsSniping)
    {
        if(EngineWeapon != none)
        {
            R6PlayAnim('StandWaitBreathe');
        }
        else
        {
            R6PlayAnim('StandSubGunHigh_nt');
        }
        return;
    }
    SetRandomWaiting(12);
    switch(m_bRepPlayWaitAnim)
    {
        case 0:
            R6PlayAnim('StandWaitBreathe');
            break;
        case 1:
            R6PlayAnim('StandWaitCrackNeck');
            break;
        case 2:
            R6PlayAnim('StandWaitLookAround01');
            break;
        case 3:
            R6PlayAnim('StandWaitLookAround02');
            break;
        case 4:
            R6PlayAnim('StandWaitLookBack01');
            break;
        case 5:
            R6PlayAnim('StandWaitLookBack02');
            break;
        case 6:
            R6PlayAnim('StandWaitLookWatch');
            break;
        case 7:
            R6PlayAnim('StandWaitScratchNose');
            break;
        case 8:
            R6PlayAnim('StandWaitShiftWeight');
            break;
        case 9:
            R6PlayAnim('StandWaitUpDown01');
            break;
        case 10:
            R6PlayAnim('StandWaitUpDown02');
            break;
        default:
            R6PlayAnim('StandWaitWipeFace');
            break;
    }
}

simulated function ResetOriginalData()
{
    local int i;

    super.ResetOriginalData();
    Skins.Remove(0, sm_aSkins.Length);

    for(i = 0; i < sm_aSkins.Length; i++)
    {
        Skins[i] = sm_aSkins[i];
        m_aOldSkins[i] = Skins[i];
        m_aRepSkins[i] = Skins[i];
    }
}

simulated function SaveOriginalData()
{
    local int iSkin;

    super(Actor).SaveOriginalData();

    for(iSkin = 0; iSkin < Skins.Length; iSkin++)
    {
        if(iSkin > 5)
        {
            break;
        }
        sm_aSkins[iSkin] = Skins[iSkin];
        m_aOldSkins[iSkin] = Skins[iSkin];
        m_aRepSkins[iSkin] = Skins[iSkin];
    }

}

simulated function InitializeRainbowAnimations()
{
    if(m_iTeam == 7)
    {
        m_eEquipWeapon = EQUIP_NoWeapon;
        m_ePlayerIsUsingHands = HANDS_None;
        PlayAnim('CrouchNoGun_nt');
    }
    else
    {
        super.InitializeRainbowAnimations();
    }
}

simulated function PlaySpecialPendingAction(R6Pawn.EPendingAction eAction, int iActionInt)
{
    if(eAction == PENDING_Custom)
    {
        PlayPickUpFloppy();
    }
    else
    {
        super.PlaySpecialPendingAction(eAction, iActionInt);
    }
}

simulated function PlayPickUpFloppy()
{
    R6ResetAnimBlendParams(13);
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    m_bPostureTransition = true;
    AnimBlendParams(1, 1.0, 0.0, 0.0);
    PlayAnim('StandGiveFloppy', 1.0, 0.2, 1);
}

simulated function PlayInteractWithDeviceAnimation()
{
    local float fAnimRate, fSkillDevice;

    if((m_eDeviceAnim == BA_DisarmBomb) || m_eDeviceAnim == BA_ArmBomb)
    {
        fSkillDevice = GetSkill(SKILL_Demolitions);
    }
    else
    {
        fSkillDevice = GetSkill(SKILL_Electronics);
    }
    if(fSkillDevice < 0.8)
    {
        fAnimRate = 1.0 + (((0.8 - fSkillDevice) / 0.8) * 0.25);
    }
    else
    {
        fAnimRate = 0.8 + (((float(1) - fSkillDevice) / 0.2) * 0.2);
    }
    R6ResetAnimBlendParams(C_iPeekingAnimChannel);
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    m_bPostureTransition = true;
    AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);
    switch(m_eDeviceAnim)
    {
        case BA_Keypad:
            if(Controller != none)
            {
                Controller.PlaySoundCurrentAction(RTV_DesactivatingSecurity);
            }
            if(bIsCrouched)
            {
                LoopAnim('CrouchKeyPad_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);
            }
            else
            {
                LoopAnim('StandKeyPad_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);
            }
            break;
        case BA_ArmBomb:
        case BA_DisarmBomb:
            LoopAnim('CrouchDisarmBomb_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);
            break;
        case BA_PlantDevice:
            if(Controller != none)
            {
                Controller.PlaySoundCurrentAction(RTV_PlacingBug);
            }
            if(bIsCrouched)
            {
                LoopAnim('CrouchPlaceBug_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);
            }
            else
            {
                LoopAnim('StandPlaceBug_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);
            }
            break;
        case BA_Keyboard:
            if(Controller != none)
            {
                Controller.PlaySoundCurrentAction(RTV_AccessingComputer);
            }
            if(bIsCrouched)
            {
                LoopAnim('CrouchKeyboard_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);
            }
            else
            {
                LoopAnim('StandKeyboard_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);
            }
            break;
        case BA_Custom:
            if(m_iCustomDeviceAnim == 1)
            {
                PlayAnim('StandPickUp', 1.0, 0.2, 1);
            }
            else
            {
                LoopAnim('Breath', fAnimRate, 0.5, 1);
            }
            break;
    }
}

simulated function bool GetNormalWeaponAnimation(out STWeaponAnim stAnim)
{
    if(m_bPlayingComAnimation)
    {
        return false;
    }
    stAnim.bBackward = false;
    stAnim.bPlayOnce = false;
    if(int(m_bIsFiringWeapon) > 0)
    {
        stAnim.fTweenTime = 0.0;
    }
    else
    {
        stAnim.fTweenTime = 0.1;
    }
    stAnim.fRate = 1.0;
    if(IsUsingHeartBeatSensor())
    {
        stAnim.nBlendName = 'R6 Spine2';
    }
    else
    {
        stAnim.nBlendName = 'R6 R Clavicle';
    }
    if(m_bIsProne)
    {
        if((EngineWeapon != none) && R6AbstractWeapon(EngineWeapon).m_BipodGadget == none)
        {
            stAnim.nAnimToPlay = EngineWeapon.GetProneWaitAnimName();
        }
        else
        {
            m_ePlayerIsUsingHands = HANDS_Both;
            return false;
        }
    }
    else
    {
        if((m_eEquipWeapon == EQUIP_NoWeapon) || EngineWeapon == none)
        {
            if(m_iTeam == 7)
            {
                stAnim.nAnimToPlay = 'CrouchNoGun_nt';
            }
            else
            {
                stAnim.nAnimToPlay = 'StandNoGun_nt';
            }
        }
        else
        {
            if(m_bUseHighStance)
            {
                stAnim.nAnimToPlay = EngineWeapon.GetHighWaitAnimName();
            }
            else
            {
                stAnim.nAnimToPlay = EngineWeapon.GetWaitAnimName();
            }
        }
    }
    return true;
}

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
    if(class'Actor'.static.GetModMgr().IsMissionPack())
    {
        if(PlayerController.GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode")
        {
            if(!Controller.IsA('MP2PlayerController') && IsAlive())
            {
                if((MP2RainbowAI(Controller).m_TeamManager != none) && (R6AIController(Controller).IsInState('FollowLeader') || R6AIController(Controller).IsInState('BumpBackUp')))
                {
                    if(MP2RainbowAI(Controller).m_TeamManager == MP2PlayerController(PlayerController).m_TeamManager)
                    {
                        Query.iHasAction = 1;
                        if(fDistance < m_fCircumstantialActionRange)
                        {
                            Query.iInRange = 1;
                        }
                        else
                        {
                            Query.iInRange = 0;
                        }
                        Query.textureIcon = Texture'R6ActionIcons.HostageStayHere';
                        Query.iPlayerActionID = MP2RainbowAI(Controller).eRainbowOrder.ROrder_StayHere;
                        Query.iTeamActionID = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                        Query.iTeamActionIDList[0] = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                        Query.iTeamActionIDList[1] = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                        Query.iTeamActionIDList[2] = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                        Query.iTeamActionIDList[3] = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                    }
                }
                else
                {
                    if(!(MP2PlayerController(PlayerController).m_TeamManager.m_iMemberCount == 4) && (R6AIController(Controller).IsInState('FreeBackupWaiting') || R6AIController(Controller).IsInState('BumpBackUp')))
                    {
                        Query.iHasAction = 1;
                        if(fDistance < m_fCircumstantialActionRange)
                        {
                            Query.iInRange = 1;
                        }
                        else
                        {
                            Query.iInRange = 0;
                        }
                        Query.textureIcon = Texture'R6ActionIcons.HostageFollowMe';
                        Query.iPlayerActionID = MP2RainbowAI(Controller).eRainbowOrder.ROrder_ComeWithMe;
                        Query.iTeamActionID = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                        Query.iTeamActionIDList[0] = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                        Query.iTeamActionIDList[1] = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                        Query.iTeamActionIDList[2] = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                        Query.iTeamActionIDList[3] = MP2RainbowAI(Controller).eRainbowOrder.ROrder_None;
                    }
                }
            }
        }
    }
    else
    {
        super.R6QueryCircumstantialAction(fDistance, Query, PlayerController);
    }
}

simulated function PlayMP2Coughing()
{
    if(m_bIsClimbingLadder || m_bWeaponTransition)
    {
        return;
    }
    m_ePlayerIsUsingHands = HANDS_None;
    m_bPawnSpecificAnimInProgress = true;
    AnimBlendParams(16, 1.0, 0.5, 0.0, 'R6 Spine');
    if(m_bIsProne)
    {
        PlayAnim('ProneGazed', 1.0, 0.0, 16);
    }
    else
    {
        if(bIsCrouched)
        {
            PlayAnim('CrouchGazed', 1.0, 0.0, 16);
        }
        else
        {
            PlayAnim('StandGazed', 1.0, 0.0, 16);
        }
    }
}

function bool ProcessBuildDeathMessage(Pawn Killer, out string szPlayerName)
{
    if(Level.NetMode != NM_Standalone)
    {
        if(Killer.m_bIsPlayer && m_bIsTheIntruder)
        {
            m_bSuicideType = 12;
        }
    }
    return super.ProcessBuildDeathMessage(Killer, szPlayerName);
}

function GiveObject()
{
    m_bHasDataObject = false;
}

simulated function ServerActionRequest(R6CircumstantialActionQuery actionRequested)
{
    if(!m_bIsPlayer || actionRequested.aQueryTarget == none)
    {
        return;
    }
    if(actionRequested.aQueryTarget.IsA('MP2Rainbow'))
    {
        if(Level.Game.m_szGameTypeFlag == "RGM_VirusUploadAdvMode")
        {
            MP2Rainbow(MP2PlayerController(Controller).m_pawn).GiveObject();
            MP2Rainbow(actionRequested.aQueryTarget).TakeObject();
        }
        else
        {
            if(Level.Game.m_szGameTypeFlag == "RGM_FreeBackupAdvMode")
            {
                MP2RainbowAI(MP2Rainbow(actionRequested.aQueryTarget).Controller).DispatchOrder(int(actionRequested.iPlayerActionID), MP2PlayerController(Controller).m_TeamManager);
            }
        }
        return;
    }
    else
    {
        super(R6Pawn).ServerActionRequest(actionRequested);
    }
}

simulated function SetSkin(Material aSkin, int iIndex)
{
    if(iIndex > 5)
    {
        return;
    }
    Skins[iIndex] = aSkin;
    m_aRepSkins[iIndex] = aSkin;
}

simulated event PostNetBeginPlay()
{
    super.PostNetBeginPlay();
}

simulated function SetFemaleParameters()
{
    SetPawnScale(0.95);
    m_fAttachFactor = 0.95;
    m_fPrePivotPawnInitialOffset = -4.0;
    if(Level.NetMode != NM_Client)
    {
        PrePivot.Z += m_fPrePivotPawnInitialOffset;
    }
}

simulated function SetRainbowFaceTexture()
{
    local int iFaceIndex;
    local string aFaceTexture;
    local Texture aTexture;

    if(bShowLog)
    {
        log((((string(self) $ " SetRainbowFaceTexture() : bIsFemale =") $ string(bIsFemale)) $ " m_iOperativeID=") $ string(m_iOperativeID));
    }
    iFaceIndex = 3;
    if(bIsFemale)
    {
        SetFemaleParameters();
        if(m_Helmet != none)
        {
            m_Helmet.DrawScale = 1.0;
        }
        if(m_NightVision != none)
        {
            m_NightVision.DrawScale = 1.0;
        }
    }
    switch(m_iOperativeID)
    {
        case 0:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceArnavisca";
            break;
        case 1:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBeckenbauer";
            break;
        case 2:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBogart";
            break;
        case 3:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBurke";
            break;
        case 4:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceChaves";
            break;
        case 5:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceDuBarry";
            break;
        case 6:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceFilatov";
            break;
        case 7:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceGalanos";
            break;
        case 8:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHaider";
            break;
        case 9:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHanley";
            break;
        case 10:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHomer";
            break;
        case 11:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceLofquist";
            break;
        case 12:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceLoiselle";
            break;
        case 13:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMaldini";
            break;
        case 14:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMcAllen";
            break;
        case 15:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMorris";
            break;
        case 16:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMurad";
            break;
        case 17:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNarino";
            break;
        case 18:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNoronha";
            break;
        case 19:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNovikov";
            break;
        case 20:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceSuo_Won";
            break;
        case 21:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFacePetersen";
            break;
        case 22:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFacePrice";
            break;
        case 23:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceRakuzanka";
            break;
        case 24:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceRaymond";
            break;
        case 25:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWalter";
            break;
        case 26:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWeber";
            break;
        case 27:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWoo";
            break;
        case 28:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceYakoby";
            break;
        default:
            aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceReserve";
    }
    if(aFaceTexture != "")
    {
        Skins[iFaceIndex] = Texture(DynamicLoadObject(aFaceTexture, Class'Engine.Texture'));
    }
}

function TakeObject()
{
    local R6IOFloppy ioFloppy;

    if(Level.m_bShowFloppy != false)
    {
        Level.m_bShowFloppy = false;
    }
    m_bHasDataObject = true;
    if(Role == ROLE_Authority)
    {
        R6PlayerController(Controller).m_fCompteurFrameDetection = 0.0;
        foreach AllActors(Class'MP2Game.R6IOFloppy', ioFloppy)
        {
            ioFloppy.bHidden = true;
            ioFloppy.SetCollision(false, false, false);
            ioFloppy.SetOwner(R6PlayerController(Controller));
        }
    }
}

function TakeObject1()
{
    local R6IOFloppy ioFloppy;

    if(Level.m_bShowFloppy != false)
    {
        Level.m_bShowFloppy = false;
    }
    else
    {
        return;
    }
    m_bHasDataObject = true;
    if(Role == ROLE_Authority)
    {
        R6PlayerController(Controller).m_fCompteurFrameDetection = 0.0;
        foreach AllActors(Class'MP2Game.R6IOFloppy', ioFloppy)
        {
            ioFloppy.bHidden = true;
            ioFloppy.SetCollision(false, false, false);
            ioFloppy.SetOwner(R6PlayerController(Controller));
        }
    }
}

function Escort_UpdateList()
{
    local int i, j;
    local R6HostageAI hostageAI;
    local R6Hostage hostage;
    local R6Rainbow newLeadRainbow;
    local R6RainbowTeam teamMgr;

    if(m_aEscortedHostage[0] == none)
    {
        return;
    }
    if(!IsAlive())
    {
        if(Level.Game.m_szGameTypeFlag == "RGM_LimitSeatsAdvMode")
        {
            i = 0;

            while((i < 4) && m_aEscortedHostage[i] != none)
            {
                hostageAI = R6HostageAI(m_aEscortedHostage[i].Controller);
                hostageAI.Order_StayHere(false);
                ++i;
            }
        }
        else
        {
            newLeadRainbow = Escort_FindRainbow(m_aEscortedHostage[0]);
            if(newLeadRainbow == none)
            {
                i = 0;

                while((i < 4) && m_aEscortedHostage[i] != none)
                {
                    hostageAI = R6HostageAI(m_aEscortedHostage[i].Controller);
                    hostageAI.Order_StayHere(false);
                    ++i;
                }
            }
            else
            {
                newLeadRainbow = newLeadRainbow.Escort_GetPawnToFollow();
                i = 0;

                while((i < 4) && m_aEscortedHostage[i] != none)
                {
                    hostage = m_aEscortedHostage[i];
                    newLeadRainbow.Escort_AddHostage(hostage, true);
                    m_aEscortedHostage[i] = none;
                    ++i;
                }
            }
        }
        return;
    }
    i = 0;

    while((i < 4) && m_aEscortedHostage[i] != none)
    {
        if(!m_aEscortedHostage[i].IsAlive())
        {

            for(j = i; (j + 1) < 4; j++)
            {
                m_aEscortedHostage[j] = m_aEscortedHostage[j + 1];
            }
            m_aEscortedHostage[j] = none;
        }
        else
        {
            i++;
        }
    }
    Escort_UpdateCloserToLead();
    for(i = 0; (i < 4) && m_aEscortedHostage[i] != none; ++i)
    {
        hostageAI = R6HostageAI(m_aEscortedHostage[i].Controller);
        if(i == 0)
        {
            hostageAI.m_pawnToFollow = self;
        }
        else
        {
            hostageAI.m_pawnToFollow = m_aEscortedHostage[i - 1];
        }
    }
}

static function string BuildDeathMessage(string Killer, string killed, byte bDeathMsgType)
{
    local string DeathMessage;

    if(int(bDeathMsgType) == DEATHMSG_CONNECTIONLOST)
    {
        DeathMessage = (killed $ " ") $ (Localize("MPDeathMessages", "LeftTheGame", "R6GameInfo"));
    }
    else
    {
        if(int(bDeathMsgType) == DEATHMSG_PENALTY)
        {
            DeathMessage = (("" $ (Localize("MPDeathMessages", "PenaltyTo", "R6GameInfo"))) $ " ") $ Killer;
        }
        else
        {
            if(int(bDeathMsgType) == DEATHMSG_HOSTAGE_DIED)
            {
                DeathMessage = Localize("MPDeathMessages", "HostageHasDied", "R6GameInfo");
            }
            else
            {
                if(int(bDeathMsgType) == 9)
                {
                    DeathMessage = (Killer $ " ") $ (Localize("MPDeathMessages", "PlayerKilledByBomb", "R6GameInfo"));
                }
                else
                {
                    if(int(bDeathMsgType) == DEATHMSG_HOSTAGE_KILLEDBYTERRO)
                    {
                        DeathMessage = (Killer $ " ") $ (Localize("MPDeathMessages", "TerroKilledHostage", "R6GameInfo"));
                    }
                    else
                    {
                        if(int(bDeathMsgType) == 11)
                        {
                            DeathMessage = (Killer $ " ") $ (Localize("MPDeathMessages", "RainbowSuffocated", "IronWrathGameInfo"));
                        }
                        else
                        {
                            if((int(bDeathMsgType) == 3) || Killer == killed)
                            {
                                DeathMessage = (Killer $ " ") $ (Localize("MPDeathMessages", "PlayerSuicided", "R6GameInfo"));
                            }
                            else
                            {
                                if(int(bDeathMsgType) == DEATHMSG_HOSTAGE_KILLEDBY)
                                {
                                    DeathMessage = (Killer $ " ") $ (Localize("MPDeathMessages", "KilledAHostage", "R6GameInfo"));
                                }
                                else
                                {
                                    if(int(bDeathMsgType) == 10)
                                    {
                                        DeathMessage = (Killer $ " ") $ (Localize("MPDeathMessages", "KilledAPrisoner", "IronWrathGameInfo"));
                                    }
                                    else
                                    {
                                        if(int(bDeathMsgType) == 8)
                                        {
                                            DeathMessage = ((Localize("MPDeathMessages", "TerroKilledPlayer", "R6GameInfo")) $ " ") $ killed;
                                        }
                                        else
                                        {
                                            if(int(bDeathMsgType) == 12)
                                            {
                                                DeathMessage = (Killer $ " ") $ (Localize("MPDeathMessages", "KilledTheIntruder", "IronWrathGameInfo"));
                                            }
                                            else
                                            {
                                                DeathMessage = (((Killer $ " ") $ (Localize("MPDeathMessages", "PlayerKilledPlayer", "R6GameInfo"))) $ " ") $ killed;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return DeathMessage;
}

defaultproperties
{
    m_FOVClass=Class'R6Characters.R6FieldOfView'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel294
        KConvulseSpacing=(Min=0.5,Max=2.2)
        KSkeleton="terroskel"
        KStartEnabled=true
        bHighDetailOnly=false
        KLinearDamping=0.5
        KAngularDamping=0.5
        KBuoyancy=1.0
        KVelDropBelowThreshold=50.0
        KFriction=0.6
        KRestitution=0.3
        KImpactThreshold=150.0
        Name="KarmaParamsSkel294"
    End Object
    KParams=KarmaParamsSkel'MP2Game.KarmaParamsSkel294'
}
