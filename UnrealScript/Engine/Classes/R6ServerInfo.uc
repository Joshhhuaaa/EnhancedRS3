class R6ServerInfo extends Object
	config(server)
    native;

var config string ServerName;
var config bool CamFirstPerson;
var config bool CamThirdPerson;
var config bool CamFreeThirdP;
var config bool CamGhost;
var config bool CamFadeToBlack;
var config bool CamTeamOnly;
var config int MaxPlayers;
var config int NbTerro;

var config bool UsePassword;
var config string GamePassword;

var config float SpamThreshold;  //3 or more "say" inside that period (seconds) trigger ChatLock
var config float ChatLockDuration;	//Duration of ChatLock (seconds)
var config float VoteBroadcastMaxFrequency; //Delay (seconds) before sending a new vote broadcast

var config string MOTD;

var config int RoundTime;
var config int RoundsPerMatch;
var config int BetweenRoundTime;

var config bool   UseAdminPassword;
var config string AdminPassword;

var config int BombTime;
var config INT DiffLevel;

var config bool ShowNames;
var config bool InternetServer;
var config bool DedicatedServer;
var config bool FriendlyFire;
var config bool Autobalance;
var config bool TeamKillerPenalty;
var config bool AllowRadar;
var config bool ForceFPersonWeapon;
var config bool AIBkp;
var config bool RotateMap;
var config Array<class> RestrictedSubMachineGuns;
var config Array<class> RestrictedShotGuns;
var config Array<class> RestrictedAssultRifles;
var config Array<class> RestrictedMachineGuns;
var config Array<class> RestrictedSniperRifles;
var config Array<class> RestrictedPistols;
var config Array<class> RestrictedMachinePistols;
var config Array<string> RestrictedPrimary;
var config Array<string> RestrictedSecondary;
var config Array<string> RestrictedMiscGadgets;
var R6MapList m_ServerMapList;
var GameInfo m_GameInfo;

// on reset we want to avoid reloading the original values
// we want to keep proper config values
function PostBeginPlay()
{
}

function ClearSettings()
{
    RestrictedSubMachineGuns.remove(0, RestrictedSubMachineGuns.length);    
    RestrictedSubMachineGuns.remove(0, RestrictedSubMachineGuns.length);    
    RestrictedShotGuns.remove(0, RestrictedShotGuns.length);    
    RestrictedAssultRifles.remove(0, RestrictedAssultRifles.length);    
    RestrictedMachineGuns.remove(0, RestrictedMachineGuns.length);    
    RestrictedSniperRifles.remove(0, RestrictedSniperRifles.length);    
    RestrictedPistols.remove(0, RestrictedPistols.length);    
    RestrictedMachinePistols.remove(0, RestrictedMachinePistols.length);    
    RestrictedPrimary.remove(0, RestrictedPrimary.length);    
    RestrictedSecondary.remove(0, RestrictedSecondary.length);    
    RestrictedMiscGadgets.remove(0, RestrictedMiscGadgets.length);    
}

event RestartServer()
{
    if (m_GameInfo!=none)
    {
        m_GameInfo.AbortScoreSubmission();
        m_GameInfo.bChangeLevels = true;
        m_GameInfo.m_bChangedServerConfig = true;
        m_GameInfo.SetJumpingMaps(true, 0);
        m_GameInfo.RestartGameMgr();
    }
}

defaultproperties
{
     MaxPlayers=8
     NbTerro=32
     RoundTime=600
     RoundsPerMatch=20
     BetweenRoundTime=20
     BombTime=45
     DiffLevel=1
     CamFirstPerson=True
     CamThirdPerson=True
     CamFreeThirdP=True
     CamGhost=True
     UseAdminPassword=True
     ShowNames=True
     InternetServer=True
     DedicatedServer=True
     FriendlyFire=True
     Autobalance=True
     TeamKillerPenalty=True
     AllowRadar=True
     RotateMap=True
     SpamThreshold=5.000000
     ChatLockDuration=15.000000
     VoteBroadcastMaxFrequency=15.000000
     ServerName="test"
     MOTD="Welcome to Raven Shield"
     AdminPassword="111"
}
