class CriticalEventPlus extends LocalMessagePlus;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY;
}

defaultproperties
{
     FontSize=1
     Lifetime=3
     bIsSpecial=True
     bIsUnique=True
     bFadeMessage=True
     bBeep=True
     bCenter=True
     YPos=196.000000
     DrawColor=(G=128,R=0)
}
