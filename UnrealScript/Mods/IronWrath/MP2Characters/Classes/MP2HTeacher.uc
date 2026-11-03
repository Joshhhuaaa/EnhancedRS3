class MP2HTeacher extends R6HostagePawn;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP2Hostage_UKX.ukx PACKAGE=MP2Hostage_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2Characters_T.utx PACKAGE=MP2Characters_T

defaultproperties
{
    m_standRunForwardName="StandRunForwardFemale"
    m_standWalkForwardName="StandWalkForwardFemale"
    bIsFemale=true
    Mesh=SkeletalMesh'MP2Hostage_UKX.MP2HTeacherMesh'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel441
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
        Name="KarmaParamsSkel441"
    End Object
    KParams=KarmaParamsSkel'MP2Characters.KarmaParamsSkel441'
    Skins[0]=Texture'MP2Characters_T.hostage.MP2HTeacher'
}
