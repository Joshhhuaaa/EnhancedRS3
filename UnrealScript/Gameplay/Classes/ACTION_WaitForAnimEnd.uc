class ACTION_WaitForAnimend extends LatentScriptedAction;

var(Action) int Channel;

function bool CompleteOnAnim(int Num)
{
	return (Channel == Num);
}

defaultproperties
{
     bValidForTrigger=False
     ActionString="Wait for animend"
}
