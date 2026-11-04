class R6MP1HVip01 extends R6HostagePawn;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\ASHostage_UKX.ukx PACKAGE=ASHostage_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6CharactersMP1_t.utx PACKAGE=R6CharactersMP1_t

simulated event PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'ASHostage_UKX.HostageAnims');
    super.PostBeginPlay();
}

defaultproperties
{
    Mesh=SkeletalMesh'ASHostage_UKX.Vip'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel367
        KConvulseSpacing=(Min=0.5,Max=2.2)
        KSkeleton="terroskel"
        KStartEnabled=true
        bHighDetailOnly=false
        KLinearDamping=0.5
        KAngularDamping=0.5
        KBuoyancy=1.0
        KVelDropBelowThreshold=50.0
        KFriction=0.6
        KRestitution=0.3
        KImpactThreshold=150.0
        Name="KarmaParamsSkel367"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel367'
    Skins[0]=Texture'R6CharactersMP1_t.vips.MP1_Vip_01'
}
