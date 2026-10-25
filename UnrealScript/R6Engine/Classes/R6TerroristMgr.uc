//=============================================================================
//  R6TerroristMgr.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:  Terrorist AI manager for interaction with hostage
//    2001/12/03 * Created by Guillaume Borgia
//=============================================================================
class R6TerroristMgr extends R6AbstractTerroristMgr
    native;

// If you modify this struct, don't forget to modify it in R6Engine.h too
struct STHostage
{
    var R6Hostage       hostage;
    var R6TerroristAI   terro;
    var INT             bInZone;
};

const MAX_Hostage = 16;

var STHostage   m_ArrayHostage[MAX_Hostage];
var INT         m_iCurrentMax;
var INT         m_iCurrentGroupID;

// List of DZone with hostage associated
var const Array<R6DeploymentZone> m_aDeploymentZoneWithHostage;

// Init the manager.  Dummy actor can be anything, just needed to have a pointer on the level
native(1825) final function Init( Actor dummy ); 
// Get the zone in wich the terrorist must go to park the hostage
native(1826) final function R6DeploymentZone FindNearestZoneForHostage( R6Terrorist terro );

function Initialization( Actor dummy )
{
    Init( dummy );
}

//============================================================================
// ResetOriginalData - 
//============================================================================
function ResetOriginalData()
{
    local INT i;

    for(i=0; i<MAX_Hostage; i++)
    {
        m_ArrayHostage[i].hostage = none;
        m_ArrayHostage[i].terro = none;
        m_ArrayHostage[i].bInZone = 0;
    }
    m_iCurrentMax = 0;
}

//============================================================================
// FindHostageIndex - 
//============================================================================
function INT FindHostageIndex( R6Hostage hostage )
{
    local INT i;

    // Check if hostage already added to the list
    if(hostage.m_iIndex!=-1)
    {
        return hostage.m_iIndex;
    }
    // add it
    else
    {
        m_iCurrentMax++;
        assert(m_iCurrentMax<MAX_Hostage);

        m_ArrayHostage[m_iCurrentMax].hostage = hostage;
        hostage.m_iIndex = m_iCurrentMax;
        return m_iCurrentMax;
    }
}

//============================================================================
// IsHostageAssigned - 
//============================================================================
function BOOL IsHostageAssigned( R6Hostage hostage )
{
    local INT i;

    i = FindHostageIndex( hostage );

    if( hostage.m_ePersonality == HPERSO_Bait )
        return true;
    else
        return (m_ArrayHostage[i].terro != None || m_ArrayHostage[i].bInZone == 1);
}

//============================================================================
// AssignHostageTo - 
//============================================================================
function AssignHostageTo( R6Hostage hostage, R6TerroristAI terro )
{
    local INT i;
    local R6DeploymentZone zone;

    i = FindHostageIndex( hostage );

    m_ArrayHostage[i].terro = terro;
    m_ArrayHostage[i].bInZone = 0;
}

//============================================================================
// AssignHostageToZone - 
//============================================================================
function AssignHostageToZone( R6Hostage hostage, R6DeploymentZone zone )
{
    local INT i;

    i = FindHostageIndex( hostage );

    m_ArrayHostage[i].terro = None;
    m_ArrayHostage[i].bInZone = 1;

    // Add hostage to terrorist zone
    zone.AddHostage( hostage );
}

//============================================================================
// RemoveHostageAssignment - 
//============================================================================
function RemoveHostageAssignment( R6Hostage hostage )
{
    local INT i;

    i = FindHostageIndex( hostage );

    m_ArrayHostage[i].terro = None;
    m_ArrayHostage[i].bInZone = 0;
}

defaultproperties
{
     m_iCurrentMax=-1
}
