//=============================================================================
//  R61stHandsGripHBS.uc
//=============================================================================
class R61stHandsGripHBS extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripHBSA');
    Super.PostBeginPlay();
}

auto state Waiting {}

state RaiseWeapon
{
    simulated event AnimEnd(int Channel)
    {
        SetDrawType(DT_None);
        Super.AnimEnd(Channel);
    }
}

state BringWeaponUp
{
    simulated event AnimEnd(int Channel)
    {
        SetDrawType(DT_None);
        Super.AnimEnd(Channel);
    }    
}

state DiscardWeapon
{
    simulated function BeginState()
    {
        SetDrawType(DT_Mesh);
        Super.BeginState();
    }    
}

state PutWeaponDown
{
    simulated function BeginState()
    {
        SetDrawType(DT_Mesh);
        Super.BeginState();
    }    
}

defaultproperties
{
     DrawType=DT_None
     Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
