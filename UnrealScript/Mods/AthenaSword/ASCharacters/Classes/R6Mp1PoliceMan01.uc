class R6Mp1PoliceMan01 extends R6HostagePawn;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Animations\ASHostage_UKX.ukx PACKAGE=ASHostage_UKX
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6CharactersMP1_t.utx PACKAGE=R6CharactersMP1_t

simulated event PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'ASHostage_UKX.HostageAnims');
    super.PostBeginPlay();
}

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
    Query.iHasAction = 0;
}

defaultproperties
{
    m_bPoliceManMp1=true
    m_bEscorted=true
    m_NocsWaitingName="StandWaitShiftWeight"
    Mesh=SkeletalMesh'ASHostage_UKX.StreetPolicemanITA'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel369
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
        Name="KarmaParamsSkel369"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel369'
    Skins[0]=Texture'R6CharactersMP1_t.policeman.MP1_policeman01'
}
