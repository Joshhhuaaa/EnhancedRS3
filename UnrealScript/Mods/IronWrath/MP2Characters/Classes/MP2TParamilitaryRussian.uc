class MP2TParamilitaryRussian extends R6TerroristPawn;

#exec OBJ LOAD FILE=..\Animations\R6Terrorist_UKX.ukx PACKAGE=R6Terrorist_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2Characters_T.utx PACKAGE=MP2Characters_T

defaultproperties
{
    m_eTerroType=TTYPE_P1T1
    Mesh=SkeletalMesh'R6Terrorist_UKX.ParaMilitary01Mesh'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel470
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
        Name="KarmaParamsSkel470"
    End Object
    KParams=KarmaParamsSkel'MP2Characters.KarmaParamsSkel470'
    Skins[0]=Texture'MP2Characters_T.terrorist.R6TParamilitaryRusse'
}
