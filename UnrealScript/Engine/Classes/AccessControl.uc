//=============================================================================
// AccessControl.
//
// AccessControl is a helper class for GameInfo.
// The AccessControl class determines whether or not the player is allowed to 
// login in the PreLogin() function, and also controls whether or not a player 
// can enter as a spectator or a game administrator.
//
//=============================================================================

/* #ifndef R6CODE 
class AccessControl extends Info;
#else */
class AccessControl extends Info
    config(BanList);
/* #endif R6CODE */



/* #ifndef R6CODE 
var globalconfig string     IPPolicies[50];
var	localized string          IPBanned;
#endif R6CODE */

/* #ifndef R6CODE
var private globalconfig string AdminPassword;	    // Password to receive bAdmin privileges.
var private globalconfig string GamePassword;		    // Password to enter game.
#else */
var private string AdminPassword;	    // Password to receive bAdmin privileges.
var private string GamePassword;		    // Password to enter game.

var config Array<string> Banned;

/* #endif R6CODE */


function SetAdminPassword(string P)
{
	AdminPassword = P;
}

function SetGamePassword(string P)
{
	GamePassword = P;
}

//#ifdef R6CODE 
function string GetGamePassword()
{
    return GamePassword;
}
// added by John Bennett - April 2002
// This funtions simply returns a boolean to indicate if this game
// requires a password or not, this information is used in UDPBeacon.uc

function BOOL GamePasswordNeeded()
{
    return ( GamePassword != "" );
}



function KickBan( string S ) 
{
    local Controller _Ctrl;
	local PlayerController P;
	local string ID;
	local int j;
    local int i;

    for (_Ctrl=Level.ControllerList; _Ctrl!=None; _Ctrl=_Ctrl.NextController )
    {
        P = PlayerController(_Ctrl);
        if ( (P != none) && 
            (P.PlayerReplicationInfo.PlayerName~=S) &&
            (NetConnection(P.Player)!=None) )
        {
			ID = P.m_szGlobalID;

            // check if not alredy banned
			if( !IsGlobalIDBanned(ID) )
			{
				//ID = Left(ID, InStr(ID, ":"));
				Log("Adding ID Ban for: "$Caps(ID) );
                Banned[Banned.Length] = Caps(ID);
                SaveConfig();
			}
			return;
        }
    }
}

function int RemoveBan(string szBanPrefix)
{
    local int i;
    local int iMatchesFound;
    local int iPosFound;

    iMatchesFound = 0;

    i=-1;
    do
    {
        i++;
        i = NextMatchingID(szBanPrefix, i);
        if (i>-1)
        {
            iMatchesFound++;
            iPosFound = i;
        }
    }
    until (i == -1);

    if (iMatchesFound==1)
    {
        Banned.Remove(iPosFound,1);
        SaveConfig();
    }
    return iMatchesFound;
}

function int NextMatchingID(string szBanPrefix, int iLastIt)
{
    local int i;
    for ( i = iLastIt; i < Banned.Length; i++ )
    {
        if ( Strnicmp(Banned[i], szBanPrefix, Len(szBanPrefix))==0)
        {
            //log("Matches "$Banned[i]);
            return i;
        }
    }
    if (i >= Banned.Length)
    {
        return -1;
    }
}

//function bool AdminLogin( PlayerController P, string Password )
//{
//    log("This is the wrong AdminLogin in "$self);
//	if (AdminPassword == "")
//		return false;
//
//	if (Password == AdminPassword)
//	{
//		Log("Administrator logged in.");
//		Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName$"logged in as a server administrator." );
//		return true;
//	}
//	return false;
//}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//

// R6MODIFICATION
event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode,
	bool bSpectator
)

{
	// Do any name or password or name validation here.
	local string InPassword, SpectatorClass;
	local PlayerController P;

	Error="";
	InPassword = Level.Game.ParseOption( Options, "Password" );

	if( (Level.NetMode != NM_Standalone) && Level.Game.AtCapacity(bSpectator) )
	{
        Error="PopUp_Error_ServerFull";
	}

    // Changed by J. Bennett.  Removed the caps macro so that
    // the passwords would be case sensitive (to be compatible
    // with ubi.com)
    //
    //  old code:
    //
    //	&&	caps(InPassword)!=caps(GamePassword)
    //	&&	(AdminPassword=="" || caps(InPassword)!=caps(AdminPassword)) )

	else if
	(	GamePassword!=""
	&&	(InPassword)!=(GamePassword)
	&&	(AdminPassword=="" || (InPassword)!=(AdminPassword)) )
	{
        Error = "PopUp_Error_PassWd";
        FailCode = "WRONGPW";
    }

/* r6code now it's done later...
	if(!CheckIDPolicy(Address))
		Error = IPBanned;
*/    
}


event bool IsGlobalIDBanned(string GlobalID )
{
	local int i;
    local string szGlobalID;
    for ( i = 0; i < Banned.Length; ++i )
    {
        if ( Banned[i] ~= GlobalID )
            return true;
    }
    return false;
}
