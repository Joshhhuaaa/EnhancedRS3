//=============================================================================
//  R6PlayerInput.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/07 * Created by Aristomenis Kolokathis
//=============================================================================

class R6PlayerInput extends PlayerInput within R6PlayerController
    config(User)
	transient;

var         bool        m_bIgnoreInput;
var         bool		m_bFluidMovement;
var         bool        m_bWasFluidMovement;

// defined in actor.uc
// double click move direction.
/*
enum EDoubleClickDir
{
	DCLICK_None,
	DCLICK_Left,        // 
	DCLICK_Right,       // Circumstantial Action
	DCLICK_Forward,     // bAltFire
	DCLICK_Back,
	DCLICK_Active,
	DCLICK_Done
};
*/

function UpdateMouseOptions()
{
	local INT	iScaledSensitivity;

	bInvertMouse = m_GameOptions.InvertMouse;
	m_GameOptions.MouseSensitivity = Clamp(m_GameOptions.MouseSensitivity, 0, 100);
	iScaledSensitivity = (m_GameOptions.MouseSensitivity / 7) + 1; // range from 1 - 15
	SetSensitivity(iScaledSensitivity);
}

event PlayerInput( float DeltaTime )
{
    if(m_bIgnoreInput)
        return; 

	if((m_GameOptions != none) && m_GameOptions.AlwaysRun)
	{
		if(m_bPlayerRun > 0)
			bRun = 0;
		else
			bRun = 1;
	}
	else
		bRun = m_bPlayerRun;

    Super.PlayerInput(DeltaTime);

	// 28 jan 2002 rbrek - when both left and right inputs are pressed, aStrafe flips back and forth between small positive and negative values
	if(abs(aStrafe) < 1.0)
		aStrafe = 0.f;	
	
    m_bFluidMovement = (m_bWasFluidMovement ^^ (m_bSpecialCrouch > 0));
	m_bWasFluidMovement = (m_bSpecialCrouch > 0);
}


// check for double click move
function Actor.eDoubleClickDir CheckForDoubleClickMove(float DeltaTime)
{
	local Actor.eDoubleClickDir DoubleClickMove, OldDoubleClick;

	if ( DoubleClickDir == DCLICK_Active )
		DoubleClickMove = DCLICK_Active;
	else
		DoubleClickMove = DCLICK_None;
	if (DoubleClickTime > 0.0)
	{
		if ( DoubleClickDir < DCLICK_Active )
		{
			OldDoubleClick = DoubleClickDir;
			DoubleClickDir = DCLICK_None;

			if(m_bFluidMovement && m_bWasFluidMovement)         //if (bEdgeForward && bWasForward)
				DoubleClickDir = DCLICK_Forward;
			else if (bEdgeBack && bWasBack)
				DoubleClickDir = DCLICK_Back;
			else if (bEdgeLeft && bWasLeft)
				DoubleClickDir = DCLICK_Left;
			else if (bEdgeRight && bWasRight)
				DoubleClickDir = DCLICK_Right;

			if ( DoubleClickDir == DCLICK_None)
				DoubleClickDir = OldDoubleClick;
			else if ( DoubleClickDir != OldDoubleClick )
				DoubleClickTimer = DoubleClickTime + 0.5 * DeltaTime;
			else 
				DoubleClickMove = DoubleClickDir;
		}

		if (DoubleClickDir == DCLICK_Done)
		{
			DoubleClickTimer -= DeltaTime;
			if (DoubleClickTimer < -0.35) 
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}		
		else if ((DoubleClickDir != DCLICK_None) && (DoubleClickDir != DCLICK_Active))
		{
			DoubleClickTimer -= DeltaTime;			
			if (DoubleClickTimer < 0)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}
	}
	return DoubleClickMove;
}

defaultproperties
{
}
