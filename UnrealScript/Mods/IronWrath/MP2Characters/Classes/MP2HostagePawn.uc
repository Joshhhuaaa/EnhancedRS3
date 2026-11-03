class MP2HostagePawn extends R6HostagePawn;

function R6Died(Pawn Killer, R6Pawn.eBodyPart eHitPart, Vector vMomentum)
{
    local R6AbstractGameInfo pGameInfo;
    local int i;
    local R6PlayerController P;
    local R6AbstractWeapon AWeapon;
    local string KillerName, szPlayerName;

    if(Killer == none)
    {
        log(" R6Died() : WARNING : Killer=none");
    }
    if(Killer.PlayerReplicationInfo != none)
    {
        KillerName = Killer.PlayerReplicationInfo.PlayerName;
    }
    else
    {
        KillerName = Killer.m_CharacterName;
    }
    if(m_bIsClimbingLadder || Physics == PHYS_Ladder)
    {
        if((m_Ladder == none) || m_Ladder.MyLadder == none)
        {
            log(((" R6Died() : WARNING : m_Ladder=" $ string(m_Ladder)) $ " m_Ladder.myLadder=") $ string(m_Ladder.MyLadder));
        }
        R6LadderVolume(m_Ladder.MyLadder).RemoveClimber(self);
        if(m_bIsPlayer && m_Ladder != none)
        {
            R6LadderVolume(m_Ladder.MyLadder).DisableCollisions(m_Ladder);
        }
    }
    if(Physics == PHYS_RootMotion)
    {
        if(Controller != none)
        {
            Controller.GotoState('None');
        }
        if(bIsCrouched)
        {
            PlayPostRootMotionAnimation(m_crouchDefaultAnimName);
        }
        else
        {
            PlayPostRootMotionAnimation(m_standDefaultAnimName);
        }
    }
    AWeapon = R6AbstractWeapon(EngineWeapon);
    if((AWeapon != none) && AWeapon.m_SelectedWeaponGadget != none)
    {
        AWeapon.m_SelectedWeaponGadget.ActivateGadget(false);
    }
    if(vMomentum == vect(0.0, 0.0, 0.0))
    {
        vMomentum = vect(1.0, 1.0, 1.0);
    }
    TearOffMomentum = vMomentum;
    bAlwaysRelevant = true;

    for(i = 0; i <= 3; i++)
    {
        if(m_WeaponsCarried[i] != none)
        {
            m_WeaponsCarried[i].SetRelevant(true);
        }
    }
    m_bUseRagdoll = true;
    bProjTarget = false;
    SpawnRagDoll();
    m_KilledBy = R6Pawn(Killer);
    if(ProcessBuildDeathMessage(Killer, szPlayerName))
    {
        foreach DynamicActors(Class'R6Engine.R6PlayerController', P)
        {
            P.ClientDeathMessage(KillerName, szPlayerName, m_bSuicideType);
        }
    }
    if(m_KilledBy == none)
    {
        log("  R6Died() : Warning!!  m_KilledBy=" $ string(m_KilledBy));
    }
    if(m_KilledBy == self)
    {
        m_bSuicided = true;
    }
    else
    {
        if(IsEnemy(m_KilledBy))
        {
            m_KilledBy.IncrementFragCount();
        }
    }
    if(R6PlayerController(Controller) != none)
    {
        R6PlayerController(Controller).ClientDisableFirstPersonViewEffects();
        R6PlayerController(Controller).PlayerReplicationInfo.m_szKillersName = KillerName;
    }
    pGameInfo = R6AbstractGameInfo(Level.Game);
    if(pGameInfo != none)
    {
        if((pGameInfo.m_bCompilingStats == true) || (pGameInfo.m_bGameOver && pGameInfo.m_bGameOverButAllowDeath))
        {
            if(Controller.PlayerReplicationInfo != none)
            {
                Controller.PlayerReplicationInfo.Deaths += 1.0;
                if(((!m_bSuicided && m_KilledBy != none) && m_KilledBy.Controller != none) && m_KilledBy.Controller.PlayerReplicationInfo != none)
                {
                    m_KilledBy.Controller.PlayerReplicationInfo.Score += 1.0;
                }
            }
            else
            {
                P = R6PlayerController(GetHumanLeaderForAIPawn());
                if(P != none)
                {
                    P.PlayerReplicationInfo.Deaths += 1.0;
                }
            }
        }
        pGameInfo.PawnKilled(self);
        if(!(Level.Game.m_szGameTypeFlag == "RGM_LimitSeatsAdvMode"))
        {
            pGameInfo.SetTeamKillerPenalty(self, Killer);
        }
    }
}

defaultproperties
{
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel430
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
        Name="KarmaParamsSkel430"
    End Object
    KParams=KarmaParamsSkel'MP2Characters.KarmaParamsSkel430'
}
