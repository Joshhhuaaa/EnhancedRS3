//===============================================================================
//  [R61stHandsSubMac119] 
//===============================================================================

class R61stHandsSubMac119 extends R61stHandsGripSPP;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubMac119A');
    Super.PostBeginPlay();
}

defaultproperties
{
}
