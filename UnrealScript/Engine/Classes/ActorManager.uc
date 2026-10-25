//=============================================================================
// ActorManager
//
// Same as SceneManager except for an actor
// Note: R6 is not added to keep the same naming convention as SceneManager
//=============================================================================
class ActorManager extends SceneManager
	placeable
	native;

#exec Texture Import File=Textures\ActorManager.pcx  Name=S_ActorManager Mips=Off

defaultproperties
{
     Affect=AFFECT_Actor
     m_Alias="ActorManager"
     Texture=Texture'Engine.S_ActorManager'
     Tag="SceneManager"
}
