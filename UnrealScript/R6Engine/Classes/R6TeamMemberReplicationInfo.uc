//=============================================================================
//  R6TeamReplicationInfo.uc : replicates pawn's location for the team's member
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/05 * Created by Jean-Francois Dube
//=============================================================================

class R6TeamMemberReplicationInfo extends Actor
	native;

var string  m_CharacterName;                // REPLICATED: Character Name. Use in InGame Map and Operative Selector
var String  m_PrimaryWeapon;                // REPLICATED: Primary Weapon ID
var String  m_SecondaryWeapon;              // REPLICATED: Secondary Weapon ID
var String  m_PrimaryGadget;                // REPLICATED: Primary Gadget ID
var String  m_SecondaryGadget;              // REPLICATED: Secondary Gadget ID
var bool    m_bIsPrimaryGadgetEmpty;        // REPLICATED: Is the character still have primary gadgets
var bool    m_bIsSecondaryGadgetEmpty;      // REPLICATED: Is the character still have secondary gadgets
var byte    m_RotationYaw;                  // REPLICATED: Short Rotation. Use in the Ingame Map
var vector  m_Location;                     // REPLICATED: Location
var byte    m_BlinkCounter;                 // REPLICATED: Used to know that we need to start blinking
var int     m_iTeam;                        // REPLICATED: Owner's team
var int     m_iTeamID;                      // REPLICATED: Owner's team ID
var byte    m_iTeamPosition;                // REPLICATED: Position of the character in his team
var byte    m_eHealth;                      // REPLICATED: Owners's health
var bool    m_bIsPilot;                     // REPLICATED: Is this pawn the pilot?
var bool    m_bIsIntruder;
var bool    m_bHasFloppy;
var byte    m_BlinkCounterOld;              //    CLIENTS: Used to know that the server requested blinking
var float   m_fLastCommunicationTime;       //    CLIENTS: Blinking time
var float   m_fClientUpdateFrequency;       //     SERVER: Replication update frequency in seconds
var float   m_fClientLastUpdate;            //     SERVER: Last replication update
var float   m_fCompteurFrameDetection;



replication
{
    unreliable if(Role == ROLE_Authority)
        m_Location, m_iTeam, m_iTeamID, m_eHealth, m_bIsPilot, m_BlinkCounter, m_CharacterName, m_RotationYaw, m_iTeamPosition,
        m_PrimaryWeapon, m_SecondaryWeapon, m_PrimaryGadget, m_SecondaryGadget, m_bIsPrimaryGadgetEmpty, m_bIsSecondaryGadgetEmpty;

    reliable if(Role == ROLE_Authority)
        m_bIsIntruder, m_bHasFloppy, m_fCompteurFrameDetection;
}

defaultproperties
{
     m_iTeamId=-1
     m_fClientUpdateFrequency=0.200000
     RemoteRole=ROLE_AutonomousProxy
     DrawType=DT_None
     bHidden=True
     bSkipActorPropertyReplication=True
     NetUpdateFrequency=5.000000
}
