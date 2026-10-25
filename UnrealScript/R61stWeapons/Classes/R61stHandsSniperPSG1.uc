//===============================================================================
//  [R61stHandsSniperPSG1] 
//===============================================================================

class R61stHandsSniperPSG1 extends R61stHandsGripSniper;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperPSG1A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
