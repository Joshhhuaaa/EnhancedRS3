//=============================================================================
//  R6RainbowTeam.uc : The R6RainbowTeam class is where the AI for the Rainbow
//					   team will be implemented.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//=============================================================================
class R6RainbowTeam extends Actor
    native;


const c_iMaxTeam = 4;

var         INT						m_iMemberCount;
var         R6Rainbow               m_Team[c_iMaxTeam];
var         COLOR                   m_TeamColour;
var         R6GameColors            Colors;

var         R6RainbowPlayerVoices       m_PlayerVoicesMgr;
var         R6RainbowMemberVoices       m_MemberVoicesMgr;
var         R6RainbowOtherTeamVoices    m_OtherTeamVoicesMgr;
var         R6MultiCommonVoices         m_MultiCommonVoicesMgr;
var         R6MultiCoopVoices           m_MultiCoopPlayerVoicesMgr;
var         R6MultiCoopVoices           m_MultiCoopMemberVoicesMgr;
var         R6PreRecordedMsgVoices      m_PreRecMsgVoicesMgr;

var         INT                         m_iIDVoicesMgr;

// each bit is used by the client for the RoseDesVents. 
// and is examined to see if we have a team member with
// a specific grenade type, this is more effecient than 
// replicate all the info for all weapons
var         BYTE                    m_bHasGrenade;
var         R6Rainbow               m_TeamLeader;
var         R6AbstractPlanningInfo  m_TeamPlanning;       

// status flags
var         bool                    m_bLeaderIsAPlayer;                 // the leader of this team is not an NPC (is a player)
var         bool                    m_bPlayerHasFocus;                  // When the player is in observer mode on the current team
var         bool                    m_bPlayerInGhostMode;       
var         bool                    m_bTeamIsClimbingLadder;            // team is in the process of climbing a ladder
var         bool                    m_bTeamIsSeparatedFromLeader;       // team was either told to hold position or to perform an action (e.g. climb ladder)
var			bool					m_bGrenadeInProximity;				// frag grenade
var			bool					m_bGasGrenadeInProximity;			// tear gas grenade

// doors & room entry
var         bool                    m_bEntryInProgress;                 // a room entry is in progress
var         bool                    m_bDoorOpensTowardTeam;
var         bool                    m_bDoorOpensClockWise;
var			bool					m_bRainbowIsInFrontOfDoor;

var         bool                    m_bWoundedHostage;                  // true if an escorted hostage is wounded

var         R6Pawn                  m_PawnControllingDoor;

// team info to maintain for members
var         rotator                 m_rTeamDirection;                   // rotator that maintains the direction of movement of the team leader 
var         R6RainbowAI.eFormation  m_eFormation;                       // team formation
var         R6RainbowAI.eFormation  m_eRequestedFormation;
var         INT                     m_iFormationDistance;               // standard distance between members when in a movement formation
var         INT                     m_iDiagonalDistance;        
var         INT                     m_iTeamHealth[c_iMaxTeam];                   // information for HUD... (information stays even if a member is dead)
var         INT                     m_iMembersLost;
var         INT                     m_iGrenadeThrower;                  // index of the last member who throwed a grenade

var			INT						m_iIntermLeader;					// used for temporary reorganisation of team; to keep track of who original lead was
var         INT                     m_iSpawnDistance;                   // distance used to spawn characters next to the start point
var         INT                     m_iSpawnDiagDist;                   // distance used to spawn characters diagonaly to the start point
var         INT                     m_iSpawnDiagOther;                  // distance used to spawn characters around the start point(not diagonaly or next to)

// ladder climbing
var         R6Ladder                m_TeamLadder;

// door control, room entry
//var         INT                     m_iAction;                          // contains the desired action to take... (door: OPEN/CLOSE)
var         INT                     m_iSubAction;                       // contains the desired sub action to take...
var         R6Door                  m_Door;                             // reference to a door actor involved in a room entry

var	enum ePlayerRoomEntry
{
	PRE_Center,
	PRE_Left,
	PRE_Right
} m_ePlayerRoomEntry;

var         INT                     m_iRainbowTeamName; 

var			R6CircumstantialActionQuery		m_actionRequested;
var			vector							m_vActionLocation;
var         BOOL							m_bCAWaitingForZuluGoCode;	

// Prevent using team for training
var         BOOL                            m_bPreventUsingTeam;
/*
//
// Bitflags.
const	TEAM_None					= 0x00000;
const	TEAM_Orders					= 0x00001;		// actions were received as orders from player and not initiated by AI (therefore requiring acknowledgement)
	
const	TEAM_OpenDoor				= 0x00010;
const	TEAM_CloseDoor				= 0x00020;
const	TEAM_Grenade				= 0x00040;
const	TEAM_ClearRoom				= 0x00080;
const	TEAM_Move					= 0x00100;
const	TEAM_ClimbLadder			= 0x00200;
const	TEAM_SecureTerrorist		= 0x00400;
const	TEAM_EscortHostage			= 0x00800;
const	TEAM_DisarmBomb				= 0x01000;
const	TEAM_InteractDevice			= 0x02000;

const	TEAM_OpenAndClear			= 0x00090;		// TEAM_OpenDoor | TEAM_ClearRoom;
const	TEAM_OpenAndGrenade			= 0x00050;		// TEAM_OpenDoor | TEAM_Grenade;
const	TEAM_OpenGrenadeAndClear	= 0x000d0;		// TEAM_OpenDoor | TEAM_ClearRoom | TEAM_Grenade;
const	TEAM_GrenadeAndClear		= 0x000c0;		// TEAM_Grenade | TEAM_ClearRoom;
const	TEAM_MoveAndGrenade			= 0x00140;		// TEAM_Move | TEAM_Grenade;
//
*/

var		INT		m_iTeamAction;
			
var R6AbstractWeapon.eWeaponGrenadeType   m_eEntryGrenadeType;

// Rules Of Engagement determines speed and hostility of unit
var         eMovementMode					m_eMovementMode;                    // Rules Of Engagement
var         eMovementSpeed					m_eMovementSpeed;
var         ePlanAction						m_ePlanAction;
var         actor       					m_PlanActionPoint;
var         vector							m_vPlanActionLocation;
var			array<R6InteractiveObject>		m_InteractiveObjectList;

var			R6IORotatingDoor				m_BreachingDoor;
var			EPlanAction						m_eNextAPAction;
var			rotator							m_rSnipingDir;
var			actor							m_LastActionPoint;
var			R6Pawn							m_SurrenderedTerrorist;
var			R6Pawn							m_HostageToRescue;
var			bool							m_bSniperReady;
var			bool							m_bSkipAction;
var			bool							m_bWasSeparatedFromLeader;
var			bool							m_bAllTeamsHold;
var			bool							m_bTeamIsHoldingPosition;
var			bool 							m_bSniperHold;
var			bool							m_bTeamIsRegrouping;
var			bool							m_bPlayerRequestedTeamReform;
var			bool							m_bPendingSnipeUntilGoCode;

var			vector							m_vPreviousPosition;

var			EPlanAction						m_ePlayerAPAction;
var			actor							m_PlayerLastActionPoint;

var enum eTeamState
{
	TS_None,
    TS_Waiting,		// + gocode
    TS_Holding,
    TS_Moving,
	TS_Following,
	TS_Regrouping,
    TS_Engaging,
	TS_Sniping,		// + gocode
	TS_LockPicking,
	TS_OpeningDoor,
	TS_ClosingDoor,
	TS_Opening,
	TS_Closing,
	TS_ClearingRoom,
	TS_Grenading,
	TS_DisarmingBomb,
	TS_InteractWithDevice,	
	TS_SecuringTerrorist,
	TS_ClimbingLadder,
	TS_WaitingForOrders,
	TS_SettingBreach,
	TS_Retired
} m_eTeamState, m_eBackupTeamState;

var			FLOAT					m_fEngagingTimer;
var			bool					m_bTeamIsEngagingEnemy;
var			vector					m_vNoiseSource;

// GOCODE_Alpha, GOCODE_Bravo, GOCODE_Charlie, GOCODE_Delta, GOCODE_None
var         eGoCode                 m_eGoCode;
var			eGoCode					m_eBackupGoCode;

//#ifdefDEBUG	
var         bool					bShowLog;
var         BOOL                    bPlanningLog;
//#endif

var         BOOL                    m_bFirstTimeInGas;

replication
{
    reliable if (Role == ROLE_Authority)
        m_iMemberCount,m_TeamColour,m_iMembersLost,m_Team,m_bHasGrenade,m_eTeamState,m_eGoCode;

	unreliable if (Role == ROLE_Authority)
		m_bTeamIsClimbingLadder;

    reliable if (Role == ROLE_Authority)
        ClientUpdateFirstPersonWpnAndPeeking;

    reliable if (Role < ROLE_Authority)
        TeamActionRequest,TeamActionRequestFromRoseDesVents,TeamActionRequestWaitForZuluGoCode;
}

function SetTeamState(eTeamState eNewState)
{
	//#ifdefDEBUG if(bShowLog) log(self$" New Team STate is : "$eNewState);	#endif
    if((m_bLeaderIsAPlayer && m_iMemberCount == 1) || (!m_bLeaderIsAPlayer && m_iMemberCount == 0))
        m_eTeamState = TS_Retired;
    else
    {
		if(m_eTeamState != TS_Engaging)
			m_eTeamState = eNewState;
		else
			m_eBackupTeamState = eNewState;
	}
}

function TeamIsSeparatedFromLead(bool bSeparated)
{
	if(m_iMemberCount <= 1)
		return;

	m_bTeamIsSeparatedFromLeader = bSeparated;
}

function TeamIsRegroupingOnLead(bool bIsRegrouping)
{
    local bool bPreviousTeamIsRegrouping;

    bPreviousTeamIsRegrouping = m_bTeamIsRegrouping;

	if(m_bLeaderIsAPlayer && m_bPlayerRequestedTeamReform && m_bTeamIsRegrouping && !bIsRegrouping)
	{
		m_bPlayerRequestedTeamReform = false;
		m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReformOnLead);
	}

	m_bTeamIsRegrouping	= bIsRegrouping;
	TeamIsSeparatedFromLead(bIsRegrouping);
	if(bIsRegrouping)
		SetTeamState(TS_Regrouping);

	// if the team has regrouped
    if ( !bIsRegrouping && bPreviousTeamIsRegrouping )
    {
        // update list of escorted hostage
        Escort_ManageList();
    }
}

simulated event Destroyed()
{
    if ( m_ActionRequested != none )
    {
        m_ActionRequested.destroy();
        m_ActionRequested = none;
    }
    
    Super.Destroyed();
} 

event PostBeginPlay()
{
	local R6InteractiveObject  IntObject;
	
	Super.PostBeginPlay();

	// prepare a list of InteractiveObjects in this map, AI team leader will check these actors periodically 
	// to determine whether they are close enough to interact with them. (ignore doors)
	foreach AllActors( class'R6InteractiveObject', IntObject )
	{
		if( IntObject.m_bRainbowCanInteract )
		{
			#ifdefDEBUG if(bShowLog) log(self$" add IntObject="$IntObject$" to list of interactive objects ");	#endif
			m_InteractiveObjectList[m_InteractiveObjectList.length] = IntObject;
		}
	}
	m_ActionRequested = Spawn(class'R6CircumstantialActionQuery');
}

//------------------------------------------------------------------
// PostNetBeginPlay
//	create Colors on the server and on the Client
//------------------------------------------------------------------
simulated event PostNetBeginPlay()
{
    Colors = new(None) class'R6GameColors';
}

//------------------------------------------------------------------
// CreateMPPlayerTeam
//  used in multiplayer
//	create the team member base on the player controller
//------------------------------------------------------------------
function CreateMPPlayerTeam(PlayerController myPlayer, R6RainbowStartInfo info, INT iMemberCount, PlayerStart start)
{
    local INT i;
	local INT iMembersToSpawn;

    if(m_iMemberCount > 0)
        return;   // team already exists...

	#ifdefDEBUG if(bShowLog) log(self$" CreateMPPlayerTeam() for " $myPlayer$ " with iMemberCount ="$iMemberCount);	#endif
    m_bLeaderIsAPlayer = true;
	m_Team[0] = R6Rainbow(myPlayer.pawn);
    m_TeamLeader = m_Team[0];
	m_iTeamHealth[0] = 0;
    m_iMemberCount=1;
    m_Team[0].m_FaceTexture = info.m_FaceTexture;
    m_Team[0].m_FaceCoords = info.m_FaceCoords;

	#ifdefDEBUG
	if(bShowLog) log(self$"CreateMPPlayerTeam: m_CharacterName=" $info.m_CharacterName$ " m_ArmorName=" $info.m_ArmorName$ " m_WeaponName" $info.m_WeaponName[0] );
	if(bShowLog) log(self$"CreateMPPlayerTeam: -- WGadget0="$info.m_WeaponGadgetName[0]$" WGadget1="$info.m_WeaponGadgetName[1]);
	if(bShowLog) log(self$"CreateMPPlayerTeam: -- Gadget0="$info.m_GadgetName[0]$" Gadget1="$info.m_GadgetName[1]);
	#endif
	for(i=1; i < iMemberCount; i++)
	{
		CreateTeamMember(info, start, false);
		m_iTeamHealth[i] = 0;
	}
    UpdateTeamGrenadeStatus();
    info.destroy();
}

function SetMultiVoicesMgr(R6AbstractGameInfo aGameInfo, INT iTeamNumber, INT iMemberCount)
{
    local BOOL bCoopGameType;

    m_MultiCommonVoicesMgr = none;
    m_MultiCoopPlayerVoicesMgr = none;
    m_MultiCoopMemberVoicesMgr = none;
    m_PreRecMsgVoicesMgr = none;

    bCoopGameType = Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag);

    if (bCoopGameType || Level.IsGameTypeTeamAdversarial(Level.Game.m_szGameTypeFlag))
    {
        m_MultiCommonVoicesMgr = R6MultiCommonVoices(aGameInfo.GetMultiCommonVoicesMgr());
        m_PreRecMsgVoicesMgr = R6PreRecordedMsgVoices(aGameInfo.GetPreRecordedMsgVoicesMgr());
    }
    

    if (bCoopGameType || (Level.IsGameTypePlayWithNonRainbowNPCs(Level.Game.m_szGameTypeFlag)))
        SetVoicesMgr(aGameInfo, true, true);

    if (bCoopGameType)
    {
        //log("**** SetMultiVoicesMgr Level.Game.CurrentID =" @ Level.Game.CurrentID @ Level.Game.Default.CurrentID);
        m_MultiCoopPlayerVoicesMgr = R6MultiCoopVoices(aGameInfo.GetMultiCoopPlayerVoicesMgr(Level.Game.CurrentID - Level.Game.Default.CurrentID));
        if (iMemberCount > 1)
            m_MultiCoopMemberVoicesMgr = R6MultiCoopVoices(aGameInfo.GetMultiCoopMemberVoicesMgr());
    }
}
//------------------------------------------------------------------//
// SetVoicesMgr()												    //
//------------------------------------------------------------------//
function SetVoicesMgr(R6AbstractGameInfo aGameInfo, BOOL bPlayerTeamStart, BOOL bPlayerInTeam, optional INT iIDVoicesMgr, optional BOOL bInGhostMode)
{
    m_PlayerVoicesMgr=none;
    m_MemberVoicesMgr=none;
    m_OtherTeamVoicesMgr=none;

    m_bPlayerInGhostMode = bInGhostMode;
    if (!bPlayerTeamStart && bPlayerInTeam)
        m_bPlayerHasFocus = true;
    else
        m_bPlayerHasFocus = false;

    m_PlayerVoicesMgr = R6RainbowPlayerVoices( aGameInfo.GetRainbowPlayerVoicesMgr() );

    if (bPlayerTeamStart)
    {
        if (m_iMemberCount > 1)
        {
            // Create the 3rd person voice
            m_MemberVoicesMgr = R6RainbowMemberVoices( aGameInfo.GetRainbowMemberVoicesMgr() );
        }
    }
    else if (m_bPlayerHasFocus && !m_bPlayerInGhostMode)
    {
        m_MemberVoicesMgr = R6RainbowMemberVoices( aGameInfo.GetRainbowMemberVoicesMgr() );
        m_MultiCoopMemberVoicesMgr = R6MultiCoopVoices(aGameInfo.GetMultiCoopMemberVoicesMgr());
    }
    else
    {
        if (m_iMemberCount > 1)
        {
            // Create the Member voices manager if is not created but not associate it
            aGameInfo.GetRainbowMemberVoicesMgr();
            aGameInfo.GetCommonRainbowMemberVoicesMgr();
        }
        m_iIDVoicesMgr = iIDVoicesMgr;
        m_OtherTeamVoicesMgr = R6RainbowOtherTeamVoices( aGameInfo.GetRainbowOtherTeamVoicesMgr(iIDVoicesMgr) );
    }

}
//------------------------------------------------------------------//
// CreatePlayerTeam()												//
//------------------------------------------------------------------//
function CreatePlayerTeam(R6TeamStartInfo TeamInfo, NavigationPoint StartingPoint, PlayerController aRainbowPC)
{
    local INT i;

    if(m_iMemberCount > 0)
        return;   // team already exists...

    m_bLeaderIsAPlayer = true;
    m_iMemberCount=0;

	#ifdefDEBUG if(bShowLog) log(self$"  CREATEPLAYERTEAM() : iMembersToSpawn="$TeamInfo.m_iNumberOfMembers);	#endif

	for(i=0; i < TeamInfo.m_iNumberOfMembers; i++)
	{
		CreateTeamMember(TeamInfo.m_CharacterInTeam[i], StartingPoint, m_iMemberCount == 0, R6PlayerController(aRainbowPC));
		m_iTeamHealth[i] = TeamInfo.m_CharacterInTeam[i].m_iHealth;
	}
	UpdateTeamGrenadeStatus();
}

//------------------------------------------------------------------//
// CreateAITeam()													//
//------------------------------------------------------------------//
function CreateAITeam(R6TeamStartInfo TeamInfo, NavigationPoint StartingPoint)
{
    local INT i;

    if(m_iMemberCount > 0)
        return;   // team already exists...

    m_bLeaderIsAPlayer = false;
    m_TeamLeader = none;
    m_iMemberCount=0;

	for(i=0; i<TeamInfo.m_iNumberOfMembers; i++)
    {
		CreateTeamMember(TeamInfo.m_CharacterInTeam[i], StartingPoint, false);
        m_iTeamHealth[i] = TeamInfo.m_CharacterInTeam[i].m_iHealth;
    }
	UpdateTeamGrenadeStatus();
}

//------------------------------------------------------------------//
// CreateTeamMember()												//
//------------------------------------------------------------------//
function CreateTeamMember(R6RainbowStartInfo RainbowToCreate, NavigationPoint StartingPoint, optional BOOL bPlayer, optional R6PlayerController RainbowPC)
{
    local R6RainbowAI           rainbowAI;
    local vector                vOriginStart;
    local vector                vStart;
    local class<R6Rainbow>      rainbowPawnClass, armorClass;
    local R6Rainbow             rainbow;
    local INT                   iSpawnTry;
    local rotator               rPosOrientation;
    local rotator               rStartingPointRot;
			
    if (Level.NetMode == NM_Client)     // should only be called by server
        return;

    // spawn team in a diamond formation (to save space) using the spawn point's orientation...
// how are we doing m_TeamPlanning in MP
// For now accessing none
    if( Level.NetMode == NM_Standalone &&
        m_TeamPlanning.m_NodeList.length != 0)
    {
		vOriginStart = m_TeamPlanning.m_NodeList[0].Location;
        rStartingPointRot = m_TeamPlanning.m_NodeList[0].rotation;
    }
    else
    {
        vOriginStart = StartingPoint.Location;
        rStartingPointRot = StartingPoint.rotation;
    }
    rStartingPointRot.Roll = 0;

/*
    spawning position based on spawn try value
    ---------------------
    | 19| 20| 21| 22| 23|
    ---------------------
    ! 18| 6 | 7 | 8 | 24|
    ---------------------  / \
    ! 17| 5 | 0 | 1 | 9 |   |
    ---------------------   |  Zone orientation
    ! 16| 4 | 3 | 2 | 10|
    ---------------------   
    | 15| 14| 13| 12| 11|
    ---------------------
*/
    iSpawnTry=0;
    while( iSpawnTry != -1)
    {
        if(iSpawnTry == 0)
        {
            vStart = vOriginStart;
        }
        else if(iSpawnTry < 8)
        {
            rPosOrientation = rStartingPointRot;
            rPosOrientation.Yaw += 32768 + 8192*(iSpawnTry + 1);
            if( (iSpawnTry == 1) || (iSpawnTry == 3) || (iSpawnTry == 5) || (iSpawnTry == 7))
            {
	            vStart = vOriginStart - (m_iSpawnDistance * vector(rPosOrientation));
            }
            else
            {
	            vStart = vOriginStart - (m_iSpawnDiagDist * vector(rPosOrientation));
            }
        }
        else if(iSpawnTry < 24)
        {
            rPosOrientation = rStartingPointRot;
            rPosOrientation.Yaw += 32768 + 16384 + 4096 * (iSpawnTry-9);
            if( (iSpawnTry == 9) || (iSpawnTry == 13) || (iSpawnTry == 17) || (iSpawnTry == 21))
            {
	            vStart = vOriginStart - (m_iSpawnDistance * 2 * vector(rPosOrientation));
            }
            else if( (iSpawnTry == 11) || (iSpawnTry == 15) || (iSpawnTry == 19) || (iSpawnTry == 23))
            {
	            vStart = vOriginStart - (m_iSpawnDiagDist * 2 * vector(rPosOrientation));
            }
            else
            {
	            vStart = vOriginStart - (m_iSpawnDiagOther * vector(rPosOrientation));
            }
        }
        else
        {
            log("    Rainbow6    <R6GameInfo::CreateTeamMember> attempt to create a rainbow member failed!!");
            return;
        }

        if(iSpawnTry ==0) // go in this section only once
        {
         
			if(RainbowToCreate == none)
			{
				#ifdefDEBUG if(bShowLog) log(self$" CreateTeamMember() : RainbowToCreate is none ... ");	#endif
				return;
			}

	        if(RainbowToCreate.m_ArmorName == "")
	        {
		        #ifdefDEBUG if(bShowLog) log(self$" Rainbow Armor Class name is none ... ");	#endif
		        return;
	        }

	        #ifdefDEBUG if(bShowLog) log(self$" Rainbow Class name is now...  RainbowToCreate.m_ArmorName="$RainbowToCreate.m_ArmorName);	#endif
            armorClass = class<R6Rainbow>(DynamicLoadObject(RainbowToCreate.m_ArmorName, class'Class'));
            if(Level.NetMode == NM_Standalone)
            {
                Level.GreenTeamSkin = armorClass.Default.Skins[0];
                Level.GreenHeadSkin = armorClass.Default.Skins[1];
                Level.GreenGogglesSkin = armorClass.Default.Skins[2];
                Level.GreenHandSkin = armorClass.Default.Skins[5];
                Level.GreenMesh = armorClass.Default.Mesh;
                Level.GreenHelmet = armorClass.Default.m_HelmetClass;
            }
            rainbowPawnClass = class<R6Rainbow>(class'Actor'.static.GetModMgr().GetDefaultRainbowPawn(armorClass.Default.m_eArmorType));
			rainbowPawnClass.Default.m_iOperativeID = RainbowToCreate.m_iOperativeID;
			rainbowPawnClass.Default.bIsFemale = !RainbowToCreate.m_bIsMale;
        }

        #ifdefDEBUG if(bShowLog) log(self$"CreateTeamMember: " $rainbowPawnClass$ " m_iSpawnDistance=" $m_iSpawnDistance$ " vStart=" $vStart$ " rotation=" $StartingPoint.rotation );	#endif
        rainbow = Spawn(rainbowPawnClass,,, vStart, rStartingPointRot,false);
        if(rainbow == none)
        {
            iSpawnTry++;
	    }
        else
        {
            rainbow.m_szPrimaryWeapon = RainbowToCreate.m_WeaponName[0];
            rainbow.m_szPrimaryGadget = RainbowToCreate.m_WeaponGadgetName[0];
            rainbow.m_szPrimaryBulletType = RainbowToCreate.m_BulletType[0];
            rainbow.m_szSecondaryWeapon = RainbowToCreate.m_WeaponName[1];
            rainbow.m_szSecondaryGadget = RainbowToCreate.m_WeaponGadgetName[1];
            rainbow.m_szSecondaryBulletType = RainbowToCreate.m_BulletType[1];

            rainbow.m_szPrimaryItem  = RainbowToCreate.m_GadgetName[0];
            rainbow.m_szSecondaryItem = RainbowToCreate.m_GadgetName[1];
			rainbow.m_szSpecialityID = RainbowToCreate.m_szSpecialityID;

            rainbow.m_FaceTexture = RainbowToCreate.m_FaceTexture;
            rainbow.m_FaceCoords = RainbowToCreate.m_FaceCoords;
	
			if(Level.NetMode == NM_Standalone)
			{
				rainbow.m_fSkillAssault	 = RainbowToCreate.m_fSkillAssault;
				rainbow.m_fSkillDemolitions = RainbowToCreate.m_fSkillDemolitions;
				rainbow.m_fSkillElectronics = RainbowToCreate.m_fSkillElectronics;
				rainbow.m_fSkillSniper		 = RainbowToCreate.m_fSkillSniper;
				rainbow.m_fSkillStealth	 = RainbowToCreate.m_fSkillStealth;
				rainbow.m_fSkillSelfControl = RainbowToCreate.m_fSkillSelfControl;
				rainbow.m_fSkillLeadership	 = RainbowToCreate.m_fSkillLeadership;
				rainbow.m_fSkillObservation = RainbowToCreate.m_fSkillObservation;
			}

            switch(RainbowToCreate.m_iHealth)
            {
		        case 0:
			        rainbow.m_eHealth = HEALTH_Healthy;
			        break;
		        case 1:
			        rainbow.m_eHealth = HEALTH_Wounded;
			        break;
		        case 2: //Should not happen
			        rainbow.m_eHealth = HEALTH_Incapacitated;
			        break;
		        case 3: //Should not happen
			        rainbow.m_eHealth = HEALTH_Dead;
			        break;
		        default :
			        rainbow.m_eHealth = HEALTH_Healthy;        
            }
			
            #ifdefDEBUG if(bShowLog) log(self$"  Team member spawned on try :"$iSpawnTry);		#endif
            iSpawnTry=-1; // minus 1 is to get out of the loop
        }
    }

	rainbow.m_vStartLocation = vStart;
	rainbow.m_CharacterName = RainbowToCreate.m_CharacterName;
 
    if (bPlayer)
    {
        if (Level.NetMode == NM_Standalone)
        {
            RainbowPC.SetLocation(vStart);
            R6AbstractGameInfo(level.game).m_Player = rainbowPC;
            RainbowPC.m_CurrentVolumeSound = rainbow.m_CurrentVolumeSound;
            rainbowPC.Possess(rainbow);
            rainbowPC.GameReplicationInfo = Level.Game.GameReplicationInfo;
            rainbow.controller = rainbowPC;
            rainbowPC.focus = none;
            
            //Set the starting point info for the sound (To know which ambience hsould be play if we switch to this player)
            RainbowPC.m_CurrentAmbianceObject = rainbow.Region.Zone;
        }
    }
    else
    {
		if(Level.NetMode == NM_Standalone)
			rainbowAI = R6RainbowAI(spawn(class'Actor'.static.GetModMgr().GetDefaultRainbowAI(),,, vStart, StartingPoint.rotation));
		else
			rainbowAI = R6RainbowAI(R6AbstractGameInfo(Level.Game).GetRainbowAIFromTable());
		rainbowAI.Possess(rainbow);		
        rainbow.controller = rainbowAI;
        rainbowAI.focus = none;
    }

    m_Team[m_iMemberCount] = rainbow; 

    if(m_TeamLeader == none)
    {          
        m_TeamLeader = rainbow;
        if(!bPlayer)
        {
            rainbowAI.m_TeamLeader = none;	
			rainbowAI.nextState = 'Patrol';	
            rainbowAI.GotoState('WaitForGameToStart');		
        }
		GetFirstActionPoint();
    }
    else
    {                
        rainbowAI.m_TeamLeader = m_TeamLeader;		
		rainbowAI.nextState = 'FollowLeader';
        rainbowAI.GotoState('WaitForGameToStart');
    }

    if(bPlayer)
    {
        if (Level.NetMode == NM_Standalone)
        {
            rainbowPC.SetRotation(StartingPoint.rotation);
            rainbowPC.m_TeamManager = self;
        }
    }
    else
    {
        rainbowAI.SetRotation(StartingPoint.rotation);
        rainbowAI.m_TeamManager = self;
    }
    rainbow.m_iID = m_iMemberCount;
    rainbow.m_iPermanentID = rainbow.m_iID;
    m_iMemberCount++;
	rainbow.GiveDefaultWeapon();
}

//------------------------------------------------------------------//
// rbrek - 11 may 2002												//
// ResetRainbowTeam()												//
//	 resets all variables and rainbow states						//
//------------------------------------------------------------------//
function ResetRainbowTeam()
{
	local INT i;

	m_bTeamIsClimbingLadder = false;            
	m_bEntryInProgress = false;
	m_bRainbowIsInFrontOfDoor = false;

	if(m_iMemberCount <= 1)
		return;

	for(i=1; i<m_iMemberCount; i++)
		m_Team[i].controller.GotoState('FollowLeader');
}

//------------------------------------------------------------------//
// LastMemberIsStationary()											//
//------------------------------------------------------------------//
function bool LastMemberIsStationary()
{
	if(m_Team[m_iMemberCount-1].IsStationary())
		return true;

	return false;
}

//------------------------------------------------------------------//
// ResetGrenadeAction()											
//------------------------------------------------------------------//
function ResetGrenadeAction()
{
	#ifdefDEBUG if(bShowLog) log(self$" ResetGrenadeAction() : m_iTeamAction="$m_iTeamAction);	#endif
	m_iTeamAction = m_iTeamAction & 0xffffffbf;	
}

//------------------------------------------------------------------//
// UpdateTeamGrenadeStatus()										//
//------------------------------------------------------------------//
function UpdateTeamGrenadeStatus()
{
    m_bHasGrenade=0;
    if (FindRainbowWithGrenadeType(GT_GrenadeFrag, false) != none)     //R6Weapons.R6FragGrenade
		m_bHasGrenade += 0x1;
    if (FindRainbowWithGrenadeType(GT_GrenadeGas, false) != none)      //R6Weapons.R6TearGasGrenade
		m_bHasGrenade += 0x2;
    if (FindRainbowWithGrenadeType(GT_GrenadeFlash, false) != none)    //R6Weapons.R6FlashBang
		m_bHasGrenade += 0x4;
	if (FindRainbowWithGrenadeType(GT_GrenadeSmoke, false) != none)    //R6Weapons.R6SmokeGrenade
		m_bHasGrenade += 0x8;
}

//------------------------------------------------------------------//
// HaveRainbowWithGrenadeType()										//
//------------------------------------------------------------------//
simulated function BOOL HaveRainbowWithGrenadeType( R6AbstractWeapon.eWeaponGrenadeType grenadeType )
{
    switch( grenadeType )
    {
    case GT_GrenadeFrag:
        return ((m_bHasGrenade & 0x1)!=0);
    case GT_GrenadeGas:
        return ((m_bHasGrenade & 0x2)!=0);
    case GT_GrenadeFlash:
        return ((m_bHasGrenade & 0x4)!=0);
    case GT_GrenadeSmoke:
        return ((m_bHasGrenade & 0x8)!=0);
    }
    return false;
}

function UpdateLocalActionRequest(R6CircumstantialActionQuery actionRequested)
{
	m_actionRequested.aQueryOwner = actionRequested.aQueryOwner;
	m_actionRequested.aQueryTarget = actionRequested.aQueryTarget;
	m_actionRequested.iMenuChoice = actionRequested.iMenuChoice;
	m_actionRequested.iSubMenuChoice = actionRequested.iSubMenuChoice;
}

//------------------------------------------------------------------//
// rbrek - 4 sept 2001                                              //
// TeamActionRequested()											//
//   this is the function that dispatches an action request to a    //
//   player's team.                                                 //
//------------------------------------------------------------------//
function TeamActionRequest(R6CircumstantialActionQuery actionRequested)
{
    local INT       iHostage;
	local vector	vActorDir;

    if(!m_bLeaderIsAPlayer || (m_iMemberCount <= 1) || m_bTeamIsClimbingLadder || Level.m_bInGamePlanningActive) 
        return;

	#ifdefDEBUG if(bShowLog) log(self$" TeamActionRequest() was called with actionRequested.aQueryTarget="$actionRequested.aQueryTarget);	#endif
	
	// reorganize team based on their original order
	RestoreTeamOrder();

	// reset ZULU gocode
	if(m_bCAWaitingForZuluGoCode)
		ResetZuluGoCode();

	UpdateLocalActionRequest(actionRequested);
	m_bTeamIsHoldingPosition = false;

	if(actionRequested.aQueryTarget.IsA('R6Terrorist'))
	{
		m_iTeamAction = TEAM_SecureTerrorist;
		InstructTeamToArrestTerrorist(R6Terrorist(actionRequested.aQueryTarget));
	}
	else if(actionRequested.aQueryTarget.IsA('R6Hostage'))
	{
		m_iTeamAction = TEAM_EscortHostage;
		MoveTeamTo(actionRequested.aQueryTarget.Location);		
	}
    else if(actionRequested.aQueryTarget.IsA('R6LadderVolume'))
    {
		m_iTeamAction = TEAM_ClimbLadder;
        InstructTeamToClimbLadder(R6LadderVolume(actionRequested.aQueryTarget));
    }
    else if(actionRequested.aQueryTarget.IsA('R6IORotatingDoor'))
    {
        if(R6IORotatingDoor(actionRequested.aQueryTarget).m_bIsDoorClosed)
            m_iTeamAction = TEAM_OpenDoor;		
        else
            m_iTeamAction = TEAM_CloseDoor;

        ChooseOpenSound(actionRequested);
		AssignAction(R6IORotatingDoor(actionRequested.aQueryTarget), -1);
    }
    else if(actionRequested.aQueryTarget.IsA('R6IOBomb'))
    {
        m_iTeamAction = TEAM_DisarmBomb;
        vActorDir = vector(R6IOBomb(actionRequested.aQueryTarget).Rotation) * -80;
        vActorDir.z = 0;
		MoveTeamTo(actionRequested.aQueryTarget.Location + vActorDir);
    }
    else if(actionRequested.aQueryTarget.IsA('R6IODevice'))
    {
        m_iTeamAction = TEAM_InteractDevice;
        vActorDir = vector(R6IODevice(actionRequested.aQueryTarget).Rotation) * -80;
		vActorDir.z = 0;
        MoveTeamTo(actionRequested.aQueryTarget.Location + vActorDir);
    }
    else if(actionRequested.aQueryTarget.IsA('R6PlayerController'))
    {
        m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamMove);
        #ifdefDEBUG if(bShowLog) log(self$" ...default action... Team Move To...");	#endif
        m_iTeamAction = TEAM_Move;
        MoveTeamTo(R6PlayerController(m_TeamLeader.controller).m_vRequestedLocation);
    }
    else
    {
		#ifdefDEBUG if(bShowLog) log(self$" unknown action requested of team...");	#endif
    }
}

//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// TeamActionRequestFromRoseDesVents()								//
//   this is the function that dispatches a action request to a     //
//   rainbow team that comes from the rose des vents                //
//------------------------------------------------------------------//
function TeamActionRequestFromRoseDesVents(R6CircumstantialActionQuery actionRequested, INT iMenuChoice, INT iSubMenuChoice, optional BOOL bOrderOnZulu)
{
    local R6IORotatingDoor    door;
	local vector	vActorDir;
	
    actionRequested.iMenuChoice=iMenuChoice;
    actionRequested.iSubMenuChoice=iSubMenuChoice;
    if((m_iMemberCount <= 1) || m_bTeamIsClimbingLadder || Level.m_bInGamePlanningActive)
		return;

	#ifdefDEBUG if(bShowLog) log(self$" TeamActionRequestFromRoseDesVents() was called with actionRequested.aQueryTarget="$actionRequested.aQueryTarget$" iMenuChoice="$iMenuChoice$" iSubMenuChoice="$iSubMenuChoice);	#endif

	// reorganize team based on their original order
	RestoreTeamOrder();

	// reset ZULU gocode
	if(!bOrderOnZulu && m_bCAWaitingForZuluGoCode)
		ResetZuluGoCode();
	
	m_bTeamIsHoldingPosition = false;

	// store a copy of the actionRequested
	UpdateLocalActionRequest(actionRequested);
	
	if(actionRequested.aQueryTarget.IsA('R6IORotatingDoor'))
    {
	    #ifdefDEBUG if(bShowLog) log(self$" TeamActionRequestFromRoseDesVents Target is a Rotating door");	#endif
        #ifdefDEBUG if(bShowLog) log(self$" Action ID: " $actionRequested.iMenuChoice);	#endif
        door = R6IORotatingDoor(actionRequested.aQueryTarget);
        switch(actionRequested.iMenuChoice)        
        {
            case door.eDoorCircumstantialAction.CA_Close:   // this should be actionMenuChoice == 0
                m_iTeamAction = TEAM_CloseDoor;
                #ifdefDEBUG if(bShowLog) log(self$" door.eDoorCircumstantialAction.CA_Close");	#endif
                ChooseOpenSound(actionRequested);
                AssignAction(door, actionRequested.iSubMenuChoice);
                break;
            case door.eDoorCircumstantialAction.CA_Open:    // this should be actionMenuChoice == 0
	            m_iTeamAction = TEAM_OpenDoor;
                #ifdefDEBUG if(bShowLog) log(self$" door.eDoorCircumstantialAction.CA_Open");		#endif
                ChooseOpenSound(actionRequested);
                AssignAction(door, actionRequested.iSubMenuChoice);
                break;
            case door.eDoorCircumstantialAction.CA_OpenAndClear:         
                m_iTeamAction = TEAM_OpenAndClear;
                #ifdefDEBUG if(bShowLog) log(self$" door.eDoorCircumstantialAction.CA_OpenAndClear");		#endif
                m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenAndClear);
                AssignAction(door, actionRequested.iSubMenuChoice);
                break;                
            case door.eDoorCircumstantialAction.CA_OpenAndGrenade:       
                m_iTeamAction = TEAM_OpenAndGrenade;
                #ifdefDEBUG if(bShowLog) log(self$" door.eDoorCircumstantialAction.CA_OpenAndGrenade");	#endif
                AssignAction(door, actionRequested.iSubMenuChoice);
                break;
            case door.eDoorCircumstantialAction.CA_OpenGrenadeAndClear: 
                m_iTeamAction = TEAM_OpenGrenadeAndClear;
                #ifdefDEBUG if(bShowLog) log(self$" door.eDoorCircumstantialAction.CA_OpenGrenadeAndClear");	#endif
                AssignAction(door, actionRequested.iSubMenuChoice);
                break;
            case door.eDoorCircumstantialAction.CA_Clear:
                m_iTeamAction = TEAM_ClearRoom;
                #ifdefDEBUG if(bShowLog) log(self$" door.eDoorCircumstantialAction.CA_Clear");	#endif
                //PlayVoices(m_TeamLeader, Sound'Voices_1rstPersonRainbow.Play_Clear', Sound'Voices_1rstPersonRainbow.Stop_Clear', SLOT_HeadSet, 10);
                //MISSING SOUND SD
                AssignAction(door, actionRequested.iSubMenuChoice);
                break;
            case door.eDoorCircumstantialAction.CA_Grenade:    
                m_iTeamAction = TEAM_Grenade;
                #ifdefDEBUG if(bShowLog) log(self$" door.eDoorCircumstantialAction.CA_Grenade");	#endif
                AssignAction(door, actionRequested.iSubMenuChoice);
                break;
            case door.eDoorCircumstantialAction.CA_GrenadeAndClear:                  
                m_iTeamAction = TEAM_GrenadeAndClear;
                #ifdefDEBUG if(bShowLog) log(self$" door.eDoorCircumstantialAction.CA_Close");	#endif
                AssignAction(door, actionRequested.iSubMenuChoice);
                break;
            default:
                #ifdefDEBUG if(bShowLog) log(self$" an unknown eDoorCircumstantialAction was requested...");	#endif
        }
    }
    else if(actionRequested.aQueryTarget.IsA('R6PlayerController'))
    {
        // default actions
        if(actionRequested.iMenuChoice 
            == R6PlayerController(actionRequested.aQueryTarget).eDefaultCircumstantialAction.PCA_MoveAndGrenade)
        {
			m_iTeamAction = TEAM_MoveAndGrenade;
			#ifdefDEBUG if(bShowLog) log(self$" ... Team Move To And Grenade...");	#endif
            // The sound is play in the MoveTeamTo like the OpenGranadeClear etc.
            MoveTeamTo(R6PlayerController(m_TeamLeader.controller).m_vRequestedLocation, actionRequested.iSubMenuChoice);
        }
		else
		{
			m_iTeamAction = TEAM_Move;
			#ifdefDEBUG if(bShowLog) log(self$" ...default action... Team Move To...");	#endif
			MoveTeamTo(R6PlayerController(m_TeamLeader.controller).m_vRequestedLocation);
		}
    }
    else if(actionRequested.aQueryTarget.IsA('R6LadderVolume'))
    {
        m_iTeamAction = TEAM_ClimbLadder;
		InstructTeamToClimbLadder(R6LadderVolume(actionRequested.aQueryTarget));
    } 
    else if(actionRequested.aQueryTarget.IsA('R6IOBomb'))
    {
        m_iTeamAction = TEAM_DisarmBomb;
        vActorDir = vector(R6IOBomb(actionRequested.aQueryTarget).Rotation) * -80;
        vActorDir.z = 0;
		MoveTeamTo(R6IOBomb(actionRequested.aQueryTarget).Location + vActorDir);
    } 
    else if(actionRequested.aQueryTarget.IsA('R6IODevice'))	
	{
        m_iTeamAction = TEAM_InteractDevice;
        vActorDir = vector(R6IODevice(actionRequested.aQueryTarget).Rotation) * -80;
		vActorDir.z = 0;
        MoveTeamTo(actionRequested.aQueryTarget.Location + vActorDir);
	}
    else if(actionRequested.aQueryTarget.IsA('R6Terrorist'))
	{
		m_iTeamAction = TEAM_SecureTerrorist;
		InstructTeamToArrestTerrorist(R6Terrorist(actionRequested.aQueryTarget));
	}
	else if(actionRequested.aQueryTarget.IsA('R6Hostage'))
	{
		m_iTeamAction = TEAM_EscortHostage;
		MoveTeamTo(actionRequested.aQueryTarget.Location);		
	}
	else
    {
		#ifdefDEBUG if(bShowLog) log(self$" unrecognized rose des vents action requested of team...actionRequested.aQueryTarget="$actionRequested.aQueryTarget);	#endif
    }
}

//------------------------------------------------------------------
// ChooseOpenSound()
//	Choose the right sound to be played. If it's a volet say open it 
//------------------------------------------------------------------
function ChooseOpenSound(R6CircumstantialActionQuery actionRequested)
{
    if(R6IORotatingDoor(actionRequested.aQueryTarget).m_bIsDoorClosed)
    {
		if(R6IORotatingDoor(actionRequested.aQueryTarget).m_bTreatDoorAsWindow)
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenShudder);
		else
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenDoor);
    }
    else
    {
		if(R6IORotatingDoor(actionRequested.aQueryTarget).m_bTreatDoorAsWindow)
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamCloseShudder);
		else
	        m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamCloseDoor);
    }		
}


//------------------------------------------------------------------
// TeamActionRequestWaitForZuluGoCode()
//	Action will be executed at Zulu GoCode
//------------------------------------------------------------------
function TeamActionRequestWaitForZuluGoCode( R6CircumstantialActionQuery actionRequested, INT iMenuChoice, INT iSubMenuChoice )
{
    actionRequested.iMenuChoice=iMenuChoice;
    actionRequested.iSubMenuChoice=iSubMenuChoice;

	#ifdefDEBUG if(bShowLog) log(self$" Team will wait for Zulu Go Code : actionRequested="$actionRequested$" actionRequested.iMenuChoice="$actionRequested.iMenuChoice );	#endif    
	UpdateLocalActionRequest(actionRequested);

	if(!m_bCAWaitingForZuluGoCode)
	{
		m_bCAWaitingForZuluGoCode = true;	
		m_eBackupGoCode = m_eGoCode;
		m_eGoCode = GOCODE_Zulu;
	}
    TeamActionRequestFromRoseDesVents( m_actionRequested, m_actionRequested.iMenuChoice,m_actionRequested.iSubMenuChoice, true);
}

//------------------------------------------------------------------//
// ReceivedZuluGoCode()												//
//------------------------------------------------------------------//
function ReceivedZuluGoCode()
{
    #ifdefDEBUG if(bShowLog) log(self$" Received Zulu Go Code" );	#endif
    
    if( m_bCAWaitingForZuluGoCode  )
		ResetZuluGoCode();
}

//------------------------------------------------------------------//
// PlaySniperOrder()                                                //
//------------------------------------------------------------------//
function PlaySniperOrder() 
{
    if (m_bSniperHold)
        m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_SniperHold);
    else        
        m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_SniperFree);
}

//------------------------------------------------------------------//
// PlayGoCode()	               									    //
//------------------------------------------------------------------//
function PlayGoCode(EGoCode eGo) 
{
    switch(eGo)
    {
        case GOCODE_Alpha:
            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_AlphaGoCode);
            break;
        case GOCODE_Bravo:
            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_BravoGoCode);
            break;
        case GOCODE_Charlie:
            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_CharlieGoCode);
            break;
        case GOCODE_Zulu:
            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_ZuluGoCode);
            if (m_bCAWaitingForZuluGoCode && (m_iMemberCount > 1))
                m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);
            break;
    }
}

//------------------------------------------------------------------
// SetTeamIsClimbingLadder: set the bool and inform the escorted team
//	to climb the ladder.
//------------------------------------------------------------------
function SetTeamIsClimbingLadder( bool bClimbing )
{
    m_bTeamIsClimbingLadder = bClimbing;
}


//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamLeaderIsClimbingLadder()										//
//   this should be called from the playercontroller as well as the //
//   AIcontroller for the team lead                                 //
//------------------------------------------------------------------//
function TeamLeaderIsClimbingLadder()
{
    local INT i;
  
	// if team is separated from leader, this should not affect their behavior; team should not follow
	if((m_bTeamIsSeparatedFromLeader && m_bLeaderIsAPlayer) || (m_iMemberCount == 1))  
    {
		#ifdefDEBUG if(bShowLog) log(self$" TeamLeaderIsClimbingLadder() was called.... team is separated from leader, or there is only one member in this team, so exit...");	#endif
		return;
	}

	// if team is already using a ladder, do nothing...
	if(m_bTeamIsClimbingLadder)
	{
		#ifdefDEBUG if(bShowLog) log(self$" TeamLeaderIsClimbingLadder() was called.... but m_bTeamIsClimbingLadder==true so exit...");	#endif
		return;
	}

	#ifdefDEBUG if(bShowLog) log(self$" TeamLeaderIsClimbingLadder() was called.... ");	#endif
    SetTeamIsClimbingLadder( true );
    UpdateTeamFormation(FORM_SingleFile); 
	m_TeamLadder = m_TeamLeader.m_Ladder;
	if(m_iMemberCount > 1)
    {
		for(i=1; i<m_iMemberCount; i++)
		{
			// set the ladder as the moveTarget so that this pawn can position himself near it...
			m_Team[i].controller.moveTarget = m_TeamLeader.m_Ladder;     
			m_Team[i].m_Ladder = m_TeamLeader.m_Ladder;
			R6RainbowAI(m_Team[i].controller).ResetStateProgress();
			m_Team[i].controller.GotoState('TeamClimbLadder');
		}
	}
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamFinishedClimbingLadder()										//
//   called when all team members have finished climbing the ladder //
//------------------------------------------------------------------//
function TeamFinishedClimbingLadder()
{
	#ifdefDEBUG if(bShowLog) log(self$"  TeamFinishedClimbingLadder() was called...m_iTeamAction="$m_iTeamAction);	#endif
	if((m_iTeamAction & TEAM_ClimbLadder) > 0)
		ActionCompleted(true);
    UpdateTeamFormation(FORM_SingleFileWallBothSides);
    SetTeamIsClimbingLadder( false );
}

//------------------------------------------------------------------
// rbrek 
// 17 sept 2002
//------------------------------------------------------------------
function bool AllMembersAreOnTheSameSideOfTheLadder(R6LadderVolume ladder)
{
	local bool bLeaderIsAtTopOfLadder;
	local INT iLeader;
	local INT i;

	if(m_bTeamIsSeparatedFromLeader)
	{
		if(m_iMemberCount == 2)
			return true;
		iLeader = 1;
		bLeaderIsAtTopOfLadder = (m_Team[1].location.z > ladder.location.z);
	}
	else
	{
		if(m_iMemberCount == 1)
			return true;
		iLeader = 0;
		bLeaderIsAtTopOfLadder = (m_TeamLeader.location.z > ladder.location.z);
	}

	for(i=iLeader+1;i<m_iMemberCount;i++)
	{
		if(bLeaderIsAtTopOfLadder != (m_Team[i].location.z > ladder.location.z))
			return false;
	}
	return true;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// MemberFinishedClimbingLadder()									//
//   called when any member of the team finished climbing the       //
//   ladder.  (NPC and player)                                      //
//------------------------------------------------------------------//
function MemberFinishedClimbingLadder(R6Pawn member)
{
    local INT i;
    local INT iTotalMember;
	local INT iLeader;

	#ifdefDEBUG if(bShowLog) log(self$" MemberFinishedClimbingLadder() was called... for member :"$member);	#endif
	if((R6Rainbow(member) == m_TeamLeader) && member.m_bIsPlayer && (m_bTeamIsSeparatedFromLeader || (m_iMemberCount == 1)))
		return;		// do nothing, leader is climbing ladder alone...

	if(!member.IsAlive())
		return;

	if(AllMembersAreOnTheSameSideOfTheLadder(R6LadderVolume(m_TeamLadder.myLadder)))
	{
		TeamFinishedClimbingLadder();			
		if(m_bTeamIsSeparatedFromLeader)
			iLeader = 1;
		else
			iLeader = 0;

        for(i=iLeader+1; i<m_iMemberCount; i++)
			m_Team[i].controller.GotoState('FollowLeader');
	}
} 

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamHasFinishedClimbingLadder()									//
//   this function returns a boolean that indicates whether the     //
//   entire team has finished climbing the ladder                   //
//------------------------------------------------------------------//
function bool TeamHasFinishedClimbingLadder()
{
    if(m_bTeamIsClimbingLadder)
        return false;
    else
        return true;
}

//------------------------------------------------------------------//
// rbrek - 8 feb 2002                                               //
// MembersAreOnSameEndOfLadder()									//
//------------------------------------------------------------------//
function bool MembersAreOnSameEndOfLadder(R6Pawn p1, R6Pawn p2)
{
	if(abs(p1.location.z - p2.location.z) < 30)
		return true;
	
	return false;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructTeamToClimbLadder()										//
//   instructs team to climb the ladder without the leader, will    //
//   move to the closest ladder actor, climb to the other end, find //
//   a spot and wait for the leader to call a team regroup          //
//------------------------------------------------------------------//
function InstructTeamToClimbLadder(R6LadderVolume ladderVolume, optional bool bPathFinding, optional int iMemberId)
{
    local FLOAT     fDistanceToTop;
    local FLOAT     fDistanceToBottom;
    local INT       i;    
	local INT		iMemberLeading;

	#ifdefDEBUG if(bShowLog) log(self$"  InstructTeamToClimbLadder() was called for ladderVolume="$ladderVolume);	#endif
    if(m_iMemberCount < 2)
        return;

	if(bPathFinding)
		iMemberLeading = iMemberId;
	else
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamUseLadder);
		PlayOrderTeamOnZulu();
	    m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);
		iMemberLeading = 1;
	}
	
    // determine whether team is at the top or bottom of the ladder
    fDistanceToTop = abs(m_Team[iMemberLeading].location.z - ladderVolume.m_TopLadder.location.z);
    fDistanceToBottom = abs(m_Team[iMemberLeading].location.z - ladderVolume.m_BottomLadder.location.z);
    if(fDistanceToTop < fDistanceToBottom)
    { 
        m_TeamLadder = ladderVolume.m_TopLadder;
    }
    else
    {
        m_TeamLadder = ladderVolume.m_BottomLadder;
    }    

	// instruct team to climb the ladder and wait for leader at the other end...    
	m_Team[iMemberLeading].controller.moveTarget = m_TeamLadder;   

	if(bPathFinding) 
	{
		#ifdefDEBUG if(bShowLog) log(self$" InstructTeamToClimbLadder() : Team is trying to find path back to leader.... ");		#endif
		SetTeamState(TS_ClimbingLadder);
		if(iMemberLeading == 0 && !m_bLeaderIsAPlayer)
			m_Team[iMemberLeading].controller.nextState = 'WaitForTeam';	
		else if(m_bLeaderIsAPlayer && (iMemberLeading == 1))
			m_Team[iMemberLeading].controller.nextState = 'TeamClimbEndNoLeader';
		else
			m_Team[iMemberLeading].controller.nextState = m_Team[iMemberLeading].controller.GetStateName(); 
		m_Team[iMemberLeading].controller.GotoState('ApproachLadder');	
	}
	else
	{
		#ifdefDEBUG if(bShowLog) log(self$" InstructTeamToClimbLadder() : Team is not already separated, will separate now...");		#endif
		if(m_Team[iMemberLeading].m_bIsClimbingLadder)
		{
			SetTeamState(TS_ClimbingLadder);
			m_Team[iMemberLeading].controller.nextState = 'TeamClimbEndNoLeader';
		}
		else
			m_Team[iMemberLeading].controller.GotoState('TeamClimbStartNoLeader');
		TeamIsSeparatedFromLead(true);
	}
  
    UpdateTeamFormation(FORM_SingleFile); 
	if(m_iMemberCount > iMemberLeading + 1)
    {
		for(i=iMemberLeading + 1; i<m_iMemberCount; i++)
		{        
			if(MembersAreOnSameEndOfLadder(m_Team[iMemberLeading], m_Team[i])) 
			{
				m_Team[i].m_Ladder = m_TeamLadder; 
				R6RainbowAI(m_Team[i].controller).ResetStateProgress();
				m_Team[i].controller.GotoState('TeamClimbLadder');
			}
		}
	}
}

function PlaySoundTeamStatusReport()
{
    if (m_TeamLeader.m_bIsPlayer || m_bPlayerHasFocus || m_bPlayerInGhostMode)
    {
        m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamStatusReport);
    }

    if (!m_TeamLeader.m_bIsPlayer && !m_bPlayerHasFocus && (m_OtherTeamVoicesMgr != none) && (m_iMemberCount > 0))
    {
        switch(m_eTeamState)
        {
            case TS_Waiting:
                switch(m_eGoCode)
                {
                    case GOCODE_Alpha:  
                        m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusWaitAlpha);
                        break;
                    case GOCODE_Bravo:  
                        m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusWaitBravo);
                        break;
                    case GOCODE_Charlie:  
                        m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusWaitCharlie);
                        break;
                    case GOCODE_Zulu:  
                        m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusWaitZulu);
                        break;
                }
                break;

            case TS_Grenading:
            case TS_DisarmingBomb:
            case TS_WaitingForOrders:
            case TS_Holding:
                m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusWaiting);
                break;

            case TS_Engaging:
                m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusEngaging);
                break;

            case TS_Sniping:
                switch(m_eGoCode)
                {
                    case GOCODE_Alpha:  
                        m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusSniperWaitAlpha);
                        break;
                    case GOCODE_Bravo:  
                        m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusSniperWaitBravo);
                        break;
                    case GOCODE_Charlie:  
                        m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusSniperWaitCharlie);
                        break;
                }
                break;

            case TS_InteractWithDevice:
                switch(m_TeamLeader.m_eDeviceAnim)
                {
                    case BA_Keypad:
                            m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_TeamLeader, RTV_DesactivatingSecurity);

                    case BA_PlantDevice:
                            m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_TeamLeader, RTV_PlacingBug);
                            break;
                    case BA_Keyboard:
                            m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_TeamLeader, RTV_AccessingComputer);
                }
                break;
            case TS_SettingBreach:
                m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_TeamLeader, RTV_PlacingExplosives);
                break;
            
            case TS_Retired:
            case TS_SecuringTerrorist:
            case TS_ClimbingLadder:
            case TS_ClearingRoom:
            case TS_Following:
            case TS_Moving:
            case TS_LockPicking:
            case TS_OpeningDoor:
            case TS_ClosingDoor:
            case TS_Regrouping:
                m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusMoving);
                break;

        }

    }
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructPlayerTeamToHoldPosition()								//
//   team holds position, and waits for leader's instruction        //
//------------------------------------------------------------------//  
function InstructPlayerTeamToHoldPosition(optional BOOL bOtherTeam)
{
    local INT i;
    local INT iMember;

	if(m_bTeamIsClimbingLadder)
	{
		#ifdefDEBUG if(bShowLog) log(self$" InstructPlayerTeamToHoldPosition() : just cancel any order that was already issued....");	#endif
		m_iTeamAction = TEAM_None;
		return;
	}

	#ifdefDEBUG if(bShowLog) log(self$" ...InstructPlayerTeamToHoldPosition()...");	#endif
    TeamIsSeparatedFromLead(true);		
	m_bTeamIsHoldingPosition = true;
	m_bPlayerRequestedTeamReform = false;

	// reset any Zulu order
	if(m_bCAWaitingForZuluGoCode)
		ResetZuluGoCode();

    // Play Sound Hold Position
    if (m_TeamLeader.m_bIsPlayer)
    {
        if (bOtherTeam)
            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_AllTeamsHold);

        if(m_iMemberCount > 1)
        {
            if (!bOtherTeam)
                m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamHold);
            m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamHoldUp);
        }
    }

    if(m_iMemberCount > 1)
    {
		for(iMember=1; iMember<m_iMemberCount; iMember++)
        {
			m_Team[iMember].controller.nextState = '';
			m_Team[iMember].controller.GotoState('HoldPosition');        
		}
    }
	// we do not want to instruct the entire team to go into the state HoldPosition, 
	// so that we ensure that the rest of the team catches up/stays together
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructPlayerTeamToFollowLead()									//
//   if team is holding position, calling this function will bring  //
//   them out of hold and will resume following leader              //
//------------------------------------------------------------------//        
function InstructPlayerTeamToFollowLead(optional BOOL bOtherTeam)
{
    local INT i;
	
	if(m_bTeamIsClimbingLadder)
		return;
	
	#ifdefDEBUG if(bShowLog) log(self$" ...InstructPlayerTeamToFollowLead()...m_bLeaderIsAPlayer="$m_bLeaderIsAPlayer);	#endif
	m_iTeamAction = TEAM_None;
	m_bTeamIsHoldingPosition = false;
	m_bEntryInProgress = false;
	m_bPlayerRequestedTeamReform = false;

	if(m_bCAWaitingForZuluGoCode)
		ResetZuluGoCode();
	
	// reorganize team based on their original order
	RestoreTeamOrder();

    if (m_TeamLeader.m_bIsPlayer && bOtherTeam)
        m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_AllTeamsMove);

    if(m_iMemberCount > 1)
    {                
        // Play Sound Regroup
        if (m_TeamLeader.m_bIsPlayer)
        {
            if (!bOtherTeam)
				m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamRegroup);	

			if(VSize(m_Team[1].location - m_TeamLeader.location) > 600)
			{
				// if team is far from player
				if(m_MemberVoicesMgr != none)
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamRegroupOnLead);
				m_bPlayerRequestedTeamReform = true;
			}
			else
			{
				// team is already closeby
				if(m_MemberVoicesMgr != none)
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReformOnLead);
			}
        }
		// it is actually only necessary to reassign the state for member m_Team[1], but i reassign 
		// the state for all the members as a failsafe; as a last resort, this can help to reinit 
		// the state for all team members.
		for(i=1; i<m_iMemberCount; i++)
		{
			m_Team[i].controller.GotoState('FollowLeader');
			R6RainbowAI(m_Team[i].controller).ResetStateProgress();
		}

        TeamIsRegroupingOnLead( true );
    }
}

//------------------------------------------------------------------//
// GrenadeInProximity()												//
// todo : modify this to handle more than one grenade at a time??	//
//------------------------------------------------------------------//
function GrenadeInProximity(R6Rainbow spotter, vector vGrenadeLocation, FLOAT fTimeLeft, FLOAT fGrenadeDangerRadius)
{
	local INT	i;

	if(m_bGrenadeInProximity)	
		return;

	m_bGrenadeInProximity = true;	
	m_bWasSeparatedFromLeader = m_bTeamIsSeparatedFromLeader;
	
	if(m_bLeaderIsAPlayer)
	{
		TeamIsSeparatedFromLead(true);
		m_vPreviousPosition = m_Team[1].location;
	}
	else
		m_vPreviousPosition = m_Team[0].location;
	
	// rbrek todo : YELL GRENADE (voice)
	// add special case for RainbowAI lead?
    if (m_bPlayerHasFocus || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
        m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(spotter, RTV_GrenadeThreat);
    else
        m_MemberVoicesMgr.PlayRainbowMemberVoices(spotter, RMV_FragNear);

    for(i=0; i<m_iMemberCount; i++)
	{
		if(!m_Team[i].m_bIsPlayer)
			R6RainbowAI(m_Team[i].controller).ReactToFragGrenade(vGrenadeLocation, fTimeLeft, fGrenadeDangerRadius);
	}
}

//------------------------------------------------------------------//
// GasGrenadeInProximity()											//
//------------------------------------------------------------------//
function GasGrenadeInProximity(R6Rainbow spotter)
{
	if(m_bGasGrenadeInProximity)
		return;
	m_bGasGrenadeInProximity = true;
    
    m_MemberVoicesMgr.PlayRainbowMemberVoices(spotter, RMV_EntersGasCloud);

}

//------------------------------------------------------------------//
// GasGrenadeCleared()												//
//------------------------------------------------------------------//
function GasGrenadeCleared(R6Pawn aPawn)
{
    local INT i;

    for(i=0; i<m_iMemberCount; i++)
    {
        if(!m_Team[i].m_bIsPlayer && m_Team[i] != aPawn && m_Team[i].m_eEffectiveGrenade == GTYPE_TearGas)
            return;
    }
            
    m_bGasGrenadeInProximity = false;
}

//------------------------------------------------------------------//
// GrenadeThreatIsOver()											//
//------------------------------------------------------------------//
function GrenadeThreatIsOver()
{
	local INT	i;
	local BOOL  bTeamIsClimbingLadder;

	if(!m_bGrenadeInProximity)
		return;

	m_bGrenadeInProximity = false;
	RestoreTeamOrder();

    TeamIsSeparatedFromLead(m_bWasSeparatedFromLeader);
	if(!m_bLeaderIsAPlayer)
	{
		for(i=0; i<m_iMemberCount; i++)
		{
			if(m_Team[i].m_bIsClimbingLadder || m_Team[i].physics == PHYS_Ladder)
			{
				bTeamIsClimbingLadder = true;
				continue;
			}

			if(i==0)
			{
				if(m_bTeamIsHoldingPosition)
				{
					R6RainbowAI(m_Team[0].controller).FindPathToTargetLocation(m_vPreviousPosition);
					R6RainbowAI(m_Team[0].controller).m_PostFindPathToState = 'HoldPosition';
				}
				else
					R6RainbowAI(m_Team[0].controller).GotoState('Patrol');				
			}
			else
				R6RainbowAI(m_Team[i].controller).GotoState('FollowLeader');
		}
	}
	else
	{
		// player team
		if(m_iMemberCount == 1)
			return;

		// remain separated from leader but go back to previous location
		for(i=1; i<m_iMemberCount; i++)
		{
			if(m_Team[i].m_bIsClimbingLadder || m_Team[i].physics == PHYS_Ladder)
			{				
				bTeamIsClimbingLadder = true;
				continue;
			}

			if(m_bTeamIsSeparatedFromLeader)
			{
				#ifdefDEBUG if(bShowLog) log(self$"  m_Team[i]="$m_Team[i]$" i="$i$" R6RainbowAI(m_Team[i].controller).m_PaceMember="$R6RainbowAI(m_Team[i].controller).m_PaceMember);	#endif
				if(i==1)
				{
					m_iTeamAction = TEAM_Move;
					m_vActionLocation = m_vPreviousPosition;
					R6RainbowAI(m_Team[i].controller).GotoState('TeamMoveTo');
				}
				else
					R6RainbowAI(m_Team[i].controller).GotoState('FollowLeader');
			}			
			else
			{
				#ifdefDEBUG if(bShowLog) log(self$"  m_Team[i]="$m_Team[i]$" i="$i$" R6RainbowAI(m_Team[i].controller).m_PaceMember="$R6RainbowAI(m_Team[i].controller).m_PaceMember);	#endif
				R6RainbowAI(m_Team[i].controller).GotoState('FollowLeader');
			}		
		}
	}

	m_bTeamIsClimbingLadder = bTeamIsClimbingLadder;
}

//------------------------------------------------------------------//
// FriendlyFlashBang()												//
//------------------------------------------------------------------//
function bool FriendlyFlashBang(actor aGrenade)
{
	local INT i;

	for(i=0; i<m_iMemberCount; i++)
	{
		if(aGrenade.Instigator == m_Team[i])
			return true;
	}

	return false;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructTeamToArrestTerrorist()									//
//------------------------------------------------------------------//
function InstructTeamToArrestTerrorist(R6Terrorist terrorist)
{
	local  INT	i;

	#ifdefDEBUG if(bShowLog) log(self$" InstructTeamToArrestTerrorist() was called.... for terrorist :"$terrorist);	#endif
    m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamSecureTerrorist);
    TeamIsSeparatedFromLead(true);
    if(m_iMemberCount > 1)
    {
        PlayOrderTeamOnZulu();

        m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);
 
        R6RainbowAI(m_Team[1].controller).m_ActionTarget = terrorist;
        m_Team[1].controller.GotoState('TeamSecureTerrorist');
    }

	if(m_iMemberCount > 2)
	{
		for(i=2; i<m_iMemberCount; i++)
			m_Team[i].controller.GotoState('FollowLeader');
	}
}

//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// MoveTeamTo()														//
// TODO: add action to the MoveTeamTo...                            //
// TODO: if team does not see the target, do nothing...             //
//------------------------------------------------------------------//
function MoveTeamTo(vector vLocation, optional INT iSubAction)
{
	local  INT	i;
    local   R6Pawn  actionMember;
    local   R6RainbowAI rainbowAI;
	#ifdefDEBUG if(bShowLog) log(self$" MoveTeamTo() was called.... with location :"$vLocation$" and iSubAction="$iSubAction);	#endif

    TeamIsSeparatedFromLead(true);  
	m_iSubAction = iSubAction;
	
    if(m_iMemberCount > 1)
    {
        switch(m_iTeamAction)
        {
            case TEAM_MoveAndGrenade:
			    // look for a member with that type of grenade				
			    actionMember = SelectMemberWithFrag(m_iSubAction, m_TeamLeader.controller);
			    // todo : handle situation where no one in team has a frag  - feedback to player if(actionMember == none)

			    // do not execute order if no one in team has frag
			    if(actionMember == none)
			    {
				    #ifdefDEBUG if(bShowLog) log(self$" no one in team is equipped with that grenade (cannot perform action)... m_eEntryGrenadeType="$m_eEntryGrenadeType);	#endif
					//rbsound
					switch(m_eEntryGrenadeType)
					{
						case GT_GrenadeFrag:
							m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_NoMoreFrag);
							break;
						case GT_GrenadeGas:
							m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_NoMoreGas);
							break;
						case GT_GrenadeFlash:
							m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_NoMoreFlash);
							break;
						case GT_GrenadeSmoke:
							m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_NoMoreSmoke);
					}		
                    ActionCompleted(false);

					// instruct team to hold position
					InstructPlayerTeamToHoldPosition(false);

				    return;
			    }
                PlayOrderTeamOnZulu();

                m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);
                break;
            
            case TEAM_DisarmBomb:
                m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamUseDemolition);
                PlayOrderTeamOnZulu();
		        ReorganizeTeamToInteractWithDevice(TEAM_DisarmBomb, m_actionRequested.aQueryTarget);	        
		        R6RainbowAI(m_Team[1].controller).m_ActionTarget = m_actionRequested.aQueryTarget;
                m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);
                
                break;
			
			case TEAM_InteractDevice:
                m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamUseElectronic);
                PlayOrderTeamOnZulu();
				ReorganizeTeamToInteractWithDevice(TEAM_InteractDevice, m_actionRequested.aQueryTarget);
				R6RainbowAI(m_Team[1].controller).m_ActionTarget = m_actionRequested.aQueryTarget;
                m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);
				break;
				
			case TEAM_EscortHostage:
				// check if hostage is already following team, then no need for team to move, simply tell hostage to stay
				if(R6Hostage(m_actionRequested.aQueryTarget).m_escortedByRainbow != none)
                    m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamHostageStayPut);
				else
				    m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamGoGetHostage);
				
                PlayOrderTeamOnZulu();
				R6RainbowAI(m_Team[1].controller).m_ActionTarget = m_actionRequested.aQueryTarget;
                m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);
				break;

            case TEAM_Move:
                m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamMove);
                PlayOrderTeamOnZulu();

                if (m_iMemberCount == 2 || m_bCAWaitingForZuluGoCode)
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);
				else
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamMoveOut);
                break;
		} 

        m_iGrenadeThrower = 1; 
        rainbowAI = R6RainbowAI(m_Team[m_iGrenadeThrower].controller);
        
        // if move and grenade 
        if ( m_iTeamAction == TEAM_MoveAndGrenade)
        {
            rainbowAI.m_iStateProgress = 0;                          // reset
            rainbowAI.m_vLocationOnTarget = vLocation;               // where we want to throw the grenade
            m_vActionLocation   = rainbowAI.pawn.location; // start from his current location
        }
        else if ( m_iTeamAction == TEAM_Move )
        {
			m_vActionLocation = vLocation + vect(0,0,80);
			m_Team[m_iGrenadeThrower].FindSpot(m_vActionLocation, vect(38,38,80));			    
			//m_Team[m_iGrenadeThrower].dbgVectorAdd( m_vActionLocation, vect(38,38,75), 0, "WALK" );
        }
		else
			m_vActionLocation = vLocation;

		if(rainbowAI.IsInState('TeamMoveTo'))
			rainbowAI.ResetTeamMoveTo();
        rainbowAI.GotoState('TeamMoveTo');
    }

	if(m_iMemberCount > 2)
	{
		for(i=2; i<m_iMemberCount; i++)
			m_Team[i].controller.GotoState('FollowLeader');
	}
}

//------------------------------------------------------------------//
// PlayOrderTeamOnZulu()                                            //
// *** Play only if a Zulu go code is send ***                      //
//------------------------------------------------------------------//
function PlayOrderTeamOnZulu()
{
    if (m_bCAWaitingForZuluGoCode)
	    m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_OrderTeamWithGoCode);
}


//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// MoveTeamToCompleted()                                            //
//------------------------------------------------------------------//
function MoveTeamToCompleted(bool bStatus)
{
	#ifdefDEBUG if(bShowLog) log(self$" MoveTeamToCompleted() bStatus="$bStatus);	#endif
	if(m_iMemberCount > 1)
	{
		m_Team[1].controller.nextState= '';
		m_Team[1].controller.GotoState('HoldPosition');
	}
    ActionCompleted(bStatus);
}

//TEAM_InteractDevice
//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// ReorganizeTeamToInteractWithDevice()                             //
// todo : need to do the same for interacting with an electronics   //
//        device (computer/keypad).									//
//------------------------------------------------------------------//
function ReorganizeTeamToInteractWithDevice(INT iTeamAction, actor actionObject)
{
    local   R6Rainbow   actionMember;
	local   INT			iMember;
	local   FLOAT       fMemberSkill, fBestSkill;

	#ifdefDEBUG if(bShowLog) log(self$" ReorganizeTeamToInteractWithDevice() was called...");	#endif

	// choose member with highest skill and/or diffuse kit
	for( iMember = 0; iMember < m_iMemberCount; iMember++ )
	{
		if(m_Team[iMember].m_bIsPlayer)
			continue;

		// get the member's skill level for the action
		if(iTeamAction == TEAM_DisarmBomb)
			fMemberSkill = m_Team[iMember].GetSkill( SKILL_Demolitions );
		else
			fMemberSkill = m_Team[iMember].GetSkill( SKILL_Electronics );

		// if a member has the appropriate kit for the action, add +20 to the skill
		if(  (iTeamAction == TEAM_DisarmBomb     &&  m_Team[iMember].m_bHasDiffuseKit)
		  || (iTeamAction == TEAM_InteractDevice &&  m_Team[iMember].m_bHasElectronicsKit) )
			fMemberSkill += 20;

		if(fMemberSkill > fBestSkill)
		{
			actionMember = m_Team[iMember];
			fBestSkill = fMemberSkill;
		}	
	}
		
	#ifdefDEBUG	if(bShowLog) log(self$" member chosen to interact with device : actionMember="$actionMember$" actionMember.m_iId="$actionMember.m_iId);	#endif
	if(m_bLeaderIsAPlayer)
	{
		if(actionMember.m_iId != 1)
			ReOrganizeTeam(actionMember.m_iId);
	}
	else
	{
		// reorganize team if member chosen is not in position 1 (second to lead)
		if(actionMember.m_iId != 0)
			ReOrganizeTeam(actionMember.m_iId);

		// set members in appropriate states to diffuse the bomb / or interact with device
		m_iTeamAction = iTeamAction;
		R6RainbowAI(m_Team[0].controller).m_ActionTarget = actionObject;
		m_vActionLocation = actionObject.location - 80*vector(actionObject.rotation);		
		m_Team[0].controller.GotoState('TeamMoveTo');
	}
}

//------------------------------------------------------------------//
// ReOrganizeTeamForGrenade											//
//   for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForGrenade(EPlanAction ePAction)
{
    local   R6Rainbow   actionMember;
	local	INT			i;

	#ifdefDEBUG if(bShowLog) log(self$" ReOrganizeTeamForGrenade() : if team lead does not have desired grenade type, reorganize team... eAction="$ePAction);	#endif
	switch(ePAction)
	{
		case PACT_Frag:		m_eEntryGrenadeType = GT_GrenadeFrag;		break;
		case PACT_Gas:		m_eEntryGrenadeType = GT_GrenadeGas;		break;
		case PACT_Flash:	m_eEntryGrenadeType = GT_GrenadeFlash;		break;
		case PACT_Smoke:	m_eEntryGrenadeType = GT_GrenadeSmoke;		break;
		default:			m_eEntryGrenadeType = GT_GrenadeNone;
	}	
	// reorganize team only if necessary... (if lead does not have the desired grenade type)
	actionMember = FindRainbowWithGrenadeType(m_eEntryGrenadeType, true);	
	if(actionMember == none)
	{
		#ifdefDEBUG if(bShowLog) log(self$" no one in team has the desired "$m_eEntryGrenadeType$" grenade, continue...");	#endif
		m_bSkipAction = true;
		return;
	}
	#ifdefDEBUG if(bShowLog) log(self$" - "$actionMember$" was chosen to throw the grenade, reorganize! m_eEntryGrenadeType="$m_eEntryGrenadeType);	#endif
	if(actionMember.m_iId != 0)
		ReOrganizeTeam(actionMember.m_iId);
}

//------------------------------------------------------------------//
// SelectMemberWithFrag()											//
//------------------------------------------------------------------//
function R6Pawn SelectMemberWithFrag(INT iSubAction, Actor target)
{
    local   R6Pawn  actionMember;

	if(target.IsA('R6IORotatingDoor'))
	{
		switch( iSubAction )
		{
			case R6IORotatingDoor(target).eDoorCircumstantialAction.CA_GrenadeFrag:
				m_eEntryGrenadeType = GT_GrenadeFrag;
				break;
			case R6IORotatingDoor(target).eDoorCircumstantialAction.CA_GrenadeGas:
				m_eEntryGrenadeType = GT_GrenadeGas;
				break;
			case R6IORotatingDoor(target).eDoorCircumstantialAction.CA_GrenadeFlash:
				m_eEntryGrenadeType = GT_GrenadeFlash;
				break;
			case R6IORotatingDoor(target).eDoorCircumstantialAction.CA_GrenadeSmoke:
				m_eEntryGrenadeType = GT_GrenadeSmoke;
				break;
			default:
				m_eEntryGrenadeType = GT_GrenadeNone;
		}
	}
	else
	{
        if(R6PlayerController(target) == none)
		{
			#ifdefDEBUG if(bShowLog) log("  PROBLEM : SelectMemberWithFrag was called with an invalid target ");	#endif
			return none;
		}

		switch( iSubAction )
		{
			case R6PlayerController(target).eDefaultCircumstantialAction.PCA_GrenadeFrag:
				m_eEntryGrenadeType = GT_GrenadeFrag;
				break;
			case R6PlayerController(target).eDefaultCircumstantialAction.PCA_GrenadeGas:
				m_eEntryGrenadeType = GT_GrenadeGas;
				break;
			case R6PlayerController(target).eDefaultCircumstantialAction.PCA_GrenadeFlash:
				m_eEntryGrenadeType = GT_GrenadeFlash;
				break;
			case R6PlayerController(target).eDefaultCircumstantialAction.PCA_GrenadeSmoke:
				m_eEntryGrenadeType = GT_GrenadeSmoke;
				break;
			default:
				m_eEntryGrenadeType = GT_GrenadeNone;
		}
	}

	if( m_eEntryGrenadeType != GT_GrenadeNone )
	{
        if (m_TeamLeader.m_bIsPlayer)   
        {
            switch(m_eEntryGrenadeType)
            {
                case GT_GrenadeFrag:
                    switch(m_iTeamAction)
                    {
                        case TEAM_MoveAndGrenade:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamMoveAndFrag);
                            break;
                        case TEAM_GrenadeAndClear:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamFragAndClear);
                            break;
                        case TEAM_OpenAndGrenade:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenAndFrag);
                            break;
                        case TEAM_OpenGrenadeAndClear:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenFragAndClear);
                            break;
                    }
                    break;
                case GT_GrenadeGas:
                    switch(m_iTeamAction)
                    {
                        case TEAM_MoveAndGrenade:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamMoveAndGas);
                            break;
                        case TEAM_GrenadeAndClear:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamGasAndClear);
                            break;
                        case TEAM_OpenAndGrenade:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenAndGas);
                            break;
                        case TEAM_OpenGrenadeAndClear:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenGasAndClear);
                            break;
                    }
                    break;
                case GT_GrenadeFlash:
                    switch(m_iTeamAction)
                    {
                        case TEAM_MoveAndGrenade:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamMoveAndFlash);
                            break;
                        case TEAM_GrenadeAndClear:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamFlashAndClear);
                            break;
                        case TEAM_OpenAndGrenade:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenAndFlash);
                            break;
                        case TEAM_OpenGrenadeAndClear:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenFlashAndClear);
                            break;
                    }
                    break;
                case GT_GrenadeSmoke:
                    switch(m_iTeamAction)
                    {
                        case TEAM_MoveAndGrenade:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamMoveAndSmoke);
                            break;
                        case TEAM_GrenadeAndClear:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamSmokeAndClear);
                            break;
                        case TEAM_OpenAndGrenade:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenAndSmoke);
                            break;
                        case TEAM_OpenGrenadeAndClear:
                            m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_TeamOpenSmokeAndClear);
                            break;
                    }
                    break;
            }
        }
        actionMember = FindRainbowWithGrenadeType( m_eEntryGrenadeType, true );
	}

	// No member with requested grenade type.
	if( actionMember != none )
	{
		// reorder team based on who the actionMember is
		ReOrganizeTeam(actionMember.m_iId);
	}		

	return(actionMember);
}

//------------------------------------------------------------------//
// rbrek - 2 sept 2001                                              //
// function AssignAction()                                          //
//    ( target is a R6IORotatingDoor )                              //
//------------------------------------------------------------------//
function AssignAction(Actor target, INT iSubAction)
{
    local   R6Pawn			actionMember;
    local   R6Door			closestDoor;    
    local   FLOAT			fDistA, fDistB;
	local   R6RainbowAI		actionMemberController;
	local	INT				i;

	if((m_iMemberCount == 1) || (!target.IsA('R6IORotatingDoor')))
         return;

	#ifdefDEBUG if(bShowLog) log(self$" AssignAction: target = "$target$" iSubAction="$iSubAction);	#endif

	TeamIsSeparatedFromLead(true); 
	m_iSubAction = iSubAction;

	// target is a door. if the action requested required a grenade,
	// look for a member with that type of grenade.
	if( iSubAction != -1 )
	{
		actionMember = SelectMemberWithFrag(m_iSubAction, target);
		if(actionMember == none)
		{
			#ifdefDEBUG if(bShowLog) log(self$" AssignAction() : no member with requested grenade type");	#endif
			ActionCompleted(false);
			return;
		}
	}
	else if((m_iTeamAction & TEAM_Grenade) > 0)		// the action include a grenade action, and grenade type is invalid
	{
		#ifdefDEBUG if(bShowLog) log(self$" AssignAction() : invalid grenade type");	#endif	
		ActionCompleted(false);
		return;
	}

	if( actionMember == none )
		actionMember = m_Team[1];  		// assign member to perform the action (for now, member 1)

    PlayOrderTeamOnZulu();

    m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamReceiveOrder);

    // find target R6Door
	#ifdefDEBUG if(bShowLog) log(self$" Target Rotating Door :"$R6IORotatingDoor(target));	#endif
	#ifdefDEBUG if(bShowLog) log(self$" m_DoorActorA = "$R6IORotatingDoor(target).m_DoorActorA$" m_DoorActorB = "$R6IORotatingDoor(target).m_DoorActorB);	#endif
    if(R6IORotatingDoor(target).m_DoorActorA != none)
		fdistA = VSize(R6IORotatingDoor(target).m_DoorActorA.location - actionMember.location);
	else
		fdistA = 99999;

	if(R6IORotatingDoor(target).m_DoorActorB != none)
		fdistB = VSize(R6IORotatingDoor(target).m_DoorActorB.location - actionMember.location);
	else
		fdistB = 99999;

	actionMemberController = R6RainbowAI(actionMember.controller);
    if(fdistA < fdistB)
        actionMemberController.m_ActionTarget = R6IORotatingDoor(target).m_DoorActorA;
    else
        actionMemberController.m_ActionTarget = R6IORotatingDoor(target).m_DoorActorB;
	
	actionMemberController.ResetStateProgress();
	actionMemberController.nextState = 'HoldPosition';
    actionMemberController.GotoState('PerformAction');
	if(m_iMemberCount > 2)
	{
		for(i=2; i<m_iMemberCount; i++)
			m_Team[i].controller.GotoState('FollowLeader');
	}
}


//------------------------------------------------------------------//
// FindRainbowWithGrenadeType()			                            //
//	Look for a rainbow (other than the player) with a grenade of a  //
//	given type.														//
//------------------------------------------------------------------//
simulated function R6Rainbow FindRainbowWithGrenadeType( R6AbstractWeapon.eWeaponGrenadeType grenadeType, bool bSetGadgetGroup )
{
	local INT				iMember;
	local INT				iWeaponGroup;
	local R6EngineWeapon    grenadeWeapon;
	local BOOL				bHasGrenade;

	// For each team member
	for( iMember = 0; iMember < m_iMemberCount; iMember++ )
	{
        if (m_Team[iMember] == none || m_Team[iMember].m_bIsPlayer || !m_Team[iMember].IsAlive())
            continue;

		// For each gadget group
		for( iWeaponGroup = 3; iWeaponGroup <= 4; iWeaponGroup++ )
		{
			bHasGrenade = false;
			grenadeWeapon = m_Team[iMember].GetWeaponInGroup(iWeaponGroup);
			// if the weapon in this group is a grenade and that there is grenades left
			// see if it's the type we're looking for
			if( grenadeWeapon != None && grenadeWeapon.m_eWeaponType == WT_Grenade && grenadeWeapon.HasAmmo() )
			{ 
				switch( grenadeType )
				{
				case GT_GrenadeFrag:
					if( grenadeWeapon.HasBulletType('R6FragGrenade') )
						bHasGrenade = true;
					break;
				case GT_GrenadeGas:
					if( grenadeWeapon.HasBulletType('R6TearGasGrenade') )
						bHasGrenade = true;
					break;
				case GT_GrenadeFlash:
					if( grenadeWeapon.HasBulletType('R6FlashBang') )
						bHasGrenade = true;
					break;
				case GT_GrenadeSmoke:
					if( grenadeWeapon.HasBulletType('R6SmokeGrenade') )
						bHasGrenade = true;
					break;
				}
			}		

			// We've found a rainbow with a grenade, make sure it's not the player
			if( bHasGrenade && !m_Team[iMember].m_bIsPlayer)
			{
				if(bSetGadgetGroup && (m_Team[iMember].controller != none))
					R6RainbowAI(m_Team[iMember].controller).m_iActionUseGadgetGroup = iWeaponGroup;
				return m_Team[iMember];
			}
		}
	}   

	return none;
}

//------------------------------------------------------------------//
// rbrek - 2 sept 2001                                              //
// ActionCompleted()												//
//   this function is called to inform the TeamAI that a requested  //
//   action has been completed (or in not possible to complete      //
//------------------------------------------------------------------//
function ActionCompleted(bool bSuccess)
{
    local		INT		i;
	local		INT		iMember;

    #ifdefDEBUG if(bShowLog) log(self$" ActionCompleted() was called with bSuccess="$bSuccess);	#endif
	if(!bSuccess)
		ResetZuluGoCode();
	
    if (m_TeamLeader.m_bIsPlayer)
    {
		if (m_iMemberCount > 1)
		{
			m_bTeamIsHoldingPosition = true;
			if(bSuccess)
			{
				if((m_iTeamAction & TEAM_ClearRoom) > 0)
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_DoorReform);
			}
			else
                m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], RMV_TeamOrderFromLeadNil);
		}
    }
	else
	{
		// team is led by a Rainbow AI; make sure team regroups on leader
		if(m_iMemberCount > 1)
		{
			for(iMember=1; iMember<m_iMemberCount; iMember++)
				m_Team[iMember].controller.GotoState('FollowLeader');		
		}
        TeamIsSeparatedFromLead(false);
	}

    m_iTeamAction = TEAM_None;
}

function ReIssueTeamOrders()
{
	#ifdefDEBUG if(bShowLog) log(self$" ReIssueTeamOrders() called.... m_iTeamAction = "$m_iTeamAction$" m_actionRequested.iMenuChoice="$m_actionRequested.iMenuChoice);		#endif

	if(m_actionRequested.iMenuChoice == -1)
		TeamActionRequest(m_actionRequested);
	else if(m_bCAWaitingForZuluGoCode)
		TeamActionRequestWaitForZuluGoCode(m_actionRequested, m_actionRequested.iMenuChoice,m_actionRequested.iSubMenuChoice);
	else
		TeamActionRequestFromRoseDesVents(m_actionRequested, m_actionRequested.iMenuChoice,m_actionRequested.iSubMenuChoice);
}

//------------------------------------------------------------------//
//  RainbowIsInFrontOfAClosedDoor()									//
//    when this occurs, the team members should enter an			//
//    appropriate formation depending on the room behind the door   //
//    ROOM_None, ROOM_OpensLeft, ROOM_OpensRight, ROOM_OpensCenter  //
// This function is called from R6Pawn when either a teamleader (or //
// the 2nd team member in a team that is separated from its leader) //
// comes into contact with a closed door							//
//------------------------------------------------------------------//
function RainbowIsInFrontOfAClosedDoor(R6Pawn rainbow, R6Door door)
{
    local   INT     i;
    local   INT     iOpensClockwise;
    local   INT     iStart;
    
#ifdefDEBUG		
	if(bShowLog) log(self$" XXX : RainbowIsInFrontOfAClosedDoor() : rainbow="$rainbow$" door="$door$" m_bTeamIsSeparatedFromLeader="$m_bTeamIsSeparatedFromLeader);
	if(bShowLog) log(self$" XXX : door.m_RotatingDoor="$door.m_RotatingDoor$" m_bEntryInProgress="$m_bEntryInProgress$" door.m_CoorespondingDoor="$door.m_CorrespondingDoor);
#endif
    if(rainbow.m_bIsPlayer && (m_bTeamIsSeparatedFromLeader || m_bTeamIsClimbingLadder))
        return; 
	
    m_Door = door;
    m_PawnControllingDoor = rainbow;

	if(m_Door.m_RotatingDoor.m_bTreatDoorAsWindow)
		return;

	m_bRainbowIsInFrontOfDoor = true;
	m_bEntryInProgress = true;

    #ifdefDEBUG	if(bShowLog) log(self$" - "$rainbow$" is in front of a closed door... m_Door="$m_Door);	#endif
    m_bDoorOpensTowardTeam = door.m_RotatingDoor.DoorOpenTowardsActor(rainbow);
    m_bDoorOpensClockWise = door.m_RotatingDoor.m_bIsOpeningClockWise;
    
    if(rainbow == m_TeamLeader)
		iStart=1;
    else
		iStart=rainbow.m_iId + 1;  

	if(!rainbow.m_bIsPlayer)
		R6RainbowAI(rainbow.controller).m_bEnteredRoom = false;

    for(i=iStart; i<m_iMemberCount; i++)
    {
		R6RainbowAI(m_Team[i].controller).ResetStateProgress();
        if(m_Team[i].m_bIsClimbingLadder)
			m_Team[i].controller.nextState = 'RoomEntry';
		else
			m_Team[i].controller.GotoState('RoomEntry');
    }    
}

//------------------------------------------------------------------//
//  EnteredRoom()													//
//   called by each member of the team once they have entered...    //
//   this function should also be called once player/leader has     //
//   entered the room                                               //
//------------------------------------------------------------------//
function EnteredRoom(R6Pawn member)
{
    local   INT     i;

	#ifdefDEBUG	if(bShowLog) log(self$" - "$member$" has EnteredRoom()");	#endif
    if(!m_bEntryInProgress)
        return;     // log this later, is not normal that a member still be in state Room Entry...

	if(!member.m_bIsPlayer)
		R6RainbowAI(member.controller).m_bEnteredRoom = true;

    // TODO: check position of team leader(player), and send other members in accordingly...
	if((member.m_iId == (m_iMemberCount - 1)) || (m_bTeamIsSeparatedFromLeader && m_PawnControllingDoor.m_bIsPlayer))
	{
        #ifdefDEBUG	if(bShowLog) log(self$" - "$member$" the last member has entered the room....");	#endif
        m_bEntryInProgress = false;
	}
}

//------------------------------------------------------------------//
//  HasGoneThroughDoor()											//
//------------------------------------------------------------------//
function bool HasGoneThroughDoor()
{
	if( (normal(m_PawnControllingDoor.location - m_Door.location) dot m_Door.m_vLookDir) < 0)
		return false;
	else
		return true;
}

//------------------------------------------------------------------//
// EndRoomEntry()													//
//   Room entry has been cancelled									//
//------------------------------------------------------------------//
function EndRoomEntry()
{    
	local	INT		iStart, i;
	
	m_PawnControllingDoor = none;
    m_bEntryInProgress = false;

	#ifdefDEBUG	if(bShowLog) log(self$" EndRoomEntry() : make sure all team members are following leader...m_bTeamIsSeparatedFromLeader="$m_bTeamIsSeparatedFromLeader);	#endif
    if(m_iMemberCount == 1)
		return;

	if(m_bTeamIsSeparatedFromLeader)
		iStart = 2;
	else
		iStart = 1;
 
	for(i=iStart; i<m_iMemberCount; i++)
    {
        m_Team[i].controller.GotoState('FollowLeader');
    } 
}

//------------------------------------------------------------------//
// RainbowHasLeftDoor()												//
//   this function is called in a few different cases...			//
//   . door opens and m_PawnControllingDoor goes through open door  //
//   . door opens and m_PawnControllingDoor leaves door area		//
//   . door is not opened, m_PawnControllingDoor leaves area		//
//------------------------------------------------------------------//
function RainbowHasLeftDoor(R6Pawn rainbow)
{
    local   INT     i;
    local   INT     iStart;
    local   vector  vDist; 
	local   FLOAT   fDir;
	local   vector	vDir;

	if(m_Door == none || m_Door.m_RotatingDoor == none)
		return;

#ifdefDEBUG	
	if(bShowLog) log(self$"  RainbowHasLeftDoor() rainbow="$rainbow$" m_bEntryInProgress="$m_bEntryInProgress$" m_bRainbowIsInFrontOfDoor="$m_bRainbowIsInFrontOfDoor);
	if(bShowLog) log(self$" m_PawnControllingDoor="$m_PawnControllingDoor$" m_PawnControllingDoor.m_bIsPlayer="$m_PawnControllingDoor.m_bIsPlayer);	
	if(bShowLog) log(self$" m_bTeamIsSeparatedFromLeader="$m_bTeamIsSeparatedFromLeader);	
#endif

	if(m_Door.m_RotatingDoor.m_bTreatDoorAsWindow)
	{
		m_Door = none;
		m_PawnControllingDoor = none;
		return;
	}
	
    if((m_iMemberCount <= 1) || !m_bEntryInProgress || !m_bRainbowIsInFrontOfDoor)
		return;

	if(rainbow != none && rainbow.m_bIsPlayer && m_bTeamIsSeparatedFromLeader)
		return;

	m_bRainbowIsInFrontOfDoor = false;

#ifdefDEBUG	
	if(bShowLog) log(self$" RainbowHasLeftDoor() : m_Door.m_RotatingDoor.m_bIsDoorClosed="$m_Door.m_RotatingDoor.m_bIsDoorClosed);
	if(bShowLog) log(self$" m_PawnControllingDoor.velocity="$m_PawnControllingDoor.velocity);
#endif

    // check to see if player has entered room, or just left the area...
    // TODO : when player decides not to storm a room after having opened the door, the team tries to enter anyway...
    if((!m_Door.m_RotatingDoor.m_bIsDoorClosed || m_Door.m_RotatingDoor.m_bInProcessOfOpening) && HasGoneThroughDoor())
    {
        // the door is open so the player has entered the room...   
		#ifdefDEBUG	if(bShowLog) log(self$" - "$m_PawnControllingDoor$" pawn has entered room....");	#endif

        EnteredRoom(m_PawnControllingDoor); 
		m_PawnControllingDoor = none; 

    }
    else
    {
		#ifdefDEBUG	if(bShowLog) log(self$" - "$m_PawnControllingDoor$" pawn did not enter room....");	#endif
        m_Door = none;

        if(m_PawnControllingDoor == m_TeamLeader)
            iStart = 1;
        else
            iStart = 2;

        for(i=iStart; i<m_iMemberCount; i++)
        {
            m_Team[i].controller.GotoState('FollowLeader');
        } 

		EndRoomEntry();
    }
}

//------------------------------------------------------------------//
//  GetPlayerDirection()											//
//------------------------------------------------------------------//
function GetPlayerDirection()
{
	local   FLOAT   fDirResult;
	local   vector	vCrossDir;
	local   vector  vPlayerMove;
	
	if(!m_TeamLeader.m_bIsPlayer)
		return;

	// get the player's movement direction...
	vPlayerMove = normal(m_TeamLeader.location - m_Door.location);
	fDirResult = vPlayerMove dot m_Door.m_vLookDir;
	vCrossDir = vPlayerMove cross m_Door.m_vLookDir;

	if(m_Door.m_eRoomLayout == ROOM_OpensLeft)
	{
		if((fDirResult > 0.9) || (vCrossDir.z > 0)) 
			m_ePlayerRoomEntry = PRE_Right;
		else if(fDirResult > 0.4)
			m_ePlayerRoomEntry = PRE_Center;
		else
			m_ePlayerRoomEntry = PRE_Left;
	}
	else if(m_Door.m_eRoomLayout == ROOM_OpensRight)
	{
		if((fDirResult > 0.9) || (vCrossDir.z < 0)) 
			m_ePlayerRoomEntry = PRE_Left;
		else if(fDirResult > 0.4)
			m_ePlayerRoomEntry = PRE_Center;
		else
			m_ePlayerRoomEntry = PRE_Right;
	}
	else
	{
		if(fDirResult > 0.9)
			m_ePlayerRoomEntry = PRE_Center; 
		else
		{			
			if(vCrossDir.z > 0)
				m_ePlayerRoomEntry = PRE_Left;  
			else
				m_ePlayerRoomEntry = PRE_Right; 
		}
	}
}

//------------------------------------------------------------------//
//  UpdatePlayerWeapon()											//
//------------------------------------------------------------------//
function UpdatePlayerWeapon(R6Rainbow rainbow)
{
    //Reset the Weapons Attachments
    rainbow.AttachWeapon(rainbow.EngineWeapon, rainbow.EngineWeapon.m_AttachPoint);

    //Weapon Update when changing characters
    if((rainbow.EngineWeapon != rainbow.GetWeaponInGroup(1)) && (rainbow.GetWeaponInGroup(1) != none))
    {
        //Reset Main Weapon's draw properties and location since they're not updated in first person
        rainbow.AttachWeapon(rainbow.GetWeaponInGroup(1), rainbow.GetWeaponInGroup(1).m_HoldAttachPoint);
    }
    if((rainbow.EngineWeapon != rainbow.GetWeaponInGroup(2)) && (rainbow.GetWeaponInGroup(2) != none))
    {
        //Reset secondary Weapon's draw properties and location since they're not updated in first person
        rainbow.AttachWeapon(rainbow.GetWeaponInGroup(2), rainbow.GetWeaponInGroup(2).m_HoldAttachPoint);
    }
    if((rainbow.EngineWeapon != rainbow.GetWeaponInGroup(3)) && (rainbow.GetWeaponInGroup(3) != none))
    {
        //Reset secondary Weapon's draw properties and location since they're not updated in first person
        rainbow.AttachWeapon(rainbow.GetWeaponInGroup(3), rainbow.GetWeaponInGroup(3).m_HoldAttachPoint);
    }
    if((rainbow.EngineWeapon != rainbow.GetWeaponInGroup(4)) && (rainbow.GetWeaponInGroup(4) != none))
    {
        //Reset secondary Weapon's draw properties and location since they're not updated in first person
        rainbow.AttachWeapon(rainbow.GetWeaponInGroup(4), rainbow.GetWeaponInGroup(4).m_HoldAttachPoint);
    }
   
    //set the weapon's gadget if it was activated.
    if(rainbow.m_bWeaponGadgetActivated == true)
    {
        //Reactivate the gadget, it should attach it to the 3rd person character.
        R6AbstractWeapon(rainbow.EngineWeapon).m_SelectedWeaponGadget.ActivateGadget(TRUE, TRUE);
    }
    
    //Turn Off the Night vision  TODO: check with design about night vision.
    if(rainbow.m_bActivateNightVision == true)
    {
        rainbow.ToggleNightVision();
    }
    
}

//------------------------------------------------------------------//
//  UpdateFirstPersonWeaponMemory()									//
//------------------------------------------------------------------//
function UpdateFirstPersonWeaponMemory(R6Rainbow npc, R6Rainbow teamLeader)
{
    local INT i;
    local R6AbstractWeapon LeaderWeapon;
    local R6AbstractWeapon NPCWeapon;

	if(Level.NetMode == NM_Standalone)
	{
        for(i=1; i<=4; i++)
        {
	        if(npc.GetWeaponInGroup(i) != none)
            {
                npc.GetWeaponInGroup(i).StopFire(true);
                npc.GetWeaponInGroup(i).RemoveFirstPersonWeapon(); //Free memory taken by First Person Weapon meshes
            }

	        if(teamLeader.GetWeaponInGroup(i) != none)
		        teamLeader.GetWeaponInGroup(i).LoadFirstPersonWeapon(); // load FP weapons of the new pawn controlled by the character
        }
        if(teamLeader.m_bChangingWeapon == true)
        {
            //Hide Engine Weapon before it's replaced by the pending weapon
            R6AbstractWeapon(teamLeader.EngineWeapon).m_FPHands.SetDrawType(DT_None);
            teamLeader.EngineWeapon.GotoState('DiscardWeapon');

            teamLeader.PendingWeapon.m_bPawnIsWalking = teamLeader.EngineWeapon.m_bPawnIsWalking;
            teamLeader.EngineWeapon = teamLeader.PendingWeapon;
            
            if(teamLeader.EngineWeapon.IsInState('RaiseWeapon'))
                teamLeader.EngineWeapon.BeginState();
            else
                teamLeader.EngineWeapon.GotoState('RaiseWeapon');
        }
        else
        {
            teamLeader.EngineWeapon.StartLoopingAnims();
        }
	}
	else
	{
        teamLeader.m_bReloadingWeapon = false;
        teamLeader.m_bPawnIsReloading = false;
        teamLeader.m_bWeaponTransition = false;
        npc.m_bReloadingWeapon = false;
        npc.m_bPawnIsReloading = false;
        npc.m_bWeaponTransition = false;

        //log("Just changed to character   :"$teamLeader.Role$" : "$teamLeader.RemoteRole$" : "$teamLeader.Controller);
        //log("Just changed from character :"$npc.Role$" : "$npc.RemoteRole$" : "$npc.Controller);

        if((Level.NetMode != NM_DedicatedServer) && teamLeader.IsLocallyControlled())
            teamLeader.RemoteRole = ROLE_SimulatedProxy;
        else
            teamLeader.RemoteRole = ROLE_AutonomousProxy;
        npc.RemoteRole = ROLE_SimulatedProxy;

        for(i=1; i<=4; i++)
        {
            LeaderWeapon = R6AbstractWeapon(teamLeader.GetWeaponInGroup(i));
            NPCWeapon = R6AbstractWeapon(npc.GetWeaponInGroup(i));
            if(LeaderWeapon != none)
            {
                if((Level.NetMode != NM_DedicatedServer) && teamLeader.IsLocallyControlled())
                    LeaderWeapon.RemoteRole = ROLE_SimulatedProxy;
                else
                    LeaderWeapon.RemoteRole = ROLE_AutonomousProxy;
                NPCWeapon.RemoteRole = ROLE_SimulatedProxy;
            }
        }
		ClientUpdateFirstPersonWpnAndPeeking(npc, teamLeader);
	}
}

//Transfer the FPhands and FPweapons to an other pawn.  On client  only
simulated function ClientUpdateFirstPersonWpnAndPeeking(R6Rainbow npc, R6Rainbow teamLeader)
{
    local INT i;
    local BOOL bLoadWorked;
    local R6AbstractWeapon LeaderWeapon;
    local R6AbstractWeapon NPCWeapon;
	local Texture scopeTexture;
    local R6PlayerController LocalController;

    //One of the two pawn has the player controller, Maybe the NPC, it's just not replicated yet.
    LocalController = R6PlayerController(npc.controller);
    if(LocalController == none)
        LocalController = R6PlayerController(teamLeader.controller);

    if(Level.NetMode == NM_Client)
    {
        teamLeader.Role = ROLE_AutonomousProxy;
        npc.Role = ROLE_SimulatedProxy;
    }
    //log("Just changed to character   :"$teamLeader.RemoteRole$" : "$teamLeader.Role$" : "$teamLeader.Controller);
    //log("Just changed from character :"$npc.RemoteRole$" : "$npc.Role$" : "$npc.Controller);

    //reset the flag locally.
    teamLeader.bRotateToDesired = false;

    for(i=1; i<=4; i++)
    {
        LeaderWeapon = R6AbstractWeapon(teamLeader.GetWeaponInGroup(i));
        NPCWeapon = R6AbstractWeapon(npc.GetWeaponInGroup(i));
        if(LeaderWeapon != none)
        {
            if(Level.NetMode == NM_Client)
            {
                LeaderWeapon.Role = ROLE_AutonomousProxy;
                NPCWeapon.Role = ROLE_SimulatedProxy;
            }

            npc.GetWeaponInGroup(i).RemoveFirstPersonWeapon(); //Free memory taken by First Person Weapon meshes
		    bLoadWorked = teamLeader.GetWeaponInGroup(i).LoadFirstPersonWeapon( ,LocalController); // load FP weapons of the new pawn controlled by the character
        }
    }

    if(bLoadWorked == true)
    {
        if(teamLeader.m_bChangingWeapon == true)
        {
            //Hide Engine Weapon before it's replaced by the pending weapon
            if(teamLeader.EngineWeapon != teamLeader.PendingWeapon)
            {
                R6AbstractWeapon(teamLeader.EngineWeapon).m_FPHands.SetDrawType(DT_None);
                teamLeader.EngineWeapon.GotoState('');
                
                teamLeader.PendingWeapon.m_bPawnIsWalking = teamLeader.EngineWeapon.m_bPawnIsWalking;
                teamLeader.EngineWeapon = teamLeader.PendingWeapon;
            }
        
            LocalController.m_bLockWeaponActions = true;
            if(teamLeader.EngineWeapon.IsInState('RaiseWeapon'))
            {
                teamLeader.EngineWeapon.BeginState();
            }
            else
            {
                teamLeader.EngineWeapon.GotoState('RaiseWeapon');
            }
        }
        else 
        {
            if(teamLeader.EngineWeapon != none)
		        teamLeader.EngineWeapon.StartLoopingAnims();
        }
    }

    LocalController.SetPeekingInfo( PEEK_none, npc.C_fPeekMiddleMax ); 
}

//------------------------------------------------------------------
// ResetWeaponReloading()							
//------------------------------------------------------------------
function ResetWeaponReloading()
{
    if(m_Team[0].m_bPawnIsReloading == true)
    {
        m_Team[0].ServerSwitchReloadingWeapon(false);
        m_Team[0].m_bPawnIsReloading=false;
        m_Team[0].GotoState('');
        m_Team[0].PlayWeaponAnimation();
    }
}

//------------------------------------------------------------------
// SetPlayerControllerState()													
//------------------------------------------------------------------
function SetPlayerControllerState(R6PlayerController aPlayerController)
{
	if(m_Team[0].m_bIsClimbingLadder)
	{
		aPlayerController.ClientHideReticule(true);
		m_Team[0].EngineWeapon.GotoState('PutWeaponDown');
		if(m_Team[0].Physics == PHYS_RootMotion)
		{
			// Physics is ROOT MOTION
			aPlayerController.m_bSkipBeginState = true;
			if(m_Team[0].m_bGettingOnLadder)
				aPlayerController.GotoState('PlayerBeginClimbingLadder');
			else
				aPlayerController.GotoState('PlayerEndClimbingLadder');
		}
		else 
		{
			// PHYS_Ladder
			aPlayerController.m_bSkipBeginState = false;			
			aPlayerController.GotoState('PlayerClimbing');
		}
	}
	else
	{		
		if(m_Team[0].physics == PHYS_Ladder && m_Team[0].onLadder != none)
		{
			// pawn was right about to get on a ladder (weapon secured)
			R6LadderVolume(m_Team[0].onLadder).RemoveClimber(m_Team[0]);
			MemberFinishedClimbingLadder(m_Team[0]);
			m_Team[0].RainbowEquipWeapon(); 
			m_Team[0].m_ePlayerIsUsingHands = HANDS_None;
			m_Team[0].m_bWeaponTransition = false;
		}		

		aPlayerController.ClientHideReticule(false);
		aPlayerController.GotoState('PlayerWalking');
		m_Team[0].SetPhysics(PHYS_Walking);
	}

	if(Level.NetMode != NM_Standalone)
	{
		aPlayerController.ClientGotoState(aPlayerController.GetStateName(),'');
		aPlayerController.ClientDisableFirstPersonViewEffects(TRUE);
	}
}

//------------------------------------------------------------------
// SetAILeadControllerState()													
//------------------------------------------------------------------
function SetAILeadControllerState()
{
	local R6Ladder topLadder, bottomLadder;

	if(m_TeamLeader.m_bIsPlayer)
		return;

	if(m_TeamLeader.m_bIsClimbingLadder)
	{
		topLadder = R6LadderVolume(m_TeamLeader.OnLadder).m_TopLadder;
		bottomLadder = R6LadderVolume(m_TeamLeader.OnLadder).m_BottomLadder;

		m_TeamLeader.controller.nextState = 'WaitForTeam';

		// set the rainbow AI state
		if(m_TeamLeader.physics == PHYS_RootMotion)
		{
			R6RainbowAI(m_TeamLeader.controller).m_bMoveTargetAlreadySet = true;
			if(m_TeamLeader.m_bGettingOnLadder)
				m_TeamLeader.controller.GotoState('BeginClimbingLadder','WaitForStartClimbingAnimToEnd');
			else
				m_TeamLeader.controller.GotoState('EndClimbingLadder', 'WaitForEndClimbingAnimToEnd');
		}
		else
		{
			// Rainbow AI is not in Root Motion...
			m_TeamLeader.controller.GotoState('BeginClimbingLadder','MoveTowardEndOfLadder');
		}

		// pick an appropriate direction to move
		if( (m_PlanActionPoint != none)	&& (abs(m_PlanActionPoint.location.z - topLadder.location.z) < abs(m_PlanActionPoint.location.z - bottomLadder.location.z)) )
			m_TeamLeader.controller.moveTarget = topLadder;
		else
			m_TeamLeader.controller.moveTarget = bottomLadder;
	}
	else
	{
		m_TeamLeader.controller.GotoState('Patrol');
		m_TeamLeader.SetPhysics(PHYS_Walking);

		if(m_TeamLeader.m_eEquipWeapon != EQUIP_Armed)
		{
			m_TeamLeader.RainbowEquipWeapon(); 
			m_TeamLeader.m_ePlayerIsUsingHands = HANDS_None;
			m_TeamLeader.m_bWeaponTransition = false;							
		}		
	}
}

//------------------------------------------------------------------
// ResetRainbowControllerStates()							
//------------------------------------------------------------------
function ResetRainbowControllerStates(R6PlayerController aPlayerController, INT iMember)
{
	local	INT		i;
	local   bool	bAtLeastOneMemberIsOnLadder;

	//////////////////////////////////////////////////////////
	// set the playerController's state appropriately
	//////////////////////////////////////////////////////////
	SetPlayerControllerState(aPlayerController);

	//////////////////////////////////////////////////////////
	// set the rest of the team's state appropriately
	//////////////////////////////////////////////////////////
	for(i=1; i<m_iMemberCount; i++)
    {
        R6RainbowAI(m_Team[i].controller).m_TeamLeader = m_TeamLeader;
		if(i == iMember && m_Team[i].m_bIsClimbingLadder)
		{
			m_Team[i].controller.nextState = 'FollowLeader';

			R6LadderVolume(m_Team[i].onLadder).DisableCollisions(m_Team[i].m_Ladder);
			if(m_Team[i].physics == PHYS_RootMotion)
			{
				R6RainbowAI(m_Team[i].controller).m_bMoveTargetAlreadySet = true;
				if(m_Team[i].m_bGettingOnLadder)
					m_Team[i].controller.GotoState('BeginClimbingLadder','WaitForStartClimbingAnimToEnd');
				else
					m_Team[i].controller.GotoState('EndClimbingLadder', 'WaitForEndClimbingAnimToEnd');
			}
			else
			{
				// Rainbow AI is not in Root Motion...
				m_Team[i].controller.GotoState('BeginClimbingLadder','MoveTowardEndOfLadder');
			}			

			// pick an appropriate moveTarget near player
			if(m_Team[0].location.z > (m_Team[i].location.z + 100))
				m_Team[i].controller.moveTarget = R6LadderVolume(m_Team[i].OnLadder).m_TopLadder;
			else
				m_Team[i].controller.moveTarget = R6LadderVolume(m_Team[i].OnLadder).m_BottomLadder;			

			bAtLeastOneMemberIsOnLadder = true;
		}
        else if(!m_Team[i].m_bIsClimbingLadder)
		{
			m_Team[i].controller.GotoState('FollowLeader');
			
			if(m_Team[i].physics != PHYS_Falling)
				m_Team[i].SetPhysics(PHYS_Walking);
			
			if(m_Team[i].m_eEquipWeapon != EQUIP_Armed)
			{
				m_Team[i].RainbowEquipWeapon(); 
				m_Team[i].m_ePlayerIsUsingHands = HANDS_None;
				m_Team[i].m_bWeaponTransition = false;							
			}
		}
		//log("  AI CONTROLLER STATES : m_Team[i]="$m_Team[i]$" m_Team[i].m_bIsClimbingLadder="$m_Team[i].m_bIsClimbingLadder);		
    }

	SetTeamIsClimbingLadder(bAtLeastOneMemberIsOnLadder);
	if(m_bCAWaitingForZuluGoCode)
		ResetZuluGoCode();
}

//------------------------------------------------------------------//
// SwitchPlayerControlToPreviousMember()							//
//   TODO : beware of doing this while team is performing an action //
//------------------------------------------------------------------//
function SwitchPlayerControlToPreviousMember()
{
    local   R6Rainbow           tempPawn;
    local   R6RainbowAI         tempRainbowAI;
    local   R6PlayerController  tempPlayerController;
    local   INT                 iLastMember;
    local   INT                 i;

    if(level.Game!=none && !R6AbstractGameInfo(level.Game).CanSwitchTeamMember())
        return;

    if( !m_Team[0].IsAlive() )
    {
        #ifdefDEBUG	if(bShowLog) log(self$" SwitchPlayerControlToPreviousMember() : leader is dead or incapacitated....");	#endif
        SwitchPlayerControlToNextMember();
        return;
    }
 
	TeamIsSeparatedFromLead(false);
    if(m_iMemberCount <= 1)
        return;

    iLastMember = m_iMemberCount-1;  

    // shift members down in rank : 0 1 2 3 --> 3 0 1 2 
    tempPawn = m_Team[iLastMember];
    for(i=m_iMemberCount-1; i>0; i--)
    {
        m_Team[i] = m_Team[i-1];        
        m_Team[i].m_iId = i;
    }   
    m_Team[0] = tempPawn;
    m_TeamLeader = m_Team[0];
    m_TeamLeader.m_iId = 0;    

    m_Team[1].ClientQuickResetPeeking();
    m_Team[1].m_bIsPlayer = false;
    m_TeamLeader.m_bIsPlayer = true;

    tempPawn = m_Team[1];
	if (tempPawn.m_bIsClimbingLadder == false)
		UpdatePlayerWeapon(tempPawn);
	else if (tempPawn.m_bActivateNightVision == true)
		tempPawn.MandatoryToggleNightVision();
	ResetWeaponReloading();
    
    // switch the controllers 
    tempRainbowAI = R6RainbowAI(m_Team[0].controller);
    tempPlayerController = R6PlayerController(m_Team[1].controller);

    //Switch the Controller Rep info
    SwitchControllerRepInfo(tempRainbowAI, tempPlayerController);

	tempPlayerController.ToggleHelmetCameraZoom(TRUE);      
	tempPlayerController.CancelShake();
    tempPlayerController.ClientForceUnlockWeapon();
    tempPlayerController.m_iPlayerCAProgress = 0;
    //tempPlayerController.m_bLockWeaponActions = false;

	// associate Rainbow AI with its pawn
	m_Team[1].UnPossessed();
    tempRainbowAI.Possess(m_Team[1]);
	
	// associate playercontroller with its pawn
	AssociatePlayerAndPawn(tempPlayerController, m_Team[0]);
	
	// reset position of head
	m_Team[1].PawnLook(rot(0,0,0),,);
    m_Team[1].ResetBoneRotation();
    m_Team[1].m_bPostureTransition = false;

    // reset any bone rotation this pawn may have had with its previous controller...
    m_TeamLeader.ResetBoneRotation();
    m_TeamLeader.ClientQuickResetPeeking();
    m_TeamLeader.m_bPostureTransition = false;

    UpdateFirstPersonWeaponMemory(tempPawn, m_TeamLeader);
	ResetRainbowControllerStates(tempPlayerController, 1);

    m_iIntermLeader = 0;
	tempPlayerController.UpdatePlayerPostureAfterSwitch();
    
    UpdateEscortList();
	UpdateTeamGrenadeStatus();

	if ((m_iTeamAction & TEAM_OpenDoor) > 0 && m_bTeamIsHoldingPosition)
		m_iTeamAction = TEAM_None;
}

//------------------------------------------------------------------//
// SwitchPlayerControlToNextMember()				   			    //
//   TODO : beware of doing this while team is performing an action //
//   TOFIX : sometimes a pawn remains invisible after switching to  //
//          another pawn (in 1st person)                            //
//------------------------------------------------------------------//
function SwitchPlayerControlToNextMember()
{
    local   R6Rainbow           tempPawn;
    local   R6RainbowAI         tempRainbowAI;
    local   R6PlayerController  tempPlayerController;
    local   INT                 iLastMember;
    local   INT                 i;
    local   bool                bLeaderIsDead;
	local   bool				bBackupIsClimbing;

    if(level.Game!=none && !R6AbstractGameInfo(level.Game).CanSwitchTeamMember())
        return;

    bLeaderIsDead = !m_Team[0].IsAlive();
	TeamIsSeparatedFromLead(false);

    if (bLeaderIsDead)
    {
        #ifdefDEBUG	if(bShowLog) log(self$" SwitchPlayerControlToNextMember() : leader is dead or incapacitated....");	#endif
        if(m_iMemberCount == 0)
            return;
        else
            R6PlayerController(m_Team[0].controller).ClientFadeCommonSound(0.5, 100);
    }
    else
    {
        if(m_iMemberCount == 1)
            return;
    }

    iLastMember = m_iMemberCount-1;
    tempPlayerController = R6PlayerController(m_Team[0].controller);	
    if(bLeaderIsDead) 
    {
        tempPawn = m_Team[0];		
        for(i=0; i<m_iMemberCount;i++)
        { 
            m_Team[i] = m_Team[i+1];
            m_Team[i].m_iId = i;
        } 
        
        m_TeamLeader = m_Team[0];
        m_Team[iLastMember+1] = tempPawn;
        m_Team[iLastMember+1].m_iId = iLastMember+1;
		tempPawn.m_bIsPlayer = false;
        m_TeamLeader.m_bIsPlayer = true;

        // The player control the new leader and the ancient controller control the dead pawn
		tempRainbowAI = R6RainbowAI(m_TeamLeader.controller);	
    	tempPlayerController.ToggleHelmetCameraZoom(TRUE);      
	    tempPlayerController.CancelShake();
        tempPlayerController.ClientForceUnlockWeapon();
        tempPlayerController.m_iPlayerCAProgress = 0;
        //tempPlayerController.m_bLockWeaponActions = false;

        //Switch the Controller Rep info
        SwitchControllerRepInfo(tempRainbowAI, tempPlayerController);

		// store m_bIsClimbingLadder as backup: when we call ResetRainbowControllerStates() we check the value of m_bIsClimbingLadder to 
		// determine what the pawn the player is taking control of was doing (on/off ladder)
		// switching to the dead state out of EndClimbingLadder causes m_bIsClimbingLadder to be reset to false.
		bBackupIsClimbing = tempRainbowAI.m_pawn.m_bIsClimbingLadder;
		tempRainbowAI.GotoState('Dead');
		tempRainbowAI.m_pawn.m_bIsClimbingLadder = bBackupIsClimbing;

		m_Team[iLastMember+1].UnPossessed();
		tempRainbowAI.Possess(m_Team[iLastMember+1]);

		// associate playercontroller with its pawn
		AssociatePlayerAndPawn(tempPlayerController, m_TeamLeader);
		if (bBackupIsClimbing)
			SetTeamIsClimbingLadder(true);
    }
    else
    { 
        // shift members up in rank : 0 1 2 3 --> 1 2 3 0
        tempPawn = m_TeamLeader;
        for(i=0; i<m_iMemberCount-1;i++)
        {
            m_Team[i] = m_Team[i+1];
            m_Team[i].m_iId = i;
        } 

        m_TeamLeader = m_Team[0];
        m_Team[iLastMember] = tempPawn;
        m_Team[iLastMember].m_iId = iLastMember;

        tempPawn.ClientQuickResetPeeking();
        tempPawn.m_bIsPlayer = false;
        m_TeamLeader.m_bIsPlayer = true;

		if (tempPawn.m_bIsClimbingLadder == false)
			UpdatePlayerWeapon(tempPawn);
		else if (tempPawn.m_bActivateNightVision == true)
			tempPawn.MandatoryToggleNightVision();
        ResetWeaponReloading();		

        // switch the controllers 
        tempRainbowAI = R6RainbowAI(m_TeamLeader.controller);
        tempPlayerController = R6PlayerController(m_Team[iLastMember].controller);
        
    	tempPlayerController.ToggleHelmetCameraZoom(TRUE);      
	    tempPlayerController.CancelShake();
        tempPlayerController.ClientForceUnlockWeapon();
        tempPlayerController.m_iPlayerCAProgress = 0;
        //tempPlayerController.m_bLockWeaponActions = false;

        //Switch the Controller Rep info
        SwitchControllerRepInfo(tempRainbowAI, tempPlayerController);

		// associate Rainbow AI with its pawn
        m_Team[iLastMember].UnPossessed();        
		tempRainbowAI.Possess(m_Team[iLastMember]);

		// associate player controller with its pawn
		AssociatePlayerAndPawn(tempPlayerController, m_TeamLeader);		
	
		// reset position of head
		m_Team[iLastMember].PawnLook(rot(0,0,0),,);
        m_Team[iLastMember].ResetBoneRotation();
        m_Team[iLastMember].m_bPostureTransition = false;
    }

    // reset any bone rotation this pawn may have had with its previous controller...
    m_TeamLeader.ResetBoneRotation();
	m_TeamLeader.ClientQuickResetPeeking();
    m_TeamLeader.m_bPostureTransition = false;

	UpdateFirstPersonWeaponMemory(tempPawn, m_TeamLeader);	
	ResetRainbowControllerStates(tempPlayerController, iLastMember);

	m_iIntermLeader = 0;
	tempPlayerController.UpdatePlayerPostureAfterSwitch();
    UpdateEscortList();
	UpdateTeamGrenadeStatus();

	if ((m_iTeamAction & TEAM_OpenDoor) > 0 && m_bTeamIsHoldingPosition)
		m_iTeamAction = TEAM_None;
}

function SwitchControllerRepInfo(R6RainbowAI tempRainbowAI, R6PlayerController tempPlayerController)
{
    local R6PawnReplicationInfo aPawnRepInfo;

    //R6Pawn(tempPlayerController.Pawn).PlayWeaponSound(WSOUND_StopFireFullAuto);//Now, we call stopfire on pawn before call this function, cleaner & safer.

    aPawnRepInfo = tempRainbowAI.m_PawnRepInfo;
    tempRainbowAI.m_PawnRepInfo = tempPlayerController.m_PawnRepInfo;
    tempRainbowAI.m_PawnRepInfo.m_ControllerOwner = tempRainbowAI;
    tempPlayerController.m_PawnRepInfo = aPawnRepInfo;
    tempPlayerController.m_PawnRepInfo.m_ControllerOwner = tempPlayerController;
    tempPlayerController.m_CurrentAmbianceObject = tempRainbowAI.Pawn.Region.Zone;
}

//------------------------------------------------------------------
// AssociatePlayerAndPawn()							
//  we don't want to use Possess/Unpossess, because that would reset 
//  the physics (root motion)
//------------------------------------------------------------------
function AssociatePlayerAndPawn(R6PlayerController player, R6Rainbow pawn)
{
	player.PossessInit(pawn);
	player.SetViewTarget(pawn);
	pawn.PlayerReplicationInfo = player.PlayerReplicationInfo;
    player.bBehindView = false; // the server must have this set to false

    // Switch PRI Health
    switch(pawn.m_eHealth)
    {
        case HEALTH_Healthy:
            player.PlayerReplicationInfo.m_iHealth = 0;//ePlayerStatus_Alive;
            break;
        case HEALTH_Wounded:
            player.PlayerReplicationInfo.m_iHealth = 1;//ePlayerStatus_Wounded;
            break;
        case HEALTH_Incapacitated:
        case HEALTH_Dead:
            player.PlayerReplicationInfo.m_iHealth = 2;//ePlayerStatus_Dead;
            break;
    }
}

//------------------------------------------------------------------//
// SwapPlayerControlWithTeamMate()							
//------------------------------------------------------------------//
function SwapPlayerControlWithTeamMate(INT iMember)
{
    local   R6Rainbow           tempPawn;
    local   R6RainbowAI         tempRainbowAI;
    local   R6PlayerController  tempPlayerController;
	local   INT                 i, iPermanentRequestID;

    if(level.Game!=none && !R6AbstractGameInfo(level.Game).CanSwitchTeamMember())
        return;

    if( (iMember == 0) || !m_Team[iMember].IsAlive())
		return;

	// The leader is dead!!!
	if (!m_Team[0].IsAlive())
	{
		// PATCH15 small hack to avoid problem when leader is dead. 
		// The SwitchPlayerControlToNextMember() already manage everything
		// use PermanentID to find the good member to switch
		iPermanentRequestID = m_Team[iMember].m_iPermanentID;

		for (i = 0; i < m_iMemberCount; i++)
		{
			SwitchPlayerControlToNextMember();
			if (m_Team[0].m_iPermanentID == iPermanentRequestID)
				break;
		}

		return;
	}

	TeamIsSeparatedFromLead(false);
	
	// swap pawns
	tempPawn = m_Team[0];
	m_Team[0] = m_Team[iMember];
	m_Team[0].m_iId = 0;
	m_TeamLeader = m_Team[0];

	m_Team[iMember] = tempPawn;
	m_Team[iMember].m_iId = iMember;

	m_TeamLeader.m_bIsPlayer = true;
	m_Team[iMember].m_bIsPlayer = false;
    m_Team[iMember].ClientQuickResetPeeking();

	tempPawn = m_Team[iMember];
	if (tempPawn.m_bIsClimbingLadder == false)
		UpdatePlayerWeapon(tempPawn);
	else if (tempPawn.m_bActivateNightVision == true)
		tempPawn.ToggleNightVision();
	ResetWeaponReloading();
	
	// switch the controllers
	tempRainbowAI = R6RainbowAI(m_Team[0].controller);
    tempPlayerController = R6PlayerController(m_Team[iMember].controller);

	tempPlayerController.ToggleHelmetCameraZoom(TRUE);      
	tempPlayerController.CancelShake();
    tempPlayerController.ClientForceUnlockWeapon();
    tempPlayerController.m_iPlayerCAProgress = 0;
    //tempPlayerController.m_bLockWeaponActions = false;

    //Switch the Controller Rep info
    SwitchControllerRepInfo(tempRainbowAI, tempPlayerController);

	// associate Rainbow AI to its pawn
	m_Team[iMember].UnPossessed();
    tempRainbowAI.Possess(m_Team[iMember]);

	// associate playercontroller to its pawn ( instead of calling possess() )
	AssociatePlayerAndPawn(tempPlayerController, m_Team[0]);

	// reset position of head
	m_Team[iMember].PawnLook(rot(0,0,0),,);
    m_Team[iMember].ResetBoneRotation();
    m_Team[iMember].m_bPostureTransition = false;

    // reset any bone rotation this pawn may have had with its previous controller...
    m_TeamLeader.ResetBoneRotation();
	m_TeamLeader.ClientQuickResetPeeking();
    m_TeamLeader.m_bPostureTransition = false;

	UpdateFirstPersonWeaponMemory(tempPawn, m_TeamLeader);
	ResetRainbowControllerStates(tempPlayerController, iMember);

	m_iIntermLeader = 0;
	tempPlayerController.UpdatePlayerPostureAfterSwitch();
    
    UpdateEscortList();
	UpdateTeamGrenadeStatus();	
}

//------------------------------------------------------------------//
// UpdateTeamStatus()												//
//   called from R6TakeDamage() in R6Pawn.uc whenever a member of   //
//   the team takes damage.											//
//------------------------------------------------------------------//
function UpdateTeamStatus(R6Pawn member)
{
    local R6PlayerController _PlayerController;
    #ifdefDEBUG	if(bShowLog) log(self$" UpdateTeamStatus() : member="$member$" member.m_eHealth="$member.m_eHealth);		#endif
    if( !(Level.Game.m_szGameTypeFlag == "RGM_FreeBackupAdvMode") )
    {
        if((m_iTeamHealth[member.m_iPermanentID] == member.eHealth.HEALTH_Incapacitated)
            && (member.m_eHealth == HEALTH_Dead))
        {
            #ifdefDEBUG	if(bShowLog) log(self$" member "$member$" has gone from incapacitated to dead!!!!!!!!");		#endif
            m_iTeamHealth[member.m_iPermanentID] = member.m_eHealth;
            return;
        }
    }

    if( !member.IsAlive() )
    {
        _PlayerController = R6PlayerController(m_TeamLeader.Controller);
        if( !(Level.Game.m_szGameTypeFlag == "RGM_FreeBackupAdvMode") )
            TeamMemberDead(member);
        else
            TeamMemberDeadInFreeBackup(member);
        if ((m_iMemberCount == 0) && (m_bLeaderIsAPlayer) && (Level.NetMode!=NM_Standalone))
        {
            _PlayerController.ClientTeamIsDead();
        }
		if((m_bLeaderIsAPlayer && m_iMemberCount == 1) || (!m_bLeaderIsAPlayer && m_iMemberCount == 0))
			SetTeamState(TS_Retired);
    }
	
	// when a member is wounded, move to end of formation (if next member in formation is healthy) except if member wounded is player
	if( !member.m_bIsPlayer 
		&& m_iTeamAction != TEAM_ClimbLadder 
		&& (m_iTeamHealth[member.m_iPermanentId] == member.eHealth.HEALTH_Healthy) 
		&& (member.m_eHealth == HEALTH_Wounded))
	{
		if((m_iMemberCount > (member.m_iId+1)) && (m_Team[member.m_iId+1].m_eHealth == HEALTH_Healthy))
		{	
			if(SendMemberToEnd(member.m_iId, true))
			{
				ResetTeamMemberStates();
				if(m_bTeamIsHoldingPosition && !m_Team[0].m_bIsPlayer)
					m_Team[0].controller.GotoState('HoldPosition');
			}
		}
	}
    m_iTeamHealth[member.m_iPermanentID] = member.m_eHealth;
}

function bool RainbowAIAreStillClimbingLadder()
{
	local INT i;

	for(i=1; i<m_iMemberCount; i++)
	{
		if(m_Team[i].IsAlive() && m_Team[i].m_bIsClimbingLadder)
			return true;
	}

	return false;
}

//------------------------------------------------------------------//
// TeamMemberDead()													//
//   called when a member of the team is killed                     //
//  note: this is called even when a member is only incapacitated...//
//------------------------------------------------------------------//
function TeamMemberDead(R6Pawn deadPawn)
{
    local INT   i;
    local INT   iMemberId;
	local bool  bReIssueTeamOrder;
	local bool  bReassignNextMemberToLeadRoomEntry;
	local INT	iIdxDeadPawn;

    UpdateEscortList(); // call before removing the pawn
	UpdateTeamGrenadeStatus();

    iMemberId = deadPawn.m_iId;	
	deadPawn.controller.enemy = none;	
	#ifdefDEBUG	if(bShowLog) log(self$"  TeamMemberDead() deadPawn="$deadPawn$" iMemberId="$iMemberId);	#endif

    // promote other members of lower rank...
    if(iMemberId == 0) //leader was killed
    {
        #ifdefDEBUG	if(bShowLog) log(self$" TeamMemberDead() : the leader was killed...the new leader is="$m_Team[1]);	#endif
        m_TeamLeader = m_Team[1];
        
        if(m_bLeaderIsAPlayer)
        {
			// todo: reset some status flags
			#ifdefDEBUG	if(bShowLog) log(self$" leader of this team is a player, so wait until player changes members");		#endif
            // do not promote, wait until player takes control...
            m_iMemberCount--;
            m_iMembersLost++;
            return;
        }
    }

	//------------------------------------------------------------------//
	// check if this member was killed while leading a team order
	if(m_iTeamAction != TEAM_None) 
	{		
		if(iMemberId==1)
		{
			bReIssueTeamOrder = true;		
			if(m_PawnControllingDoor == deadPawn)
				bReassignNextMemberToLeadRoomEntry = true;
		}

		if(m_iTeamAction == TEAM_ClimbLadder)
		{
			if(iMemberId == m_iMemberCount-1)	
				TeamFinishedClimbingLadder();
		}
	}
	//------------------------------------------------------------------//
	
	// check to see if any of the member of the team is climbing a ladder
	if(!RainbowAIAreStillClimbingLadder())
		m_bTeamIsClimbingLadder = false;
	
    #ifdefDEBUG	if(bShowLog) log(self$" TeamMemberDead() : member "$deadPawn$" was killed...m_iId="$iMemberId$" m_iTeamAction="$m_iTeamAction$" bReIssueTeamOrder="$bReIssueTeamOrder);		#endif	 	
    for(i=iMemberId+1; i<(m_iMemberCount + m_iMembersLost); i++)
    {
		if(m_Team[i].IsAlive())
		{
			m_Team[i-1] = m_Team[i];
			if(m_Team[i].Controller != none)
				R6RainbowAI(m_Team[i].Controller).Promote();
		}
    }

	// move the dead/incapacitate member at the end of m_Team[]	
	if(m_bLeaderIsAPlayer && m_Team[0].m_bIsPlayer && !m_Team[0].IsAlive())
	{
		// player/leader is dead and still attached to pawn
		// member count does not include first spot (index 0), start at 1 instead
		iIdxDeadPawn = m_iMemberCount;	
	}
	else
		iIdxDeadPawn = m_iMemberCount - 1;

	m_Team[iIdxDeadPawn] = R6Rainbow(deadPawn);
	deadPawn.m_iId = iIdxDeadPawn;
	
    // if this is an AI controlled team, inform leader that a member has been lost...
    if(!m_bLeaderIsAPlayer && (m_TeamLeader != none) && (m_TeamLeader.Controller != none))
        R6RainbowAI(m_TeamLeader.Controller).m_bTeamMateHasBeenKilled = true;

#ifdefDEBUG	
	if(bShowLog)
	{
		for(i=0;i<(m_iMemberCount+m_iMembersLost);i++)
			log(" team list: i="$i$" : "$m_Team[i]$" and m_iID="$m_Team[i].m_iId);
	}
#endif
    m_iMemberCount--;
    m_iMembersLost++;

	//------------------------------------------------------------------//
	// reissue team order team order
	if(bReIssueTeamOrder && (m_iMemberCount >1))
	{
		if(m_bTeamIsClimbingLadder)
			m_Team[1].controller.nextState = 'TeamClimbEndNoLeader';
		else
			ReIssueTeamOrders();

		if(bReassignNextMemberToLeadRoomEntry)
			m_PawnControllingDoor = m_Team[1];
	}
	//------------------------------------------------------------------//
}

function TeamMemberDeadInFreeBackup(R6Pawn deadPawn)
{
    local INT i, iMemberId;

    iMemberId = deadPawn.m_iID;
    deadPawn.Controller.Enemy = none;
    if(iMemberId == 0)
    {
        m_TeamLeader = none;
        for(i=1; i<m_iMemberCount; i++)
        {
            if(m_Team[i] != none)
            {
                if(m_Team[i].Controller != none)
                {
                    m_Team[i].Controller.Enemy = none;
                    R6RainbowAI(m_Team[i].Controller).FreeBackupPromote();
                }
            }
        }
        m_iMemberCount = 0;
        return;
    }

    if(!RainbowAIAreStillClimbingLadder())
        m_bTeamIsClimbingLadder = false;

    switch(m_Team[iMemberId].m_iID)
    {
        case 1:
            if(m_Team[2] != none)
            {
                m_Team[1] = m_Team[2];
                m_Team[1].m_iID = 1;
                R6RainbowAI(m_Team[1].Controller).FreeBackupPromote();
                if(m_Team[3] != none)
                {
                    m_Team[2] = m_Team[3];
                    m_Team[2].m_iID = 2;
                    R6RainbowAI(m_Team[2].Controller).FreeBackupPromote();
                    m_Team[3] = none;
                }
                else
                    m_Team[2] = none;
            }
            break;
        case 2:
            if(m_Team[3] != none)
            {
                m_Team[2] = m_Team[3];
                m_Team[2].m_iID = 2;
                R6RainbowAI(m_Team[2].Controller).FreeBackupPromote();
                m_Team[3] = none;
            }
            break;
        case 3:
            m_Team[3] = none;
            break;
    }
    m_iMemberCount--;
    ResetNeutralFighterTeam();
}

function ResetNeutralFighterTeam()
{
    if(m_iMemberCount <= 1)
        return;

    switch(m_iMemberCount)
    {
        case 2:
            if(m_Team[1] != none && !m_Team[1].IsAlive())
            {
                m_Team[1] = none;
                m_iMemberCount = 1;
            }
            break;
        case 3:
            if(m_Team[1] != none && !m_Team[1].IsAlive())
            {
                if(m_Team[2] != none && m_Team[2].IsAlive())
                {
                    m_Team[1] = m_Team[2];
                    m_Team[1].m_iID = 1;
                    m_Team[2] = none;
                    m_iMemberCount = 2;
                }
                else
                {
                    m_Team[1] = none;
                    m_Team[2] = none;
                    m_iMemberCount = 1;
                }
            }
            else if(m_Team[2] != none && !m_Team[2].IsAlive())
            {
                m_Team[2] = none;
                m_iMemberCount = 2;
            }
            break;
        case 4:
            if(m_Team[1] != none && m_Team[1].IsAlive())
            {
                if(m_Team[2] != none && !m_Team[2].IsAlive())
                {
                    if(m_Team[3] != none && m_Team[3].IsAlive())
                    {
                        m_Team[2] = m_Team[3];
                        m_Team[2].m_iID = 2;
                        m_Team[3] = none;
                        m_iMemberCount = 3;
                    }
                    else
                    {
                        m_Team[2] = none;
                        m_Team[3] = none;
                        m_iMemberCount = 2;
                    }
                }
                else if(m_Team[3] != none && !m_Team[3].IsAlive())
                {
                    m_Team[3] = none;
                    m_iMemberCount = 3;
                }
            }
            else
            {
                if(m_Team[2] != none && !m_Team[2].IsAlive())
                {
                    if(m_Team[3] != none && m_Team[3].IsAlive())
                    {
                        m_Team[1] = m_Team[3];
                        m_Team[1].m_iID = 1;
                        m_Team[2] = none;
                        m_Team[3] = none;
                        m_iMemberCount = 2;
                    }
                    else
                    {
                        m_Team[1] = none;
                        m_Team[2] = none;
                        m_Team[3] = none;
                        m_iMemberCount = 1;
                    }
                }
                else if(m_Team[3] != none && !m_Team[3].IsAlive())
                {
                    m_Team[1] = m_Team[2];
                    m_Team[1].m_iID = 1;
                    m_Team[2] = none;
                    m_Team[3] = none;
                    m_iMemberCount = 2;
                }
            }
            break;
    }
}

//------------------------------------------------------------------//
// AtLeastOneMemberIsWounded()										//
//  used by an AI led team; AI lead should walk if any of the		//
//  members are wounded or if any of the hostages being escorted	//
//  are wounded.													//
//------------------------------------------------------------------//
function bool AtLeastOneMemberIsWounded()
{
	local INT	i;
	
	if(m_bWoundedHostage)
		return true;
	
	for(i=0; i<m_iMemberCount; i++)
	{
		if(m_Team[i].m_eHealth == HEALTH_Wounded)
			return true;
	}
	return false;
}

//------------------------------------------------------------------//
// SetFormation()													//
//   TODO : this function may have become unnecessary               //
//------------------------------------------------------------------//
function SetFormation(R6RainbowAI memberAI) 
{
#ifdefDEBUG	
    if(m_TeamLeader == none)
        if(bShowLog) log(self$" <R6RainbowTeam::SetFormation()>  TeamAI does not know who the team leader is... (m_TeamLeader == none"); 
#endif    
    memberAI.m_eFormation = m_eFormation;
}

//------------------------------------------------------------------//
// UpdateTeamFormation()											//
//   inform all the team members of the change in formation         //
//------------------------------------------------------------------//
event UpdateTeamFormation(R6RainbowAI.eFormation eFormation)
{     
    local   INT     i;
    local   INT     iStart;

    m_eFormation = eFormation;    
    if(m_bLeaderIsAPlayer)
        iStart = 1;

    for(i=iStart; i<m_iMemberCount; i++)
    {
        SetFormation(R6RainbowAI(m_Team[i].controller));
    }
}

//------------------------------------------------------------------//
// RequestFormationChange()											//
//   two requests by team members are necessary before the          //
//   current formation will be changed...                           //
//------------------------------------------------------------------//
event RequestFormationChange(R6RainbowAI.eFormation eFormation)
{     
    if(m_eRequestedFormation == eFormation)
    {        
        // this is the second request for the change in formation
        UpdateTeamFormation(eFormation);
    }
    else
    {
        m_eRequestedFormation = eFormation;
    }
}

//------------------------------------------------------------------//
// Tick()															//
//   keep this function's content to an absolute minimun since it   //
//   called so frequently...                                        //
//------------------------------------------------------------------//
function Tick(FLOAT fDelta)
{ 
    local   INT     i;

	if(!m_bTeamIsEngagingEnemy && m_eTeamState == TS_Engaging)
	{
		if(Level.TimeSeconds - m_fEngagingTimer > 1.0)
			m_eTeamState = m_eBackupTeamState;
	}

    // if m_TeamLeader is none, then there is no team. (no members)
    if(m_TeamLeader != none)
    {     
        //update the team's orientation only if the teamLeader is moving...
        if(VSize(m_TeamLeader.velocity) > 5)
        {
            // team orientation should indicate movement direction not the teamleader's orientation...
            m_rTeamDirection = rotator(m_TeamLeader.velocity);  
        }

        // update info about leader's pace (for player lead)
        if(m_bLeaderIsAPlayer)
        {
			if(Level.NetMode == NM_Standalone)
			{
				if(m_PlanActionPoint != none)
				{
					if(VSize(m_TeamLeader.location - m_PlanActionPoint.location) < 250)
					{
						#ifdefDEBUG	if(bShowLog) log(self$" reached action point : m_PlanActionPoint="$m_PlanActionPoint$" m_PlanActionPoint.location="$m_PlanActionPoint.location);		#endif
						m_PlayerLastActionPoint = m_PlanActionPoint;					
						ActionPointReached();					

						// make a backup of the Planning Action associated with this node, so that we can display this action until the player
						// moves far enough away from this Action Point.
						m_ePlayerAPAction = m_ePlanAction;
						if(m_eGoCode == GOCODE_None)
						{
							if(m_ePlanAction != PACT_None)
								ActionNodeCompleted();	
						}
						else
						{
							// Player must launch a GoCode, find out what action was planned for this action point to display in the HUD.
							m_ePlayerAPAction = m_TeamPlanning.GetAction();
						}
					}

					// when the player has moved far enough away from the CurrentActionPoint, 
					// any suggested actions associated with the CurrentActionPoint.
					if((m_ePlayerAPAction != PACT_None) && (VSize(m_TeamLeader.location - m_PlayerLastActionPoint.location) > 250))
					{
						// Player has moved far away enough from the previous ActionPoint, so we can stop displaying the previous planned action.
						m_ePlayerAPAction = PACT_None;
					}
				}
				else
				{
					if(m_eGoCode == GOCODE_None)
					{
						// rbrek todo : maybe this should be checked less frequently.... 
						GetNextActionPoint();					
						if(m_PlanActionPoint != none)
						{
							// GoCode was received and player now has the next ActionPoint in the planning.  log("  GOCODE WAS RECEIVED : New Action Point ="$m_PlanActionPoint);
							m_ePlayerAPAction = m_ePlanAction;
							ActionNodeCompleted();
						}
					}
				}
			}

            if(m_TeamLeader.m_bIsProne) // before bIsCrouched
                m_TeamLeader.m_eMovementPace = PACE_Prone;
            else if(m_TeamLeader.bIsCrouched)
            {
                if(m_TeamLeader.bIsWalking)
                    m_TeamLeader.m_eMovementPace = PACE_CrouchWalk;
                else
                    m_TeamLeader.m_eMovementPace = PACE_CrouchRun;
            }
            else
            {
                if(m_TeamLeader.bIsWalking)
                    m_TeamLeader.m_eMovementPace = PACE_Walk;
                else
                    m_TeamLeader.m_eMovementPace = PACE_Run;
            }       
        }
		else
			m_ePlayerAPAction = m_ePlanAction;
    } 
}

//------------------------------------------------------------------//
//  PickMemberClosestTo()											//
//------------------------------------------------------------------//
function INT PickMemberClosestTo(actor aNoiseSource)
{
	local	INT		i;
	local	INT		iMemberClosest;
	local	INT		fDist, fClosestDist;

	iMemberClosest = -1;
	fClosestDist = 10000f;	
	
	// if there is only one member, return
	if(m_iMemberCount == 1)
	{
		if(m_bLeaderIsAPlayer)
			return iMemberClosest;
		else
			return 0;
	}

	for(i=1; i<m_iMemberCount; i++)
	{
		if(m_Team[i].m_bIsPlayer)
			continue;
		
		fDist = VSize(m_Team[i].location - aNoiseSource.location);
		if(fDist < fClosestDist)
		{
			iMemberClosest = i;
			fClosestDist = fDist;
		}
	}

	#ifdefDEBUG	if(bShowLog) log(self$" PickMemberClosestTo() aNoiseSource="$aNoiseSource$" closest member is = "$iMemberClosest);	#endif
	return iMemberClosest;	
}

//------------------------------------------------------------------//
// TeamHearNoise()													//
//------------------------------------------------------------------//
function TeamHearNoise(Actor aNoiseMaker)
{
	local INT	iMember;

	#ifdefDEBUG	if(bShowLog) log(self$"  TeamHearNoise() : aNoiseMaker.location="$aNoiseMaker.location$" m_vNoiseSource="$m_vNoiseSource);	#endif

	m_vNoiseSource = aNoiseMaker.location;	
	if(m_bLeaderIsAPlayer)
	{
		// player led team will not stop to react to sounds, 
		// one member will set his focus to the source of the noise instead
		// pick member who is closest to the source of the noise
		if(m_iMemberCount == 1)
			return;
	}
	else
	{
		// team never stops to react to sound
		if(m_iMemberCount == 1)
		{
			#ifdefDEBUG	if(bShowLog) log(self$"  member count == 1....  m_Team[0].controller state="$m_Team[0].controller.GetStateName());	#endif
			// if there is only one member in the team and this member is sniping
			if(m_Team[0].controller.IsInState('SnipeUntilGoCode')) 
			{
				#ifdefDEBUG	if(bShowLog) log(self$" only one member in team and they are sniping.... call SetNoiseFocus()");		#endif
				// sniper should stop sniping and get up to look around...
				R6RainbowAI(m_Team[0].controller).SetNoiseFocus(m_vNoiseSource);
				return;
			}
		}
	}	
	
	iMember = PickMemberClosestTo(aNoiseMaker);		
	if(iMember < 0)
		return;
	R6RainbowAI(m_Team[iMember].controller).SetNoiseFocus(m_vNoiseSource);
	#ifdefDEBUG	if(bShowLog) log(self$"  TeamHearNoise() :  Member="$iMember$" will investigate noise...");	#endif
}

//------------------------------------------------------------------//
//  TeamSpottedSurrenderedTerrorist()								//
//------------------------------------------------------------------//
function TeamSpottedSurrenderedTerrorist(R6Pawn terrorist)
{
	if(m_TeamLeader.m_bIsPlayer)
		return;

	if(!R6Terrorist(terrorist).m_bIsUnderArrest)
		m_SurrenderedTerrorist = terrorist;
}

//------------------------------------------------------------------//
//  RainbowIsEngaging()								
//------------------------------------------------------------------//
function bool RainbowIsEngaging()
{
	local INT i;
	
	for(i=1; i<m_iMemberCount; i++)
	{
		if(m_Team[i].controller.enemy != none)
			return true;
	}
	return false;
}

//------------------------------------------------------------------//
//  EngageEnemyIfNotAlreadyEngaged()								//
//------------------------------------------------------------------//
function bool EngageEnemyIfNotAlreadyEngaged(R6Pawn rainbow, R6Pawn enemy)
{
    local bool  bFound;
    local INT   i;

	if(enemy == none || m_iMemberCount == 0)
		return false;

    for(i=0; i<m_iMemberCount; i++)
    {
		if(m_Team[i].m_bIsPlayer || m_Team[i] == rainbow)
			continue;

        if(R6RainbowAI(m_Team[i].controller).enemy == enemy)
			return false;	// enemy is already engaged by another rainbow
    }

    if ((m_TeamLeader.m_bIsPlayer || m_bPlayerHasFocus ) && !R6Terrorist(enemy).m_bEnteringView)
    {
		R6Terrorist(enemy).m_bEnteringView = true;
		if ((m_Team[m_iMemberCount-1] == rainbow) && (R6RainbowAI(rainbow.controller).m_bIsMovingBackwards))
            m_MemberVoicesMgr.PlayRainbowMemberVoices(rainbow, RMV_ContactRearAndEngages);
        else
            m_MemberVoicesMgr.PlayRainbowMemberVoices(rainbow, RMV_ContactAndEngages);
    }

    return true;
}

//------------------------------------------------------------------//
//  DisEngaged()													//
//------------------------------------------------------------------//
function DisEngageEnemy(Pawn rainbow, Pawn enemy)
{
	CheckTeamEngagingStatus(rainbow);
}

function RainbowIsEngagingEnemy()
{
	m_bTeamIsEngagingEnemy = true;
	if(m_eTeamState != TS_Engaging)
	{
		m_eBackupTeamState = m_eTeamState;
		SetTeamState(TS_Engaging);	
	}
}

function CheckTeamEngagingStatus(optional Pawn rainbowToIgnore)
{
	local bool	bRainbowAreStillEngaging;
	local INT	i;
	
	// check if there are any rainbow left still engaging
	for(i=0; i<m_iMemberCount; i++)
	{
		if(m_Team[i].m_bIsPlayer || m_Team[i] == rainbowToIgnore)
			continue;

		if(m_Team[i].controller.enemy != none && !(m_Team[i].m_bIsSniping && m_bSniperHold))
		{
			m_bTeamIsEngagingEnemy = true;
			return;
		}
	}

	if(m_bTeamIsEngagingEnemy)
	{
		m_bTeamIsEngagingEnemy = false;
		m_fEngagingTimer = Level.TimeSeconds;
	}
}

//------------------------------------------------------------------//
//  AITeamHoldPosition()											//
//------------------------------------------------------------------//
function AITeamHoldPosition()
{
	local INT	iMember;

    if (m_bPlayerHasFocus || m_bPlayerInGhostMode)
        m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_AllTeamsHold);

    if((m_bLeaderIsAPlayer) || (m_iMemberCount == 0) || m_bTeamIsClimbingLadder)
        return;

	// reset any Zulu Gocode that was previously issued
	if(m_bCAWaitingForZuluGoCode)
		ResetZuluGoCode();

    m_bTeamIsHoldingPosition = true;	

	if(m_TeamLeader.m_bIsSniping || m_TeamLeader.controller.IsInState('PlaceBreachingCharge') || m_TeamLeader.controller.IsInState('DetonateBreachingCharge'))
		return;

	for(iMember=0; iMember<m_iMemberCount; iMember++)
    {
		m_Team[iMember].controller.nextState = '';
		m_Team[iMember].controller.GotoState('HoldPosition');        
	}
}

//------------------------------------------------------------------//
//  AITeamFollowPlanning()											//
//------------------------------------------------------------------//
function AITeamFollowPlanning()
{
	local INT	iMember;

    if (m_bPlayerHasFocus || m_bPlayerInGhostMode)
        m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, RPV_AllTeamsMove);

    if((m_bLeaderIsAPlayer) || (m_iMemberCount == 0) || m_bTeamIsClimbingLadder)
        return;

	m_bTeamIsHoldingPosition = false;

	if(m_TeamLeader.m_bIsSniping || m_TeamLeader.controller.IsInState('PlaceBreachingCharge') || m_TeamLeader.controller.IsInState('DetonateBreachingCharge'))
		return;
    
	m_TeamLeader.controller.GotoState('Patrol');
	for(iMember=1; iMember<m_iMemberCount; iMember++)
	{
		m_Team[iMember].controller.GotoState('FollowLeader');
		R6RainbowAI(m_Team[iMember].controller).ResetStateProgress();
	}
}

//------------------------------------------------------------------//
//  SendMemberToEnd()												//
//------------------------------------------------------------------//
function bool SendMemberToEnd(INT iMember, optional bool bReorganizeWounded)
{
	local	INT			i;
	local	R6Rainbow	rainbow;
	local   R6RainbowAI rainbowAI;

	#ifdefDEBUG if(bShowLog) log(self$" SendMemberToEnd() iMember="$iMember$" m_iTeamAction="$m_iTeamAction$" m_iTeamAction="$m_iTeamAction);	#endif

	rainbow = m_Team[iMember];
	rainbowAI = R6RainbowAI(rainbow.controller);

	// do not send member to end if they are in the middle of performing an action
	if(bReorganizeWounded)
	{
		if( ( m_iTeamAction != TEAM_None 
				|| m_bTeamIsClimbingLadder 
				|| rainbow.m_bIsSniping 
				|| rainbow.m_bInteractingWithDevice 
				|| m_bEntryInProgress 
				|| m_eTeamState == TS_Engaging)
			&& rainbow.m_eHealth == HEALTH_Wounded )
		{
			rainbowAI.m_bReorganizationPending = true;
			return false;
		}
		else
			rainbowAI.m_bReorganizationPending = false;
	}

	// move member to end of formation, and move up other members	
	for(i=iMember; i<m_iMemberCount-1; i++)
	{
		m_Team[i] = m_Team[i+1];
		m_Team[i].m_iId = i;
	}
	m_Team[i] = rainbow;
	m_Team[i].m_iId = i;

	return true;
}

//------------------------------------------------------------------//
//  AssignNewTeamLeader()			
//------------------------------------------------------------------//
function AssignNewTeamLeader(INT iNewLeader)
{
	ReOrganizeTeam(iNewLeader);
	m_iIntermLeader = 0;
}

//------------------------------------------------------------------//
//  ReOrganizeTeam()												//
//------------------------------------------------------------------//
function ReOrganizeTeam(INT iNewLeader)
{
	local	INT			i;

	// if there is only one member, there is nothing to reorganize 
	if(m_iMemberCount == 1)
		return;

	if(m_bLeaderIsAPlayer)
	{
		if(m_iMemberCount == 2)
			return;

		for(i=1; i<iNewLeader; i++)
			SendMemberToEnd(1);
	}
	else
	{	
		if(m_iMemberCount == 1)
			return;
		
		for(i=0; i<iNewLeader; i++)
			SendMemberToEnd(0);

		ResetTeamMemberStates();
	}
	m_iIntermLeader = iNewLeader;
	Escort_ManageList();
}

//------------------------------------------------------------------
//  ResetTeamMemberStates()												
//------------------------------------------------------------------
function ResetTeamMemberStates()
{
	local INT i;

	if(m_bLeaderIsAPlayer)
		return;

	m_TeamLeader = m_Team[0];
	if(m_TeamLeader == none)
		return;
	
	for(i=0; i<m_iMemberCount; i++)
	{
		if(i == 0)
		{
			R6RainbowAI(m_Team[0].controller).m_TeamLeader = none;
			//	if(!m_Team[i].controller.IsInState('Patrol'))
				m_Team[i].controller.GotoState('Patrol');
		}
		else
		{
			R6RainbowAI(m_Team[i].controller).m_TeamLeader = m_TeamLeader;
			m_Team[i].controller.GotoState('FollowLeader');
		}
	}
}

//------------------------------------------------------------------
//  RestoreTeamOrder()												
//------------------------------------------------------------------
function RestoreTeamOrder()
{
	local	INT			i;

	if(m_bCAWaitingForZuluGoCode)
		return;

	if(m_iIntermLeader == 0)
		return;

	if(m_bLeaderIsAPlayer)
	{
		if((m_iMemberCount == 2) || (m_iIntermLeader == 1))
			return;

		for(i=1; i<=(m_iMemberCount - m_iIntermLeader); i++)
			SendMemberToEnd(1);		
	}
	else
	{
		// if there is only one member, there is nothing to reorganize 
		if(m_iMemberCount == 1)
			return;

		for(i=0; i<(m_iMemberCount - m_iIntermLeader); i++)
			SendMemberToEnd(0);

		ReOrganizeWoundedMembers();
		ResetTeamMemberStates();
	}
	m_iIntermLeader = 0;

	// update list of escorted hostage
    Escort_ManageList();
}

function ReOrganizeWoundedMembers()
{
	local INT i;
	local bool  bReOrganized;

	// move any injured members to the end
	for(i=0; i<m_iMemberCount; i++)
	{
		if(m_Team[i].m_bIsPlayer)
			continue;

		if((i < m_iMemberCount-1) && m_Team[i].m_eHealth == HEALTH_Wounded && m_Team[i+1].m_eHealth == HEALTH_Healthy)
		{
			if(SendMemberToEnd(i, true))
				bReOrganized = true;
		}
		else
			R6RainbowAI(m_Team[i].controller).m_bReorganizationPending = false;
	}

	// if at least one member was reorganized, reset the controller states
	if(bReOrganized)
		ResetTeamMemberStates();
}

//------------------------------------------------------------------//
// FindRainbowWithBreachingCharge()									//
//------------------------------------------------------------------//
function R6Rainbow FindRainbowWithBreachingCharge()
{
	local INT				iMember;
	local INT				iWeaponGroup;
	local R6AbstractWeapon	demolitionsWeapon;
	
	// for each team member
	for( iMember = 0; iMember < m_iMemberCount; iMember++ )
	{
        if(m_Team[iMember].m_bIsPlayer)
            continue;

		if(HasBreachingCharge(m_Team[iMember]))
			return m_Team[iMember];
	}   	
	return none;
}

//------------------------------------------------------------------//
//  HasBreachingCharge												//
//------------------------------------------------------------------//
function bool HasBreachingCharge(R6Rainbow rainbow)
{
	local INT				iWeaponGroup;
	local R6EngineWeapon    demolitionsWeapon;
	
	// check both gadget groups
	for( iWeaponGroup = 3; iWeaponGroup <= 4; iWeaponGroup++ )
	{
		demolitionsWeapon = rainbow.GetWeaponInGroup(iWeaponGroup);
		if((demolitionsWeapon != none) 
			&& demolitionsWeapon.IsA('R6BreachingChargeGadget') && demolitionsWeapon.HasAmmo())
		{
			// this rainbow has a breaching charge				
			R6RainbowAI(rainbow.controller).m_iActionUseGadgetGroup = iWeaponGroup;
			return true;
		}
	}

	return false;
}

//------------------------------------------------------------------//
//  ReOrganizeTeamForBreachDoor										//
//   for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForBreachDoor()
{
    local   R6Rainbow   actionMember;
	local	INT			i;
	
	#ifdefDEBUG	if(bShowLog) log(self$" ReOrganizeTeamForBreachDoor() was called...m_BreachingDoor="$m_BreachingDoor$" m_eGoCode="$m_eGoCode);	#endif	
	m_BreachingDoor = R6IORotatingDoor(m_TeamPlanning.GetNextDoorToBreach(m_PlanActionPoint));

	// if team lead has a breaching charge, no changes are required, exit now...
	// or if the door is already open or is already destroyed, do not reorganize
	if(HasBreachingCharge(m_Team[0]) || !m_BreachingDoor.ShouldBeBreached())
		return;

	#ifdefDEBUG	if(bShowLog) log(self$" team lead did not have a breaching charge so reorganize team... ");	#endif
	// reorganize team only if necessary... (if lead has no breaching charge)
	actionMember = FindRainbowWithBreachingCharge();	
	if(actionMember == none)
	{
		#ifdefDEBUG	if(bShowLog) log(self$" no one in team has a breaching charge, continue...");	#endif
		return;
	}
	#ifdefDEBUG	if(bShowLog) log(self$" - "$actionMember$" was chosen to breach the door, reorganize!");	#endif
	
	ReOrganizeTeam(actionMember.m_iId);
}

//------------------------------------------------------------------//
//  PlaceBreachCharge()												//
//------------------------------------------------------------------//
function PlaceBreachCharge()
{
    #ifdefDEBUG	if(bShowLog) log(self$" Instruct team to place breaching change on door : "$m_BreachingDoor);		#endif
	if(m_bLeaderIsAPlayer)
		return;

	if(m_BreachingDoor == none)
	{
		#ifdefDEBUG	if(bShowLog) log(self$" m_BreachingDoor is invalid!... cannot perform place breach charge...");	#endif
		ActionNodeCompleted();
		return;
	}

	// double check!!!
	if(m_BreachingDoor.ShouldBeBreached() && !HasBreachingCharge(m_Team[0]))
		ReOrganizeTeamForBreachDoor();

	if(!HasBreachingCharge(m_Team[0]) || !m_BreachingDoor.ShouldBeBreached())
	{
		#ifdefDEBUG	if(bShowLog) log(self$"  m_eGoCode="$m_eGoCode$" CAN DO NOTHING, NO ONE HAS BREACH - Play voice/sound? ");	#endif
		if(m_eGoCode == GOCODE_None)
			ActionNodeCompleted();
		else
			m_bSkipAction = true;
		m_BreachingDoor = none;	
	}
	else
	{
		R6RainbowAI(m_Team[0].controller).ResetStateProgress();
		m_Team[0].controller.GotoState('PlaceBreachingCharge');
	}
}

//------------------------------------------------------------------//
//  BreachDoor														//	
//------------------------------------------------------------------//
function BreachDoor()
{
    #ifdefDEBUG	if(bShowLog) log(self$" BreachDoor() was called... BOOM no more door!");		#endif
	if(m_bLeaderIsAPlayer)
		ResetTeamGoCode();
	else if(m_bSkipAction)
		ActionNodeCompleted();
	else
		R6RainbowAI(m_Team[0].controller).DetonateBreach();
}

//------------------------------------------------------------------
//  SetTeamGoCode()
//    set Alpha, Bravo, or Charlie gocodes
//------------------------------------------------------------------
function SetTeamGoCode(eGoCode eCode)
{
	if(m_bCAWaitingForZuluGoCode)
		m_eBackupGoCode = eCode;
	else
	{
		m_eBackupGoCode = GOCODE_None;
		m_eGoCode = eCode;
	}
}

//------------------------------------------------------------------
//  ResetTeamGoCode()
//    called when Alpha, Bravo, or Charlie gocodes are received
//------------------------------------------------------------------
function ResetTeamGoCode()
{
	if(m_bCAWaitingForZuluGoCode)
		return;

	m_eGoCode = GOCODE_None;
	m_eBackupGoCode = GOCODE_None;
}

//------------------------------------------------------------------
//  ResetZuluGoCode()
//------------------------------------------------------------------
function ResetZuluGoCode()
{
	if(!m_bCAWaitingForZuluGoCode)
		return;

	#ifdefDEBUG	if(bShowLog) log(self$" ResetZuluGoCode() .... m_eBackupGoCode="$m_eBackupGoCode); 	#endif
	m_bCAWaitingForZuluGoCode = false;	
	m_eGoCode = m_eBackupGoCode;
	m_eBackupGoCode = GOCODE_None;
}

//------------------------------------------------------------------//
//  ReOrganizeTeamForSniping										//
//    for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForSniping()
{
    local   R6Rainbow   actionMember;
	local	INT			i;
	local	INT			iBestSniper;
	local	FLOAT		fBestRange;
	local	FLOAT		fCurrentRange;
	
	// check if team has already been reorganized for sniping...
	if(m_bSniperReady)
		return;

	#ifdefDEBUG	if(bShowLog) log(self$" ReOrganizeTeamForSniping() was called...");	#endif
	// choose which member of the team will snipe 
	// (find the member with a sniper rifle as their primary weapon and the highest sniper skill)	
	iBestSniper = -1;
	for(i=0; i<m_iMemberCount; i++)
	{
		if(m_Team[i].m_WeaponsCarried[0].m_eWeaponType == WT_Sniper)
		{
			if(iBestSniper == -1)
				iBestSniper = i;
			else // pick the better sniper of the two
			{
				if(m_Team[i].GetSkill(SKILL_Sniper) > m_Team[iBestSniper].GetSkill(SKILL_Sniper))
					iBestSniper = i;
			}
		}
	}	

	// if no one in the team is equipped with a sniper rifle, choose the 
	// member equipped with the weapon with the longest range
	if(iBestSniper == -1)
	{
		iBestSniper = 0;
		fBestRange = m_Team[0].m_WeaponsCarried[0].GetWeaponRange();
		for(i=0; i<m_iMemberCount; i++)
		{
			fCurrentRange = m_Team[i].m_WeaponsCarried[0].GetWeaponRange();
			if(fCurrentRange > fBestRange)
			{
				iBestSniper = i;
				fBestRange = fCurrentRange;
			}
		}
	}

	// change team order to place sniper in front
	if(iBestSniper != 0)
		ReOrganizeTeam(iBestSniper);

	m_bSniperReady = true;
	#ifdefDEBUG	if(bShowLog) log(self$"  SnipeUntilGoCode() : bestSniper="$iBestSniper$" (now new temp leader) pawn="$m_Team[iBestSniper]$" fBestRange="$fBestRange);	#endif
}

//------------------------------------------------------------------//
//  SnipeUntilGoCode()												//
//   AI led team only; this function should be called when AI lead  //
//   is close enough to the sniping location; it may be necessary 	//
//   to temporarily reorganise the order of the team members.		//
//------------------------------------------------------------------//
function SnipeUntilGoCode() 
{
	local	INT			i;
	local	vector		vLocation;
	local	rotator		rRotation;

    if(m_bLeaderIsAPlayer)
        return;

	if(m_bTeamIsClimbingLadder)
	{
		m_bPendingSnipeUntilGoCode = true;
		return;
	}

	m_bPendingSnipeUntilGoCode = false;
	m_TeamPlanning.GetSnipingCoordinates(vLocation, rRotation);
	#ifdefDEBUG	if(bShowLog) log(self$" SnipeUntilGoCode() was called...vLocation="$vLocation$" rRotation="$rRotation);	#endif

	// set state for sniper who now is temporary leader
	SetTeamState(TS_Sniping);
	R6RainbowAI(m_Team[0].controller).m_ActionTarget = m_LastActionPoint; 
	m_rSnipingDir = rRotation;
	m_Team[0].controller.GotoState('SnipeUntilGoCode');
	
	if(m_bCAWaitingForZuluGoCode)
		SetTeamState(TS_Waiting);
	else
	{
		for(i=1; i<m_iMemberCount; i++)
			m_Team[i].controller.GotoState('FollowLeader');
	}
}

//------------------------------------------------------------------//
//  TeamSnipingOver()												//
//    can be called from team manager when go code is received		//
//------------------------------------------------------------------//
function TeamSnipingOver()
{
	local INT	i;

	if(m_bLeaderIsAPlayer)
    {
		ResetTeamGoCode();
		return;
	}

	#ifdefDEBUG if(bShowLog) log(self$" teamSnipingOver() was called...");	#endif
	// reorganize team based on their original order
	RestoreTeamOrder();

	// set the appropriate new AI states for each member
	if(m_bTeamIsHoldingPosition)
		m_Team[0].controller.GotoState('HoldPosition');
	else
		m_Team[0].controller.GotoState('Patrol');
		
	for(i=1; i<m_iMemberCount; i++)
		m_Team[i].controller.GotoState('FollowLeader');

	ActionNodeCompleted();
}

//------------------------------------------------------------------//
//  NotifyActionPoint()												//
//------------------------------------------------------------------//
function TeamNotifyActionPoint(ENodeNotify eMsg, EGoCode eCode)
{
    switch(eMsg) 
    {
        case NODEMSG_NewAction:            
            m_ePlanAction = m_TeamPlanning.GetAction();
            m_vPlanActionLocation = m_TeamPlanning.GetActionLocation();
			ResetTeamGoCode();
			#ifdefDEBUG	if(bPlanningLog) log(" Team  : NODEMSG_NewAction received : m_ePlanAction="$m_ePlanAction);		#endif
			if(m_ePlanAction == PACT_Breach)
			{				
				m_BreachingDoor = R6IORotatingDoor(m_TeamPlanning.GetDoorToBreach());			
				PlaceBreachCharge();
			}
            return;
    
        case NODEMSG_NewMode:       
            m_eMovementMode = m_TeamPlanning.GetMovementMode();
            #ifdefDEBUG	if(bPlanningLog) log(" Team  : NODEMSG_NewMode received : m_eMovementMode="$m_eMovementMode);	#endif
            return;
    
        case NODEMSG_NewSpeed:        
			m_eMovementSpeed = m_TeamPlanning.GetMovementSpeed();
            #ifdefDEBUG	if(bPlanningLog) log(" Team  : NODEMSG_NewSpeed received : m_eMovementSpeed="$m_eMovementSpeed);	#endif
            return;
    
        case NODEMSG_NewNode:
            ResetTeamGoCode();
			GetNextActionPoint();
            #ifdefDEBUG	if(bPlanningLog) log(" Team  : NODEMSG_NewNode received : m_PlanActionPoint="$m_PlanActionPoint$" m_TeamPlanning="$m_TeamPlanning);	#endif
            return;

        case NODEMSG_WaitingGoCode:  
			SetTeamGoCode(eCode);
			PlayWaitingGoCode(m_eGoCode);
            #ifdefDEBUG	if(bPlanningLog) log(" Team  : NODEMSG_WaitingGoCode received...eCode="$eCode);		#endif
            return;

        case NODEMSG_SnipeUntilGoCode:
            #ifdefDEBUG	if(bPlanningLog) log(" Team  : NODEMSG_SnipeUntilGoCode received...");	#endif            			
			SetTeamGoCode(eCode);
			m_ePlanAction = PACT_SnipeGoCode;    
			SnipeUntilGoCode();
            return;

        case NODEMSG_BreachDoorAtGoCode:
            SetTeamGoCode(eCode);
			m_ePlanAction = PACT_Breach;
			m_BreachingDoor = R6IORotatingDoor(m_TeamPlanning.GetDoorToBreach());			
            #ifdefDEBUG	if(bPlanningLog) log(" Team  : NODEMSG_BreachDoorAtGoCode received...m_BreachingDoor="$m_BreachingDoor$" eCode="$eCode);	#endif
			PlaceBreachCharge();
            return;

        // do nothing...
        case NODEMSG_GoCodeLaunched:
            #ifdefDEBUG	if(bPlanningLog) log(" Team  : NODEMSG_GoCodeLaunched received...");	#endif
			GetNextActionPoint();  
			return;

        case NODEMSG_ActionNodeCompleted:        
            return;
    }
}

function PlayWaitingGoCode(EGoCode eCode, optional BOOL bSnipeUntilGoCode)
{
	if(m_OtherTeamVoicesMgr == none)
		return;

    if (!m_bLeaderIsAPlayer)
    {
        switch(eCode)
        {
            case GOCODE_Alpha:
                if (bSnipeUntilGoCode)
                    m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusSniperUntilAlpha);
                else
                    m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_WaitAlpha);
                break;
            case GOCODE_Bravo:
                if (bSnipeUntilGoCode)
                    m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusSniperUntilBravo);
                else
                    m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_WaitBravo);
                break;
            case GOCODE_Charlie:
                if (bSnipeUntilGoCode)
                    m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_StatusSniperUntilCharlie);
                else
                    m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_WaitCharlie);
                break;
            case GOCODE_Zulu:
                m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, ROTV_WaitZulu);
                break;
        }
    }
}


//------------------------------------------------------------------//
//  GetFirstActionPoint()											//
//------------------------------------------------------------------//
function GetFirstActionPoint()
{
    m_PlanActionPoint = m_TeamPlanning.GetFirstActionPoint();
	m_LastActionPoint = m_PlanActionPoint;
    #ifdefDEBUG	if(bPlanningLog) log(" Team Get first action point!!! m_PlanActionPoint="$m_PlanActionPoint);	#endif

    //check if the first action point is a gocode?
    TeamNotifyActionPoint(NODEMSG_NewSpeed, GOCODE_None);
    TeamNotifyActionPoint(NODEMSG_NewMode, GOCODE_None);
}

//------------------------------------------------------------------//
//  GetNextActionPoint()											//
//------------------------------------------------------------------//
function GetNextActionPoint()
{
	m_PlanActionPoint = m_TeamPlanning.GetNextActionPoint();	
	if(m_PlanActionPoint != none)
	{
		m_eNextAPAction = m_TeamPlanning.NextActionPointHasAction(m_PlanActionPoint);
		
		// may need to know in advance which door we will be breaching (in order to check if it is already open/destroyed)
		if(m_BreachingDoor == none)
			m_BreachingDoor = R6IORotatingDoor(m_TeamPlanning.GetNextDoorToBreach(m_PlanActionPoint));
	}			
	m_LastActionPoint = m_PlanActionPoint;	
}

//------------------------------------------------------------------//
//  PreviewNextActionPoint()										//
//------------------------------------------------------------------//
function actor PreviewNextActionPoint()
{
	return m_TeamPlanning.PreviewNextActionPoint();
}

//------------------------------------------------------------------//
//  ActionPointReached()											//
//------------------------------------------------------------------//
function ActionPointReached()
{
    #ifdefDEBUG	if(bPlanningLog) log(" Team ActionPointReached() : "$m_PlanActionPoint$" call NotifyActionPoint(NODEMSG_NodeReached)");		#endif
    m_PlanActionPoint = none;  
    m_TeamPlanning.NotifyActionPoint(NODEMSG_NodeReached,GOCODE_None);
}

//------------------------------------------------------------------//
//  ActionNodeCompleted()								            //
//------------------------------------------------------------------//
function ActionNodeCompleted()
{
    #ifdefDEBUG	if(bPlanningLog) log(" Team ActionCompleted() : "$m_ePlanAction$" call NotifyActionPoint(NODEMSG_ActionNodeCompleted) m_eGoCode="$m_eGoCode);	#endif
	m_ePlanAction = PACT_None;
	m_bSkipAction = false;
    m_TeamPlanning.NotifyActionPoint(NODEMSG_ActionNodeCompleted,GOCODE_None);

	// reset necessary flags
	m_bSniperReady = false;
}

//------------------------------------------------------------------//
//  PlayerHasAbandonedTeam()										//
//------------------------------------------------------------------//
function PlayerHasAbandonedTeam()
{
	local R6Rainbow		tempPawn;
	local INT			iLastMember, i;

    #ifdefDEBUG	if(bPlanningLog) log(" Team PlayerHasAbandonedTeam() : call NotifyActionPoint(NODEMSG_PlayerLeft) m_TeamLeader="$m_TeamLeader);		#endif
    m_TeamPlanning.NotifyActionPoint(NODEMSG_PlayerLeft,GOCODE_None);
	
	if(m_Team[0].m_bIsPlayer && !m_Team[0].IsAlive())
	{
		m_Team[0].UnPossessed();
	    iLastMember = m_iMemberCount-1;
		// player died and left team, so reorganize
		tempPawn = m_Team[0];  		
        for(i=0; i<m_iMemberCount;i++)
        { 
            m_Team[i] = m_Team[i+1];
            m_Team[i].m_iId = i;
			m_Team[i].m_bIsPlayer = false;
        }         
        m_TeamLeader = m_Team[0];
        m_Team[iLastMember+1] = tempPawn;
		tempPawn.m_bIsPlayer = false;
        m_Team[iLastMember+1].m_iId = iLastMember+1;
		m_TeamLeader.controller.GotoState('Patrol');	
	}

	if(m_iTeamAction == TEAM_None)
	{
		// reset team members AI state
		for(i=1; i<m_iMemberCount; i++)
			m_Team[i].controller.GotoState('FollowLeader');
		TeamIsSeparatedFromLead(false);
	}
}

//------------------------------------------------------------------
// Escort_GetLastRainbow: return the last rainbow that
//  will be at the end of the list of escorted hostage
//------------------------------------------------------------------
function R6Rainbow Escort_GetLastRainbow()
{
    local int i;
    
    if ( m_iMemberCount > 0 )
    {
        i = m_iMemberCount - 1;
        while ( i >= 0 && m_Team[i] != none  )
        {
            if ( m_Team[i].isAlive() )
                return m_Team[i];
            --i;
        }    
    }

    return none;
}

//------------------------------------------------------------------
// Escort_UpdateTeamSpeed: check if a escorted hostage is wounded
//	
//------------------------------------------------------------------
function Escort_UpdateTeamSpeed()
{
    local INT i;
    local INT iRainbow;
    local R6Rainbow r;
    
    m_bWoundedHostage = false;

    for ( iRainbow = 0; iRainbow < m_iMemberCount; iRainbow++ )
    {
        r = m_Team[iRainbow];

        while ( r != none && i < ArrayCount(r.m_aEscortedHostage) && r.m_aEscortedHostage[i] != none ) 
        {
            if ( r.m_aEscortedHostage[i].m_eHealth == HEALTH_Wounded )
            {
                m_bWoundedHostage = true;
                break;
            }
            ++i;
        }
    }
}

//------------------------------------------------------------------
// UpdateEscortList: update directly who's following who and set team
//  formation info
//------------------------------------------------------------------
function UpdateEscortList()
{
    local INT   i;
    
    if ( m_Team[0] == none ) // on a reset, it avoid to get an accessed none
        return;

	for(i=0; i<m_iMemberCount; i++)
    {
        m_Team[i].Escort_UpdateList();
    }
}


// A SERVER SIDE FUNCTION
function SetTeamColor(int iTeamNum)
{
    if ((iTeamNum<0)|| (iTeamNum>2))
        iTeamNum = 0;

    m_TeamColour=Colors.TeamHUDColor[iTeamNum];
}

simulated function Color GetTeamColor()
{
    if (Level.NetMode == NM_Standalone)
    {
        SetTeamColor(m_iRainbowTeamName);
    }
    return m_TeamColour;
}


//------------------------------------------------------------------
// SetMemberTeamID: set the team ID used for the friendship system.
//	in single player, by default it's c_iTeamNumAlpha.
//------------------------------------------------------------------
function SetMemberTeamID( int iTeamID )
{
    local int i;

    #ifdefDEBUG	if(bShowLog) log(self$" RainbowTeam SetMemberTeamID of " $self$ " iTeamID=" $iTeamID );	#endif

    for(i=0; i<m_iMemberCount; i++)
    {
        m_Team[i].m_iTeam = iTeamID;
        
        if ( m_Team[i].PlayerReplicationInfo != none )
        {
            m_Team[i].PlayerReplicationInfo.TeamID = iTeamID;
        }
        
        R6AbstractGameInfo(level.game).SetPawnTeamFriendlies( m_Team[i] );
    }
}

simulated function ResetTeam()
{
    local INT i;

    for(i=0; i<c_iMaxTeam; i++)
        m_Team[i] = none;

    m_TeamLeader = none;
}

simulated function FirstPassReset()
{
    ResetTeam();
}


//------------------------------------------------------------------
// Escort_ManageList
//	
//------------------------------------------------------------------
function Escort_ManageList()
{
    local INT i,iHostage;
    local R6Rainbow lastRainbow;
    local R6Hostage hostage;

    // update only if not separated from the team
    if ( m_bTeamIsSeparatedFromLeader )
        return;

    lastRainbow = Escort_GetLastRainbow();
    if ( lastRainbow == none )
        return;
   
    for( i = 0; i < m_iMemberCount; i++)
    {
        if ( lastRainbow == m_Team[i] )
            continue;

        // there's at least one hostage
        if ( m_Team[i].m_aEscortedHostage[0] != none )
        {
            iHostage = 0;
            while ( iHostage < ArrayCount( m_Team[i].m_aEscortedHostage ) && m_Team[i].m_aEscortedHostage[iHostage] != none )
            {
                hostage = m_Team[i].m_aEscortedHostage[iHostage];

                if ( hostage.m_escortedByRainbow != none  )
                {
                    hostage.m_escortedByRainbow.Escort_RemoveHostage( hostage, true );
                }
                lastRainbow.Escort_AddHostage( hostage, true );
                iHostage++;
            }
        }
    }
}

//------------------------------------------------------------------
// Escort_GetPawnToFollow: 
//	return the rainbow who will lead the escorted hostages
//  the rainbow needs to be in the team (not separated) otherwise
//  the rainbow who ordered to follow will be the lead.
//------------------------------------------------------------------
function R6Rainbow Escort_GetPawnToFollow( R6Rainbow rainbow, bool bRunningTowardMe )
{
    local R6Rainbow lastRainbow;

    // if not separated, check if the last rainbow can be followed
    if ( !m_bTeamIsSeparatedFromLeader || !rainbow.isAlive() )
    {
        lastRainbow = Escort_GetLastRainbow();

        // if the last rainbow is not separated from the team
        if ( lastRainbow != none && lastRainbow.isAlive() )
        {
            rainbow = lastRainbow;
        }
    }

    return rainbow;
}

// Reset the gas grenade variable
event Timer()
{
    m_bFirstTimeInGas = false;
}

defaultproperties
{
     m_eFormation=FORM_SingleFileWallBothSides
     m_eMovementSpeed=SPEED_Normal
     m_eGoCode=GOCODE_None
     m_eBackupGoCode=GOCODE_None
     m_iFormationDistance=100
     m_iDiagonalDistance=80
     m_iSpawnDistance=81
     m_iSpawnDiagDist=115
     m_iSpawnDiagOther=180
     m_bSniperHold=True
     m_bFirstTimeInGas=True
     RemoteRole=ROLE_SimulatedProxy
     bHidden=True
     m_bDeleteOnReset=True
     NetUpdateFrequency=4.000000
}
