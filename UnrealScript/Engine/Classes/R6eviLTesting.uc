//================================================================================
// R6eviLTesting.
//================================================================================

class R6eviLTesting extends Actor
	native
	HideCategories(Movement,Collision,Lighting,LightColor,Karma,Force);

native(1356) final function NativeRunAllTests ();

event RunAll ()
{
	NativeRunAllTests();
}

defaultproperties
{
    bHidden=True

}
