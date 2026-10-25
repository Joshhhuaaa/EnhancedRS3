class ACTION_KillInstigator extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.GetInstigator().ServerForceKillResult(4);
	C.GetInstigator().R6TakeDamage( 100000, 1000000, None, vect(0,0,0), vect(0,0,0), 0 );
	C.GetInstigator().ServerForceKillResult(0);
	return false;	
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
     ActionString="Kill instigator"
}
