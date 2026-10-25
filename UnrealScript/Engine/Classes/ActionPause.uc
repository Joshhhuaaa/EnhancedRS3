//=============================================================================
// ActionPause:
//
// Pauses for X seconds.
//=============================================================================
class ActionPause extends MatAction
	native;
 
//#ifdef R6MATINEE
#exec Texture Import File=Textures\ActionCamPause.pcx Name=ActionCamPauseIcon Mips=Off
//#endif

defaultproperties
{
     Icon=Texture'Engine.ActionCamPauseIcon'
}
