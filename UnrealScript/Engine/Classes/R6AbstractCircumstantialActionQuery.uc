//=============================================================================
//  R6CircumstantialActionQuery.uc : describes action that can be performed on an actor
//                                  originally stCircumstantialActionQuery
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/05 * Created by Aristomenis Kolokathis
//=============================================================================

class R6AbstractCircumstantialActionQuery extends actor
	native
	nativereplication;


var BYTE        iHasAction;                 // Is the CA Initialized ?
var BYTE        iInRange;                   // Is this action is in range ?

var Actor       aQueryOwner;                // Actor who made the query (usually the player pawn)
var Actor       aQueryTarget;               // Actor targeted (actor possessing the actions)

// Action list - Refer to ID that should be define in the aQueryTarget class
var BYTE        iPlayerActionID;            // Action ID for the player action 
var BYTE        iTeamActionID;              // Action ID for the team action
var BYTE        iTeamActionIDList[4];       // Actions IDs for the team action menu
var BYTE		iTeamSubActionsIDList[16];	// Actions Ids for the team action submenus (0-3 are subactions for menu action 0, 4-7 are subaction for menu action 1, ...)

var INT			iMenuChoice;                // Action ID selected from the rose des vents menu
var INT			iSubMenuChoice;             // Action ID selected from the rose des vents sub menu

var Texture     textureIcon;                // Icon associated with this actor action

var BOOL        bCanBeInterrupted;          // Is this action interruptible
var FLOAT       fPlayerActionTimeRequired;  // Time required for the player to start the action (with base skill) - Skill should affect this value
var FLOAT       m_fPressedTime;             // How long the action key has been pressed

replication
{
    reliable if (Role==Role_Authority)
        iHasAction,iInRange,aQueryOwner,aQueryTarget,textureIcon,
        bCanBeInterrupted,fPlayerActionTimeRequired,iPlayerActionID,
        iTeamActionIDList,iTeamSubActionsIDList;
}

//resets this object

simulated function ResetOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();
    
    aQueryTarget = None;
    iHasAction = 0;
    bCanBeInterrupted = false;
    fPlayerActionTimeRequired = 0.0f;
    iMenuChoice = -1;
    iSubMenuChoice = -1;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_None
     bHidden=True
}
