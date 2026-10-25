//===============================================================================
//  [R61stHandsGripGrenade ] 
//===============================================================================

class R61stHandsGripGrenade extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX
    
function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripGrenadeA');
    Super.PostBeginPlay();
}


auto state Waiting
{
    simulated function Timer()
    {
        local INT HowLongBeforeWait;

        PlayAnim('Wait01');

        m_bPlayWaitAnim = true;

        HowLongBeforeWait = rand(10);
        SetTimer(HowLongBeforeWait + 5, false);
    }
}

state RaiseWeapon
{
    simulated function BeginState()
    {
        //Draw the weapon.
        //log("Animation Begin");
        SetDrawType(DT_Mesh);
        AssociatedWeapon.SetDrawType(DT_Mesh);
        AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);

        Owner.Owner.PlaySound(R6AbstractWeapon(Owner).m_EquipSnd, SLOT_SFX);
        
        PlayAnim('Begin', R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration);
    }
}

simulated state FiringWeapon
{
    function EndState() {}
    function FireEmpty() {}

    function BeginState()
    {
        //log("HANDS - Begin Firing Anims");
        //Start Looping in channel 0;
        LoopAnim('Neutral',,,1);
    }
    
    simulated function AnimEnd(INT iChannel)
    {
        if(bShowLog)log("animEnd "$Self);
        if(iChannel != 0 || (owner == none))
        {
            return;
        }
        if(m_bCanQuitOnAnimEnd == true)
        {
            AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);

            //log("HANDS - EndAnim, goto wait");
            AnimBlendParams(1, 0);
            //Reset the variables for animations
            LoopAnim('Empty_nt');
            m_bCanQuitOnAnimEnd=false;
            m_bCannotPlayEmpty=false;
            m_bInBurst=false;
            GotoState('');
        }
        else
        {
            AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
            LoopAnim('Fire_nt', R6AbstractWeapon(Owner).m_fFireAnimRate, 0.1);
        }
        if(bShowLog)log("Calling FPAO");
        R6AbstractWeapon(Owner).FirstPersonAnimOver();
    }

    
    simulated function FireGrenadeThrow()
    {
        AssociatedWeapon.SetDrawType(DT_None);
        AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
        PlayAnim('Fire_Up', R6Pawn(Owner.Owner).ArmorSkillEffect() * 0.8);
        m_bCanQuitOnAnimEnd=true;
        if(bShowLog)log("FireGrenadeThrow "$Self);
    }

    simulated function FireGrenadeRoll()
    {
        AssociatedWeapon.SetDrawType(DT_None);
        AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
        PlayAnim('Fire_Down', R6Pawn(Owner.Owner).ArmorSkillEffect() * 0.8);
        m_bCanQuitOnAnimEnd=true;
        if(bShowLog)log("FireGrenadeRoll "$Self);
    }

    simulated function FireSingleShot()
    {
        AssociatedWeapon.PlayAnim(AssociatedWeapon.m_Fire, R6Pawn(Owner.Owner).ArmorSkillEffect());
        AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
        PlayAnim('Fire', R6Pawn(Owner.Owner).ArmorSkillEffect());
        m_bCanQuitOnAnimEnd=false; 
        if(bShowLog)log("FireSingleShot "$Self);
    }
}

defaultproperties
{
     DrawType=DT_None
     Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
