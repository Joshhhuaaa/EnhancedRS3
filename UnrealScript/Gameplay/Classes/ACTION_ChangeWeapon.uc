class ACTION_ChangeWeapon extends ScriptedAction;

/*@@@CODEDROP927

var(Action) class<Weapon> NewWeapon;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.PendingWeapon = Weapon(C.Pawn.FindInventoryType(newWeapon));
	C.Pawn.ChangedWeapon();

	return false;	
}

*/

defaultproperties
{
}
