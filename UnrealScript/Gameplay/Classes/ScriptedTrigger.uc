//=============================================================================
// ScriptedTrigger
// replaces Counter, Dispatcher, SpecialEventTrigger
//=============================================================================
class ScriptedTrigger extends ScriptedSequence;

function PostBeginPlay()
{
	local ScriptedTriggerController TriggerController;

	Super.PostBeginPlay();
	TriggerController = Spawn(class'ScriptedTriggerController');
	TriggerController.InitializeFor(self);
}

function bool ValidAction(Int N)
{
	return Actions[N].bValidForTrigger;
}

defaultproperties
{
     Texture=Texture'Gameplay.S_SpecialEvent'
}
