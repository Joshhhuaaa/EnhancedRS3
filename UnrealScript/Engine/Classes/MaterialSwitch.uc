class MaterialSwitch extends Modifier
	editinlinenew
	hidecategories(Modifier)
	native;


var() int Current;
var() editinline array<Material> Materials;

function Trigger( Actor Other, Actor EventInstigator )
{
	Current++;
	if( Current >= Materials.Length )
		Current = 0;

	Material = Materials[Current];

	if( Material != None )
		Material.Trigger( Other, EventInstigator );
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

defaultproperties
{
}
