class MP2RainbowPawn extends MP2Rainbow
    abstract;

#exec OBJ LOAD FILE=..\Animations\R6Rainbow_UKX.ukx PACKAGE=R6Rainbow_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP2Rainbow_UKX.ukx PACKAGE=MP2Rainbow_UKX

var MeshAnimation m_MP2RainbowAnims;

simulated event PostBeginPlay()
{
    if((Level.NetMode == NM_DedicatedServer) || Level.NetMode == NM_ListenServer)
    {
        m_iTeam = m_iDefaultTeam;
    }
    if(m_bUseSpecialSkin == false)
    {
        if((m_iDefaultTeam == 3) && Level.NetMode != NM_Standalone)
        {
            Skins[0] = Level.RedTeamSkin;
            Skins[1] = Level.RedHeadSkin;
            Skins[2] = Level.RedGogglesSkin;
            Skins[5] = Level.RedHandSkin;
            LinkMesh(Level.RedMesh);
        }
        else
        {
            Skins[0] = Level.GreenTeamSkin;
            Skins[1] = Level.GreenHeadSkin;
            Skins[2] = Level.GreenGogglesSkin;
            Skins[5] = Level.GreenHandSkin;
            LinkMesh(Level.GreenMesh);
        }
    }
    LinkSkelAnim(MeshAnimation'R6Rainbow_UKX.RainbowAnim');
    LinkSkelAnim(m_MP2RainbowAnims);
    super(R6Rainbow).PostBeginPlay();
}

defaultproperties
{
    m_MP2RainbowAnims=MeshAnimation'MP2Rainbow_UKX.MP2RainbowAnim'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel295
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
        Name="KarmaParamsSkel295"
    End Object
    KParams=KarmaParamsSkel'MP2Game.KarmaParamsSkel295'
}
