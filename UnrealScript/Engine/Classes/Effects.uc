//=============================================================================
// Effects, the base class of all gratuitous special effects.
// 
//=============================================================================
class Effects extends Actor;

var() sound 	EffectSound1;

defaultproperties
{
     RemoteRole=ROLE_None
     bNetTemporary=True
     bUnlit=True
     bGameRelevant=True
}
