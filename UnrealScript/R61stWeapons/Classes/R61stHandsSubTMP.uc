//===============================================================================
//  [R61stHandsSubTMP] 
//===============================================================================

class R61stHandsSubTMP extends R61stHandsGripP90;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubTMPA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
