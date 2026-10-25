class ACTION_MoveToPlayer extends LatentScriptedAction;

function bool MoveToGoal()
{
	return true;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	return C.GetMyPlayer();
}

defaultproperties
{
     bValidForTrigger=False
     ActionString="Move to player"
}
