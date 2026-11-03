class MP21stHandsAssaultType89f extends R61stHandsGripMP5;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stHands_UKX.ukx PACKAGE=MP21stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stHands_UKX.R61stHandsAssaultType89fA');
    super.PostBeginPlay();
}
