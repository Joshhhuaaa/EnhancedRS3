//===============================================================================
//  [R61stHandsAssaultM14] 
//===============================================================================

class R61stHandsAssaultM14 extends R61stHandsGripMP5;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultM14A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
