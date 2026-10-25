//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================

class StaticMeshActor extends Actor
	native
	placeable;


// JFDUBE: I didn't use the m_i prefix because I wanted it to appear just after Skins in the editor.
var(Display)    INT     SkinsIndex;
// JFDUBE: Approved by Eric, so I don't have to go to jail and pay 25 cents.

//R6MODIFIERS
var(Modifier)	FLOAT	m_fScale;
var(Modifier)	FLOAT	m_fFrequency;
var(Modifier)	FLOAT	m_fNormalScale;
var(Modifier)   FLOAT   m_fMinZero;
var(Modifier)   FLOAT   CullDistanceWave;
var(Modifier)	vector	m_vScalePerAxis;
var(Modifier)   BOOL    m_bWave;
//END R6MODIFIERS

//R6CNEWRENDERERFEATURES
var()           BOOL    m_bBlockCoronas;

var(Tessellation) BOOL  m_bUseTesselletation;
var(Tessellation) FLOAT m_fTesseletationLevel;

defaultproperties
{
     SkinsIndex=255
     m_bBlockCoronas=True
     m_fScale=1.000000
     m_fFrequency=1.000000
     m_fNormalScale=0.100000
     CullDistanceWave=1000.000000
     m_fTesseletationLevel=4.000000
     m_vScalePerAxis=(X=1.000000,Y=1.000000,Z=1.000000)
     DrawType=DT_StaticMesh
     bStatic=True
     bWorldGeometry=True
     bAcceptsProjectors=True
     bShadowCast=True
     bStaticLighting=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bEdShouldSnap=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
}
