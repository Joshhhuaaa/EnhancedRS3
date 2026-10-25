//===============================================================================
//  [R61stHandsSubMTAR21] 
//===============================================================================

class R61stHandsSubMTAR21 extends R61stHandsGripP90;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubMTAR21A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
