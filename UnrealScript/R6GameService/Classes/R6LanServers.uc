//=============================================================================
//  R6LanServers.uc : This class contains all inofrmation and functions 
//  for building a list of LAN servers.
//
//  Revision history:
//    2002/04/02 * Created by John Bennett
//============================================================================//

class R6LanServers extends R6ServerList
	native;

var INT  m_iIndRefrAttempts;    // Number of attempts made to refresh an indiavidual server
var INT  m_iIndRefrEndTime;     // Time at which ind refresh is considered timed out

var BOOL m_bIndRefrInProgress;       // Individual refresh in progress

const K_REFRESH_TIMEOUT = 1000;  // Timeout in milli-seconds for an individual refresh
const K_INDREFR_MAXATT  = 4;     // Maximum number of attempts for an individual refresh

//=============================================================================
// RefreshServers - Refresh the list of servers, that is, erase the old list
// and rebuild from start.
//=============================================================================

function RefreshServers()
{
    m_GameServerList.Remove(0, m_GameServerList.length);         // Clear entire list
    m_GSLSortIdx.Remove(0, m_GSLSortIdx.length);
    m_ClientBeacon.RefreshServers();
    m_bIndRefrInProgress = FALSE;
}
//=============================================================================
// RefreshServers - Refresh the list of servers, that is, erase the old list
// and rebuild from start.
//=============================================================================

function RefreshOneServer( INT sortedListIdx )
{
    local INT  serverListIndex;

    serverListIndex = m_GSLSortIdx[sortedListIdx];

    // Only allow one refresh at a time
    if ( m_bIndRefrInProgress )
        return;

    m_iIndRefrAttempts   = 0;
    m_bIndRefrInProgress = TRUE;
    m_iIndRefrIndex      = serverListIndex;

    SendBeaconToOneServer( serverListIndex );
}

function SendBeaconToOneServer( INT iIndex )
{
    local InternetLink.IpAddr Addr; // Adress structure used by StringToIpAddr()
    local string   szIP;            // IP address extracted from IP:Port string

    m_iIndRefrAttempts++;
    m_iIndRefrEndTime = NativeGetMilliSeconds() + K_REFRESH_TIMEOUT;

    // The IP is in the form 10.10.10.10:1234, separate this string into its IP part (szIP)
    // and its port part (iPort)

    szIP = Left( m_GameServerList[iIndex].szIPAddress, InStr( m_GameServerList[iIndex].szIPAddress,":" ) );

    // Convert the IP string into an integer, note that StringToIpAddr returns a port number of 0.

    m_ClientBeacon.StringToIpAddr( szIP, Addr );

    // Set port number

    Addr.Port = m_ClientBeacon.ServerBeaconPort;

    // Send a beacon to this address

    m_ClientBeacon.BroadcastBeacon( Addr );
}

//===========================================================================
// Created - Should be called when this class is spawned
//===========================================================================
function Created()
{
    Super.Created();
    NativeInitFavorites();
}

//===========================================================================
// LANSeversManager - The manager will process information that is received
// from the LAN by UDPClientBeaconReceiver.  The manager should be called 
// regularly (every second or two).
//===========================================================================
function LANSeversManager()
{
    local INT           i,j;
    local stGameServer  sSvr;
    local BOOL          bFound;
    local INT           iIndex;
    local string        szSvrAddr;
    local BOOL          bListChanged;
    local INT           iBeaconArraySize;
	local string		szCurrentMod;

    bListChanged = FALSE;

    if ( m_ClientBeacon == None )
        return;

    iBeaconArraySize = m_ClientBeacon.GetBeaconListSize();

    // GO through list of beacons and check if we have received
    // any new server information.

	szCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;

    for ( i = 0; i< iBeaconArraySize; i++ ) 
    {

        if ( m_ClientBeacon.GetBeaconIntAddress(i) != 0 && m_ClientBeacon.GetNewDataFlag(i) )
        {
 
            // Make sure that the server is not already in the list
            szSvrAddr = m_ClientBeacon.GetBeaconAddress(i);

            // The adress returned by IpAddrToString is of the form 10.10.10.10:7777,
            // remove everything after the ":" to get the true IP address.

            //  szSvrAddr = left(szSvrAddr, InStr(szSvrAddr, ":"));

            bFound = FALSE;
            for ( j = 0; j < m_GameServerList.length && !bFound; j++ )
            {
                if ( szSvrAddr == m_GameServerList[j].szIPAddress )
                {
                    bFound = TRUE;
                    iIndex = j;
                    if ( m_bIndRefrInProgress && iIndex == m_iIndRefrIndex )
                        m_bIndRefrInProgress = FALSE;
                }
            }
           
/*
======================================================================
    BEGIN PATCH Eric Bégin (ASE/GameSpy Support)
======================================================================
Since Internet Servers on the LAN respond to the LAN REPORT request,
we need to filter Internet servers out from the LAN Servers Page
======================================================================
*/
            if (!m_ClientBeacon.GetInternetServer(i) && (m_ClientBeacon.GetModName(i) ~= szCurrentMod))
            {
                sSvr.sGameData   = getSvrData(i);
                sSvr.szIPAddress = szSvrAddr;
                sSvr.bDisplay    = TRUE;
                sSvr.bFavorite   = IsAFavorite(szSvrAddr); 
                sSvr.iPing       = NativeGetPingTime( left(szSvrAddr, InStr(szSvrAddr, ":") ) );
                sSvr.iGroupID    = m_ClientBeacon.GetGroupID(i);
                sSvr.iLobbySrvID = m_ClientBeacon.GetLobbyID(i);
                sSvr.iBeaconPort = m_ClientBeacon.GetBeaconPort(i);

                // Use the beacon/Level to determine the game mode and game type name
                sSvr.sGameData.bAdversarial = m_ClientBeacon.Level.IsGameTypeAdversarial( sSvr.sGameData.szGameDataGameType );
                sSvr.sGameData.szGameType   = m_ClientBeacon.Level.GetGameNameLocalization( sSvr.sGameData.szGameDataGameType );

                // Update list with new server info, or append list if the server
                // is not already in the list

                if ( bFound )
                {
                    m_GameServerList[iIndex].sGameData = sSvr.sGameData;
                    m_GameServerList[iIndex].iPing     = sSvr.iPing;
                    m_GameServerList[iIndex].iGroupID    = sSvr.iGroupID;
                    m_GameServerList[iIndex].iLobbySrvID = sSvr.iLobbySrvID;
                    m_GameServerList[iIndex].iBeaconPort = sSvr.iBeaconPort;
                }
                else
                {
                    iIndex = m_GameServerList.length;
                    m_GameServerList[m_GameServerList.length] = sSvr;
                    m_GSLSortIdx[m_GSLSortIdx.length] = m_GSLSortIdx.length - 1;   
                }

                m_GameServerList[iIndex].bSameVersion = ( m_GameServerList[iIndex].sGameData.szGameVersion == class'Actor'.static.GetGameVersion(false, !class'Actor'.static.GetModMgr().IsRavenShield()) );

                m_ClientBeacon.SetNewDataFlag( i, FALSE );
                m_bServerListChanged = TRUE;
            }
/*
======================================================================
    END PATCH Eric Bégin (ASE/GameSpy Support)
======================================================================
*/            
        }
    }

  
    if ( m_bIndRefrInProgress )
    {
        if ( NativeGetMilliSeconds() > m_iIndRefrEndTime )
        {
            if ( m_iIndRefrAttempts < K_INDREFR_MAXATT )
                SendBeaconToOneServer( m_iIndRefrIndex );
            else
            {
                m_GameServerList.Remove( m_iIndRefrIndex, 1 );
                m_GSLSortIdx.Remove( m_iIndRefrIndex, 1 );
                m_bIndRefrInProgress = FALSE;
                m_bServerListChanged = TRUE;
            }
        }
    }
}
