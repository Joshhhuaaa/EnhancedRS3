class MaterialTrigger extends Triggers;

#exec Texture Import File=Textures\MaterialTrigger.pcx Name=S_MaterialTrigger Mips=Off MASKED=1

var() array<Material> MaterialsToTrigger;

function Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;
	for( i=0;i<MaterialsToTrigger.Length;i++ )
	{
		if( MaterialsToTrigger[i] != None )
			MaterialsToTrigger[i].Trigger( Other, EventInstigator );
	}
}

defaultproperties
{
     bCollideActors=False
     Texture=Texture'Engine.S_MaterialTrigger'
}
