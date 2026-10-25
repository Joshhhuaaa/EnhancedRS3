//=============================================================================
// VoicePack.
//=============================================================================
class VoicePack extends Info
	abstract;
	
/* 
ClientInitialize() sets up playing the appropriate voice segment, and returns a string
 representation of the message
*/
function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex);
function PlayerSpeech(name Type, int Index, int Callsign);

static function byte GetMessageIndex(name PhraseName)
{
	return 0;
}
	

defaultproperties
{
     RemoteRole=ROLE_None
     LifeSpan=10.000000
}
