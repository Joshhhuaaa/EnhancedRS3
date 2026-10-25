//=============================================================================
// RoundRobin: Each time it's triggered, it advances through a list of
// outgoing events.
// OBSOLETE - superceded by ScriptedTrigger
//=============================================================================
class RoundRobin extends Triggers
	notplaceable;

var() name OutEvents[16]; // Events to generate.
var() bool bLoop;         // Whether to loop when get to end.
var int i;                // Internal counter.

//
// When RoundRobin is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	TriggerEvent(OutEvents[i],self,EventInstigator);
	i++;
	if ( i>=ArrayCount(OutEvents) || (OutEvents[i]=='') || (OutEvents[i]=='None') )
	{
		if( bLoop ) 
			i=0;
		else
			SetCollision(false,false,false);
	}

}

defaultproperties
{
     bObsolete=True
}
