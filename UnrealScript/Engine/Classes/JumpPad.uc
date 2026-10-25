//=============================
// Jumppad - bounces players/bots up
// not directly placeable.  Make a subclass with appropriate sound effect etc.
//
class JumpPad extends NavigationPoint
	native
	placeable;

var vector JumpVelocity;
var Actor JumpTarget;
var() vector JumpModifier;	// for tweaking JumpVelocity, if needed


event Touch(Actor Other)
{
	if ( Pawn(Other) == None )
		return;

	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
}

event PostTouch(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);
	if ( P == None )
		return;

	if ( AIController(P.Controller) != None )
	{
		P.Controller.Movetarget = JumpTarget;
		P.Controller.Focus = JumpTarget;
		P.Controller.MoveTimer = 2.0;
		P.DestinationOffset = JumpTarget.CollisionRadius;
	}
	if ( P.Physics == PHYS_Walking )
		P.SetPhysics(PHYS_Falling);
	P.Velocity =  JumpVelocity + JumpModifier;
	P.Acceleration = vect(0,0,0);
}

defaultproperties
{
     JumpVelocity=(Z=150.000000)
     bDestinationOnly=True
     bCollideActors=True
}
