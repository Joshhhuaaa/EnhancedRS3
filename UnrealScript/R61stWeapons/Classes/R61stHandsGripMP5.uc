//===============================================================================
//  [R61stHandsGripMP5] 
//===============================================================================

class R61stHandsGripMP5 extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripMP5A');
    Super.PostBeginPlay();
}

defaultproperties
{
     DrawType=DT_None
     Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
