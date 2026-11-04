class R61stHandsAssaultOTs14Silenced extends R61stHandsGripUZI;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\AS1stHands_UKX.ukx PACKAGE=AS1stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'AS1stHands_UKX.R61stHandsAssaultOTs14SilencedA');
    super.PostBeginPlay();
}

defaultproperties
{
    Mesh=SkeletalMesh'AS1stHands_UKX.AS1stHands'
}
