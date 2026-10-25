//========================================================================================
//  R6EngineWeapon.uc :     This is the base class for the r6Weapon class.  It's here
//                          to put a pointer in the Pawn Class. and replace the 
//                          weapon/inventory system
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    July 18th, 2001 * Created by Joel Tremblay
//=============================================================================
class R6EngineWeapon extends actor
    abstract
    native;


enum eWeaponType
{
    WT_Pistol,
    WT_Sub,
    WT_Assault,
    WT_ShotGun,
    WT_Sniper,
    WT_LMG,
    WT_Grenade,
    WT_Gadget
};

enum eGripType
{
	GRIP_None,
	GRIP_Aug,
	GRIP_BullPup,
	GRIP_LMG,
	GRIP_P90,
	GRIP_ShotGun,
	GRIP_Uzi,
	GRIP_SubGun,
	GRIP_HandGun
};

enum eWeaponGrenadeType
{
    GT_GrenadeNone,
	GT_GrenadeFrag,
	GT_GrenadeGas,
	GT_GrenadeFlash,
	GT_GrenadeSmoke
};

enum eRateOfFire
{
    ROF_Single,
    ROF_ThreeRound,
    ROF_FullAuto
};

enum eGadgetType
{
    GAD_Other,
    GAD_SniperRifleScope,
    GAD_Magazine,
    GAD_Bipod,
    GAD_Muzzle,
    GAD_Silencer,
    GAD_Light
};

enum EWeaponSound
{
    WSOUND_None,
    WSOUND_Initialize,
    WSOUND_PlayTrigger,
    WSOUND_PlayFireSingleShot,
    WSOUND_PlayFireEndSingleShot,
    WSOUND_PlayFireThreeBurst,
    WSOUND_PlayFireFullAuto,
    WSOUND_PlayEmptyMag,
    WSOUND_PlayReloadEmpty,
    WSOUND_PlayReload,
    WSOUND_StopFireFullAuto
};

var FLOAT       m_fTimeDisplayParticule;
var INT         m_iNbParticlesToCreate;

var (R6GunProperties) eWeaponType m_eWeaponType;
var  				  eGripType   m_eGripType;
var (R6GunProperties) BOOL        m_bDisplayHudInfo;

//Weapon Management
var		INT				m_InventoryGroup;     // The weapon/gadget set, 0-3
var     string          m_NameID;             // Weapon Name ID 
var     string          m_WeaponDesc;         // Weapon Name
var		string			m_WeaponShortName;    // Abreviation for this weapon in some menu

// Animation names for the Pawn
var (R6Animation) name m_PawnWaitAnimLow;           // Rainbow
var (R6Animation) name m_PawnWaitAnimHigh;          // Rainbow
var (R6Animation) name m_PawnWaitAnimProne;         // Rainbow

var (R6Animation) name m_PawnFiringAnim;            // Rainbow
var (R6Animation) name m_PawnFiringAnimProne;       // Rainbow
var (R6Animation) name m_PawnReloadAnim;            // Rainbow
var (R6Animation) name m_PawnReloadAnimTactical;    // Rainbow 
var (R6Animation) name m_PawnReloadAnimProne;       // Rainbow
var (R6Animation) name m_PawnReloadAnimProneTactical;    // Rainbow 

// Attachments
var (R6Attachment) name m_AttachPoint;
var (R6Attachment) name m_HoldAttachPoint;
var (R6Attachment) name m_HoldAttachPoint2; 

var (R6Attachment) string m_szMagazineClass;
var (R6Attachment) string m_szMuzzleClass;
var (R6Attachment) string m_szSilencerClass;
var (R6Attachment) string m_szTacticalLightClass;

var (R6Sounds)	Sound m_ReloadSound;

var (R6GunProperties) vector  m_vPositionOffset;      // Offsets to display the weapon
var (R6GunProperties) FLOAT   m_fMaxZoom;             //Max zoom for gun with integrated scope
var (R6GunProperties) Texture m_ScopeTexture;           //Scope texture while zooming.
var (R6GunProperties) Texture m_ScopeAdd;               //Scope add texture (not used in heat or night vision)
var (R6GunProperties) StaticMesh m_WithScopeSM;         //Mesh used when gadget is a scope.
var (R6GunProperties) Texture m_FPMuzzleFlashTexture;   // to override the texture in the emitter.


var                   FLOAT      m_fFireAnimRate; // m_fRateOfFire / 0.1
var                   FLOAT      m_fFPBlend;      // anim blending while firing (based on weapon energy).
var	(R6GunProperties) FLOAT		 BobDamping;		 // how much to damp view bob

var (R6GunProperties) FLOAT      m_fReloadTime;
var (R6GunProperties) FLOAT      m_fReloadEmptyTime;
var                   FLOAT      m_fPauseWhenChanging;
var (R6GunProperties) BOOL       m_bBipod;
var                   BOOL       m_bDeployBipod;
var                   BOOL       m_bBipodDeployed;

var         BOOL        bFiredABullet;                      // To play the firing animation

var         BOOL        m_bPawnIsWalking;   // To keep the bobing animation after changing weapon.
var         BOOL        m_bIsSilenced;      // weapon is either inherently silenced or has a weapon gadget added to silence it - 19 feb 2002 rbrek
var         BOOL        m_bUnlimitedClip;   // Weapon have infinite number of clip (for terrorist)
var         BOOL        m_bUseMicroAnim;    // Weapon have use micro animation (for terrorist)

var         vector      m_FPFlashLocation;

var BYTE                m_iNbBulletsInWeapon; //Current Number Of bullets in weapon, to be replicated

// Sound Stuff
var (R6WeaponSound)   sound m_EquipSnd;              // Sound when the player pick his weapon
var (R6WeaponSound)   sound m_UnEquipSnd;           // Sound when the player store his weapon
var (R6WeaponSound)   sound m_ReloadSnd;            // Reload Sound
var (R6WeaponSound)   sound m_ReloadEmptySnd;       // Reload Sound when the mag is empty
var (R6WeaponSound)   sound m_ChangeROFSnd;         // Change Rate of Fire sound
var (R6WeaponSound)   sound m_SingleFireStereoSnd;  // Single shot stereo (for 1st person view)
var (R6WeaponSound)   sound m_SingleFireEndStereoSnd;// Single shot that is interruptible.
var (R6WeaponSound)   sound m_BurstFireStereoSnd;   // 3 rounds burst stereo
var (R6WeaponSound)   sound m_FullAutoStereoSnd;    // Full Auto Stereo
var (R6WeaponSound)   sound m_FullAutoEndMonoSnd;   // Last bullet in full auto for mono sound
var (R6WeaponSound)   sound m_FullAutoEndStereoSnd; // Last bullet in full auto for stereo sound
var (R6WeaponSound)   sound m_EmptyMagSnd;          // Sound when the mag is empty
var (R6WeaponSound)   sound m_TriggerSnd;           // Trigger Sound

var (R6WeaponSound)   sound m_ShellSingleFireSnd;	// Single Fire Shell
var (R6WeaponSound)   sound m_ShellBurstFireSnd;    // 3 rounds burst shell 
var (R6WeaponSound)   sound m_ShellFullAutoSnd;     // Full Auto shell only for LMG
var (R6WeaponSound)   sound m_ShellEndFullAutoSnd;  // End Full Auto Shell

var (R6WeaponSound)   sound m_CommonWeaponZoomSnd;
var (R6WeaponSound)   sound m_SniperZoomFirstSnd;    // First zoom sound
var (R6WeaponSound)   sound m_SniperZoomSecondSnd;   // Second zoom sound

var (R6WeaponSound)   sound m_BipodSnd;				 // Use bipod with the gun

var Material m_HUDTexture;
var Plane	 m_HUDTexturePos;

replication
{
	reliable if (Role < ROLE_Authority) 
		ServerStopFire;

	reliable if (Role == ROLE_Authority) 
		StopFire, ClientStopFire;

    unreliable if (Role < ROLE_Authority)
        ServerDetonate, ServerPlaceCharge, ServerPlaceChargeAnimation, ServerPutBulletInShotgun,
        ServerShowInfo;//R6DEBUG

    unreliable if (Role == ROLE_Authority)
        m_bUnlimitedClip, m_bDeployBipod, m_iNbBulletsInWeapon;

    unreliable if (Role == ROLE_Authority)
		WeaponZoomSound;

    unreliable if (bNetOwner && Role == ROLE_Authority)
        m_fMaxZoom;
}

simulated function PostRender( canvas Canvas );

simulated event DeployWeaponBipod(BOOL bBipodOpen);

simulated function bool ClientFire( float Value );
simulated function bool ClientAltFire( float Value );

function Fire( float Value );
function AltFire( float Value );

simulated function BOOL LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController){return false;}
simulated function RemoveFirstPersonWeapon();
simulated function AttachEmittersToFPWeapon();
simulated function AttachEmittersTo3rdWeapon();
simulated function DisableWeaponOrGadget();
simulated function TurnOffEmitters(BOOL bTurnOff);

function GiveMoreAmmo();

function AttachMagazine();
simulated function INT NumberOfBulletsLeftInClip();
function FLOAT GetCurrentMaxAngle();
function BOOL IsAtBestAccuracy();

function FLOAT GetWeaponJump();
exec function SetNextRateOfFire();
function BOOL SetRateOfFire(eRateOfFire eNewRateOfFire);
function eRateOfFire GetRateOfFire();
function SetHoldAttachPoint();
function UseScopeStaticMesh();

function SetTerroristNbOfClips(INT iNewNumber);
function INT GetNbOfClips();
function BOOL HasAtLeastOneFullClip();
function INT GetClipCapacity();
function FLOAT GetMuzzleVelocity();
/////////////////////////
// ANIMATION FUNCTIONS //
/////////////////////////
simulated function name GetWaitAnimName()           {return m_PawnWaitAnimLow;}         // Rainbow
simulated function name GetHighWaitAnimName()       {return m_PawnWaitAnimHigh;}        // Rainbow
simulated function name GetProneWaitAnimName()      {return m_PawnWaitAnimProne;}       // Rainbow

simulated function name GetFiringAnimName()         {return m_PawnFiringAnim;}          // Rainbow
simulated function name GetProneFiringAnimName()    {return m_PawnFiringAnimProne;}     // Rainbow
simulated function name GetReloadAnimName()         {return m_PawnReloadAnim;}          // Rainbow
simulated function name GetReloadAnimTacticalName() {return m_PawnReloadAnimTactical;}  // Rainbow
simulated function name GetProneReloadAnimName()    {return m_PawnReloadAnimProne;}     // Rainbow
simulated function name GetProneReloadAnimTacticalName() {return m_PawnReloadAnimProneTactical;} //Rainbow

simulated function PlayReloading();

//First Person walking animation (bobing)
simulated event PawnIsMoving();
simulated event PawnStoppedMoving();

function BOOL HasAmmo();
function ChangeClip(); 
function FullCurrentClip();
function FillClips();
function AddExtraClip();
simulated function AddClips(INT iNbOfExtraClips);
function BOOL CanSwitchToWeapon();

function ServerStopFire(optional BOOL bSoundOnly);
function ClientStopFire(optional BOOL bSoundOnly);
function LocalStopFire(optional BOOL bSoundOnly);
function StopFire(optional BOOL bSoundOnly);
function StopAltFire();

function FullAmmo();
function PerfectAim();

event SetIdentifyTarget(bool bIdentifyCharacter, bool bFriendly, string characterName);
simulated function R6SetReticule(optional Controller LocalPlayerController);
simulated function UpdateHands();
simulated function WeaponInitialization( Pawn pawnOwner );

function StartLoopingAnims();
simulated function FirstPersonAnimOver(){}
function ServerPutBulletInShotgun(){}
function ClientAddShell(){}
function BOOL GunIsFull(){return false;}
simulated function BOOL GotBipod(){return m_bBipod;}
function Toggle3rdBipod(BOOL bBipodOpen);

//Grenade specific functions
function ThrowGrenade();
function FLOAT GetSaveDistanceToThrow() { return 0; }

// Charge specific functions
function ServerPlaceCharge(vector vLocation);
function ServerDetonate();
function ServerPlaceChargeAnimation();
function NPCPlaceCharge(actor aDoor);
function NPCDetonateCharge();

function GiveBulletToWeapon(string aBulletName);
function BOOL HasBulletType( name strBulletType );

simulated event BOOL IsGoggles() { return false; }
function SetHeartBeatRange(FLOAT fRange);
function WeaponZoomSound(BOOL bFirstZoom);

function Texture Get2DIcon();
simulated function StartFalling();

simulated function SetGadgets();

function bool AffectActor(int BulletGroup, actor ActorAffected);

simulated function BOOL IsPumpShotGun() { return false; }
function BOOL IsSniperRifle() { return m_eWeaponType == WT_Sniper; }
simulated function BOOL IsLMG() { return m_eWeaponType == WT_LMG; }
function BOOL HasScope();
function FLOAT GetExplosionDelay();
function FLOAT GetWeaponRange();
simulated event UpdateWeaponAttachment( );
function SetRelevant( BOOL bNewAlwaysRelevant );
function SetTearOff( BOOL bNewTearOff );
simulated event ShowWeaponParticules(EWeaponSound eWeaponSound);

function SetAccuracyOnHit();

simulated function ServerShowInfo()
{
#ifdefDEBUG
    if(Level.NetMode == NM_DedicatedServer)
        ShowInfo();
#endif
}

#ifdefDEBUG
simulated function DisplayWeaponDGBInfo()
{
    ClientShowInfo();
    ServerShowInfo();
}

simulated function ClientShowInfo()
{
    ShowInfo();
}

simulated function ShowInfo()
{
    log("-----------------------------------------------------------------------------------------------------------------");
    log("Weapon "$Self$" is in state : "$GetStateName());
    log("Owner "$Owner$" is in state : "$Owner.GetStateName());
    log("Controller "$Pawn(Owner).Controller$" is in state : "$Pawn(Owner).Controller.GetStateName());
    
    log("Controller.Pawn : "$Pawn(Owner).Controller.Pawn);
    log("pawn.Weapon "$Pawn(Owner).EngineWeapon);
    log("Pawn.Owner "$Pawn(Owner).Owner);

    log("Weapon.REmoteRole = "$RemoteRole);
    log("Weapon.Role = "$Role);
}
#endif

defaultproperties
{
     m_eGripType=GRIP_SubGun
     m_InventoryGroup=1
     m_fMaxZoom=1.500000
     m_fFireAnimRate=1.000000
     BobDamping=0.960000
     m_fReloadTime=2.500000
     m_fReloadEmptyTime=3.000000
     m_fPauseWhenChanging=0.500000
     RemoteRole=ROLE_SimulatedProxy
}
