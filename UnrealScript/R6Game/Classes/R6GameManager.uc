//=============================================================================
// R6GameManager.uc: game manager object.
//
// Revision history:
//      * 22-04-2003 : Created by Jean-Francois Dube
//=============================================================================
class R6GameManager extends R6AbstractGameManager
    native;

var R6GSServers m_GameMgrGameService;

var R6Console   m_GameMgrConsole;

function SetConsoleInGameMgr(Console _pConsole)
{
    m_GameMgrConsole = R6Console(_pConsole);
}

function Object GetGameMgrGameService()
{
    return m_GameMgrGameService;
}

function SetLocalPlayerCtrl(PlayerController _localPlayer)
{
    m_GameMgrGameService.m_LocalPlayerController = _localPlayer;
}

event GMProcessMsg(string _szMsg)
{
    if (m_GameMgrConsole != none)
        m_GameMgrConsole.Root.ProcessGSMsg(_szMsg);
}

defaultproperties
{
}
