class MP2ColdThunderA1 extends R6TerroristPawn;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP2Terrorist_UKX.ukx PACKAGE=MP2Terrorist_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2Characters_T.utx PACKAGE=MP2Characters_T

defaultproperties
{
    m_eTerroType=TTYPE_T1T1
    Mesh=SkeletalMesh'MP2Terrorist_UKX.MP2TColdThunderAMesh'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel449
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
        Name="KarmaParamsSkel449"
    End Object
    KParams=KarmaParamsSkel'MP2Characters.KarmaParamsSkel449'
    Skins[0]=Texture'MP2Characters_T.terrorist.MP2ColdThunderA1'
}
