class R6MP1TMilitant04 extends R6MP1TMilitant02;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6CharactersMP1_t.utx PACKAGE=R6CharactersMP1_t

defaultproperties
{
    m_eTerroType=TTYPE_M2T4
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel379
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
        Name="KarmaParamsSkel379"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel379'
    Skins[0]=Texture'R6CharactersMP1_t.terrorist.MP1_R6TMilitant4'
}
