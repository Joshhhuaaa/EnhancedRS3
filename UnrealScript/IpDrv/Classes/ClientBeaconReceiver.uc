//=============================================================================
// ClientBeaconReceiver: Receives LAN beacons from servers.
//=============================================================================
class ClientBeaconReceiver extends UdpBeacon
	transient;

var struct BeaconInfo
{
	var IpAddr      Addr;
	var float       Time;
	var string      Text;

//#ifdef R6CODE // added by John Bennett - April 2002
    var INT         iNumPlayers;
    var INT         iMaxPlayers;
    var string         szCurrGameType;
    var string              szMapName;
    var string              szSvrName;
    var BOOL                bDedicated;
    var BOOL                bLocked;
    var string              mapList[32];
    var string		        szGameType[32];
    var string              szPlayerName[32];
    var string              szPlayerTime[32];
    var INT                 iPlayerPingTime[32];
    var INT                 iPlayerKillCount[32];
//    var string              szGameName[32];         //Actually an array of game types
//    var FLOAT               fMapTime;
    var INT                 iRoundsPerMap;
    var FLOAT               fRndTime;
    var FLOAT               fBetTime;
    var FLOAT               fBombTime;
    var BOOL                bShowNames;
    var BOOL                bInternetServer;
    var BOOL                bFriendlyFire;
    var BOOL                bAutoBalTeam;
    var BOOL                bTKPenalty;
    var BOOL                bNewData;       // Flag indicating new data has been received
    var BOOL                bRadar;
    var INT                 iPort;
    var string              szGameVersion;
    var INT                 iLobbyID;
    var INT                 iGroupID;
    var INT                 iBeaconPort;
    var INT                 iNumTerro;
    var BOOL                bAIBkp;
    var BOOL                bRotateMap;
    var BOOL                bForceFPWpn;
    var string              szModName; // MPF
//#ifdef R6PUNKBUSTER
    var BOOL                bPunkBuster;
//#endif //R6PUNKBUSTER
//#endif R6CODE

} Beacons[32];

//#ifdef R6CODE

// Structure used to store information received from a response
// from a PreJoinQuery

var struct PreJoinResponseInfo
{
    var BOOL        bResponseRcvd;
    var INT         iLobbyID;
    var INT         iGroupID;
    var BOOL        bLocked;
    var string      szGameVersion;
    var string      szPreJoinModName;
    var BOOL        bInternetServer;
    var INT         iNumPlayers;
    var INT         iMaxPlayers;
    var INT         iPunkBusterEnabled;
} PreJoinInfo;
//#endif R6CODE

function string GetBeaconAddress( int i )
{
	return IpAddrToString(Beacons[i].Addr);
}

function string GetBeaconText(int i)
{
	return Beacons[i].Text;
}

function BeginPlay()
{
	local IpAddr Addr;

//#ifdef R6CODE
    InitBeaconProduct();
//#endif R6CODE 
//#ifndef R6CODE
//	if( BindPort( BeaconPort, true ) > 0 )
//else
	if( BindPort( BeaconPort, true, LocalIpAddress ) > 0 )
//#endif
	{
		SetTimer( 1.0, true );
		log( "ClientBeaconReceiver initialized." );
	}
	else
	{
		log( "ClientBeaconReceiver failed: Beacon port in use." );
	}

	Addr.Addr = BroadcastAddr;
	Addr.Port = ServerBeaconPort;

	BroadcastBeacon(Addr);
}

function Destroyed()
{
	log( "ClientBeaconReceiver finished." );
}

function Timer()
{
	local int i, j;
	for( i=0; i<arraycount(Beacons); i++ )
		if
		(	Beacons[i].Addr.Addr!=0
		&&	Level.TimeSeconds-Beacons[i].Time<BeaconTimeout )
			Beacons[j++] = Beacons[i];
	for( j=j; j<arraycount(Beacons); j++ )
    {
//        ClearBeacon(j);
		Beacons[j].Addr.Addr=0;
    }
}

function BroadcastBeacon(IpAddr Addr)
{
    local INT i;
    local IpAddr lAddr;

//#ifdef R6CODE

    // Send a beacon to all possible port numbers,

    for ( i = 0; i < GetMaxAvailPorts(); i++)
    {
        lAddr.Addr = Addr.Addr;
        lAddr.Port = Addr.Port + i;
	    SendText( lAddr, "REPORT" );
    }

//#endif R6CODE
}

//#ifndef R6CODE
// send a broadcast command to the serveronce we join
// if the server receives this messages, then the server
// will assume that the client is indeed on the same server
//function BroadcastLanClient(IpAddr Addr)
//{
//    local IpAddr lAddr;
//
//    lAddr.Addr = -1;
//    lAddr.Port = Addr.Port;
//    SendText(lAddr , "PINGQUERY");
//}
//#endif

//#ifdef R6CODE

//=========================================================================
// PreJoinQuery.  Used when joining a server using the Join IP button, 
// since we know nothing about this server we will query the server for
// some basic information (e.g. is a password required).
// returns false if the ip string is an invalid format
//=========================================================================

function BOOL PreJoinQuery( string szIP, INT iBeaconPort )
{
	local IpAddr Addr;

    // Reset server information
    PreJoinInfo.bResponseRcvd = FALSE;
    PreJoinInfo.iLobbyID      = 0;
    PreJoinInfo.iGroupID      = 0;
    PreJoinInfo.szGameVersion = "";

    if (InStr( szIP,":" )!=-1)
    {
        szIP = Left( szIP, InStr( szIP,":" ) );
    }

    if ( !StringToIpAddr ( szIP, Addr ) )
        return false;

	if (Addr.Addr == 0)
		return false;

    if ( iBeaconPort != 0)
        Addr.Port = iBeaconPort;
    else
        Addr.Port = ServerBeaconPort;


	SendText( Addr, "PREJOIN" );
//#ifndef R6CODE
// BroadcastLanClient(Addr);
//#endif

    return true;
}

//#endif R6CODE



event ReceivedText( IpAddr Addr, string Text )
{
	local int i, n;

//#ifdef R6CODE // added by John Bennett - April 2002
    local INT    pos;               // Position in the current string
	local string szSecondWord;      // The second word in the message
    local string szThirdWord;       // The third word in the message
    local string szRemainingText;   // What remains to be decoded from the original string
    local string szOneKWMessage;    // String containing just ine keyword and associated parameters
    local string szPreJoinString;   // Used to store remainder of string
    local BOOL   bBooleanValue;     // Boolean value extracted from data
    local string szStringValue;     // String value extracted from data

    //----------------------------------------------------------------
    // Check if message is using a keyword to pass a specific value,
    // These messages be of the form...
    //    <BeaconProduct> <Port Number> <KeyWordMarker> <uniqueDataMarker> <data>
    //
    // For example...
    //    unreal 7777 KEYWORD %MAXPLAYERS 16 %NUMPLAYERS 2 %MAPNAME rooms.unr
    //
    // Call the ReceivedKeyWordString to decode these type os messages.
    //----------------------------------------------------------------
    n = len(BeaconProduct);

	if( left(Text,n+1) ~= (BeaconProduct$" ") )
	{

        // Decode the second word to determine the port number of the server

        szSecondWord = mid(Text,n+1);
        Addr.Port = int(szSecondWord);

        // Check for the string KEYWORD

        szThirdWord = mid(szSecondWord,InStr(szSecondWord," ")+1);

        n = len( KeyWordMarker );

        if ( left( szThirdWord, n+1 ) ~= ( KeyWordMarker$" " ) )
        {

            for( i=0; i<arraycount(Beacons); i++ )
                if( Beacons[i].Addr.Addr==Addr.Addr && Beacons[i].Addr.Port==Addr.Port)
                    break;

            if( i==arraycount(Beacons) )
                for( i=0; i<arraycount(Beacons); i++ )
                    if( Beacons[i].Addr.Addr==0 )
                        break;

            if ( i == arraycount(Beacons) )
                return;

            pos = InStr( szThirdWord, ModNameMarker );
            if ( pos != -1 )
            {
                szStringValue = mid( szThirdWord, pos + len(ModNameMarker) + 1 );
                pos = InStr( szStringValue, "�" );
                if ( pos != -1 )
                {
                    szStringValue = left( szStringValue, pos - 1 );
                    if ( !(class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord ~= szStringValue) )
                        return;
                }
            }

		    Beacons[i].Addr      = Addr;
		    Beacons[i].Time      = Level.TimeSeconds;
		    Beacons[i].Text      = mid(Text,InStr(Text," ")+1);
            Beacons[i].bNewData  = TRUE;
            
            DecodeKeyWordString( i, szThirdWord ); 
            return;
        }

        // Check for the Pre Join Query marker, deocde the information
        // received and store in the PreJoinInfo structure.

        else if ( left( szThirdWord, len( PreJoinQueryMarker ) + 1 ) ~= ( PreJoinQueryMarker$" " ) )
        {
            // Find the first keyword
            pos = InStr( mid(szThirdWord, 1), "�" );
            if ( pos != -1 )
                szPreJoinString = mid( szThirdWord, pos );

            // Clear any previous data
            PreJoinInfo.bResponseRcvd = TRUE;
            PreJoinInfo.iLobbyID = 0;
            PreJoinInfo.iGroupID  = 0;

            // Go through the string searching for keyword pairs

            while ( pos > 0 )
            {
                pos = InStr( mid(szPreJoinString, 1), "�" );

                if ( pos != -1 )  // -1 is the return value when a string is not found
                {
                    pos += 1;
                    szOneKWMessage = left( szPreJoinString, pos - 1 );  // -1 to eliminate space at end of string
                    szPreJoinString = mid( szPreJoinString, pos );      // move to next key word marker
                }
                else
                    szOneKWMessage = szPreJoinString;  // Last message in the string


                // Check for the lobby server ID number
                if ( left(szOneKWMessage,len(LobbyServerIDMarker)) ~= LobbyServerIDMarker ) 
                {
                    PreJoinInfo.iLobbyID = int(mid(szOneKWMessage,InStr(szOneKWMessage," ")+1));
                    //log ("---> "$PreJoinInfo.iLobbyID);
                }

                // Check for the group ID number
                else if ( left(szOneKWMessage,len(GroupIDMarker)) ~= GroupIDMarker ) 
                {
                    PreJoinInfo.iGroupID = int(mid(szOneKWMessage,InStr(szOneKWMessage," ")+1));
                    //log ("---> "$PreJoinInfo.iGroupID);
                }
                // Server locked (requires a password)
                else if ( left(szOneKWMessage,len(LockedMarker)) ~= LockedMarker )
                {   // Decode value
                    bBooleanValue = BOOL(int(mid(szOneKWMessage,InStr(szOneKWMessage," ")+1)));
                    PreJoinInfo.bLocked = bBooleanValue;
                }
                // Game Version
                else if ( left(szOneKWMessage,len(GameVersionMarker)) ~= GameVersionMarker)
                {   // Decode value
    	            szStringValue =  mid(szOneKWMessage,InStr(szOneKWMessage," ")+1);
                    PreJoinInfo.szGameVersion = szStringValue;
                }
                // Internet server
                else if ( left(szOneKWMessage,len(InternetServerMarker)) ~= InternetServerMarker)
                {   // Decode value
                    bBooleanValue = BOOL(int(mid(szOneKWMessage,InStr(szOneKWMessage," ")+1)));
                    PreJoinInfo.bInternetServer = bBooleanValue;
                }
                // Check for the marker for the current number of players in the game
                else if ( left(szOneKWMessage,len(NumPlayersMarker)) ~= NumPlayersMarker )
                {   // Decode value
                    PreJoinInfo.iNumPlayers = int(mid(szOneKWMessage,InStr(szOneKWMessage," ")+1));
                }
                // Max Players
                else if ( left(szOneKWMessage,len(MaxPlayersMarker)) ~= MaxPlayersMarker )
                {   // Decode value
                    PreJoinInfo.iMaxPlayers = int(mid(szOneKWMessage,InStr(szOneKWMessage," ")+1));
                }
                // PB enabled server
                else if ( left(szOneKWMessage,len(PunkBusterMarker)) ~= PunkBusterMarker )
                {   // Decode value
                    PreJoinInfo.iPunkBusterEnabled = int(mid(szOneKWMessage,InStr(szOneKWMessage," ")+1));
                }
                else if ( left(szOneKWMessage,len(ModNameMarker)) ~= ModNameMarker )
                {   // Decode value
                    PreJoinInfo.szPreJoinModName = mid(szOneKWMessage,InStr(szOneKWMessage," ")+1);
                }

            }
        }
    }

//#endif R6CODE



//#ifdef R6CODE // This section commented out, no longer used in RAVENSHIELD, replaced by code above
/*
//#endif R6CODE


    n = len(BeaconProduct);
	if( left(Text,n+1) ~= (BeaconProduct$" ") )
	{
		Text = mid(Text,n+1);
		Addr.Port = int(Text);
		for( i=0; i<arraycount(Beacons); i++ )
			if( Beacons[i].Addr==Addr )
				break;
		if( i==arraycount(Beacons) )
			for( i=0; i<arraycount(Beacons); i++ )
				if( Beacons[i].Addr.Addr==0 )
					break;
		if( i==arraycount(Beacons) )
			return;
		Beacons[i].Addr      = Addr;
		Beacons[i].Time      = Level.TimeSeconds;
		Beacons[i].Text      = mid(Text,InStr(Text," ")+1);
        Beacons[i].bNewData  = TRUE;
	}

//#ifdef R6CODE 
*/
//#endif R6CODE

}




//#ifdef R6CODE // added by John Bennett - April 2002
       
//=========================================================================
// Get functions.  The script compiler would not let me access the Beacon 
// member variable from another class because it was too big.  Instead
// I set up these get functions and a ClearBeacon function to clear values 
// in the Beacon array.
//=========================================================================
function INT GetBeaconListSize()
{
	return arraycount(Beacons);
}

function INT GetBeaconIntAddress( INT i )
{
	return Beacons[i].Addr.Addr;
}

function INT GetMaxPlayers( INT i )
{
	return Beacons[i].iMaxPlayers;
}

function INT GetPortNumber( INT i )
{
	return Beacons[i].iPort;
}

function INT GetNumPlayers( INT i )
{
	return Beacons[i].iNumPlayers;
}

function string GetFirstMapName( INT i )
{
	return Beacons[i].szMapName;
}
function string GetSvrName( INT i )
{
	return Beacons[i].szSvrName;
}

// MPF
function string GetModName( INT i )
{
	return Beacons[i].szModName;
}

function BOOL GetLocked( INT i )
{
	return Beacons[i].bLocked;
}
function BOOL GetDedicated( INT i )
{
	return Beacons[i].bDedicated;
}

function FLOAT GetRoundsPerMap( INT i )
{
    return Beacons[i].iRoundsPerMap;
}
//function FLOAT GetMapTime( INT i )
//{
//	return Beacons[i].fMapTime;
//}

function FLOAT GetRoundTime( INT i )
{
	return Beacons[i].fRndTime;
}
function FLOAT GetBetTime( INT i )
{
	return Beacons[i].fBetTime;
}
function FLOAT GetBombTime( INT i )
{
	return Beacons[i].fBombTime;
}


function INT GetMapListSize( INT i )
{
    local INT j;
    for ( j = 0; j < arraycount(Beacons[i].mapList); j++)
        if ( Beacons[i].mapList[j] == "" )
            break;
    return j;
}

function string GetOneMapName( INT iBeacon, INT i )
{
	return Beacons[iBeacon].mapList[i];
}

function INT GetPlayerListSize( INT i )
{
    local INT j;
    for ( j = 0; j < arraycount(Beacons[i].szPlayerName); j++)
        if ( Beacons[i].szPlayerName[j] == "" )
            break;
    return j;
}

function string GetPlayerName( INT iBeacon, INT i )
{
	return Beacons[iBeacon].szPlayerName[i];
}

function string GetPlayerTime( INT iBeacon, INT i )
{
	return Beacons[iBeacon].szPlayerTime[i];
}

function INT GetPlayerPingTime( INT iBeacon, INT i )
{
	return Beacons[iBeacon].iPlayerPingTime[i];
}
function INT GetPlayerKillCount( INT iBeacon, INT i )
{
	return Beacons[iBeacon].iPlayerKillCount[i];
}

//function INT GetGameNameListSize( INT i )
//{
//    local INT j;
//    for ( j = 0; j < arraycount(Beacons[i].szGameName); j++)
//        if ( Beacons[i].szGameName[j] == "" )
//            break;
//    return j;
//}

//function string GetGameName( INT iBeacon, INT i )
//{
//	return Beacons[iBeacon].szGameName[i];
//}
function string GetGameType( INT iBeacon, INT i )
{
    return Beacons[iBeacon].szGameType[i];
}

function BOOL GetShowEnemyNames( INT i )
{
	return Beacons[i].bShowNames;
}
function BOOL GetInternetServer( INT i )
{
	return Beacons[i].bInternetServer;
}
function BOOL GetFriendlyFire( INT i )
{
	return Beacons[i].bFriendlyFire;
}
function BOOL GetAutoBalanceTeam( INT i )
{
	return Beacons[i].bAutoBalTeam;
}
function BOOL GetTKPenalty( INT i )
{
	return Beacons[i].bTKPenalty;
}
function BOOL GetRadar(INT i)
{
	return Beacons[i].bRadar;
}
function string GetCurrGameType( INT i )
{
    return Beacons[i].szCurrGameType;
}
function BOOL GetNewDataFlag( INT i )
{
    return Beacons[i].bNewData;
}
function string GetServerGameVersion( INT i )
{
    return Beacons[i].szGameVersion;
}
function SetNewDataFlag( INT i, BOOL bNewData )
{
    Beacons[i].bNewData = bNewData;
}
function INT GetLobbyID( INT i )
{
	return Beacons[i].iLobbyID;
}
function INT GetGroupID( INT i )
{
	return Beacons[i].iGroupID;
}
function INT GetBeaconPort( INT i )
{
	return Beacons[i].iBeaconPort;
}
function INT GetNumTerrorists( INT i )
{
	return Beacons[i].iNumTerro;
}
function BOOL GetAIBackup( INT i )
{
    return Beacons[i].bAIBkp;
}
function BOOL GetRotateMap( INT i )
{
    return Beacons[i].bRotateMap;
}
function BOOL GetForceFirstPersonWeapon( INT i )
{
    return Beacons[i].bForceFPWpn;
}

//#ifdef R6PUNKBUSTER
function BOOL GetPunkBusterEnabled( INT i )
{
    return Beacons[i].bPunkBuster;
}
//#endif R6PUNKBUSTER

//-------------------------------------------------------------------------------
// This functio will clear all the information in the beacon
//-------------------------------------------------------------------------------
function ClearBeacon( INT i )
{
    local int j;
    
    Beacons[i].Addr.Addr    = 0;
    Beacons[i].iNumPlayers  = 0;
    Beacons[i].iMaxPlayers  = 0;
    Beacons[i].szMapName    = "";
    Beacons[i].szCurrGameType = "RGM_AllMode";
    Beacons[i].szSvrName    = "";
    Beacons[i].bDedicated   = FALSE;
    Beacons[i].bLocked      = FALSE;

    for ( j = 0; j < arraycount(Beacons[i].mapList); j++)
        Beacons[i].mapList[j] = "";

    for ( j = 0; j < arraycount(Beacons[i].szPlayerName); j++)
        Beacons[i].szPlayerName[j] = "";

    for ( j = 0; j < arraycount(Beacons[i].szPlayerTime); j++)
        Beacons[i].szPlayerTime[j] = "";

//    for ( j = 0; j < arraycount(Beacons[i].szGameName); j++)
//        Beacons[i].szGameName[j] = "";

//    Beacons[i].fMapTime         = 0.0;
    Beacons[i].iRoundsPerMap    = 0;
    Beacons[i].fRndTime         = 0.0;
    Beacons[i].fBetTime         = 0.0;
    Beacons[i].fBombTime        = 0.0;
    Beacons[i].bShowNames       = FALSE;
    Beacons[i].bInternetServer  = FALSE;
    Beacons[i].bFriendlyFire    = FALSE;
    Beacons[i].bAutoBalTeam     = FALSE;
    Beacons[i].bTKPenalty       = FALSE;
    Beacons[i].bRadar           = FALSE;
    Beacons[i].iPort            = 0;
    Beacons[i].szGameVersion    = "";
    Beacons[i].iLobbyID         = 0;
    Beacons[i].iGroupID         = 0;
    Beacons[i].szModName        = "";

//#ifdef R6PUNKBUSTER
    Beacons[i].bPunkBuster		= FALSE;
//#endif R6PUNKBUSTER
}

//=========================================================================
// RefreshServers - Clears the list of beacons already received, then sends
// out a broadcast message looking for servers. 
//=========================================================================

function RefreshServers()
{
	local IpAddr Addr;
    local INT    i;

    // Clear list

	for( i = 0; i<arraycount(Beacons); i++ )
		Beacons[i].Addr.Addr=0;

    // Send broadcast message requesting servers to answer back

	Addr.Addr = BroadcastAddr;
	Addr.Port = ServerBeaconPort;
	BroadcastBeacon(Addr);
}

//=========================================================================
// ReceivedKeyWordString - If the message received is using a keyword,
// detect whick keyword it is and decode the value.  Messages will be 
// of the type...
//
//  KEYWORD MAXPLAYERS 16
//  KEYWORD NUMPLAYERS 2
//  KEYWORD MAPNAME rooms.unr
//
//=========================================================================

//
// Grab the next option from a string.
//
function bool GrabOption( out string Options, out string Result )
{

	if( Left(Options,1)=="�" )
	{
		// Get result.
		Result = Mid(Options,1);
		if( InStr(Result,"�")>=0 )
			Result = Left( Result, InStr(Result,"�") );

		// Update options.
		Options = Mid(Options,1);
		if( InStr(Options,"�")>=0 )
			Options = Mid( Options, InStr(Options,"�") );
		else
			Options = "";

		return true;
	}
	else return false;
}

//
// Break up a key=value pair into its key and value.
//
function GetKeyValue( string Pair, out string Key, out string Value )
{
	if( InStr(Pair,"=")>=0 )
	{
		Key   = Left(Pair,InStr(Pair,"="));
		Value = Mid(Pair,InStr(Pair,"=")+1);
	}
	else
	{
		Key   = Pair;
		Value = "";
	}
}
/* ParseOption()
 Find an option in the options string and return it.
*/

function string ParseOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return Value;
	}
	return "";
}

//=========================================================================
// DecodeKeyWordString - Go through the keyword string and extract
// key word pairs (keyword and associated value).  Call DecodeKeyWordPair
// to decode each pair.
//=========================================================================
function DecodeKeyWordString( INT iBeaconIdx, string szKewWordString )
{
    local INT    pos;               // Position in the current string
    local INT    counter;           // Counter
    local INT    i;
//	local string szSecondWord;      // The second word in the message
//    local string szRemainingText;   // What remains to be decoded from the original string
    local string szOneKWMessage;    // String containing just ine keyword and associated parameters

    // Find the first uniqueDataMarker 
     
    pos = ( InStr(szKewWordString, "�") );
    if ( pos != -1 )
        szKewWordString = mid( szKewWordString, pos );


    // Decode each of the keyword messages until the last message is found
    counter = 0;
    while ( pos > 0 && counter < 255 ) // Counter used as protection against infinite loop
    {
        counter++;
        pos = InStr( mid(szKewWordString, 1), "�" );
        if ( pos != -1 )  // -1 is the return value when a string is not found
        {
            pos += 1;
            szOneKWMessage = left( szKewWordString, pos - 1 );  // -1 to eliminate space at end of string
            szKewWordString = mid( szKewWordString, pos );      // move to next key word marker
        }
        else
            szOneKWMessage = szKewWordString;  // Last message in the string

        DecodeKeyWordPair( szOneKWMessage, iBeaconIdx );

        Beacons[iBeaconIdx].bNewData = TRUE;

    }
}

//=========================================================================
// DecodeKeyWordPair - Given a string containing a keyword pair (keyword 
// and associated value) determine which keyword is used, and extract
// the associated value.  Place results in the Beacons array.
//=========================================================================
function DecodeKeyWordPair( string szKeyWord, int iIndex )
{
    local INT    iIntegerValue;  // Integer value extracted from data
    local BOOL   bBooleanValue;  // Boolean value extracted from data
    local string szStringValue;  // String value extracted from data
    local string szOptionName;   // Name of option in command line option string
    local INT    j,n,pos;        // counters and position variables
	local string InOpt, LeftOpt;

    // Check for the game port number
    if ( left(szKeyWord,len(GamePortMarker)) ~= GamePortMarker ) 
    {
        iIntegerValue = int(mid(szKeyWord,InStr(szKeyWord," ")+1));
        Beacons[iIndex].iPort = iIntegerValue;
    }

    // Check for the marker for the current number of players in the game
    if ( left(szKeyWord,len(NumPlayersMarker)) ~= NumPlayersMarker )
    {   // Decode value
        iIntegerValue = int(mid(szKeyWord,InStr(szKeyWord," ")+1));
        Beacons[iIndex].iNumPlayers = iIntegerValue;
    }

    // Max Players
    else if ( left(szKeyWord,len(MaxPlayersMarker)) ~= MaxPlayersMarker )
    {   // Decode value
        iIntegerValue = int(mid(szKeyWord,InStr(szKeyWord," ")+1));
        Beacons[iIndex].iMaxPlayers = iIntegerValue;
    }

    // Check for the marker for the map name
    else if ( left(szKeyWord,len(MapNameMarker)) ~= MapNameMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);
        Beacons[iIndex].szMapName = szStringValue;
    }

    // Check for the marker for the server name
    else if ( left(szKeyWord,len(SvrNameMarker)) ~= SvrNameMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);
        Beacons[iIndex].szSvrName = szStringValue;
    }

    // Check for the marker for the Game mode
    else if ( left(szKeyWord,len(GameTypeMarker)) ~= GameTypeMarker )
    {   // Decode value
		szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);
		Beacons[iIndex].szCurrGameType = szStringValue;
    }

    // Check for the marker for the dedicated server flag
    else if ( left(szKeyWord,len(DecicatedMarker)) ~= DecicatedMarker )
    {   // Decode value
        bBooleanValue = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
        Beacons[iIndex].bDedicated = bBooleanValue;
    }

    // Check for the marker for the password required flag
    else if ( left(szKeyWord,len(LockedMarker)) ~= LockedMarker )
    {   // Decode value
        bBooleanValue = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
        Beacons[iIndex].bLocked = bBooleanValue;
    }

    // Check for the marker for the Map List
    else if ( left(szKeyWord,len(MapListMarker)) ~= MapListMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);

        for ( j = 0; j < arraycount(Beacons[iIndex].mapList); j++)
            Beacons[iIndex].mapList[j] = "";         // Clear entire list

        j = 0;
        while ( InStr(szStringValue, "/") != -1 )  // -1 is the return value when a string is not found
        {
            szStringValue = mid( szStringValue, InStr( szStringValue, "/" ) + 1 );
            pos = InStr( szStringValue, "/" );
            if ( pos != -1 )
                Beacons[iIndex].mapList[j] = left( szStringValue, pos );
            else // last map in list
                Beacons[iIndex].mapList[j] = szStringValue;
            j++;
        }
    }

    // Check for the marker for the Game mode type List
    else if ( left(szKeyWord,len(MenuGmNameMarker)) ~= MenuGmNameMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);

        for ( j = 0; j < arraycount(Beacons[iIndex].szGameType); j++)
            Beacons[iIndex].szGameType[j] = "RGM_AllMode";         // Clear entire list

        j = 0;
        while ( InStr(szStringValue, "/") != -1 )  // -1 is the return value when a string is not found
        {
            szStringValue = mid( szStringValue, InStr( szStringValue, "/" ) + 1 );
            pos = InStr( szStringValue, "/" );
            if ( pos != -1 )
            {
                Beacons[iIndex].szGameType[j] = left( szStringValue, pos );
            }
            else // last map in list
            {
                Beacons[iIndex].szGameType[j] = szStringValue;
            }
            j++;
        }
    }


    // Check for the marker for the Player List
    else if ( left(szKeyWord,len(PlayerListMarker)) ~= PlayerListMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);

        for ( j = 0; j < arraycount(Beacons[iIndex].szPlayerName); j++)
            Beacons[iIndex].szPlayerName[j] = "";         // Clear entire list

        j = 0;
        while ( InStr(szStringValue, "/") != -1 )  // -1 is the return value when a string is not found
        {
            szStringValue = mid( szStringValue, InStr( szStringValue, "/" ) + 1 );
            pos = InStr( szStringValue, "/" );
            if ( pos != -1 )
                Beacons[iIndex].szPlayerName[j] = left( szStringValue, pos );
            else // last map in list
                Beacons[iIndex].szPlayerName[j] = szStringValue;
            j++;
        }
    }

    // Check for the marker for the Player time
    else if ( left(szKeyWord,len(PlayerTimeMarker)) ~= PlayerTimeMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);

        for ( j = 0; j < arraycount(Beacons[iIndex].szPlayerTime); j++)
            Beacons[iIndex].szPlayerTime[j] = "";         // Clear entire list

        j = 0;
        while ( InStr(szStringValue, "/") != -1 )  // -1 is the return value when a string is not found
        {
            szStringValue = mid( szStringValue, InStr( szStringValue, "/" ) + 1 );
            pos = InStr( szStringValue, "/" );
            if ( pos != -1 )
                Beacons[iIndex].szPlayerTime[j] = left( szStringValue, pos );
            else // last map in list
                Beacons[iIndex].szPlayerTime[j] = szStringValue;
            j++;
        }
    }

    // Check for the marker for the Player ping time
    else if ( left(szKeyWord,len(PlayerPingMarker)) ~= PlayerPingMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);

        for ( j = 0; j < arraycount(Beacons[iIndex].iPlayerPingTime); j++)
            Beacons[iIndex].iPlayerPingTime[j] = 0;         // Clear entire list

        j = 0;
        while ( InStr(szStringValue, "/") != -1 )  // -1 is the return value when a string is not found
        {
            szStringValue = mid( szStringValue, InStr( szStringValue, "/" ) + 1 );
            pos = InStr( szStringValue, "/" );
            if ( pos != -1 )
                Beacons[iIndex].iPlayerPingTime[j] = INT(left( szStringValue, pos ));
            else // last map in list
                Beacons[iIndex].iPlayerPingTime[j] = INT(szStringValue);
            j++;
        }
    }

    // Check for the marker for the player kill count
    else if ( left(szKeyWord,len(PlayerKillMarker)) ~= PlayerKillMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);

        for ( j = 0; j < arraycount(Beacons[iIndex].iPlayerKillCount); j++)
            Beacons[iIndex].iPlayerKillCount[j] = 0;         // Clear entire list

        j = 0;
        while ( InStr(szStringValue, "/") != -1 )  // -1 is the return value when a string is not found
        {
            szStringValue = mid( szStringValue, InStr( szStringValue, "/" ) + 1 );
            pos = InStr( szStringValue, "/" );
            if ( pos != -1 )
                Beacons[iIndex].iPlayerKillCount[j] = INT(left( szStringValue, pos ));
            else // last map in list
                Beacons[iIndex].iPlayerKillCount[j] = INT(szStringValue);
            j++;
        }
    }

    // Map time
//    else if ( left(szKeyWord,len(MapTimeMarker)) ~= MapTimeMarker )
//    {   // Decode value
//        iIntegerValue = FLOAT(mid(szKeyWord,InStr(szKeyWord," ")+1));
//        Beacons[iIndex].fMapTime = iIntegerValue;
//    }

    // Rounds per match (map)
    else if ( left(szKeyWord,len(RoundsPerMatchMarker)) ~= RoundsPerMatchMarker )
    {   // Decode value
        iIntegerValue = FLOAT(mid(szKeyWord,InStr(szKeyWord," ")+1));
        Beacons[iIndex].iRoundsPerMap = iIntegerValue;
    }


    // Round time
    else if ( left(szKeyWord,len(RoundTimeMarker)) ~= RoundTimeMarker )
    {   // Decode value
        iIntegerValue = FLOAT(mid(szKeyWord,InStr(szKeyWord," ")+1));
        Beacons[iIndex].fRndTime = iIntegerValue;
    }

    // Between Round time
    else if ( left(szKeyWord,len(BetTimeMarker)) ~= BetTimeMarker )
    {   // Decode value
        iIntegerValue = FLOAT(mid(szKeyWord,InStr(szKeyWord," ")+1));
        Beacons[iIndex].fBetTime = iIntegerValue;
    }

    // Bomb time
    else if ( left(szKeyWord,len(BombTimeMarker)) ~= BombTimeMarker )
    {   // Decode value
        iIntegerValue = FLOAT(mid(szKeyWord,InStr(szKeyWord," ")+1));
        Beacons[iIndex].fBombTime = iIntegerValue;
    }

    // Show Names 
    else if ( left(szKeyWord,len(ShowNamesMarker)) ~= ShowNamesMarker)
    {   // Decode value
        bBooleanValue = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
        Beacons[iIndex].bShowNames = bBooleanValue;
    }

    // Public server
    else if ( left(szKeyWord,len(InternetServerMarker)) ~= InternetServerMarker)
    {   // Decode value
        bBooleanValue = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
        Beacons[iIndex].bInternetServer = bBooleanValue;
    }

    // Allow friendly
    else if ( left(szKeyWord,len(FriendlyFireMarker)) ~= FriendlyFireMarker)
    {   // Decode value
        bBooleanValue = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
        Beacons[iIndex].bFriendlyFire = bBooleanValue;
    }


    // AutoBalance Team
    else if ( left(szKeyWord,len(AutoBalTeamMarker)) ~= AutoBalTeamMarker)
    {   // Decode value
        bBooleanValue = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
        Beacons[iIndex].bAutoBalTeam = bBooleanValue;
    }

    // Team mate killer penalty
    else if ( left(szKeyWord,len(TKPenaltyMarker)) ~= TKPenaltyMarker)
    {   // Decode value
        bBooleanValue = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
        Beacons[iIndex].bTKPenalty = bBooleanValue;
    }

    // Allow Radar
    else if ( left(szKeyWord,len(AllowRadarMarker)) ~= AllowRadarMarker)
    {   // Decode value
        bBooleanValue = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
        Beacons[iIndex].bRadar = bBooleanValue;
    }

    // Game Version
    else if ( left(szKeyWord,len(GameVersionMarker)) ~= GameVersionMarker)
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);
        Beacons[iIndex].szGameVersion = szStringValue;
    }

    // Check for the lobby server ID number
    else if ( left(szKeyWord,len(LobbyServerIDMarker)) ~= LobbyServerIDMarker ) 
    {
        Beacons[iIndex].iLobbyID = int(mid(szKeyWord,InStr(szKeyWord," ")+1));
    }

    // Check for the group ID number
    else if ( left(szKeyWord,len(GroupIDMarker)) ~= GroupIDMarker ) 
    {
        Beacons[iIndex].iGroupID = int(mid(szKeyWord,InStr(szKeyWord," ")+1));
    }

    // Check for the Beacon Port Number
    else if ( left(szKeyWord,len(BeaconPortMarker)) ~= BeaconPortMarker ) 
    {
        Beacons[iIndex].iBeaconPort = int(mid(szKeyWord,InStr(szKeyWord," ")+1));
    }

    // Check for the Number of terrorists
    else if ( left(szKeyWord,len(NumTerroMarker)) ~= NumTerroMarker ) 
    {
        Beacons[iIndex].iNumTerro = int(mid(szKeyWord,InStr(szKeyWord," ")+1));
    }

    // Check for AI Backup
    else if ( left(szKeyWord,len(AIBkpMarker)) ~= AIBkpMarker ) 
    {
        Beacons[iIndex].bAIBkp = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
    }

    // Check for Rotate Map
    else if ( left(szKeyWord,len(RotateMapMarker)) ~= RotateMapMarker ) 
    {
        Beacons[iIndex].bRotateMap = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
    }

    // Check for force first person weapons
    else if ( left(szKeyWord,len(ForceFPWpnMarker)) ~= ForceFPWpnMarker ) 
    {
        Beacons[iIndex].bForceFPWpn = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
    }
    
    // MPF
    // Check for the marker for the MOD name 
    else if ( left(szKeyWord,len(ModNameMarker)) ~= ModNameMarker )
    {   // Decode value
    	szStringValue =  mid(szKeyWord,InStr(szKeyWord," ")+1);
        Beacons[iIndex].szModName = szStringValue;
    }

//#ifdef R6PUNKBUSTER
    // Check if PunkBuster is enabled
    else if ( left(szKeyWord,len(PunkBusterMarker)) ~= PunkBusterMarker ) 
    {
        Beacons[iIndex].bPunkBuster = BOOL(int(mid(szKeyWord,InStr(szKeyWord," ")+1)));
    }
//#endif R6PUNKBUSTER


}

//#endif//R6CODE

defaultproperties
{
}
