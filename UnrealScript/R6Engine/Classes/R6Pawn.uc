//=============================================================================
//  R6Pawn.uc : This is the base pawn class for all Rainbow 6 characters
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    2001/05/07   Joel Tremblay        Add Kill and Stun results
//                                      Add R6TakeDamage and R6Died
//    2001/05/29   Joel Tremblay        Add Activate Night Vision.
//    2001/05/29   Aristo Kolokathis    Added player's base accuracy
//    2001/07/24   Joel Tremblay        Change player response to hit
//=============================================================================
class R6Pawn extends R6AbstractPawn
    native
    abstract;

// R6CIRCUMSTANTIALACTION
#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons

// R6HEARTBEAT R6BLOODSPLATS R6NIGHTVISION
#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx PACKAGE=Inventory_t

#exec OBJ LOAD FILE=..\Sounds\Voices_1rstPersonRainbow.uax PACKAGE=Voices_1rstPersonRainbow
#exec OBJ LOAD FILE=..\Sounds\Voices_3rdPersonRainbow.uax PACKAGE=Voices_3rdPersonRainbow

// structure for PlayWeaponAnimation()
struct STWeaponAnim
{
    var name    nAnimToPlay;
    var name    nBlendName;
    var FLOAT   fTweenTime;
    var FLOAT   fRate;
    var BOOL    bPlayOnce;
    var BOOL    bBackward;
};

const C_iHeartRateMaxTerrorist  = 184;
const C_iHeartRateMaxOther      = 182; // Other contain hostages, rainbows civilans
const C_iHeartRateMinTerrorist  = 65;  
const C_iHeartRateMinOther      = 90; // Other contain hostages, rainbows civilans

// R6CIRCUMSTANTIALACTION

const C_iBaseAnimChannel        = 0;
const C_iBaseBlendAnimChannel   = 1;
const C_iPostureAnimChannel     = 12;
const C_iPeekingAnimChannel     = 13;
const C_iWeaponRightAnimChannel = 14;
const C_iWeaponLeftAnimChannel  = 15;

const C_iPawnSpecificChannel    = 16;   // Channel reserved to pawn class specific animation.  Should not be used directly in R6Pawn.uc

const C_fPrePivotStairOffset = 5.0;

const C_fHeadRadius = 22.f;             // approx value of the head radius. With this value, the colbox doesn't reduce when hit walls
const C_fHeadHeight = 26.f;             // approx value of the head height

enum eBodyPart
{
    BP_Head,
    BP_Chest,
    BP_Abdomen,
    BP_Legs,
    BP_Arms,
};

enum eArmor
{
    ARMOR_None,
    ARMOR_Light,
    ARMOR_Medium,
    ARMOR_Heavy,
};

enum EHeadAttachmentType
{
    ATTACH_Glasses,
    ATTACH_Sunglasses,
    ATTACH_GasMask,
    ATTACH_None
};

enum ETerroristType
{
    TTYPE_B1T1,
    TTYPE_B1T3,
    TTYPE_B2T2,
    TTYPE_B2T4,
    TTYPE_M1T1,
    TTYPE_M1T3,
    TTYPE_M2T2,
    TTYPE_M2T4,
    TTYPE_P1T1,
    TTYPE_P2T2,
    TTYPE_P3T3,
    TTYPE_P1T4,
    TTYPE_P2T5,
    TTYPE_P3T6,
    TTYPE_P1T7,
    TTYPE_P2T8,
    TTYPE_P3T9,
    TTYPE_P1T10,
    TTYPE_P2T11,
    TTYPE_P3T12,
    TTYPE_P4T13,
    TTYPE_D1T1,
    TTYPE_D1T2,
    TTYPE_GOSP,
    TTYPE_GUTI,
    TTYPE_S1T1,
    TTYPE_S1T2,
    TTYPE_TXIC,
    TTYPE_T1T1,
    TTYPE_T2T2,
    TTYPE_T1T3,
    TTYPE_T2T4,
};

enum eMovementDirection
{
    MOVEDIR_Forward,
    MOVEDIR_Backward,
    MOVEDIR_Strafe
};

enum eMovementPace
{
    PACE_None,
    PACE_Prone,
    PACE_CrouchWalk,
    PACE_CrouchRun,
    PACE_Walk,
    PACE_Run
};
var                 eMovementPace   m_eMovementPace;

// Special animation replicated to be played on all client
enum EPendingAction
{
    PENDING_None,
    // Common animation
    PENDING_Coughing,
    PENDING_StopCoughing,
    PENDING_Blinded,
    PENDING_OpenDoor,
    PENDING_StartClimbingLadder,
    PENDING_PostStartClimbingLadder,
    PENDING_EndClimbingLadder,
    PENDING_PostEndClimbingLadder,
    PENDING_DropWeapon,
    PENDING_ProneToCrouch,
    PENDING_CrouchToProne,
    PENDING_MoveHitBone,
    PENDING_StartClimbingObject,
    PENDING_PostStartClimbingObject,
    // Specific Rainbow animation
    PENDING_SetRemoteCharge,
    PENDING_SetBreachingCharge,
    PENDING_SetClaymore,
    PENDING_InteractWithDevice,
    PENDING_LockPickDoor,
    PENDING_ComFollowMe,
    PENDING_ComCover,
    PENDING_ComGo,
    PENDING_ComRegroup,
    PENDING_ComHold,
    PENDING_ActivateNightVision,
    PENDING_DeactivateNightVision,
    PENDING_SecureWeapon,
    PENDING_EquipWeapon,
    PENDING_SecureTerrorist,
    // Specific Terrorist animation
    PENDING_ThrowGrenade,
    PENDING_Surrender,
    PENDING_Kneeling,
    PENDING_Arrest,
    PENDING_CallBackup,
    PENDING_SpecialAnim,
    PENDING_LoopSpecialAnim,
    PENDING_StopSpecialAnim,
    // Specific Hostage animation
    PENDING_HostageAnim,
            // MPF1
	    // Specific Capture The Enemy animations
	PENDING_EndSurrender, //MissionPack1
	PENDING_StartSurrender, //MissionPack1
	PENDING_PostEndSurrender, //MissionPack1
	PENDING_SetFree,		  //MissionPack1
	PENDING_ArrestKneel,		  //MPF_Milan
	PENDING_ArrestWaiting,	//MPF_Milan_7_1_2003
	PENDING_EndArrest,		//MPF_Milan_7_1_2003
	PENDING_Custom
};

const C_MaxPendingAction = 5;
var EPendingAction m_ePendingAction[C_MaxPendingAction];
var INT            m_iPendingActionInt[C_MaxPendingAction];
var BYTE           m_iNetCurrentActionIndex;
var BYTE           m_iLocalCurrentActionIndex;

//weapon variables for RainbowSix
var  enum eHands
{
    HANDS_None,
    HANDS_Right,
    HANDS_Left,
    HANDS_Both
}m_ePlayerIsUsingHands;

var enum eDeviceAnimToPlay
{
    BA_ArmBomb,
    BA_DisarmBomb,
    BA_Keypad,
    BA_PlantDevice,
    BA_Keyboard,
    BA_Custom
}m_eDeviceAnim;

enum EHostagePersonality
{
    HPERSO_Coward,
    HPERSO_Normal,
    HPERSO_Brave,
    HPERSO_Bait,
    HPERSO_None
};

// NB: If you change C_fPeekMiddleMax, don't forget to change
//     m_fPeeking and m_fPeekingGoal in the default properties
//     and function SetPeekingInfo in R6PlayerController
const C_fPeekLeftMax        =    0.0;   // head:    0  ...  1000 ... 2000
const C_fPeekMiddleMax      = 1000.0;   //       left      middle    right
const C_fPeekRightMax       = 2000.0;
const C_fPeekCrouchLeftMax  =  400.0;   // crouch: 400 ...  1000 ... 1600
const C_fPeekCrouchRightMax = 1600.0;   
const C_fPeekSpeedInMs      = 3000.0;   
const C_fPeekProneTime      =  120.0;   // time is takes to reach max rotation when prone

// -- identification -- //
var()               INT             m_iID;                  // this identifies the character rank within the team (for formation purposes)
var()               INT             m_iPermanentID;         // this id stays with the character, does not change
var                 INT             m_iVisibilityTest;      // used for visibility checks; ensure that location of checks vary to improve chances of partial detection...

// -- personality/skills -- //
var(Personality)    FLOAT           m_fSkillAssault;        // affects how fast the reticule adjusts from max inaccuracy to most accurate,
                                                            //   when using weapons without a scope.
var(Personality)    FLOAT           m_fSkillDemolitions;    // affects how fast this pawn can plant and disarm explosives (0->10s,50->6s,100->2s)
var(Personality)    FLOAT           m_fSkillElectronics;    // affects how fast this pawn can plant and disable electronic devices (same as above)
var(Personality)    FLOAT           m_fSkillSniper;         // affects how fast the reticule adjusts from maximum inaccuracy to most accurate
                                                            //   when using weapons with a scope activated.
var(Personality)    FLOAT           m_fSkillStealth;        // this influences the amount of noise this pawn makes when moving (sound radius). 
                                                            //   (0->7m, 50->4m, 100->1m)
var(Personality)    FLOAT           m_fSkillSelfControl;    // this influences how willing this pawn is to shoot when there is a good chance of 
                                                            //   missing the target. (0->60% chance of hit,50->75%,100->90%)
var(Personality)    FLOAT           m_fSkillLeadership;     // this affects the delay between the time when the orders are issued, and the time 
                                                            //   when this member responds to the orders. (0->5s,50->3s,100->1s)
var(Personality)    FLOAT           m_fSkillObservation;    // affect how likely then pawn is to spot other pawn

// -- movement -- //
var                 vector          m_vStairDirection;      // vector indicates direction towards top of stairs
var                 BOOL            m_bIsClimbingStairs;
var                 BOOL            m_bIsMovingUpStairs;    // when m_bIsClimbingStairs is true, this var indicates whether pawn is facing up or down
var                 BOOL            m_bIsClimbingLadder;
var                 BOOL            m_bSlideEnd;
var                 BOOL            m_bCanClimbObject;      // used by NPC: allowed to climb a ClimbableObject
var                 BOOL            m_bOldCanWalkOffLedges;

// -- gadgets -- //
var                 BOOL            m_bActivateHeatVision;  // Boolean to activate the heat vision and the black flag.
var                 BOOL            m_bActivateNightVision; // Boolean to determine if the night vision is on
var                 BOOL            m_bActivateScopeVision; // Boolean to determine if the scope vision is on
var                 BOOL            m_bWeaponGadgetActivated;     // Boolean to activate the current gadget

var         R6AbstractBulletManager m_pBulletManager;

var                 BOOL            m_bIsKneeling;
var                 BOOL            m_bIsSniping;
var					BOOL			m_bPlayingComAnimation;
var                 BOOL            m_bDontKill;

// -- animation -- //
var                 eHands          m_eLastUsingHands;
var                 eHands          m_ePawnIsUsingHand;        // Used in Native function
var                 name            m_WeaponAnimPlaying;
var                 BOOL            m_bPreviousAnimPlayOnce;
var                 BOOL            m_bToggleServerCancelPlacingCharge;
var                 BOOL            m_bOldServerCancelPlacingCharge;
var                 BOOL            m_bReAttachToRightHand;  // When using blot action rifle and the notify that re attach to righ hand was not called.

// Speeds (Rainbow values set in R6Rainbow)
var             FLOAT               m_fReloadSpeedMultiplier;
var             FLOAT               m_fGunswitchSpeedMultiplier;
var             FLOAT               m_fGadgetSpeedMultiplier;

// -- weapons -- //
var                 BOOL            m_bReloadingWeapon;
var                 BOOL            m_bReloadAnimLoop;      //Replicated bool to loop shotguns reload anims.
var                 BOOL            m_bChangingWeapon;      
var                 BOOL            m_bIsFiringState;            // Wait until it false to change weapon   
var                 BOOL            m_bPawnIsReloading;        // Used in Native function
var                 BOOL            m_bPawnIsChangingWeapon;   // Used in Native function
var                 BOOL            m_bPawnReloadShotgunLoop;
var(Equip)          eArmor          m_eArmorType;

var                 R6Ladder        m_Ladder;

// -- movement speeds -- // 
var                 FLOAT           m_fWalkingSpeed;
var                 FLOAT           m_fWalkingBackwardStrafeSpeed;

var                 FLOAT           m_fRunningSpeed;
var                 FLOAT           m_fRunningBackwardStrafeSpeed;

var                 FLOAT           m_fCrouchedWalkingSpeed;
var                 FLOAT           m_fCrouchedWalkingBackwardStrafeSpeed;

var                 FLOAT           m_fCrouchedRunningSpeed;
var                 FLOAT           m_fCrouchedRunningBackwardStrafeSpeed;

var                 FLOAT           m_fProneSpeed;
var                 FLOAT           m_fProneStrafeSpeed;

// -- object and actor interaction -- //
var                 Actor           m_potentialActionActor;
var                 R6Door          m_Door;
var                 R6Door          m_Door2;

// Action Mode
var                 R6ClimbableObject m_climbObject;

// peeking data
var                 float           m_fLastValidPeeking;
var                 ePeekingMode    m_eOldPeekingMode;           // used in updatedmovementAnimation  
var                 float           m_fOldCrouchBlendRate;       // used in updatedmovementAnimation 
var                 float           m_fOldPeekBlendRate;         // used in updatedmovementAnimation  
var                 float           m_fPeekingGoalModifier; // modifier of the goal (used by ai). Tween value, 1 == 100% of the goal setted
var                 float           m_fPeekingGoal;         // value that peekingatio reaches (replication) 
var                 float           m_fPeeking;             // current ratio
var                 BOOL            m_bPeekingReturnToCenter;    // when peeking is over, return to center
var                 BOOL            m_bWasPeeking;
var                 BOOL            m_bWasPeekingLeft;

var                 BOOL            m_bAutoClimbLadders;
var                 BOOL            m_bAim; 
var                 BOOL            m_bPostureTransition;
var                 BOOL            m_bWeaponTransition;
var                 BOOL            m_bPawnSpecificAnimInProgress;
var                 BOOL            m_bSoundChangePosture;
var                 BOOL            m_bNightVisionAnimation;

// Sound variable
var                 Sound           m_sndNightVisionActivation;
var                 Sound           m_sndNightVisionDeactivation;
var                 Sound           m_sndCrouchToStand;
var                 Sound           m_sndStandToCrouch;
var                 Sound           m_sndThermalScopeActivation;
var                 Sound           m_sndThermalScopeDeactivation;
var                 Sound           m_sndDeathClothes;
var                 Sound           m_sndDeathClothesStop;

//AK: m_bSuicided should be set to true, this will be used to punish those who suicide in deathmatch and perhaps other game modes
////
var                 BYTE            m_bSuicideType;     // how did the player quit the round/match
////
var                 BOOL            m_bSuicided;

var                 BOOL            m_bAvoidFacingWalls;
var                 BOOL            m_bWallAdjustmentDone;
var                 FLOAT           m_fWallCheckDistance;   // distance to use when checking if wall is too close 


// Used for debug.  This pawn will not treat hearnoise and seeplayer from a human player (m_bIsPlayer == true)
// NB: ** Currently only implemented for terrorist and hostage.
var(Debug)          BOOL            m_bDontSeePlayer;
var(Debug)          BOOL            m_bDontHearPlayer;
var(Debug)          BOOL            m_bUseKarmaRagdoll;

// Death variables
var             BOOL                m_bTerroSawMeDead;      // Set to true as soon as one terrorist saw this dead body
var             R6AbstractCorpse    m_ragdoll;              // Ragdoll controling the bone when dead
var             R6Pawn              m_KilledBy;             // pawn who killed me
var             INT                 m_iForceKill;           // force kill result for testing
var             INT                 m_iForceStun;
var             FLOAT               m_fStunShakeTime;

// Hit variable
var             rotator             m_rHitDirection;

var             Actor           m_TrackActor;

var             rotator         m_rPrevRotationOffset;  // previous rotation offset

//These variables are put here for network.
var             FLOAT               m_fWeaponJump;          // How much the weapon jumps when firing, set when changing weapon
var             FLOAT               m_fZoomJumpReturn;      // jump return factor when zoom

const                               C_iRotationOffsetNormal = 5461; //8192; //16384;
const                               C_iRotationOffsetProne  = 3000;
const                               C_iRotationOffsetBipod  = 5600;
var                 INT             m_iMaxRotationOffset;   // if prone: C_iRotationOffsetProne, otherwise C_iRotationOffsetNormal 

// upright movement animation names
var                 name            m_standRunForwardName;
var                 name            m_standRunLeftName;
var                 name            m_standRunBackName;
var                 name            m_standRunRightName;

var                 name            m_standWalkForwardName;
var                 name            m_standWalkBackName;
var                 name            m_standWalkLeftName;
var                 name            m_standWalkRightName;

// hurt anim
var                 name            m_hurtStandWalkLeftName;
var                 name            m_hurtStandWalkRightName;

// turning animation names
var                 name            m_standTurnLeftName;
var                 name            m_standTurnRightName;

// falling animation names
var                 name            m_standFallName;
var                 name            m_standLandName;
var                 name            m_crouchFallName;
var                 name            m_crouchLandName;

// crouch movement animation names
var                 name            m_crouchWalkForwardName;

// stair walk animation names
var                 name            m_standStairWalkUpName;
var                 name            m_standStairWalkUpBackName;
var                 name            m_standStairWalkUpRightName;
var                 name            m_standStairWalkDownName;
var                 name            m_standStairWalkDownBackName;
var                 name            m_standStairWalkDownRightName;

// stair run animation names
var                 name            m_standStairRunUpName;
var                 name            m_standStairRunUpBackName;
var                 name            m_standStairRunUpRightName;
var                 name            m_standStairRunDownName;
var                 name            m_standStairRunDownBackName;
var                 name            m_standStairRunDownRightName;

// stair crouch animation names
var                 name            m_crouchStairWalkDownName;
var                 name            m_crouchStairWalkDownBackName;
var                 name            m_crouchStairWalkDownRightName;

var                 name            m_crouchStairWalkUpName;
var                 name            m_crouchStairWalkUpBackName;
var                 name            m_crouchStairWalkUpRightName;

var                 name            m_crouchStairRunUpName;
var                 name            m_crouchStairRunDownName;

// Movement noise timer
var                 FLOAT           m_fNoiseTimer;
const C_NoiseTimerFrequency = 0.33f;

var                 Actor           m_FOV;
var                 class<Actor>    m_FOVClass;

var                 name            m_crouchDefaultAnimName; // default name for the anim
var                 name            m_standDefaultAnimName;
var                 name            m_standClimb64DefaultAnimName;
var                 name            m_standClimb96DefaultAnimName;

// Firing start point caching
var                 FLOAT           m_fLastFSPUpdate;
var                 vector          m_vFiringStartPoint;

var                 FLOAT           m_fLastVRPUpdate;
var                 rotator         m_rViewRotation;

var                 BOOL            m_bInteractingWithDevice;   // For the bomb & other devices (computer, keypad, placebug)
var                 BOOL            m_bCanDisarmBomb;           // For the bomb
var                 BOOL            m_bCanArmBomb;              // For the bomb

var                 BOOL            m_bUsingBipod;              // true when prone and the gun have a bipod
var                 INT             m_iRepBipodRotationRatio;   // for replication m_fBipodRotation/C_iRotationOffsetBipod
var                 INT             m_iLastBipodRotation;       // last bipod rotation 
var                 FLOAT           m_fBipodRotation;           // current bipod rotation 

var                 BOOL            m_bLeftFootDown;          // To know which foot is on the floor (use to check the surface) 
var                 FLOAT           m_fTimeStartBodyFallSound;

var                 FLOAT           m_fFiringTimer;

//#ifdefDEBUG
var (DEBUG_Bones) BOOL    m_bModifyBones;
var (DEBUG_Bones) Rotator m_rRoot;
var (DEBUG_Bones) Rotator m_rPelvis;
var (DEBUG_Bones) Rotator m_rSpine;
var (DEBUG_Bones) Rotator m_rSpine1;
var (DEBUG_Bones) Rotator m_rSpine2;
var (DEBUG_Bones) Rotator m_rNeck;
var (DEBUG_Bones) Rotator m_rHead;
var (DEBUG_Bones) Rotator m_rPonyTail1;
var (DEBUG_Bones) Rotator m_rPonyTail2;
var (DEBUG_Bones) Rotator m_rJaw;
var (DEBUG_Bones) Rotator m_rLClavicle;
var (DEBUG_Bones) Rotator m_rLUpperArm;
var (DEBUG_Bones) Rotator m_rLForeArm;
var (DEBUG_Bones) Rotator m_rLHand;
var (DEBUG_Bones) Rotator m_rLFinger0;
var (DEBUG_Bones) Rotator m_rRClavicle;
var (DEBUG_Bones) Rotator m_rRUpperArm;
var (DEBUG_Bones) Rotator m_rRForeArm;
var (DEBUG_Bones) Rotator m_rRHand;
var (DEBUG_Bones) Rotator m_rRFinger0;
var (DEBUG_Bones) Rotator m_rLThigh;
var (DEBUG_Bones) Rotator m_rLCalf;
var (DEBUG_Bones) Rotator m_rLFoot;
var (DEBUG_Bones) Rotator m_rLToe;
var (DEBUG_Bones) Rotator m_rRThigh;
var (DEBUG_Bones) Rotator m_rRCalf;
var (DEBUG_Bones) Rotator m_rRFoot;
var (DEBUG_Bones) Rotator m_rRToe;
//#endif

//R6BLOOD
var eBodyPart m_eLastHitPart;

var BOOL m_bHelmetWasHit;

// Player Diagonal Strafing
var enum eStrafeDirection
{
    STRAFE_None,
    STRAFE_ForwardRight,
    STRAFE_ForwardLeft,
    STRAFE_BackwardRight,
    STRAFE_BackwardLeft
} m_eStrafeDirection;

// rbrek 25 oct 2001
// this flag is used to ensure that the bone rotation that is needed for diagonal movement is only
// done once when the diagonal movement begins, and once when the player returns to normal movement.
var                 BOOL    m_bMovingDiagonally;    

//R6Breathing
var                 Emitter m_BreathingEmitter;

//R6HEARTBEAT
var                 FLOAT m_fHBTime;
var                 FLOAT m_fHBMove;
var                 FLOAT m_fHBWound;
var                 FLOAT m_fHBDefcon;
var                 BOOL  m_bEngaged;
//END R6HEARTBEAT

//R6ArmPatches
var                 bool                    m_bHasArmPatches;
var                 R6ArmPatchGlow          m_ArmPatches[2];

//
var                 INT             m_iUniqueID; // Each pawnthis identifies the character rank within the team (for formation purposes)

// R6CollisionBox
var                 vector          m_vPrePivotProneBackup; // when going prone, backup the value
var                 FLOAT           m_fPrePivotLastUpdate;  // when prone, we do small translation of the prepivot instead of a radical change

// For wait animation Synch
var         BYTE                m_bRepPlayWaitAnim;
var         BYTE                m_bSavedPlayWaitAnim;
var         BYTE                m_byRemainingWaitZero;

// Lipsynch data
var         INT                 m_hLipSynchData;

// Dirty footsteps
var         class<R6FootStep>   m_LeftDirtyFootStep;
var         FLOAT               m_fLeftDirtyFootStepRemainingTime;
var         class<R6FootStep>   m_RightDirtyFootStep;
var         FLOAT               m_fRightDirtyFootStepRemainingTime;

// Friendly Fire
var         BOOL                m_bCanFireFriends;      // when a bullet touch someone, check if the friendly fire can be used
var         BOOL                m_bCanFireNeutrals;

var         FLOAT               m_fTimeGrenadeEffectBeforeSound; // Use for the sound when a pawn enter a smoke grenade or tear gas
          

var         INT                 m_iDesignRandomTweak;
var         INT                 m_iDesignLightTweak;
var         INT                 m_iDesignMediumTweak;
var         INT                 m_iDesignHeavyTweak;
var         BOOL                m_bDesignToggleLog;

// R6CODE
var R6TeamMemberReplicationInfo m_TeamMemberRepInfo;  // used for radar replication
var R6SoundReplicationInfo m_SoundRepInfo; // only used for Audio replication

native(2002) final function eKillResult GetKillResult(INT iKillDamage, INT ePartHit, INT eArmorType, INT iBulletToArmorModifier, BOOL bHitBySilencedWeapon);
native(2003) final function eStunResult GetStunResult(INT iStunDamage, INT ePartHit, INT eArmorType, INT iBulletToArmorModifier, BOOL bHitBySilencedWeapon);
native(2006) final function INT GetThroughResult(INT iKillDamage, INT ePartHit, vector vBulletDirection);
native(2004) final function ToggleHeatProperties(BOOL bTurnItOn, Texture pMaskTexture, Texture pAddTexture);
native(2600) final function ToggleNightProperties(BOOL bTurnItOn, Texture pMaskTexture, Texture pAddTexture);
native(2605) final function ToggleScopeProperties(BOOL bTurnItOn, Texture pMaskTexture, Texture pAddTexture);

// this function is used to set the collision cylinder
native(2200) final function bool AdjustFluidCollisionCylinder(FLOAT fBlendRate, OPTIONAL BOOL bTest ); 
native(2212) final function SetPawnScale(FLOAT fNewScale);

native(1507) final function bool CheckCylinderTranslation( vector vStart, vector vDest, OPTIONAL Actor ignoreActor1, OPTIONAL bool bIgnoreAllActor1Class );
native(1508) final function FLOAT GetPeekingRatioNorm( FLOAT fPeeking );
native(1512) final function INT  GetMaxRotationOffset();
native(1517) final function eMovementDirection GetMovementDirection();
native(2611) final function StartLipSynch(Sound _hSound, Sound _hStopSound);
native(1603) final function StopLipSynch();
native(1846) final function MoveHitBone( rotator rHitDirection, INT iHitBone );
native(1844) final function FootStep( name nBoneName, BOOL bLeftFoot );

native(2214) final function PawnLook(rotator rLookDir, optional bool bAim, optional bool bNoBlend);
native(2215) final function PawnLookAbsolute(rotator rLookDir, optional bool bAim, optional bool bNoBlend);
native(2216) final function PawnLookAt(vector vTarget, optional bool bAim, optional bool bNoBlend);
native(2217) final function PawnTrackActor(Actor Target, optional bool bAim);
native(2218) final function UpdatePawnTrackActor(optional bool bNoBlend);

native(1841) final function rotator R6GetViewRotation();
native(1842) final function rotator GetRotationOffset();
native(1845) final function BOOL PawnCanBeHurtFrom( vector vLocation );  // Check if the pawn can be hurt by an explosion

native(2729) final function SendPlaySound(Sound S, ESoundSlot Id, optional BOOL bDoNotPlayLocallySound);
native(2730) final function PlayVoices(Sound sndPlayVoice, ESoundSlot eSlotUse, INT iPriority, optional ESendSoundStatus eSend, optional BOOL bWaitToFinishSound, optional FLOAT fTime);
native(2731) final function SetAudioInfo();


replication
{
    // for debugging ///////////////////////////////////////////
#ifdefDEBUG
    unreliable if (Role < ROLE_Authority)
        ServerSetBetTime, ServerSetRoundTime, ServerToggleCollision,
        ServerGod; 
#endif

    // function client asks server to do
    unreliable if (Role < ROLE_Authority)
       ServerSwitchReloadingWeapon,
       ServerPerformDoorAction,ServerSuicidePawn,
       ServerPlayReloadAnimAgain;
       
    reliable if (Role < ROLE_Authority)
	   //ServerSurrender, //MissionPack1 2 // MPF1
       ServerGivesWeaponToClient,ServerActionRequest,ServerClimbLadder;  

    // data server sends to client
    unreliable if (Role == ROLE_Authority)
        m_potentialActionActor, m_Ladder, m_bInteractingWithDevice,
        m_KilledBy,m_bHasArmPatches, m_bReloadingWeapon, m_bReloadAnimLoop, m_bRepPlayWaitAnim, m_bIsKneeling,
        m_eDeviceAnim, m_bPawnSpecificAnimInProgress, m_climbObject,
        m_iRepBipodRotationRatio,m_ePlayerIsUsingHands,m_bChangingWeapon,m_fBipodRotation,
        m_iForceKill,m_iForceStun,m_bIsClimbingLadder,
        m_bCanArmBomb, m_bCanDisarmBomb, m_rHitDirection, m_bCanFireFriends, m_bCanFireNeutrals, m_bSuicideType, m_SoundRepInfo,
        m_TeamMemberRepInfo, m_bEngaged;

    // data server sends to client
    reliable if (Role == ROLE_Authority)
		Arrested, ClientSetFree, //MissionPack1 // MPF1
		ClientSurrender, //MissionPack1 2       // MPF1
        m_ePendingAction, m_iPendingActionInt, m_iNetCurrentActionIndex;

    // server update to clients except the owner of the var
    unreliable if (!bNetOwner && (Role == ROLE_Authority))
        m_fPeekingGoal, m_bToggleServerCancelPlacingCharge;

    unreliable if (Role == ROLE_Authority)
       R6ClientAffectedByFlashbang,ClientSetJumpValues;

//    unreliable if (Role == ROLE_Authority)
//        ClientSetDoor;
}

//function ClientSetDoor(R6IActionObject whichDoor, rotator rNewRotation)
//{
//    whichDoor.bRotateToDesired = true;
//    whichDoor.desiredRotation = rNewRotation;
//    if(bShowLog) log("AK: we want to rotate to "$whichDoor.desiredRotation$" current rotation is "$whichDoor.rotation);
//}

simulated event ZoneChange(ZoneInfo NewZone)
{
    local int              i;
    local PlayerController PC;
    local ZoneInfo         WZ;

    if(Level.m_WeatherEmitter == none || Level.m_WeatherEmitter.Emitters.Length == 0)
        return;

    PC = PlayerController(Controller);
    if(PC == none || Viewport(PC.Player) == none)
        return;

    // disable old zone alternate weather emitters
    WZ = Region.Zone;
    if(WZ.m_bAlternateEmittersActive)
    {
        for(i=0; i<WZ.m_AlternateWeatherEmitters.Length; i++)
        {
            if(WZ.m_AlternateWeatherEmitters[i] != none && WZ.m_AlternateWeatherEmitters[i].Emitters.Length > 0)
            {
                WZ.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 1;
                WZ.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
            }
        }
        WZ.m_bAlternateEmittersActive = false;
    }

    // enable new zone alternate weather emitters
    if(!NewZone.m_bAlternateEmittersActive)
    {
        for(i=0; i<NewZone.m_AlternateWeatherEmitters.Length; i++)
        {
            if(NewZone.m_AlternateWeatherEmitters[i] != none && NewZone.m_AlternateWeatherEmitters[i].Emitters.Length > 0)
            {
                NewZone.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 0;
                NewZone.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
            }
        }
        NewZone.m_bAlternateEmittersActive = true;
    }
}

//------------------------------------------------------------------
// ProcessBuildDeathMessage
//  return true if the build death msg can be build by "static BuildDeathMessage"
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage( Pawn Killer, OUT string szPlayerName )
{
    szPlayerName = "";
    if( PlayerReplicationInfo != none )
    {
        szPlayerName = PlayerReplicationInfo.PlayerName;
        return true;
    }
        
    return false;
}

static function string BuildDeathMessage(string Killer, string Killed, byte bDeathMsgType )
{
    local String DeathMessage;

    if (bDeathMsgType == DEATHMSG_CONNECTIONLOST)
    {
        DeathMessage = Killed $ " " $Localize("MPDeathMessages", "LeftTheGame", "R6GameInfo");
    }
    else if (bDeathMsgType == DEATHMSG_PENALTY)
    {
        DeathMessage = "" $Localize("MPDeathMessages", "PenaltyTo", "R6GameInfo")$ " " $Killer;
    }
    else if ( bDeathMsgType == DEATHMSG_HOSTAGE_DIED )  // before suicide and bomb
    {
        DeathMessage = Localize("MPDeathMessages", "HostageHasDied", "R6GameInfo");
    }
    else if ((bDeathMsgType == DEATHMSG_KILLED_BY_BOMB)) // before suicide
    {
        DeathMessage = Killer $" "$ Localize("MPDeathMessages", "PlayerKilledByBomb", "R6GameInfo");
    }
    else if ( bDeathMsgType == DEATHMSG_HOSTAGE_KILLEDBYTERRO )  // before suicide
    {
        DeathMessage = Killer $" "$ Localize("MPDeathMessages", "TerroKilledHostage", "R6GameInfo");
    }
    else if ((bDeathMsgType == DEATHMSG_KAMAKAZE) || (Killer == Killed))
    {
        DeathMessage = Killer $" "$ Localize("MPDeathMessages", "PlayerSuicided", "R6GameInfo");
    }
    else if ( bDeathMsgType == DEATHMSG_HOSTAGE_KILLEDBY)
    {
        DeathMessage = Killer $" "$ Localize("MPDeathMessages", "KilledAHostage", "R6GameInfo");
    }
    else if ( bDeathMsgType == DEATHMSG_RAINBOW_KILLEDBYTERRO )
    {
        DeathMessage = Localize("MPDeathMessages", "TerroKilledPlayer", "R6GameInfo") $" "$ Killed;
    }
    else
    {
        if ( bDeathMsgType == DEATHMSG_INTRUDER_KILLEDBY )
            DeathMessage = Killer $" "$ Localize("MPDeathMessages", "KilledTheIntruder", "IronWrathGameInfo");
        else
            DeathMessage = Killer $" "$ Localize("MPDeathMessages", "PlayerKilledPlayer", "R6GameInfo") $" "$ Killed;
    }

    return DeathMessage;
}

//------------------------------------------------------------------
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//------------------------------------------------------------------
simulated function logX( string szText )
{
    local string szSource;
	local string time;

    if(Controller!=None)
    {
        Controller.logX( szText, 1 );
    }
    else
    {
        time = string(Level.TimeSeconds);
	    time = Left(Time, InStr(Time, ".") + 3); // 2 digits after the dot
        szSource = "(" $time$ ":P) ";    // pawn
        log( szSource $ name $ " [ None |" $ GetStateName() $ "] " $ szText );
    }
}

//------------------------------------------------------------------
// logWarning: important log to catch (ie: they should not happen,
//  and the don't have bShowLog in front of them)
//------------------------------------------------------------------
simulated function logWarning( string text )
{
    log(" *********************************************************************************** ");
    logX(" WARNING!!! " $text );
    log(" *********************************************************************************** ");
}

//============================================================================
//                  ##                            
//  #####   ##  #        ####   ####   #####   
//  ##      ## #    ##    ##     ##    ##      
//  ####    ###     ##    ##     ##    ####    
//     ##   ## #    ##    ##     ##       ##   
//  ####    ##  #   ##   ####   ####   ####    
//============================================================================
event FLOAT GetSkill( ESkills eSkillName )
{
    local FLOAT fSkill;
    local FLOAT fLevelMul;

    switch(eSkillName)
    {
        case SKILL_Assault:
            fSkill = m_fSkillAssault;       break;
        case SKILL_Demolitions:
            fSkill = m_fSkillDemolitions;   break;
        case SKILL_Electronics:
            fSkill = m_fSkillElectronics;   break;
        case SKILL_Sniper:
            fSkill = m_fSkillSniper;        break;
        case SKILL_Stealth:
            fSkill = m_fSkillStealth;       break;
        case SKILL_SelfControl:
            fSkill = m_fSkillSelfControl;   break;
        case SKILL_Leadership:
            fSkill = m_fSkillLeadership;    break;
        case SKILL_Observation:
            fSkill = m_fSkillObservation;   break;
    }

    fLevelMul = 1.0f;
    if(!m_bIsPlayer)
    {
        if(m_ePawnType==PAWN_Terrorist)
            fLevelMul = Level.m_fTerroSkillMultiplier;
        else if(m_ePawnType==PAWN_Rainbow)
            fLevelMul = Level.m_fRainbowSkillMultiplier;
    }

    return SkillModifier() * fSkill * fLevelMul;
}

function FLOAT SkillModifier()
{
    local FLOAT fFactor;

    fFactor = 1.0;
    if(m_eHealth == HEALTH_Wounded)
        fFactor *= 0.75;

    if(m_eEffectiveGrenade==GTYPE_TearGas)
        fFactor *= 0.75;

    return fFactor;
}

function FLOAT ArmorSkillEffect()
{
    return 1.0;
}
//== 3Nd 5Ki775 ==============================================================

function IncrementBulletsFired();

function ClientSetJumpValues(FLOAT fNewValue)
{
    m_fWeaponJump = fNewValue;
    m_fZoomJumpReturn = 1.0;
}

//------------------------------------------------------------------
// HasBumpPriority: return true if this pawn has bump priority
//  over bumpedBy. This is used when the pawn is NOT stationary so he 
//  should get out of the way
//------------------------------------------------------------------
function bool HasBumpPriority( R6Pawn bumpedBy )
{
    return true; 
}

//============================================================================
// R6MakeMovementNoise - Make a noise every X second
//============================================================================
event R6MakeMovementNoise()
{
    // If on a client in a network game, GameInfo is none
    if(R6AbstractGameInfo(Level.Game)!=None)
    {
        R6AbstractGameInfo(Level.Game).GetNoiseMgr().R6MakePawnMovementNoise( Self );
    }
}

//R6BLOOD
simulated event R6DeadEndedMoving()
{
    local bool bSpawnBloodBath;
    local vector vBloodBathLocation;
    local rotator rBloodBathRotation;
    local vector vFloorLocation;
    local vector vFloorNormal;
    local vector vTraceEnd;

    bProjTarget = false;
    //SetCollision(false, false, false);

    if(Level.NetMode != NM_DedicatedServer)
    {
        SendPlaySound(m_sndDeathClothesStop, SLOT_SFX);
        // Spawn blood bath
        switch(m_eLastHitPart)
        {
        case BP_Head:
            bSpawnBloodBath = true;
            vBloodBathLocation = GetBoneCoords('R6 Head', true).Origin;
            break;
        case BP_Chest:
            bSpawnBloodBath = true;
            vBloodBathLocation = GetBoneCoords('R6 Spine2', true).Origin;
            break;
        case BP_Abdomen:
            bSpawnBloodBath = true;
            vBloodBathLocation = GetBoneCoords('R6 Spine', true).Origin;
            break;
        case BP_Legs:
            bSpawnBloodBath = false;
            break;
        case BP_Arms:
            bSpawnBloodBath = false;
            break;
        }

        if(bSpawnBloodBath == true)
        {
            rBloodBathRotation.Pitch = -16384;
            rBloodBathRotation.Yaw = 0;
            rBloodBathRotation.Roll = Rand(65535);

            vTraceEnd = vBloodBathLocation + vector(rBloodBathRotation) * 250;
            if(Trace(vFloorLocation, vFloorNormal, vTraceEnd, vBloodBathLocation) != none)
            {
                vFloorLocation.Z += 4;
                Level.m_DecalManager.AddDecal(vFloorLocation, rBloodBathRotation, texture'Inventory_t.BloodSplats.BloodBath', DECAL_BloodBaths, 1, 0, 0, 50);
            }
        }
    }
}

simulated function DestroyShadow()
{
    local ShadowProjector aShadowProjector;

    if ( Shadow != none )
    {
        aShadowProjector = ShadowProjector(Shadow);
        if ( aShadowProjector != none )
        {
            aShadowProjector.ShadowActor = none;
            if ( aShadowProjector.ShadowTexture != none )
                aShadowProjector.ShadowTexture.ShadowActor = none;
        }
        Shadow.Destroy();
        Shadow = none;
    }
}

simulated function FirstPassReset()
{
    m_KilledBy = none;
}

simulated event Destroyed()
{
    local INT iCounter;
    local Actor A;
    local R6PlayerController aPC;

    if ( m_collisionBox != none )
    {
        A = m_collisionBox;
        m_collisionBox = none;
        A.Destroy();
        A = none;
    }

    if ( m_collisionBox2 != none )
    {
        A = m_collisionBox2;
        m_collisionBox2 = none;
        A.Destroy();
        A = none;
    }

    aPC = R6PlayerController(Controller);
    if( aPC != none && aPC.m_TeamManager!=none )
        aPC.m_TeamManager.ResetTeam();

    Super.Destroyed();
    for (iCounter=0; iCounter<4; iCounter++)
    {
        if (m_WeaponsCarried[iCounter] != none)
        {
            m_WeaponsCarried[iCounter].destroy();
            m_WeaponsCarried[iCounter] = none;
        }
    }

    //R6ArmPatches
    for(iCounter=0; iCounter<2; iCounter++)
    {
        if(m_ArmPatches[iCounter] != none)
        {
            m_ArmPatches[iCounter].Destroy();
            m_ArmPatches[iCounter] = none;
        }
    }

    if(m_SoundRepInfo != none)
    {
        m_SoundRepInfo.Destroy();
        m_SoundRepInfo = none;
    }

    if (EngineWeapon != none)
    {
        EngineWeapon.destroy();
        EngineWeapon = none;
    }

    if ( m_pBulletManager != none )
    {
         m_pBulletManager.destroy();
         m_pBulletManager = none;
    }

    if(m_TeamMemberRepInfo != none)
    {
        m_TeamMemberRepInfo.Destroy();
        m_TeamMemberRepInfo = none;
    }

    if(m_BreathingEmitter != none)
    {
        if ( m_BreathingEmitter.Emitters.Length != 0 )
        {
            m_BreathingEmitter.Emitters[0].AllParticlesDead = false;
            m_BreathingEmitter.Emitters[0].m_iPaused = 1;
        }
        DetachFromBone(m_BreathingEmitter);
        m_BreathingEmitter.Destroy();
        m_BreathingEmitter = none;
    }

    ForEach AllActors(class 'Actor', A)
    {
        if(A.Instigator == Self)
            A.Instigator = none;
    }
}    

function Rotator GetFiringRotation()
{
    return GetViewRotation();
}

function vector GetHandLocation()
{
    return(GetBoneCoords( 'R6 R Hand' ).Origin);
}

event vector GetFiringStartPoint()
{    
    if( m_fLastFSPUpdate != Level.TimeSeconds )
    {
        m_fLastFSPUpdate = Level.TimeSeconds;
        m_vFiringStartPoint = Location + EyePosition();        
    }
    return m_vFiringStartPoint;
}

function vector GetGrenadeStartLocation(eGrenadeThrow eThrow)
{
    local vector vStart;

    vStart = location + EyePosition(); 
    if(eThrow == GRENADE_PeekLeft || eThrow == GRENADE_PeekRight || eThrow == GRENADE_Roll)
    {
        if(m_bIsProne)
            vStart -= vect(0,0,10);
        else if(bIsCrouched)
            vStart -= vect(0,0,30); 
        else
            vStart -= vect(0,0,40);
    }

    return vStart;
}


function RenderGunDirection( Canvas c )
{
    c.Draw3DLine(   GetFiringStartPoint(),
                    GetFiringStartPoint() + vector(GetFiringRotation())*10000,
                    class'Canvas'.Static.MakeColor(255,0,0) );
}

function DrawViewRotation( Canvas c )
{
    c.Draw3DLine( location + EyePosition(), location + EyePosition() + 70*vector(GetViewRotation()), class'Canvas'.Static.MakeColor(255,0,0));
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
    if ( Physics == PHYS_Ladder )       
    {
        if(OnLadder != none)
            SetRotation(OnLadder.LadderList.Rotation);      // OnLadder.rotation is always (0,0,0)
        else if(Level.NetMode != NM_Standalone)
        {       
            // rbrek - fix for multiplayer, not pretty (todo)
            m_bPostureTransition = false;
            R6ResetAnimBlendParams(C_iBaseBlendAnimChannel);
            SetPhysics(PHYS_Walking);
        }
    }
    else
    {
        if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) || (Physics == PHYS_RootMotion) )
            NewRotation.Pitch = 0;
        SetRotation(NewRotation);
    }
}

//===================================================================================================
// function PossessedBy()                                               
//===================================================================================================
function PossessedBy(Controller C)
{
    Super.PossessedBy(C);
    if(controller.IsA('PlayerController'))
    {
        m_bIsPlayer = true;
        AvoidLedges(false);
    }
    else
    {       
        AvoidLedges(true);
    }

    if (m_SoundRepInfo != none)
        m_SoundRepInfo.m_PawnRepInfo = Controller.m_PawnRepInfo;

    // Set the focal point so that the pawn doesn't turn
    Controller.FocalPoint = Location + vector(Rotation); 
}


//------------------------------------------------------------------
// SetDefaultWalkAnim();
//  
//------------------------------------------------------------------
function SetDefaultWalkAnim()
{
    // stand walk anim
    m_standWalkForwardName   = default.m_standWalkForwardName;
    m_standWalkBackName      = default.m_standWalkBackName;
    m_standWalkLeftName      = default.m_standWalkLeftName;
    m_standWalkRightName     = default.m_standWalkRightName;
    m_standTurnLeftName      = default.m_standTurnLeftName;
    m_standTurnRightName     = default.m_standTurnRightName;
    m_standRunForwardName    = default.m_standRunForwardName;
    m_standRunLeftName       = default.m_standRunLeftName;
    m_standRunBackName       = default.m_standRunBackName;
    m_standRunRightName      = default.m_standRunRightName;
    m_standDefaultAnimName   = default.m_standDefaultAnimName;
    m_standClimb64DefaultAnimName = default.m_standClimb64DefaultAnimName;
    m_standClimb96DefaultAnimName = default.m_standClimb96DefaultAnimName;

    m_standStairWalkUpName   = default.m_standStairWalkUpName;
    m_standStairWalkDownName = default.m_standStairWalkDownName;
}


//===================================================================================================
// function PostNetBeginPlay()
//===================================================================================================
simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    #ifdefDEBUG if(bShowLog) log("PostNetBeginPlay - R6Pawn: "$ self); #endif

    if( Level.NetMode != NM_Client )
    {
        m_iLocalCurrentActionIndex = 0;
        m_iNetCurrentActionIndex = 0;
    }

	// controller has not been spawned yet
    if (controller == none)
        return;

    if( (controller.IsA('PlayerController') ) &&
        (PlayerController(controller).Player != none) && 
        (PlayerController(controller).Player.IsA('ViewPort')) )
    {
        m_bIsPlayer = true;
    }
}

simulated event PostBeginPlay()
{
    local INT iCounter;
    local R6GameOptions GameOptions;

    GameOptions = GetGameOptions();
    
    Super.PostBeginPlay();
    
    if(Role == ROLE_Authority)
    {
        R6AbstractGameInfo(Level.Game).SetPawnTeamFriendlies(self);

        if ( m_SoundRepInfo == none )
            m_SoundRepInfo = Spawn(class'R6SoundReplicationInfo');
        m_SoundRepInfo.m_PawnOwner = Self;
        m_SoundRepInfo.m_NewWeaponSound = 1; // WSOUND_Initialize
        m_fHeartBeatTime[0] = Rand(1000/(m_fHeartBeatFrequency/60));
        m_fHeartBeatTime[1] = m_fHeartBeatTime[0];
    }
    if(Level.NetMode != NM_DedicatedServer)
    {
        //R6ArmPatches
        if(m_bHasArmPatches)
        {
            if ( m_ArmPatches[0] == none )
                m_ArmPatches[0] = Spawn(class'R6ArmPatchGlow');
            m_ArmPatches[0].m_pOwnerNightVision = self;
            m_ArmPatches[0].m_AttachedBoneName = 'R6 L UpperArm';
            m_ArmPatches[0].m_fMatrixMul = 1.0;
            if ( m_ArmPatches[1] == none )
                m_ArmPatches[1] = Spawn(class'R6ArmPatchGlow');
            m_ArmPatches[1].m_pOwnerNightVision = self;
            m_ArmPatches[1].m_AttachedBoneName = 'R6 R UpperArm';
            m_ArmPatches[1].m_fMatrixMul = -1.0;
        }

        //R6Breath
        if(Level.m_BreathingEmitterClass != none && m_BreathingEmitter == none)
        {
            m_BreathingEmitter = Spawn(Level.m_BreathingEmitterClass);
            if(m_BreathingEmitter != none)
            {
                AttachToBone(m_BreathingEmitter, 'R6 Head');
                m_BreathingEmitter.SetRelativeLocation(vect(0,-20,0));
            }
        }

        //R6SHADOW
        if(class'Actor'.static.IsVideoHardwareAtLeast64M() &&
           ((m_ePawnType == PAWN_Rainbow && GameOptions.RainbowsShadowLevel == eEL_High) ||
            (m_ePawnType == PAWN_Hostage && GameOptions.HostagesShadowLevel == eEL_High) ||
            (m_ePawnType == PAWN_Terrorist && GameOptions.TerrosShadowLevel == eEL_High)))
        { // Projected shadow
            if ( Shadow == none )
            {
                Shadow = Spawn(class'ShadowProjector', Self, '', Location);
                ShadowProjector(Shadow).ShadowActor = Self;
                ShadowProjector(Shadow).UpdateShadow();
            }
        }
        else if((m_ePawnType == PAWN_Rainbow && GameOptions.RainbowsShadowLevel != eEL_None) ||
                (m_ePawnType == PAWN_Hostage && GameOptions.HostagesShadowLevel != eEL_None) ||
                (m_ePawnType == PAWN_Terrorist && GameOptions.TerrosShadowLevel != eEL_None))
        { // Simple shadow
            if ( Shadow == none )
                Shadow = Spawn(class'R6ShadowProjector', self);
        }
    }

    m_iMaxRotationOffset = GetMaxRotationOffset();

    // forces to have info in this channel to prevent the first peeking to be too fast
    R6BlendAnim( m_standDefaultAnimName, C_iPeekingAnimChannel, 0, 'R6 Spine', 0, 0, true );

    // Initialize eye location with an aproximative value
    m_vEyeLocation = Location;
    m_vEyeLocation.Z += 70;
}

event TornOff()
{
    local INT i;

    DropWeaponToGround();

    for(i=0; i<4; i++)
    {
        if(m_WeaponsCarried[i]!=none)
            m_WeaponsCarried[i].SetTearOff(true);
    }
}

#ifdefDEBUG
simulated function UpdateBones()
{
    if (m_bModifyBones)
    { 
        SetBoneRotation('R6',           m_rRoot,, 1.0);
        SetBoneRotation('R6 Pelvis',    m_rPelvis,, 1.0);
        SetBoneRotation('R6 Spine',     m_rSpine,, 1.0);
        SetBoneRotation('R6 Spine1',    m_rSpine1,, 1.0);
        SetBoneRotation('R6 Spine2',    m_rSpine2,, 1.0);
        SetBoneRotation('R6 Neck',      m_rNeck,, 1.0);
        SetBoneRotation('R6 Head',      m_rHead,, 1.0);
        SetBoneRotation('R6 PonyTail1', m_rPonyTail1,, 1.0);
        SetBoneRotation('R6 PonyTail2', m_rPonyTail2,, 1.0);
        SetBoneRotation('R6 Jaw',       m_rJaw,, 1.0);
        SetBoneRotation('R6 L Clavicle', m_rLClavicle,, 1.0);
        SetBoneRotation('R6 L UpperArm', m_rLUpperArm,, 1.0);
        SetBoneRotation('R6 L Forearm',  m_rLForeArm,, 1.0);
        SetBoneRotation('R6 L Hand',     m_rLHand,, 1.0);
        SetBoneRotation('R6 L Finger0',  m_rLFinger0,, 1.0);
        SetBoneRotation('R6 R Clavicle', m_rRClavicle,, 1.0);     
        SetBoneRotation('R6 R UpperArm', m_rRUpperArm,, 1.0);
        SetBoneRotation('R6 R Forearm',  m_rRForeArm,, 1.0);
        SetBoneRotation('R6 R Hand',     m_rRHand,, 1.0);
        SetBoneRotation('R6 R Finger0',  m_rRFinger0,, 1.0);
        SetBoneRotation('R6 L Thigh',    m_rLThigh,, 1.0);
        SetBoneRotation('R6 L Calf',     m_rLCalf,, 1.0);
        SetBoneRotation('R6 L Foot',     m_rLFoot,, 1.0);
        SetBoneRotation('R6 L Toe',      m_rLToe,, 1.0);
        SetBoneRotation('R6 R Thigh',    m_rRThigh,, 1.0);
        SetBoneRotation('R6 R Calf',     m_rRCalf,, 1.0);
        SetBoneRotation('R6 R Foot',     m_rRFoot,, 1.0);
        SetBoneRotation('R6 R Toe',      m_rRToe,, 1.0);
    }
}
#endif

simulated function UpdateVisualEffects(float fDeltaTime)
{
    // breath effect
    if(m_BreathingEmitter != none)
    {
        m_BreathingEmitter.Emitters[0].AllParticlesDead = false;
        m_BreathingEmitter.Emitters[0].m_iPaused = INT(Region.Zone.m_bInDoor);
    }

    // dirty footsteps
    if(m_LeftDirtyFootStep != none)
    {
        m_fLeftDirtyFootStepRemainingTime -= fDeltaTime;
        if(m_fLeftDirtyFootStepRemainingTime <= 0.0)
        {
            m_LeftDirtyFootStep = none;
            m_fLeftDirtyFootStepRemainingTime = 0.0;
        }
    }

    if(m_RightDirtyFootStep != none)
    {
        m_fRightDirtyFootStepRemainingTime -= fDeltaTime;
        if(m_fRightDirtyFootStepRemainingTime <= 0.0)
        {
            m_RightDirtyFootStep = none;
            m_fRightDirtyFootStepRemainingTime = 0.0;
        }
    }
}

simulated function Tick( float DeltaTime )
{
    local float tempDelta;
    local float sign;
    local float fHeartBeatRateMAX;
    local float fHeartBeatRateMIN;
    local float fHeartBeatFrequency;

    super.Tick(DeltaTime);

    if(m_fDecrementalBlurValue > 0)
    {
        m_fDecrementalBlurValue -= DeltaTime * 8.0f;
        m_fDecrementalBlurValue = Max(m_fDecrementalBlurValue, 0.0f);
    }

    if (Role<ROLE_Authority)
    {
        if (m_bRepPlayWaitAnim!=m_bSavedPlayWaitAnim)
        {
            m_bSavedPlayWaitAnim=m_bRepPlayWaitAnim;
            PlayWaiting();
        }
    }

    // If helmet was hit, reset the value on the server only
    if (Role == ROLE_Authority && m_bHelmetWasHit == true)
    {
        m_bHelmetWasHit=false;
    }

    //R6HeartBeat
    m_fHBTime += DeltaTime;

    if(m_fHBTime > 1.0f)
    {
        m_fHBTime = m_fHBTime - 1.0f;
        if ( m_ePawnType == PAWN_Terrorist )
        {
            fHeartBeatRateMAX = C_iHeartRateMaxTerrorist;
            fHeartBeatRateMIN = C_iHeartRateMinTerrorist;
        }
        else
        {
            fHeartBeatRateMAX = C_iHeartRateMaxOther;
            fHeartBeatRateMIN = C_iHeartRateMinOther;
        }

        fHeartBeatFrequency = fHeartBeatRateMIN * m_fHBMove * m_fHBWound * m_fHBDefcon;
        if(m_bEngaged)
            fHeartBeatFrequency *= 1.2;

        if (fHeartBeatFrequency > m_fHeartBeatFrequency)
        {
            m_fHeartBeatFrequency+=5;
            if (m_fHeartBeatFrequency > fHeartBeatRateMAX)
            {
                m_fHeartBeatFrequency = fHeartBeatRateMAX;
            }
        }
        else
        {
            if (fHeartBeatFrequency < m_fHeartBeatFrequency)
            {
                m_fHeartBeatFrequency-=1;
            }            
        }
    }

    UpdateVisualEffects(DeltaTime);
}

//============================================================================
// event rotator GetViewRotation - 
//============================================================================
simulated event rotator GetViewRotation()
{
// gborgia - 17 oct 2001 - Moved to native code
    return R6GetViewRotation();
}

//===================================================================================================
// rbrek - 12 nov 2001
// for NPCS (non-player pawns)
// set the m_rRotationOffset using this function; uses m_rPrevRotationOffset in order to keep track of 
// previous rotationOffset
//===================================================================================================
simulated event SetRotationOffset(INT iPitch, INT iYaw, INT iRoll)
{
    m_fBoneRotationTransition = 0.f;
    m_rPrevRotationOffset = m_rRotationOffset;
    m_rRotationOffset.pitch = iPitch;
    m_rRotationOffset.yaw = iYaw;
    m_rRotationOffset.roll = iRoll;
}

//===================================================================================================
// EyePosition() 
//  Returns the offset for the eye from the Pawn's location at which to place the camera or to start
//  the line of sight 
// rbrek - 19 July 2001 - Originally defined in Pawn.uc.  Overridden here in order to 
//   include the proper offset due to peeking and/or fluid crouching...
//===================================================================================================
simulated event vector EyePosition()
{
    local vector vEyeHeight;
    local PlayerController pc;

    if(m_bIsPlayer)
    {
        //if (bShowLog) log("EYEPOSITION: m_vEyeLocation = "$m_vEyeLocation$" and location = "$location);
        pc = PlayerController(Controller);
        if(pc!=none && !pc.bBehindView && pc.ViewTarget==self)
            return (m_vEyeLocation - Location);
    }

    if(bIsCrouched)
        vEyeHeight.Z = 30;
    else if(m_bIsProne)
        vEyeHeight.Z = 0;
    else if(m_bIsKneeling)
        vEyeHeight.Z = 20;
    else
        vEyeHeight.Z = 70;

    return vEyeHeight;
}

//===================================================================================================
// R6CalcDrawLocation() 
// rbrek 23 nov 2001
// obtains the true location of the eyes based on the location of the 'R6 PonyTail1' bone.  
// uses the same information that the 1st person camera uses.
//===================================================================================================
simulated function vector R6CalcDrawLocation(R6EngineWeapon Wep, out rotator MoveRotation, vector Offset)
{
    local vector drawLocation;
    local vector bobOffset;
    local vector    vAxisX;
    local vector    vAxisY;
    local vector    vAxisZ;

    drawLocation = location;
    if ( (Level.NetMode == NM_DedicatedServer) 
        || ((Level.NetMode == NM_ListenServer) && (RemoteRole == ROLE_AutonomousProxy)) )
    {
        drawLocation += EyePosition();
    }
    else
    {   
        // rbrek 26 nov 2001 - use true eyeposition for placing 1st person gun...
        if(R6PlayerController(controller).m_bAttachCameraToEyes)
        {
            drawLocation = m_vEyeLocation;  
        }
        else
        {
            drawLocation = location + EyePosition();
        }

        GetAxes(GetViewRotation(),vAxisX,vAxisY,vAxisZ);

        drawLocation.X += (vAxisX.X * Offset.X) + (vAxisY.X * Offset.Y) + (vAxisZ.X * Offset.Z);
        drawLocation.Y += (vAxisX.Y * Offset.X) + (vAxisY.Y * Offset.Y) + (vAxisZ.Y * Offset.Z);
        drawLocation.Z += (vAxisX.Z * Offset.X) + (vAxisY.Z * Offset.Y) + (vAxisZ.Z * Offset.Z);
    }
    return drawLocation;
}

simulated function RotateBone(name boneName, int pitch, int yaw, int roll, optional float InTime)
{
    local rotator rOffset;

    rOffset.pitch = pitch;
    rOffset.yaw = yaw;
    rOffset.roll = roll;
    SetBoneRotation(boneName, rOffset,, 1.0, InTime);
}

simulated function ResetBoneRotation()
{
    SetBoneRotation('R6 PonyTail1', rot(0,0,0),, 1.0, 0.4);
    SetBoneRotation('R6 Head', rot(0,0,0),, 1.0, 0.4);  // add later if necessary...
    SetBoneRotation('R6 Spine', rot(0,0,0),, 1.0, 0.4);
    SetBoneRotation('R6 Spine1', rot(0,0,0),, 1.0, 0.4);
    SetBoneRotation('R6 Neck', rot(0,0,0),, 1.0, 0.4);
    SetBoneRotation('R6 R Clavicle', rot(0,0,0),, 1.0, 0.4); 
    SetBoneRotation('R6 L Clavicle', rot(0,0,0),, 1.0, 0.4); 
}

function AimUp()
{
    ResetBoneRotation();
    SetBoneRotation('R6 Spine', rot(0,-3000,0),, 1.0);
    SetBoneRotation('R6 Neck', rot(0,-4000,0),, 1.0);
}

function AimDown()
{
    ResetBoneRotation();
    SetBoneRotation('R6 Spine', rot(0,3000,0),, 1.0);
    SetBoneRotation('R6 Neck', rot(0,3000,0),, 1.0);
}

function bool IsWalking()
{
    return bIsWalking && (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y + Velocity.Z * Velocity.Z > 1000);
}

function bool IsRunning()
{
    return !bIsWalking && (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y + Velocity.Z * Velocity.Z > 1000);
}

function bool IsMovingForward()
{
    if ( velocity == vect(0,0,0) )
        return true;
    if(normal(velocity) dot vector(rotation) > 0.5)
        return true;
    else
        return false;
}

function bool IsMovingUpLadder()
{
    if(velocity.z > 0)
        return true;
    else
        return false;
}

simulated event AnimEnd(int iChannel)
{
    if( iChannel == C_iBaseAnimChannel )
    {       
        if ( physics != PHYS_RootMotion )       
        {
            PlayWaiting();
        }
    }
    else if((iChannel == C_iBaseBlendAnimChannel) && m_bPostureTransition)
    {
        m_bSoundChangePosture=false;        
        m_bIsLanding = false;
        m_bPostureTransition = false;       
    }
    else if ((iChannel == C_iWeaponRightAnimChannel) && m_bWeaponTransition)
    {
        m_bWeaponTransition = false;
        if (m_eGrenadeThrow != GRENADE_RemovePin) // To stay in the last frame of this animation don't call the PlayWeaponAnimation
        {
            PlayWeaponAnimation();
        }

    }
}

//===================================================================================================
// R6LoopAnim()
//   can be used instead of calling LoopAnim directly, so that tweening is done automatically
//   if the requested animation differs from the current one
//===================================================================================================
simulated function R6LoopAnim(name animName, optional FLOAT fRate, optional FLOAT fTween)
{
    if(fRate == 0)
        fRate = 1.0;

    if(fTween == 0)
        fTween = 0.25;

    LoopAnim(animName, fRate, fTween);
}

//===================================================================================================
// R6PlayAnim()
//   can be used instead of calling LoopAnim directly, so that tweening is done automatically
//   if the requested animation differs from the current one
//===================================================================================================
simulated function R6PlayAnim(name animName, optional FLOAT fRate, optional FLOAT fTween)
{  
    if(fRate == 0)
        fRate = 1.0;

    if(fTween == 0)
        fTween = 0.25;

    PlayAnim(animName, fRate, fTween);
}

//===================================================================================================
// R6BlendAnim()
//===================================================================================================
simulated function R6BlendAnim(name animName, INT iBlendChannel, FLOAT fBlendAlpha, optional name boneName, optional FLOAT fRate, optional FLOAT fTween, optional BOOL bPlayOnce )
{ 
    if(fRate == 0.0)
        fRate = 1.0;

    if(fTween == 0.0)
        fTween = 0.2;

    AnimBlendParams(iBlendChannel, fBlendAlpha, 0.0, 0.0, boneName);

    if( !bPlayOnce )
    {
        LoopAnim(animName, fRate, fTween, iBlendChannel);
    }
    else
    {
        PlayAnim(animName, fRate, fTween, iBlendChannel);
    }
}

//===================================================================================================
// R6ResetAnimBlendParams()
//   reset the blend parameters for a specific channel
//===================================================================================================
simulated function R6ResetAnimBlendParams(INT iBlendChannel)
{
    AnimBlendParams(iBlendChannel, 0.0, 0.0, 0.0);
    ClearChannel( iBlendChannel );
}

//===================================================================================================
// rbrek 12 nov 2001
// PlayRootMotionAnimation()
//   used to play an uncompressed animation using Root Motion
//===================================================================================================
simulated function PlayRootMotionAnimation(name animName, optional FLOAT fRate)
{
    if(fRate == 0.0f)
        fRate = 1.0f;

    // make sure that channel 1 is cleared (MP bug)
    m_bPostureTransition = false;
    R6ResetAnimBlendParams(C_iBaseBlendAnimChannel);
    #ifdefDEBUG if(bShowLog) log(self$" PlayRootMotionAnimation() animName="$animName);    #endif 
    PlayAnim(animName, fRate);
    SetPhysics(PHYS_RootMotion);    
    bCollideWorld = false;
}

//===================================================================================================
// rbrek 12 nov 2001
// PlayPostRootMotionAnimation()
//   used to reset the mode after using root motion, and to play a regular compressed animation 
//===================================================================================================
simulated function PlayPostRootMotionAnimation(name animName)
{
    m_ePlayerIsUsingHands = HANDS_None;
    bCollideWorld = true;
    SetPhysics(PHYS_Walking);
    #ifdefDEBUG if(bShowLog) log(self$" PlayPostRootMotionAnimation() animName="$animName); #endif
    m_bPostureTransition = true;
    AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);
    PlayAnim(animName, 1.4, 0.0, C_iBaseBlendAnimChannel);      // must use zero tween time here...
}

//===================================================================================================
//                                  rbrek 12 nov 2001
//                      ===      ROOT MOTION ANIMATIONS     ===
//===================================================================================================


function StartClimbObject( R6ClimbableObject climbObj )
{
    /* // R6CLIMBABLEOBJECT
    #ifdefDEBUG if( bShowLog ) logX( "StartClimbObject : m_climbObject="$m_climbObject$ " climbObj=" $climbObj ); #endif

    // if climbing an object 
    if ( m_climbObject != none || climbObj == none ) 
        return;

    if ( m_bIsPlayer || (Level.NetMode != NM_Standalone) )
    {
        m_climbObject = climbObj;
        R6PlayerController(Controller).GotoState( 'PlayerClimbObject' );
    }
    else
    {
        R6AIController(Controller).GotoClimbObjectState( climbObj, controller.GetStateName() );
    } */
}

/* // R6CLIMBABLEOBJECT
//------------------------------------------------------------------
// PlayClimbObject: start to play climb animation. start the rootmotion if
//  not already started
//------------------------------------------------------------------
simulated function PlayClimbObject()
{
    local bool bClimb64;

    if ( m_climbObject == none )
    {
        return;
    }

    bClimb64 = m_climbObject.m_eClimbHeight == m_climbObject.EClimbHeight.EClimb64;
    
    if ( bIsCrouched )
    {
        if ( bClimb64  )
        {
            PlayRootMotionAnimation('CrouchClimb64Up');
        }
        else
        {
            PlayRootMotionAnimation('CrouchClimb96Up');
        }
    }
    else
    {
        if ( bClimb64 )
        {
            PlayRootMotionAnimation( m_standClimb64DefaultAnimName );
        }
        else
        {
            PlayRootMotionAnimation( m_standClimb96DefaultAnimName );
        }
    }
}

simulated function PlayPostClimb()
{
    local float fHeight;

    if ( bIsCrouched )
    {
        PlayPostRootMotionAnimation( m_crouchDefaultAnimName );
    }
    else
    {
        PlayPostRootMotionAnimation( m_standDefaultAnimName );
    }
    
    m_climbObject = none; // set it to none at the end of all postFunction
}
*/ // R6CLIMBABLEOBJECT

simulated function PlayPostStartLadder()
{   
    m_ePlayerIsUsingHands = HANDS_Both;
    bCollideWorld = true;
    SetPhysics(PHYS_Ladder);

    m_bPostureTransition = true;
    AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);
    PlayAnim('StandLadder_nt', 1.0, 0.0, C_iBaseBlendAnimChannel);      // must use zero tween time here...

    if(m_Ladder.m_bIsTopOfLadder)
    {
        // *************************************************************************
        // RBREK  TOFIX : find a cleaner solution to the problem of collisions with actors while in root motion
        //                this only repairs the damage after the fact in order to be able to keep playing
        // pawn.SetLocation(pawn.location + 28*vector(pawn.rotation)); 
        SetLocation(m_Ladder.location - 38*vector(m_Ladder.rotation) - vect(0,0,126));
    }
    else
    {
        // *************************************************************************
        // RBREK  TOFIX : find a cleaner solution to the problem of collisions with actors while in root motion
        //                this only repairs the damage after the fact in order to be able to keep playing
        // pawn.SetLocation(pawn.location - 23*vector(pawn.rotation));              
        SetLocation(m_Ladder.location + 4*vector(m_Ladder.rotation) + vect(0,0,100));
    }
}

simulated function PlayPostEndLadder()
{
    m_ePlayerIsUsingHands = HANDS_Both;

    if ( m_ePawntype == PAWN_Hostage ) 
    {
        SetLocation(location + vect(0,0,15) );
        
        // specific for the hostage because ladder's anim are based on the Stand anim, not Scare 
        PlayPostRootMotionAnimation( default.m_standDefaultAnimName );
    }    
    else
        PlayPostRootMotionAnimation( m_standDefaultAnimName );
}

function bool IsValidClimber()
{
	if(!m_bIsClimbingLadder && physics == PHYS_Walking)
		return false;

	return true;
}

//===================================================================================================
//                              CROUCHING AND PEEKING FUNCTIONS
//===================================================================================================


//------------------------------------------------------------------
// SetPeekingInfo: set peeking info 
//  
//------------------------------------------------------------------
simulated event SetPeekingInfo( ePeekingMode eMode, FLOAT fPeeking, OPTIONAL bool bPeekLeft )
{
    m_fPeekingGoal = fPeeking;
    m_ePeekingMode = eMode; 

    // set left or right peeking
    if ( m_ePeekingMode == PEEK_fluid )
    {
        m_bPeekingLeft = fPeeking < C_fPeekMiddleMax;
    }
    else if ( m_ePeekingMode != PEEK_none )
    {
        m_bPeekingLeft = bPeekLeft;
    }

    // ai player are limited in their peeking, except when returning to center pos
    if ( !m_bIsPlayer && m_fPeekingGoal != C_fPeekMiddleMax )
    {
        m_fPeekingGoal = (C_fPeekMiddleMax - m_fPeekingGoal) * m_fPeekingGoalModifier + C_fPeekMiddleMax;
    }
}

//------------------------------------------------------------------
// SetCrouchBlend
//  
//------------------------------------------------------------------
simulated event SetCrouchBlend( FLOAT fCrouchBlend )
{
    m_fCrouchBlendRate = fCrouchBlend;
}


simulated event BOOL IsPeekingLeft()
{
    return m_bPeekingLeft;
}

//===================================================================================================
// GetPeekingRate()
//  this function returns the exact rate of peeking between -1 and 1
//===================================================================================================
simulated function FLOAT GetPeekingRate()
{
    return GetPeekingRatioNorm( m_fPeeking ); // needed in Pawn.uc
}

//------------------------------------------------------------------
// IsPeeking: true if peeking in mode. False when returning to center
//  
//------------------------------------------------------------------
simulated function bool IsPeeking()
{    
    return m_ePeekingMode != PEEK_None; 
}

//------------------------------------------------------------------
// StartFluidPeeking: 
//  
//------------------------------------------------------------------
simulated event StartFluidPeeking()
{
    m_bPeekingReturnToCenter = false;
}

//------------------------------------------------------------------
// GetPeekAnimName
//	
//------------------------------------------------------------------
simulated function name GetPeekAnimName( float fPeeking, bool bPeekingLeft )
{
    if ( m_bIsPlayer )
    {
        if ( bIsCrouched  )  // if crouch, cap the value to the max value 
        {
            if ( bPeekingLeft )
            {
                if ( fPeeking < C_fPeekCrouchLeftMax  ) 
                    fPeeking = C_fPeekCrouchLeftMax;
            }
            else
            {
                if ( fPeeking > C_fPeekCrouchRightMax  ) 
                    fPeeking = C_fPeekCrouchRightMax;
            }
        }

        fPeeking = abs( GetPeekingRatioNorm( fPeeking ) ) * 100;
        
    }
    else
        fPeeking = 100; 
        
    if ( m_bPeekingLeft )
    {
        if      ( fPeeking <= 15 && m_fCrouchBlendRate < 0.5 ) return '';
        else if ( fPeeking <= 25) return 'PeekLeft_nt_20';
        else if ( fPeeking <= 45) return 'PeekLeft_nt_40';
        else if ( fPeeking <= 65) return 'PeekLeft_nt_60';
        else if ( fPeeking <= 85) return 'PeekLeft_nt_80';
        else                      return 'PeekLeft_nt';
    }
    else
    {
        if      ( fPeeking <= 15 && m_fCrouchBlendRate < 0.5 ) return '';
        else if ( fPeeking <= 25) return 'PeekRight_nt_20';
        else if ( fPeeking <= 45) return 'PeekRight_nt_40';
        else if ( fPeeking <= 65) return 'PeekRight_nt_60';
        else if ( fPeeking <= 85) return 'PeekRight_nt_80';
        else                      return 'PeekRight_nt';    
    }
}

//------------------------------------------------------------------
// StartFullPeeking: init var for peeking
//  
//------------------------------------------------------------------
simulated event StartFullPeeking()
{
    local name animName;
    m_bPeekingReturnToCenter = false;

    if ( m_bIsProne )
    {
        if ( m_bPeekingLeft ) // peekingleft: the roll is bigger than on the right
        {
            RotateBone('R6 Spine1', 0, 2000, 10000, 0.6 ); 
        }
        else
        {
            RotateBone('R6 Spine1', 0, -2000, -6000, 0.6 );
        }
    }

    // not human player 
    if ( !m_bIsPlayer && !m_bIsProne )
    {
        if ( m_bPeekingLeft )
            animName = 'PeekLeft_nt';
        else
            animName = 'PeekRight_nt';
        
        R6BlendAnim(animName, C_iPeekingAnimChannel, 0.35, 'R6 Spine', 1.0, 0.2); 
    }
}

//------------------------------------------------------------------
// EndPeekingMode: end the peeking mode but have to return to the center
//  
//------------------------------------------------------------------
simulated event EndPeekingMode( ePeekingMode eMode )
{
    if ( eMode == PEEK_fluid )
    {
        // nothing
    }
    else if ( eMode == PEEK_full )
    {
        // reset bones 
        RotateBone('R6 Spine1', 0, 0, 0, 0.6 );
    }

    // allows to return smoothly to the center
    m_bPeekingReturnToCenter = true; 
    m_fPeekingGoal = C_fPeekMiddleMax;
}

//------------------------------------------------------------------
// IsFullPeekingOver: return true if full peeking is over
//  
//------------------------------------------------------------------
simulated event bool IsFullPeekingOver()
{
    local FLOAT fGoal;

    if ( bIsCrouched )
    {
        // not over, out of bound
        if ( m_fPeekingGoal <= C_fPeekCrouchLeftMax )
        {
            fGoal = C_fPeekCrouchLeftMax;
        }
        else if ( m_fPeekingGoal >= C_fPeekCrouchRightMax )
        {
            fGoal = C_fPeekCrouchRightMax;
        }
        else 
        {
            fGoal = m_fPeekingGoal;
        }
    }
    else
    {
        fGoal = m_fPeekingGoal;
    }

    return fGoal == m_fPeeking;
}

//------------------------------------------------------------------
// PlayPeekingAnim
//  
//------------------------------------------------------------------
simulated event PlayPeekingAnim( OPTIONAL bool bUseSpecialPeekAnim )
{
    local FLOAT fRatio;
    local name  animName;
    local FLOAT fPeekingAdjust;

    if ( !m_bIsPlayer )
        return;
    
    // don't play anim if prone 
    if ( !m_bPostureTransition && !m_bIsProne )
    {
        if ( bUseSpecialPeekAnim )
        {
            animName = GetPeekAnimName( m_fPeeking, m_fPeeking < C_fPeekMiddleMax );
            fRatio = 1;
            
            if ( animName == '' )
                bUseSpecialPeekAnim = false;
            
        }

        if ( bUseSpecialPeekAnim == false )
        {
            if ( m_fPeeking < C_fPeekMiddleMax )
                animName = 'PeekLeft_nt';
            else
                animName = 'PeekRight_nt';
            
            fRatio = abs( GetPeekingRatioNorm(m_fPeeking) );
        }


        AnimBlendParams(C_iPeekingAnimChannel, fRatio, 0.0, 0.0, 'R6 Spine');
        LoopAnim(animName, 1.0, 0, C_iPeekingAnimChannel);
    }
}

 
//===================================================================================================
// UpdateFluidPeeking()
//  -- for player pawn only --
//  blending between upright movement and crouched running animations
//===================================================================================================
simulated event PlayFluidPeekingAnim(FLOAT fForwardPct, FLOAT fLeftPct, FLOAT fDeltaTime)
{
    local name      crouchAnim;
    local FLOAT     fCrouchAnimRate;
    local FLOAT     fAnimRateAdjustment;
    local name      animName;
    local FLOAT     fOldCrouchBlendRate;
    local FLOAT     fMaxPeek;

    if ( m_bIsProne )
        return;

    fCrouchAnimRate = 1.0;   
    fAnimRateAdjustment = 0.f;

	// play waiting animation
	AnimBlendParams(2 /*RIGHTTURNCHANNEL*/, m_fCrouchBlendRate, 0.0, 0.0);   
	LoopAnim('CrouchRun_nt', 1.0, 0.0, 2 /*RIGHTTURNCHANNEL*/);

	// blend crouched movement animation
	if( fForwardPct!=0.f || fLeftPct!=0 )
    {
		if(abs(fForwardPct) > abs(fLeftPct))
		{
			if(fForwardPct > 0)
			{
				if(bIsWalking)
				{
					crouchAnim = m_crouchWalkForwardName;               
					fAnimRateAdjustment = (m_fWalkingSpeed - m_fCrouchedWalkingSpeed) / m_fCrouchedWalkingSpeed;
				}
				else
				{
					crouchAnim = 'CrouchRunForward';
					fCrouchAnimRate = 1.5;
					fAnimRateAdjustment = (m_fRunningSpeed - m_fCrouchedRunningSpeed) / m_fCrouchedRunningSpeed;
				}
			}
			else
			{
				if(bIsWalking)
					crouchAnim = 'CrouchWalkBack';
				else
				{
					crouchAnim = 'CrouchRunBack';
					fCrouchAnimRate = 1.333;
				}
			}
		}
		else
		{
			if(fLeftPct > 0)
			{
				if(bIsWalking)
					crouchAnim = 'CrouchWalkLeft';
				else
					crouchAnim = 'CrouchRunLeft';
			}
			else
			{
				if(bIsWalking)
					crouchAnim = 'CrouchWalkRight';
				else
					crouchAnim = 'CrouchRunRight';
			}
			fCrouchAnimRate = 1.07;
		}
	}

    if(crouchAnim == '')
        crouchAnim = m_crouchWalkForwardName;

    // because crouch run looks more like a walk but higher (height) than the crouch walk
	if(Acceleration == vect(0,0,0))
	{
		AnimBlendToAlpha(C_iPostureAnimChannel, 0.0, 0.3 );	
	}
    else
	{
		AnimBlendToAlpha(C_iPostureAnimChannel, m_fCrouchBlendRate, 0.1 );
		LoopAnim(crouchAnim, fCrouchAnimRate, 0.0, C_iPostureAnimChannel,, true);   
	}
}

//===================================================================================================
// AvoidLedges()
//   rbrek 09 feb 2002
//   use to set or reset the desireability to avoid ledges... (now that it is possible to walk off a 
//   ledges, it is easy for NPCs to fall off inadvertantly.
//===================================================================================================
function AvoidLedges(bool bAvoid)
{
    #ifdefDEBUG if(bShowLog) log(self$" : AvoidLedges()... bAvoid = "$bAvoid); #endif
    bCanWalkOffLedges = !bAvoid;
    bAvoidLedges = bAvoid;
}

//===================================================================================================
// SetAvoidFacingWalls()
//===================================================================================================
function SetAvoidFacingWalls( bool bAvoidFacingWalls )
{
    m_bAvoidFacingWalls = bAvoidFacingWalls;
}

//===================================================================================================
// TurnAwayFromNearbyWalls()
//   rbrek 18 jan 2002
//   pick a focalpoint so that we are not facing a wall... (traces do not check for actors)
//   currently using a distance of 3m for the trace tests
//===================================================================================================
function TurnAwayFromNearbyWalls()
{
    local rotator   rViewDir;                   // direction the pawn is currently looking 
    local vector    vViewDir;                   // direction used for trace
    local vector    vTraceStart;                // starting location used for trace
    local vector    vTraceEnd;                  // end location used for trace
    local vector    vHitLocation, vHitNormal;   // HitLocation and HitNormal updated by call to trace   
    local vector    vDir;                       // vector defining the chosen direction to orient pawn
    local vector    vDirFarthest;               // location of furthest wall (used if pawn is blocked in all directions)
    local FLOAT     fDist, fDistFarthest;       // used for selecting a fallback orientation (facing the furthest wall)

    // get this pawn's look direction
    rViewDir    = GetViewRotation();

    // check directly in front of pawn to see if there is a wall
    vViewDir    = vector(rViewDir);
    vTraceStart = location + EyePosition(); 
    vTraceEnd   = vTraceStart + (CollisionRadius + m_fWallCheckDistance)*vViewDir;
    if(Trace(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, false) == none)
        return;     // if there is no wall directly ahead, do nothing... 

    // there is a wall in front of this pawn, but store this direction anyway because we may have to settle for it
    // as choice to fallback on if we find we are blocked in all directions 
    fDistFarthest = VSize(vHitLocation - vTraceStart);
    vDirFarthest = vViewDir; 

    // check directly behind pawn to see if there is a wall
    vViewDir    = vector(rViewDir + rot(0,32768,0));
    vTraceEnd   = vTraceStart + (CollisionRadius + m_fWallCheckDistance)*vViewDir;   
    if(Trace(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, false) == none)
    {
        // there is no wall behind this pawn, turn around 180degrees...
        vDir = vViewDir; 
    }
    else
    {
        // there is also a wall behind this pawn, check to see if this is a better fallback option
        fDist = VSize(vHitLocation - vTraceStart);
        if(fDistFarthest > fDist)
        {
            fDistFarthest = VSize(vHitLocation - vTraceStart);
            vDirFarthest = vViewDir; 
        }
        
        // check to the right of the pawn
        vViewDir    = vector(rViewDir + rot(0,16384,0));
        vTraceEnd   = vTraceStart + (CollisionRadius + m_fWallCheckDistance)*vViewDir;      
        if(Trace(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, false) == none)
        {
            // there is no wall to the right of this pawn so turn 90 degrees...
            vDir = vViewDir; 
        }
        else
        {   
            // there is a wall to the right, so check to see if this is a better fallback option
            fDist = VSize(vHitLocation - vTraceStart);
            if(fDistFarthest > fDist)
            {
                fDistFarthest = fDist;
                vDirFarthest = vViewDir; 
            }

            // check to the left of this pawn
            vViewDir    = vector(rViewDir - rot(0,16384,0));
            vTraceEnd   = vTraceStart + (CollisionRadius + m_fWallCheckDistance)*vViewDir;          
            if(Trace(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, false) == none)
            {
                // there is no wall to the left of this pawn so turn left 90 degrees...
                vDir = vViewDir; 
            }
            else
            {
                // pick the direction of the least close wall
                fDist = VSize(vHitLocation - vTraceStart);
                if(fDistFarthest > fDist)
                    vDirFarthest = vViewDir; 

                vDir = vDirFarthest;
            }
        }
    }
    if(controller != none)
    {
        controller.focus = none;
        controller.focalpoint = location + 100*vDir;    
    }
}

//===================================================================================================
// ChangeAnimation()
//===================================================================================================
simulated event ChangeAnimation()
{
    if ( (Controller != None) && Controller.bControlAnimations )
    {
        #ifdefDEBUG if(bShowLog) log(" controller="$controller$" controller.bControlAnimations="$controller.bControlAnimations); #endif
        return;
    } 

    // todo : this perhaps should not be here, but without it, weapon animations do not seem to be playing in MP
    PlayWeaponAnimation();  // also grenade aren't being thrown in first person otherwise
    
    // player animation - set up new idle and moving animations
    if(physics != PHYS_RootMotion)
        PlayWaiting();

    PlayMoving();   

    // try to look intelligent and not stare at walls - pick an appropriate direction to orient pawn
    // this is done only once each time a pawn stops moving.
    if(!m_bWallAdjustmentDone 
        && (acceleration == vect(0,0,0)) /*IsStationary()*/ 
        && (physics==PHYS_Walking) 
        && !m_bIsPlayer 
        && m_bAvoidFacingWalls
        && !m_bPostureTransition )  
    {
        TurnAwayFromNearbyWalls();
        m_bWallAdjustmentDone = true;
    }
}

//===================================================================================================
// PlayMoving()
//===================================================================================================
simulated function PlayMoving()
{
    if((physics == PHYS_None) 
        || ((controller != None) && controller.bPreparingMove))
    {
        #ifdefDEBUG if(bShowLog) log(self$" is preparing move - not really moving ... "); #endif
        PlayWaiting();
        return;
    } 

    // reset this variable to false as soon as we are no longer stationary
    m_bWallAdjustmentDone = false;

    if(m_bIsClimbingStairs && (velocity != vect(0,0,0)))
    {
        if(normal(velocity) dot normal(m_vStairDirection) <= 0.0)
            m_bIsMovingUpStairs = false;
        else
            m_bIsMovingUpStairs = true;
    }

    // add case for PHYS_RootMotion ???
    if (physics == PHYS_Ladder)
    {
        AnimateClimbing();
    }
    else    // assuming (physics == PHYS_Walking)
    {
        if(m_bIsProne)
        {          
            AnimateProneTurning();
            AnimateProneWalking();
        }
        else if(m_bIsKneeling)
        {
            TurnLeftAnim = 'KneelTurnLeft';
            TurnRightAnim = 'KneelTurnRight';
            AnimateCrouchWalking();
        }
        else if(bIsCrouched)
        {
            AnimateCrouchTurning();
            if(m_bIsClimbingStairs)
            {
                if(bIsWalking)
                {
                    if(m_bIsMovingUpStairs)
                        AnimateCrouchWalkingUpStairs();
                    else
                        AnimateCrouchWalkingDownStairs();
                }
                else
                {
                    if(m_bIsMovingUpStairs)
                        AnimateCrouchRunningUpStairs(); 
                    else
                        AnimateCrouchRunningDownStairs();
                }
            }
            else
            {
                if(bIsWalking)
                    AnimateCrouchWalking();
                else
                    AnimateCrouchRunning();
            }
        }
        else
        {
            AnimateStandTurning();
            if(m_bIsClimbingStairs)
            {
                if(bIsWalking) 
                {
                    if(m_bIsMovingUpStairs)
                        AnimateWalkingUpStairs();   
                    else
                        AnimateWalkingDownStairs();
                }   
                else
                {
                    if(m_bIsMovingUpStairs)
                        AnimateRunningUpStairs();   
                    else
                        AnimateRunningDownStairs();
                }
            }
            else
            {
                if(bIsWalking)
                    AnimateWalking();
                else
                    AnimateRunning();
            }
        }
    }
}

//===================================================================================================
simulated function AnimateStandTurning()
{
    TurnLeftAnim = m_standTurnLeftName;
    TurnRightAnim = m_standTurnRightName;
}

//===================================================================================================
simulated function AnimateCrouchTurning()
{
    TurnLeftAnim = 'CrouchTurnLeft';
    TurnRightAnim = 'CrouchTurnRight';
}

//===================================================================================================
simulated function AnimateProneTurning()
{
    TurnLeftAnim = 'ProneTurnLeft';
    TurnRightAnim = 'ProneTurnRight';
}

simulated function InitBackwardAnims()
{
    local INT i;
    for(i=0; i<4; i++)
        AnimPlayBackward[i] = 0;
}

//===================================================================================================
simulated function AnimateWalking()
{
    if(m_eHealth==HEALTH_Wounded)
    {
        MovementAnims[0] = 'HurtStandWalkForward';  
        MovementAnims[1] = m_hurtStandWalkLeftName;
        MovementAnims[2] = 'HurtStandWalkBack';
        MovementAnims[3] = m_hurtStandWalkRightName;
    }
    else
    {
        MovementAnims[0] = m_standWalkForwardName;  
        MovementAnims[1] = m_standWalkLeftName;
        MovementAnims[2] = m_standWalkBackName;
        MovementAnims[3] = m_standWalkRightName;
    }

    InitBackwardAnims();
}

//===================================================================================================
simulated function AnimateRunning()
{
    MovementAnims[0] = m_standRunForwardName;
    MovementAnims[1] = m_standRunLeftName; 
    MovementAnims[2] = m_standRunBackName;
    MovementAnims[3] = m_standRunRightName;

    InitBackwardAnims();
}

//===================================================================================================
simulated function AnimateCrouchWalking()
{
    MovementAnims[0] = m_crouchWalkForwardName;
    MovementAnims[1] = 'CrouchWalkLeft';
    MovementAnims[2] = 'CrouchWalkBack';
    MovementAnims[3] = 'CrouchWalkRight';

    InitBackwardAnims();
}

//===================================================================================================
simulated function AnimateCrouchRunning()
{
    MovementAnims[0] = 'CrouchRunForward';
    MovementAnims[1] = 'CrouchRunLeft';
    MovementAnims[2] = 'CrouchRunBack'; 
    MovementAnims[3] = 'CrouchRunRight';

    InitBackwardAnims();
}

//===================================================================================================
simulated function AnimateProneWalking()
{
    MovementAnims[0] = 'ProneWalkForward';
    MovementAnims[1] = 'ProneWalkLeft';
    MovementAnims[2] = 'ProneWalkBack';
    MovementAnims[3] = 'ProneWalkRight';

    InitBackwardAnims();
}

//===================================================================================================
// there still remains a problem when strafing across stairs (should use regular non-stair strafing animation)
simulated function AnimateWalkingUpStairs()
{
    MovementAnims[0] = m_standStairWalkUpName;          // walking forward towards top of stairs
    MovementAnims[1] = m_standStairWalkDownRightName;   // strafing left up towards top of stairs 
    MovementAnims[2] = m_standStairWalkUpBackName;      // walking backward, moving towards the top of the stairs
    MovementAnims[3] = m_standStairWalkUpRightName;     // strafing down the stairs, facing top of stairs

    InitBackwardAnims();
    AnimPlayBackward[1] = 1;
}
 
//===================================================================================================
simulated function AnimateWalkingDownStairs()
{
    MovementAnims[0] = m_standStairWalkDownName;
    MovementAnims[1] = m_standStairWalkUpRightName;  
    MovementAnims[2] = m_standStairWalkDownBackName;
    MovementAnims[3] = m_standStairWalkDownRightName;

    InitBackwardAnims();
    AnimPlayBackward[1] = 1;    
}

//===================================================================================================
simulated function AnimateRunningUpStairs()
{
    MovementAnims[0] = m_standStairRunUpName;
    MovementAnims[1] = m_standStairRunDownRightName;  
    MovementAnims[2] = m_standStairRunUpBackName;
    MovementAnims[3] = m_standStairRunUpRightName;

    InitBackwardAnims();
    AnimPlayBackward[1] = 1;
}

//===================================================================================================
simulated function AnimateRunningDownStairs()
{
    MovementAnims[0] = m_standStairRunDownName;
    MovementAnims[1] = m_standStairRunUpRightName;  // inverse rate
    MovementAnims[2] = m_standStairRunDownBackName;
    MovementAnims[3] = m_standStairRunDownRightName;

    InitBackwardAnims();
    AnimPlayBackward[1] = 1;
}

//===================================================================================================
simulated function AnimateCrouchWalkingUpStairs()
{
    MovementAnims[0] = m_crouchStairWalkUpName;
    MovementAnims[1] = m_crouchStairWalkDownRightName;  // inverse rate
    MovementAnims[2] = m_crouchStairWalkUpBackName;
    MovementAnims[3] = m_crouchStairWalkDownRightName;

    InitBackwardAnims();
    AnimPlayBackward[1] = 1;    
}

//===================================================================================================
simulated function AnimateCrouchRunningUpStairs()
{
    AnimateCrouchWalkingUpStairs();
    MovementAnims[0] = m_crouchStairRunUpName;
}

//===================================================================================================
simulated function AnimateCrouchWalkingDownStairs()
{
    MovementAnims[0] = m_crouchStairWalkDownName;
    MovementAnims[1] = m_crouchStairWalkUpRightName;  // inverse rate
    MovementAnims[2] = m_crouchStairWalkDownBackName;
    MovementAnims[3] = m_crouchStairWalkDownRightName;

    InitBackwardAnims();
    AnimPlayBackward[1] = 1;
}

//===================================================================================================
simulated function AnimateCrouchRunningDownStairs()
{
    AnimateCrouchWalkingDownStairs();
    MovementAnims[0] = m_crouchStairRunDownName;
}

//===================================================================================================
simulated function AnimateClimbing()
{
    local   name    ladderAnim;
    local   INT     i;

    ladderAnim = 'StandLadderUp_c';
    if(bIsWalking)
    {
        for(i=0; i<4; i++)
        {
            MovementAnims[i] = ladderAnim;
            AnimPlayBackward[i] = 0;
        }
        AnimPlayBackward[2] = 1;
    }
    else
    {
        for(i=0; i<4; i++)
        {
            MovementAnims[i] = ladderAnim;
            AnimPlayBackward[i] = 0;
        }

        if(m_ePawnType == PAWN_Rainbow) 
        {
            MovementAnims[2] = 'StandLadderSlide_nt';
            AnimPlayBackward[2] = 0;
        }
        else
            AnimPlayBackward[2] = 1;
    }

    TurnLeftAnim = ladderAnim;
    TurnRightAnim = ladderAnim;
}

simulated function AnimateStoppedOnLadder()
{
    m_ePlayerIsUsingHands = HANDS_Both;
    TweenAnim('StandLadder_nt', 0.2); 
}

//===================================================================================================
// PlayFalling() 
//  rbrek 3 dec 2001
//  this function is called when a pawn first starts to fall
// 3 jan 2002 - rbrek, removed PlayInAir() (obsolete), can replace with calls to PlayFalling()
//===================================================================================================
simulated event PlayFalling()
{
    m_ePlayerIsUsingHands = HANDS_Both;
    if(bWantsToCrouch) 
        R6LoopAnim(m_crouchFallName);
    else
        R6LoopAnim(m_standFallName);
}


//------------------------------------------------------------------
// Falling: fired when the pawn physic switch to falling or when he
//  has to jump (not the case in ravenshield)
//------------------------------------------------------------------
event Falling()
{
    m_fFallingHeight = Location.Z;

    #ifdefDEBUG if ( bShowLog) logX( "event falling: m_fFallingHeight=" $m_fFallingHeight ); #endif
}

//------------------------------------------------------------------
// Landed: when the pawn land on the floor
//  
//------------------------------------------------------------------
event Landed(vector HitNormal)
{
    local FLOAT     fDistanceFallen;
    local eHealth   ePreviousHealth;
    local bool      bGameOver;

    #ifdefDEBUG if (bShowLog) logX( "landed: m_fFallingHeight=" $m_fFallingHeight$ " height=" $(m_fFallingHeight - location.z)); #endif

    if ( Level.NetMode == NM_Client)
    {
        if(m_bIsPlayer && R6PlayerController(controller).GameReplicationInfo.m_bGameOverRep)
        {
            m_bIsLanding = true;
            acceleration = vect(0,0,0);
            velocity = vect(0,0,0);
            return;
        }
    }
    else if ( Level.Game.m_bGameOver && !R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath )
    {
        m_bIsLanding = true;
        acceleration = vect(0,0,0);
        velocity = vect(0,0,0);
        return;
    }
    // MPF1
    if ( class'Actor'.static.GetModMgr().IsMissionPack() )
    {
 	    // MissionPack1 - Player is invulnerable when falling in Capture The Enemy game type; R6Pawn can only be a R6Rainbow
	    if((PlayerController(Controller).GameReplicationInfo.m_szGameTypeFlagRep)== "RGM_CaptureTheEnemyAdvMode"
			&& m_bSuicideType != DEATHMSG_KAMAKAZE // MPF_Milan_7_1_2003 - player hasn't suicided
			&& m_bSuicideType != DEATHMSG_CONNECTIONLOST && m_bSuicideType != DEATHMSG_PENALTY)
	    {
		    if(m_fFallingHeight - location.z >= 128.0)
		    {
	            m_bIsLanding = true;
		        acceleration = vect(0,0,0);
			    velocity = vect(0,0,0);
		    }
		    
		    return; // Don't process damage
        }
    }
	// End MissionPack1    
    if ( m_fFallingHeight == 0 )
        return;


    ePreviousHealth = m_eHealth;
    fDistanceFallen = m_fFallingHeight - location.z;
	
    if( !InGodMode() 
        && ( (fDistanceFallen >= 600) 
             || ((fDistanceFallen >= 300) && (m_eHealth == HEALTH_Wounded || m_eHealth == HEALTH_Incapacitated) )) )
    {
        m_eHealth = HEALTH_Dead;

        if ((Role == ROLE_Authority) && (Controller != none))
            Controller.PlaySoundDamage(Self);
        
        if ( Level.NetMode != NM_Client )
        {
            TakeHitLocation = vect(0,0,0);
            R6Died(self, BP_Legs, vect(0,0,0));
        }
    }
	else if ( fDistanceFallen >= 128.0 && m_eHealth != HEALTH_Dead ) 
    {
        if ( !InGodMode() && fDistanceFallen >= 300.0 )
        {			
            m_eHealth = HEALTH_Wounded;
            m_fHBWound = 1.2;
            if ((Role == ROLE_Authority) && (Controller != none))
                Controller.PlaySoundDamage(Self);
        }
        
        m_bIsLanding = true;
        acceleration = vect(0,0,0);
        velocity = vect(0,0,0);
    }

    if (PlayerReplicationInfo!=none)
    {
        PlayerReplicationInfo.m_iHealth = m_eHealth;
    }
    
    if ( ePreviousHealth != m_eHealth )
    {
        // update the team's knowledge about this member's health status
        if(m_ePawnType==PAWN_Rainbow)
        {
            if( m_bIsPlayer )
            {
                if(R6PlayerController(controller).m_TeamManager != none)
                    R6PlayerController(controller).m_TeamManager.UpdateTeamStatus(self);
            }
            else
            {
                if(R6RainbowAI(controller).m_TeamManager != none)
                    R6RainbowAI(controller).m_TeamManager.UpdateTeamStatus(self);
            }
        }
    }    
}


//===================================================================================================
// PlayLandingAnimation() 
//  rbrek 3 dec 2001
//  this function is called when pawn's physics changes from PHYS_Falling to PHYS_Walking
//  called by PlayLanded() which also handles playing the appropriate sound.
//===================================================================================================
simulated event PlayLandingAnimation(float impactVel)
{
    #ifdefDEBUG if(bShowLog) logX("PlayLandingAnimation"); #endif

    if ( m_eHealth == HEALTH_Dead )
        return;

    if((m_fFallingHeight - location.z) < 128)
    {
        // if we're falling down and we fall on a pawn more than once, 
        // the height can be < 128, so reset isLanding		
        m_bIsLanding = false; 
        return;       
    }
    m_bIsLanding = true;
    m_fFallingHeight = 0;

    m_ePlayerIsUsingHands = HANDS_Both;
    
    // if wounded make sure we have the hurt anim
    if ( m_eHealth == HEALTH_Wounded )
        ChangeAnimation();          

    m_bPostureTransition = true;
    AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);
    if(bWantsToCrouch) 
        PlayAnim(m_crouchLandName, 1.5, 0.1, C_iBaseBlendAnimChannel);
    else
        PlayAnim(m_standLandName, 1.5, 0.1, C_iBaseBlendAnimChannel);
}

//------------------------------------------------------------------
// BaseChange: when the base was a pawn, the base was taking damage
// and self was jumping like a monkey on acid.
// - overriden from pawn.uc 
//------------------------------------------------------------------
singular event BaseChange()
{
    if ( bInterpolating )
        return;

    if ( (base == None) && (Physics == PHYS_None) )
    {
        SetPhysics(PHYS_Falling);
    }
    else if ( Pawn(Base) != None || R6ColBox(Base) != None )
    {
        if ( Level.NetMode != NM_Client )
        {
            R6JumpOffPawn();
		    Falling();
            PlayFalling();
        }
    }
}

//------------------------------------------------------------------
// R6JumpOffPawn
//	jump off something: good velocity + not to high 
//------------------------------------------------------------------
function R6JumpOffPawn()
{
    local int i;

    i = 200; // give a good velocity [200..400] or [-400..-200]

    // choose a random direction
    Velocity += (i) * VRand();
    
    // now force to have a fast velocity
    if ( Velocity.X < 0 )
        Velocity.X = (rand( i ) + i) * -1;
    else
        Velocity.X = (rand( i ) + i);
    
    if ( Velocity.Y < 0 )
        Velocity.Y = (rand( i ) + i) * -1;
    else
        Velocity.Y = (rand( i ) + i);

    // and not to high
    Velocity.Z = 25;

    SetPhysics(PHYS_Falling);
	bNoJumpAdjust = true;
	Controller.SetFall();
}


//============================================================================
// AttachToClimbableObject - 
//============================================================================
function AttachToClimbableObject( R6ClimbableObject pObject )
{
    m_bOldCanWalkOffLedges = bCanWalkOffLedges;
    bCanWalkOffLedges = true;
}

//============================================================================
// DetachFromClimbableObject - 
//============================================================================
function DetachFromClimbableObject( R6ClimbableObject pObject )
{
    bCanWalkOffLedges = m_bOldCanWalkOffLedges;
}

//===================================================================================================
// rbrek
// EncroachedBy()
//   this function was overriden from Pawn.uc; actors were being gibbed (killed) when they were encroached 
//   on by another actor who started crouching. it is left empty to prevent pawn from being 'gibbed'
//===================================================================================================
event EncroachedBy( actor Other )
{
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//                          ANIMATION FUNCTIONS COMMON TO ALL STATES
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
simulated function PlayWaiting()
{
    m_ePlayerIsUsingHands = HANDS_None;
    R6LoopAnim(m_standDefaultAnimName);
}

simulated function PlayDuck()
{
    R6LoopAnim(m_crouchDefaultAnimName);
}

simulated function PlayCrouchWaiting()
{
    m_ePlayerIsUsingHands = HANDS_None;
    R6LoopAnim(m_crouchDefaultAnimName);
}

simulated event PlayCrouchToProne( OPTIONAL bool bForcedByClient )
{
    local vector vHitLocation, vHitNormal, vPositionEnd;

    #ifdefDEBUG if (bShowLog) logX( "playCrouchToProne() bForcedByClient=" $bForcedByClient ); #endif

    // it's a client and we are not forced and we are the owner of this pawn
    if ( Level.NetMode == NM_Client && !bForcedByClient && Role == ROLE_AutonomousProxy )
        return;

    //both hands are used to get in prone position
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();


    m_bPostureTransition = true;
    m_bSoundChangePosture = true;

    vPositionEnd = Location;
    vPositionEnd.Z -= collisionHeight;
    vPositionEnd.Z -= 50;

    // Set the material under is feet.
    R6Trace(vHitLocation, vHitNormal, vPositionEnd, Location, TF_SkipVolume,, m_HitMaterial);

    // Play the sound for the animation
    PlaySurfaceSwitch();
    
    AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);
    if((engineWeapon != none) && (m_ePawnType == PAWN_Rainbow) && EngineWeapon.GotBipod())
    {
        EngineWeapon.GotoState('DeployBipod');
        PlayAnim('CrouchToProneBipod', 1.4*ArmorSkillEffect(), 0.1, C_iBaseBlendAnimChannel);  
    }
    else
    {
        PlayAnim('CrouchToProne', 1.4*ArmorSkillEffect(), 0.1, C_iBaseBlendAnimChannel);  
    }
}

simulated event PlayProneToCrouch( OPTIONAL bool bForcedByClient )
{
    local vector vHitLocation, vHitNormal, vPositionEnd;

    #ifdefDEBUG if (bShowLog) logX(self$" playProneToCrouch() bForcedByClient=" $bForcedByClient ); #endif

    if ( Level.NetMode == NM_Client && !bForcedByClient && Role == ROLE_AutonomousProxy)
        return;

    // reset: yaw rotation of the torso that prevent full body rotation
    SetBoneRotation('R6 Spine',  rot(0,0,0),, 1.0, 0.4); 
    SetBoneRotation('R6 Pelvis', rot(0,0,0),, 1.0, 0 ); // used in the stair/terrain

    //both hands are used to get in prone position
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();

    m_bPostureTransition = true;
    m_bSoundChangePosture = true;

    vPositionEnd = Location;
    vPositionEnd.Z -= collisionHeight;
    vPositionEnd.Z -= 50;

    // Set the material under is feet.
    R6Trace(vHitLocation, vHitNormal, vPositionEnd, Location, TF_SkipVolume,, m_HitMaterial);

    // Play the sound for the animation
    PlaySurfaceSwitch();

    AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);
    if((engineWeapon != none) && (m_ePawnType == PAWN_Rainbow) && EngineWeapon.GotBipod())
    {
        EngineWeapon.GotoState('CloseBipod');
        PlayAnim('CrouchToProneBipod', 1.4*ArmorSkillEffect(), 0, C_iBaseBlendAnimChannel, true);   // play animation backward
    }
    else
    {
        PlayAnim('CrouchToProne', 1.4*ArmorSkillEffect(), 0, C_iBaseBlendAnimChannel, true);   // play animation backward
    }
}

event StartCrouch(float HeightAdjust)
{
    visibility = 64; // max 128
    PlayDuck();
}

event EndCrouch(float fHeight)
{
    visibility = 128; // max 128
}

event StartCrawl()
{
    visibility = 38; // max 128

    if ( Level.NetMode != NM_Client )
        SetNextPendingAction(PENDING_CrouchToProne);
    else
        PlayCrouchToProne( true );
}

event EndCrawl()
{
    visibility = 64;

    if ( Level.NetMode != NM_Client )
        SetNextPendingAction(PENDING_ProneToCrouch);
    else
        PlayProneToCrouch( true );
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  PLAYER OBJECT INTERACTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

function ServerGod( bool bIsGod, bool bUpdateTeam, bool bForHostage, string szPlayerName, bool bForTerro )
{
    local R6Pawn p;
    local string szMsg;

    #ifdefDEBUG if ( bShowLog) log( szPlayerName$ " called ServerGod bIsGod= " $bIsGod$ " bUpdateTeam= " $bUpdateTeam$ " bIsGod=" $bIsGod ); #endif
    
    if ( !bUpdateTeam && !bForHostage && !bForTerro )
    {
        Controller.bGodMode = bIsGod; 
        if ( Controller.bGodMode )
        {
            szMsg =  szPlayerName$ " activated GOD mode";
            m_eHealth = HEALTH_Healthy;
        }
        else
        {
            szMsg =  szPlayerName$ " deactivated GOD mode";
        }
    }
    else
    {
        foreach AllActors( class 'R6Pawn', p )
        {
            if(!p.IsAlive())
                continue;

            if ( bForTerro )
            {
                if ( p.m_ePawnType != PAWN_Terrorist )    // not a terro
                    continue;

                bIsGod = !p.controller.bGodMode;
            
            }
            else if ( bForHostage )
            {
                if ( p.m_ePawnType != PAWN_Hostage )    // not a hostage
                    continue;

                bIsGod = !p.controller.bGodMode;
            }
            else if ( p.m_ePawnType != PAWN_Rainbow )   // not a rainbow
            {
                continue;
            }
            // in multiplayer AND a rainbow but not same team
            else if ( Level.NetMode != NM_Standalone && p.m_iteam != p.m_iteam )          
            {
                continue;
            }

            if( p.controller != none )
            {
                p.controller.bGodMode = bIsGod;

                if ( p.controller.bGodMode )
                {
                    p.m_eHealth = HEALTH_Healthy;
                }
            }
        }

        if ( bForTerro )
        {
            if ( bIsGod )
               szMsg =  szPlayerName$ " activated TERRORIST GOD mode";
            else
               szMsg =  szPlayerName$ " deactivated TERRORIST GOD mode";
        }
        else if ( bForHostage )
        {
            if ( bIsGod )
                szMsg =  szPlayerName$ " activated HOSTAGE GOD mode";
            else
               szMsg =  szPlayerName$ " deactivated HOSTAGE GOD mode";
        }
        else
        {
            if ( bIsGod )
                szMsg =  szPlayerName$ " activated TEAM GOD mode";
            else
               szMsg =  szPlayerName$ " deactivated TEAM GOD mode";
        }
    }

    Level.Game.Broadcast( none, szMsg, 'ServerMessage');
}

//------------------------------------------------------------------
// ServerSuicidePawn: for debugging
//  
//------------------------------------------------------------------
function ServerSuicidePawn(BYTE bSuicidedType)
{
    if ( InGodMode() )
        return;

    #ifdefDEBUG if ( bShowLog ) logX( "ServerSuicidePawn"); #endif
    m_bSuicideType = bSuicidedType;
    velocity = vect(0,0,0);
    acceleration = vect(0,0,0);
    m_fFallingHeight = Location.Z + 1000;
    Landed( vect(0,0,0) );
}

function ServerSetRoundTime( int iTime )
{
    Level.Game.Broadcast( none, "ServerSetRoundTime: " $iTime$ " seconds", 'ServerMessage');
    if( R6AbstractGameInfo(Level.Game) != None)
    {
        R6AbstractGameInfo(Level.Game).m_fEndingTime = Level.TimeSeconds + iTime;
    }
}

function ServerSetBetTime( int iTime )
{
    Level.Game.Broadcast( none, "ServerSetBetTime: " $iTime$ " seconds", 'ServerMessage');
    if( R6AbstractGameInfo(Level.Game) != None)
    {
        R6AbstractGameInfo(Level.Game).m_fTimeBetRounds = iTime;
    }
}

//------------------------------------------------------------------
// ServerToggleCollision: for debugging and not safe
//  
//------------------------------------------------------------------
function ServerToggleCollision()
{
    local bool bValue;

    bValue = !bCollideActors;
    #ifdefDEBUG if(bShowLog) logX( "ServerToggleCollision: " $bValue ); #endif 
    SetCollision(bValue,bValue,bValue); 
}

function ServerSwitchReloadingWeapon(BOOL NewValue)
{
    m_bReloadingWeapon = NewValue;
    if(m_bReloadingWeapon == FALSE)
    {
        m_WeaponAnimPlaying = 'None';
    }
}

function ServerPerformDoorAction(R6IORotatingDoor whichDoor, INT iActionID)
{
//    PlayDoorAnim(whichDoor);
    whichDoor.Instigator = Self;
    whichDoor.performDoorAction(iActionID);
}


simulated function PlaySecureTerrorist();

function BOOL PawnHaveFinishedRotation()
{
    local BOOL bSuccess;

    bSuccess = (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) < 2000);
    if (!bSuccess) //check if on opposite sides of zero
    {
        bSuccess = (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) > 63535); 
    }
    return bSuccess;
}

//------------------------------------------------------------------
// CanInteractWithObjects()
//------------------------------------------------------------------
function bool CanInteractWithObjects()
{
    if( m_bIsProne 
        || m_bChangingWeapon 
        || m_bReloadingWeapon 
        || m_bIsFiringState 
        || Level.m_bInGamePlanningActive)
        return false;

    return true;
}

// PLAYERPAWN - request to perform an action has been recieved from PlayerController...
simulated function ServerActionRequest(R6CircumstantialActionQuery actionRequested)
{
    #ifdefDEBUG if(bShowLog) log("    ServerActionRequest() actionRequested.aQueryTarget="$actionRequested.aQueryTarget$" CanInteractWithObjects()="$CanInteractWithObjects());   #endif    
	if(!m_bIsPlayer || actionRequested.aQueryTarget == none) // check this only on client side : || !CanInteractWithObjects())
        return;     // this function should not be called for a non player...   

    if(actionRequested.aQueryTarget.IsA('R6IORotatingDoor'))
    {
        actionRequested.aQueryTarget.Instigator = Self;
        R6IORotatingDoor(actionRequested.aQueryTarget).PerformDoorAction(actionRequested.iPlayerActionID);
    }
    else if (actionRequested.aQueryTarget.IsA('R6IOObject'))
    {
        R6IOObject(actionRequested.aQueryTarget).ToggleDevice(self);        
    }
    else if (actionRequested.aQueryTarget.IsA('R6Hostage'))
    {
        R6Hostage(actionRequested.aQueryTarget).m_controller.DispatchOrder(actionRequested.iPlayerActionID, self);
    }
	else if ( actionRequested.aQueryTarget.IsA('R6LadderVolume'))
	{
        if(!m_bIsClimbingLadder)
        {
            #ifdefDEBUG if(bShowLog) log(" action button pressed with a potential ladder nearby...,  tell server we want to climb ladder! "); #endif
			PotentialClimbLadder(LadderVolume(actionRequested.aQueryTarget));
            ClimbLadder(LadderVolume(actionRequested.aQueryTarget));
		}
	}	
	/*
    else if(m_potentialActionActor != none)
    {
        // R6CLIMBABLEOBJECT
        if(m_potentialActionActor.IsA('R6ClimbableObject'))
        {
            if ( m_climbObject == none )
            {
                #ifdefDEBUG if(bShowLog) log(" action button pressed with a potential ClimbableObject nearby...,  tell server we want to climb ladder! "); #endif
                StartClimbObject( R6ClimbableObject(m_potentialActionActor) );
            }
        }
    }
	*/
}

simulated function ActionRequest(R6CircumstantialActionQuery actionRequested)
{
    if(!m_bIsPlayer || actionRequested == none || actionRequested.aQueryTarget == none)
        return;     // this function should not be called for a non player...   

    ServerActionRequest(actionRequested);

    if(actionRequested.aQueryTarget.IsA('R6IORotatingDoor'))
    {
        PlayDoorAnim(R6IORotatingDoor(actionRequested.aQueryTarget));
    }
    else if ( actionRequested.aQueryTarget.IsA('R6IOObject')  ||    //R6IOObject includes bombs and planted devices
              actionRequested.aQueryTarget.IsA('R6Hostage')  )
    {
        #ifdefDEBUG if(bShowLog) log(" Let server handle action"); #endif
    }
	else if ( actionRequested.aQueryTarget.IsA('R6LadderVolume') )
	{
        if (Level.NetMode==NM_Client && !m_bIsClimbingLadder)
        {
            #ifdefDEBUG if(bShowLog) log(" action button pressed with a potential ladder nearby...,  tell server we want to climb ladder! "); #endif
			PotentialClimbLadder(LadderVolume(actionRequested.aQueryTarget));
            ClimbLadder(LadderVolume(actionRequested.aQueryTarget));
		}
	}
	/*
    else if(m_potentialActionActor != none)
    {
        // R6CLIMBABLEOBJECT
        if(m_potentialActionActor.IsA('R6ClimbableObject'))
        {
            if ( m_climbObject == none )
            {
                #ifdefDEBUG if(bShowLog) log(" action button pressed with a potential ClimbableObject nearby...,  tell server we want to climb ladder! "); #endif
                StartClimbObject( R6ClimbableObject(m_potentialActionActor) );
            }
        }
    }
    */
//    else log(" action button was pressed but there is no action to perform.... ");    
}

function PlayInteraction( )
{
}

// climbladder has been requested...
function PotentialClimbLadder(LadderVolume L)
{
    #ifdefDEBUG if (bShowLog) log(" add potential climb ladder "$L$", pawn is close enough to climb..."); #endif
    m_potentialActionActor = L;
}

function RemovePotentialClimbLadder(LadderVolume L)
{
    #ifdefDEBUG if (bShowLog) log(" remove potential ladder "$L$"..."); #endif
    m_potentialActionActor = none;
}

function PotentialClimbableObject( R6ClimbableObject obj )
{
    #ifdefDEBUG if (bShowLog) log(" add potential climbableObject "$obj$", pawn is close enough to climb..."); #endif
    m_potentialActionActor = obj;
}

simulated function RemovePotentialClimbableObject( R6ClimbableObject obj )
{
    #ifdefDEBUG if (bShowLog) log(" remove potential climbableObject "$obj ); #endif
    m_potentialActionActor = none;
}

function bool IsTouching(R6Door door)
{
    local R6Door aDoor;
    forEach TouchingActors(class'R6Door', aDoor)
    {
        if(door == aDoor)
            return true;
    }
    return false;
}

//===================================================================================================
// PotentialOpenDoor()                                        
//===================================================================================================
event PotentialOpenDoor(R6Door door)
{
    #ifdefDEBUG if(bShowLog) log(self$" PotentialOpenDoor() : pawn is close enough to a door to open..."$door);		#endif
    if(door.m_RotatingDoor == none)
        return;
        
    if(m_Door != none)
    {
        if(m_Door.m_RotatingDoor != door.m_RotatingDoor)
			m_Door2 = door;
    }
    else
    {
        m_Door = door;
        m_potentialActionActor = door.m_RotatingDoor;
    }

    if((m_ePawnType == PAWN_Rainbow) && door.m_RotatingDoor.m_bIsDoorClosed && !door.m_RotatingDoor.m_bTreatDoorAsWindow)
    {
        if(m_bIsPlayer)
        {
            if( (R6PlayerController(controller) != none) && (R6PlayerController(controller).m_TeamManager != none) )
            {
                #ifdefDEBUG if(bShowLog) log(" player is in front of a closed door..."); #endif
                R6PlayerController(controller).m_TeamManager.RainbowIsInFrontOfAClosedDoor(self, m_Door);       
            }
        }
	}   
    //log(self$"   end of PotentialOpenDoor() : door="$door$" m_Door="$m_Door$" m_Door2="$m_door2);
}

//===================================================================================================
// RemovePotentialOpenDoor()                                  
//===================================================================================================
event RemovePotentialOpenDoor(R6Door door)
{
    #ifdefDEBUG if(bShowLog) log(" remove potential door ...."$door);  #endif

    if(m_Door == door)
    {
        if(IsTouching(door.m_CorrespondingDoor))
        {
            // player has already received (but ignored) a PotentialOpenDoor() notification for this door's corresponding R6Door
            m_Door = door.m_CorrespondingDoor;
			m_potentialActionActor = m_Door.m_RotatingDoor;
        }
        else
        {
            if(m_ePawnType==PAWN_Terrorist && Controller!=none && Controller.IsInState('OpenDoor'))
                return;

            // player has lost contact with the R6Door actor
            m_potentialActionActor = none;
            m_Door = none;          

            if(m_Door2 != none)
            {
                m_Door = m_Door2;
                m_Door2 = none;
                m_potentialActionActor = m_Door.m_RotatingDoor;
            }
        }
    }
    else if(m_Door2 == door)
        m_Door2 = none;
    else
        return;

    // inform TEAMAI : this occurs mainly when the player leaves the door prematurely...
    if( m_bIsPlayer && controller != none && R6PlayerController(controller).m_TeamManager != none ) // needed for resetting a level
        R6PlayerController(controller).m_TeamManager.RainbowHasLeftDoor(self);
    //log(self$"   end of RemovePotentialOpenDoor() : door="$door$" m_Door="$m_Door$" m_Door2="$m_door2);
}

//===================================================================================================
// PlayDoorAnim()
//===================================================================================================
simulated function PlayDoorAnim(R6IORotatingDoor door)
{
    local   bool    bOpensTowardsPawn;

    if(bIsCrouched)     {   PlayCrouchedDoorAnim(door);     return;     }

    bOpensTowardsPawn = door.DoorOpenTowardsActor(self);

    //Do not blend left hand animations while opening doors
    m_ePlayerIsUsingHands = HANDS_Left;

    // if door is closed, play opening animation    
    if(door.m_bIsDoorClosed)
    {
        // door opens towards pawn
        if(bOpensTowardsPawn)
            PlayAnim('StandDoorPull', 1.0, 0.2);
        else  // door opens away from pawn
            PlayAnim('StandDoorPush', 1.0, 0.2);
    }  
    else  // otherwise play a close door animation
    {
        // door closes towards pawn
        if(bOpensTowardsPawn)
            PlayAnim('StandDoorPush', 1.0, 0.2);
        else // door closes away from pawn
            PlayAnim('StandDoorPull', 1.0, 0.2);
    }
}

//===================================================================================================    
// PlayCrouchedDoorAnim()
//===================================================================================================
simulated function PlayCrouchedDoorAnim(R6IORotatingDoor door)
{
    local   bool    bOpensTowardsPawn;

    bOpensTowardsPawn = door.DoorOpenTowardsActor(self);

    //Dont blend animations for left hand
    m_ePlayerIsUsingHands = HANDS_Left;

    // if door is closed, play opening animation    
    if(door.m_bIsDoorClosed)
    {
        // door opens towards pawn
        if(bOpensTowardsPawn)
            PlayAnim('CrouchDoorPull', 1.0, 0.2);
        else  // door opens away from pawn
            PlayAnim('CrouchDoorPush', 1.0, 0.2);
    }  
    else  // otherwise play a close door animation
    {
        // door closes towards pawn
        if(bOpensTowardsPawn)
            PlayAnim('CrouchDoorPush', 1.0, 0.2);
        else // door closes away from pawn
            PlayAnim('CrouchDoorPull', 1.0, 0.2);
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  LADDER FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

//===================================================================================================
// LocateLadderActor()                                        
//    determine which ladder actor this pawn is closest to              
//    (top or bottom)
//===================================================================================================
function Ladder LocateLadderActor(LadderVolume L)
{
    if(L == none)
        return none;

    if(VSize(R6LadderVolume(L).m_TopLadder.location - location) < VSize(R6LadderVolume(L).m_BottomLadder.location - location))
        return R6LadderVolume(L).m_TopLadder;
    else
        return R6LadderVolume(L).m_BottomLadder;
}

function ServerClimbLadder(LadderVolume L, R6Ladder ladder )
{
    #ifdefDEBUG if(bShowLog) log(" ServerClimbLadder L="$L$" ladder="$ladder$" onLadder="$onLadder$" m_Ladder="$m_Ladder);   #endif
    if(onLadder == L)
        return;

    m_Ladder = ladder;
    ClimbLadder(L);
}

//===================================================================================================
// ClimbLadder()                                              
//===================================================================================================
function ClimbLadder(LadderVolume L)
{
    local  vector   vStartPosition; 

    if(m_bIsClimbingLadder)
        return;  

    // check if pawn is falling while trying to engage ladder
    if(physics == PHYS_Falling)
        return;

    #ifdefDEBUG if(bShowLog) log(self$" ClimbLadder() was called.... L="$L);     #endif
    onLadder = L;
    if(m_Ladder == none)
    {
        #ifdefDEBUG if(bShowLog) log(" LAST RESORT!! find m_Ladder...."); #endif
        m_Ladder = R6Ladder(LocateLadderActor(L));
    }

    if(Level.NetMode == NM_Client)
		ServerClimbLadder(L, m_Ladder);

    // make sure pawn has correct orientation before getting on the ladder
    if(m_Ladder.m_bIsTopOfLadder)
    {
        #ifdefDEBUG if(bShowLog) log("m_Ladder="$m_Ladder); #endif
        vStartPosition = m_Ladder.location + 50*vector(onLadder.LadderList.Rotation);
        vStartPosition.z = location.z; 
        SetRotation(m_Ladder.rotation + rot(0,32768,0));
    }
    else
    {
        vStartPosition = m_Ladder.location;
        vStartPosition.z = location.z;
        SetRotation(m_Ladder.rotation);
    }           
    SetLocation(vStartPosition);  
    SetPhysics(PHYS_Ladder);  
	R6LadderVolume(L).AddClimber(self);
    
	if (m_bIsPlayer) 
        R6PlayerController(controller).GotoState('PreBeginClimbingLadder');
    else
        R6AIController(controller).GotoState('BeginClimbingLadder');       
}

simulated function PlayStartClimbing()
{
    local name animName;

    // if playing a special in this channel, end it (ie: grenade effect)
    AnimBlendToAlpha(C_iPawnSpecificChannel, 0.0, 0.5 );

    #ifdefDEBUG if(bShowLog) log(self$" PlayStartClimbing() was called..."); #endif
    m_bSlideEnd = false;

//  if((m_Ladder == none) && (onLadder != none))
//      m_Ladder = R6Ladder(LocateLadderActor(onLadder));

    if(m_Ladder == none)
        logWarning( "PlayStartClimbing() "$self$" m_Ladder="$m_Ladder$" onLadder="$onLadder );

    if(m_Ladder!=none && m_Ladder.m_bIsTopOfLadder)   
        animName = 'StandLadderDown_b';
    else
        animName = 'StandLadderUp_b';

    m_ePlayerIsUsingHands = HANDS_Both;
    PlayRootMotionAnimation(animName, ArmorSkillEffect()*1.5);
}

simulated function bool EndOfLadderSlide()
{
    if(m_Ladder == none)
        return false;

    if((location.z - collisionHeight) > m_Ladder.location.z)
        return false;
    else
        return true;
}

simulated function PlayEndClimbing()
{
    local name animName;

    if(physics == PHYS_Walking)
        return;

    #ifdefDEBUG if(bShowLog) log(self$" PlayEndClimbing() was called..."); #endif
//  if((m_Ladder == none) && (onLadder != none))
//      m_Ladder = R6Ladder(LocateLadderActor(onLadder));

    if(m_Ladder.m_bIsTopOfLadder) 
    {   
        // climbing up... end climb at top of ladder
        m_ePlayerIsUsingHands = HANDS_Both;
        PlayRootMotionAnimation('StandLadderUp_e', ArmorSkillEffect()*1.5);  
    }
    else
    {
        if((m_ePawnType == PAWN_Rainbow) && EndOfLadderSlide())
        {
            #ifdefDEBUG if(bShowLog) log(self$" play ladder slide end animation "); #endif
            m_bSlideEnd = true;
            // play ladder slide end animation
            PlayAnim('StandLadderSlide_e', 1.5*ArmorSkillEffect(), 0.0); 
            // PlaySound() ICI Jouer le son générique.
        }
        else   
        {
            #ifdefDEBUG if(bShowLog) log(self$" player ladder end normal (root motion) "); #endif
            // climbing down... end climb at bottom of ladder
            #ifdefDEBUG if(bShowLog) log(" PlayEndClimbing() ... climbing down..."); #endif
            m_ePlayerIsUsingHands = HANDS_Both;
            PlayRootMotionAnimation('StandLadderDown_e', ArmorSkillEffect()*1.5);
        }
    }
}

event EndClimbLadder(LadderVolume OldLadder)
{
    local INT iFacing;

    #ifdefDEBUG if(bShowLog) log(" EndClimbLadder() is called... ");  #endif
    if(onLadder == None)
    {
        #ifdefDEBUG if (bShowLog) log(" .... we exit because onLadder == none , physics ="$physics); #endif
        return;
    }

    R6LadderVolume(OldLadder).RemoveClimber(self);
    if(m_bIsPlayer)
    {
        if(!m_bIsClimbingLadder)
            return;
    }
    else
    {
        if(controller.isInState('EndClimbingLadder'))
        {
            #ifdefDEBUG if (bShowLog) log(" endClimbLadder() called because pawn has exited the LadderVolume...");           #endif
            SetPhysics(PHYS_Walking);  // TODO: move this to someplace more global (if possible)
            return;            
        }
    }
        
    if(m_bIsPlayer)
    {
        if(Level.NetMode != NM_Client)
        {   
			R6PlayerController(controller).m_bSkipBeginState = false;
            R6PlayerController(controller).GotoState('PlayerEndClimbingLadder');
        }
    }
    else
    {
        R6AIController(controller).GotoState('EndClimbingLadder');
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  STAIRS FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

//===================================================================================================
// ClimbStairs()
//  vStairDirection indicates the direction towards the top of the stairs
//===================================================================================================
simulated function ClimbStairs(vector vStairDirection)
{
    PrePivot.Z -= C_fPrePivotStairOffset;
    m_vPrePivotProneBackup.Z -= C_fPrePivotStairOffset;

    // store direction of stair climbing...
    m_vStairDirection = vStairDirection;
    ChangeAnimation();
}

//===================================================================================================
// EndClimbStairs()
//===================================================================================================
simulated function EndClimbStairs()
{
    PrePivot.Z += C_fPrePivotStairOffset;
    m_vPrePivotProneBackup.Z += C_fPrePivotStairOffset;

    ChangeAnimation();
}

simulated function bool IsUsingHeartBeatSensor()
{
    if(!m_bIsPlayer)
        return false;

    if( (EngineWeapon != none) && EngineWeapon.IsGoggles() )
        return true;

    return false;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  BONE CONTROL FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// GunShouldFollowHead()
// rbrek - 11 april 2002
///////////////////////////////////////////////////////////////////////////////////////
simulated function bool GunShouldFollowHead()
{
    if(physics == PHYS_RootMotion || m_bIsClimbingLadder) 
        return false;   

    if(IsUsingHeartBeatSensor())
        return true;
    
    if(m_fFiringTimer > 0)
        return true;

    if(m_bWeaponGadgetActivated)
        return true;

    return false;
}

//===================================================================================================
// rbrek - 13 feb 2002                                              
// AdjustPawnForDiagonalStrafing()                                      
//===================================================================================================
simulated event AdjustPawnForDiagonalStrafing()
{
    local rotator   rDirection;
    local rotator   rBoneRotation;
    local INT       iOffset;

    // if prone, we cant strafe oherewise the camera goes inside the geometry
    if ( !m_bMovingDiagonally || m_bIsProne )
        return;

    rDirection.pitch = m_rRotationOffset.pitch;
	// if bIsCrouched
	iOffset = 5825; //6000;

    rBoneRotation.yaw = iOffset;

    if((m_eStrafeDirection == STRAFE_ForwardRight) || (m_eStrafeDirection == STRAFE_BackwardLeft))
    {
        SetBoneRotation('R6', rBoneRotation,, 1.0, 0.4); 
        rDirection.yaw = -rBoneRotation.yaw;
        PawnLook(rDirection, true);
    }
    else
    {
        rBoneRotation.yaw *= -1;
        SetBoneRotation('R6', rBoneRotation,, 1.0, 0.4);        
        rDirection.yaw = -rBoneRotation.yaw;
        PawnLook(rDirection, true);
    }
}

simulated event ResetDiagonalStrafing()
{
    m_eStrafeDirection = STRAFE_None;
    m_bMovingDiagonally = false;
    SetBoneRotation('R6', rot(0,0,0),, 1.0, 0.4);
    R6ResetLookDirection();
}

//===================================================================================================
// rbrek - 15 oct 2001                                              
// TurnToFaceActor()                                      
//===================================================================================================
event TurnToFaceActor(Actor target)
{
    local rotator   rDesiredRotation;
    local INT       iYawDiff;

    rDesiredRotation = rotator(target.location - location);                         
    if(rDesiredRotation.yaw < 0)
    {
        rDesiredRotation.yaw += 65536;
    }
    else if(rDesiredRotation.yaw < 0)
    {
        rDesiredRotation.yaw -= 65536;          
    }
    iYawDiff = rDesiredRotation.yaw - rotation.yaw;

    if((iYawDiff > 32768) || ((iYawDiff > -32768) && (iYawDiff < 0)))
    {                   
        controller.SetLocation(target.location);
    }
    else
    {               
        controller.SetLocation(target.location); 
    }

    SetRotationOffset(0,0,0);
    controller.focus = controller;
}

//===================================================================================================
// rbrek - 3 oct 2001                                               
// function R6ResetLookDirection()                                  
//   Reset the bone rotations that have be imposed.                 
//===================================================================================================
simulated event R6ResetLookDirection()
{
    m_TrackActor = none;
    ResetBoneRotation();
}

///////////////////////////////////////////////////////////////////////////////////////

function eBodyPart WhichBodyPartWasHit(vector vHitLocation, vector vBulletDirection)
{
    local INT iHitDistanceFromGround;

    if( m_iTracedBone != 0 )
        return GetBodyPartFromBoneID( m_iTracedBone , vBulletDirection);

    iHitDistanceFromGround = vHitLocation.Z - Location.Z + CollisionHeight;

    //first check for head hit
    if ( iHitDistanceFromGround > 0.80 * 2 * CollisionHeight )
    {
        #ifdefDEBUG if (bShowLog) log("HitHead"); #endif
        CheckForHelmet(vBulletDirection);
        return eBodyPart.BP_Head;
    }
    else if(iHitDistanceFromGround > 0.6 * 2 * CollisionHeight )
    {
        #ifdefDEBUG if (bShowLog) log("Hitchest"); #endif
        return eBodyPart.BP_Chest;
    }
    else if(iHitDistanceFromGround > 0.45 * 2 * CollisionHeight )
    {
        #ifdefDEBUG if (bShowLog) log("Hitabdomen"); #endif
        return eBodyPart.BP_Abdomen;
    }
    else
    {
        #ifdefDEBUG if (bShowLog) log("HitLegs"); #endif
        return eBodyPart.BP_Legs;
    }
}


function eBodyPart GetBodyPartFromBoneID( BYTE iBone, vector vBulletDirection )
{
    // Chest
    if( iBone <= 5 || iBone == 15 || iBone == 10 )
    {
        #ifdefDEBUG if (bShowLog) log("HitChest"); #endif
        return eBodyPart.BP_Chest;
    }
    // Head
    else if( (iBone >= 6 && iBone <= 9) )
    {
        #ifdefDEBUG if (bShowLog) log("HitHead"); #endif
        CheckForHelmet(vBulletDirection);
        return eBodyPart.BP_Head;
    }
    // Arms
    else if( iBone >= 11 && iBone <= 19 && iBone != 15 )
    {
        #ifdefDEBUG if (bShowLog) log("HitArms"); #endif
        return eBodyPart.BP_Arms;
    }
    // Legs
    else
    {
        #ifdefDEBUG if (bShowLog) log("HitLegs"); #endif
        return eBodyPart.BP_Legs;
    }
}

function CheckForHelmet(vector vBulletDirection)
{
    local rotator rBulletRotator;
    local rotator rHeadRotator;
    local INT     iYawDiff;

    rHeadRotator = GetBoneRotation('R6 Head');
    rBulletRotator = rotator(vBulletDirection);

    iYawDiff = ShortestAngle2D(rBulletRotator.Yaw, rHeadRotator.Yaw);

    if(iYawDiff > 24576)
    {
        m_bHelmetWasHit=false;
    }
    else
    {
        m_bHelmetWasHit=true;
    }
}

function PlayerController GetHumanLeaderForAIPawn()
{
    local R6RainbowTeam _TeamManager;

    if (R6RainbowAI(Controller)==none)
        return none;
    _TeamManager = (R6RainbowAI(Controller)).m_TeamManager;        
    if ((_TeamManager == none) || (_TeamManager.m_TeamLeader == none) || (_TeamManager.m_TeamLeader.owner==none) )
        return none;
    return PlayerController(_TeamManager.m_TeamLeader.owner);
}

function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy, vector vHitLocation, 
                           vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
{
    local eKillResult eKillFromTable;
    local eStunResult eStunFromTable;
    local eBodyPart   eHitPart;
    local INT         iKillFromHit;
    local vector      vBulletDirection;
    local INT         iSndIndex;
    local bool        bIsSilenced;

    //BloodSplats
    local R6BloodSplat BloodSplat;
    local Rotator BloodRotation;
    local R6WallHit   aBloodEffect;
    local bool  _bAffectedActor;      // for sounds and stats (because of multiple bullets in shotguns)
    local PlayerController _playerController;

    //logX( "iKillValue=" $iKillValue$ " iStunValue=" $iStunValue$ " vHitLocation="$vHitLocation$ " vMomentum=" $vMomentum$ " iBulletToArmorModifier="$iBulletToArmorModifier );

    //  MPF1 
	//--------- MissionPack1 
	if( PlayerController(Controller)!= none &&
        PlayerController(Controller).GameReplicationInfo != none &&
        PlayerController(Controller).GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CaptureTheEnemyAdvMode")
	{
		return R6TakeDamageCTE(iKillValue,iStunValue,instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);
	}
	//-------MissionPack1


    if ( instigatedBy != none && instigatedBy.EngineWeapon != none )
        _bAffectedActor = instigatedBy.EngineWeapon.AffectActor(iBulletGoup,self);
    else 
        _bAffectedActor = false;
        
    // only track if instigated from an enemy and we only count shutgun fragments from the same shell once
    if ( IsEnemy(instigatedBy) && _bAffectedActor ) 
    {
        if(Level.NetMode == NM_Standalone)
        {       
            if( instigatedBy != none && instigatedBy.m_ePawnType == PAWN_Rainbow)
            {
                R6Rainbow(instigatedBy).IncrementRoundsHit();
            }
        }
        else if ((instigatedBy != none) && (Level.Game.m_bCompilingStats==true))
        {       
            // only track if instigated from an enemy
            if (instigatedBy.PlayerReplicationInfo != none)
            {
                instigatedBy.PlayerReplicationInfo.m_iRoundsHit++;
            }
            else
            {
                _playerController = R6Pawn(instigatedBy).GetHumanLeaderForAIPawn();
                if (_playerController!=none)
                {
                    _playerController.PlayerReplicationInfo.m_iRoundsHit++;
                }
            }
        }
    }

    TakeHitLocation = vHitLocation;

    if (!IsAlive())
    {
        if(Level.NetMode != NM_DedicatedServer)
        {
            //already dead.  We count the stat (above) and return
            KAddImpulse( Normal(vMomentum)*50000 , vHitLocation);
        }
        return 0;
    }

    // here, we don't allow the game to process damage if it's game over
    // - 
    if ( Level.NetMode == NM_Client)
    {
        if (m_bIsPlayer && R6PlayerController(controller).GameReplicationInfo.m_bGameOverRep)
        {
            return 0;
        }
    }
    else if ( Level.Game.m_bGameOver && !R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath )
    {
        return 0;
    }

    #ifdefDEBUG if(bShowLog) log(self$" inform Rainbow member that they are being attacked by (even if in god mode)... instigatedBy="$instigatedBy); #endif
    if(m_ePawnType==PAWN_Rainbow && !m_bIsPlayer )
        R6RainbowAI(controller).IsBeingAttacked(instigatedBy);

    if(InGodMode())
    {
        #ifdefDEBUG if(bShowLog) log("No damage, GOD MODE!"); #endif
        return 0;
    }

    eHitPart = WhichBodyPartWasHit(vHitLocation, vMomentum);

    //R6BLOOD
    m_eLastHitPart = eHitPart;

    if ( instigatedBy != none && instigatedBy.EngineWeapon != none )
        bIsSilenced = instigatedBy.EngineWeapon.m_bIsSilenced;
    else
        bIsSilenced = false;
    

    //Don't do anything if the character is dead
    if(m_eHealth != HEALTH_Dead)
    {
        //Force kill is set by the grenade or iobomb or by the debug function
        if(m_iForceKill != 0)
        {
            switch(m_iForceKill)
            {
            case 1:
                eKillFromTable = KR_None;
                break;
            case 2:
                eKillFromTable = KR_Wound;
                break;
            case 3:
                eKillFromTable = KR_Incapacitate;
                break;
            case 4:
                eKillFromTable = KR_Killed;
                break;
            }
        }
        else
        {
            eKillFromTable = GetKillResult(iKillValue, eHitPart, m_eArmorType, iBulletToArmorModifier, bIsSilenced );
        }

        //Default value set for stun values.
        if(m_iForceStun != 0 && m_iForceStun < 5)
        {
            switch(m_iForceStun)
            {
            case 1:
                eStunFromTable = SR_None;
                break;
            case 2:
                eStunFromTable = SR_Stunned;
                break;
            case 3:
                eStunFromTable = SR_Dazed;
                break;
            case 4:
                eStunFromTable = SR_KnockedOut;
                break;
            }
        }
        else
        {
            //If the character is not out
            eStunFromTable = GetStunResult(iStunValue, eHitPart, m_eArmorType, iBulletToArmorModifier, bIsSilenced );
        }

        vBulletDirection = Normal(vMomentum);

        //Spawn blood splat
        BloodRotation = Rotator(vBulletDirection);
        BloodRotation.Roll = 0;

        if ( !InGodMode() && (eKillFromTable != KR_None))
        {
            aBloodEffect = Spawn(class'R6SFX.r6BloodEffect', , , vHitLocation);
            if ((aBloodEffect != none) && !_bAffectedActor)
                aBloodEffect.m_bPlayEffectSound = false;
        }

        if(eKillFromTable == KR_Killed)
			BloodSplat = Spawn(class'Engine.R6BloodSplat',,, vHitLocation, BloodRotation);
		else if(eKillFromTable != KR_None)
			BloodSplat = Spawn(class'Engine.R6BloodSplatSmall',,, vHitLocation, BloodRotation);

        // Move the bone
        if(m_iTracedBone!=0)
        {
            m_rHitDirection = rotator(vBulletDirection);
            if ( Level.NetMode != NM_Client )
                SetNextPendingAction( PENDING_MoveHitBone, m_iTracedBone );
        }

        if((eKillFromTable == KR_Killed)
            || ((eKillFromTable == KR_Incapacitate || eKillFromTable == KR_Wound) && (m_eHealth == HEALTH_Incapacitated))
            || ((eKillFromTable == KR_Incapacitate ) && (m_eHealth == HEALTH_Wounded)))
        {
            #ifdefDEBUG if (bShowLog) log("...... pawn "$self$" is DEAD!! hit="$eKillFromTable$"  priorHealth="$m_eHealth$" was killed by "$instigatedBy); #endif
            m_eHealth = HEALTH_Dead;    
        }
        else if(eKillFromTable == KR_Incapacitate  || (eKillFromTable == KR_Wound && m_eHealth == HEALTH_Wounded))
        {
            #ifdefDEBUG if (bShowLog) log("...... pawn "$self$" is INCAPACITATED!! hit="$eKillFromTable$"  priorHealth="$m_eHealth); #endif
            m_eHealth = HEALTH_Incapacitated;
        }
        else if(eKillFromTable == KR_Wound)
        {
            #ifdefDEBUG if (bShowLog) log("...... pawn "$self$" is WOUNDED!! hit="$eKillFromTable$"  priorHealth="$m_eHealth); #endif
            m_eHealth = HEALTH_Wounded;
            m_fHBWound = 1.2;

			if (m_bIsClimbingLadder)
				bIsWalking = true;

            // 17 jan 2002 rbrek - immediately update current animations with injured ones (if such anims exist)
            ChangeAnimation(); 
        }

        if( instigatedBy != none && R6PlayerController(instigatedBy.Controller) != none)
        {
            if(R6PlayerController(instigatedBy.Controller).m_bShowHitLogs)
            {
                log("Player HIT : "$self$" Bullet Energy : "$iKillValue$" body part : "$eHitPart$" KillResult : "$eKillFromTable$" Armor type : "$m_eArmorType);
            }
        }
    
        // update the team's knowledge about this member's health status
        if(m_ePawnType==PAWN_Rainbow && (eKillFromTable != KR_None))
        {
            if( m_bIsPlayer )
            {
                R6PlayerController(controller).m_TeamManager.m_eMovementMode = MOVE_Assault;
                R6PlayerController(controller).m_TeamManager.UpdateTeamStatus(self);
            }
            else if(R6RainbowAI(controller).m_TeamManager!=none)
            {
                R6RainbowAI(controller).m_TeamManager.m_eMovementMode = MOVE_Assault;
                R6RainbowAI(controller).m_TeamManager.UpdateTeamStatus(self);
            }
        }
    
        // Inform controller that this pawn is under attack
        if(controller != none)
        {
            controller.R6DamageAttitudeTo(instigatedBy, eKillFromTable, eStunFromTable, vMomentum);
            if (eKillFromTable != KR_None)
                controller.PlaySoundDamage(instigatedBy);        
        }
        else
        {
            #ifdefDEBUG if (bShowLog) log("NoController"); #endif
        }

        if(eKillFromTable != KR_None)
        {
            // Adjust momentum from stun result (for the rag doll)
            iStunValue = Min( iStunValue, 5000 );
            vMomentum = Normal(vMomentum) * (iStunValue*100);
            if( !IsAlive() )
            {
                //Kill the pawn
                R6Died(instigatedBy, eHitPart, vMomentum);  
            }
        }
    }

    //The bullet can always go through a body part, even if the character is dead.
    iKillFromHit = GetThroughResult(iKillValue, eHitPart, vMomentum);
    
    if(PlayerReplicationInfo != none)
    {
        switch(m_eHealth)
        {
        case HEALTH_Healthy:
            PlayerReplicationInfo.m_iHealth = 0;//ePlayerStatus_Alive;
            break;
        case HEALTH_Wounded:
            PlayerReplicationInfo.m_iHealth = 1;//ePlayerStatus_Wounded;
            break;
        case HEALTH_Incapacitated:
        case HEALTH_Dead:
            PlayerReplicationInfo.m_iHealth = 2;//ePlayerStatus_Dead;
            break;
        }
    }
    
    return iKillFromHit;    // Goes through if iKillFromHit > 0
}

//============================================================================
// R6Died
//      Called only on the server
//============================================================================
function R6Died(Pawn Killer, eBodyPart eHitPart, vector vMomentum)
{
    local R6AbstractGameInfo pGameInfo;
    local INT i;
    local r6PlayerController P;
    local R6AbstractWeapon aWeapon;
    local string KillerName;
    local string szPlayerName;

#ifndefMPDEMO
	if(Killer == none)
		log(" R6Died() : WARNING : Killer=none");
#endif

    if(Killer.PlayerReplicationInfo != none)
        KillerName = Killer.PlayerReplicationInfo.PlayerName;
    else
        KillerName = Killer.m_CharacterName; // Was copied in UnPossessed()

    #ifdefDEBUG if(bShowLog) logX(" entered function R6Died, was killed by " $ Killer ); #endif
    
    // Remove from ladder
    if(m_bIsClimbingLadder || Physics==PHYS_Ladder)
    {
#ifndefMPDEMO
		if(m_Ladder == none || m_Ladder.myLadder == none)
			log(" R6Died() : WARNING : m_Ladder="$m_Ladder$" m_Ladder.myLadder="$m_Ladder.myLadder);
#endif
		R6LadderVolume(m_Ladder.myLadder).RemoveClimber(self);
		if(m_bIsPlayer && m_Ladder != none)
			R6LadderVolume(m_Ladder.myLadder).DisableCollisions(m_Ladder);
	}

    // stop rootmotion
    if ( Physics == PHYS_RootMotion ) 
    {
        if( Controller != none )
            Controller.GotoState('');

        if ( bIsCrouched )
            PlayPostRootMotionAnimation( m_crouchDefaultAnimName );
        else
            PlayPostRootMotionAnimation( m_standDefaultAnimName );
    }

    // close current gagdet if activated.
    aWeapon = R6AbstractWeapon(EngineWeapon);
    if( aWeapon != none && aWeapon.m_SelectedWeaponGadget!=None)
        aWeapon.m_SelectedWeaponGadget.ActivateGadget(FALSE);

    // Variables setting
    if(vMomentum==vect(0,0,0))
        vMomentum = vect(1,1,1);
    TearOffMomentum = vMomentum;
    bAlwaysRelevant = true;
    for(i=0; i<=3; i++)
    {
        if(m_WeaponsCarried[i]!=none)
            m_WeaponsCarried[i].SetRelevant(true);
    }

    //EngineWeapon.bAlwaysRelevant = true;
    m_bUseRagdoll   = true;
    bProjTarget     = false;

    SpawnRagDoll();

    m_KilledBy = R6Pawn(Killer);

    if( ProcessBuildDeathMessage( Killer, szPlayerName ) )
    {
        #ifdefDEBUG if (bShowLog) log(class'R6Pawn'.static.BuildDeathMessage(KillerName, szPlayerName, m_bSuicideType )); #endif
        ForEach DynamicActors(class'R6PlayerController', P)
        {
            P.ClientDeathMessage(KillerName, szPlayerName, m_bSuicideType );
        }
    }

#ifndefMPDEMO
	if(m_KilledBy == none)
		log("  R6Died() : Warning!!  m_KilledBy="$m_KilledBy);
#endif
    if( m_KilledBy == Self ) // if this is suicide, most probably by grenade
    {
        m_bSuicided = true;
    }
    else
    {       
        if(IsEnemy(m_KilledBy))
            m_KilledBy.IncrementFragCount();
    }
    
    if (R6PlayerController(Controller) != none)
    {
        R6PlayerController(Controller).ClientDisableFirstPersonViewEffects();
        R6PlayerController(Controller).PlayerReplicationInfo.m_szKillersName = KillerName;
    }
    
    // GameInfo stuff
    pGameInfo = R6AbstractGameInfo(Level.Game);
    if ( pGameInfo != none )
    {
        // compile stats only when we have adversaries
        if ((pGameInfo.m_bCompilingStats==true || (pGameInfo.m_bGameOver && pGameInfo.m_bGameOverButAllowDeath)))
        { 
            if (controller.PlayerReplicationInfo != none)
            {
                controller.PlayerReplicationInfo.Deaths += 1.f;
                if ( !m_bSuicided && m_KilledBy != none && m_KilledBy.Controller != none && m_KilledBy.Controller.PlayerReplicationInfo!=none )
                    m_KilledBy.Controller.PlayerReplicationInfo.Score += 1.f;
            }
            else
            {
                P = R6PlayerController(GetHumanLeaderForAIPawn());
                if (P!=none)
                {
                    P.PlayerReplicationInfo.Deaths += 1.f;
                }
            }
        }

        pGameInfo.PawnKilled( self );
        pGameInfo.SetTeamKillerPenalty(self, killer);
    }
}

// this function should only be entered server side
function IncrementFragCount()
{
    local PlayerController _playerController;
    if(Level.NetMode == NM_Standalone)
    {       
        if(Instigator.IsA('R6Rainbow'))
            R6Rainbow(Instigator).IncrementKillCount();
    }
    else
    {
        if ((Level.Game!=none) && (Level.Game.m_bCompilingStats==true))
        {
            if (PlayerReplicationInfo != none)
            {
                PlayerReplicationInfo.m_iKillCount += 1;
                PlayerReplicationInfo.m_iRoundKillCount += 1;
            }
            else 
            {
                _playerController = GetHumanLeaderForAIPawn();
                if (_playerController!=none)
                {
                    _playerController.PlayerReplicationInfo.m_iKillCount++;
                    _playerController.PlayerReplicationInfo.m_iRoundKillCount++;
                }
            }
        }
    }
}

function ServerForceKillResult(INT iKillResult)
{
    m_iForceKill = iKillResult;
}

function ServerForceStunResult(INT iStunResult)
{
    m_iForceStun = iStunResult;
}

function ToggleHeatVision()
{
    if(Level.m_bHeartBeatOn == true)
        return;
    if(m_bActivateScopeVision == true)
    {  
        m_bActivateHeatVision = !m_bActivateHeatVision;
        R6PlayerController(Controller).m_bHeatVisionActive = m_bActivateHeatVision;
        R6PlayerController(Controller).ServerToggleHeatVision(m_bActivateHeatVision);

        //Turn off night vision
        if(m_bActivateNightVision == true)
        {
            m_bActivateNightVision = false;
            ToggleNightProperties(false, none, none);
            R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionDeactivation, SLOT_SFX);
        }

        if(m_bActivateHeatVision == true)
        {
            ToggleScopeProperties(false, none, none);
            ToggleHeatProperties(m_bActivateHeatVision, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
            R6PlayerController(Controller).ClientPlaySound(m_sndThermalScopeActivation, SLOT_SFX);
        }
        else if((m_bActivateScopeVision == true) && (m_bActivateHeatVision == false))
        {
            R6PlayerController(Controller).ClientPlaySound(m_sndThermalScopeDeactivation, SLOT_SFX);
            ToggleHeatProperties(false, none, none);
            ToggleScopeProperties(true, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
        }
    }
} 

exec function ToggleNightVision()
{
    if(Level.m_bHeartBeatOn == true)
        return;

    m_bActivateNightVision = !m_bActivateNightVision;

    if(R6Rainbow(self) != none)
        R6Rainbow(self).ServerToggleNightVision(m_bActivateNightVision);

    //Turn off night vision
    if(m_bActivateHeatVision == true)
    {
        m_bActivateHeatVision = false;
        R6PlayerController(Controller).m_bHeatVisionActive = m_bActivateHeatVision;
        R6PlayerController(Controller).ServerToggleHeatVision(m_bActivateHeatVision);
        ToggleHeatProperties(false, none, none);
        R6PlayerController(Controller).ClientPlaySound(m_sndThermalScopeDeactivation, SLOT_SFX);
    }

    if((m_bActivateScopeVision == true) && (m_bActivateNightVision == true) && (EngineWeapon.m_ScopeTexture != none))
    {
        R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionActivation, SLOT_SFX);
        ToggleScopeProperties(false, none, none);
        ToggleNightProperties(m_bActivateNightVision, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
    }
    else if((m_bActivateScopeVision == true) && (m_bActivateNightVision == false))
    {
        R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionDeactivation, SLOT_SFX);
        ToggleNightProperties(false, none, none); 
        ToggleScopeProperties(true, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
    }
    else
    {        
        if (m_bActivateNightVision)
        {
//          log("!@@!@!@!@!@!@! #1");
            R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionActivation, SLOT_SFX);
        }
        else
        {
//          log("!@@!@!@!@!@!@! #2" @ m_sndNightVisionDeactivation);
            R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionDeactivation, SLOT_SFX);
        }
        ToggleNightProperties(m_bActivateNightVision, Texture'Inventory_t.NightVision.NightVisionTex', none);
    }
}

function ToggleScopeVision()
{
    if(Level.m_bHeartBeatOn == true)
        return;
    
    if(Level.NetMode == NM_DedicatedServer)
        return;

    m_bActivateScopeVision = !m_bActivateScopeVision;

    if((m_bActivateNightVision == false) && (m_bActivateHeatVision == false))
    {
        ToggleScopeProperties(m_bActivateScopeVision, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
    }
    else if(m_bActivateNightVision == true)
    {
        if((m_bActivateScopeVision == true) && (EngineWeapon.m_ScopeTexture != none))
        {
            ToggleNightProperties(true, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
        }
        else 
        {
            ToggleNightProperties(true, Texture'Inventory_t.NightVision.NightVisionTex', none);
        }
    }
    else if(m_bActivateHeatVision == true)
    {
        if(m_bActivateScopeVision == true)
        {
            ToggleHeatProperties(true, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
        }
        else 
        {
            m_bActivateHeatVision = false;
            R6PlayerController(Controller).m_bHeatVisionActive = m_bActivateHeatVision;
            R6PlayerController(Controller).ServerToggleHeatVision(m_bActivateHeatVision);
            ToggleHeatProperties(false, none, none);
        }
    }
} 

exec function ToggleGadget()
{
    local R6AbstractWeapon aWeapon;

    aWeapon = R6AbstractWeapon(EngineWeapon);

    if ((aWeapon != none) && (aWeapon.m_SelectedWeaponGadget != none))
    {
        m_bWeaponGadgetActivated = !m_bWeaponGadgetActivated;
        aWeapon.m_SelectedWeaponGadget.ActivateGadget(m_bWeaponGadgetActivated, R6PlayerController(Controller).bBehindView);
    }
}

//AK: don't invalidate this function, we need it to set the right weapon in MP games
//function ChangedWeapon(){}

///////////////////
// RELOAD WEAPON //
///////////////////
function ReloadWeapon()
{
    #ifdefDEBUG if(bShowLog) log( name $ " entered function ReloadWeapon" ); #endif

    EngineWeapon.PlayReloading(); 
}

//Notify function
simulated function ReloadingWeaponEnd()
{
    #ifdefDEBUG if(bShowLog) log ( name $ " entered function ReloadingWeaponEnd *****************************m_bIsPlayer="$m_bIsPlayer); #endif
    
    if( !m_bIsPlayer || !((Controller != none) && (R6PlayerController(Controller).bBehindView == FALSE)))
    {
        EngineWeapon.ChangeClip();
        EngineWeapon.GotoState('');
    }
}

//For rainbow when using Bolt Action rifles.
simulated function BoltActionSwitchToRight();

//Notify Function
// will always close the bipod at the beginning of an animation
simulated function WeaponBipod()
{
    local BOOL bSetBipod;
    local R6AbstractWeapon pWeaponWithTheBipod;

    pWeaponWithTheBipod = R6AbstractWeapon(EngineWeapon);
    if((EngineWeapon == PendingWeapon) || (PendingWeapon == none))
    {
        //At the beginning, bipod stay close or will be close
        bSetBipod = false;
    }

    if((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer))
    {
        pWeaponWithTheBipod.m_bDeployBipod = bSetBipod;
    }

    //In Single player Call this function and the listen server.
    if((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer))
    {
        pWeaponWithTheBipod.DeployWeaponBipod(bSetBipod);
    }
}

// Will always open the bipod at the end of an animation
simulated function WeaponBipodLast()
{
    local BOOL bSetBipod;
    local R6AbstractWeapon pWeaponWithTheBipod;

    pWeaponWithTheBipod = R6AbstractWeapon(EngineWeapon);
    if((EngineWeapon == PendingWeapon) || (PendingWeapon == none))
    {
        bSetBipod = m_bWantsToProne;
    }
    else
    {
        if(PendingWeapon.GotBipod())
        {
            pWeaponWithTheBipod = R6AbstractWeapon(PendingWeapon);
            bSetBipod = TRUE;
        }
    }

    if((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer))
    {
        pWeaponWithTheBipod.m_bDeployBipod = bSetBipod;
    }

    //In Single player Call this function and the listen server.
    if((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer))
    {
        pWeaponWithTheBipod.DeployWeaponBipod(bSetBipod);
    }
}

function ServerPlayReloadAnimAgain()
{
    m_bReloadAnimLoop = !m_bReloadAnimLoop;
}


simulated function PutShellInWeapon()
{
    #ifdefDEBUG if(bShowLog) log ( name $ " entered function PutShellInWeapon"); #endif
    
    if( !m_bIsPlayer || !((Controller != none) && (R6PlayerController(Controller).bBehindView == FALSE)))
    {
        EngineWeapon.ServerPutBulletInShotgun();
    }
}

simulated function FLOAT PrepareDemolitionsAnimation()
{
    local FLOAT fSkillDemolitions;

    fSkillDemolitions = GetSkill(SKILL_Demolitions);

    R6ResetAnimBlendParams(C_iPeekingAnimChannel);
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();  // this is necessary so that the hands are freed... (tofix rbrek)
    m_bPostureTransition = true;
    AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);

    if (Controller != none)
        Controller.PlaySoundCurrentAction(RTV_PlacingExplosives);

    if( fSkillDemolitions  < 0.6)
        return(0.8);
    else
        return(0.8 + ((fSkillDemolitions - 0.6)/0.4)*0.45);
}

simulated function PlayClaymoreAnimation()
{
    local FLOAT fAnimRate;
    local FLOAT fTween;

    if((Controller != none) && !Controller.IsInState('PlayerSetExplosive'))
    {
        if(Controller.bFire == 1)
            Controller.GotoState('PlayerSetExplosive');
        else 
            return;
    }
    
    #ifdefDEBUG if(bShowLog) log(self$" : PlayClaymoreAnimation() "); #endif
    fAnimRate = PrepareDemolitionsAnimation();
    
    if(m_bIsProne)
    {
        fTween = 0.2 / m_fGadgetSpeedMultiplier;
        PlayAnim('ProneClaymore', fAnimRate * m_fGadgetSpeedMultiplier, fTween, C_iBaseBlendAnimChannel);
    }
    else
    {
        if(!bIsCrouched)
            fTween = 1.0 / m_fGadgetSpeedMultiplier;
        PlayAnim('CrouchClaymore', fAnimRate * m_fGadgetSpeedMultiplier, fTween, C_iBaseBlendAnimChannel);    
    }
}

simulated function PlayRemoteChargeAnimation()
{
    local FLOAT fAnimRate;
    local FLOAT fTween;

    if((Controller != none) && !Controller.IsInState('PlayerSetExplosive'))
    {
        if(Controller.bFire == 1)
            Controller.GotoState('PlayerSetExplosive');
        else 
            return;
    }
    
    #ifdefDEBUG if(bShowLog) log(self$" : PlayRemoteChargeAnimation() "); #endif
    fAnimRate = PrepareDemolitionsAnimation();

    if(m_bIsProne)
    {
        fTween = 0.2 / m_fGadgetSpeedMultiplier;
        PlayAnim('ProneC4', fAnimRate * m_fGadgetSpeedMultiplier, fTween, C_iBaseBlendAnimChannel);
    }
    else
    {
        if(!bIsCrouched)
            fTween = 1.0 / m_fGadgetSpeedMultiplier;
        PlayAnim('CrouchC4', fAnimRate * m_fGadgetSpeedMultiplier, fTween, C_iBaseBlendAnimChannel);    
    }
}

simulated function PlayBreachDoorAnimation()
{
    local FLOAT fAnimRate;

    if(m_bIsPlayer && (Controller != none) && !Controller.IsInState('PlayerSetExplosive'))
    {
        if(Controller.bFire == 1)
            Controller.GotoState('PlayerSetExplosive');
        else 
            return;
    }
    
    #ifdefDEBUG if(bShowLog) log(self$" : PlayBreachDoorAnimation() "); #endif
    fAnimRate = PrepareDemolitionsAnimation();

    if(bIsCrouched)
        PlayAnim('CrouchPlaceBreach', fAnimRate * m_fGadgetSpeedMultiplier, 0, C_iBaseBlendAnimChannel);   
    else
        PlayAnim('StandPlaceBreach', fAnimRate * m_fGadgetSpeedMultiplier, 0, C_iBaseBlendAnimChannel);    
}

simulated function PlayInteractWithDeviceAnimation()
{
    local FLOAT fAnimRate;
    local FLOAT fSkillDevice;

    #ifdefDEBUG if(bShowLog) log(self$" : PlayInteractWithDeviceAnimation() is called..."); #endif
    if ((m_eDeviceAnim == BA_DisarmBomb) || (m_eDeviceAnim == BA_ArmBomb))
        fSkillDevice = GetSkill(SKILL_Demolitions);
    else
        fSkillDevice = GetSkill(SKILL_Electronics);

    if(fSkillDevice < 0.8)
        fAnimRate = 1.0 + ((0.8 - fSkillDevice) / 0.8) * 0.25;
    else
        fAnimRate = 0.8 + ((1 - fSkillDevice) / 0.2) * 0.2; 

    R6ResetAnimBlendParams(C_iPeekingAnimChannel);
    m_ePlayerIsUsingHands = HANDS_Both; 
    PlayWeaponAnimation();
    m_bPostureTransition = true;
    AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);

    switch(m_eDeviceAnim)
    {
        case BA_Keypad: 
            if (Controller != none)
                Controller.PlaySoundCurrentAction(RTV_DesactivatingSecurity);
            if(bIsCrouched)
                LoopAnim('CrouchKeyPad_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);    
            else
                LoopAnim('StandKeyPad_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);     
            break;         
        case BA_ArmBomb:
        case BA_DisarmBomb:
            LoopAnim('CrouchDisarmBomb_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);  
            break;
        case BA_PlantDevice:
            if (Controller != none)
                Controller.PlaySoundCurrentAction(RTV_PlacingBug);
            if(bIsCrouched)
                LoopAnim('CrouchPlaceBug_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);  
            else
                LoopAnim('StandPlaceBug_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);   
            break;      
        case BA_Keyboard:
            if (Controller != none)
                Controller.PlaySoundCurrentAction(RTV_AccessingComputer);
            if(bIsCrouched)
                LoopAnim('CrouchKeyboard_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);  
            else
                LoopAnim('StandKeyboard_c', fAnimRate, 0.5, C_iBaseBlendAnimChannel);  
            break;
    }
}

//============================================================================
// function PlayProneFireAnimation - 
//============================================================================
simulated function PlayProneFireAnimation() 
{
    local name animName;
    local float fRatio;

    if (m_ePawnType == PAWN_Terrorist)
    {
        return;
    }
   
    fRatio = 100;
    if ( m_iRepBipodRotationRatio > 0 )
    {
        if(EngineWeapon.IsLMG() == true)
        {
            animName = 'proneBipodRightFireLMG';
        }
        else
        {
            if(EngineWeapon.GetProneFiringAnimName() == 'ProneBipodFireAndBoltRifle')
            {
                animName = 'ProneBipodRightFireAndBoltRifle';
            }
            else
            {
                animName = 'proneBipodRightFireSniper';
            }
        }
    }
    else
    {
        if(EngineWeapon.IsLMG() == true)
        {
            animName = 'proneBipodLeftFireLMG';
        }
        else
        {
            if(EngineWeapon.GetProneFiringAnimName() == 'ProneBipodFireAndBoltRifle')
            {
                animName = 'ProneBipodLeftFireAndBoltRifle';
            }
            else
            {
                animName = 'ProneBipodLeftFireSniper';
            }
        }
    }

    if ( IsLocallyControlled() && Level.NetMode != NM_Standalone ) // in local and multi: needed for 3rd view camera
        fRatio = abs( m_fBipodRotation / C_iRotationOffsetBiPod );
    else
        fRatio = abs( m_iRepBipodRotationRatio / fRatio );
    
    AnimBlendParams(C_iPostureAnimChannel, fRatio, 0.0, 0.0, 'R6');
    PlayAnim(animName, 1.5, 0.0, C_iPostureAnimChannel);
}


//============================================================================
simulated function BOOL GetReloadWeaponAnimation( out STWeaponAnim stAnim ) { return false; }
simulated function BOOL GetChangeWeaponAnimation( out STWeaponAnim stAnim ) { return false; }
simulated function BOOL GetFireWeaponAnimation( out STWeaponAnim stAnim ) { return false; }
simulated function BOOL GetThrowGrenadeAnimation( out STWeaponAnim stAnim ) { return false; }
simulated function BOOL GetNormalWeaponAnimation( out STWeaponAnim stAnim ) { return false; }
simulated function BOOL GetPawnSpecificAnimation( out STWeaponAnim stAnim ) { return false; }

simulated function BOOL HasPawnSpecificWeaponAnimation()
{
    return false;
}

//============================================================================
// event PlayWeaponAnimation - 
//============================================================================
simulated event PlayWeaponAnimation()
{
    local STWeaponAnim stAnim;
    local BOOL bContinue;

    if( m_bWeaponTransition || m_bPostureTransition )
        return;

    //if pawn uses both hands, don't play any weapon animations
    if(m_ePlayerIsUsingHands == HANDS_Both)
    {
        if(m_eLastUsingHands != m_ePlayerIsUsingHands)
        {
            m_eLastUsingHands = m_ePlayerIsUsingHands;
            //Stop the animation only the first time.
            R6ResetAnimBlendParams(C_iWeaponRightAnimChannel);
            R6ResetAnimBlendParams(C_iWeaponLeftAnimChannel);
        }           
        return;
    }

    if( EngineWeapon == none )
    {
        bContinue = GetNormalWeaponAnimation( stAnim );
    }
    else if( HasPawnSpecificWeaponAnimation() )
    {
        bContinue = GetPawnSpecificAnimation( stAnim );
    }
    // ================
    // Reloading
    else if( m_bReloadingWeapon )
    {
        bContinue = GetReloadWeaponAnimation( stAnim );
    }
    // ================
    // Change weapon
    else if( m_bChangingWeapon )
    {
        bContinue = GetChangeWeaponAnimation( stAnim );
    }
    // ================
    // Fire
    else if(EngineWeapon.bFiredABullet == TRUE)  //Firing animation
    {
        bContinue = GetFireWeaponAnimation( stAnim );
        EngineWeapon.bFiredABullet = FALSE;
    }
    // ================
    // Throw grenade
    else if (m_eGrenadeThrow != GRENADE_None)
    {
        bContinue = GetThrowGrenadeAnimation( stAnim );
    }
    // ================
    // Normal stance
    else
    {
        bContinue = GetNormalWeaponAnimation( stAnim );
    }

    if(m_bReAttachToRightHand == true)
    {
        BoltActionSwitchToRight();
    }

    // ================
    // Play Anim Here
    // ================
    if( bContinue )
    {
        if( m_bPreviousAnimPlayOnce || m_WeaponAnimPlaying!=stAnim.nAnimToPlay || m_eLastUsingHands!=m_ePlayerIsUsingHands )
        {
            m_bPreviousAnimPlayOnce = stAnim.bPlayOnce;
            m_eLastUsingHands = m_ePlayerIsUsingHands;
            #ifdefDEBUG if (bShowLog) log("ANIM: "$ self $" Playing Anim: "$ stAnim.nAnimToPlay $" Player is using Hands: "$ m_ePlayerIsUsingHands $" PlayOnce = " $ stAnim.bPlayOnce); #endif
            #ifdefDEBUG if (bShowLog) log("ANIM BlendName : "$ stAnim.nBlendName); #endif

            // Both hands or right hand
            if(m_ePlayerIsUsingHands == HANDS_None || m_ePlayerIsUsingHands == HANDS_Left)
            {
                AnimBlendParams(C_iWeaponRightAnimChannel, 1.0,,, stAnim.nBlendName);
                if( stAnim.bPlayOnce )
                {
                    PlayAnim( stAnim.nAnimToPlay, stAnim.fRate, stAnim.fTweenTime, C_iWeaponRightAnimChannel, stAnim.bBackward);
                }
                else
                {
                    LoopAnim( stAnim.nAnimToPlay, stAnim.fRate, stAnim.fTweenTime, C_iWeaponRightAnimChannel );
                }
                m_WeaponAnimPlaying = stAnim.nAnimToPlay;
            }
            else
            {
                if(!m_bNightVisionAnimation) 
                    R6ResetAnimBlendParams(C_iWeaponRightAnimChannel);
            }

            // Left hand
            if( (m_ePlayerIsUsingHands == HANDS_None || m_ePlayerIsUsingHands == HANDS_Right) && (stAnim.nBlendName == 'R6 R Clavicle') )
            { 
                AnimBlendParams(C_iWeaponLeftAnimChannel, 1.0,,, 'R6 L Clavicle');
                if( stAnim.bPlayOnce )
                {
                    PlayAnim( stAnim.nAnimToPlay, stAnim.fRate, stAnim.fTweenTime, C_iWeaponLeftAnimChannel, stAnim.bBackward);
                }
                else
                {
                    LoopAnim( stAnim.nAnimToPlay, stAnim.fRate, stAnim.fTweenTime, C_iWeaponLeftAnimChannel);
                    m_WeaponAnimPlaying = stAnim.nAnimToPlay;
                }
            }
            else
            {
                if(!m_bNightVisionAnimation) 
                    R6ResetAnimBlendParams(C_iWeaponLeftAnimChannel);
            }
        }
    }
}

//============================================================================
// ServerChangedWeapon - 
//============================================================================
function ServerChangedWeapon(R6EngineWeapon OldWeapon, R6EngineWeapon W)
{
    local vector vTagLocation;
    local rotator rTagRotator;

    if ( W == None )
    {
        return;
    }
    if ( OldWeapon != None )
    {
        OldWeapon.SetDefaultDisplayProperties();        
        DetachFromBone( OldWeapon ); // Remove old weapon attachment from self (includes setting weapon base to null.)
    }
    EngineWeapon = W;
    m_pBulletManager.SetBulletParameter(EngineWeapon);

    // Attaching EngineWeapon to actor bone.
    AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint); // Attach new weapon (includes a SetBase to 'self'.) 

    EngineWeapon.SetRelativeLocation(vect(0,0,0));

	if(Level.NetMode == NM_ListenServer)
	{
		// if EngineWeapon was just received, we need to call PlayWeaponAnimation() so that the appropriate neutral weapon animation is played.
		// (otherwise pawn will continue playing the NoGun_nt animations until the player moves)
		PlayWeaponAnimation();
	}
}

//Notify called by the animations ro attach the weapon to the left hand for reloading.
simulated function GetClipInHand()
{
    if((R6AbstractWeapon(EngineWeapon) != none) && (R6AbstractWeapon(EngineWeapon).m_MagazineGadget != none))
    {
        R6AbstractWeapon(EngineWeapon).m_MagazineGadget.SetBase(none);
        AttachToBone(R6AbstractWeapon(EngineWeapon).m_MagazineGadget, 'TagMagazineHand');
        R6AbstractWeapon(EngineWeapon).m_MagazineGadget.SetRelativeLocation(vect(0,0,0));
        R6AbstractWeapon(EngineWeapon).m_MagazineGadget.SetRelativeRotation(Rot(0,0,0));
    }
}

// Notify called to attach the magazine to the weapon once reload is over
simulated function AttachClipToWeapon()
{    
    if(R6AbstractWeapon(EngineWeapon).m_MagazineGadget != none)
    {
        DetachFromBone(R6AbstractWeapon(EngineWeapon).m_MagazineGadget);
        R6AbstractWeapon(EngineWeapon).m_MagazineGadget.UpdateAttachment( EngineWeapon );
    }
}

// Notify function for foot on ladder
simulated function FootStepLadder()
{
    if (m_Ladder != none)
    {
        SendPlaySound(R6LadderVolume(m_Ladder.myLadder).m_FootSound, SLOT_SFX);
    }

}
// Notify function for Hands on ladder
simulated function HandGripLadder()
{
    if (m_Ladder != none)
    {
        SendPlaySound(R6LadderVolume(m_Ladder.myLadder).m_HandSound, SLOT_SFX);
    }
}
// Notify function for footsteps
simulated function FootStepRight()
{
    // #ifdefDEBUG if (bShowLog) log("FootStepRight TIME:"@ Level.TimeSeconds); #endif
    m_bLeftFootDown = FALSE;

    FootStep('R6 R Foot', false);
}

// Notify function for footsteps
simulated function FootStepLeft()
{
    // #ifdefDEBUG if (bShowLog) log("FootStepLeft TIME:"@ Level.TimeSeconds); #endif
    m_bLeftFootDown = TRUE;

    FootStep('R6 L Foot',true);
}

// Notify function for Surface. Can be call for other notify also.
simulated event PlaySurfaceSwitch()
{
    // #ifdefDEBUG if (bShowLog) log("PlaySurfaceSwitch"); #endif

    if (m_ePawnType == PAWN_Rainbow) 
    {
        SendPlaySound(Level.m_SurfaceSwitchSnd, SLOT_SFX);
    }
    else
    {
        SendPlaySound(Level.m_SurfaceSwitchForOtherPawnSnd, SLOT_SFX);
    }
}

//============================================================================
// IsFighting: return true when the pawn is in active combat (ie: a threat)
//============================================================================
function bool IsFighting()
{
    return false;
}

//===================================================================================================
// IsStationary
//   21 jan 2002 rbrek - check only acceleration.  velocity is only set to (0,0,0) a few ticks later...
//===================================================================================================
function bool IsStationary()
{
    if((velocity == vect(0,0,0)) && (acceleration == vect(0,0,0)))
        return true;
    else
        return false;
}

simulated function bool CheckForPassiveGadget(string aClassName)
{
    return false;
}

function CreateBulletManager()
{
    local Class<R6AbstractBulletManager> aBulletMgrClass;
    
    aBulletMgrClass = class<R6AbstractBulletManager>(DynamicLoadObject("R6Weapons.R6BulletManager", class'Class'));

    m_pBulletManager = Spawn(aBulletMgrClass);
    if(m_pBulletManager != none)
        m_pBulletManager.InitBulletMgr(Self);
}

simulated function ServerGivesWeaponToClient(string aClassName, 
                                             INT iWeaponOrItemSlot,
                                             optional string bulletType,
                                             optional string weaponGadget)
{
    local class<R6AbstractWeapon> WeaponClass;
    local R6AbstractWeapon NewWeapon;
	
    if(m_pBulletManager==none)
        CreateBulletManager();

    if (iWeaponOrItemSlot == 4)
    {
        if ((m_WeaponsCarried[2] != none) && (m_WeaponsCarried[3] != none))
        {
            #ifdefDEBUG if(bShowLog) log("Could not spawn weapon or inventory Group Already Full!"); #endif
            return;
        }
    }
    else if (m_WeaponsCarried[iWeaponOrItemSlot-1]!=none)
    {
        #ifdefDEBUG if(bShowLog) log("Could not spawn weapon or inventory Group Already Full!"); #endif
        return;
    }

    if (m_SoundRepInfo != none)
    {
        if((iWeaponOrItemSlot == 2) && (m_WeaponsCarried[0] == none))
        {
            m_SoundRepInfo.m_CurrentWeapon = 1;
        }
        else if (iWeaponOrItemSlot == 1)
        {
            m_SoundRepInfo.m_CurrentWeapon = 0;
        }
    }

    // check for passive devices/gadgets
    if(CheckForPassiveGadget(aClassName))
        return;

    WeaponClass = class<R6AbstractWeapon>(DynamicLoadObject(aClassName, class'Class'));
    NewWeapon = Spawn(WeaponClass, Self);

    if (NewWeapon != none)
    {
        NewWeapon.m_InventoryGroup = iWeaponOrItemSlot;
        if ((iWeaponOrItemSlot == 4) && (m_WeaponsCarried[2] == none))
        {
            NewWeapon.m_InventoryGroup = 3;
        }        
        NewWeapon.SetHoldAttachPoint();

        if (level.NetMode != NM_Standalone)
            NewWeapon.RemoteRole = ROLE_AutonomousProxy;

        NewWeapon.Instigator = self;

        #ifdefDEBUG if(bShowLog) log("Add weapon: " $ NewWeapon $ " To group : " $ NewWeapon.m_InventoryGroup $ " Owner is: " $ Self $ " Gadget : "$ weaponGadget); #endif

        if(m_ePawnType == PAWN_Rainbow)
        {
			AttachWeapon( NewWeapon, NewWeapon.m_HoldAttachPoint );
			if(NewWeapon.m_bHiddenWhenNotInUse)
				NewWeapon.bHidden = true;
		}

        if(weaponGadget != "")
            NewWeapon.m_WeaponGadgetClass = class<R6AbstractGadget>(DynamicLoadObject(weaponGadget, class'Class'));

        //Will only be called on listen server or in single player.
        if(Level.NetMode != NM_DedicatedServer)
        {
            NewWeapon.SetGadgets();
        }

        if (bulletType!="")
            NewWeapon.GiveBulletToWeapon(bulletType);

        m_WeaponsCarried[NewWeapon.m_InventoryGroup-1] = NewWeapon;
    }
}

//Defined in R6Rainbow.uc
simulated function GetWeapon(R6AbstractWeapon NewWeapon){}

simulated function R6EngineWeapon GetWeaponInGroup(INT iGroup)
{
	if(iGroup == 0)
	{
		log(self$"  Error : GetWeaponInGroup() : iGroup==0, iGroup must be between 1 and 4 ");
		return none;
	}
    return m_WeaponsCarried[iGroup-1];
}

simulated function AttachWeapon(R6EngineWeapon WeaponToAttach, name Attachment)
{
    if(WeaponToAttach == none)
        return;

    if( WeaponToAttach.bNetOwner || WeaponToAttach.Role == ROLE_Authority)
    {
        //Attach the weapon to Attachment
        AttachToBone(WeaponToAttach, Attachment);
    }
}

//------------------------------------------------------------------
// AttachCollisionBox
//  iNbOfColBox
//------------------------------------------------------------------
simulated function AttachCollisionBox( int iNbOfColBox )
{ 
    // first colbox
    if ( m_collisionBox == none && 1 <= iNbOfColBox  )
    {
        m_collisionBox = spawn( class'R6ColBox', self ); 
    }

    // second colbox
    if ( m_collisionBox2 == none && m_collisionBox != none && 2 <= iNbOfColBox  )
    {
        m_collisionBox2 = spawn( class'R6ColBox', m_collisionBox ); 
        m_collisionBox2.SetCollision( false, false, false );
        m_collisionBox2.bCollideWorld  = false;
        m_collisionBox2.bBlockActors   = false;
        m_collisionBox2.bBlockPlayers  = false;
        m_collisionBox2.m_fFeetColBoxRadius = 28.f;
    }

}

event FLOAT GetStanceReticuleModifier()
{
    //Values taken from the design document.
    if(m_bIsProne)
    {
        if(EngineWeapon.GotBipod())
        {
            return 1.3;
        }
        else
        {
            return 1.2;
        }
    }
    else if(bIsCrouched)
    {
        return 1.1;
    }
    return 1.0;
}

function FLOAT GetStanceJumpModifier()
{
    //Values taken from the design document.
    if(m_bIsProne)
    {
        if(EngineWeapon.GotBipod())
        {
            return 0.55;
        }
        else
        {
            return 0.75;
        }
    }
    else if(bIsCrouched)
    {
        return 0.85;
    }
    return 1.0;
}

//------------------------------------------------------------------
// CanBeAffectedByGrenade: return true if can be affected by the grenade 
//   at this moment
//------------------------------------------------------------------
simulated function bool CanBeAffectedByGrenade( Actor aGrenade, EGrenadeType eType )
{
     // if climbing a ladder or climbableObject, return
     if ( m_bIsClimbingLadder || m_climbObject != none )
     {
        return false;
     }

    return true;
}

//============================================================================
// function R6ClientAffectedByFlashbang - 
//============================================================================
simulated function R6ClientAffectedByFlashbang(Vector vGrenadeLocation)
{
    m_vGrenadeLocation = vGrenadeLocation;
    m_eEffectiveGrenade = GTYPE_FlashBang;
    m_bFlashBangVisualEffectRequested = true;
    m_fRemainingGrenadeTime = 5.f;
}

//============================================================================
// AffectedByGrenade - 
//============================================================================
function AffectedByGrenade( Actor aGrenade, EGrenadeType eType )
{
    local R6AIController aiController;

    #ifdefDEBUG if(bShowLog) logX("Affected by grenade " $ aGrenade.name $ " type: " $ eType ); #endif

    // Always reset the timer
    m_fRemainingGrenadeTime = 5.f;

    // if not the same type of greneda, end previous
    if( m_eEffectiveGrenade != eType )
    {
        if(m_eEffectiveGrenade != GTYPE_None)
            EndOfGrenadeEffect(m_eEffectiveGrenade);

        m_eEffectiveGrenade = eType;
        m_fTimeGrenadeEffectBeforeSound = Level.TimeSeconds;
    }

    // If it's not a TearGas or we don't have a gas mask, inform the AI that we are affected
    if( (eType!=GTYPE_TearGas || !m_bHaveGasMask)
        && CanBeAffectedByGrenade( aGrenade, eType) )
    {
        aiController = R6AIController(Controller);
        if( aiController != none)
            aiController.AIAffectedByGrenade( aGrenade, eType );
    }

    // Set the flashbang effect
    if(eType == GTYPE_FlashBang && m_bIsPlayer )
    {
        m_vGrenadeLocation = aGrenade.Location;
        R6ClientAffectedByFlashbang(m_vGrenadeLocation);
    }

    // Cough
    if( !m_bHaveGasMask && (Level.TimeSeconds > m_fTimeGrenadeEffectBeforeSound))
    {
        m_fTimeGrenadeEffectBeforeSound = Level.TimeSeconds + 7.0f + RandRange(0.0, 6.0);
        if(Controller != none)
            Controller.PlaySoundAffectedByGrenade(eType);
    }
}

event EndOfGrenadeEffect( EGrenadeType eType )
{
    #ifdefDEBUG if(bShowLog) logX("No more affected by grenade " $ eType ); #endif
}

//============================================================================
// SetRandomWaiting - 
//============================================================================
function SetRandomWaiting(INT iMax, optional BOOL bDontUseWaitZero )
{
    if (Role==ROLE_Authority)
    {
        if(m_bEngaged)
            m_bRepPlayWaitAnim = 0;
        else
        {
            if( bDontUseWaitZero || m_byRemainingWaitZero<=0 )
            {
                // Play base waiting animation 1 to 5 time in row
                m_byRemainingWaitZero = Rand(5)+1;
                m_bRepPlayWaitAnim = Rand(iMax);
            }
            else
            {
                // Decrease remaining wait zero
                m_byRemainingWaitZero--;
                m_bRepPlayWaitAnim = 0;
            }
        }
    }
}

//============================================================================
//##### ####  #####  #### ####  ###  ##      ###   #### ##### ####  ###  #   #   
//##    ##  # ##    ##     ##  ##  # ##     ##  # ##     ##    ##  ##  # ##  #   
//##### ####  ####  ##     ##  ##### ##     ##### ##     ##    ##  ##  # # # #   
//   ## ##    ##    ##     ##  ##  # ##     ##  # ##     ##    ##  ##  # #  ##   
//##### ##    #####  #### #### ##  # #####  ##  #  ####  ##   ####  ###  #   #   
//============================================================================

//============================================================================
// SetNextPendingAction - 
//============================================================================
function SetNextPendingAction( EPendingAction eAction, OPTIONAL INT i )
{
    if( Level.NetMode == NM_Client )
    {
        logWarning( " client shouldn't call SetNextPendingAction "  $eAction );
        return;
    }


    // Increment action index
    m_iNetCurrentActionIndex++;
    if(m_iNetCurrentActionIndex>=C_MaxPendingAction)
        m_iNetCurrentActionIndex = 0;

    m_ePendingAction[m_iNetCurrentActionIndex] = eAction;
    m_iPendingActionInt[m_iNetCurrentActionIndex] = i;

    // if player local or dedicated server, play the pending action now. don't wait next tick
    if( Level.NetMode != NM_Client )
    {
        // if you modify the 3 lines below, update the code in  AR6Pawn::UpdateMovementAnimation
        m_iLocalCurrentActionIndex++;
        if(m_iLocalCurrentActionIndex>=C_MaxPendingAction)
            m_iLocalCurrentActionIndex=0;

        if(IsAlive())
            PlaySpecialPendingAction( m_ePendingAction[m_iLocalCurrentActionIndex], m_iPendingActionInt[m_iLocalCurrentActionIndex] );
    }
}

//============================================================================
// PlaySpecialPendingAction - Called from UpdateMovementAnimation to
//                            play special animation on all clients
//============================================================================
simulated event PlaySpecialPendingAction( EPendingAction eAction, INT iActionInt )
{
    #ifdefDEBUG if(bShowLog) logX("PlaySpecialPendingAction " $ eAction ); #endif
    
    switch(eAction)
    {
        case PENDING_None:
            break;
        case PENDING_Coughing:
            PlayCoughing();
            break;
        case PENDING_Blinded:
            PlayBlinded();
            break;
        case PENDING_OpenDoor:
            if ( m_Door != none )
                PlayDoorAnim(m_Door.m_RotatingDoor);
            break;
        case PENDING_InteractWithDevice:
            PlayInteractWithDeviceAnimation();
            break;
        case PENDING_StartClimbingLadder:
            PlayStartClimbing();
            break;
        case PENDING_PostStartClimbingLadder:            
            PlayPostStartLadder();
            break;
        case PENDING_EndClimbingLadder:
            PlayEndClimbing();
            break;
        case PENDING_PostEndClimbingLadder:
            PlayPostEndLadder();
            break;
        case PENDING_DropWeapon:
            DropWeaponToGround();
            break;
        /* // R6CLIMBABLEOBJECT
        case PENDING_StartClimbingObject:
            //PlayClimbObject();        
            break;
        case PENDING_PostStartClimbingObject:
            //PlayPostClimb();          
            break; */
        case PENDING_CrouchToProne:
            PlayCrouchToProne();
            break;
        case PENDING_ProneToCrouch:
            PlayProneToCrouch();
            break;
        case PENDING_MoveHitBone:
            MoveHitBone( m_rHitDirection, m_iPendingActionInt[m_iLocalCurrentActionIndex] );
            break;
        default:
            logWarning("Received PlaySpecialPendingAction not defined for " $ eAction @ iActionInt );
    }
}

simulated function PlayCoughing();
simulated function PlayBlinded();

//== End Special Action ======================================================

//
//============================================================================
// ####    #####    ###    ####    
// ## ##   ##      ##  #   ## ##   
// ##  #   ####    #####   ##  #   
// ## ##   ##      ##  #   ## ##   
// ####    #####   ##  #   ####    
//============================================================================

//============================================================================
// KImpact - 
//============================================================================
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
    local vector vHitLocation, vHitNormal;

    if (Level.TimeSeconds > m_fTimeStartBodyFallSound)
    {
        // Make noise for AI
        if ( Level.NetMode != NM_Client )
            R6MakeNoise( SNDTYPE_Dead );

//        log("+++++ KImpact Send body fall for" @ self @ "impactVel=" @ impactVel @ "impactNorm=" @ impactNorm @ "++++++");
        R6Trace(vHitLocation, vHitNormal, pos - vect(0,0,50), pos + vect(0,0,10), TF_SkipVolume,, m_HitMaterial);
        m_fTimeStartBodyFallSound = Level.TimeSeconds + 1;
            
        if (m_ePawnType == PAWN_Rainbow) 
            SendPlaySound(Level.m_BodyFallSwitchSnd, SLOT_SFX);
        else
            SendPlaySound(Level.m_BodyFallSwitchForOtherPawnSnd, SLOT_SFX);
    }
}

//============================================================================
// DropWeaponToGround - 
//============================================================================
simulated function DropWeaponToGround()
{
    // Drop weapon to ground
    if(EngineWeapon!=None)
    {
        EngineWeapon.StartFalling();
        m_bDroppedWeapon = true;
    }
}

//============================================================================
// SpawnRagDoll - 
//============================================================================
simulated event SpawnRagDoll()
{
    local class<R6AbstractCorpse> corpseClass;
    local KarmaParamsSkel skelParams;
    local vector shotDir, shotDir2D, hitLocRel;
    local FLOAT maxDim;
    local INT i;

    #ifdefDEBUG if (bShowLog) logX("Spawn ragdoll"); #endif

    StopWeaponSound();
    DropWeaponToGround();

    bPlayedDeath = true;

    // Play Clothe sound
    m_fTimeStartBodyFallSound = Level.TimeSeconds + 0.5;
    SendPlaySound(m_sndDeathClothes, SLOT_SFX);

    if(!m_bUseKarmaRagdoll)
    {
        SetPhysics( PHYS_None );
        //corpseClass = class<R6AbstractCorpse>(DynamicLoadObject("R6Physics.R6RagDoll", class'Class'));
        m_ragdoll = Spawn(class'R6RagDoll', Self, , Location, Rotation );
        m_ragdoll.FirstInit(Self);
        #ifdefDEBUG if(bShowLog) log( name $ " has spawned the corpse: " $ m_ragdoll ); #endif

        //if( m_iTracedBone != 0 )
        //{
        //    // Add velocity to the hit bone
        //    m_ragdoll.TakeAHit( m_iTracedBone, vMomentum );
        //}
    }
    else
    {
        if ( Level.NetMode != NM_DedicatedServer )
        {
            KMakeRagdollAvailable();
        
            if( KIsRagdollAvailable() )
            {  
                skelParams = KarmaParamsSkel(KParams);

                shotDir = Normal(TearOffMomentum);
                
                // Calculate angular velocity to impart, based on shot location.
                if(TakeHitLocation!=vect(0,0,0))
                {
                    hitLocRel = (TakeHitLocation - GetBoneCoords('R6 Spine').Origin) * 1000.0f;
                    hitLocRel.Z = 0.0f;
                    shotDir2D = shotDir;
                    shotDir2D.Z = 0.0f;
                    skelParams.KStartAngVel = hitLocRel cross Normal(shotDir2D);
                }
                
                // Set initial angular and linear velocity for ragdoll.
                // Scale horizontal velocity for characters - they run really fast!
                skelParams.KStartLinVel.X = 0.6 * Velocity.X;
                skelParams.KStartLinVel.Y = 0.6 * Velocity.Y;
                skelParams.KStartLinVel.Z = 1.0 * Velocity.Z;
                skelParams.KStartLinVel += shotDir*200;

                // Set up deferred shot-bone impulse
                maxDim = Max(CollisionRadius, CollisionHeight);
                
                skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
                skelParams.KShotEnd = TakeHitLocation + (2*maxDim*shotDir);
                skelParams.KShotStrength = VSize(TearOffMomentum);

                KParams = skelParams;

                // Turn on Karma collision for ragdoll.
                KSetBlockKarma(true);

                // Set physics mode to ragdoll. 
                // This doesn't actually start it straight away, it's deferred to the first tick.
                SetPhysics(PHYS_KarmaRagdoll);
            }
        }
    }

    // Remove breath emitter
    if(m_BreathingEmitter != none)
    {
        m_BreathingEmitter.Emitters[0].AllParticlesDead = false;
        m_BreathingEmitter.Emitters[0].m_iPaused = 1;
        DetachFromBone(m_BreathingEmitter);
        m_BreathingEmitter.Destroy();
        m_BreathingEmitter = none;
    }

    GotoState('Dead');
}

//============================================================================
// event StopAnimForRG - 
//============================================================================
simulated event StopAnimForRG()
{
    local rotator rot;

    StopAnimating(true);
    m_bAnimStopedForRG = true;

    // Close the eyes
    rot.Yaw = 1500;
    SetBoneRotation('R6 PonyTail1', rot,, 1.0, 1.0 );
}

//------------------//
// -- state Dead -- //
//------------------//
simulated state Dead
{
    ignores PlayWeaponAnimation, PlayWaiting;
    
    simulated function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX( "Enter dead state..."); #endif
    }

    event vector EyePosition()
    {
        return GetBoneCoords('R6 Head').Origin - Location;
    }

    event Timer()
    {
        bProjTarget=false;
    }
    
Begin:
    if ( IsPeeking() )
        SetPeekingInfo( PEEK_none, C_fPeekMiddleMax );

    bProjTarget=true;
    SetCollision(true,false,false);
    SetCollisionSize( 1.5 * default.CollisionRadius, 1.0 * default.CollisionHeight );
    SetTimer( 0.5, false );
    if ( m_collisionBox != none )
        m_collisionBox.EnableCollision( false );

    if ( m_collisionBox2 != none )
        m_collisionBox2.EnableCollision( false );
    
    if(Controller != none)
    {
        Controller.FocalPoint = vect(0,0,0);
        Controller.Focus = none;
        Controller.bRotateToDesired = false;
        Controller.PawnDied();
    }

    bRotateToDesired = false;

    if ( Level.NetMode != NM_Client )
        R6MakeNoise( SNDTYPE_Dead );
}

//------------------------------------------------------------------
// InitBiPodPosture: called when going prone/unprone, selecting/unselecting 
//  a weapon
//------------------------------------------------------------------
simulated event InitBiPodPosture( bool bEnable )
{
    // log( "InitBiPodPosture bEnable=" $bEnable );
    ResetBipodPosture();

    m_bUsingBipod = bEnable;
    
    if ( m_bUsingBipod && m_ePeekingMode != PEEK_none )
    {
        SetPeekingInfo( PEEK_none, C_fPeekMiddleMax );
    }

    m_iMaxRotationOffset = GetMaxRotationOffset();
}

//------------------------------------------------------------------
// ResetBipodPosture: reset basic bipod posture info
//  
//------------------------------------------------------------------
simulated event ResetBipodPosture()
{
    // log( " ResetBipodPosture " );
    m_fBipodRotation = 0;
    m_iLastBipodRotation = 0;
    m_iRepBipodRotationRatio = 0;
}

//------------------------------------------------------------------
// Update bipod posture only if using one and not moving
//  
//------------------------------------------------------------------
simulated event UpdateBipodPosture()
{
    local name animName;
    local float fRatio;

    if(EngineWeapon.bFiredABullet == TRUE)  //Firing animation
    {
        PlayProneFireAnimation();
        EngineWeapon.bFiredABullet = FALSE;
        return;
    }

    if(m_iLastBipodRotation == m_iRepBipodRotationRatio)
        return;

    if ( m_iRepBipodRotationRatio > 0 )
    {
        if(EngineWeapon.IsLMG() == true)
        {
            animName = 'proneBipodRightLMGBreathe';
        }
        else
        {
            animName = 'ProneBipodRightSniperBreathe';
        }
    }
    else
    {
        if(EngineWeapon.IsLMG() == true)
        {
            animName = 'proneBipodLeftLMGBreathe';
        }
        else
        {
            animName = 'proneBipodLeftSniperBreathe';
        }
    }

    fRatio = 100;
    
    if ( IsLocallyControlled() && Level.NetMode != NM_Standalone ) // in local and multi: needed for 3rd view camera
        fRatio = abs( m_fBipodRotation / C_iRotationOffsetBiPod );
    else
        fRatio = abs( m_iRepBipodRotationRatio / fRatio );
    
    AnimBlendParams(C_iPostureAnimChannel, fRatio, 0.0, 0.0, 'R6');
    PlayAnim(animName, 1, 0.0, C_iPostureAnimChannel);

    m_iLastBipodRotation = m_iRepBipodRotationRatio;
}   
 

//------------------------------------------------------------------
// CanPeek(): return true if the pawn can peek
//  
//------------------------------------------------------------------
function bool CanPeek()
{
    // can't peek if using bipod
    return !m_bUsingBipod;
}

//------------------------------------------------------------------
// EnteredExtractionZone
//------------------------------------------------------------------
function EnteredExtractionZone( R6AbstractExtractionZone zone );

//------------------------------------------------------------------
// LeftExtractionZone
//------------------------------------------------------------------
function LeftExtractionZone( R6AbstractExtractionZone zone );

//------------------------------------------------------------------
// SetFriendlyFire
//  - called by controller posses fn
//------------------------------------------------------------------
function SetFriendlyFire()
{
    local bool bFriendlyFire;

    if ( Controller.IsA('AIController') ) // if it's an AI
    {
        // use default properties of terro, hostage and rainbow
        m_bCanFireFriends  = default.m_bCanFireFriends;
        m_bCanFireNeutrals = default.m_bCanFireNeutrals;
    }
    else 
    {
        if ( m_ePawnType != PAWN_Rainbow ) // only rainbow can be human player
        {
            log( "WARNING: SetFriendlyFire unknow m_ePawnType for " $self );
        }

        // in multi, we use the information setted by the server
        if ( Level.IsGameTypeMultiplayer( R6AbstractGameInfo(Level.Game).m_szGameTypeFlag ) )
        {
            bFriendlyFire = R6AbstractGameInfo(Level.Game).m_bFriendlyFire;
        }
        else // in single player, human player are not allowed to have friendly fire
        {
            bFriendlyFire = true;
        }
        
        m_bCanFireFriends  = bFriendlyFire;
        m_bCanFireNeutrals = bFriendlyFire;
    }
}

// Play sound because no animation here just interpolation
simulated function CrouchToStand()
{
    SendPlaySound(m_sndCrouchToStand, SLOT_SFX);
}

// Play sound because no animation here just interpolation
simulated function StandToCrouch()
{
    SendPlaySound(m_sndStandToCrouch, SLOT_SFX);
}

function PlayLocalWeaponSound(R6EngineWeapon.EWeaponSound eWeaponSound)
{
    if (m_SoundRepInfo != none)
    {
        //#ifdefDEBUG if(bShowLog) log("R6Pawn::PlayLocalWeaponSound "$self$" | (m_SoundRepInfo != none) IS TRUE | " $ m_SoundRepInfo); #endif
    
        m_SoundRepInfo.PlayLocalWeaponSound(eWeaponSound);
    }
}

// Server call this function
function PlayWeaponSound(R6EngineWeapon.EWeaponSound eWeaponSound)
{
    if (m_SoundRepInfo != none)
    {
        #ifdefDEBUG if(bShowLog) log("R6Pawn::PlayWeaponSound "$self$" | SOUND = " $ eWeaponSound $ " | m_SoundRepInfo != none | " $ m_SoundRepInfo); #endif
    
        SetAudioInfo();
        m_SoundRepInfo.PlayWeaponSound(eWeaponSound);
    }
}

// Stop sound when the ragdoll is spawn. Done on the client side.
simulated function StopWeaponSound()
{
//    log("$$$ StopWeaponSound in pawn" @ self @ "m_SoundRepInfo=" @ m_SoundRepInfo);
    if (m_SoundRepInfo != none)
        m_SoundRepInfo.StopWeaponSound();
}

//============================================================================
// FellOutOfWorld - 
//============================================================================
event FellOutOfWorld()
{
	if ( Role < ROLE_Authority )
		return;

    if(!m_bIsPlayer)
        ServerSuicidePawn(DEATHMSG_KAMAKAZE);
}



// -----------  MissionPack1
// MPF1 
function INT R6TakeDamageCTE( INT iKillValue, INT iStunValue, Pawn instigatedBy, vector vHitLocation, 
                           vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
{
    local eKillResult eKillFromTable;
    local eStunResult eStunFromTable;
    local eBodyPart   eHitPart;
    local INT         iKillFromHit;
    local vector      vBulletDirection;
    local INT         iSndIndex;
    local bool        bIsSilenced;
	local bool		  bIsSurrended;

    //BloodSplats
    local R6BloodSplat BloodSplat;
    local Rotator BloodRotation;
    local R6WallHit   aBloodEffect;
    local bool  _bAffectedActor;      // for sounds and stats (because of multiple bullets in shotguns)

    #ifdefDEBUG if(bShowLog) logX( "R6TakeDamageCTE called"); #endif 

	if( bInvulnerableBody || (IsA('R6Rainbow') && R6Rainbow(self).m_bIsSurrended ))
		return 0;

    if ( instigatedBy != none && instigatedBy.EngineWeapon != none )
        _bAffectedActor = instigatedBy.EngineWeapon.AffectActor(iBulletGoup,self);
    else 
        _bAffectedActor = false;
        
    // only track if instigated from an enemy and we only count shutgun fragments from the same shell once
    if ( IsEnemy(instigatedBy) && _bAffectedActor ) 
    {
        if(Level.NetMode == NM_Standalone)
        {       
            if( instigatedBy != none && instigatedBy.m_ePawnType == PAWN_Rainbow)
            {
                R6Rainbow(instigatedBy).IncrementRoundsHit();
            }
        }
        else
        {       
            // only track if instigated from an enemy
            if ((instigatedBy != none && instigatedBy.PlayerReplicationInfo != none) && (Level.Game.m_bCompilingStats==true))
            {
                instigatedBy.PlayerReplicationInfo.m_iRoundsHit++;
            }
        }
    }
	else
		return 0;

    TakeHitLocation = vHitLocation;


    // here, we don't allow the game to process damage if it's game over
    // - 
    if ( Level.NetMode == NM_Client)
    {
        if (m_bIsPlayer && R6PlayerController(controller).GameReplicationInfo.m_bGameOverRep)
        {
            return 0;
        }
    }
    else if ( Level.Game.m_bGameOver && !R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath )
    {
        return 0;
    }

    if ( !InGodMode() && (iKillValue != 0))
    {
        aBloodEffect = Spawn(class'R6SFX.r6BloodEffect', , , vHitLocation);
        if ((aBloodEffect != none) && !_bAffectedActor)
            aBloodEffect.m_bPlayEffectSound = false;
    }
    
    #ifdefDEBUG if(bShowLog) log(self$" inform Rainbow member that they are being attacked by (even if in god mode)... instigatedBy="$instigatedBy); #endif
    if(m_ePawnType==PAWN_Rainbow && !m_bIsPlayer )
        R6RainbowAI(controller).IsBeingAttacked(instigatedBy);

    if(InGodMode())
    {
        #ifdefDEBUG if(bShowLog) log("No damage, GOD MODE!"); #endif
        return 0;
    }

    eHitPart = WhichBodyPartWasHit(vHitLocation, vMomentum);

    //R6BLOOD
    m_eLastHitPart = eHitPart;

    if ( instigatedBy != none && instigatedBy.EngineWeapon != none )
        bIsSilenced = instigatedBy.EngineWeapon.m_bIsSilenced;
    else
        bIsSilenced = false;
    


        //Force kill is set by the grenade or iobomb or by the debug function
    if(m_iForceKill != 0)
    {
        switch(m_iForceKill)
        {
        case 1:
            eKillFromTable = KR_None;
            break;
        case 2:
            eKillFromTable = KR_Wound;
            break;
        case 3:
            eKillFromTable = KR_Incapacitate;
            break;
        case 4:
            eKillFromTable = KR_Killed;
            break;
        }
    }
    else
    {
        eKillFromTable = GetKillResult(iKillValue, eHitPart, m_eArmorType, iBulletToArmorModifier, bIsSilenced );
    }

	if(eKillFromTable == KR_Killed || eKillFromTable == KR_Incapacitate) 
	{	// override Kill status with wound if we're in Capture The Enemy gameType
        eKillFromTable = KR_Wound;
		bIsSurrended = true;
	}

    //Default value set for stun values.
    if(m_iForceStun != 0 && m_iForceStun < 5)
    {
        switch(m_iForceStun)
        {
        case 1:
            eStunFromTable = SR_None;
            break;
        case 2:
            eStunFromTable = SR_Stunned;
            break;
        case 3:
            eStunFromTable = SR_Dazed;
            break;
        case 4:
            eStunFromTable = SR_KnockedOut;
            break;
        }
    }
    else
    {
        //If the character is not out
        eStunFromTable = GetStunResult(iStunValue, eHitPart, m_eArmorType, iBulletToArmorModifier, bIsSilenced );
    }

    vBulletDirection = Normal(vMomentum);

    //Spawn blood splat
    BloodRotation = Rotator(vBulletDirection);
    BloodRotation.Roll = 0;

	if(eKillFromTable != KR_None)
		BloodSplat = Spawn(class'Engine.R6BloodSplatSmall',,, vHitLocation, BloodRotation);

    // Move the bone
	if(m_iTracedBone!=0) 
    {
        m_rHitDirection = rotator(vBulletDirection);
//        if ( Level.NetMode != NM_Client )
//            SetNextPendingAction( PENDING_MoveHitBone, m_iTracedBone );
    }

//	if(R6PlayerController(controller).m_bIsSurrended)
	if(bIsSurrended)
	{
        #ifdefDEBUG if (bShowLog) log("...... pawn "$self$" is SURRENDED!! hit="$eKillFromTable$"  priorHealth="$m_eHealth); #endif
        m_eHealth = HEALTH_Healthy;
        m_fHBWound = 1.0;

	}
	/*
	else if(eKillFromTable == KR_Incapacitate  || (eKillFromTable == KR_Wound && m_eHealth == HEALTH_Wounded))
    {
        #ifdefDEBUG if (bShowLog) log("...... pawn "$self$" is INCAPACITATED!! hit="$eKillFromTable$"  priorHealth="$m_eHealth); #endif
        m_eHealth = HEALTH_Incapacitated;
    }*/
    else if(eKillFromTable == KR_Wound)
    {
        #ifdefDEBUG if (bShowLog) log("...... pawn "$self$" is WOUNDED!! hit="$eKillFromTable$"  priorHealth="$m_eHealth); #endif
        m_eHealth = HEALTH_Wounded;
        m_fHBWound = 1.2;

		if (m_bIsClimbingLadder)
			bIsWalking = true;

        // 17 jan 2002 rbrek - immediately update current animations with injured ones (if such anims exist)
//		ChangeAnimation(); 
		
    }


    if( instigatedBy != none && R6PlayerController(instigatedBy.Controller) != none)
    {
        if(R6PlayerController(instigatedBy.Controller).m_bShowHitLogs)
        {
                log("Player HIT : "$self$" Bullet Energy : "$iKillValue$" body part : "$eHitPart$" KillResult : "$eKillFromTable$" Armor type : "$m_eArmorType);
        }
    }

 

        // update the team's knowledge about this member's health status
    if(m_ePawnType==PAWN_Rainbow && (eKillFromTable != KR_None))
    {
        if( m_bIsPlayer )
        {
            R6PlayerController(controller).m_TeamManager.m_eMovementMode = MOVE_Assault;
            R6PlayerController(controller).m_TeamManager.UpdateTeamStatus(self);
        }
		/* MPF_Milan_7_1_2003 - useless, no RainbowAI in CTE
        else if(R6RainbowAI(controller).m_TeamManager!=none)
        {
            R6RainbowAI(controller).m_TeamManager.m_eMovementMode = MOVE_Assault;
            R6RainbowAI(controller).m_TeamManager.UpdateTeamStatus(self);
        } 
        */
    }
    
    // Inform controller that this pawn is under attack
	if(controller != none)
    {
        controller.R6DamageAttitudeTo(instigatedBy, eKillFromTable, eStunFromTable, vMomentum);
        if (eKillFromTable != KR_None)
            controller.PlaySoundDamage(instigatedBy);        
    }
    else
	{
        #ifdefDEBUG if (bShowLog) log("NoController"); #endif
	}

	if(eKillFromTable != KR_None)
	{
		// Adjust momentum from stun result (for the rag doll)
		iStunValue = Min( iStunValue, 5000 );
		vMomentum = Normal(vMomentum) * (iStunValue*100);
//		if( R6PlayerController(controller).m_bIsSurrended )
		if( bIsSurrended )
		{
			if(m_ePawnType==PAWN_Rainbow &&  m_bIsPlayer)
   			{
	    		R6Surrender(instigatedBy, eHitPart, vMomentum);
			}
		}
	}
    //The bullet can always go through a body part, even if the character is dead.
    iKillFromHit = GetThroughResult(iKillValue, eHitPart, vMomentum);

    if(PlayerReplicationInfo != none)
    {
        switch(m_eHealth)
        {
        case HEALTH_Healthy:
            PlayerReplicationInfo.m_iHealth = 0;//ePlayerStatus_Alive;
            break;
      //  case HEALTH_Incapacitated:
		case HEALTH_Wounded:
            PlayerReplicationInfo.m_iHealth = 1;//ePlayerStatus_Wounded;
            break;
        case HEALTH_Dead:
            PlayerReplicationInfo.m_iHealth = 2;//ePlayerStatus_Dead;
            break;
        }
    }
    
    return iKillFromHit;    // Goes through if iKillFromHit > 0
}

// MPF_Milan_9_23_2003 - uncommented 
function ServerSurrender()
{
    #ifdefDEBUG if(bShowLog) logX("R6Pawn::ServerSurrender()");  #endif 

    if(IsA('R6Rainbow') && R6PlayerController(controller).IsInState('PlayerStartSurrenderSequence'))//R6Rainbow(self).m_bIsSurrended)
        return;

    Surrender();
}
// End MPF_Milan_9_23_2003 

function ClientSurrender()
{
    #ifdefDEBUG if(bShowLog) logX("R6Pawn::ClientSurrender()"); #endif 
    if(IsA('R6Rainbow') && R6PlayerController(controller).IsInState('PlayerStartSurrenderSequence'))//R6Rainbow(self).m_bIsSurrended)
        return;

    Surrender();
}


//====================================================================================// Surrender()                                              
//====================================================================================

function Surrender()
{
    #ifdefDEBUG if(bShowLog) log(self$" Surrender() was called.... ");  #endif 
        
    if(IsA('R6Rainbow') && R6Rainbow(self).m_bIsSurrended)
        return;  

    #ifdefDEBUG if(bShowLog) log(self$" Surrender() was called 2.... ");  #endif 
        
    if(IsA('R6Rainbow') && R6PlayerController(controller).IsInState('PlayerStartSurrenderSequence'))
        return;  

    // if(bShowLog) log(self$" Surrender() calls PlayerStartSurrenderSequence.... ");    //MP1DEBUG 

	R6PlayerController(controller).GotoState('PlayerStartSurrenderSequence'); // MissionPack1 2
	
	if(IsA('R6Rainbow'))
		R6Rainbow(self).m_bIsSurrended = true;

    //if(Level.NetMode == NM_Client)
	/* MPF_Milan 
	if ( Role < ROLE_Authority )
	{
        ServerSurrender();
        // R6PlayerController(controller).ServerStartSurrenderSequence();
	}
	else
	*/

	//MPF_Milan_9_23_2003 if(Level.NetMode == NM_DedicatedServer)
   	if ( Role == ROLE_Authority ) //MPF_Milan_9_23_2003
	{
        ClientSurrender();
	}

// MissionPack1 2	R6PlayerController(controller).GotoState('PlayerStartSurrenderSequence');
}




/*
function ServerArrested()
{
    #ifdefDEBUG if(bShowLog) log(" ServerArrested "); #endif
    if(R6Rainbow(self).m_bIsBeingArrestedOrFreed)
        return;
    Arrested();
}
*/

//===================================================================================================
// Arrested()                                              
//===================================================================================================
simulated function Arrested()
{
    #ifdefDEBUG if(bShowLog) log(self$" Arrested() was called.... "); #endif 
	     
	R6Rainbow(self).m_bIsBeingArrestedOrFreed = true;
	R6PlayerController(controller).GotoState('PlayerStartArrest');
}


function ClientSetFree()
{
    #ifdefDEBUG if(bShowLog) log(" ClientSetFree "); #endif 
    
    if(R6Rainbow(self).m_bIsBeingArrestedOrFreed)
        return;

    SetFree();
}

//===================================================================================================
// SetFree()                                              
//===================================================================================================
function SetFree()
{

    if(R6Rainbow(self).m_bIsBeingArrestedOrFreed)
        return;  

    #ifdefDEBUG if(bShowLog) log(self$" SetFree() was called.... "); #endif 

    R6Rainbow(self).m_bIsBeingArrestedOrFreed = true;
    if(Level.NetMode != NM_Client) // MPF_Milan2 - bug fix (was "==")
        ClientSetFree();
        R6PlayerController(controller).GotoState('PlayerSetFree');
}


//============================================================================
// R6Surrender
//      Called only on the server
//============================================================================
function R6Surrender(Pawn Killer, eBodyPart eHitPart, vector vMomentum)
{
    local R6AbstractGameInfo pGameInfo;
    local INT i;
    local r6PlayerController P;
    local R6AbstractWeapon aWeapon;
    local string KillerName;
    local string szPlayerName;

    #ifdefDEBUG if(bShowLog) logX("R6Pawn::R6Surrender()"); #endif 

#ifndefMPDEMO
	if(Killer == none)
		log(" R6Surrender() : WARNING : Killer=none");
#endif

    if(Killer.PlayerReplicationInfo != none)
        KillerName = Killer.PlayerReplicationInfo.PlayerName;
    else
        KillerName = Killer.m_CharacterName; // Was copied in UnPossessed()

    #ifdefDEBUG if(bShowLog) logX(" entered function R6Surrender, was humiliated by " $ Killer ); #endif
    
    // Remove from ladder
    if(m_bIsClimbingLadder || Physics==PHYS_Ladder)
    {
#ifndefMPDEMO
		if(m_Ladder == none || m_Ladder.myLadder == none)
			log(" R6Surrender() : WARNING : m_Ladder="$m_Ladder$" m_Ladder.myLadder="$m_Ladder.myLadder);
#endif
		R6LadderVolume(m_Ladder.myLadder).RemoveClimber(self);
		if(m_bIsPlayer && m_Ladder != none)
			R6LadderVolume(m_Ladder.myLadder).DisableCollisions(m_Ladder);
	}

    // stop rootmotion
 
    if ( Physics == PHYS_RootMotion ) 
    {
        if( Controller != none )
            Controller.GotoState('');

        if ( bIsCrouched )
            PlayPostRootMotionAnimation( m_crouchDefaultAnimName );
        else
            PlayPostRootMotionAnimation( m_standDefaultAnimName );
    }


    // close current gagdet if activated.
    aWeapon = R6AbstractWeapon(EngineWeapon);
    if( aWeapon != none && aWeapon.m_SelectedWeaponGadget!=None)
        aWeapon.m_SelectedWeaponGadget.ActivateGadget(FALSE);
	
    // Variables setting
    if(vMomentum==vect(0,0,0))
        vMomentum = vect(1,1,1);
    TearOffMomentum = vMomentum;
    bAlwaysRelevant = true;
    for(i=0; i<=3; i++)
    {
        if(m_WeaponsCarried[i]!=none)
            m_WeaponsCarried[i].SetRelevant(true);
    }

    //EngineWeapon.bAlwaysRelevant = true;
    bProjTarget     = false;

    m_KilledBy = R6Pawn(Killer);

    if( ProcessBuildDeathMessage( Killer, szPlayerName ) )
    {
        #ifdefDEBUG if (bShowLog) log(class'R6Pawn'.static.BuildDeathMessage(KillerName, szPlayerName, m_bSuicideType )); #endif
        ForEach DynamicActors(class'R6PlayerController', P)
        {
			// TO DO: replace with SurrenderMessage
            P.ClientDeathMessage(KillerName, szPlayerName, m_bSuicideType );
        }
    }

#ifndefMPDEMO
	if(m_KilledBy == none)
		log("  R6Surrender() : Warning!!  m_KilledBy="$m_KilledBy);
#endif
    if(IsEnemy(m_KilledBy))
        m_KilledBy.IncrementFragCount();

	if (R6PlayerController(Controller) != none)
    {
//MP1        R6PlayerController(Controller).ClientDisableFirstPersonViewEffects();
        R6PlayerController(Controller).PlayerReplicationInfo.m_szKillersName = KillerName;
    }

    // GameInfo stuff
	/* MP1 this test must be performed only when captured
    pGameInfo = R6AbstractGameInfo(Level.Game);
    if ( pGameInfo != none )
    {
        // compile stats only when we have adversaries
		
        if ((pGameInfo.m_bCompilingStats==true || (pGameInfo.m_bGameOver && pGameInfo.m_bGameOverButAllowDeath))  
             && controller.PlayerReplicationInfo != none)
        {
            controller.PlayerReplicationInfo.Deaths += 1.f;
            if ( !m_bSuicided && m_KilledBy != none && m_KilledBy.controller != none)
                m_KilledBy.controller.PlayerReplicationInfo.Score += 1.f;
        }
		
        pGameInfo.PawnKilled( self );
        MP1 pGameInfo.SetTeamKillerPenalty(self, killer);
    }
	*/

	Surrender();
}


// --------------------------- End MissionPack1

defaultproperties
{
     m_iNetCurrentActionIndex=255
     m_iLocalCurrentActionIndex=255
     m_eLastUsingHands=HANDS_Both
     m_iUniqueID=1
     m_iDesignRandomTweak=50
     m_iDesignLightTweak=10
     m_iDesignMediumTweak=30
     m_iDesignHeavyTweak=50
     m_bAvoidFacingWalls=True
     m_bUseKarmaRagdoll=True
     m_fSkillAssault=0.800000
     m_fSkillDemolitions=0.800000
     m_fSkillElectronics=0.800000
     m_fSkillSniper=0.800000
     m_fSkillStealth=0.800000
     m_fSkillSelfControl=0.800000
     m_fSkillLeadership=0.800000
     m_fSkillObservation=0.800000
     m_fReloadSpeedMultiplier=1.000000
     m_fGunswitchSpeedMultiplier=1.000000
     m_fGadgetSpeedMultiplier=1.000000
     m_fWalkingSpeed=170.000000
     m_fWalkingBackwardStrafeSpeed=170.000000
     m_fRunningSpeed=290.000000
     m_fRunningBackwardStrafeSpeed=290.000000
     m_fCrouchedWalkingSpeed=80.000000
     m_fCrouchedWalkingBackwardStrafeSpeed=80.000000
     m_fCrouchedRunningSpeed=150.000000
     m_fCrouchedRunningBackwardStrafeSpeed=150.000000
     m_fProneSpeed=45.000000
     m_fProneStrafeSpeed=17.000000
     m_fPeekingGoalModifier=1.000000
     m_fPeekingGoal=1000.000000
     m_fPeeking=1000.000000
     m_fWallCheckDistance=300.000000
     m_fZoomJumpReturn=1.000000
     m_fHBMove=1.000000
     m_fHBWound=1.000000
     m_fHBDefcon=1.000000
     m_sndNightVisionActivation=Sound'Gadgets_NightVision.Play_NightActivation'
     m_sndNightVisionDeactivation=Sound'Gadgets_NightVision.Stop_NightActivation_Go'
     m_sndCrouchToStand=Sound'Foley_RainbowGear.Play_Crouch_Stand_Gear'
     m_sndStandToCrouch=Sound'Foley_RainbowGear.Play_Stand_Crouch_Gear'
     m_sndThermalScopeActivation=Sound'CommonSniper.Play_ThermScopeActivation'
     m_sndThermalScopeDeactivation=Sound'CommonSniper.Stop_ThermScopeActivation_Go'
     m_sndDeathClothes=Sound'Foley_RainbowClothesLight.Play_DeathClothes'
     m_sndDeathClothesStop=Sound'Foley_RainbowClothesLight.Stop_DeathClothes'
     m_standRunForwardName="StandRunForward"
     m_standRunLeftName="StandRunLeft"
     m_standRunBackName="StandRunBack"
     m_standRunRightName="StandRunRight"
     m_standWalkForwardName="StandWalkForward"
     m_standWalkBackName="StandWalkBack"
     m_standWalkLeftName="StandWalkLeft"
     m_standWalkRightName="StandWalkRight"
     m_hurtStandWalkLeftName="HurtStandWalkLeft"
     m_hurtStandWalkRightName="HurtStandWalkRight"
     m_standTurnLeftName="StandTurnLeft"
     m_standTurnRightName="StandTurnRight"
     m_standFallName="StandFall_nt"
     m_standLandName="StandLand"
     m_crouchFallName="CrouchFall_nt"
     m_crouchLandName="CrouchLand"
     m_crouchWalkForwardName="CrouchWalkForward"
     m_standStairWalkUpName="StandStairWalkUpForward"
     m_standStairWalkUpBackName="StandStairWalkUpBack"
     m_standStairWalkUpRightName="StandStairWalkUpRight"
     m_standStairWalkDownName="StandStairWalkDownForward"
     m_standStairWalkDownBackName="StandStairWalkDownBack"
     m_standStairWalkDownRightName="StandStairWalkDownRight"
     m_standStairRunUpName="StandStairRunUpForward"
     m_standStairRunUpBackName="StandStairRunUpBack"
     m_standStairRunUpRightName="StandStairRunUpRight"
     m_standStairRunDownName="StandStairRunDownForward"
     m_standStairRunDownBackName="StandStairRunDownBack"
     m_standStairRunDownRightName="StandStairRunDownRight"
     m_crouchStairWalkDownName="CrouchStairWalkDownForward"
     m_crouchStairWalkDownBackName="CrouchStairWalkDownBack"
     m_crouchStairWalkDownRightName="CrouchStairWalkDownRight"
     m_crouchStairWalkUpName="CrouchStairWalkUpForward"
     m_crouchStairWalkUpBackName="CrouchStairWalkUpBack"
     m_crouchStairWalkUpRightName="CrouchStairWalkUpRight"
     m_crouchStairRunUpName="CrouchStairRunUpForward"
     m_crouchStairRunDownName="CrouchStairRunDownForward"
     m_crouchDefaultAnimName="CrouchSubGunHigh_nt"
     m_standDefaultAnimName="StandSubGunHigh_nt"
     m_standClimb64DefaultAnimName="StandClimb64Up"
     m_standClimb96DefaultAnimName="StandClimb96Up"
     bCanCrouch=True
     m_bCanProne=True
     bCanClimbLadders=True
     bCanWalkOffLedges=True
     bSameZoneHearing=True
     bMuffledHearing=True
     bAroundCornerHearing=True
     bDontPossess=True
     m_bWantsHighStance=True
     bPhysicsAnimUpdate=True
     PeripheralVision=0.500000
     GroundSpeed=340.000000
     LadderSpeed=50.000000
     WalkingPct=1.000000
     CrouchHeight=60.000000
     CrouchRadius=35.000000
     m_fProneHeight=28.000000
     m_fProneRadius=40.000000
     m_fHeartBeatFrequency=90.000000
     m_pHeartBeatTexture=Texture'Inventory_t.HeartBeat.SphereBeat'
     m_sndHBSSound=Sound'Foley_HBSensor.Play_HBSensorAction2'
     m_sndHearToneSound=Sound'Grenade_FlashBang.Play_HearTone'
     m_sndHearToneSoundStop=Sound'Grenade_FlashBang.Stop_HearTone'
     MovementAnims(0)="StandWalkForward"
     MovementAnims(1)="StandWalkLeft"
     MovementAnims(2)="StandWalkBack"
     MovementAnims(3)="StandWalkRight"
     TurnLeftAnim="StandTurnLeft"
     TurnRightAnim="StandTurnRight"
     m_HeatIntensity=255
     m_bReticuleInfo=True
     m_bShowInHeatVision=True
     m_bDeleteOnReset=True
     m_bPlanningAlwaysDisplay=True
     CollisionRadius=35.000000
     CollisionHeight=75.000000
     m_fBoneRotationTransition=1.000000
     Begin Object Class=KarmaParamsSkel Name=R6AllRagDoll
         KConvulseSpacing=(Max=2.200000)
         KSkeleton="terroskel"
         KStartEnabled=True
         bHighDetailOnly=False
         KLinearDamping=0.500000
         KAngularDamping=0.500000
         KBuoyancy=1.000000
         KVelDropBelowThreshold=50.000000
         KFriction=0.600000
         KRestitution=0.300000
         KImpactThreshold=150.000000
         Name="R6AllRagDoll"
     End Object
     KParams=KarmaParamsSkel'R6Engine.R6AllRagDoll'
     RotationRate=(Yaw=30000,Roll=0)
}
