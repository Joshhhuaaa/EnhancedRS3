class R6MP1TMilitant03 extends R6MP1TMilitant01;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6CharactersMP1_t.utx PACKAGE=R6CharactersMP1_t

defaultproperties
{
    m_eTerroType=TTYPE_M1T3
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel377
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
        Name="KarmaParamsSkel377"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel377'
    Skins[0]=Texture'R6CharactersMP1_t.terrorist.MP1_R6TMilitant3'
}
