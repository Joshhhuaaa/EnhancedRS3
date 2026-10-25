class ACTION_PlaySound extends ScriptedAction;

var(Action)		sound	Sound;
var(Action)		float	Volume;
var(Action)		float	Pitch;
var(Action)		bool	bAttenuate;

function bool InitActionFor(ScriptedController C)
{
	// play appropriate sound

//R6CODE        
//    if ( Sound != None )
//		C.GetSoundSource().PlaySound(Sound,SLOT_Interact,Volume,true,,Pitch,bAttenuate);
//END R6CODE        
	return false;	
}

function string GetActionString()
{
	return ActionString@Sound;
}

defaultproperties
{
     bAttenuate=True
     Volume=1.000000
     Pitch=1.000000
     ActionString="play sound"
}
