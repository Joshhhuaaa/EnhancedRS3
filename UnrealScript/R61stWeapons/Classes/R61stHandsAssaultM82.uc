//===============================================================================
//  [R61stHandsAssaultM82] 
//===============================================================================

class R61stHandsAssaultM82 extends R61stHandsGripUZI;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultM82A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
