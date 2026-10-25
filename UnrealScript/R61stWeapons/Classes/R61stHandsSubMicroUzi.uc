//===============================================================================
//  [R61stHandsSubMicroUzi] 
//===============================================================================

class R61stHandsSubMicroUzi extends R61stHandsPistolMicroUzi;  
// NOTE: RECYCLING anims form R61stHandsPistolMicroUzi

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubMicroUziA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
