//=============================================================================
// ActionMoveCamera:
//
// Moves the camera to a specified interpolation point.
//=============================================================================
class ActionMoveCamera extends MatAction
	native;

//#ifdef R6MATINEE
#exec Texture Import File=Textures\ActionCamMove.pcx Name=ActionCamMoveIcon Mips=Off
//#endif

var(Path) config enum EPathStyle
{
	PATHSTYLE_Linear,
	PATHSTYLE_Bezier,
} PathStyle;

defaultproperties
{
     Icon=Texture'Engine.ActionCamMoveIcon'
}
