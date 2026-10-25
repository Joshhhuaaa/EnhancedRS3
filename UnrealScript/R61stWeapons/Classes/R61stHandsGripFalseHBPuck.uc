//=============================================================================
//  R61stHandsGripFalseHBPuck.uc
//=============================================================================
class R61stHandsGripFalseHBPuck extends R61stHandsGripGrenade;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsItemFakeHBPuckA');
    Super.PostBeginPlay();
}

state RaiseWeapon
{
    simulated function BeginState()
    {
        //Draw the weapon.
        //log("Animation Begin");
        SetDrawType(DT_Mesh);
        AssociatedWeapon.SetDrawType(DT_Mesh);
        PlayAnim('Begin', R6Pawn(Owner.Owner).ArmorSkillEffect());
    }
}

defaultproperties
{
}
