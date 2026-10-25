//===============================================================================
//  [R61stHandsSubCZ61] 
//===============================================================================

class R61stHandsSubCZ61 extends R61stHandsGripP90;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubCZ61A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
