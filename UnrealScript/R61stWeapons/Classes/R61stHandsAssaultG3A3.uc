//===============================================================================
//  [R61stHandsAssaultG3A3] 
//===============================================================================

class R61stHandsAssaultG3A3 extends R61stHandsGripMP5;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultG3A3A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
