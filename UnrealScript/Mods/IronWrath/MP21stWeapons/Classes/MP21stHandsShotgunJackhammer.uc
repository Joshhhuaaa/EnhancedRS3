class MP21stHandsShotgunJackhammer extends R61stHandsGripShotgun;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stHands_UKX.ukx PACKAGE=MP21stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stHands_UKX.R61stHandsShotgunJackhammerA');
    super.PostBeginPlay();
}
