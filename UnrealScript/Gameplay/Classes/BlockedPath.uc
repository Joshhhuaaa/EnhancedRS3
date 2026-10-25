//=============================================================================
// BlockedPath.
// 
//=============================================================================
class BlockedPath extends NavigationPoint
	placeable;

function Trigger( actor Other, pawn EventInstigator )
{
	bBlocked = !bBlocked;
}

defaultproperties
{
     bBlocked=True
}
