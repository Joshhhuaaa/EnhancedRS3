//=============================================================================
// SpecialEventTrigger: Receives trigger messages and does some "special event"
// some combination of a message, sound playing, damage, and/or death to the instigator
// if the event of this actor is set, will try to send player on the interpolation path
// with tag matching this event.
//=============================================================================
class SpecialEventTrigger extends Triggers;

#exec Texture Import File=..\engine\Textures\TrigSpcl.pcx Name=S_SpecialEvent Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Variables.

var() int        Damage;         // how much to damage triggering actor
var() sound      Sound;          // if not none, this sound effect will be played
var() localized  string Message; // message to display
var() bool       bBroadcast;     // To broadcast the message to all players.
var() bool		 bPlayerJumpToInterpolation;	// if true, player is teleported to start of interpolation path
var() bool		 bPlayersPlaySoundEffect;		// if true, have sound effect played at players' location
var() bool		 bKillInstigator;	// if true, kill the instigator
var() bool		 bViewTargetInterpolatedActor;	// if true, playercontroller viewtargets the interpolated actor
var() bool		 bThirdPersonViewTarget;		// if true, playercontroller third person views the interpolated actor
var() name		 InterpolatedActorTag;	// tag of actor to send on interpolation path (if none, then instigator is used)
var() name		 PlayerScriptTag;		// tag of scripted sequence to put player's pawn while player is viewtargeting another actor

//-----------------------------------------------------------------------------
// Functions.

function Trigger( actor Other, pawn EventInstigator )
{
	local PlayerController P;
	local InterpolationPoint i;
	local ScriptedSequence S;
	local ScriptedController C;
	local Actor A;

	if ( Len(Message) != 0 )
	{
		if( bBroadcast )
			Level.Game.Broadcast(EventInstigator, Message, 'CriticalEvent'); // Broadcast message to all players.
		else if( (len(Message)!=0) && (EventInstigator != None) )
			EventInstigator.ClientMessage( Message ); // Send message to instigator only.
	}

//R6CODE        
    if ( Sound != None )
	{
		if ( bPlayersPlaySoundEffect )
		{
			ForEach DynamicActors(class'PlayerController', P)
				P.ClientPlaySound(Sound, SLOT_SFX);
		}
		else
			PlaySound( Sound, SLOT_SFX);
	}
//END R6CODE        

	if ( Damage > 0 )
		Other.R6TakeDamage( Damage, Damage, EventInstigator, EventInstigator.Location, Vect(0,0,0), 0);

	if ( EventInstigator == None )
		return;

	if ( AmbientSound != None )
		EventInstigator.AmbientSound = AmbientSound;

	if ( bKillInstigator )
		EventInstigator.Died( None, EventInstigator.Location );

	if( (Event != 'None') && (Event != '') && (Level.NetMode == NM_Standalone) )
	{
		if ( (InterpolatedActorTag == 'None') || (InterpolatedActorTag == '') )
		{
			if ( EventInstigator.IsPlayerPawn() )
			{
				A = EventInstigator;
				if ( A.bInterpolating )
					return;
			}
			else
				return;
		}
		else
		{
			ForEach DynamicActors( class'Actor', A, InterpolatedActorTag )
				break;
			if ( (A == None) || A.bInterpolating )
				return;
			if ( bViewTargetInterpolatedActor && EventInstigator.IsHumanControlled() )
			{
				PlayerController(EventInstigator.Controller).SetViewTarget(A);
				PlayerController(EventInstigator.Controller).bBehindView = bThirdPersonViewTarget;
				if ( PlayerScriptTag != 'None' )
				{
					ForEach DynamicActors( class'ScriptedSequence', S, PlayerScriptTag )
						break;
					if ( S != None )
					{
						EventInstigator.Controller.Pawn = None;
						PlayerController(EventInstigator.Controller).GotoState('Spectating');
						S.TakeOver(EventInstigator);
					}
				}
			}				
		}
		//*WDM*
		//ForEach AllActors( class 'InterpolationPoint',i, Event )
		//	if( i.Position == 0 )
		//	{
		//		A.StartInterpolation(i.next, bPlayerJumpToInterpolation);
		//		if ( AmbientSound != None )
		//			A.AmbientSound = AmbientSound;
		//		break;
		//	}
	}
}

defaultproperties
{
     bPlayerJumpToInterpolation=True
     Texture=Texture'Gameplay.S_SpecialEvent'
}
