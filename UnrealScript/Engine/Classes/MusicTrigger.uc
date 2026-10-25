class MusicTrigger extends Triggers;

var()				string		Song;
var()				float		FadeInTime;
var()				float		FadeOutTime;
var()				bool		FadeOutAllSongs;

var		transient	bool		Triggered;
var 	transient	int			SongHandle;

function Trigger( Actor Other, Pawn EventInstigator )
{
	if( FadeOutAllSongs )
	{
//#ifndef R6SOUND
//		EventInstigator.StopAllMusic( FadeOutTime );
//#endif // R6SOUND
	}
	else
	{
		if( !Triggered )
		{
			Triggered	= true;
//#ifndef R6SOUND
//			SongHandle	= EventInstigator.PlayMusic( Song, FadeInTime );
//#endif // R6SOUND
		}
		else
		{
			Triggered	= false;
			if( SongHandle != 0 )
			{
//#ifndef R6SOUND
//				EventInstigator.StopMusic( SongHandle, FadeOutTime );
//#endif //R6SOUND
			}
			else
			{
				Log("WARNING: invalid song handle");
			}
		}
	}
}

defaultproperties
{
     bCollideActors=False
}
