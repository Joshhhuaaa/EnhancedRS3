//===============================================================================
//  [R61stHandsAssaultFAMASG2] 
//===============================================================================

class R61stHandsAssaultFAMASG2 extends R61stHandsGripUZI;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultFAMASG2A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
