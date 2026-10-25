//=============================================================================
// SceneManager
//
// Manages a matinee scene.  Contains a list of action items that will
// be played out in order.
//=============================================================================
class SceneManager extends Info
	placeable
	native;

#exec Texture Import File=Textures\SceneManager.pcx  Name=S_SceneManager Mips=Off

// Graphics for UI
#exec Texture Import File=Textures\S_MatineeIP.pcx Name=S_MatineeIP Mips=Off MASKED=1
#exec Texture Import File=Textures\S_MatineeIPSel.pcx Name=S_MatineeIPSel Mips=Off MASKED=1
#exec Texture Import File=Textures\S_MatineeTimeMarker.pcx Name=S_MatineeTimeMarker Mips=Off MASKED=1
#exec Texture Import File=Textures\ActionCamMove.pcx  Name=S_ActionCamMove Mips=Off
#exec Texture Import File=Textures\ActionCamPause.pcx  Name=S_ActionCamPause Mips=Off
#exec Texture Import File=Textures\PathLinear.pcx  Name=S_PathLinear Mips=Off MASKED=1
#exec Texture Import File=Textures\PathBezier.pcx  Name=S_PathBezier Mips=Off MASKED=1
#exec Texture Import File=Textures\S_BezierHandle.pcx  Name=S_BezierHandle Mips=Off MASKED=1
#exec Texture Import File=Textures\SubActionIndicator.pcx  Name=SubActionIndicator Mips=Off MASKED=1

struct Orientation
{
	var() ECamOrientation	CamOrientation;
	var() actor LookAt;
	var() float EaseIntime;
	var() int bReversePitch;
	var() int bReverseYaw;
	var() int bReverseRoll;

	var int MA;
	var float PctInStart, PctInEnd, PctInDuration;
	var rotator StartingRotation;
}; 

struct Interpolator
{
	var() int bDone;
	var() float _value;
	var() float _remainingTime;
	var() float _totalTime;
	var() float _speed;
	var() float _acceleration;
};

// Exposed vars
var()	export	editinline	array<MatAction>	Actions;
var()	config	enum EAffect
{
	AFFECT_ViewportCamera,
	AFFECT_Actor,
} Affect;
var()	Actor	AffectedActor;			// The name of the actor which will follow the matinee path (if Affect==AFFECT_Actor)
var()	bool	bLooping;				// If this is TRUE, the path will looping endlessly
var()	bool	bCinematicView;			// Should the screen go into letterbox mode when playing this scene?
var()   name	PlayerScriptTag;		// Tag of sequence that player's pawn should use during sequence
var()	name	NextSceneTag;			// The tag of the next scenemanager to execute when this one finishes


//#ifdef R6CODE----

/*MATINEE_AI_MODE
var enum eSceneState
{
	ST_Animate,
	ST_Wait

} m_CurrentState;
*/

var(R6Scene)   string				m_Alias;			//Used for display in the Matinee Dialog
var			   transient MatAction	m_PreviousAction;	//The previous action, 
var(R6Scene)   bool					m_bFixedPosition;	//If true, the intPoints dont affect the Actor
var			   transient bool		m_bPreviewReplay;   //If true, the preview will replay the scene

//Cached values for display:
var			   transient string     m_DisplayString;	//The info string displayed by the preview.

//clauzon march 13 2002: Used if we are in AI mode to update the subActions.
//The PctSceneComplete is not updated because we don't know how much time the ExecuteAI will last.
//Matinee was designed to make fixed length scene. So during an ExecuteAI action we stop the matinee
//time and use our own timer and routine to update the SubActions...
//MATINEE_AI_MODE var			   transient float		m_fTimeElapsed;	

//#endif R6CODE----


// These vars are set by the SceneManager in it's Tick function.  Don't mess with them directly.
var		transient float PctSceneComplete;			// How much of the scene has finished running
var		transient mataction	CurrentAction;			// The currently executing action
var		transient float SceneSpeed;
var		transient float	TotalSceneTime;				// The total time the scene will take to run (in seconds)
var		transient Actor	Viewer;						// The actor viewing this scene (the one being affected by the actions)
var		transient Pawn OldPawn;						// The pawn we need to repossess when scene is over
var		transient bool bIsRunning;					// If TRUE, this scene is executing.
var		transient bool bIsSceneStarted;				// If TRUE, the scene has been initialized and is running
var		transient float CurrentTime;				// Keeps track of the current time using the DeltaTime passed to Tick
var		transient array<vector> SampleLocations;	// Sampled locations for camera movement
var		transient array<MatSubAction> SubActions;	// The list of sub actions which will execute during this scene
var		transient Orientation CamOrientation;		// The current camera orientation
var		transient Orientation PrevOrientation;		// The previous orientation that was set
var		transient Interpolator RotInterpolator;		// Interpolation helper for rotations
var		transient vector CameraShake;				// The SubActionCameraShake effect fills this var in each frame
var		transient vector DollyOffset;				// How far away we are from the actor we are locked to

// Native functions
native		 function float GetTotalSceneTime();

//#ifdef R6CODE
native(2906) final function TerminateAIAction();	//Go back to the normal Matinee mode.
native(2909) final function SceneDestroyed();
//#endif

simulated function BeginPlay()
{
	Super.BeginPlay();

	if( Affect == AFFECT_Actor && AffectedActor == None )
		log( "SceneManager : Affected actor is NULL!" );

	//
	// Misc set up
	//

	TotalSceneTime = GetTotalSceneTime();
	bIsRunning = false;
	bIsSceneStarted = false;
}

function Trigger( actor Other, Pawn EventInstigator )
{
	bIsRunning = true;
	bIsSceneStarted = false;
	Disable( 'Trigger' );
}

// Events
event SceneStarted()	// Called from C++ when the scene starts.
{
	local Controller P;
	local AIScript S;

	// Figure out who our viewer is.
	Viewer = None;
	if( Affect==AFFECT_Actor )
		Viewer = AffectedActor;
	else
	{
		for( P = Level.ControllerList ; P != None ; P = P.nextController )
		{

			log("for PlayerController");
		
			if( P.IsA('PlayerController') && (P.Pawn != None) )
			{
				log("Is a Player Controller");

				Viewer = P;
				OldPawn = PlayerController(Viewer).Pawn;
				if ( OldPawn != None )
				{

				    OldPawn.Velocity = vect(0,0,0);
				    OldPawn.Acceleration = vect(0,0,0);

//#ifdef R6CODE
					PlayerController(Viewer).InitMatineeCamera();
//#endif

				    PlayerController(Viewer).UnPossess();
					if ( PlayerScriptTag != 'None' )
					{
						ForEach DynamicActors( class'AIScript', S, PlayerScriptTag )
							break;
						if ( S != None )
							S.TakeOver(OldPawn);
					}
				}

				PlayerController(Viewer).StartInterpolation();
				PlayerController(Viewer).MyHud.bHideHUD = true;
				break;
			}//if isA
		}//for
	}//else

}

event SceneEnded()		// Called from C++ when the scene ends.
{
	bIsSceneStarted = false;

	if( Affect==AFFECT_ViewportCamera )
	{

//#ifdef R6CODE
	PlayerController(Viewer).EndMatineeCamera();
//#endif

		if ( PlayerController(Viewer) != None )
		{
			if ( OldPawn != None )
				PlayerController(Viewer).Possess( OldPawn );
			PlayerController(Viewer).MyHud.bHideHUD = false;
		}
	}
	Viewer.FinishedInterpolation();
	Enable( 'Trigger' );
}


//#ifdef R6CODE
event Destroyed()
{
	log("SceneManager DESTROYED");
	SceneDestroyed();
}

/*MATINEE_AI_MODE
event WaitForTag(name tagName)
{
	Tag = tagName;
	log("Passe a WaitState");
	GotoState('WaitState');
}

auto state AnimState
{
	event BeginState()
	{
		m_CurrentState=ST_Animate;
	}
}

state WaitState
{
	event BeginState()
	{
		m_CurrentState=ST_Wait;
	}

	event Trigger( Actor Other, Pawn EventInstigator )
	{
		log("Passe de WaitState a AnimState");
		TerminateAIAction();
		GotoState('AnimState');
	}
}
*/
//#endif

defaultproperties
{
     m_Alias="SceneManager"
     Texture=Texture'Engine.S_SceneManager'
}
