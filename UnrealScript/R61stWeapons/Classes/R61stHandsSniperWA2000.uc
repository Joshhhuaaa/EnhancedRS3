//===============================================================================
//  [R61stHandsSniperWA2000] 
//===============================================================================

class R61stHandsSniperWA2000 extends R61stHandsGripSniper;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperWA2000A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
