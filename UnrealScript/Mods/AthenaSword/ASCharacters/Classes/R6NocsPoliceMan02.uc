class R6NocsPoliceMan02 extends R6HostagePawn;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\ASHostage_UKX.ukx PACKAGE=ASHostage_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\ItaPolice_T.utx PACKAGE=ItaPolice_T

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
    Query.iHasAction = 0;
}

simulated event PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'ASHostage_UKX.HostageAnims');
    super.PostBeginPlay();
}

defaultproperties
{
    m_bPoliceManMp1=true
    m_bPoliceManHasWeapon=true
    m_bPoliceManCanSeeRainbows=true
    m_bEscorted=true
    m_NocsWaitingName="CrouchHandWhaitDown"
    m_NocsSeeRainbowsName="CrouchHandRainbowDown"
    Mesh=SkeletalMesh'ASHostage_UKX.PoliceManIta'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel371
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
        Name="KarmaParamsSkel371"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel371'
    Skins[0]=Texture'ItaPolice_T.R6RGoggles'
    Skins[1]=Texture'ItaPolice_T.R6RPoliceIta'
    Skins[2]=Texture'ItaPolice_T.R6RPoliceItaHead'
    Skins[3]=Texture'ItaPolice_T.R6RPoliceItaEyes'
}
