class R6TextureTrigger extends Trigger;

var (R6Trigger) Actor ActorToChange;
var (R6Trigger) array<Material> Skins;

function Touch( actor Other )
{
	local INT iSkinCount;

	Super.Touch(Other);
	if (ActorToChange != None)
	{
		for (iSkinCount = 0; iSkinCount < Skins.Length; iSkinCount++)
		{
			ActorToChange.Skins[iSkinCount] = Skins[iSkinCount];
		}
	}
}

defaultproperties
{
}
