//=============================================================================
//  R6WindowListServerInfoItem.uc : Class used to hold the values for 
//  the entries in the list of players in the ServerInfo tab in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================


class R6WindowListInfoPlayerItem extends UWindowListBoxItem;

// Variables holding infomation on servers

var string  szPlName;       // Player Name
var INT     iSkills;        //
var string  szTime;         // Total time the player has been playing at this server
var INT     iPing;          // Ping time to players computer
var INT     iRank;          // Player Rank

// Variables used to define X position of the fields in the
// server list menu.

var FLOAT   fNameXOff;
var FLOAT   fSkillsXOff;
var FLOAT   fTimeXOff;
var FLOAT   fPingXOff;

var FLOAT   fNameWidth;

defaultproperties
{
     fNameXOff=5.000000
     fSkillsXOff=91.000000
     fTimeXOff=50.000000
     fPingXOff=50.000000
     fNameWidth=86.000000
}
