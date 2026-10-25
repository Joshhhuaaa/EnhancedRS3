class R6MorphMeshActor extends Actor
    native
    placeable;

enum EMvtStat
{
    Mvt_None,
    Mvt_Wait,
    Mvt_Simple,
    Mvt_Loop,
    Mvt_Random,
    Mvt_End
};

var(MP2Movement) EMvtStat MvtStat;
var(Display) int SkinsIndex;
var int b_sensMorph;
var(MP2Morphing) bool m_bMorph;
var() bool m_bBlockCoronas;
var(MP2Morphing) float MorphDeltaAlpha;
var float MorphAlpha;
var(MP2Morphing) StaticMesh MorphMesh;

event PreBeginPlay()
{
    Super.PreBeginPlay();
    MorphAlpha = 0;
    m_bMorph = false;
    if ( bDeleteMe )
        return;
}

function Tick(float DeltaTime);

function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, vector vHitLocation, vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
    local int iDamage;

    iDamage = Super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);
    log("-------------------  morph -------" $ iDamage);
    if ( MvtStat == Mvt_Wait )
    {
        if ( MorphMesh != None )
        {
            b_sensMorph = 1;
            m_bMorph = true;
            MorphAlpha = 0;
            MvtStat = Mvt_Simple;
        }
    }
    return iDamage;
}

defaultproperties
{
     SkinsIndex=255
     m_bBlockCoronas=True
     DrawType=DT_StaticMesh
     bWorldGeometry=True
     bAcceptsProjectors=True
     m_bHandleRelativeProjectors=True
     bShadowCast=True
     bStaticLighting=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bEdShouldSnap=True
     m_bForceStaticLighting=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
}
