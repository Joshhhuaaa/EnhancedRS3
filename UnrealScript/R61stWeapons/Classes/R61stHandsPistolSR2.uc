//===============================================================================
//  [R61stHandsPistolSR2] 
//===============================================================================

class R61stHandsPistolSR2 extends R61stHandsGripSPP;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsPistolSR2A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
