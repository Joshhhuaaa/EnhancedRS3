//===============================================================================
//  [R61stHandsPistolMac119] 
//===============================================================================

class R61stHandsPistolMac119 extends R61stHandsGripSPP;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsPistolMac119A');
    super.PostBeginPlay();
}

defaultproperties
{
}
