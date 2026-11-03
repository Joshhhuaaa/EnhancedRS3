class MP2MenuButtonsDefines extends R6MenuButtonsDefines;

function string GetButtonLoc(int _iButtonID, optional bool _bTip, optional R6MenuButtonsDefines.eButLocalizationExt _eBLE)
{
    local string szName, szTip, szExt;

    switch(_iButtonID)
    {
        case EButtonName.EBN_RoundPerMatch:
            szName = Localize("MPCreateGame", "Options_RoundMatch", "R6Menu");
            break;
        case EButtonName.EBN_RoundTime:
            szName = Localize("MPCreateGame", "Options_Round", "R6Menu");
            break;
        case EButtonName.EBN_NB_Players:
            szName = Localize("MPCreateGame", "Options_NbOfPlayers", "R6Menu");
            break;
        case EButtonName.EBN_BombTimer:
            szName = Localize("MPCreateGame", "Options_BombTimer", "R6Menu");
            break;
        case EButtonName.EBN_Spectator:
            szName = Localize("MPCreateGame", "Options_Spectator", "R6Menu");
            break;
        case EButtonName.EBN_RoundPerMission:
            szName = Localize("MPCreateGame", "Options_RoundMission", "R6Menu");
            break;
        case EButtonName.EBN_TimeBetRound:
            szName = Localize("MPCreateGame", "Options_BetRound", "R6Menu");
            break;
        case EButtonName.EBN_NB_of_Terro:
            szName = Localize("MPCreateGame", "Options_NbOfTerro", "R6Menu");
            break;
        case EButtonName.EBN_InternetServer:
            szName = Localize("MPCreateGame", "Options_ServerLocation", "R6Menu");
            szTip = Localize("Tip", "Options_ServerLocation", "R6Menu");
            break;
        case EButtonName.EBN_DedicatedServer:
            szName = Localize("MPCreateGame", "Options_Dedicated", "R6Menu");
            szTip = Localize("Tip", "Options_Dedicated", "R6Menu");
            break;
        case EButtonName.EBN_FriendlyFire:
            szName = Localize("MPCreateGame", "Options_Friendly", "R6Menu");
            szTip = Localize("Tip", "Options_Friendly", "IronWrathMnu");
            break;
        case EButtonName.EBN_AllowTeamNames:
            szName = Localize("MPCreateGame", "Options_AllowTeamNames", "R6Menu");
            szTip = Localize("Tip", "Options_AllowTeamNames", "R6Menu");
            break;
        case EButtonName.EBN_AutoBalTeam:
            szName = Localize("MPCreateGame", "Options_Auto", "R6Menu");
            szTip = Localize("Tip", "Options_Auto", "R6Menu");
            break;
        case EButtonName.EBN_TKPenalty:
            szName = Localize("MPCreateGame", "Options_TK", "R6Menu");
            szTip = Localize("Tip", "Options_TK", "R6Menu");
            break;
        case EButtonName.EBN_AllowRadar:
            szName = Localize("MPCreateGame", "Options_AllowRadar", "R6Menu");
            szTip = Localize("Tip", "Options_AllowRadar", "R6Menu");
            break;
        case EButtonName.EBN_RotateMap:
            szName = Localize("MPCreateGame", "Options_RotateMap", "R6Menu");
            szTip = Localize("Tip", "Options_RotateMap", "R6Menu");
            break;
        case EButtonName.EBN_AIBkp:
            szName = Localize("MPCreateGame", "Options_AIBackup", "R6Menu");
            szTip = Localize("Tip", "Options_AIBackup", "R6Menu");
            break;
        case EButtonName.EBN_ForceFPersonWp:
            szName = Localize("MPCreateGame", "Options_ForceFPersonWp", "R6Menu");
            szTip = Localize("Tip", "Options_ForceFPersonWp", "R6Menu");
            break;
        case EButtonName.EBN_CamFirstPerson:
            szName = Localize("MPCreateGame", "Options_FirstP", "R6Menu");
            szTip = Localize("Tip", "Options_FirstP", "R6Menu");
            break;
        case EButtonName.EBN_CamThirdPerson:
            szName = Localize("MPCreateGame", "Options_ThirdP", "R6Menu");
            szTip = Localize("Tip", "Options_ThirdP", "R6Menu");
            break;
        case EButtonName.EBN_CamFreeThirdP:
            szName = Localize("MPCreateGame", "Options_FreeThirdP", "R6Menu");
            szTip = Localize("Tip", "Options_FreeThirdP", "R6Menu");
            break;
        case EButtonName.EBN_CamGhost:
            szName = Localize("MPCreateGame", "Options_Ghost", "R6Menu");
            szTip = Localize("Tip", "Options_Ghost", "R6Menu");
            break;
        case EButtonName.EBN_CamFadeToBk:
            szName = Localize("MPCreateGame", "Options_Fade", "R6Menu");
            szTip = Localize("Tip", "Options_Fade", "R6Menu");
            break;
        case EButtonName.EBN_CamTeamOnly:
            szName = Localize("MPCreateGame", "Options_TeamOnly", "R6Menu");
            szTip = Localize("Tip", "Options_TeamOnly", "R6Menu");
            break;
        case EButtonName.EBN_PunkBuster:
            szName = Localize("MPCreateGame", "Options_PunkBuster", "R6Menu");
            szTip = Localize("Tip", "Options_PunkBuster", "R6Menu");
            if(_eBLE == eBLE_DisableToolTip)
            {
                szExt = Localize("MPCreateGame", "Options_PunkBuster", "R6Menu");
            }
            break;
        case EButtonName.EBN_LogIn:
            szName = Localize("MultiPlayer", "ButtonLogIn", "R6Menu");
            szTip = Localize("Tip", "ButtonLogIn", "R6Menu");
            break;
        case EButtonName.EBN_LogOut:
            szName = Localize("MultiPlayer", "ButtonLogOut", "R6Menu");
            szTip = Localize("Tip", "ButtonLogOut", "R6Menu");
            break;
        case EButtonName.EBN_Join:
            szName = Localize("MultiPlayer", "ButtonJoin", "R6Menu");
            szTip = Localize("Tip", "ButtonJoin", "R6Menu");
            break;
        case EButtonName.EBN_JoinIP:
            szName = Localize("MultiPlayer", "ButtonJoinIP", "R6Menu");
            szTip = Localize("Tip", "ButtonJoinIP", "R6Menu");
            break;
        case EButtonName.EBN_Refresh:
            szName = Localize("MultiPlayer", "ButtonRefresh", "R6Menu");
            szTip = Localize("Tip", "ButtonRefresh", "R6Menu");
            break;
        case EButtonName.EBN_Create:
            szName = Localize("MultiPlayer", "ButtonCreate", "R6Menu");
            szTip = Localize("Tip", "ButtonCreate", "R6Menu");
            break;
        case EButtonName.EBN_DiffLevel:
            szName = Localize("MPCreateGame", "Options_DiffLev", "R6Menu");
            szTip = Localize("Tip", "Options_DiffLev", "R6Menu");
            break;
        case EButtonName.EBN_Recruit:
            szName = Localize("SinglePlayer", "Difficulty1", "R6Menu");
            szTip = Localize("Tip", "Diff_Recruit", "R6Menu");
            break;
        case EButtonName.EBN_Veteran:
            szName = Localize("SinglePlayer", "Difficulty2", "R6Menu");
            szTip = Localize("Tip", "Diff_Veteran", "R6Menu");
            break;
        case EButtonName.EBN_Elite:
            szName = Localize("SinglePlayer", "Difficulty3", "R6Menu");
            szTip = Localize("Tip", "Diff_Elite", "R6Menu");
            break;
        case EButtonName.EBN_None:
            szName = "";
            break;
        default:
            log("Button not supported");
            break;
    }
    if(_eBLE != eBLE_None)
    {
        return szExt;
    }
    else
    {
        if(_bTip)
        {
            return szTip;
        }
        else
        {
            return szName;
        }
    }
}
