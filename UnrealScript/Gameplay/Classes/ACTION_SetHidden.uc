class ACTION_SetHidden extends ScriptedAction;

var(Action) bool bHidden;

function bool InitActionFor(ScriptedController C)
{
	C.GetInstigator().bHidden = bHidden;
	return false;	
}

defaultproperties
{
}
