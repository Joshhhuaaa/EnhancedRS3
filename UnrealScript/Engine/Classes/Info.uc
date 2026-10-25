//=============================================================================
// Info, the root of all information holding classes.
//=============================================================================
class Info extends Actor
	abstract
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	native;

defaultproperties
{
     bHidden=True
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
     NetUpdateFrequency=5.000000
}
