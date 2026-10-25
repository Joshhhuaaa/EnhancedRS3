//=============================================================================
//  R61stHandsGripC4.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/05 * Created by Rima Brek
//=============================================================================
class R61stHandsGripC4 extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripC4A');
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
        GotoState('DiscardWeaponAfterFire');
    }
}


state DiscardWeaponAfterFire
{
    function  Timer()
    {
        R6AbstractWeapon(Owner).FirstPersonAnimOver();
    }

    simulated event AnimEnd(int Channel)
    {
        if(bShowLog)log("IN:"@self@"::DiscardWeaponAfterFire::AnimEnd()");
		if(Owner == none)
			return;
		
        if(Channel == 0)
        {
            //Hide this weapon.
            SetDrawType(DT_None);
            SetTimer(R6AbstractWeapon(Owner).m_fPauseWhenChanging, false);
        }
        if(bShowLog)log("OUT:"@self@"::DiscardWeaponAfterFire::AnimEnd()");
    }

    simulated function BeginState()
    {
        if(bShowLog)log("IN:"@self@"::DiscardWeaponAfterFire::BeginState()");
        PlayAnim('FireEmpty', R6Pawn(Owner.Owner).ArmorSkillEffect());
        if(bShowLog)log("OUT:"@self@"::DiscardWeaponAfterFire::BeginState()");
    }
}

state DiscardWeapon
{
    function Timer()
    {
        R6AbstractWeapon(Owner).FirstPersonAnimOver();
    }

    simulated event AnimEnd(int Channel)
    {
        if(bShowLog)log("HANDS - "$self$" -  "$self$" -   IN:"@self@"::DiscardWeapon::AnimEnd()");
        if(Owner == none)
            return;

        if(Channel == 0)
        {
            SetDrawType(DT_None);
            SetTimer(R6AbstractWeapon(Owner).m_fPauseWhenChanging, false);
        }
    }

    simulated function BeginState()
    {
        if(bShowLog)log("HANDS - "$self$" -  IN:"@self@"::DiscardWeapon::BeginState()");
        Owner.Owner.PlaySound(R6AbstractWeapon(Owner).m_UnEquipSnd, SLOT_SFX);
        PlayAnim('End', R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration);
    }
}

defaultproperties
{
     DrawType=DT_None
     Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
