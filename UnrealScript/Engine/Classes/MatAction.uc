//=============================================================================
// MatAction: Base class for Matinee actions.
//=============================================================================

class MatAction extends MatObject
	abstract
	native;

import class Actor;

var()		interpolationpoint	IntPoint;	// The interpolation point that we want to move to/wait at.
var()		string				Comment;	// User can enter a comment here that will appear on the GUI viewport

var(Time)	float	Duration;		// How many seconds this action should take

var(Sub)	export	editinline	array<MatSubAction>	SubActions;		// Sub actions are actions to perform while the main action is happening

var(Path) bool		bSmoothCorner;			// true by default - when one control point is adjusted, other is moved to keep tangents the same
var(Path) vector	StartControlPoint;		// Offset from the current interpolation point
var(Path) vector	EndControlPoint;		// Offset from the interpolation point we're moving to (InPointName)
var(Path) bool		bConstantPathVelocity;
var(Path) float		PathVelocity;

var		float		PathLength;

var		transient array<vector> SampleLocations;
var		transient float	PctStarting;
var		transient float	PctEnding;
var		transient float	PctDuration;

//#ifdef R6MATINEE
var				texture		Icon;			//The icon to use in the matinee UI
//#endif 

//#ifdef R6CODE
var(R6Pawn)		bool				m_bCollideActor; //If this Actor.bCollide==true during the action
var(R6Pawn)		Actor.ePhysics		m_PhysicsActor;  //Physics of the target Actor during the Action


event Initialize();


//This action must be overloaded to have a more customized behavior
event ActionStart(Actor viewer)
{
	if(m_bCollideActor==true)
	{
		Viewer.SetCollision(true, true, true);
	}
	else
	{
		Viewer.SetCollision(true, false, false);
	}

	Viewer.SetPhysics(m_PhysicsActor);
	viewer.bInterpolating = true;
}
//#endif R6CODE

defaultproperties
{
     bSmoothCorner=True
     StartControlPoint=(X=800.000000,Y=800.000000)
     EndControlPoint=(X=-800.000000,Y=-800.000000)
}
