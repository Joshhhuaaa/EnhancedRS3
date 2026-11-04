class ASMenuMultiPlayerWidget extends R6MenuMultiPlayerWidget
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
    eServerInfoID_TerroristAdv,     // 19
    eServerInfoID_ScatteredAdv,     // 20
    eServerInfoID_CaptTheEnemyAdv,  // 21
    eServerInfoID_Kamikaze          // 22
};

var config bool m_bFilterTerroristHuntAdv;
var config bool m_bFilterScatteredHuntAdv;
var config bool m_bFilterCaptureTheEnemyAdv;
var config bool m_bFilterKamikaze;

function SetServerFilterBooleans(int _iServerInfoID, bool _bNewChoice)
{
    local bool bIsANewFilter;

    bIsANewFilter = true;
    switch(_iServerInfoID)
    {
        case eServerInfoID.eServerInfoID_TerroristAdv:
            m_bFilterTerroristHuntAdv = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_ScatteredAdv:
            m_bFilterScatteredHuntAdv = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_CaptTheEnemyAdv:
            m_bFilterCaptureTheEnemyAdv = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Kamikaze:
            m_bFilterKamikaze = _bNewChoice;
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
        if(!m_bFilterTerroristHuntAdv && szTempGDGameType == "RGM_TerroristHuntAdvMode")
        {
            continue;
        }
        if(!m_bFilterScatteredHuntAdv && szTempGDGameType == "RGM_ScatteredHuntAdvMode")
        {
            continue;
        }
        if(!m_bFilterCaptureTheEnemyAdv && szTempGDGameType == "RGM_CaptureTheEnemyAdvMode")
        {
            continue;
        }
        if(!m_bFilterKamikaze && szTempGDGameType == "RGM_KamikazeMode")
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
    m_bFilterTerroristHuntAdv=true
    m_bFilterScatteredHuntAdv=true
    m_bFilterCaptureTheEnemyAdv=true
    m_bFilterKamikaze=true
}
