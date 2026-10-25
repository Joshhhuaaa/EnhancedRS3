//===============================================================================
//  [R61stHandsAssaultGalilARM] 
//===============================================================================

class R61stHandsAssaultGalilARM extends R61stHandsGripMP5;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultGalilARMA');
    Super.PostBeginPlay();
}

simulated function SwitchFPAnim()
{
    UnLinkSkelAnim();
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultGalilARMWithScopeA');
    PostBeginPlay();
}

defaultproperties
{
}
