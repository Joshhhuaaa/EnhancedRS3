//=============================================================================
// Material: Abstract material class
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Material extends Object
	native
	hidecategories(Object)
	collapsecategories
	noexport;

//R6MATERIAL
enum ESurfaceType
{
    SURF_Generic,
    SURF_GenericHardSurface,
    SURF_DustyConcrete,
    SURF_CompactSnow,
    SURF_DeepSnow,
    SURF_Dirt,
    SURF_HardWood,
    SURF_BoomyWood,
    SURF_Carpet,
    SURF_Grate,
    SURF_HardMetal,
    SURF_SheetMetal,
    SURF_WaterPuddle,
    SURF_DeepWater,
    SURF_OilPuddle,
    SURF_DirtyGrass,
    SURF_CleanGrass,
    SURF_Gravel
}; 

#exec Texture Import File=Textures\DefaultTexture.pcx

var() Material FallbackMaterial;

var Material DefaultMaterial;
var const transient bool UseFallback;	// Render device should use the fallback.
var const transient bool Validated;		// Material has been validated as renderable.

//#ifdef R6CODE
var(Rainbow)    bool                m_bForceNoSort;
var(Rainbow)    bool                m_bDynamicMaterial;
var(Rainbow)    bool                m_bProneTrail;
var             INT                 m_SpecificRenderData;
//#endif R6CODE

//#ifdef R6MATERIAL
var (Rainbow)   INT                 m_iPenetration;
var (Rainbow)   INT                 m_iResistanceFactor;
var (Rainbow)   class<R6WallHit>    m_pHitEffect;
var (Rainbow)   class<R6FootStep>   m_pFootStep;
var (Rainbow)   ESurfaceType        m_eSurfIdForSnd;
var             Material            m_pUnused;  // not able to remove it
var (Rainbow)   BYTE                m_iNightVisionFactor;
//#endif R6MATERIAL

function Trigger( Actor Other, Actor EventInstigator )
{
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

defaultproperties
{
     DefaultMaterial=Texture'Engine.DefaultTexture'
     m_iNightVisionFactor=128
}
