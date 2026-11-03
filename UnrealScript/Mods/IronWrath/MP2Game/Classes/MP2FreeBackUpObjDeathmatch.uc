class MP2FreeBackUpObjDeathmatch extends R6MObjDeathmatch
    editinlinenew;

function PawnKilled(Pawn killedPawn)
{
    local MP2Rainbow pPawn;
    local int aPlayerAliveInTeam[2], iNbAlive;

    ResetLivingPlayerInTeam();
    foreach m_mgr.DynamicActors(Class'MP2Game.MP2Rainbow', pPawn)
    {
        if(pPawn.m_iTeam == pPawn.c_iTeamNumFreeBackup)
        {
            continue;
        }
        if((pPawn.Controller != none) && pPawn.Controller.IsA('MP2PlayerController'))
        {
            if(pPawn.IsAlive())
            {
                ++iNbAlive;
                if(m_bTeamDeathmatch)
                {
                    if(pPawn.m_iTeam < 48)
                    {
                        ++m_aLivingPlayerInTeam[pPawn.m_iTeam];
                    }
                }
                if(m_bShowLog)
                {
                    if(PlayerController(pPawn.Controller).PlayerReplicationInfo != none)
                    {
                        logX((PlayerController(pPawn.Controller).PlayerReplicationInfo.PlayerName $ " is alive in teamID") $ string(pPawn.m_iTeam));
                    }
                    else
                    {
                        logX((string(PlayerController(pPawn.Controller)) $ " is alive in teamID") $ string(pPawn.m_iTeam));
                    }
                }
                m_winnerCtrl = PlayerController(pPawn.Controller);
            }
            else
            {
                if(m_bShowLog)
                {
                    if(PlayerController(pPawn.Controller).PlayerReplicationInfo != none)
                    {
                        logX(PlayerController(pPawn.Controller).PlayerReplicationInfo.PlayerName $ " is dead");
                    }
                    else
                    {
                        logX(string(PlayerController(pPawn.Controller)) $ " is dead");
                    }
                }
            }
        }
        if(!m_bTeamDeathmatch)
        {
            if(iNbAlive > 1)
            {
                if(m_bShowLog)
                {
                    logX("more than 1 player alive ");
                }
                break;
            }
        }
    }
    if(iNbAlive == 0)
    {
        if(m_bShowLog)
        {
            logX("failed: zero man standing");
        }
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
        return;
    }
    if(m_bTeamDeathmatch)
    {
        m_iWinningTeam = GetWinningTeam();
        if(m_iWinningTeam != -1)
        {
            if(m_bShowLog)
            {
                logX("completed, last team standing teamID=" $ string(m_iWinningTeam));
            }
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
        }
        else
        {
            if(m_bShowLog)
            {
                logX("no winner yet");
            }
        }
    }
    else
    {
        if(iNbAlive == 1)
        {
            if(m_bShowLog)
            {
                logX("completed, one man standing");
            }
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
        }
        else
        {
            if(m_bShowLog)
            {
                logX("no winner yet");
            }
            m_winnerCtrl = none;
        }
    }
}

defaultproperties
{
    m_bShowLog=true
}
