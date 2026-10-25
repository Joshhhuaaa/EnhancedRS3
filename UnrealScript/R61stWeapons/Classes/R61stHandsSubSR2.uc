//===============================================================================
//  [R61stHandsSubSR2] 
//===============================================================================

class R61stHandsSubSR2 extends R61stHandsGripSPP;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubSR2A');
    Super.PostBeginPlay(); // RECYCLING ANIMS FROM R61stHandsPistolSR2
}

defaultproperties
{
}
