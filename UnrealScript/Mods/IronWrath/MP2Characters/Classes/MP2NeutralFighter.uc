class MP2NeutralFighter extends MP2Rainbow;

#exec OBJ LOAD FILE=..\Animations\R6Rainbow_UKX.ukx PACKAGE=R6Rainbow_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\Animations\MP2Rainbow_UKX.ukx PACKAGE=MP2Rainbow_UKX
#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2Characters_T.utx PACKAGE=MP2Characters_T
#exec OBJ LOAD FILE=..\Textures\R61stWeapons_T.utx PACKAGE=R61stWeapons_T

var MeshAnimation m_MP2RainbowAnims;

simulated function SetRainbowFaceTexture()
{
}

simulated event PostNetBeginPlay()
{
    LinkMesh(SkeletalMesh'R6Rainbow_UKX.PilotMesh');
    LinkSkelAnim(MeshAnimation'R6Rainbow_UKX.RainbowAnim');
    super.PostNetBeginPlay();
}

defaultproperties
{
    m_MP2RainbowAnims=MeshAnimation'MP2Rainbow_UKX.MP2RainbowAnim'
    m_eArmorType=ARMOR_None
    m_iTeam=7
    Mesh=SkeletalMesh'R6Rainbow_UKX.PilotMesh'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel443
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
        Name="KarmaParamsSkel443"
    End Object
    KParams=KarmaParamsSkel'MP2Characters.KarmaParamsSkel443'
    Skins[0]=Texture'MP2Characters_T.NeutralFighter.NeutralFighterN3'
    Skins[1]=none
    Skins[2]=none
    Skins[3]=none
    Skins[4]=none
    Skins[5]=Texture'R61stWeapons_T.Hands.R61stHands'
}
