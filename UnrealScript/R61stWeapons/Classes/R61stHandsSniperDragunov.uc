//===============================================================================
//  [R61stHandsSniperDragunov] 
//===============================================================================

class R61stHandsSniperDragunov extends R61stHandsGripSniper;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperDragunovA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
