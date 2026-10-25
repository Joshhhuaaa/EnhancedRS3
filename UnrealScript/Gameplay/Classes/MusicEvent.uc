//=============================================================================
// MusicEvent.
// OBSOLETE - superceded by ScriptedTrigger
//=============================================================================
class MusicEvent extends Triggers
	notplaceable;

// Variables.
var() string           Song;
var() EMusicTransition Transition;
var() bool             bSilence;
var() bool             bOnceOnly;
var() bool             bAffectAllPlayers;

// When gameplay starts.
function BeginPlay()
{
	if( Song=="" )
	{
		Song = Level.Song;
	}
	if( bSilence )
	{
	}
}

// When triggered.
function Trigger( actor Other, pawn EventInstigator )
{
	local PlayerController P;
	local Controller A;

	if( bAffectAllPlayers )
	{
		For ( A=Level.ControllerList; A!=None; A=A.nextController )
			if ( A.IsA('PlayerController') )
				PlayerController(A).ClientSetMusic( Song, Transition );
	}
	else
	{
		// Only affect the one player.
		P = PlayerController(EventInstigator.Controller);
		if( P==None )
			return;
			
		// Go to music.
		P.ClientSetMusic( Song, Transition );
	}	

	// Turn off if once-only.
	if( bOnceOnly )
	{
		SetCollision(false,false,false);
		disable( 'Trigger' );
	}
}

defaultproperties
{
     Transition=MTRAN_Fade
     bAffectAllPlayers=True
     bObsolete=True
}
