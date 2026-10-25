//===============================================================================
//  [R61stHandsAssaultAK47] 
//===============================================================================

class R61stHandsAssaultAK47 extends R61stHandsGripMP5;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultAK47A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
