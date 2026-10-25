class Projector extends Actor
	placeable
	native;

#exec Texture Import File=Textures\Proj_IconMasked.pcx Name=Proj_Icon Mips=Off MASKED=1
#exec Texture Import file=Textures\GRADIENT_Fade.tga Name=GRADIENT_Fade Mips=Off UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP
#exec Texture Import file=Textures\GRADIENT_Clip.tga Name=GRADIENT_Clip Mips=Off UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP


// Projector blending operation.

enum EProjectorBlending
{
	PB_None,
	PB_Modulate,
    PB_Modulate1X,
	PB_AlphaBlend,
	PB_Add,
    PB_Darken
};

var() EProjectorBlending	MaterialBlendingOp,		// The blending operation between the material being projected onto and ProjTexture.
							FrameBufferBlendingOp;	// The blending operation between the framebuffer and the result of the base material blend.

// Projector properties.

var() Material	ProjTexture;
var() int		FOV;
var() int		MaxTraceDistance;
var() bool		bProjectBSP;
var() bool		bProjectTerrain;
var() bool		bProjectStaticMesh;
var() bool		bProjectParticles;
var() bool		bProjectActor;
var() bool		bProjectBullet;
var() bool		bLevelStatic;
var() bool		bClipBSP;
var() bool		m_bClipStaticMesh;          //R6CODE - Clip StaticMeshes for speed.
var() bool		m_bRelative;                //R6CODE - Projector is relative to moving actors.
var   bool      m_bDirectionalModulation;   //R6CODE - Don't project on backfacing geometry and fade with angle.
var   bool      m_bProjectTransparent;      //R6CODE - Project on transparent objects.
var   bool      m_bProjectOnlyOnFloor;      //R6CODE - Project only on floor.
var() bool		bProjectOnUnlit;
var() bool		bGradient;
var() bool		bProjectOnAlpha;
var() bool		bProjectOnParallelBSP;
var() bool		bProjectOnlyFirst;
var() name		ProjectTag;
var() Texture	GradientTexture;


// Internal state.

var const transient plane FrustumPlanes[6];
var const transient vector FrustumVertices[8];
var const transient Box Box;
var const transient ProjectorRenderInfoPtr RenderInfo;
var transient Matrix GradientMatrix;
var transient Matrix Matrix;
var transient Vector OldLocation;

//R6SHADOW
var bool bLightInfluenced;

// Native interface.

// functions
native function AttachProjector();
native function DetachProjector(optional bool Force);
native function AbandonProjector(optional float Lifetime);

native function AttachActor( Actor A );
native function DetachActor( Actor A );

event PostBeginPlay()
{
	AttachProjector();
	if( bLevelStatic )
	{
		AbandonProjector();
		Destroy();
	}
	if( bProjectActor )
	{
		SetCollision(True, False, False);
		// GotoState('ProjectActors');  //FIXME - state doesn't exist
	}
}

// fix unprog
simulated event Touch( Actor Other )
{
    if( Other.bAcceptsProjectors && (ProjectTag=='' || Other.Tag==ProjectTag) && (bProjectStaticMesh || Other.StaticMesh == None) )
        AttachActor(Other);
}

event Untouch( Actor Other )
{
	DetachActor(Other);
}

//R6SHADOW
event LightUpdateDirect(vector LightDir, float LightDist, byte bOpacity) 
{
}

event UpdateShadow()
{
}

defaultproperties
{
     FrameBufferBlendingOp=PB_Modulate
     MaxTraceDistance=1000
     bProjectBSP=True
     bProjectTerrain=True
     bProjectStaticMesh=True
     bProjectParticles=True
     bProjectActor=True
     m_bProjectTransparent=True
     GradientTexture=Texture'Engine.GRADIENT_Fade'
     bStatic=True
     bHidden=True
     bDirectional=True
     Texture=Texture'Engine.Proj_Icon'
}
