//===============================================================================
//  [R61stHandsAssaultG36K] 
//===============================================================================

class R61stHandsAssaultG36K extends R61stHandsGripMP5;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultG36KA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
