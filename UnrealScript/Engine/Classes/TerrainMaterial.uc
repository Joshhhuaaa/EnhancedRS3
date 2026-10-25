class TerrainMaterial extends RenderedMaterial
	native
	noteditinlinenew;


struct native TerrainMaterialLayer
{
	var material		Texture;
	var bitmapmaterial	AlphaWeight;
	var matrix			TextureMatrix;
};

var const array<TerrainMaterialLayer> Layers;
var const byte RenderMethod;
var const bool FirstPass;

defaultproperties
{
}
