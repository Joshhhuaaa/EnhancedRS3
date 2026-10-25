class ACTION_StopAnimation extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.ClearAnimation();
	return false;	
}

defaultproperties
{
     bValidForTrigger=False
     ActionString="stop animation"
}
