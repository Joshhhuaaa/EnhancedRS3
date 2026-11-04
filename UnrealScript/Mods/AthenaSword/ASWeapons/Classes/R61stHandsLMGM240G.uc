class R61stHandsLMGM240G extends R61stHandsGripLMG;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\AS1stHands_UKX.ukx PACKAGE=AS1stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'AS1stHands_UKX.R61stHandsLMGM240GA');
    super.PostBeginPlay();
}

defaultproperties
{
    Mesh=SkeletalMesh'AS1stHands_UKX.AS1stHands'
}
