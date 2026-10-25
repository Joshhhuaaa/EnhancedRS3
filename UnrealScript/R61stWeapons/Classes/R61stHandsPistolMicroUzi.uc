//===============================================================================
//  [R61stHandsPistolMicroUzi] 
//===============================================================================

class R61stHandsPistolMicroUzi extends R61stHandsGripPistol;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsPistolMicroUziA');
    super.PostBeginPlay();
}

defaultproperties
{
}
