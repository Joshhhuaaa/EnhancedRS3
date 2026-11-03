class MP2MenuMultiPlayerWidget extends R6MenuMultiPlayerWidget
    config(User);

enum eServerInfoID
{
    eServerInfoID_DeathMatch,       // 0
    eServerInfoID_TeamDeathMatch,   // 1
    eServerInfoID_Bomb,             // 2
    eServerInfoID_HostageAdv,       // 3
    eServerInfoID_Escort,           // 4
    eServerInfoID_Mission,          // 5
    eServerInfoID_Terrorist,        // 6
    eServerInfoID_HostageCoop,      // 7
    eServerInfoID_Defend,           // 8
    eServerInfoID_Recon,            // 9
    eServerInfoID_Unlocked,         // 10
    eServerInfoID_Favorites,        // 11
    eServerInfoID_Dedicated,        // 12
    eServerInfoID_PunkBuster,       // 13
    eServerInfoID_NotEmpty,         // 14
    eServerInfoID_NotFull,          // 15
    eServerInfoID_Responding,       // 16
    eServerInfoID_HasPlayer,        // 17
    eServerInfoID_SameVersion,      // 18
    eServerInfoID_IntruderAdv,      // 19
    eServerInfoID_VirusUploadAdv,   // 20
    eServerInfoID_GazAlertAdv,      // 21
    eServerInfoID_LimitSeatsAdv,    // 22
    eServerInfoID_FreeBackUpAdv     // 23
};

var config bool m_bFilterIntruderAdv;
var config bool m_bFilterVirusUploadAdv;
var config bool m_bFilterGazAlertAdv;
var config bool m_bFilterLimitSeatsAdv;
var config bool m_bFilterFreeBackUpAdv;

function SetServerFilterBooleans(int _iServerInfoID, bool _bNewChoice)
{
    local bool bIsANewFilter;

    bIsANewFilter = true;
    switch(_iServerInfoID)
    {
        case eServerInfoID.eServerInfoID_IntruderAdv:
            m_bFilterIntruderAdv = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_VirusUploadAdv:
            m_bFilterVirusUploadAdv = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_GazAlertAdv:
            m_bFilterGazAlertAdv = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_LimitSeatsAdv:
            m_bFilterLimitSeatsAdv = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_FreeBackUpAdv:
            m_bFilterFreeBackUpAdv = _bNewChoice;
            break;
        default:
            bIsANewFilter = false;
            break;
    }
    if(bIsANewFilter)
    {
        UpdateServerFilters();
    }
    else
    {
        super.SetServerFilterBooleans(_iServerInfoID, _bNewChoice);
    }
}

function UpdateFilters()
{
    local R6ModMgr pModMgr;
    local int i, j, iNbOfServers;
    local bool bFound, bIsRavenShield, bIsLanServers;
    local string szCurrentMod, szTempGDGameType;
    local R6ServerList.stGameServer stTempGameServerItem;

    pModMgr = class'Actor'.static.GetModMgr();
    szCurrentMod = pModMgr.m_pCurrentMod.m_szKeyWord;
    bIsLanServers = m_ConnectionTab == TAB_Lan_Server;
    if(bIsLanServers)
    {
        iNbOfServers = m_LanServers.m_GameServerList.Length;
    }
    else
    {
        iNbOfServers = m_GameService.m_GameServerList.Length;
    }

    for(i = 0; i < iNbOfServers; i++)
    {
        if(bIsLanServers)
        {
            m_LanServers.m_GameServerList[i].bDisplay = false;
            stTempGameServerItem = m_LanServers.m_GameServerList[i];
        }
        else
        {
            m_GameService.m_GameServerList[i].bDisplay = false;
            stTempGameServerItem = m_GameService.m_GameServerList[i];
        }
        szTempGDGameType = stTempGameServerItem.sGameData.szGameDataGameType;
        if(!m_bFilterDeathMatch && szTempGDGameType == "RGM_DeathmatchMode")
        {
            continue;
        }
        if(!m_bFilterTeamDeathMatch && szTempGDGameType == "RGM_TeamDeathmatchMode")
        {
            continue;
        }
        if(!m_bFilterDisarmBomb && szTempGDGameType == "RGM_BombAdvMode")
        {
            continue;
        }
        if(!m_bFilterHostageRescueAdv && szTempGDGameType == "RGM_HostageRescueAdvMode")
        {
            continue;
        }
        if(!m_bFilterEscortPilot && szTempGDGameType == "RGM_EscortAdvMode")
        {
            continue;
        }
        if(!m_bFilterMission && szTempGDGameType == "RGM_MissionMode")
        {
            continue;
        }
        if(!m_bFilterTerroristHunt && szTempGDGameType == "RGM_TerroristHuntCoopMode")
        {
            continue;
        }
        if(!m_bFilterHostageRescueCoop && szTempGDGameType == "RGM_HostageRescueCoopMode")
        {
            continue;
        }
        if(!m_bFilterIntruderAdv && szTempGDGameType == "RGM_IntruderAdvMode")
        {
            continue;
        }
        if(!m_bFilterVirusUploadAdv && szTempGDGameType == "RGM_VirusUploadAdvMode")
        {
            continue;
        }
        if(!m_bFilterGazAlertAdv && szTempGDGameType == "RGM_GazAlertAdvMode")
        {
            continue;
        }
        if(!m_bFilterLimitSeatsAdv && szTempGDGameType == "RGM_LimitSeatsAdvMode")
        {
            continue;
        }
        if(!m_bFilterFreeBackUpAdv && szTempGDGameType == "RGM_FreeBackupAdvMode")
        {
            continue;
        }
        if((stTempGameServerItem.sGameData.szModName != "") && !(stTempGameServerItem.sGameData.szModName ~= szCurrentMod))
        {
            log(("UpdateFilters() szModName is different than current MOD " @ stTempGameServerItem.sGameData.szModName) @ szCurrentMod);
            continue;
        }
        if(m_bFilterUnlockedOnly && stTempGameServerItem.sGameData.bUsePassword)
        {
            continue;
        }
        if(m_bFilterFavoritesOnly && !stTempGameServerItem.bFavorite)
        {
            continue;
        }
        if(m_bFilterDedicatedServersOnly && !stTempGameServerItem.sGameData.bDedicatedServer)
        {
            continue;
        }
        if(m_bFilterServersNotEmpty && stTempGameServerItem.sGameData.iNbrPlayer == 0)
        {
            continue;
        }
        if(bIsLanServers)
        {
            if(m_bFilterServersNotFull && stTempGameServerItem.sGameData.iNbrPlayer >= m_LanServers.m_GameServerList[i].sGameData.iMaxPlayer)
            {
                continue;
            }
        }
        else
        {
            if(m_bFilterServersNotFull && stTempGameServerItem.sGameData.iNbrPlayer >= m_GameService.m_GameServerList[i].sGameData.iMaxPlayer)
            {
                continue;
            }
        }
        if(m_bFilterPunkBusterServerOnly && !stTempGameServerItem.sGameData.bPunkBuster)
        {
            continue;
        }
        if(m_bFilterResponding && stTempGameServerItem.iPing >= 1000)
        {
            continue;
        }
        if((m_iFilterFasterThan > 0) && stTempGameServerItem.iPing > m_iFilterFasterThan)
        {
            continue;
        }
        if(m_bFilterSameVersion && !stTempGameServerItem.bSameVersion)
        {
            continue;
        }
        if(bIsLanServers)
        {
            m_LanServers.m_GameServerList[i].bDisplay = true;
            continue;
        }
        m_GameService.m_GameServerList[i].bDisplay = true;
    }
}

defaultproperties
{
    m_bFilterIntruderAdv=true
    m_bFilterVirusUploadAdv=true
    m_bFilterGazAlertAdv=true
    m_bFilterLimitSeatsAdv=true
    m_bFilterFreeBackUpAdv=true
}
