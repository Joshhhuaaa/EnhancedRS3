//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Animation / Mesh editor object to expose/shuttle only selected editable 
//  parameters from UMeshAnim/ UMesh objects back and forth in the editor.
//  
 
class MeshEditProps extends Object
	hidecategories(Object)
	native;	


struct native LODLevel
{
	var() float   DistanceFactor;
	var() float   ReductionFactor;	
	var() float   Hysteresis;
	var() int     MaxInfluences;
	var() bool    SwitchRedigest;
};

var const int WBrowserAnimationPtr;
var(Mesh) vector			 Scale;
var(Mesh) vector             Translation;
var(Mesh) rotator            Rotation;
var(Mesh) vector             MinVisBound;
var(Mesh) vector			 MaxVisBound;
var(Mesh) vector             VisSphereCenter;
var(Mesh) float              VisSphereRadius;

var(Redigest) int            LODStyle; //Make drop-down box w. styles...
var(Animation) MeshAnimation DefaultAnimation;

var(Skin) array<Material>					Material;

// To be implemented: - material order specification to re-sort the sections (for multiple translucent materials )
// var(RenderOrder) array<int>					MaterialOrder;
// To be implemented: - originalmaterial names from Maya/Max
// var(OriginalMaterial) array<name>			OrigMat;

var(LOD) float            LOD_Strength;
var(LOD) array<LODLevel>  LODLevels;

defaultproperties
{
     Scale=(X=1.000000,Y=1.000000,Z=1.000000)
}
