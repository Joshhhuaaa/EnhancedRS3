class R6AbstractGameService extends Object
	native;

var PlayerController m_LocalPlayerController;
var config string m_szUserID;               // User login name for GameService

var BOOL    m_bServerWaitMatchStartReply;   // we have to reset this to true when we are going to a new round
var BOOL    m_bClientWaitMatchStartReply;   // we have to reset this to true when we are going to a new round
var BOOL    m_bClientWillSubmitResult;      // if this client will be required to do score submission
var BOOL    m_bWaitSubmitMatchReply;
var BOOL    m_bMSClientLobbyDisconnect;     // The connection for the MSClient lobby server has been lost
var BOOL m_bMSClientRouterDisconnect;       // The connection for the MSClient router has been lost

native(1297) final function         NativeSubmitMatchResult();
function CallNativeSetMatchResult(string szUbiUserID, INT iField, INT iValue);
function BOOL CallNativeProcessIcmpPing(string _ServerIpAddress, out INT piPingTime);function string MyID();

defaultproperties
{
}
