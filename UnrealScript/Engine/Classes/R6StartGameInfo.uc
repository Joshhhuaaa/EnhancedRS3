/********************************************************************
	created:	2001/06/19
	filename: 	R6StartGameInfo.uc
	author:		Joel Tremblay
	
	purpose:	Informations set in the menu are stored here before
                the game/mission is launched.
                Used only by the menu,
                Has no influence once the game is started
	
	Modification:

*********************************************************************/

class R6StartGameInfo extends actor
    native;

var  string  m_MapName;
var     INT  m_DifficultyLevel;
var     INT  m_CurrentMenu;
var  string  m_GameMode;
var    BOOL  m_SkipPlanningPhase; // Once the map is in memory, start directly whithout planning
var    BOOL  m_ReloadPlanning;    // Once the map is in memory, load backup/backup.pln  
var    BOOL  m_ReloadActionPointOnly; // when loading backup plan, do not load operatives 
var     INT  m_iNbTerro;           // This is for terro hunt  

var Object m_CurrentMission;

var config R6TeamStartInfo  m_TeamInfo[3];
var    BOOL m_bIsPlaying;
var    INT  m_iTeamStart;
//var             CustomMissionInfo;

function Save()
{
}

function Load()
{
}

defaultproperties
{
     m_iNbTerro=35
}
