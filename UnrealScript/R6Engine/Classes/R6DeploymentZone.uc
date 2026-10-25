//=============================================================================
//  R6DeploymentZone.uc : Zone for terrorist deployment
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/10 * Created by Guillaume Borgia
//=============================================================================

class R6DeploymentZone extends Actor
    native
	abstract;

import class R6AIController;
import class R6TerroristAI;

#exec OBJ LOAD FILE=..\Textures\R6Engine_T.utx PACKAGE=R6Engine_T

const C_NB_Template = 5;

struct STTemplate
{
    var()   String  m_szName;
    var()   INT     m_iChance;
};

var(Debug)              BOOL                m_bDontSeePlayer;       // Only for debug purpose
var(Debug)              BOOL                m_bDontHearPlayer;      // Only for debug purpose
var(Debug)              BOOL                m_bHearNothing;         // Only for debug purpose

var(R6DZoneTerrorist)   BOOL                m_bAllowLeave;
var(R6DZoneTerrorist)   BOOL                m_bPreventCrouching;
var(R6DZoneTerrorist)   BOOL                m_bKnowInPlanning;

var(R6DZoneTerrorist)   BOOL				m_bHuntDisallowed;
var(R6DZoneTerrorist)   BOOL				m_bHuntFromStart;

var                     BOOL                m_bAlreadyInitialized;
var(R6DZoneTerrorist)   BOOL                m_bUseGrenade;
var(MP2Civilian)        BOOL                m_bClassicMissionCivilian;

var(R6DZoneTerrorist)   INT                 m_iGroupID;
var(R6DZoneTerrorist)   editinline array<INT>           m_iGroupIDsToCall;
var(R6DZoneTerrorist)   array<R6DeploymentZone>         m_HostageZoneToCheck;
var(MP2Civilian)        array<PathNode>                 m_pListOfCoverNodes;
var(R6DZoneTerrorist)   INT                             m_HostageShootChance;
var(R6DZoneTerrorist)   R6Terrorist.EDefCon             m_eDefCon;
var(R6DZoneTerrorist)   R6TerroristAI.EEngageReaction   m_eEngageReaction;
var(R6DZoneTerrorist)   INT                 m_iMinTerrorist;
var(R6DZoneTerrorist)   INT                 m_iMaxTerrorist;
var(R6DZoneTerrorist)   INT                 m_iChanceToUseGrenadeAtFirstReaction;

var(R6DZoneTerrorist)   STTemplate          m_Template[C_NB_Template]; // Terrorist template

var(R6DZoneTerrorist)   R6InteractiveObject m_InteractiveObject;

var(R6DZoneHostage)     INT                 m_iMinHostage;
var(R6DZoneHostage)     INT                 m_iMaxHostage;
var(R6DZoneHostage)     INT                 m_iPrisonerTeam;
var(R6DZoneHostage)     STTemplate          m_HostageTemplates[C_NB_Template];

var const Array<R6Terrorist>    m_aTerrorist;
var const Array<R6Hostage>      m_aHostage;

native(1830) final function FirstInit();
native(1831) final function vector FindRandomPointInArea();
native(1832) final function BOOL IsPointInZone( Vector vPoint );
native(1833) final function vector FindClosestPointTo( Vector vPoint );
native(1834) final function BOOL HaveTerrorist();
native(1835) final function BOOL HaveHostage();
native(1836) final function AddHostage( R6Hostage hostage );
native(1837) final function OrderTerroListFromDistanceTo( Vector vPoint );
native(1838) final function R6Hostage GetClosestHostage( Vector vPoint );

function InitZone()
{
    FirstInit();
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();
    
    m_aTerrorist.Remove( 0, m_aTerrorist.Length );
    m_aHostage.Remove( 0, m_aHostage.Length );
}

defaultproperties
{
     m_eDefCon=DEFCON_3
     m_iMinTerrorist=1
     m_iMaxTerrorist=1
     m_iChanceToUseGrenadeAtFirstReaction=100
     m_bAllowLeave=True
     m_bKnowInPlanning=True
     m_bUseGrenade=True
     bStatic=True
     bHidden=True
     bNoDelete=True
     m_bUseR6Availability=True
     DrawScale=3.000000
     CollisionRadius=40.000000
     CollisionHeight=85.000000
     Texture=Texture'R6Engine_T.Icons.DZoneTer'
}
