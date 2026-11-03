class MP2PlayerController extends R6PlayerController
    native
    config(User);

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2ActionIcons.utx PACKAGE=MP2ActionIcons
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\SFX_MdeGazAlrt.uax PACKAGE=SFX_MdeGazAlrt

var int m_iIntervalLength;
var int m_iNbPrisonersSaved;
var bool m_bDisplayDetectable;
var() float m_fCompteurFrame;
var float m_fOxygeneLevel;
var float m_fCompteurFrameDetection;
var Sound m_sndBoucleStress;
var Sound m_sndBoucleStressStop;
var Sound m_sndBoucleBaisse;
var Sound m_sndBoucleBaisseStop;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientGameTypeDescriptionMP2, m_bDisplayDetectable,
        m_fCompteurFrameDetection, m_fOxygeneLevel,
        m_iNbPrisonersSaved;
}

simulated function HideLimitSeatsIcons()
{
    local MP2PrisonerIcon PIco;

    foreach AllActors(Class'R6Engine.MP2PrisonerIcon', PIco)
    {
        PIco.bHidden = false;
        if(!PIco.m_bKnownForOtherTeam)
        {
            if(!((PIco.m_iPrisonerTeam + 2) == m_pawn.m_iTeam))
            {
                PIco.bHidden = true;
            }
        }
    }
}

function InitInteractions()
{
    if(Player != none)
    {
        if(m_InteractionMaster == none)
        {
            m_InteractionMaster = Player.InteractionMaster;
        }
        if(m_InteractionCA == none)
        {
            m_InteractionCA = R6InteractionCircumstantialAction(m_InteractionMaster.AddInteraction("MP2Game.MP2InteractionCircumstantialAction", Player));
        }
        if(m_InteractionInventory == none)
        {
            m_InteractionInventory = R6InteractionInventoryMnu(m_InteractionMaster.AddInteraction("R6Engine.R6InteractionInventoryMnu", Player));
        }
    }
    log("Creating Interactions  m_InteractionCA= " $ string(m_InteractionCA));
}

function ClientGameTypeDescriptionMP2(string szGameTypeFlag)
{
    local string szObjective;

    if(PlayerReplicationInfo.TeamID == int(ePlayerTeamSelection.PTS_Bravo))
    {
        szObjective = Level.GetRedShortDescription(szGameTypeFlag);
        if(szObjective != "")
        {
            HandleServerMsgMP2(szObjective, 6, 1);
        }
    }
    else
    {
        szObjective = Level.GetGreenShortDescription(szGameTypeFlag);
        if(szObjective != "")
        {
            HandleServerMsgMP2(szObjective, 6, 1);
        }
    }
}

function HandleServerMsgMP2(string _szServerMsg, optional int iLifeTime, optional byte bMessageUseBigFont)
{
    myHUD.AddTextServerMessage(_szServerMsg, Class'Engine.LocalMessage', iLifeTime, bMessageUseBigFont);
}

simulated function ResetOriginalData()
{
    super.ResetOriginalData();
    if(Role == ROLE_Authority)
    {
        if(Level.Game.m_szGameTypeFlag == "RGM_GazAlertAdvMode")
        {
            m_fOxygeneLevel = Level.m_fOxygeneTopLevel;
            m_iIntervalLength = int(Level.m_iCoughSeuil / (Level.m_fOxygeneStepDecrease * float(Level.m_iCoughTimes)));
        }
        else
        {
            m_fOxygeneLevel = -1.0;
        }
    }
}

event Tick(float fDeltaTime)
{
    local int j;
    local float f;
    local R6AbstractEviLPatchService.PatchState PatchState;

    if(m_bQuitToUpdateServerDisplayed == false)
    {
        PatchState = class'R6AbstractEviLPatchService'.static.GetState();
        if(PatchState == PS_RunPatch)
        {
            m_bQuitToUpdateServerDisplayed = true;
            HandleServerMsg(Localize("Options", "PatchStatus_RunPatch", "R6Menu"));
        }
    }
    if((m_pawn != none) && Pawn != none)
    {
        UpdateCircumstantialAction();
        UpdateReticule(fDeltaTime);
        if(m_pawn.bInvulnerableBody)
        {
            if((Level.TimeSeconds - m_fStartSurrenderTime) > float(3))
            {
                m_pawn.bInvulnerableBody = false;
            }
        }
    }
    if(m_fCompteurFrameDetection == 0.0)
    {
        MP2PlayVirusUploadSounds(0.0);
    }
    if((Role == ROLE_Authority) && PlayerReplicationInfo.m_bPlayerReady)
    {
        if(Level.Game.m_szGameTypeFlag == "RGM_VirusUploadAdvMode")
        {
            if(MP2Rainbow(m_pawn).m_bHasDataObject == true)
            {
                if(m_fCompteurFrameDetection < (Level.m_fTempsDetection * 0.92))
                {
                    m_fCompteurFrameDetection += fDeltaTime;
                    Level.m_fCompteurFrameDetection = m_fCompteurFrameDetection;
                }
            }
            else
            {
                m_fCompteurFrameDetection = -1.0;
            }
        }
    }
    if((MP2Rainbow(m_pawn) != none) && MP2Rainbow(m_pawn).m_bHasDataObject == true)
    {
        if(((((Level.m_fTempsDetection * 0.92) - m_fCompteurFrameDetection) < fDeltaTime) && float(0) <= ((Level.m_fTempsDetection * 0.92) - m_fCompteurFrameDetection)) || (((Level.m_fClignoteTime - MP2Hud(myHUD).m_fClignoteTexte) < fDeltaTime) && float(0) <= (Level.m_fClignoteTime - MP2Hud(myHUD).m_fClignoteTexte)))
        {
            MP2PlayVirusUploadSounds(fDeltaTime);
        }
    }
    if((Pawn != none) && Pawn.IsLocallyControlled())
    {
        if(m_fCompteurFrameDetection < (Level.m_fTempsDetection * 0.92))
        {
            MP2Hud(myHUD).m_fClignoteTexteFrequece = 0.9;
            MP2Hud(myHUD).m_fClignoteTexte = 0.0;
        }
        else
        {
            MP2Hud(myHUD).m_fClignoteTexteFrequece += fDeltaTime;
            MP2Hud(myHUD).m_fClignoteTexte += fDeltaTime;
            if(MP2Hud(myHUD).m_fClignoteTexte < Level.m_fClignoteTime)
            {
                if(MP2Hud(myHUD).m_fClignoteTexteFrequece > 0.8)
                {
                    MP2Hud(myHUD).m_fClignoteTexteFrequece = 0.0;
                    MP2Hud(myHUD).MP2AddTextServerMessage(Localize("Game", "PilotDetectable", "IronWrathGameMode"), Class'Engine.LocalMessage', 0.5, 2);
                }
            }
        }
    }
    if(PlayerReplicationInfo.m_bPlayerReady)
    {
        m_fCompteurFrame += fDeltaTime;
        if(m_fCompteurFrame > float(1))
        {
            if(m_fOxygeneLevel == Level.m_fOxygeneTopLevel)
            {
                ClientPlaySound(m_sndBoucleBaisseStop, SLOT_SFX);
                ClientPlaySound(m_sndBoucleBaisse, SLOT_SFX);
            }
            if((-Level.m_fOxygeneStepDecrease <= (Level.m_iCoughSeuil - m_fOxygeneLevel)) && (Level.m_iCoughSeuil - m_fOxygeneLevel) <= float(0))
            {
                ClientPlaySound(m_sndBoucleStress, SLOT_SFX);
            }
            if(Role == ROLE_Authority)
            {
                if(Level.Game.m_szGameTypeFlag == "RGM_GazAlertAdvMode")
                {
                    if((m_MenuCommunication == none) || int(m_MenuCommunication.m_GameRepInfo.m_eCurrectServerState) > m_MenuCommunication.m_GameRepInfo.RSS_InPreGameState)
                    {
                        j = int(m_fOxygeneLevel / (Level.m_fOxygeneStepDecrease * float(m_iIntervalLength)));
                        f = float(j * m_iIntervalLength) * Level.m_fOxygeneStepDecrease;
                        if(MP2Rainbow(m_pawn).IsAlive())
                        {
                            m_fOxygeneLevel -= Level.m_fOxygeneStepDecrease;
                        }
                        if((m_fOxygeneLevel < float(0)) && m_pawn.IsAlive())
                        {
                            MP2Rainbow(m_pawn).m_bSuicideType = 11;
                            MP2Rainbow(m_pawn).ServerForceKillResult(4);
                            MP2Rainbow(m_pawn).R6TakeDamage(1000, 1000, m_pawn, m_pawn.Location + m_pawn.EyePosition(), vect(0.0, 0.0, 0.0), 0);
                            MP2Rainbow(m_pawn).ServerForceKillResult(0);
                            PlaySuffocationSound();
                        }
                        else
                        {
                            if(((m_fOxygeneLevel <= Level.m_iCoughSeuil) && (m_fOxygeneLevel > (f - Level.m_fOxygeneStepDecrease)) && m_fOxygeneLevel <= f) && MP2Rainbow(m_pawn).IsAlive())
                            {
                                MP2Rainbow(m_pawn).PlayMP2Coughing();
                                PlayCoughSound();
                            }
                        }
                    }
                }
                else
                {
                    m_fOxygeneLevel = -1.0;
                }
            }
            m_fCompteurFrame = 0.0;
        }
    }
}

function MP2PlayVirusUploadSounds(float f)
{
    if(m_fCompteurFrameDetection == float(0))
    {
        ClientPlaySound(m_sndBoucleBaisse, SLOT_SFX);
    }
    else
    {
        if((m_fCompteurFrameDetection + f) >= (Level.m_fTempsDetection * 0.92))
        {
            ClientPlaySound(m_sndBoucleBaisseStop, SLOT_SFX);
            ClientPlaySound(m_sndBoucleStress, SLOT_SFX);
        }
        if((MP2Hud(myHUD).m_fClignoteTexte + f) >= Level.m_fClignoteTime)
        {
            ClientPlaySound(m_sndBoucleStressStop, SLOT_SFX);
        }
    }
}

function PlayCoughSound()
{
    m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_Cough);
}

function PlaySuffocationSound()
{
    m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_Suffocation);
}

exec function ToggleTeamHold()
{
    if(m_TeamManager == none)
    {
        return;
    }
    if(m_TeamManager.m_iMemberCount == 1)
    {
        return;
    }
    if(bOnlySpectator || bCheatFlying)
    {
        return;
    }
    if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode")
    {
        return;
    }
    if(m_TeamManager.m_bTeamIsHoldingPosition && !m_TeamManager.m_Team[1].Controller.IsInState('FollowLeader'))
    {
        m_TeamManager.InstructPlayerTeamToFollowLead();
    }
    else
    {
        m_TeamManager.InstructPlayerTeamToHoldPosition();
    }
}

exec function ToggleAllTeamsHold()
{
    local R6RainbowTeam AITeam;

    ToggleTeamHold();
    if(Level.NetMode != NM_Standalone)
    {
        return;
    }
    if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode")
    {
        return;
    }
    if(m_bAllTeamsHold)
    {
        m_bAllTeamsHold = false;
        if(R6AbstractGameInfo(Level.Game) != none)
        {
            R6AbstractGameInfo(Level.Game).InstructAllTeamsToFollowPlanning();
        }
    }
    else
    {
        m_bAllTeamsHold = true;
        if(R6AbstractGameInfo(Level.Game) != none)
        {
            R6AbstractGameInfo(Level.Game).InstructAllTeamsToHoldPosition();
        }
    }
}

function ServerPlayerActionProgress()
{
    m_PlayerCurrentCA = m_RequestedCircumstantialAction;
    if(m_PlayerCurrentCA.aQueryTarget.IsA('R6Terrorist'))
    {
        GotoState('PlayerSecureTerrorist');
    }
    else
    {
        if(m_PlayerCurrentCA.aQueryTarget.IsA('MP2Rainbow'))
        {
            GotoState('PlayerInteractWithPlayer');
        }
        else
        {
            if(m_PlayerCurrentCA.aQueryTarget.IsA('R6IOFloppy'))
            {
                GotoState('PlayerActionFloppyProgress');
            }
            else
            {
                GotoState('PlayerActionProgress');
            }
        }
    }
}

function bool PlayerCanSwitchToAIBackup()
{
    if(Level.NetMode == NM_Standalone)
    {
        if(R6AbstractGameInfo(Level.Game).RainbowOperativesStillAlive())
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    if((m_TeamManager == none) || m_TeamManager.m_iMemberCount == 0)
    {
        return false;
    }
    if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode")
    {
        return false;
    }
    if(!Level.IsGameTypeCooperative(GameReplicationInfo.m_szGameTypeFlagRep))
    {
        return false;
    }
    if(!R6GameReplicationInfo(GameReplicationInfo).m_bAIBkp)
    {
        return false;
    }
    return true;
}

function bool CanIssueTeamOrder()
{
    if(((((m_TeamManager == none) || m_TeamManager.m_iMemberCount <= 1) || m_TeamManager.m_bTeamIsClimbingLadder) || GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode") || Level.m_bInGamePlanningActive)
    {
        return false;
    }
    return true;
}

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
    local bool bIsOpen;
    local Vector vFacingDir, vActorDir;

    Query.iHasAction = 1;
    if(bOnlySpectator)
    {
        Query.iInRange = 1;
        Query.textureIcon = Texture'R6ActionIcons.Spectator';
        Query.iPlayerActionID = eDefaultCircumstantialAction.PCA_None;
        Query.iTeamActionID = eDefaultCircumstantialAction.PCA_None;
        Query.iTeamActionIDList[0] = eDefaultCircumstantialAction.PCA_None;
        Query.iTeamActionIDList[1] = eDefaultCircumstantialAction.PCA_None;
        Query.iTeamActionIDList[2] = eDefaultCircumstantialAction.PCA_None;
        Query.iTeamActionIDList[3] = eDefaultCircumstantialAction.PCA_None;
        return;
    }
    if(Level.Game.m_szGameTypeFlag == "RGM_VirusUploadAdvMode")
    {
        if(!MP2Rainbow(m_pawn).m_bHasDataObject)
        {
            if(fDistance < float(110))
            {
                vFacingDir = Vector(Rotation);
                vFacingDir.Z = 0.0;
                vActorDir = Vector(PlayerController.Pawn.Rotation);
                vActorDir.Z = 0.0;
                if((vActorDir Dot vFacingDir) < - 0.8) // Joshua - Spaced so it compiles to a negation, as shipped
                {
                    Query.iInRange = 1;
                }
                else
                {
                    Query.iInRange = 0;
                }
            }
            else
            {
                Query.iInRange = 0;
            }
            Query.iHasAction = 1;
            Query.bCanBeInterrupted = true;
            Query.textureIcon = Texture'MP2ActionIcons.icones_disquette';
            return;
        }
    }
    if(((m_TeamManager == none) || m_TeamManager.m_iMemberCount <= 1) || m_bPreventTeamMemberUse)
    {
        Query.iHasAction = 0;
        return;
    }
    if(fDistance < m_fCircumstantialActionRange)
    {
        Query.iInRange = 1;
        Query.textureIcon = Texture'R6ActionIcons.RegroupOnMe';
    }
    else
    {
        Query.iInRange = 0;
        Query.textureIcon = Texture'R6ActionIcons.TeamMoveTo';
    }
    Query.iPlayerActionID = eDefaultCircumstantialAction.PCA_TeamRegroup;
    Query.iTeamActionID = eDefaultCircumstantialAction.PCA_TeamMoveTo;
    Query.iTeamActionIDList[0] = eDefaultCircumstantialAction.PCA_TeamMoveTo;
    Query.iTeamActionIDList[1] = eDefaultCircumstantialAction.PCA_MoveAndGrenade;
    Query.iTeamActionIDList[2] = eDefaultCircumstantialAction.PCA_None;
    Query.iTeamActionIDList[3] = eDefaultCircumstantialAction.PCA_None;
    R6FillSubAction(Query, 0, eDefaultCircumstantialAction.PCA_None);
    R6FillGrenadeSubAction(Query, 1);
    R6FillSubAction(Query, 2, eDefaultCircumstantialAction.PCA_None);
    R6FillSubAction(Query, 3, eDefaultCircumstantialAction.PCA_None);
}

function int R6GetCircumstantialActionProgress(R6AbstractCircumstantialActionQuery Query, Pawn actingPawn)
{
    local name Anim;
    local float fFrame, fRate;

    actingPawn.GetAnimParams(m_pawn.C_iBaseBlendAnimChannel, Anim, fFrame, fRate);
    Clamp(int(fFrame), 0, 100);
    return int(fFrame * float(100));
}

function PlaySoundCurrentAction(Pawn.ERainbowTeamVoices eVoices)
{
    if(Role == ROLE_Authority)
    {
        if(Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
        {
            m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, eVoices);
        }
        else
        {
            if(eVoices == RTV_HostageSecured)
            {
                if(!(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_LimitSeatsAdvMode"))
                {
                    m_TeamManager.m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_pawn, RPV_HostageSecured);
                }
            }
        }
    }
}

function ClientResetGameMsg()
{
    local int i;

    for(i = 0; i < myHUD.c_iTextServerMessagesMax; i++)
    {
        myHUD.TextServerMessages[i] = "";
        myHUD.MessageServerLife[i] = 0.0;
        myHUD.MessageUseBigFont[i] = 0;
    }
}

function addToOxygenLevel(float f)
{
    if((m_fOxygeneLevel <= Level.m_iCoughSeuil) && Level.m_iCoughSeuil <= f)
    {
        ClientPlaySound(m_sndBoucleStressStop, SLOT_SFX);
    }
    m_fOxygeneLevel = f;
}

function ClientRestartMatchMsg(string _AdminName, string explanation)
{
    HandleServerMsg((_AdminName $ " ") $ (Localize("Game", "RestartsTheMatch", "R6GameInfo")));
    if(explanation != "")
    {
        HandleServerMsg(explanation);
    }
    m_MenuCommunication.SetPlayerReadyStatus(false);
}

exec function RestartMatch(string explanation)
{
    local MP2PlayerController _playerController;
    local string _AdminName;

    if((CheckAuthority(1)) == false)
    {
        ClientNoAuthority();
        return;
    }
    _AdminName = PlayerReplicationInfo.PlayerName;
    DisableFirstPersonViewEffects();
    foreach AllActors(Class'MP2Game.MP2PlayerController', _playerController)
    {
        _playerController.ClientDisableFirstPersonViewEffects();
        _playerController.ClientRestartMatchMsg(_AdminName, explanation);
    }
    Level.Game.AbortScoreSubmission();
    Level.Game.RestartGame();
}

function ClientDeathMessage(string Killer, string killed, byte bSuicideType)
{
    if(Level.NetMode == NM_Standalone)
    {
        return;
    }
    if(myHUD != none)
    {
        if(int(bSuicideType) == DEATHMSG_CONNECTIONLOST)
        {
            myHUD.AddTextMessage(class'R6Pawn'.static.BuildDeathMessage(Killer, killed, bSuicideType), Class'Engine.LocalMessage');
        }
        else
        {
            if(int(bSuicideType) != DEATHMSG_SWITCHTEAM)
            {
                if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CaptureTheEnemyAdvMode")
                {
                    myHUD.AddDeathTextMessage((((((killed $ " ") $ (Localize("MPDeathMessages", "PlayerHasBeenShot", "ASGameMode"))) $ " ") $ Killer) $ " ") $ (Localize("MPDeathMessages", "PlayerSurrender", "ASGameMode")), Class'Engine.LocalMessage');
                }
                else
                {
                    myHUD.AddDeathTextMessage(class'MP2Rainbow'.static.BuildDeathMessage(Killer, killed, bSuicideType), Class'Engine.LocalMessage');
                }
            }
        }
    }
}

exec function Suicide()
{
    if(R6Pawn(Pawn) == none)
    {
        return;
    }
    if(!m_pawn.IsAlive())
    {
        return;
    }
    if(GameReplicationInfo == none)
    {
        return;
    }
    if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_LimitSeatsAdvMode")
    {
        return;
    }
    if((Level.NetMode != NM_Standalone) && int(GameReplicationInfo.m_eCurrectServerState) != GameReplicationInfo.RSS_InGameState)
    {
        return;
    }
    if(GameReplicationInfo.m_bInPostBetweenRoundTime || GameReplicationInfo.m_bGameOverRep)
    {
        return;
    }
    R6Pawn(Pawn).ServerSuicidePawn(DEATHMSG_KAMAKAZE);
    if(Player.Console != none)
    {
        Player.Console.Message("Commited suicide", 6.0);
    }
}

state CameraPlayer
{
    function SpectatorChangeTeams(bool bNextTeam)
    {
        local MP2Rainbow Other, first, Last;
        local bool bFound;

        if(bShowLog)
        {
            log("  SpectatorChangeTeams() bNextTeam=" $ string(bNextTeam));
        }
        if((Level.Game != none) && !Level.Game.bCanViewOthers)
        {
            return;
        }
        if(m_bSpectatorCameraTeamOnly && m_iTeamId == 0)
        {
            ValidateCameraTeamId();
        }
        if(bNextTeam)
        {
            first = none;
            foreach AllActors(Class'MP2Game.MP2Rainbow', Other)
            {
                if(Other.IsAlive())
                {
                    if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode")
                    {
                        if(!Other.m_bIsPlayer)
                        {
                            continue;
                        }
                    }
                    if(m_bSpectatorCameraTeamOnly && Other.m_iTeam != m_iTeamId)
                    {
                        continue;
                    }
                    if(bFound || first == none)
                    {
                        first = Other;
                        if(bFound)
                        {
                            break;
                        }
                    }
                    if(Other == ViewTarget)
                    {
                        bFound = true;
                    }
                }
            }
            if(first != none)
            {
                SetNewViewTarget(first);
            }
            else
            {
                return;
            }
        }
        else
        {
            Last = none;
            foreach AllActors(Class'MP2Game.MP2Rainbow', Other)
            {
                if(Other.IsAlive())
                {
                    if(m_bSpectatorCameraTeamOnly && Other.m_iTeam != m_iTeamId)
                    {
                        continue;
                    }
                    if((Other == ViewTarget) && Last != none)
                    {
                        break;
                    }
                    Last = Other;
                }
            }
            if(Last != none)
            {
                SetNewViewTarget(Last);
            }
            else
            {
                return;
            }
        }
    }

    simulated function SetNewViewTarget(Actor aViewTarget)
    {
        local MP2Rainbow aPawn;
        local R6RainbowTeam aOldTeamManager;

        if(m_eCameraMode == CAMERA_Ghost)
        {
            return;
        }
        if(bShowLog)
        {
            log("  SetNewViewTarget() aViewTarget=" $ string(aViewTarget));
        }
        aPawn = MP2Rainbow(aViewTarget);
        if(aPawn == none)
        {
            return;
        }
        if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode")
        {
            if(!aPawn.m_bIsPlayer)
            {
                return;
            }
        }
        SetViewTarget(aPawn);
        if(aPawn.Controller != none)
        {
            aOldTeamManager = m_TeamManager;
            if(!aPawn.m_bIsPlayer)
            {
                m_TeamManager = MP2RainbowAI(aPawn.Controller).m_TeamManager;
            }
            else
            {
                m_TeamManager = MP2PlayerController(aPawn.Controller).m_TeamManager;
            }
            if(((((Role == ROLE_Authority) && aOldTeamManager != none) && aOldTeamManager != m_TeamManager) && !aOldTeamManager.m_bLeaderIsAPlayer) && !m_TeamManager.m_bLeaderIsAPlayer)
            {
                aOldTeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, false, m_TeamManager.m_iIDVoicesMgr);
                m_TeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, true);
            }
        }
        SetSpectatorRotation();
        FixFOV();
        if((Level.NetMode == NM_ListenServer) && Viewport(Player) != none)
        {
            DisplayClientMessage();
        }
    }
}

state PlayerInteractWithPlayer extends PlayerWalking
{
    function BeginState()
    {
        m_bHideReticule = true;
        m_bDisplayActionProgress = true;
        if(m_pawn.EngineWeapon != none)
        {
            ToggleHelmetCameraZoom(true);
            Pawn.EngineWeapon.GotoState('PutWeaponDown');
            if(Level.NetMode != NM_Client)
            {
                m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
            }
            m_pawn.RainbowSecureWeapon();
        }
        SetPeekingInfo(PEEK_none, m_pawn.C_fPeekMiddleMax);
        ResetFluidPeeking();
        if(Role == ROLE_Authority)
        {
            m_bDisplayDetectable = false;
        }
    }

    function EndState()
    {
        log(string(Pawn) $ " has exited state PlayerInteractWithPlayer ");
        m_bDisplayActionProgress = false;
        m_pawn.m_bPawnSpecificAnimInProgress = false;
        if(m_iPlayerCAProgress < 100)
        {
            m_pawn.R6ResetAnimBlendParams(m_pawn.C_iBaseBlendAnimChannel);
            if(Role == ROLE_Authority)
            {
                R6CircumstantialActionCancel();
            }
        }
        m_pawn.m_bPostureTransition = false;
        m_iPlayerCAProgress = 0;
        m_pawn.m_ePlayerIsUsingHands = HANDS_None;
        if(m_pawn.EngineWeapon != none)
        {
            Pawn.EngineWeapon.GotoState('BringWeaponUp');
            if(Level.NetMode != NM_Client)
            {
                m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
            }
            m_pawn.RainbowEquipWeapon();
        }
    }

    function PlayerMove(float fDeltaTime)
    {
        aForward = 0.0;
        aStrafe = 0.0;
        aMouseX = 0.0;
        aMouseY = 0.0;
        aTurn = 0.0;
        m_bPeekLeft = 0;
        m_bPeekRight = 0;
        global.PlayerMove(fDeltaTime);
    }

    function LongClientAdjustPosition(float TimeStamp, name NewState, Actor.EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ)
    {
        super(PlayerController).LongClientAdjustPosition(TimeStamp, 'PlayerInteractWithPlayer', newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);
    }

    event AnimEnd(int iChannel)
    {
        if((iChannel == m_pawn.C_iBaseBlendAnimChannel) && m_pawn.m_bPostureTransition)
        {
            m_pawn.m_bPostureTransition = false;
            m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5);
            m_iPlayerCAProgress = 100;
            if(Level.NetMode == NM_DedicatedServer)
            {
                ClientPlaySound(m_sndBoucleStressStop, SLOT_SFX);
                ClientPlaySound(m_sndBoucleBaisseStop, SLOT_SFX);
                ClientActionProgressDone();
            }
            if(m_InteractionCA != none)
            {
                ClientPlaySound(m_sndBoucleStressStop, SLOT_SFX);
                ClientPlaySound(m_sndBoucleBaisseStop, SLOT_SFX);
                m_InteractionCA.ActionProgressDone();
            }
            GotoState('PlayerWalking');
        }
        else
        {
            if((iChannel == m_pawn.C_iWeaponRightAnimChannel) && int(m_pawn.m_eEquipWeapon) == int(m_pawn.eEquipWeapon.EQUIP_NoWeapon))
            {
                m_pawn.m_bWeaponTransition = false;
                m_pawn.m_bPostureTransition = false;
                m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
                if(Level.NetMode != NM_Client)
                {
                    m_pawn.SetNextPendingAction(PENDING_Custom);
                }
            }
        }
    }

    event Tick(float fDeltaTime)
    {
        local Vector vActorDir, vhitnorm, vhitloc, vFacingDir;
        local float fDistancetoPawn;
        local Actor pHit;

        if((m_pawn.EngineWeapon != none) && int(m_pawn.m_eEquipWeapon) != int(m_pawn.eEquipWeapon.EQUIP_NoWeapon))
        {
            return;
        }
        if(!m_pawn.m_bPostureTransition)
        {
            return;
        }
        if(m_bDisplayDetectable)
        {
            m_iPlayerCAProgress = 0;
            GotoState('PlayerWalking');
        }
        if(Role == ROLE_Authority)
        {
            vFacingDir = Vector(Rotation);
            vFacingDir.Z = 0.0;
            vActorDir = Vector(MP2Rainbow(m_PlayerCurrentCA.aQueryTarget).Rotation);
            vActorDir.Z = 0.0;
            fDistancetoPawn = VSize(Pawn.Location - MP2Rainbow(m_PlayerCurrentCA.aQueryTarget).Location);
            if(((vActorDir Dot vFacingDir) < - 0.9) && fDistancetoPawn <= float(110)) // Joshua - Spaced so it compiles to a negation, as shipped
            {
                m_bDisplayDetectable = false;
                m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress(m_PlayerCurrentCA, m_pawn);
            }
            else
            {
                log("merde la distance est : " $ string(fDistancetoPawn));
                log("m_PlayerCurrentCA.aQueryTarget =" $ string(m_PlayerCurrentCA.aQueryTarget));
                log("my position " $ string(m_pawn.Location));
                log("aQueryTarget.location " $ string(MP2Rainbow(m_PlayerCurrentCA.aQueryTarget).Location));
                m_bDisplayDetectable = true;
            }
        }
    }
}

state PlayerActionFloppyProgress extends PlayerWalking
{
    function BeginState()
    {
        m_bHideReticule = true;
        m_bDisplayActionProgress = true;
        if(m_pawn.EngineWeapon != none)
        {
            ToggleHelmetCameraZoom(true);
            m_pawn.EngineWeapon.GotoState('PutWeaponDown');
            if(Level.NetMode != NM_Client)
            {
                m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
            }
        }
        Pawn.Acceleration = vect(0.0, 0.0, 0.0);
    }

    function LongClientAdjustPosition(float TimeStamp, name NewState, Actor.EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ)
    {
        super(PlayerController).LongClientAdjustPosition(TimeStamp, 'PlayerActionFloppyProgress', newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);
    }

    function PlayerMove(float fDeltaTime)
    {
        aForward = 0.0;
        aStrafe = 0.0;
        aMouseX = 0.0;
        aMouseY = 0.0;
        aTurn = 0.0;
        global.PlayerMove(fDeltaTime);
    }

    function StartProgressAction()
    {
        m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
        m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
        m_pawn.m_bInteractingWithDevice = true;
        m_pawn.m_eDeviceAnim = R6IOFloppy(m_RequestedCircumstantialAction.aQueryTarget).m_eAnimToPlay;
        MP2Rainbow(m_pawn).m_iCustomDeviceAnim = R6IOFloppy(m_RequestedCircumstantialAction.aQueryTarget).m_iMP2DeviceAnim;
        if(Level.NetMode != NM_Client)
        {
            m_pawn.SetNextPendingAction(PENDING_InteractWithDevice);
        }
    }

    event AnimEnd(int iChannel)
    {
        if((iChannel == m_pawn.C_iBaseBlendAnimChannel) && m_pawn.m_bPostureTransition)
        {
            m_pawn.m_bPostureTransition = false;
            m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5);
            m_iPlayerCAProgress = 100;
            if((Level.NetMode != NM_Standalone) && Level.NetMode != NM_Client)
            {
                ClientActionProgressDone();
            }
            if(m_InteractionCA != none)
            {
                m_InteractionCA.ActionProgressDone();
            }
            GotoState('PlayerWalking');
        }
        else
        {
            if((iChannel == m_pawn.C_iWeaponRightAnimChannel) && int(m_pawn.m_eEquipWeapon) == int(m_pawn.eEquipWeapon.EQUIP_NoWeapon))
            {
                m_pawn.m_bWeaponTransition = false;
                StartProgressAction();
            }
        }
    }

    function EndState()
    {
        m_bDisplayActionProgress = false;
        if(m_pawn != none)
        {
            m_pawn.m_bPostureTransition = false;
            m_pawn.m_bIsLockPicking = false;
            m_pawn.m_bInteractingWithDevice = false;
            m_pawn.m_ePlayerIsUsingHands = HANDS_None;
            if(m_pawn.EngineWeapon != none)
            {
                m_pawn.EngineWeapon.GotoState('BringWeaponUp');
                if(Level.NetMode != NM_Client)
                {
                    m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
                }
            }
            if(((Role == ROLE_Authority) && !m_pawn.IsAlive()) && m_iPlayerCAProgress < 105)
            {
                m_RequestedCircumstantialAction.aQueryTarget.R6CircumstantialActionCancel();
            }
        }
        m_iPlayerCAProgress = 0;
    }

    event Tick(float fDeltaTime)
    {
        if((m_pawn.EngineWeapon != none) && int(m_pawn.m_eEquipWeapon) != int(m_pawn.eEquipWeapon.EQUIP_NoWeapon))
        {
            return;
        }
        if(!m_pawn.m_bIsLockPicking && !m_pawn.m_bInteractingWithDevice)
        {
            return;
        }
        if(Role == ROLE_Authority)
        {
            m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress(m_PlayerCurrentCA, m_pawn);
        }
    }
}

state PlayerActionProgress
{
    function StartProgressAction()
    {
        m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
        if(m_RequestedCircumstantialAction.aQueryTarget.IsA('R6IOObject'))
        {
            if(m_RequestedCircumstantialAction.aQueryTarget.IsA('mp2ioprovider'))
            {
                m_pawn.m_bInteractingWithDevice = true;
                m_pawn.m_eDeviceAnim = mp2ioprovider(m_RequestedCircumstantialAction.aQueryTarget).m_eAnimToPlay;
                MP2Rainbow(m_pawn).m_iCustomDeviceAnim = mp2ioprovider(m_RequestedCircumstantialAction.aQueryTarget).m_iMP2DeviceAnim;
                if(Level.NetMode != NM_Client)
                {
                    m_pawn.SetNextPendingAction(PENDING_InteractWithDevice);
                }
            }
            else
            {
                m_pawn.m_bInteractingWithDevice = true;
                m_pawn.m_eDeviceAnim = R6IOObject(m_RequestedCircumstantialAction.aQueryTarget).m_eAnimToPlay;
                if(Level.NetMode != NM_Client)
                {
                    m_pawn.SetNextPendingAction(PENDING_InteractWithDevice);
                }
            }
        }
        else
        {
            if(m_RequestedCircumstantialAction.aQueryTarget.IsA('R6IORotatingDoor'))
            {
                m_pawn.m_bIsLockPicking = true;
                if(Level.NetMode != NM_Client)
                {
                    m_pawn.SetNextPendingAction(PENDING_LockPickDoor);
                }
            }
        }
    }
}

defaultproperties
{
    m_sndBoucleStress=Sound'SFX_MdeGazAlrt.Play_AlertGaz'
    m_sndBoucleStressStop=Sound'SFX_MdeGazAlrt.Stop_AlertGaz'
    m_sndBoucleBaisse=Sound'SFX_MdeGazAlrt.Play_DegradNiveauR'
    m_sndBoucleBaisseStop=Sound'SFX_MdeGazAlrt.Stop_DegradNiveauR'
}
