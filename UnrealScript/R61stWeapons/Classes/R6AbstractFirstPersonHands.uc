//===============================================================================
//  [R6AbstractFirstPersonHands] 
//===============================================================================

class R6AbstractFirstPersonHands extends R6AbstractFirstPersonWeapon 
    abstract;

var R6AbstractFirstPersonWeapon     AssociatedWeapon;
var R6AbstractGadget				AssociatedGadget;
var BOOL                            m_bPlayWaitAnim;        // hands are playing a waiting anim
var BOOL                            m_bCanQuitOnAnimEnd;    // once this animation calls anim end qe can quit the state
var BOOL                            m_bCannotPlayEmpty;     // If this is false, fireEmpty does not do anything
var BOOL                            m_bInBurst;             // this is true while the hands are firing a burst
var BOOL                            m_bBipodDeployed;       // use weapon bipod animation
var BOOL                            bShowLog;
var BOOL                            bPlayerWalking;

var FLOAT                           m_fAnimAcceleration;

var (R6HandAnimation)name m_HandFire;
var (R6HandAnimation)name m_HandFireLast;
var (R6HandAnimation)name m_HandBipodFire;
var (R6HandAnimation)name m_HandReloadEmpty;
var (R6HandAnimation)name m_HandBipodReloadEmpty;
var (R6HandAnimation)name m_WaitAnim1;
var (R6HandAnimation)name m_WaitAnim2;
var (R6HandAnimation)name m_WalkAnim;

function PostBeginPlay()
{
    if(!HasAnim('Fire'))
    {
        m_HandFire = 'Neutral';
    }
    if(!HasAnim('FireLast'))
    {
        m_HandFireLast = m_HandFire;
    }

    if(!HasAnim('BipodFire'))
    {
        m_HandBipodFire=m_HandFire;
    }
    
    if(!HasAnim('ReloadEmpty'))
    {
        m_HandReloadEmpty = 'Reload';
    }
    if(!HasAnim('BipodReloadEmpty'))
    {
        m_HandBipodReloadEmpty = 'BipodReload';
    }

    if(!HasAnim('Wait01'))
    {
        m_WaitAnim1 = 'Wait_c';
    }
    if(!HasAnim('Wait02'))
    {
        m_WaitAnim2 = m_WaitAnim1;
    }
    if(!HasAnim('walk_c'))
    {
        m_WalkAnim = 'Wait_c';
    }

    Super.PostBeginPlay();
}

function ResetNeutralAnim()
{
    AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_Neutral;
    AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);
}

function PlayWalkingAnimation()
{
    if(IsInState('Waiting'))
    {
        LoopAnim(m_WalkAnim);
    }
    bPlayerWalking=true;
}

function StopWalkingAnimation()
{
    if(IsInState('Waiting'))
    {
        LoopAnim('Wait_c');
    }
    bPlayerWalking=false;
}

simulated function SetAssociatedWeapon(R6AbstractFirstPersonWeapon AWeapon)
{
    AssociatedWeapon = AWeapon;
}

simulated function SetAssociatedGadget(R6AbstractGadget AGadget)
{
	AssociatedGadget = AGadget;
}

state Reloading
{
    function EndState()
    {
        if(bShowLog)log("HANDS - "$self$" -  Leaving State Reloading");
    }
    simulated event AnimEnd(int Channel)
    {
        //this event is called only in FirstPerson
        if(Channel == 0)
        {
            //Weapon Animation
            if(m_bBipodDeployed)
            {
                AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_BipodNeutral;
            }
            else
            {
                AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_Neutral;
            }
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);

            // returning to normal state
            Gotostate('Waiting');
            AssociatedWeapon.GotoState('');
            R6AbstractWeapon(Owner).FirstPersonAnimOver();
        }
    }

    simulated function BeginState()
    {
        if(bShowLog)log("HANDS - "$self$" -  Begin State Reloading");
        R6Pawn(Owner.Owner).ServerPlayReloadAnimAgain();
        AssociatedWeapon.GotoState('Reloading');
        if(m_bReloadEmpty == true)
        {
            if(m_bBipodDeployed)
            {
                PlayAnim(m_HandBipodReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
            }
            else
            {
                PlayAnim(m_HandReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                AssociatedWeapon.PlayAnim(AssociatedWeapon.m_ReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
            }
            m_bReloadEmpty=FALSE;
        }
        else
        {
            if(m_bBipodDeployed)
            {
                PlayAnim('BipodReload', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodReload, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
            }
            else
            {
                PlayAnim('Reload', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
                AssociatedWeapon.PlayAnim(AssociatedWeapon.m_Reload, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
            } 
        }
    }
}

//Discard weapon is when a character is changing weapon, then drawtype is set to None
state DiscardWeapon
{
    simulated event AnimEnd(int Channel)
    {
        if(bShowLog)log("HANDS - "$self$" -  "$self$" -   IN:"@self@"::DiscardWeapon::AnimEnd()");
		if(Owner == none)
			return;
		
        if(Channel == 0)
        {
            //Hide this weapon.
            SetDrawType(DT_None);
            R6AbstractWeapon(Owner).FirstPersonAnimOver();
        }
//        if(bShowLog)log("HANDS - "$self$" -  OUT:"@self@"::DiscardWeapon::AnimEnd()");
    }

    simulated function BeginState()
    {
        if(bShowLog)log("HANDS - "$self$" -  IN:"@self@"::DiscardWeapon::BeginState()");

        Owner.Owner.PlaySound(R6AbstractWeapon(Owner).m_UnEquipSnd, SLOT_SFX);

        if(m_bBipodDeployed)
        {
            PlayAnim('BipodEnd', R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration);
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodDiscard);
        }
        else
        {
            PlayAnim('End', R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration);
        }
//        if(bShowLog)log("HANDS - "$self$" -  OUT:"@self@"::DiscardWeapon::BeginState()");
    }
}

state RaiseWeapon
{
    simulated event AnimEnd(int Channel)
    {
        if(Channel == 0)
        {
            Gotostate('Waiting');
            R6AbstractWeapon(Owner).FirstPersonAnimOver();
        }
    }
    
    simulated function BeginState()
    {
        //Draw the weapon.
        if(bShowLog) log("HANDS - "$self$" -  RaiseWeapon, Animation Begin");
        SetDrawType(DT_Mesh);

        m_bBipodDeployed = R6Pawn(Owner.Owner).m_bIsProne && R6AbstractWeapon(Owner).GotBipod();
        AssociatedWeapon.m_bWeaponBipodDeployed = m_bBipodDeployed;

        Owner.Owner.PlaySound(R6AbstractWeapon(Owner).m_EquipSnd, SLOT_SFX);


        if(m_bBipodDeployed)
        {
            PlayAnim('BipodBegin',R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration);
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodRaise);
        }
        else
        {
            PlayAnim('Begin', R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration);
        }
    }
}

//Weapon is still active, character needs his two hands.
state PutWeaponDown
{
    simulated event AnimEnd(int Channel)
    {
        if(Channel == 0)
        {
            //Hide this weapon.
            SetDrawType(DT_None);
            R6AbstractWeapon(Owner).FirstPersonAnimOver();
        }
    }

    simulated function BeginState()
    {
        Owner.Owner.PlaySound(R6AbstractWeapon(Owner).m_UnEquipSnd, SLOT_SFX);

        if(m_bBipodDeployed)
        {
            PlayAnim('BipodEnd');
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodDiscard, R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration);
        }
        else
        {
            PlayAnim('End', R6Pawn(Owner.Owner).ArmorSkillEffect() * 1.5);
        }
    }
}

state BringWeaponUp
{
    simulated function BeginState()
    {
        //Draw the weapon.
        SetDrawType(DT_Mesh);

        m_bBipodDeployed = R6Pawn(Owner.Owner).m_bIsProne && R6AbstractWeapon(Owner).GotBipod();
        AssociatedWeapon.m_bWeaponBipodDeployed = m_bBipodDeployed;

        Owner.Owner.PlaySound(R6AbstractWeapon(Owner).m_EquipSnd, SLOT_SFX);

        if(m_bBipodDeployed)
        {
            PlayAnim('BipodBegin');
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodRaise, R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration);
        }
        else
        {
            PlayAnim('Begin', R6Pawn(Owner.Owner).ArmorSkillEffect() * 1.5);
        }
    }

    simulated event AnimEnd(int Channel)
    {
        if(Channel == 0)
        {
            Gotostate('Waiting');
            R6AbstractWeapon(Owner).FirstPersonAnimOver();
        }
    }
}

auto state Waiting
{
    simulated function Timer()
    {
        local INT WhichAnim;
        local INT HowLongBeforeWait;

        if(DrawType != DT_None)
        {
            StopAnimating();
            WhichAnim = rand(10);
            if(WhichAnim < 5)
            {
                PlayAnim(m_WaitAnim1);
            }
            else
            {
                PlayAnim(m_WaitAnim2);
            }
            m_bPlayWaitAnim = true;

            HowLongBeforeWait = rand(10);
            SetTimer(HowLongBeforeWait + 5, false);
        }
    }

    event AnimEnd(INT iChannel)
    {
        if(m_bPlayWaitAnim == true)
        {
            m_bPlayWaitAnim = false;
            if(m_bBipodDeployed)
            {
                LoopAnim('Bipod_nt');
            }
            else if (bPlayerWalking == true)
            {
                LoopAnim(m_WalkAnim);
            }
            else
            {
                LoopAnim('Wait_c');
            }
        }
    }

    function StopTimer()
    {
        SetTimer(0, false);
    }

    function StartTimer()
    {
        local INT HowLongBeforeWait;
        if(DrawType != DT_None)
        {
            HowLongBeforeWait = rand(10);
            SetTimer(HowLongBeforeWait + 5, false);
        }
    }

    simulated function EndState()
    {
        if(bShowLog)log("HANDS - "$self$" -  Waiting::EndState ");
        StopAnimating();
        StopTimer();
    }

    //The original BeginState, for wait Anims()
    simulated function BeginState()
    {
        if(bShowLog)log("HANDS - "$self$" -  Waiting::BeginState ");
        if(m_bBipodDeployed)
        {
            LoopAnim('Bipod_nt');
        }
        else if (bPlayerWalking == true)
        {
            LoopAnim(m_WalkAnim);
        }
        else
        {
            LoopAnim('Wait_c');
        }
        StartTimer();
    }
}

simulated state FiringWeapon
{
    function EndState()
    {
        if(bShowLog)log("HANDS - "$self$" -  Leaving State FiringWeapon");
        //Stop blending
        AnimBlendParams(1, 0);
    
    }
    
    function AnimEnd(INT iChannel)
    {
        if(iChannel != 0 || (owner == none))
        {
            return;
        }

        if(bShowLog)log("HANDS - "$self$" -  FiringWeapon::AnimEnd Can quit: "$m_bCanQuitOnAnimEnd$" In burst "$m_bInBurst);

        if(m_bCanQuitOnAnimEnd == true)
        {
            if(bShowLog) log("HANDS - "$self$" -  EndAnim, goto wait Owner : "$R6AbstractWeapon(Owner));
            //Play the weapon animation
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);

            AnimBlendParams(1, 0);
            GotoState('Waiting');
            R6AbstractWeapon(Owner).FirstPersonAnimOver();
            //Reset the variables for animations
            m_bCanQuitOnAnimEnd=false;
            m_bCannotPlayEmpty=false;
            m_bInBurst=false;
        }
        else if(m_bInBurst == true)
        {
            if(bShowLog)log("HANDS - "$self$" -  EndAnim, loop Burst");
            //Loop the fireburst if InBurst is true
            AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
            LoopAnim('FireBurst_c', R6AbstractWeapon(Owner).m_fFireAnimRate, 0.1);
            AssociatedWeapon.LoopWeaponBurst();
        }
        else
        {
            if(bShowLog)log("HANDS - "$self$" -  EndAnim, playing fireburst_2");
            m_bCannotPlayEmpty = true;
            m_bCanQuitOnAnimEnd = true;
            AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
            PlayAnim('FireBurst_e',,0.1);
            AssociatedWeapon.StopWeaponBurst();
        }
    }

    function StopFiring()
    {
        if(bShowLog)log("HANDS - "$self$" -  StopFiring");
        //Stop the burst loop animation
        m_bInBurst = false;
        AnimEnd(0);
    }

    function InterruptFiring()
    {
        if(bShowLog)log("HANDS - "$self$" -  InterruptFiring");
        //interrupt the 3 bullets burst animation
        m_bCanQuitOnAnimEnd = true;
        m_bInBurst = false;
        AnimEnd(0);
    }

    function FireEmpty()
    {
        if(bShowLog) log("HANDS - "$self$" -  Fire Empty");
        //Weapon Animation
        if(!m_bBipodDeployed)
        {
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_FireEmpty);
        }

        if(m_bCannotPlayEmpty == false)
        {
            PlayAnim('FireEmpty');
            m_bCanQuitOnAnimEnd = true;
        }
    }

    function FireLastBullet()
    {
        if(bShowLog)log("HANDS - "$self$" -  FireLastBullet");
        //Blend With Anim playing in channel 1
        AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
        if(m_bBipodDeployed)
        {
            PlayAnim(m_HandBipodFire);
            AssociatedWeapon.m_WeaponNeutralAnim=AssociatedWeapon.m_BipodNeutral;
        }
        else
        {
            PlayAnim(m_HandFireLast);
            if(bShowLog)log("New neutral anim is: "$AssociatedWeapon.m_Empty);
            AssociatedWeapon.m_WeaponNeutralAnim=AssociatedWeapon.m_Empty;
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_FireLast);
        }
        m_bCanQuitOnAnimEnd = true;
    }

    function FireSingleShot()
    {
        if(bShowLog) log("HANDS - "$self$" -  FireSingleShot");
        //Blend With Anim playing in channel 1
        AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
        if(m_bBipodDeployed)
        {
            PlayAnim(m_HandBipodFire);
        }
        else
        {
            PlayAnim(m_HandFire);
        }
        m_bCanQuitOnAnimEnd=true;
    }

    function FireThreeShots()
    {
        if(bShowLog)log("HANDS - "$self$" -  FireThreeShots rate = "$R6AbstractWeapon(Owner).m_fFireAnimRate$"Blend = "$R6AbstractWeapon(Owner).m_fFPBlend);
        //Blend With Anim playing in channel 1
        AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
        PlayAnim('FireBurst_b', R6AbstractWeapon(Owner).m_fFireAnimRate);
        m_bCanQuitOnAnimEnd=false;
    }

    function StartBurst()
    {
        if(bShowLog)log("HANDS - "$self$" -  StartBurst rate = "$R6AbstractWeapon(Owner).m_fFireAnimRate$"  Blend = "$R6AbstractWeapon(Owner).m_fFPBlend);
        //Blend With Anim playing in channel 1
        m_bCanQuitOnAnimEnd=false;
        AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
        PlayAnim('FireBurst_b', R6AbstractWeapon(Owner).m_fFireAnimRate);
        m_bInBurst = true;
        AssociatedWeapon.StartWeaponBurst();
    }

    function BeginState()
    {
        if(bShowLog)log("HANDS - "$self$" -  Begin Firing Anims");
        //Start Looping in channel 0;
        LoopAnim('Neutral',,,1);
    }
}

state HandsDown
{
    simulated function EndState()
    {
        StopAnimating();
        PlayAnim('OneHand_e');
    }

    Event AnimEnd(INT iChannel)
    {
        LoopAnim('OneHand_nt');
    }

    simulated function BeginState()
    {
        PlayAnim('OneHand_b');
    }
}

state DeployBipod
{
    event AnimEnd(INT iChannel)
    {
        if(bShowLog)log("HANDS - "$self$" -  DeployBipod::AnimEnd");
        GotoState('Waiting');
        R6AbstractWeapon(Owner).FirstPersonAnimOver();
    }

    simulated function BeginState()
    {
        if(bShowLog)log("HANDS - "$self$" -  DeployBipod::BeginState");
        PlayAnim('Bipod_b');
        AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodDeploy);
        m_bBipodDeployed = true;
        AssociatedWeapon.m_bWeaponBipodDeployed = m_bBipodDeployed;
        AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_BipodNeutral;
    }
    function EndState()
    {
        if(bShowLog)log("HANDS - "$self$" -  DeployBipod::EndState");
    }
}

state CloseBipod
{
    simulated function EndState()
    {
        if(bShowLog)log("HANDS - "$self$" -  CloseBipod::EndState");
        m_bBipodDeployed = false;
        AssociatedWeapon.m_bWeaponBipodDeployed = m_bBipodDeployed;
        AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_Neutral;
    }

    Event AnimEnd(INT iChannel)
    {
        if(bShowLog)log("HANDS - "$self$" -  CloseBipod::AnimEnd");
        GotoState('Waiting');
        R6AbstractWeapon(Owner).FirstPersonAnimOver();
    }

    simulated function BeginState()
    {
        if(bShowLog)log("HANDS - "$self$" -  CloseBipod::BeginState");
        PlayAnim('Bipod_e');
        AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodClose);
    }
}

state ZoomIn
{
    Event AnimEnd(INT iChannel)
    {
        if(bShowLog)log("HANDS - "$self$" -  ZoomIn::AnimEnd");
        GotoState('Waiting');
        R6AbstractWeapon(Owner).FirstPersonAnimOver();
    }

    simulated function BeginState()
    {
        if(HasAnim('ZoomIn'))
            PlayAnim('ZoomIn');
        else
            AnimEnd(0);
    }
}

state ZoomOut
{
    Event AnimEnd(INT iChannel)
    {
        LoopAnim(AssociatedWeapon.m_WeaponNeutralAnim);
        GotoState('Waiting');
        R6AbstractWeapon(Owner).FirstPersonAnimOver();
    }

    simulated function BeginState()
    {
        if(HasAnim('ZoomOut'))
            PlayAnim('ZoomOut');
        else
            AnimEnd(0);
    }
}

defaultproperties
{
     m_fAnimAcceleration=1.200000
     m_HandFire="Fire"
     m_HandFireLast="FireLast"
     m_HandBipodFire="BipodFire"
     m_HandReloadEmpty="ReloadEmpty"
     m_HandBipodReloadEmpty="BipodReloadEmpty"
     m_WaitAnim1="Wait01"
     m_WaitAnim2="Wait02"
     m_WalkAnim="walk_c"
     bHidden=True
}
