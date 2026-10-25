//===============================================================================
//  [R61stHandsSubMp5KPDW] 
//===============================================================================

class R61stHandsSubMp5KPDW extends R61stHandsGripAUG;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubMp5KPDWA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
