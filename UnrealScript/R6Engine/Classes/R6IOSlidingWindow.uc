//=============================================================================
//  R6SlidingWindow : This should allow action moves a window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
// 
//  Revision history:
//    2001/05/23 * Created by Alexandre Dionne
//    2001/11/26 * Merged with interactive objects - Jean-Francois Dube
//  Note: if you make R6IOSlidingWindow native then you will need to take care so
//  that the names in eWindowCircumstantialAction do not conflict with other enums
//=============================================================================

class R6IOSlidingWindow extends R6IActionObject
	placeable;



// R6CIRCUMSTANTIALACTION
#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
// R6CIRCUMSTANTIALACTION

enum EOpeningSide{ Top,Bottom, Left, Right};

enum eWindowCircumstantialAction
{
    CA_None,
    CA_Open,
    CA_Close,
	CA_Climb,
	CA_Grenade,
	CA_OpenAndGrenade,

	// Grenade sub menu
	CA_GrenadeFrag,
	CA_GrenadeGas,
	CA_GrenadeFlash,
	CA_GrenadeSmoke
};
var     FLOAT       C_fWindowOpen;


//-----------------------------------------------------------------------------
// Editables.

var(R6WindowProperties) bool		m_bIsWindowLocked;	//Is the window Locked
var                     bool		sm_bIsWindowLocked;	//Is the window Locked
var(R6WindowProperties) EOpeningSide eOpening;			//The direction of the window opening
var(R6WindowProperties) INT			m_iInitialOpening;		//The percentage of initial window opening
var                     INT			sm_iInitialOpening;		
var(R6WindowProperties) FLOAT		m_iMaxOpening;			//The maximum value for the window to open


//-----------------------------------------------------------------------------
// Internal

var bool    m_bIsWindowClosed;		//Is the door open or not
var vector  sm_Location;
var FLOAT   m_TotalMovement;


//------------------------------------------------------------------
// SaveOriginalData
//	
//------------------------------------------------------------------
simulated function SaveOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( true );
    Super.SaveOriginalData();

    sm_Location        = Location;
    sm_iInitialOpening = m_iInitialOpening;
    sm_bIsWindowLocked = m_bIsWindowLocked;
}
//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    local vector vNewLocation, vX,vY,vZ;

    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    m_ActionInstigator = none;

    SetLocation( sm_Location );
    m_iInitialOpening = sm_iInitialOpening;
    m_bIsWindowLocked = sm_bIsWindowLocked;
    
	if( m_iInitialOpening > 0)
	{
		vNewLocation = Location;
		GetAxes(Rotation, vX,vY, vZ);
	
		switch(eOpening)
		{
			case Top:
				m_TotalMovement = m_iInitialOpening;
				vNewLocation.z = Location.z + m_iInitialOpening;
				break;
			case Bottom:
				m_TotalMovement = m_iMaxOpening -  m_iInitialOpening;
				vNewLocation.z = Location.z - m_iInitialOpening;
				break;
			case Left:
				m_TotalMovement = m_iMaxOpening -  m_iInitialOpening;
				vNewLocation = Location - (m_iInitialOpening * vX);
				break;
			case Right:
				m_TotalMovement = m_iInitialOpening;
				vNewLocation = Location + (m_iInitialOpening * vX);
				break;
		}

		SetLocation(vNewLocation);
	}

    m_bIsWindowClosed = (m_iInitialOpening > 0); 
}

function bool startAction(FLOAT fdeltaMouse, Actor actionInstigator)
{
	
	if(m_ActionInstigator != NONE)
	{
		return false;
	}
	m_ActionInstigator = actionInstigator;

	return updateAction(fDeltaMouse, actionInstigator);	
	
}

function bool updateAction(FLOAT fdeltaMouse, Actor actionInstigator)
{
	local vector vNewLocation, vX,vY,vZ;
	local FLOAT  fWindowMovement;

	if(actionInstigator != m_ActionInstigator)
	{
		return false;
	}
	
	//We scale the mouse movement
	fWindowMovement = FClamp( Abs(fDeltaMouse), m_fMinMouseMove, m_fMaxMouseMove);
	
	
	//Determine how much to open the door based on
	//the mouse movement scaled
	//fWindowMovement = fWindowMovement / m_fMaxMouseMove;
	fWindowMovement = fWindowMovement * m_iMaxOpening / m_fMaxMouseMove;
	
	//Scale the door movement depending of it's mass
	if(Default.Mass != 0 && Mass != 0)
	{
		fWindowMovement = fWindowMovement * Default.Mass / Mass;
	}
	
	if( fdeltaMouse < 0)
	{	
		fWindowMovement = fWindowMovement * -1.0f;		
	}

	m_TotalMovement = m_TotalMovement + fWindowMovement;

	if( m_TotalMovement < 0)
	{
		fWindowMovement = fWindowMovement - m_TotalMovement;
		m_TotalMovement = 0;
	}
	else
		if(m_TotalMovement > m_iMaxOpening)
		{
			fWindowMovement = fWindowMovement - (m_TotalMovement - m_iMaxOpening);
			m_TotalMovement = m_iMaxOpening;
		}

	GetAxes(Rotation, vX,vY, vZ);
	
	vNewLocation = Location;

	switch(eOpening)
	{
		
	case Top:		
		vNewLocation.z = Location.z + fWindowMovement;
		break;	
	case Bottom:		
		vNewLocation.z = Location.z + fWindowMovement;
		break;	
	case Left:				
	case Right:
		vNewLocation = Location + (fWindowMovement * vX);
		break;
		
	}

	SetLocation(vNewLocation);

	return true;
}

function endAction()
{
	m_ActionInstigator = NONE;	
}

event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    local BOOL bIsOpen;

    // If opened at more than 90%, consider the window open
    if( m_TotalMovement > m_iMaxOpening * C_fWindowOpen )
    {
        Query.iHasAction = 1;
        bIsOpen = true;
    }
    else
    {
        Query.iHasAction = 0;
        bIsOpen = false;
        //return;
    }
	
    if( fDistance < m_fCircumstantialActionRange )
    {
        Query.iInRange = 1;
    }
    else
    {
        Query.iInRange = 0;
    }
	
    Query.textureIcon = Texture'R6ActionIcons.Climb';
        
    if( bIsOpen )
    {
        //Query.textureIcon = Texture'R6ActionIcons.CloseWindow';
        
        Query.iPlayerActionID      = eWindowCircumstantialAction.CA_Close;
        Query.iTeamActionID        = eWindowCircumstantialAction.CA_Close;

        Query.iTeamActionIDList[0] = eWindowCircumstantialAction.CA_Close;     
        Query.iTeamActionIDList[1] = eWindowCircumstantialAction.CA_Grenade;
        Query.iTeamActionIDList[2] = eWindowCircumstantialAction.CA_None;
        Query.iTeamActionIDList[3] = eWindowCircumstantialAction.CA_None;

		R6FillSubAction( Query, 0, eWindowCircumstantialAction.CA_None );
		R6FillGrenadeSubAction( Query, 1, playerController );
		R6FillSubAction( Query, 2, eWindowCircumstantialAction.CA_None );
		R6FillSubAction( Query, 3, eWindowCircumstantialAction.CA_None );
    }
    else
    {
        //Query.textureIcon = Texture'R6ActionIcons.OpenWindow';
        
        Query.iPlayerActionID      = eWindowCircumstantialAction.CA_Open;
        Query.iTeamActionID        = eWindowCircumstantialAction.CA_Open;

        Query.iTeamActionIDList[0] = eWindowCircumstantialAction.CA_Open;     
        Query.iTeamActionIDList[1] = eWindowCircumstantialAction.CA_OpenAndGrenade;
        Query.iTeamActionIDList[2] = eWindowCircumstantialAction.CA_None;
        Query.iTeamActionIDList[3] = eWindowCircumstantialAction.CA_None;

		R6FillSubAction( Query, 0, eWindowCircumstantialAction.CA_None );
		R6FillGrenadeSubAction( Query, 1, playerController );
		R6FillSubAction( Query, 2, eWindowCircumstantialAction.CA_None );
		R6FillSubAction( Query, 3, eWindowCircumstantialAction.CA_None );
    }
}

function R6FillGrenadeSubAction( Out R6AbstractCircumstantialActionQuery Query, INT iSubMenu, PlayerController playerController )
{
    local INT i;
    local INT j;

    if (R6ActionCanBeExecuted(eWindowCircumstantialAction.CA_GrenadeFrag, playerController))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eWindowCircumstantialAction.CA_GrenadeFrag;
        i++;
    }

    if (R6ActionCanBeExecuted(eWindowCircumstantialAction.CA_GrenadeGas, playerController))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eWindowCircumstantialAction.CA_GrenadeGas;
        i++;
    }

    if (R6ActionCanBeExecuted(eWindowCircumstantialAction.CA_GrenadeFlash, playerController))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eWindowCircumstantialAction.CA_GrenadeFlash;
        i++;
    }

    if (R6ActionCanBeExecuted(eWindowCircumstantialAction.CA_GrenadeSmoke, playerController))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eWindowCircumstantialAction.CA_GrenadeSmoke;
		i++;
    }

    for(j = i ; j < 4; j++)
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + j] = eWindowCircumstantialAction.CA_None;
    }
}
	

defaultproperties
{
     m_bIsWindowClosed=True
     C_fWindowOpen=0.900000
     m_iMaxOpening=50.000000
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_StaticMesh
     m_eDisplayFlag=DF_ShowOnlyIn3DView
     bObsolete=True
     CollisionRadius=10.000000
     CollisionHeight=10.000000
}
