//===============================================================================
//  [R61stHandsGripLMG] 
//===============================================================================

class R61stHandsGripLMG extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PoStBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripLMGA');
    Super.PostBeginPlay();
}

defaultproperties
{
     DrawType=DT_None
     Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
