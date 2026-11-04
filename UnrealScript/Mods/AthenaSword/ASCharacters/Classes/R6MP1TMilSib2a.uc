class R6MP1TMilSib2a extends R6TerroristPawn;

#exec OBJ LOAD FILE=..\Animations\R6Terrorist_UKX.ukx PACKAGE=R6Terrorist_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6CharactersMP1_t.utx PACKAGE=R6CharactersMP1_t

defaultproperties
{
    m_eTerroType=TTYPE_M2T2
    Mesh=SkeletalMesh'R6Terrorist_UKX.Militant02Mesh'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel380
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
        Name="KarmaParamsSkel380"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel380'
    Skins[0]=Texture'R6CharactersMP1_t.terrorist.MP1_R6TMilSib2a'
}
