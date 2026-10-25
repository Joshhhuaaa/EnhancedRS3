//===============================================================================
//  [R61stHandsSubM12S] 
//===============================================================================

class R61stHandsSubM12S extends R61stHandsGripAUG;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubM12SA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
