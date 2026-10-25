//=============================================================================
// Action MoveActor:
//
// Simple class to provide a better name for action that need to move an actor.
// Note: R6 is not added to keep the same naming convention as ActionMoveCamera
//=============================================================================
class ActionMoveActor extends ActionMoveCamera
	native;

#exec Texture Import File=Textures\ActionActorMove.pcx Name=ActionActorMoveIcon Mips=Off

defaultproperties
{
     Icon=Texture'Engine.ActionActorMoveIcon'
}
