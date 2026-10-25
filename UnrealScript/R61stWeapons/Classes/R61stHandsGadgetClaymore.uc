//=============================================================================
//  R61stHandsGadgetClaymore.uc
//=============================================================================
class R61stHandsGadgetClaymore extends R61stHandsGripC4;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsItemFakeHBPuckA');
    Super.PostBeginPlay();
}

defaultproperties
{
}
