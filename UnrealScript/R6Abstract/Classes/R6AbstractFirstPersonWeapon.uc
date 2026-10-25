//===============================================================================
//  [R6AbstractFirstPersonWeapon] 
//===============================================================================

class R6AbstractFirstPersonWeapon extends R6EngineFirstPersonWeapon
    native
    abstract;

var (R6FPAnimations) name m_Empty;
var (R6FPAnimations) name m_Fire;
var (R6FPAnimations) name m_FireEmpty;
var (R6FPAnimations) name m_FireLast;
var (R6FPAnimations) name m_Neutral;
var (R6FPAnimations) name m_Reload;
var (R6FPAnimations) name m_ReloadEmpty;
var (R6FPAnimations) name m_BipodRaise;   //Raise weapon & Put the bipod down, if any
var (R6FPAnimations) name m_BipodDeploy;      //Bring the bipod up
var (R6FPAnimations) name m_BipodDiscard; //Close bipod, and lower weapon
var (R6FPAnimations) name m_BipodClose;    //Put the bipod down, if any
var (R6FPAnimations) name m_BipodNeutral; //Bipod is down
var (R6FPAnimations) name m_BipodReload;  //reload anim with the bipod down
var (R6FPAnimations) name m_BipodReloadEmpty;


var Actor m_smGun;   //First Person gun as static Mesh
var Actor m_smGun2;  //If the weapon has more than one static mesh.

var BOOL        m_bWeaponBipodDeployed;
var BOOL        m_bReloadEmpty;
var name        m_WeaponNeutralAnim;

function StopFiring();
function InterruptFiring();
function FireEmpty();
function FireLastBullet();
function FireSingleShot();
function FireThreeShots();
function LoopBurst();
function StartBurst();

function StopTimer();
function StartTimer();
function FireGrenadeThrow();
function FireGrenadeRoll() ;
function DestroyBullets();

function StartWeaponBurst();
function LoopWeaponBurst();
function StopWeaponBurst();

function PlayWalkingAnimation();
function StopWalkingAnimation();
function ResetNeutralAnim();

simulated function SwitchFPMesh();
simulated function SwitchFPAnim();

simulated function SetAssociatedWeapon(R6AbstractFirstPersonWeapon AWeapon);

// LMG functions
function HideBullet(INT iWhichBullet);

function PlayFireAnim()
{
    //Don't play any Animations if a bipod is deployed
    if(m_bWeaponBipodDeployed == false)
    {
        PlayAnim(m_Fire);
    }
}

function PlayFireLastAnim()
{
    //Don't play any Animations if a bipod is deployed
    if(m_bWeaponBipodDeployed == false)
    {
        PlayAnim(m_FireLast);
    }
}


function DestroySM()
{
    local Actor aActor;

    aActor = m_smGun;
    m_smGun = none;
    if(aActor != none)
        aActor.Destroy();

    aActor = m_smGun2;
    m_smGun2 = none;
    if(aActor != none)
        aActor.Destroy();

    DestroyBullets();
}

simulated function PostBeginPlay()
{

    if(!HasAnim(m_Neutral))
    {
        log("Missing Neutral Anim for Weapon :"$self);
    }
    if(!HasAnim(m_Empty))
    {
        m_Empty = m_Neutral;
    }
    if(!HasAnim(m_Fire))
    {
        //log("Missing Fire Anim for Weapon :"$self);
        m_Fire = m_Neutral;
    }
    if(!HasAnim(m_FireLast))
    {
        m_FireLast = m_Fire;
    }
    if(!HasAnim(m_FireEmpty))
    {
        m_FireEmpty = m_Neutral;
    }
    if(!HasAnim(m_Reload))
    {
        m_Reload = m_Neutral;
    }
    if(!HasAnim(m_ReloadEmpty))
    {
        //log("Missing ReloadEmpty Anim for Weapon :"$self);
        m_ReloadEmpty = m_Reload;
    }
    
    if(!HasAnim(m_BipodRaise))
    {
        m_BipodRaise = m_Neutral;
    }
    if(!HasAnim(m_BipodDeploy))
    {
        m_BipodDeploy = m_Neutral;
    }
    if(!HasAnim(m_BipodDiscard))
    {
        m_BipodDiscard = m_Neutral;
    }
    if(!HasAnim(m_BipodClose))
    {
        m_BipodClose = m_Neutral;
    }

    if(!HasAnim(m_BipodNeutral))
    {
        m_BipodNeutral = m_Neutral;
    }
    if(!HasAnim(m_BipodReload))
    {
        m_BipodReload = m_BipodNeutral;
    }
    if(!HasAnim(m_BipodReloadEmpty))
    {
        m_BipodReloadEmpty = m_BipodReload;
    }
}

state Reloading
{
    function BeginState()
    {
    }
}

simulated event Destroyed()
{
    DestroySM();

    Super.Destroyed();
}

defaultproperties
{
     m_Empty="Empty_nt"
     m_Fire="Fire"
     m_FireEmpty="FireEmpty"
     m_FireLast="FireLast"
     m_Neutral="Neutral"
     m_Reload="Reload"
     m_ReloadEmpty="ReloadEmpty"
     m_BipodRaise="BipodBegin"
     m_BipodDeploy="Bipod_b"
     m_BipodDiscard="BipodEnd"
     m_BipodClose="Bipod_e"
     m_BipodNeutral="Bipod_nt"
     m_BipodReload="BipodReload"
     m_BipodReloadEmpty="BipodReloadEmpty"
     m_WeaponNeutralAnim="Neutral"
     RemoteRole=ROLE_None
     DrawType=DT_Mesh
     m_bAllowLOD=False
}
