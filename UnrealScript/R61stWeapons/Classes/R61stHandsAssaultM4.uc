//===============================================================================
//  [R61stHandsAssaultM4] 
//===============================================================================

class R61stHandsAssaultM4 extends R61stHandsGripMP5;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultM4A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
