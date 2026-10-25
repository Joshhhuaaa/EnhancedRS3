//=============================================================================
// ShadowProjector.
//=============================================================================
class ShadowProjector extends Projector
	placeable;

var()   Actor					ShadowActor;
var()   vector				    LightDirection;
var()   float					LightDistance;
var     ShadowBitmapMaterial	ShadowTexture;
var()   bool                    bUseLightAverage;
var     byte                    m_bOpacity;
var     bool                    m_bAttached;

simulated event PostBeginPlay()
{
	if(bProjectActor)
		SetCollision(true, false, false);

    ShadowTexture = new(none) class'ShadowBitmapMaterial';
    ProjTexture   = ShadowTexture;
}

event UpdateShadow()
{
    local vector	ShadowLocation;
    local Plane	    BoundingSphere;

    if(bProjectActor)
        SetCollision(false, false, false);

    if(ShadowActor != none && !ShadowActor.bHidden && m_bOpacity > 0)
    {
        BoundingSphere = ShadowActor.GetRenderBoundingSphere();
        BoundingSphere.W *= 4.0f;
        FOV = Atan(BoundingSphere.W * 2 / LightDistance) * 180 / PI + 5;

        if(ShadowActor.DrawType == DT_Mesh && ShadowActor.Mesh != none)
            ShadowLocation = ShadowActor.GetBoneCoords('R6 Pelvis', true).Origin;
        else
            ShadowLocation = ShadowActor.Location;

        ShadowTexture.m_LightLocation = ShadowLocation;

        SetLocation(ShadowLocation);
        SetRotation(Rotator(-LightDirection));
        SetDrawScale(LightDistance * tan(0.5 * FOV * PI / 180) / (0.5 * ShadowTexture.USize));

        ShadowTexture.ShadowActor    = ShadowActor;
        ShadowTexture.LightDirection = LightDirection;
        ShadowTexture.LightDistance  = LightDistance;
        ShadowTexture.LightFOV       = FOV;
        ShadowTexture.Dirty          = true;
        ShadowTexture.m_bOpacity     = m_bOpacity;

        AttachProjector();
        m_bAttached = true;

        if(bProjectActor)
            SetCollision(true, false, false);
    }
}

simulated function Tick(float DeltaTime)
{
    if(m_bAttached)
    {
        m_bAttached = false;
        DetachProjector(true);
    }
}

event Touch(Actor Other)
{
    if (Other != ShadowActor && Other.bAcceptsProjectors && bProjectActor)
	    AttachActor(Other);
}

simulated function LightUpdateDirect(vector LightDir, float LightDist, byte bOpacity) 
{
    LightDistance  = LightDist;
    LightDirection = LightDir;
    m_bOpacity     = bOpacity;
}

simulated event Destroyed()
{
    if(ShadowTexture!=none)
        ShadowTexture.ShadowActor = none;
}

defaultproperties
{
     m_bOpacity=128
     bUseLightAverage=True
     FrameBufferBlendingOp=PB_Modulate1X
     MaxTraceDistance=250
     bProjectParticles=False
     bProjectActor=False
     m_bDirectionalModulation=True
     m_bProjectTransparent=False
     bGradient=True
     bProjectOnParallelBSP=True
     bLightInfluenced=True
     RemoteRole=ROLE_None
     bStatic=False
     CullDistance=3500.000000
}
