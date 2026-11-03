class MP2RainbowHeavy extends MP2RainbowPawn;

#exec OBJ LOAD FILE=..\Animations\R6Rainbow_UKX.ukx PACKAGE=R6Rainbow_UKX
#exec OBJ LOAD FILE=..\Textures\R6Characters_T.utx PACKAGE=R6Characters_T
#exec OBJ LOAD FILE=..\Textures\R61stWeapons_T.utx PACKAGE=R61stWeapons_T

defaultproperties
{
    m_HelmetClass=Class'R6Characters.R6RHeavyHelmet'
    Mesh=SkeletalMesh'R6Rainbow_UKX.HeavyMesh'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel296
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
        Name="KarmaParamsSkel296"
    End Object
    KParams=KarmaParamsSkel'MP2Game.KarmaParamsSkel296'
    Skins[0]=Texture'R6Characters_T.Rainbow.R6RHeavy'
    Skins[1]=Texture'R6Characters_T.Rainbow.R6RHeavyMedHead'
    Skins[2]=FinalBlend'R6Characters_T.Rainbow.R6RGogglesFB'
    Skins[3]=none
    Skins[4]=none
    Skins[5]=Texture'R61stWeapons_T.Hands.R61stHands'
}
