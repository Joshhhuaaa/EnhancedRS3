//=============================================================================
// MapList.
//
// contains a list of maps to cycle through
//
//=============================================================================
class MapList extends Info
	abstract
    native;

var(Maps) config string Maps[32];
const K_NextDefaultMap = -2;

function string GetNextMap(int iNextMapNum);

defaultproperties
{
}
