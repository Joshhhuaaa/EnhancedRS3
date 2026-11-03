class MP2InteractionCircumstantialAction extends R6InteractionCircumstantialAction;

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons

function ActionProgressStart()
{
    if(!R6Pawn(m_Player.Pawn).CanInteractWithObjects())
    {
        return;
    }
    m_Player.m_PlayerCurrentCA = m_Player.m_RequestedCircumstantialAction;
    GotoState('ActionProgress');
    m_Player.ServerPlayerActionProgress();
    if(m_Player.m_PlayerCurrentCA.aQueryTarget.IsA('R6Terrorist'))
    {
        m_Player.GotoState('PlayerSecureTerrorist');
    }
    else
    {
        if(class'Actor'.static.GetModMgr().IsMissionPack() && m_Player.m_PlayerCurrentCA.aQueryTarget.IsA('MP2Rainbow'))
        {
            m_Player.GotoState('PlayerInteractWithPlayer');
        }
        else
        {
            if(class'Actor'.static.GetModMgr().IsMissionPack() && m_Player.m_PlayerCurrentCA.aQueryTarget.IsA('R6IOFloppy'))
            {
                m_Player.GotoState('PlayerActionFloppyProgress');
            }
            else
            {
                m_Player.GotoState('PlayerActionProgress');
            }
        }
    }
}

function PerformCircumstantialAction(R6InteractionCircumstantialAction.eCircumstantialActionPerformer ePerformer)
{
    if(m_Player.m_RequestedCircumstantialAction == none)
    {
        return;
    }
    if(m_iCurrentSubMnuChoice != -1)
    {
        m_Player.m_RequestedCircumstantialAction.iMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentSubMnuChoice]);
        m_Player.m_RequestedCircumstantialAction.iSubMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamSubActionsIDList[(m_iCurrentSubMnuChoice * 4) + m_iCurrentMnuChoice]);
    }
    else
    {
        if(m_iCurrentMnuChoice != -1)
        {
            m_Player.m_RequestedCircumstantialAction.iMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentMnuChoice]);
            m_Player.m_RequestedCircumstantialAction.iSubMenuChoice = -1;
        }
    }
    switch(ePerformer)
    {
        case CACTION_Player:
            if(m_Player.m_RequestedCircumstantialAction.bCanBeInterrupted)
            {
                ActionProgressStart();
            }
            else
            {
                m_Player.m_pawn.ActionRequest(m_Player.m_RequestedCircumstantialAction);
            }
            break;
        case CACTION_Team:
            if(!(m_Player.GameReplicationInfo.m_szGameTypeFlagRep == "RGM_FreeBackupAdvMode"))
            {
                m_Player.m_TeamManager.TeamActionRequest(m_Player.m_RequestedCircumstantialAction);
            }
            break;
        case CACTION_TeamFromList:
            m_Player.m_TeamManager.TeamActionRequestFromRoseDesVents(m_Player.m_RequestedCircumstantialAction, m_Player.m_RequestedCircumstantialAction.iMenuChoice, m_Player.m_RequestedCircumstantialAction.iSubMenuChoice);
            break;
        case CACTION_TeamFromListZulu:
            m_Player.m_TeamManager.TeamActionRequestWaitForZuluGoCode(m_Player.m_RequestedCircumstantialAction, m_Player.m_RequestedCircumstantialAction.iMenuChoice, m_Player.m_RequestedCircumstantialAction.iSubMenuChoice);
            break;
    }
}

function DrawCircumstantialActionInfo(Canvas C)
{
    local R6CircumstantialActionQuery Query;
    local int iMnuChoice, iSubMenu;
    local bool bHasAction;
    local Color TeamColor;
    local R6GameOptions GameOptions;

    if(m_Player == none)
    {
        return;
    }
    if(m_Player.m_CurrentCircumstantialAction == none)
    {
        return;
    }
    GameOptions = class'Actor'.static.GetGameOptions();
    bHasAction = int(m_Player.m_CurrentCircumstantialAction.iHasAction) == 1;
    Query = m_Player.m_CurrentCircumstantialAction;
    C.Style = 5;
    if(m_Player.m_bDisplayMessage && GameOptions.HUDShowActionIcon)
    {
        C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
        C.SetPos(C.HalfClipX - float(24), C.ClipY - float(82));
        C.DrawTile(Texture'R6ActionIcons.SkipText', 48.0, 48.0, 0.0, 0.0, 32.0, 32.0);
        if((m_Player.m_iPlayerCAProgress > 0) || m_Player.m_bDisplayActionProgress)
        {
            SetPosAndDrawActionProgress(C);
        }
        return;
    }
    if(((m_Player.bOnlySpectator && !m_Player.bBehindView) && !m_Player.Level.m_bInGamePlanningActive) && (GameOptions.HUDShowReticule || m_Player.m_bShowCompleteHUD))
    {
        DrawSpectatorReticule(C);
    }
    if(m_Player.bOnlySpectator && (GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD))
    {
        if(m_Player.m_TeamManager != none)
        {
            TeamColor = m_Player.m_TeamManager.Colors.HUDWhite;
        }
        else
        {
            TeamColor = m_Player.m_SpectatorColor;
        }
        C.SetDrawColor(TeamColor.R, TeamColor.G, TeamColor.B, TeamColor.A);
        C.SetPos(C.HalfClipX - float(16), C.ClipY - float(74));
        C.DrawTile(Texture'R6ActionIcons.Spectator', 32.0, 32.0, 0.0, 0.0, 32.0, 32.0);
        return;
    }
    if(m_Player.m_TeamManager == none)
    {
        return;
    }
    if((m_Player.m_iPlayerCAProgress > 0) || m_Player.m_bDisplayActionProgress)
    {
        SetPosAndDrawActionProgress(C);
    }
    else
    {
        if(bHasAction && !m_Player.m_bAMenuIsDisplayed)
        {
            if(int(Query.iInRange) == 0)
            {
                if(!m_Player.CanIssueTeamOrder())
                {
                    if(m_Player.GameReplicationInfo.m_szGameTypeFlagRep == "RGM_VirusUploadAdvMode")
                    {
                        if(m_Player.Role == ROLE_Authority)
                        {
                            if(m_Player.m_CurrentCircumstantialAction.aQueryTarget.IsA('R6Rainbow'))
                            {
                                C.SetDrawColor(byte(255), byte(255), byte(255), 70);
                            }
                            else
                            {
                                return;
                            }
                        }
                    }
                    else
                    {
                        return;
                    }
                }
                TeamColor = m_Player.m_TeamManager.GetTeamColor();
                C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDGrey.R, m_Player.m_TeamManager.Colors.HUDGrey.G, m_Player.m_TeamManager.Colors.HUDGrey.B, m_Player.m_TeamManager.Colors.HUDGrey.A);
            }
            else
            {
                if(m_Player.Pawn != none)
                {
                    if(!R6Pawn(m_Player.Pawn).CanInteractWithObjects())
                    {
                        return;
                    }
                    C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
                    if(Query.aQueryTarget == m_Player)
                    {
                        if(!m_Player.CanIssueTeamOrder())
                        {
                            return;
                        }
                    }
                }
            }
            if(GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD)
            {
                C.SetPos(C.HalfClipX - float(16), C.ClipY - float(74));
                C.DrawTile(Query.textureIcon, 32.0, 32.0, 0.0, 0.0, 32.0, 32.0);
            }
        }
        else
        {
            if((bHasAction && bVisible) && int(Query.iInRange) == 0)
            {
                if(!m_Player.CanIssueTeamOrder())
                {
                    return;
                }
                DrawTeamActionMnu(C, Query);
            }
        }
    }
}
