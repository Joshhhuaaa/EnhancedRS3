//=============================================================================
//  R6SoundReplicationInfo.uc : replicates weapon's infos
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/11 * Created by Jean-Francois Dube
//=============================================================================

class R6SoundReplicationInfo extends Actor
	native;

var R6Pawn                      m_PawnOwner;                    // REPLICATED: Pawn
var vector                      m_Location;                     // REPLICATED: Location
var R6PawnReplicationInfo       m_PawnRepInfo;                  // REPLICATED: PawnReplicationInfo for each in controller for each pawn
var BYTE                        m_CurrentWeapon;                // REPLICATED: What weapon they use righ now
var BYTE                        m_NewWeaponSound;               // REPLICATED: Contain the sound to play
var BYTE                        m_NewPawnState;                 // REPLICATED: contain : m_GunSoundType, m_PawnState
var BYTE                        m_Material;                     // REPLICATED: m_Material

var FLOAT                       m_fClientUpdateFrequency;       //     SERVER: Replication update frequency in seconds
var FLOAT                       m_fClientLastUpdate;            //     SERVER: Last replication update

var BYTE                        m_PawnState;
var BYTE                        m_TeamColor;
var BYTE                        m_GunSoundType;
var BYTE                        m_StatusOtherTeam;             

var BOOL                        m_bInitialize;
var BOOL                        m_bLastSoundFullAuto;
var BYTE                        m_LastPlayedWeaponSound;    // Only use on client side

native(2727) final function PlayWeaponSound(R6EngineWeapon.EWeaponSound eWeaponSound);
native(2728) final function StopWeaponSound();
native(3000) final function PlayLocalWeaponSound(R6EngineWeapon.EWeaponSound eWeaponSound);

replication
{
    unreliable if(Role == ROLE_Authority)
        m_Location, m_NewPawnState, m_Material;

    reliable if (Role == ROLE_Authority)
        m_CurrentWeapon, m_PawnRepInfo, m_PawnOwner, m_NewWeaponSound;
}

function Destroyed()
{
    m_PawnOwner = none;
    Super.Destroyed();
}

defaultproperties
{
     m_fClientUpdateFrequency=1.000000
     RemoteRole=ROLE_AutonomousProxy
     DrawType=DT_None
     bHidden=True
     bSkipActorPropertyReplication=True
     m_fSoundRadiusActivation=5600.000000
     NetUpdateFrequency=10.000000
}
