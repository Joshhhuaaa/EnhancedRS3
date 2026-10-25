//=============================================================================
//  R6WindowListBoxItem.uc : Class used to hold the values for the entries
//  in the list of servers in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/28 * Created by John Bennett
//=============================================================================


class R6WindowListServerItem extends UWindowListBoxItem;

enum eServerItem
{
	eSI_Favorites,
	eSI_Locked,
	eSI_Dedicated,
//#ifdefR6PUNKBUSTER
	eSI_PunkBuster,
//#endif
	eSI_ServerName,
	eSI_Ping,
	eSI_GameType,
	eSI_GameMode,
	eSI_Map,
	eSI_Players
};

// Variables holding infomation on servers

var BOOL    bFavorite;      // Favorite server
var BOOL    bLocked;        // Server requires a password
var BOOL    bDedicated;     // Server is a dedicated server
//#ifdefR6PUNKBUSTER
var BOOL	bPunkBuster;	// Server with punk buster
//#endif
var STRING  szIPAddr;       // IP Address of server, eg 1.2.3.4
var STRING  szName;         // Name of server
var INT     iPing;          // Ping time to server
var STRING  szGameMode;     // Game mode (adversarial or cooperative)
var STRING  szMap;          // Map name (first map to be played)
var INT     iMaxPlayers;    // Max number of players allowed
var INT     iNumPlayers;    // Current number of players
var STRING  szGameType;     // Game type (deathmatch, Mission, etc).
var INT     iMainSvrListIdx;// The index of this intem in the main server list
var BOOL    bSameVersion;   // The server s the same version as the client
var BOOL    m_bNewItem;		// it's a new item

// Variables used to define X position of the fields in the
// server list menu.

var stCoordItem m_stServerItemPos[10];
 
function Created()
{
	m_bNewItem = true;

	// Favorite
	m_stServerItemPos[eServerItem.eSI_Favorites].fXPos   = 0;
	m_stServerItemPos[eServerItem.eSI_Favorites].fWidth  = 15;
	// Locked
	m_stServerItemPos[eServerItem.eSI_Locked].fXPos		 = m_stServerItemPos[eServerItem.eSI_Favorites].fXPos + m_stServerItemPos[eServerItem.eSI_Favorites].fWidth;
	m_stServerItemPos[eServerItem.eSI_Locked].fWidth	 = 15;
	// Dedicated
	m_stServerItemPos[eServerItem.eSI_Dedicated].fXPos   = m_stServerItemPos[eServerItem.eSI_Locked].fXPos + m_stServerItemPos[eServerItem.eSI_Locked].fWidth;
	m_stServerItemPos[eServerItem.eSI_Dedicated].fWidth  = 15;
//#ifdefR6PUNKBUSTER
	// PunkBuster
	m_stServerItemPos[eServerItem.eSI_PunkBuster].fXPos   = m_stServerItemPos[eServerItem.eSI_Dedicated].fXPos + m_stServerItemPos[eServerItem.eSI_Dedicated].fWidth;
	m_stServerItemPos[eServerItem.eSI_PunkBuster].fWidth  = 15;
	// Server Name
	m_stServerItemPos[eServerItem.eSI_ServerName].fXPos  = m_stServerItemPos[eServerItem.eSI_PunkBuster].fXPos + m_stServerItemPos[eServerItem.eSI_PunkBuster].fWidth;
	m_stServerItemPos[eServerItem.eSI_ServerName].fWidth = 155;
//#endif
	// Ping
	m_stServerItemPos[eServerItem.eSI_Ping].fXPos		 = m_stServerItemPos[eServerItem.eSI_ServerName].fXPos + m_stServerItemPos[eServerItem.eSI_ServerName].fWidth;
	m_stServerItemPos[eServerItem.eSI_Ping].fWidth		 = 40;
	// GameType
	m_stServerItemPos[eServerItem.eSI_GameType].fXPos    = m_stServerItemPos[eServerItem.eSI_Ping].fXPos + m_stServerItemPos[eServerItem.eSI_Ping].fWidth;
	m_stServerItemPos[eServerItem.eSI_GameType].fWidth   = 100;
	// GameMode
	m_stServerItemPos[eServerItem.eSI_GameMode].fXPos    = m_stServerItemPos[eServerItem.eSI_GameType].fXPos + m_stServerItemPos[eServerItem.eSI_GameType].fWidth;
	m_stServerItemPos[eServerItem.eSI_GameMode].fWidth   = 100;
	// Map
	m_stServerItemPos[eServerItem.eSI_Map].fXPos		 = m_stServerItemPos[eServerItem.eSI_GameMode].fXPos + m_stServerItemPos[eServerItem.eSI_GameMode].fWidth;
	m_stServerItemPos[eServerItem.eSI_Map].fWidth		 = 100;
	// Players
	m_stServerItemPos[eServerItem.eSI_Players].fXPos     = m_stServerItemPos[eServerItem.eSI_Map].fXPos + m_stServerItemPos[eServerItem.eSI_Map].fWidth;
	m_stServerItemPos[eServerItem.eSI_Players].fWidth    = 63;
}

defaultproperties
{
}
