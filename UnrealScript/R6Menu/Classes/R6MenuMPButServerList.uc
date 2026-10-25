//=============================================================================
//  R6MenuMPButServerList.uc : manage buttons for server list
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/19  * Create by Yannick Joly
//=============================================================================
class R6MenuMPButServerList extends UWindowDialogClientWindow;

// X Pos of Buttons
const C_fX_FAVORITES		= 0;

// Width of Buttons -- according the value in server list -- Total size of window 618
const C_fW_FAVORITES		= 15;
const C_fW_LOCKED			= 15;
const C_fW_DEDICATED		= 15;
//#ifdefR6PUNKBUSTER
const C_fW_PUNKBUSTER		= 15;
//#endif
const C_fW_NAME				= 155;
const C_fW_PING				= 40;
const C_fW_GAMEMODE			= 100;
const C_fW_GAMETYPE			= 100;
const C_fW_MAP				= 100;
const C_fW_PLAYERS			= 63;

var R6WindowButtonSort				m_pButFavorites;
var R6WindowButtonSort				m_pButLocked;
var R6WindowButtonSort				m_pButDedicated;
//#ifdefR6PUNKBUSTER
var R6WindowButtonSort				m_pButPunkBuster;
//#endif
var R6WindowButtonSort				m_pButPingTime;
var R6WindowButtonSort				m_pButName;
var R6WindowButtonSort				m_pButGameType;
var R6WindowButtonSort				m_pButGameMode;
var R6WindowButtonSort				m_pButMap;
var R6WindowButtonSort				m_pButNumPlayers;

var R6WindowButtonSort				m_pLastButtonClick;


function Created()
{
	local R6ServerList pSLDummy;
	local FLOAT fXOffset;

	pSLDummy = R6MenuMultiPlayerWidget(OwnerWindow).m_GameService;

	fXOffset = C_fX_FAVORITES;
	CreateServerListButton( pSLDummy.eSortCategory.eSG_Favorite, "InfoBar_F", "InfoBar_F", fXOffset, C_fW_FAVORITES, m_pButFavorites);	
	fXOffset += C_fW_FAVORITES;
	CreateServerListButton( pSLDummy.eSortCategory.eSG_Locked, "InfoBar_L", "InfoBar_L", fXOffset, C_fW_LOCKED, m_pButLocked);
	fXOffset += C_fW_LOCKED;
	CreateServerListButton( pSLDummy.eSortCategory.eSG_Dedicated, "InfoBar_D", "InfoBar_D", fXOffset, C_fW_DEDICATED, m_pButDedicated);
	fXOffset += C_fW_DEDICATED;
//#ifdefR6PUNKBUSTER
	CreateServerListButton( pSLDummy.eSortCategory.eSG_PunkBuster, "InfoBar_P", "InfoBar_P", fXOffset, C_fW_PUNKBUSTER, m_pButPunkBuster);
	fXOffset += C_fW_PUNKBUSTER;
//#endif
	CreateServerListButton( pSLDummy.eSortCategory.eSG_Name, "InfoBar_Server", "InfoBar_Server", fXOffset, C_fW_NAME, m_pButName);
	fXOffset += C_fW_NAME;
	CreateServerListButton( pSLDummy.eSortCategory.eSG_PingTime, "InfoBar_Ping", "InfoBar_Ping", fXOffset, C_fW_PING, m_pButPingTime);
	fXOffset += C_fW_PING;
	CreateServerListButton( pSLDummy.eSortCategory.eSG_GameType, "InfoBar_Type", "InfoBar_Type", fXOffset, C_fW_GAMETYPE, m_pButGameType);
	fXOffset += C_fW_GAMETYPE;
	CreateServerListButton( pSLDummy.eSortCategory.eSG_GameMode, "InfoBar_GameMode", "InfoBar_GameMode", fXOffset, C_fW_GAMEMODE, m_pButGameMode);
	fXOffset += C_fW_GAMEMODE;
	CreateServerListButton( pSLDummy.eSortCategory.eSG_Map, "InfoBar_Map", "InfoBar_Map", fXOffset, C_fW_MAP, m_pButMap);
	fXOffset += C_fW_MAP;
	CreateServerListButton( pSLDummy.eSortCategory.eSG_NumPlayers, "InfoBar_Players", "InfoBar_Players", fXOffset, C_fW_PLAYERS, m_pButNumPlayers);

	// the default sort is by ping
	m_pButPingTime.m_bDrawSortIcon = true;
	m_pButPingTime.m_bAscending	   = true;

	m_pLastButtonClick = m_pButPingTime;
}

function CreateServerListButton( INT _iButtonID, string _szName, string _szTip, FLOAT _FX, FLOAT _fWidth, out R6WindowButtonSort _R6Button)
{
	_R6Button = R6WindowButtonSort(CreateControl( class'R6WindowButtonSort', _FX, 0, _fWidth, WinHeight, self));
    _R6Button.ToolTipString  = Localize("Tip", _szTip,"R6Menu");
    _R6Button.Text			 = Localize("MultiPlayer", _szName,"R6Menu");
	_R6Button.Align			 = TA_Center;
	_R6Button.m_buttonFont   = Root.Fonts[F_VerySmallTitle];
	_R6Button.m_iButtonID	 = _iButtonID;
}

function Notify(UWindowDialogControl C, byte E)
{
	local BOOL bTypeOfSort;

	if(E == DE_Click)
	{
		bTypeOfSort = R6MenuMultiPlayerWidget(OwnerWindow).m_bLastTypeOfSort;

		if (m_pLastButtonClick == None) // the first time only
			m_pLastButtonClick = R6WindowButtonSort(C);

		// "reset" last button
		m_pLastButtonClick.m_bDrawSortIcon = false;

		if (m_pLastButtonClick == R6WindowButtonSort(C))
		{
			bTypeOfSort = !bTypeOfSort;
		}
		else
		{
			m_pLastButtonClick = R6WindowButtonSort(C);
		}

		R6WindowButtonSort(C).m_bDrawSortIcon = true;
		R6WindowButtonSort(C).m_bAscending = bTypeOfSort;

		// sort
		R6MenuMultiPlayerWidget(OwnerWindow).ResortServerList( R6WindowButtonSort(C).m_iButtonID, bTypeOfSort);
	}
}

defaultproperties
{
}
