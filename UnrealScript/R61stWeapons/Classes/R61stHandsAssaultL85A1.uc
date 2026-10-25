//===============================================================================
//  [R61stHandsAssaultL85A1] 
//===============================================================================

class R61stHandsAssaultL85A1 extends R61stHandsGripUZI;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultL85A1A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
