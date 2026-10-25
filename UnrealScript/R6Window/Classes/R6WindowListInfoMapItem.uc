//=============================================================================
//  R6WindowListServerInfoItem.uc : Class used to hold the values for 
//  the entries in the list of maps in the ServerInfo tab in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================


class R6WindowListInfoMapItem extends UWindowListBoxItem;

// Variables holding infomation on servers

var string  szMap;          // Map name 
var string  szType;         // Game type

// Variables used to define X position of the fields in the
// server list menu.

var FLOAT   fMapXOff;
var FLOAT   fTypeXOff;

var FLOAT   fMapWidth;
var FLOAT   fTypeWidth;

defaultproperties
{
     fMapXOff=5.000000
     fTypeXOff=68.000000
     fMapWidth=60.000000
     fTypeWidth=159.000000
}
