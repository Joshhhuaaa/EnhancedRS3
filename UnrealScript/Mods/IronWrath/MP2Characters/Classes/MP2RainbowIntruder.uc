class MP2RainbowIntruder extends MP2Rainbow;

#exec OBJ LOAD FILE=..\Animations\R6Rainbow_UKX.ukx PACKAGE=R6Rainbow_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP2Rainbow_UKX.ukx PACKAGE=MP2Rainbow_UKX

var MeshAnimation m_MP2RainbowAnims;

simulated event PostBeginPlay()
{
    if((Level.NetMode == NM_DedicatedServer) || Level.NetMode == NM_ListenServer)
    {
        m_iTeam = m_iDefaultTeam;
    }
    if((m_iDefaultTeam == 2) && Level.NetMode != NM_Standalone)
    {
        Skins[0] = Level.RedTeamSkin;
        Skins[1] = Level.RedHeadSkin;
        Skins[2] = Level.RedGogglesSkin;
        Skins[5] = Level.RedHandSkin;
        SetSkin(Level.RedTeamSkin, 0);
        SetSkin(Level.RedHeadSkin, 1);
        SetSkin(Level.RedGogglesSkin, 2);
        SetSkin(Level.RedHandSkin, 5);
        LinkMesh(Level.RedMesh);
        LinkSkelAnim(MeshAnimation'R6Rainbow_UKX.RainbowAnim');
        LinkSkelAnim(m_MP2RainbowAnims);
    }
    super(R6Rainbow).PostBeginPlay();
}

defaultproperties
{
    m_MP2RainbowAnims=MeshAnimation'MP2Rainbow_UKX.MP2RainbowAnim'
    m_eArmorType=ARMOR_Medium
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel444
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
        Name="KarmaParamsSkel444"
    End Object
    KParams=KarmaParamsSkel'MP2Characters.KarmaParamsSkel444'
}
