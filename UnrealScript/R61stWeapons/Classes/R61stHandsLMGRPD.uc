//===============================================================================
//  [R61stHandsLMGRPD] 
//===============================================================================

class R61stHandsLMGRPD extends R61stHandsGripLMG;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsLMGRPDA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
