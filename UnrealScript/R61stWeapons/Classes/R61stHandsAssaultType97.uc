//===============================================================================
//  [R61stHandsAssaultType97] 
//===============================================================================

class R61stHandsAssaultType97 extends R61stHandsGripP90;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultType97A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
