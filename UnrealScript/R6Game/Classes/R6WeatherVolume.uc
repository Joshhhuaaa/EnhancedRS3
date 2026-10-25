/********************************************************************
	created:	2001/06/19
	filename: 	R6WeatherVolume.uc
	author:		Jean-Francois Dube
*********************************************************************/

class R6WeatherVolume extends R6SoundVolume;

event Touch(Actor Other)
{
    Other.m_bInWeatherVolume++;
}

event Untouch(Actor Other)
{
    Other.m_bInWeatherVolume--;
}

defaultproperties
{
}
