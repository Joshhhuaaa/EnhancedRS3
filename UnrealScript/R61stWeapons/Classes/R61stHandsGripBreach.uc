//=============================================================================
//  R61stHandsGripBreach.uc : (add small description)
//=============================================================================
class R61stHandsGripBreach extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripBreachA');
    Super.PostBeginPlay();
    m_HandFire='Fire';
}

simulated state FiringWeapon
{
    function AnimEnd(INT iChannel)
    {
        if(iChannel != 0 || (owner == none))
        {
            return;
        }

        if(bShowLog) log("HANDS - EndAnim, goto wait");
        //Play the weapon animation
        AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);

        AnimBlendParams(1, 0);
        R6AbstractWeapon(Owner).FirstPersonAnimOver();
        //Reset the variables for animations
        m_bCanQuitOnAnimEnd=false;
        m_bCannotPlayEmpty=false;
        m_bInBurst=false;
        GotoState('DiscardWeapon');
    }
}

defaultproperties
{
     DrawType=DT_None
     Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
