class MP2RainbowPilot extends MP2RainbowPawn;

#exec OBJ LOAD FILE=..\Animations\R6Rainbow_UKX.ukx PACKAGE=R6Rainbow_UKX
#exec OBJ LOAD FILE=..\Textures\R6Characters_T.utx PACKAGE=R6Characters_T
#exec OBJ LOAD FILE=..\Textures\R61stWeapons_T.utx PACKAGE=R61stWeapons_T

simulated event PostBeginPlay()
{
    m_bUseSpecialSkin = true;
    super.PostBeginPlay();
}

simulated function SetRainbowFaceTexture()
{
    if(bIsFemale)
    {
        SetFemaleParameters();
        Skins[1] = Texture(DynamicLoadObject("R6Characters_t.Rainbow.R6RPilotHeadF", Class'Engine.Texture'));
        if(m_Helmet != none)
        {
            m_Helmet.DrawScale = 1.0;
        }
        if(m_NightVision != none)
        {
            m_NightVision.DrawScale = 1.1;
        }
    }
}

simulated function AttachNightVision()
{
    super(R6Rainbow).AttachNightVision();
    m_NightVision.SetRelativeLocation(vect(-1.0, -1.0, 0.0));
}

defaultproperties
{
    m_bScaleGasMaskForFemale=false
    m_GasMaskClass=Class'R6Engine.R6PilotGasMask'
    m_NightVisionClass=Class'R6Engine.R6PilotNightVision'
    m_eArmorType=ARMOR_Medium
    m_HelmetClass=Class'R6Characters.R6RPilotHelmet'
    Mesh=SkeletalMesh'R6Rainbow_UKX.PilotMesh'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel442
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
        Name="KarmaParamsSkel442"
    End Object
    KParams=KarmaParamsSkel'MP2Characters.KarmaParamsSkel442'
    Skins[0]=Texture'R6Characters_T.Rainbow.R6RPilot'
    Skins[1]=none
    Skins[2]=none
    Skins[3]=none
    Skins[4]=none
    Skins[5]=Texture'R61stWeapons_T.Hands.R61stHandsGreen'
}
