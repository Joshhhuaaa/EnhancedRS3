class R6RainbowOtherTeamVoices extends R6Voices;

var Sound m_sndSniperHasTarget;
var Sound m_sndSniperLooseTarget;
var Sound m_sndSniperTangoDown;
var Sound m_sndMemberDown;
var Sound m_sndRainbowHitRainbow;
var Sound m_sndObjective1;
var Sound m_sndObjective2;
var Sound m_sndObjective3;
var Sound m_sndObjective4;
var Sound m_sndObjective5;
var Sound m_sndObjective6;
var Sound m_sndObjective7;
var Sound m_sndObjective8;
var Sound m_sndObjective9;
var Sound m_sndObjective10;
var Sound m_sndWaitAlpha;
var Sound m_sndWaitBravo;
var Sound m_sndWaitCharlie;
var Sound m_sndWaitZulu;
var Sound m_sndEntersSmoke;
var Sound m_sndEntersGas;
var Sound m_sndPlacingBug;
var Sound m_sndBugActivated;
var Sound m_sndAccessingComputer;
var Sound m_sndComputerHacked;
var Sound m_sndEscortingHostage;
var Sound m_sndHostageSecured;
var Sound m_sndPlacingExplosives;
var Sound m_sndExplosivesReady;
var Sound m_sndDesactivatingSecurity;
var Sound m_sndSecurityDeactivated;
var Sound m_sndStatusEngaging;
var Sound m_sndStatusMoving;
var Sound m_sndStatusWaiting;
var Sound m_sndStatusWaitAlpha;
var Sound m_sndStatusWaitBravo;
var Sound m_sndStatusWaitCharlie;
var Sound m_sndStatusWaitZulu;
var Sound m_sndStatusSniperWaitAlpha;
var Sound m_sndStatusSniperWaitBravo;
var Sound m_sndStatusSniperWaitCharlie;
var Sound m_sndStatusSniperUntilAlpha;
var Sound m_sndStatusSniperUntilBravo;
var Sound m_sndStatusSniperUntilCharlie;

function PlayRainbowOtherTeamVoices(R6Pawn aPawn, Pawn.ERainbowOtherTeamVoices eRainbowVoices)
{
    switch(eRainbowVoices)
    {
        case ROTV_SniperHasTarget:
            aPawn.PlayVoices(m_sndSniperHasTarget, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_SniperLooseTarget:
             aPawn.PlayVoices(m_sndSniperLooseTarget, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_SniperTangoDown:
             aPawn.PlayVoices(m_sndSniperTangoDown, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_MemberDown:
             aPawn.PlayVoices(m_sndMemberDown, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_RainbowHitRainbow:
             aPawn.PlayVoices(m_sndRainbowHitRainbow, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective1:
             aPawn.PlayVoices(m_sndObjective1, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective2:
             aPawn.PlayVoices(m_sndObjective2, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective3:
             aPawn.PlayVoices(m_sndObjective3, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective4:
             aPawn.PlayVoices(m_sndObjective4, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective5:
             aPawn.PlayVoices(m_sndObjective5, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective6:
             aPawn.PlayVoices(m_sndObjective6, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective7:
             aPawn.PlayVoices(m_sndObjective7, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective8:
             aPawn.PlayVoices(m_sndObjective8, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective9:
             aPawn.PlayVoices(m_sndObjective9, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_Objective10:
             aPawn.PlayVoices(m_sndObjective10, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_WaitAlpha:
             aPawn.PlayVoices(m_sndWaitAlpha, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_WaitBravo:
             aPawn.PlayVoices(m_sndWaitBravo, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_WaitCharlie:
             aPawn.PlayVoices(m_sndWaitCharlie, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_WaitZulu:
             aPawn.PlayVoices(m_sndWaitZulu, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_EntersSmoke:
//             aPawn.PlayVoices(m_sndEntersSmoke, SLOT_Talk, 5, SSTATUS_SendToAll);
            break;
        case ROTV_EntersGas:
             aPawn.PlayVoices(m_sndEntersGas, SLOT_Talk, 5, SSTATUS_SendToAll);
            break;
        case ROTV_StatusEngaging:
             aPawn.PlayVoices(m_sndStatusEngaging, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusMoving:
             aPawn.PlayVoices(m_sndStatusMoving, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusWaiting:
             aPawn.PlayVoices(m_sndStatusWaiting, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusWaitAlpha:
             aPawn.PlayVoices(m_sndStatusWaitAlpha, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusWaitBravo:
             aPawn.PlayVoices(m_sndStatusWaitBravo, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusWaitCharlie:
             aPawn.PlayVoices(m_sndStatusWaitCharlie, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusWaitZulu:
             aPawn.PlayVoices(m_sndStatusWaitZulu, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusSniperWaitAlpha:
             aPawn.PlayVoices(m_sndStatusSniperWaitAlpha, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusSniperWaitBravo:
             aPawn.PlayVoices(m_sndStatusSniperWaitBravo, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusSniperWaitCharlie:
             aPawn.PlayVoices(m_sndStatusSniperWaitCharlie, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusSniperUntilAlpha:
             aPawn.PlayVoices(m_sndStatusSniperUntilAlpha, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusSniperUntilBravo:
             aPawn.PlayVoices(m_sndStatusSniperUntilBravo, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case ROTV_StatusSniperUntilCharlie:
             aPawn.PlayVoices(m_sndStatusSniperUntilCharlie, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
    }
}

function PlayRainbowTeamVoices(R6Pawn aPawn, R6Pawn.ERainbowTeamVoices eRainbowVoices)
{
    switch(eRainbowVoices)
    {
        case RTV_PlacingBug:
             aPawn.PlayVoices(m_sndPlacingBug, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RTV_BugActivated:
             aPawn.PlayVoices(m_sndBugActivated, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RTV_AccessingComputer:
             aPawn.PlayVoices(m_sndAccessingComputer, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RTV_ComputerHacked:
             aPawn.PlayVoices(m_sndComputerHacked, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RTV_EscortingHostage:
             aPawn.PlayVoices(m_sndEscortingHostage, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RTV_HostageSecured:
             aPawn.PlayVoices(m_sndHostageSecured, SLOT_HeadSet, 15, SSTATUS_SendToAll, true);
            break;
        case RTV_PlacingExplosives:
             aPawn.PlayVoices(m_sndPlacingExplosives, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RTV_ExplosivesReady:
             aPawn.PlayVoices(m_sndExplosivesReady, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RTV_DesactivatingSecurity:
             aPawn.PlayVoices(m_sndDesactivatingSecurity, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RTV_SecurityDeactivated:
             aPawn.PlayVoices(m_sndSecurityDeactivated, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
    }
}

defaultproperties
{
}
