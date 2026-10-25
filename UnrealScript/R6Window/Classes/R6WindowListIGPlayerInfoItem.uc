//=============================================================================
//  R6WindowListBoxItem.uc : Class used to hold the values for the entries
//  in the list of servers in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/28 * Created by John Bennett
//=============================================================================


class R6WindowListIGPlayerInfoItem extends UWindowListBoxItem;

enum ePlStatus
{
    ePlayerStatus_Alive,
    ePlayerStatus_Wounded,
    ePlayerStatus_Incapacitated,
    ePlayerStatus_Dead,
	ePlayerStatus_Spectator,
    ePlayerStatus_TooLate
};

// this enum serve for store value in array (the order is what's displaying on the screen)
enum ePLInfo
{
	ePL_Ready,
	ePL_HealthStatus,
	ePL_Name,
	ePL_RoundsWon,
	ePL_Kill,
	ePL_DeadCounter,
	ePL_Efficiency,
	ePL_RoundFired,
	ePL_RoundHit,
	ePL_KillerName,
	ePL_PingTime,
};

struct stSettings
{
    var FLOAT    fXPos;
    var FLOAT    fWidth;
	var BOOL	 bDisplay;
};

const C_NB_OF_PLAYER_INFO  = 11;

// Variables holding infomation on servers
var string      szPlName;                   // Player name
var string      szKillBy;                   // Kill by (This icon show the name of the killer)
var string		szRoundsWon;				// Nb of rounds wons on nb of round play

var ePlStatus   eStatus;                    // Status of the player at the end of the round

var INT         iKills;                     // Number of kills
var INT			iMyDeadCounter;				// Number of time I die
var INT         iEfficiency;                // Efficiency (hits/shot)
var INT         iRoundsFired;               // Rounds fired (Bullets shot by the player)
var INT         iRoundsHit;                 // Bullets shot by the player and that hit somebody
var INT         iPingTime;                  // ping (The delay between player and server communication)

var BOOL        bOwnPlayer;                 // This player is the player on this computer
var BOOL		bReady;						// The player is ready

var INT         m_iRainbowTeam;             // This is for single player to know in wich team the rainbow is //0= Red, 1=Green, 2=Gold
var INT         m_iOperativeID;             // This is usefull when we try to retreive the r6rainbow class

// Variables used to define X position of the fields in the
// server list menu.
var stSettings  stTagCoord[C_NB_OF_PLAYER_INFO];   //

function INT GetHealth( ePlStatus _ePLStatus)
{
    switch( _ePLStatus )
    {
		case ePlayerStatus_Alive:
			return 0;
		case ePlayerStatus_Wounded:
			return 1;
        case ePlayerStatus_Incapacitated:
            return 2;
		case ePlayerStatus_Dead:
			return 3;
		case ePlayerStatus_Spectator:
			return 4;
		default:
			return 0;
    }
}

defaultproperties
{
}
