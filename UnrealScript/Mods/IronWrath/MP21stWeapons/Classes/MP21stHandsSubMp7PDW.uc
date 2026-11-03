class MP21stHandsSubMp7PDW extends R61stHandsGripAUG;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP21stHands_UKX.ukx PACKAGE=MP21stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'MP21stHands_UKX.R61stHandsSubMp7PDWA');
    super.PostBeginPlay();
}
