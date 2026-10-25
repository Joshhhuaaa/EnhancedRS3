//
// Level Change
// When triggered causes change to level described in URL
// OBSOLETE - superceded by ScriptedTrigger
//
class LevelChange extends Triggers
	notplaceable;

var() string URL;

function Trigger( actor Other, pawn EventInstigator )
{
}

defaultproperties
{
     bObsolete=True
}
