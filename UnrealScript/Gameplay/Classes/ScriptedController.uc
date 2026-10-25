// ScriptedController
// AI controller which is controlling the pawn through a scripted sequence specified by 
// an AIScript

class ScriptedController extends AIController;

var controller PendingController;	// controller which will get this pawn after scripted sequence is complete
var int ActionNum;
var int AnimsRemaining;
var ScriptedSequence SequenceScript;
var LatentScriptedAction CurrentAction;
var Action_PLAYANIM CurrentAnimation;
var bool bBroken;
var bool bShootTarget;
var bool bShootSpray;
var bool bPendingShoot;
var bool bFakeShot;			// FIXME - this is currently a hack
var bool bUseScriptFacing;
var Actor ScriptedFocus;
var PlayerController MyPlayerController;
var int NumShots;
var name FiringMode;
var int IterationCounter;
var int IterationSectionStart;

function TakeControlOf(Pawn aPawn)
{
	if ( Pawn != aPawn )
	{
		aPawn.PossessedBy(self);
		Pawn = aPawn;
	}
	GotoState('Scripting');
}

function SetEnemyReaction(int AlertnessLevel);

function DestroyPawn()
{
	if ( Pawn != None )
		Pawn.Destroy();
	Destroy();
}

function Pawn GetMyPlayer()
{
	if ( (MyPlayerController == None) || (MyPlayerController.Pawn == None) )
		ForEach DynamicActors(class'PlayerController',MyPlayerController)
			if ( MyPlayerController.Pawn != None )
				break;
	if ( MyPlayerController == None )
		return None;
	return MyPlayerController.Pawn;
}

function Pawn GetInstigator()
{
	if ( Pawn != None )
		return Pawn;
	return Instigator;
}

function Actor GetSoundSource()
{
	if ( Pawn != None )
		return Pawn;
	return SequenceScript;
}

function bool CheckIfNearPlayer(float Distance)
{
	local Pawn MyPlayer;

	MyPlayer = GetMyPlayer();
	return ( (MyPlayer != None) && (VSize(Pawn.Location - MyPlayer.Location) < Distance+CollisionRadius+MyPlayer.CollisionRadius ) && Pawn.PlayerCanSeeMe() );
}

function SetNewScript(ScriptedSequence NewScript)
{
	MyScript = NewScript;
	SequenceScript = NewScript;
	ActionNum = 0;
	Focus = None;
	CurrentAction = None;
	CurrentAnimation = None;
	ScriptedFocus = None;
	Pawn.SetWalking(false);
	Pawn.ShouldCrouch(false);
	SetEnemyReaction(3);
	SequenceScript.SetActions(self);
}

function ClearAnimation()
{
	AnimsRemaining = 0;
	bControlAnimations = false;
	CurrentAnimation = None;
	Pawn.PlayWaiting();
}

function int SetFireYaw(int FireYaw)
{
	FireYaw = FireYaw & 65535;

	if ( (Abs(FireYaw - (Rotation.Yaw & 65535)) > 8192)
		&& (Abs(FireYaw - (Rotation.Yaw & 65535)) < 57343) )
	{
		if ( FireYaw ClockwiseFrom Rotation.Yaw )
			FireYaw = Rotation.Yaw + 8192;
		else
			FireYaw = Rotation.Yaw - 8192;
	}
	return FireYaw;
}

/*@@@CODEDROP927 
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int AimError)
{
	local rotator LookDir;

	// make sure bot has a valid target
	if ( Target == None )
		Target = ScriptedFocus;
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
		{
			bFire = 0;
			bAltFire = 0;
			return Pawn.Rotation;
		}
	}
	LookDir = rotator(Target.Location - projStart);
	LookDir.Yaw = SetFireYaw(LookDir.Yaw);
	return LookDir;
}
*/
function LeaveScripting();

state Scripting
{
	function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
	{
		Super.DisplayDebug(Canvas,YL,YPos);
		Canvas.DrawText("AIScript "$SequenceScript$" ActionNum "$ActionNum, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
		CurrentAction.DisplayDebug(Canvas,YL,YPos);
	}

	/* UnPossess()
	scripted sequence is over - return control to PendingController
	*/
	function UnPossess()
	{
		Pawn.UnPossessed();
		if ( (Pawn != None) && (PendingController != None) )
		{
			PendingController.bStasis = false;
			PendingController.Possess(Pawn);
		}
		Pawn = None;
		Destroy();
	}

	function LeaveScripting()
	{
		UnPossess();
	}

	function InitForNextAction()
	{
		SequenceScript.SetActions(self);
		if ( CurrentAction == None )
		{
			LeaveScripting();
			return;
		}
		MyScript = SequenceScript;
		if ( CurrentAnimation == None )
			ClearAnimation();
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( CurrentAction.CompleteWhenTriggered() )
			CompleteAction();
	}

	function Timer()
	{
		if ( CurrentAction.WaitForPlayer() && CheckIfNearPlayer(CurrentAction.GetDistance()) )
			CompleteAction();
		else if ( CurrentAction.CompleteWhenTimer() )
			CompleteAction();
	}

	function AnimEnd(int Channel)
	{
		if ( CurrentAction.CompleteOnAnim(Channel) )
		{
			CompleteAction();
			return;
		}
		if ( Channel == 0 )
		{
			if ( (CurrentAnimation == None) || !CurrentAnimation.PawnPlayBaseAnim(self,false) )
				ClearAnimation();
		}
		else 
		{
			// FIXME - support for CurrentAnimation play on other channels
			Pawn.AnimEnd(Channel);
		}
	}

	function CompleteAction()
	{
		ActionNum++;
		GotoState('Scripting','Begin');
	}

	function SetMoveTarget()
	{
		local Actor NextMoveTarget;

		Focus = ScriptedFocus;
		NextMoveTarget = CurrentAction.GetMoveTargetFor(self);
		if ( NextMoveTarget == None )
		{
			GotoState('Broken');
			return;
		}
		if ( Focus == None )
			Focus = NextMoveTarget;
		MoveTarget = NextMoveTarget;
		if ( !ActorReachable(MoveTarget) )
		{
			MoveTarget = FindPathToward(MoveTarget);
			if ( Movetarget == None )
			{
				AbortScript();
				return;
			}
			if ( Focus == NextMoveTarget )
				Focus = MoveTarget;				
		}
	}

	function AbortScript()
	{
		LeaveScripting();
	}
/* R6CHANGEWEAPONSYSTEM
	// WeaponFireAgain()
	//Notification from weapon when it is ready to fire (either just finished firing,
	//or just finished coming up/reloading).
	//Returns true if weapon should fire.
	//If it returns false, can optionally set up a weapon change
	function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
	{
		if ( Pawn.bIgnorePlayFiring )
		{
			Pawn.bIgnorePlayFiring = false;
			return false;
		}
		if ( NumShots < 0 )
		{
			bShootTarget = false;
			bShootSpray = false;
			StopFiring();
			return false;
		}
		if ( bShootTarget && (ScriptedFocus != None) && !ScriptedFocus.bDeleteMe )
		{
			Target = ScriptedFocus;
			if ( (!bShootSpray && ((Pawn.Weapon.RefireRate() < 0.99) && !Pawn.Weapon.CanAttack(Target)))
				|| !Pawn.Weapon.BotFire(bFinishedFire,FiringMode) )
			{
				Enable('Tick'); //FIXME - use multiple timer for this instead
				bPendingShoot = true;
				return false;
			}
			if ( NumShots > 0 )
			{
				NumShots--;
				if ( NumShots == 0 )
					NumShots = -1;
			}
			return true;
		}
		StopFiring();
		return false;
	}
*/

	function Tick(float DeltaTime)
	{
		if ( bPendingShoot )
		{
			bPendingShoot = false;
			MayShootTarget();
		}
		if ( !bPendingShoot
			&& ((CurrentAction == None) || !CurrentAction.StillTicking(self,DeltaTime)) )
			disable('Tick');
	}

	function MayShootAtEnemy();

	function MayShootTarget()
	{
/* R6CHANGEWEAPONSYSTEM
		WeaponFireAgain(0,false);
*/
	}

	function EndState()
	{
		bUseScriptFacing = true;
		bFakeShot = false;
	}

Begin:
	InitforNextAction();
	if ( bBroken )
		GotoState('Broken');
	if ( CurrentAction.TickedAction() )
		enable('Tick');
	if ( !bShootTarget )
	{
		bFire = 0;
		bAltFire = 0;
	}
	else
	{
//@@@CODEDROP927    Pawn.Weapon.RateSelf();
		if ( bShootSpray )
			MayShootTarget();
	}
	if ( CurrentAction.MoveToGoal() )
	{
		Pawn.SetMovementPhysics();
		WaitForLanding();
KeepMoving:
		SetMoveTarget();
		MayShootTarget();
		MoveToward(MoveTarget, Focus,,,,Pawn.bIsWalking);
		if ( (MoveTarget != CurrentAction.GetMoveTargetFor(self))
			|| !Pawn.ReachedDestination(CurrentAction.GetMoveTargetFor(self)) )
			Goto('KeepMoving');
		CompleteAction();
	}
	else if ( CurrentAction.TurnToGoal() )
	{
		Pawn.SetMovementPhysics();
		Focus = CurrentAction.GetMoveTargetFor(self);
		if ( Focus == None )
			FocalPoint = Pawn.Location + 1000 * vector(SequenceScript.Rotation);
		FinishRotation();
		CompleteAction();
	}
	else
	{
		//Pawn.SetPhysics(PHYS_RootMotion);
		Pawn.Acceleration = vect(0,0,0);
		Focus = ScriptedFocus;
		if ( !bUseScriptFacing )
			FocalPoint = Pawn.Location + 1000 * vector(Pawn.Rotation);
		else if ( Focus == None )
		{
			MayShootAtEnemy();
			FocalPoint = Pawn.Location + 1000 * vector(SequenceScript.Rotation);
		}
		FinishRotation();
		MayShootTarget();
	}
}

// Broken scripted sequence - for debugging
State Broken
{
Begin:
	warn(Pawn$" Scripted Sequence BROKEN "$SequenceScript$" ACTION "$CurrentAction);
	Pawn.bPhysicsAnimUpdate = false;
	Pawn.StopAnimating();
	if ( GetMyPlayer() != None )
		PlayerController(GetMyPlayer().Controller).SetViewTarget(Pawn);
}

defaultproperties
{
     IterationSectionStart=-1
     bUseScriptFacing=True
}
