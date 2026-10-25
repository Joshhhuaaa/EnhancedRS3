//=============================================================================
//  R6AbstractGameManager.uc : game manager object.
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//  Revision history:
//      * 18-08-2003 : Created by Yannick Joly
//=============================================================================

class R6AbstractGameManager extends Object
    native;

var BOOL m_bGSClientInitialized;     // The GG client SDK has been intialized
var bool m_bStartedByGSClient;  // Flag to indicate if the game was launched by the ubi.com client
var BOOL m_bReturnToGSClient;   // Minimize game and return to ubi.com client
var BOOL m_bGSClientAlreadyInit;
var BOOL m_bMultiPlayerGameActive;
var BOOL m_bGSJoinUbiServer;
var BOOL m_bQueryServerInfoDone;

native(1284) final function StartJoinServer( string _szIPAddress, string _szOptions, INT _iPlayerSpawnNumber );
native(1285) final function LaunchListenSrv( string _szMap, string _szMode );
native(1286) final function ClientLeaveServer();
native(1287) final function BOOL ConnectionInterrupted( optional BOOL _bUserDisconnect );
native(1288) final function StartPreJoinProcedure();
native(1289) final function StartLogInProcedure();
native(1290) final function StopGSClientProcedure();
native(1201) static final function BOOL IsGSCreateUbiServer();
native(1203) final function SetGSCreateUbiServer( BOOL gsCreateUbiServer );

function SetConsoleInGameMgr( Console _pConsole );
function Object GetGameMgrGameService();
function SetLocalPlayerCtrl( PlayerController _localPlayer );
event GMProcessMsg( string _szMsg );

defaultproperties
{
}
