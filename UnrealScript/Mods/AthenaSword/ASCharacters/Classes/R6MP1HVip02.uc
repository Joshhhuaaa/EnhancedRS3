class R6MP1HVip02 extends R6MP1HVip01;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\ASHostage_UKX.ukx PACKAGE=ASHostage_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6CharactersMP1_t.utx PACKAGE=R6CharactersMP1_t

simulated event PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'ASHostage_UKX.HostageAnims');
    super.PostBeginPlay();
}

defaultproperties
{
    Mesh=SkeletalMesh'ASHostage_UKX.Vip_02'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel368
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
        Name="KarmaParamsSkel368"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel368'
    Skins[0]=Texture'R6CharactersMP1_t.vips.MP1_Vip_02'
}
