//===============================================================================
//  [R61stHandsAssaultTAR21] 
//===============================================================================

class R61stHandsAssaultTAR21 extends R61stHandsGripMP5;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultTAR21A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
