//=============================================================================
//  R6WindowListServerInfoItem.uc : Class used to hold the values for 
//  the entries in the list of options in the ServerInfo tab in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================


class R6WindowListInfoOptionsItem extends UWindowListBoxItem;

// Variables holding infomation on servers


var string  szOptions;      // ServerOptions


// Variables used to define X position of the fields in the
// server list menu.


var FLOAT   fOptionsXOff;

defaultproperties
{
     fOptionsXOff=5.000000
}
