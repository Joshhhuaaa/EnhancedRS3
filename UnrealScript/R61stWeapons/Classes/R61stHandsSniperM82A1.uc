//===============================================================================
//  [R61stHandsSniperM82A1] 
//===============================================================================

class R61stHandsSniperM82A1 extends R61stHandsSniperDragunov;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperM82A1A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
