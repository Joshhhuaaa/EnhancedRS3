class FadeViewTrigger extends Triggers
	notplaceable;

var(ZoneLight) vector ViewFlash, ViewFog;


var() vector TargetFlash;
var() bool bTriggerOnceOnly; 
var() float FadeSeconds;


var vector OldViewFlash;
var bool bTriggered;

event Trigger( Actor Other, Pawn EventInstigator )
{
	if(bTriggered && !bTriggerOnceOnly)
	{
		bTriggered = False;
		PhysicsVolume.ViewFlash = OldViewFlash;
	}
	else
	{
		bTriggered = True;
		OldViewFlash = PhysicsVolume.ViewFlash;
		GotoState('IsTriggered');
	}
}

State IsTriggered
{
	event Tick(float DeltaTime)
	{
		local vector V;
		local bool bXDone, bYDone, bZDone;

		if(bTriggered)
		{
			bXDone = False;
			bYDone = False;
			bZDone = False;

			V = PhysicsVolume.ViewFlash - (OldViewFlash - TargetFlash) * (DeltaTime/FadeSeconds);

			if( V.X < TargetFlash.X ) { V.X = TargetFlash.X; bXDone = True; }
			if( V.Y < TargetFlash.Y ) { V.Y = TargetFlash.Y; bYDone = True; }
			if( V.Z < TargetFlash.Z ) { V.Z = TargetFlash.Z; bZDone = True; }

			PhysicsVolume.ViewFlash = V;

			if(bXDone && bYDone && bZDone)
				GotoState('');;
		}
	}
}

defaultproperties
{
     FadeSeconds=5.000000
     TargetFlash=(X=-2.000000,Y=-2.000000,Z=-2.000000)
     bObsolete=True
}
