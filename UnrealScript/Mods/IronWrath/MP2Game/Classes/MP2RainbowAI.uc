class MP2RainbowAI extends R6RainbowAI
    native;

enum eRainbowOrder
{
    ROrder_None,                    // 0
    ROrder_None1,                   // 1
    ROrder_None2,                   // 2
    ROrder_None3,                   // 3
    ROrder_None4,                   // 4
    ROrder_None5,                   // 5
    ROrder_None6,                   // 6
    ROrder_None7,                   // 7
    ROrder_None8,                   // 8
    ROrder_None9,                   // 9
    ROrder_None10,                  // 10
    ROrder_ComeWithMe,              // 11
    ROrder_StayHere                 // 12
};

var bool m_bFBISWainting;
var bool m_bFBSkinUpdated;

function DispatchOrder(int iOrder, optional R6RainbowTeam teamManager)
{
    switch(iOrder)
    {
        case eRainbowOrder.ROrder_ComeWithMe:
            if(m_bFBISWainting)
            {
                m_bFBISWainting = false;
                Order_FollowMe(teamManager, true);
            }
            break;
        case eRainbowOrder.ROrder_StayHere:
            if(!m_bFBISWainting)
            {
                m_bFBISWainting = true;
                Order_StayHere(true);
            }
            break;
        default:
            m_pawn.logWarning("unknow eFreeBackupCircumstantialAction " $ string(iOrder));
    }
}

function Order_FollowMe(R6RainbowTeam teamManager, bool bOrderedByRainbow)
{
    m_TeamManager = teamManager;
    m_TeamManager.m_Team[m_TeamManager.m_iMemberCount] = m_pawn;
    m_TeamManager.m_TeamLeader = m_TeamManager.m_Team[0];
    m_pawn.m_iID = m_TeamManager.m_iMemberCount;
    m_pawn.m_iPermanentID = m_pawn.m_iID;
    m_TeamManager.m_iMemberCount++;
    m_pawn.m_CharacterName = ((m_TeamManager.m_Team[0].PlayerReplicationInfo.PlayerName $ "'s") $ " ") $ (Localize("Game", "Fighter", "IronWrathGameInfo"));
    FreeBackupSetMemberTeamID(m_pawn, m_TeamManager.m_Team[0].m_iTeam);
    m_TeamManager.ResetNeutralFighterTeam();
    if(m_TeamManager.m_TeamLeader != none)
    {
        m_TeamLeader = m_TeamManager.m_TeamLeader;
        GotoState('FreeBackupFollowLeader');
    }
}

function Order_StayHere(bool bOrderedByRainbow)
{
    GotoState('FreeBackupWait');
}

function FragGrenadeInProximity(Vector vGrenadeLocation, float fTimeLeft, float fGrenadeDangerRadius)
{
    if(m_pawn.m_bIsClimbingLadder || IsInState('RunAwayFromGrenade'))
    {
        return;
    }
    if(CanSeeGrenade(vGrenadeLocation))
    {
        if(m_TeamManager != none)
        {
            m_TeamManager.GrenadeInProximity(m_pawn, vGrenadeLocation, fTimeLeft, fGrenadeDangerRadius);
        }
        else
        {
            FreeBackupReactToFragGrenade(vGrenadeLocation, fTimeLeft, fGrenadeDangerRadius);
        }
    }
}

function FreeBackupReactToFragGrenade(Vector vGrenadeLocation, float fTimeLeft, float fGrenadeDangerRadius)
{
    if((m_pawn.m_bIsClimbingLadder || Pawn.Physics == PHYS_Ladder) || VSize(vGrenadeLocation - Pawn.Location) > fGrenadeDangerRadius)
    {
        return;
    }
    m_vGrenadeLocation = vGrenadeLocation;
    m_fGrenadeDangerRadius = fGrenadeDangerRadius;
    GotoState('FreeBackupRunAwayFromGrenade');
}

function UpdateFighterSkin(int iTeam)
{
    local int iFaceIndex;
    local string aFaceTexture;

    iFaceIndex = m_pawn.m_iOperativeID;
    switch(iFaceIndex)
    {
        case 100:
            if(iTeam == 2)
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterG1";
            }
            else
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterR1";
            }
            m_bFBSkinUpdated = true;
            break;
        case 101:
            if(iTeam == 2)
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterG2";
            }
            else
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterR2";
            }
            m_bFBSkinUpdated = true;
            break;
        case 102:
            if(iTeam == 2)
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterG3";
            }
            else
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterR3";
            }
            m_bFBSkinUpdated = true;
            break;
        case 103:
            if(iTeam == 2)
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterG4";
            }
            else
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterR4";
            }
            m_bFBSkinUpdated = true;
            break;
        case 104:
            if(iTeam == 2)
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterG5";
            }
            else
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterR5";
            }
            m_bFBSkinUpdated = true;
            break;
        case 105:
            if(iTeam == 2)
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterG6";
            }
            else
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterR6";
            }
            m_bFBSkinUpdated = true;
            break;
        default:
            if(iTeam == 2)
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterG1";
            }
            else
            {
                aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterR1";
            }
            m_bFBSkinUpdated = true;
    }
    MP2Rainbow(m_pawn).SetSkin(Texture(DynamicLoadObject(aFaceTexture, Class'Engine.Texture')), 0);
}

function UpdateNeutralSkin()
{
    local int iFaceIndex;
    local string aFaceTexture;

    iFaceIndex = m_pawn.m_iOperativeID;
    switch(iFaceIndex)
    {
        case 100:
            aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterN1";
            break;
        case 101:
            aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterN2";
            break;
        case 102:
            aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterN3";
            break;
        case 103:
            aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterN4";
            break;
        case 104:
            aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterN5";
            break;
        case 105:
            aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterN6";
            break;
        default:
            aFaceTexture = "MP2Characters_T.NeutralFighter.NeutralFighterN1";
    }
    m_bFBSkinUpdated = false;
    MP2Rainbow(m_pawn).SetSkin(Texture(DynamicLoadObject(aFaceTexture, Class'Engine.Texture')), 0);
}

function EndAttack()
{
    m_pawn.m_bEngaged = false;
    if(m_TeamManager != none)
    {
        m_TeamManager.DisEngageEnemy(Pawn, Enemy);
    }
    Enemy = none;
    Target = none;
    if(IsMoving(Pawn))
    {
        if(MoveTarget != none)
        {
            Focus = MoveTarget;
        }
    }
}

function FreeBackupPromote()
{
    m_TeamLeader = m_TeamManager.m_TeamLeader;
    if(m_TeamLeader == none)
    {
        m_TeamManager = none;
        FreeBackupSetMemberTeamID(m_pawn, 7);
        if(!m_pawn.m_bIsClimbingLadder)
        {
            GotoState('FreeBackupWait');
            m_pawn.m_CharacterName = Localize("Game", "NeutralFighter", "IronWrathGameInfo");
        }
        else
        {
            NextState = 'FreeBackupWait';
            NextLabel = 'Begin';
            m_pawn.m_CharacterName = Localize("Game", "NeutralFighter", "IronWrathGameInfo");
        }
    }
    else
    {
        GotoState('FollowLeader');
    }
}

function FreeBackupSetMemberTeamID(R6Pawn aPawn, int iTeamId)
{
    MP2Rainbow(aPawn).m_iTeam = iTeamId;
    if(aPawn.PlayerReplicationInfo != none)
    {
        aPawn.PlayerReplicationInfo.TeamID = iTeamId;
    }
    R6AbstractGameInfo(Level.Game).SetPawnTeamFriendlies(aPawn);
}

state FreeBackupWait
{
    ignores AttackTimer;

    function BeginState()
    {
        m_bFBISWainting = true;
        m_bIgnoreBackupBump = true;
        NextState = 'None';
        NextLabel = 'None';
        StopFiring();
        EndAttack();
    }

    function EndState()
    {
        m_bIgnoreBackupBump = false;
        if(m_pawn.IsAlive())
        {
            NFTeamManager();
        }
    }

    function NFTeamManager()
    {
        if(m_TeamManager != none)
        {
            m_TeamManager.m_Team[m_pawn.m_iID] = none;
        }
        switch(m_pawn.m_iID)
        {
            case 1:
                if((m_TeamManager != none) && m_TeamManager.m_Team[2] != none)
                {
                    m_TeamManager.m_Team[1] = m_TeamManager.m_Team[2];
                    m_TeamManager.m_Team[1].m_iID = 1;
                    m_TeamManager.m_Team[2] = none;
                }
                if((m_TeamManager != none) && m_TeamManager.m_Team[3] != none)
                {
                    m_TeamManager.m_Team[2] = m_TeamManager.m_Team[3];
                    m_TeamManager.m_Team[2].m_iID = 2;
                    m_TeamManager.m_Team[3] = none;
                }
                break;
            case 2:
                if((m_TeamManager != none) && m_TeamManager.m_Team[3] != none)
                {
                    m_TeamManager.m_Team[2] = m_TeamManager.m_Team[3];
                    m_TeamManager.m_Team[2].m_iID = 2;
                    m_TeamManager.m_Team[3] = none;
                }
                break;
        }
        m_TeamLeader = none;
        m_pawn.m_iID = -1;
        if(m_TeamManager != none)
        {
            m_TeamManager.m_iMemberCount--;
            m_TeamManager.ResetNeutralFighterTeam();
        }
        m_TeamManager = none;
        m_pawn.m_CharacterName = Localize("Game", "NeutralFighter", "IronWrathGameInfo");
        FreeBackupSetMemberTeamID(m_pawn, 7);
    }
Begin:
    if(Pawn.bIsCrouched)
    {
        Pawn.bWantsToCrouch = false;
        Sleep(0.5);

        while(m_pawn.m_bPostureTransition)
        {
            Sleep(0.5);
        }
    }
    FinishAnim(m_pawn.C_iWeaponRightAnimChannel);
    Pawn.Acceleration = vect(0.0, 0.0, 0.0);
    m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
    FinishAnim(m_pawn.C_iWeaponRightAnimChannel);
    Pawn.bWantsToCrouch = true;
    UpdateNeutralSkin();
    GotoState('FreeBackupWaiting');
}

state FreeBackupWaiting
{
    ignores AttackTimer;

    function BeginState()
    {
    }

    function EndState()
    {
    }
Begin:
    Sleep(0.5);
    if(Pawn != none)
    {
        if(!Pawn.bIsCrouched)
        {
            Pawn.bWantsToCrouch = true;
        }
        if(Level.Game.m_bGameStarted && NextState != 'None')
        {
            if(m_pawn.m_iID == 0)
            {
                Sleep(1.0);
            }
            GotoState(NextState);
        }
        else
        {
            goto 'Begin';
        }
    }
}

state FreeBackupFollowLeader
{
    ignores AttackTimer;

    function BeginState()
    {
        m_bIgnoreBackupBump = true;
    }

    function EndState()
    {
        m_bIgnoreBackupBump = false;
        m_TeamManager.ResetNeutralFighterTeam();
    }
Begin:
    FinishAnim(m_pawn.C_iWeaponRightAnimChannel);
    Pawn.bWantsToCrouch = false;
    m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
    FinishAnim(m_pawn.C_iWeaponRightAnimChannel);
    UpdateFighterSkin(m_TeamManager.m_Team[0].m_iTeam);
    GotoState('FollowLeader');
}

state FreeBackupRunAwayFromGrenade
{
    function BeginState()
    {
        m_bIgnoreBackupBump = true;
    }

    function EndState()
    {
        m_bIgnoreBackupBump = false;
    }

    function Vector SafeLocation()
    {
        local Vector vDir, vLocation;

        vDir = Normal(Pawn.Location - m_vGrenadeLocation);
        vLocation = m_vGrenadeLocation + ((m_fGrenadeDangerRadius + float(600)) * vDir);
        vLocation.Z = Pawn.Location.Z;
        if(PointReachable(vLocation))
        {
            return vLocation;
        }
        vLocation = m_vGrenadeLocation - ((m_fGrenadeDangerRadius + float(600)) * vDir);
        vLocation.Z = Pawn.Location.Z;
        if(PointReachable(vLocation))
        {
            return vLocation;
        }
        return vect(0.0, 0.0, 0.0);
    }
Begin:
    m_vTargetPosition = SafeLocation();
    EnsureRainbowIsArmed();
    if(m_vTargetPosition != vect(0.0, 0.0, 0.0))
    {
        goto 'RunToDirectly';
    }
FindPathAway:
    MoveTarget = FindSafeSpot();
    if(MoveTarget != none)
    {
        if(NeedToOpenDoor(MoveTarget))
        {
            m_pawn.PlayDoorAnim(m_pawn.m_Door.m_RotatingDoor);
            Sleep(0.5);
            m_pawn.ServerPerformDoorAction(m_pawn.m_Door.m_RotatingDoor, m_pawn.m_Door.m_RotatingDoor.eDoorCircumstantialAction.CA_Open);
        }
        R6PreMoveToward(MoveTarget, MoveTarget, PACE_Run);
        MoveToward(MoveTarget);
        if(m_eMoveToResult == eMoveTo_failed)
        {
            Sleep(0.5);
        }
        if(VSize(m_vGrenadeLocation - Pawn.Location) > (m_fGrenadeDangerRadius + float(300)))
        {
            goto 'Wait';
        }
        goto 'FindPathAway';
    }
    goto 'Wait';
RunToDirectly:
    R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Run);
    MoveTo(m_vTargetPosition);
Wait:
    StopMoving();
    GotoState('FreeBackupWait');
}

state HoldPosition
{Begin:

    if((m_TeamManager != none) && m_r6pawn.m_iTeam == 7)
    {
        m_TeamManager.ResetNeutralFighterTeam();
        GotoState('FollowLeader');
    }
    m_TeamManager.SetTeamState(TS_Holding);
    Focus = none;
    m_iWaitCounter = 0;
    Pawn.Acceleration = vect(0.0, 0.0, 0.0);
    SetTimer(1.0, true);
    Sleep(1.0);
Hold:
    VerifyWeaponInventory();
    EnsureRainbowIsArmed();
    if((!Pawn.bIsCrouched && !Pawn.m_bIsProne) && float(m_iWaitCounter) > 8.0)
    {
        Pawn.bWantsToCrouch = true;
        Sleep(0.5);
    }
    if(NeedToReload())
    {
        RainbowReloadWeapon();
    }
    Sleep(1.0);
    if(NextState != 'None')
    {
        GotoState(NextState);
    }
    goto 'Hold';
}

state FollowLeader
{
    function EndState()
    {
        m_bIgnoreBackupBump = false;
        m_bReactToNoise = false;
        if(m_TeamManager != none)
        {
            if(!m_TeamManager.m_bGrenadeInProximity)
            {
                SetTimer(0.0, false);
            }
        }
        m_pawn.StopPeeking();
        m_pawn.m_u8DesiredYaw = 0;
        if(m_TeamManager != none)
        {
            if((!m_TeamManager.m_bLeaderIsAPlayer && m_TeamManager.m_bTeamIsRegrouping) && m_PaceMember == m_TeamLeader)
            {
                m_TeamManager.TeamIsRegroupingOnLead(false);
            }
        }
        if((m_TeamManager != none) && m_r6pawn.m_iTeam == 7)
        {
            m_TeamManager.ResetNeutralFighterTeam();
        }
    }

    function Timer()
    {
        m_iWaitCounter++;
        m_iTurn++;
        if(m_iTurn == 6)
        {
            m_iTurn = 0;
        }
        if((((m_pawn.m_iID == 1) || m_pawn.m_iID == 2) && IsMoving(Pawn)) && m_ePawnOrientation != PO_Back)
        {
            CheckEnvironment();
        }
        if(m_bIsCatchingUp)
        {
            m_pawn.ResetBoneRotation();
        }
        else
        {
            if((m_TeamManager != none) && m_r6pawn.m_iTeam != 7)
            {
                SetRainbowOrientation();
            }
        }
    }
Begin:
    if(m_PaceMember == none)
    {
        if((m_TeamLeader != none) && m_TeamManager != none)
        {
            m_PaceMember = m_TeamManager.m_Team[m_pawn.m_iID - 1];
        }
    }
    m_TeamManager.SetFormation(self);
    SetTimer(1.0, true);
    VerifyWeaponInventory();
    EnsureRainbowIsArmed();
    if(!m_pawn.IsStationary() && SniperChangeToSecondaryWeapon())
    {
        Sleep(0.5);
    }
Moving:
    if(((m_TeamManager != none) && m_TeamManager.m_Team[0].Controller.IsA('MP2PlayerController')) && MP2PlayerController(m_TeamManager.m_Team[0].Controller).GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode")
    {
        if(m_bFBSkinUpdated == false)
        {
            UpdateFighterSkin(m_TeamManager.m_Team[0].m_iTeam);
        }
    }
    if(NeedToReload())
    {
        RainbowReloadWeapon();
    }
    if(m_bIsCatchingUp)
    {
        m_bIsCatchingUp = false;
    }
    if((m_PaceMember == m_TeamLeader) && m_TeamLeader.m_bIsPlayer)
    {
        m_TeamManager.SetTeamState(TS_Following);
    }
    if(m_bReorganizationPending)
    {
        ReorganizeTeamAsNeeded();
    }
    m_vTargetPosition = GetNextTargetPosition();
    if(RainbowShouldWait())
    {
        Pawn.Acceleration = vect(0.0, 0.0, 0.0);
        if(!m_bAlreadyWaiting)
        {
            m_iWaitCounter = 0;
            m_pawn.ResetBoneRotation();
            m_pawn.StopPeeking();
            EnsureRainbowIsArmed();
            if(((m_ePawnOrientation == PO_Back) && !m_bIsMovingBackwards) && !Pawn.m_bIsProne)
            {
                Sleep(0.2);
                m_bIsMovingBackwards = true;
                SetLocation(Pawn.Location - (float(2) * (m_PaceMember.Location - Pawn.Location)));
                Focus = self;
            }
            m_bAlreadyWaiting = true;
        }
        if(VSize(m_TeamLeader.Velocity) == float(0))
        {
            if((m_iWaitCounter > 6) && !m_TeamManager.m_bTeamIsClimbingLadder)
            {
                if(SniperChangeToPrimaryWeapon())
                {
                    FinishAnim(m_pawn.C_iWeaponRightAnimChannel);
                }
                if(!Pawn.bIsCrouched && !Pawn.m_bIsProne)
                {
                    m_pawn.StopPeeking();
                    Pawn.bWantsToCrouch = true;
                    Sleep(0.2);
                }
            }
        }
        Sleep(0.2);
        goto 'Moving';
    }
    m_vPreviousPosition = m_vTargetPosition;
    if(m_bAlreadyWaiting)
    {
        m_pawn.StopPeeking();
        Sleep(0.2);
        if(SniperChangeToSecondaryWeapon())
        {
            Sleep(0.5);
        }
    }
    m_bAlreadyWaiting = false;
    if(!CanWalkTo(m_vTargetPosition) && !PointReachable(m_vTargetPosition))
    {
        goto 'bLocked';
    }
    if(m_PaceMember == m_TeamLeader)
    {
        m_TeamManager.TeamIsSeparatedFromLead(false);
        m_TeamManager.TeamIsRegroupingOnLead(false);
    }
    if(((m_ePawnOrientation != PO_Back) || Pawn.m_bIsProne) || m_PaceMember.m_bIsProne)
    {
        m_bIsMovingBackwards = false;
        R6PreMoveTo(m_vTargetPosition, m_vTargetPosition);
        SetLocation(m_vTargetPosition);
    }
    else
    {
        if((m_PaceMember.IsWalking() && m_iTurn > 2) && (DistanceTo(m_PaceMember)) < ((GetFormationDistance()) + float(120)))
        {
            m_bIsMovingBackwards = true;
            SetLocation(Pawn.Location - (float(2) * (m_PaceMember.Location - Pawn.Location)));
            R6PreMoveTo(m_vTargetPosition, Location, GetPace(true));
        }
        else
        {
            m_bIsMovingBackwards = false;
            SetLocation(m_vTargetPosition);
            if(m_PaceMember.bIsCrouched && (DistanceTo(m_PaceMember)) > ((GetFormationDistance()) + float(40)))
            {
                R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_CrouchRun);
            }
            else
            {
                R6PreMoveTo(m_vTargetPosition, m_vTargetPosition);
            }
        }
    }
    if(PostureHasChanged())
    {
        Sleep(0.5);

        while(m_pawn.m_bPostureTransition)
        {
            Sleep(0.5);
        }
    }
    MoveTo(m_vTargetPosition, self);
    if(m_eMoveToResult == eMoveTo_failed)
    {
        goto 'bLocked';
    }
    else
    {
        goto 'Moving';
    }
bLocked:
    m_bIsCatchingUp = true;
    if(m_PaceMember == m_TeamLeader)
    {
        m_TeamManager.TeamIsRegroupingOnLead(true);

        while((DistanceTo(m_TeamManager.m_Team[m_TeamManager.m_iMemberCount - 1])) > float(600))
        {
            Sleep(0.5);
        }
    }
    m_pawn.StopPeeking();
    m_ePawnOrientation = PO_Front;
    if(NeedToReload())
    {
        RainbowReloadWeapon();
    }
    MoveTarget = FindPathToward(m_PaceMember, true);
    if(MoveTarget == none)
    {
        m_pawn.logWarning(("is at location " $ string(Pawn.Location)) $ " and there appear to be insufficient pathnodes...");
        MoveTo(Pawn.Location + (Normal(m_PaceMember.Location - Pawn.Location) * float(100)));
        Sleep(1.0);
        goto 'bLocked';
    }
    if(MoveTarget == m_PaceMember)
    {

        while(m_PaceMember.m_bIsClimbingLadder)
        {
            Sleep(1.0);
        }
        EngageLadderIfNeeded(R6LadderVolume(m_TargetLadder.MyLadder));
    }
    m_TargetLadder = R6Ladder(MoveTarget);
    if(TargetIsLadderToClimb(m_TargetLadder))
    {
        m_pawn.m_potentialActionActor = m_TargetLadder.MyLadder;
        m_TeamManager.InstructTeamToClimbLadder(R6LadderVolume(m_TargetLadder.MyLadder), true, m_pawn.m_iID);
    }
    else
    {
        if(NeedToOpenDoor(MoveTarget))
        {
            m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
            MoveToPosition(m_pawn.m_Door.Location, m_pawn.m_Door.Rotation);
            Pawn.Acceleration = vect(0.0, 0.0, 0.0);
            SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
            Sleep(1.0);
            GotoStateLeadRoomEntry();
        }
    }
    if(m_PaceMember.bIsCrouched)
    {
        R6PreMoveToward(MoveTarget, MoveTarget, PACE_CrouchRun);
    }
    else
    {
        if(m_pawn.m_eHealth == HEALTH_Wounded)
        {
            R6PreMoveToward(MoveTarget, MoveTarget, PACE_Walk);
        }
        else
        {
            R6PreMoveToward(MoveTarget, MoveTarget, PACE_Run);
        }
    }
    if(MoveTarget.IsA('R6Ladder'))
    {
        Pawn.bIsWalking = true;
    }
    MoveToward(MoveTarget);
    if(!CanWalkTo(m_PaceMember.Location) && !ActorReachable(m_PaceMember))
    {
        goto 'bLocked';
    }
    else
    {
        goto 'Moving';
    }
}

state EndClimbingLadder
{End:

    if(m_r6pawn.m_Ladder.m_bIsTopOfLadder)
    {
        Destination = Pawn.Location + (float(120) * Pawn.OnLadder.LookDir);
        R6PreMoveTo(Destination, Destination, PACE_Walk);
        MoveTo(Destination);
    }
    else
    {
        Destination = Pawn.Location - (float(120) * Pawn.OnLadder.LookDir);
        R6PreMoveTo(Destination, Pawn.OnLadder.Location, PACE_Walk);
        MoveTo(Destination, Pawn.OnLadder);
    }
    StopMoving();
    if(m_r6pawn.m_ePawnType == PAWN_Rainbow)
    {
        if(!m_bGetOffLadder)
        {
            if(MP2RainbowAI(Pawn.Controller).m_TeamManager != none)
            {
                MP2RainbowAI(Pawn.Controller).m_TeamManager.MemberFinishedClimbingLadder(m_r6pawn);
            }
        }
    }
    else
    {
        if(m_r6pawn.m_ePawnType == PAWN_Hostage)
        {
            ClimbLadderIsOver();
        }
    }
    if(m_bGetOffLadder)
    {
        m_bGetOffLadder = false;
        GotoState('WaitToClimbLadder');
    }
    else
    {
        if(NextState != 'None')
        {
            GotoState(NextState, NextLabel);
        }
        else
        {
            GotoState('Dispatcher');
        }
    }
}

defaultproperties
{
    m_bFBISWainting=true
}
