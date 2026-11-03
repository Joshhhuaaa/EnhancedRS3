class MP21stHandsLMGUltimax100 extends R61stHandsLMGM60E4;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stHands_UKX.ukx PACKAGE=MP21stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stHands_UKX.R61stHandsLMGUltimax100A');
    super.PostBeginPlay();
}
