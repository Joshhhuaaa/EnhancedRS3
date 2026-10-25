//=============================================================================
// BlockingVolume:  a bounding volume
// used to block certain classes of actors
// primary use is to provide collision for non-zero extent traces around static meshes 

//=============================================================================

class BlockingVolume extends Volume
	native;

defaultproperties
{
     bWorldGeometry=True
     bBlockActors=True
     bBlockPlayers=True
}
