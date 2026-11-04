class R61stHandsPistol93R extends R61stHandsGripPistol;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\AS1stHands_UKX.ukx PACKAGE=AS1stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'AS1stHands_UKX.R61stHandsPistol93RA');
    super.PostBeginPlay();
}

defaultproperties
{
    Mesh=SkeletalMesh'AS1stHands_UKX.AS1stHands'
}
