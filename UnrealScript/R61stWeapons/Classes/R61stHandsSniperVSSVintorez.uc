//===============================================================================
//  [R61stHandsSniperVSSVintorez] 
//===============================================================================

class R61stHandsSniperVSSVintorez extends R61stHandsSniperDragunov;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperVSSVintorezA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
