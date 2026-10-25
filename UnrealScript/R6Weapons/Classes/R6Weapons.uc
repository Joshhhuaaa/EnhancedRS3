//=============================================================================
//  R6Weapons.uc : Base class of all weapons
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/20 * Created by Aristomenis Kolokathis
//    2001/05/03 * (AK) Added bullet burst
//    2003/06/12 * Major rework to eliminate "Trigger Lag" (Olivier Rouleau)
//=============================================================================
class R6Weapons extends R6AbstractWeapon
    native
    abstract;

//#exec OBJ LOAD FILE="..\textures\R6TextureWeapons.utx"  Package="R6TextureWeapons.Flash"
//#exec OBJ LOAD FILE="..\textures\R6WeaponsIcons.utx" Package="R6WeaponsIcons.Icons"

//#exec OBJ LOAD FILE="..\Textures\Color.utx" PACKAGE=Color 
#exec NEW StaticMesh FILE="models\RedWeapon.ASE" NAME="RedWeaponStaticMesh"


// lists all possible settings for this weapon.
// If you change that Structure don't forget to check R6WeaponStruct.h
struct stWeaponCaps
{
    var () INT bSingle;                 // caps set to 1 if weapon can fire single shots
    var () INT bThreeRound;             // caps set to 1 if weapon can fire 3 bullets bursts
    var () INT bFullAuto;               // caps set to 1 if weapon can fire full automatic
    var () INT bCMag;                   // caps set to 1 if weapon can have a CMag as gadget
    var () INT bSilencer;               // caps set to 1 if weapon can have a silencer as gadget
    var () INT bLight;                  // caps set to 1 if weapon can have a tactical light as gadget
    var () INT bMiniScope;              // caps set to 1 if weapon can have a 3.5x mini scope as gadget
    var () INT bHeatVision;             // caps set to 1 if weapon can have a heat vision scope (sniper gun only)
};

// If you change that Structure don't forget to check R6WeaponStruct.h
struct stAccuracyType
{
	var () FLOAT fBaseAccuracy;			// Best possible accuracy
	var () FLOAT fShuffleAccuracy;		// Worst Possible Accuracy when character is looking around
	var () FLOAT fWalkingAccuracy;		// Worst Accuracy when a character is walking
	var () FLOAT fWalkingFastAccuracy;	// Worst Accuracy when a characters is walking fast(Rainbow's run)
	var () FLOAT fRunningAccuracy;		// Worst Accuracy when a characters is running (Terrorist running), worst overall accuracy
	var () FLOAT fReticuleTime;			// Number of seconds it takes to recover from the Running to the base accuracy
    var () FLOAT fAccuracyChange;       // Accuracy penalty after the character fires a bullet
	var () FLOAT fWeaponJump;			// How much the weapon jumps after each round.
};


var const INT C_iMaxNbOfClips;

var (R6GunProperties) FLOAT  m_fMuzzleVelocity;       // muzzle velocity of bullet, this may affect the range of bullet, friction is negligible and bullet will travel in a straight line
var (R6GunProperties) stWeaponCaps m_stWeaponCaps;    //use to describe avalaible options in menus and selected options in the game
var (R6GunProperties) Texture m_WeaponIcon;           // icon to display weapon in the hud (must be 128x64)

var                   R6Reticule    m_ReticuleInstance;   // instance of the reticule

var (R6Clip)  INT m_iClipCapacity;      // Number of round per magazine
var (R6Clip)  INT m_iNbOfClips;         // This is the number of clip that the guns had at the beginning of the mission
var (R6Clip)  INT m_iNbOfExtraClips;    // Number of extra clips per EXTRA CLIP gadget
var (R6Clip)  BYTE m_aiNbOfBullets[20]; // Number of bullets in each magazines (The current maximum is 16 (8+4+4))
var (R6Clip)  class<R6Bullet> m_pBulletClass;  //current class spawned in the game, default bullet for terrorist.
var (R6Clip)  class<R6SFX>    m_pEmptyShells;  //empty shell particule spawned when firing 
var R6SFX                     m_pEmptyShellsEmitter;
var (R6Clip)  class<R6SFX>    m_pMuzzleFlash;  // MuzzleFlash spawned when firing
var R6SFX                     m_pMuzzleFlashEmitter;
var(MuzzleFlash)	FLOAT	  m_MuzzleScale;		// scaling of muzzleflash


var INT			m_iCurrentClip;         // Active Clip Number
var INT			m_iNbOfRoundsToShoot;   // Number of rounds to be shoot by holding the trigger (safe = 0, Single = 1, ThreeRound = 3, FullAuto=MagazineCapacity)
var INT			m_iCurrentNbOfClips;    // Number of clip with at least one round in
var BYTE        m_iNbOfRoundsInBurst;   // Number of rounds shot since the trigger was pull

var rotator     m_rLastRotation;        // Last Pawn.Rotation.  Use to compute the delta angle
var rotator     m_rBuckFirstBullet;     // Inital direction of a buckshot shell
var FLOAT       m_fAverageDegChanges;
var FLOAT       m_fAverageDegTable[5];
var INT         m_iCurrentAverage;
var FLOAT       m_fStablePercentage;    // Accuracy improvement when you're stable
var FLOAT       m_fWorstAccuracy;       // Accuracy in worst case.
var FLOAT       m_fOldWorstAccuracy;    // Old value for worst accuracy, to detect if the value changed
var FLOAT		m_fEffectiveAccuracy;   // Effective accuracy. This accuracy is compute once a tick
var FLOAT		m_fDesiredAccuracy;     // Desired accuracy.
var FLOAT       m_fMaxAngleError;       // Angle that is set depending of the effective accuracy
var FLOAT       m_fCurrentFireJump;     // 
var FLOAT       m_fFireSoundRadius;     // Distance (in unit) at wich the fire is heard by the AI
var BOOL        m_bPlayLoopingSound;

var (R6Firing)        FLOAT             m_fRateOfFire;  //Time between each rounds
var	(R6Firing)	      stAccuracyType    m_stAccuracyValues;
var (R6Firing)	      eRateOfFire       m_eRateOfFire;          // Current Rate of Fire

var(Debug)          BOOL    m_bSoundLog;
var(Debug)          BOOL    bShowLog;
var(Debug)          INT     m_iDbgNextReticule; // allow to cycle through all the defined reticule in dbgNextReticule
var                 FLOAT   m_fDisplayFOV;		// weapon's FOV
var                 BOOL    m_bFireOn;
var                 BOOL    m_bEmptyAllClips;   // when set to true, a pistol in MP can always be reloaded with 5 bullets.

// Variable used for falling
var                 Vector  m_vPawnLocWhenKilled;// Location the pawn was at when the weapon start falling.  Used to find a location for the falling weapon if everything else fails.
var (R6GunProperties) string m_szReticuleClass;
var (R6GunProperties) string m_szWithWeaponReticuleClass;
var                 BYTE    m_wNbOfBounce;       // Location the pawn was at when the weapon start falling.  Used to find a location for the falling weapon if everything else fails.

const AccuracyLostWhenWounded = 1.2;   // Accuracy is 20% higher when the character is wounded.

replication
{
    //functions that the server will ask the client to do
    reliable if (Role == ROLE_Authority)
        ClientYourOwnerIs, 
        ClientsFireBullet, ClientShowBulletFire, ClientStartFiring, ClientStartChangeClip;

    //functions that the client will ask the server to do
    reliable if (Role < ROLE_Authority)
        ServerSetNextRateOfFire, ServerAddClips, ServerWhoIsMyOwner,
        ServerChangeClip, ServerStartFiring, ServerFireBullet, ServerStartChangeClip;

    //values that the server updates on the client
    unreliable if (Role == ROLE_Authority)
        m_iCurrentNbOfClips, m_iCurrentClip, m_eRateOfFire;

    unreliable if (bNetInitial && (Role == ROLE_Authority))
        m_iClipCapacity, m_pBulletClass;
}

simulated event HideAttachment();


function BOOL HasScope()
{
    return m_fMaxZoom > 2.0;
}

simulated function UseScopeStaticMesh()
{
    if(m_WithScopeSM != none)
    {
        SetStaticMesh(m_WithScopeSM);
    }
}

simulated function SpawnSelectedGadget()
{
    if (m_WeaponGadgetClass.default.m_eGadgetType == GAD_Silencer)
    {
        //Destroy the muzzle Gadget, silencer will replace it
        if (m_MuzzleGadget != none)
        {
            m_MuzzleGadget.destroy();
            m_MuzzleGadget = none;
        }
        R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szSilencerClass, class'Class')));
        //Update Muzzle Falsh position?
    }
    else if(m_WeaponGadgetClass.default.m_eGadgetType == GAD_Light)
    {
        if(m_szTacticalLightClass != "")
            R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szTacticalLightClass, class'Class')));
    }
    else
    {
        R6SetGadget(m_WeaponGadgetClass);
    } 
   
}

simulated function SetGadgets()
{
    #ifdefDEBUG if(bShowLog) log("SET GADGETS for :"$Self$" Gadget class = "$m_WeaponGadgetClass$" owner: "$Owner); #endif

	if(Level.NetMode != NM_Client)  //Client will set the m_WeaponGadgetClass with function SpawnSelectedGadget()
    {
        if (m_WeaponGadgetClass != none)
        {
            if(m_WeaponGadgetClass.default.m_eGadgetType == GAD_Silencer)
            {
                //Destroy the muzzle Gadget, silencer will replace it
                if (m_MuzzleGadget != none)
                {
                    m_MuzzleGadget.destroy();
                    m_MuzzleGadget = none;
                }
                R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szSilencerClass, class'Class')));
                //Update Muzzle Falsh position?
            }
            else if(m_WeaponGadgetClass.default.m_eGadgetType == GAD_Light)
            {
                if(m_szTacticalLightClass != "")
                    R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szTacticalLightClass, class'Class')));
            }
            else
            {
                R6SetGadget(m_WeaponGadgetClass);
            }  
        }
    }

    //Setting up the Weapon's automatic gadgets
    if (m_InventoryGroup == 1)  // primary weapon
    {
        if(m_szMagazineClass != "")
        {
            //For every weapon that has a magazine.
            R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szMagazineClass, class'Class')));
        }
        else
        {
            m_MagazineGadget=none;
        }
    
        if(GotBipod())
        {
            if(IsA('R6SniperRifle'))
            {
                if( Owner.IsA('R6Rainbow'))
                {
                    R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject("R6WeaponGadgets.R63rdRainbowScope", class'Class')));
                }
                else
                {
                    R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject("R6WeaponGadgets.R6ScopeGadget", class'Class')));
                }

                R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject("R6WeaponGadgets.R63rdSnipeBipod", class'Class')));
            }
            else
            {
                R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject("R6WeaponGadgets.R63rdLMGBipod", class'Class')));
            }
        }

        if (m_szMuzzleClass != "")
        {
            R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szMuzzleClass, class'Class')));
        }
    }
    else if(m_InventoryGroup == 2)  //secondary weapon
    {
        //every weapon has a magazine.
        R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szMagazineClass, class'Class')));

        if (m_szMuzzleClass != "")
        {
            R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szMuzzleClass, class'Class')));
        }
    }
}

simulated event Destroyed()
{
    //Function should not be called on servers or on AI characters.
	// if((R6Pawn(Owner) != none) && R6Pawn(Owner).IsLocallyControlled() == true)
	if(R6Pawn(Owner) != none && R6Pawn(Owner).m_bIsPlayer)
		RemoveFirstPersonWeapon();

    // Remove our references
    if(m_pMuzzleFlashEmitter != none)
    {
        m_pMuzzleFlashEmitter.Destroy();
        m_pMuzzleFlashEmitter = none;
    }

    if(m_pEmptyShellsEmitter != none)
    {
        m_pEmptyShellsEmitter.Destroy();
        m_pEmptyShellsEmitter = none;
    }

    if (m_SelectedWeaponGadget != none)
    {
        m_SelectedWeaponGadget.Destroy();
        m_SelectedWeaponGadget = none;
    }

    if (m_MuzzleGadget != none)
    {
        m_MuzzleGadget.destroy();
        m_MuzzleGadget = none;
    }

    if (m_ScopeGadget != none)
    {
        m_ScopeGadget.destroy();
        m_ScopeGadget = none;
    }

    if (m_BipodGadget != none)
    {
        m_BipodGadget.destroy();
        m_BipodGadget = none;
    }

    if (m_MagazineGadget != none)
    {
        m_MagazineGadget.destroy();
        m_MagazineGadget = none;
    }

    if (m_FPWeapon != none)
    {
        m_FPWeapon.destroy();
        m_FPWeapon=none;
    }
    
    Super.Destroyed();
}    
////////////////////////////////////////////////////////////////////////////
// WEAPON INITIALISATION                                                  //
////////////////////////////////////////////////////////////////////////////
// Do not put the PostBeginPlay Simulated because in MultiPlayer when the //
// weapon become relevant the nb of bullet it reset to the clip capacity  //
////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    FillClips();

    if((Level.NetMode != NM_Standalone) && (m_eWeaponType == WT_Pistol))
    {
        //In MP add 5 bullets to a handgun if no clip left
        m_bUnlimitedClip = true;
    }

    m_fEffectiveAccuracy = m_stAccuracyValues.fBaseAccuracy;
    m_fDesiredAccuracy = m_stAccuracyValues.fBaseAccuracy;
    m_fWorstAccuracy = m_stAccuracyValues.fBaseAccuracy;
}

simulated function FillClips()
{
    local INT i;

    //Filling clips
    //if(bShowLog) log("WEAPON - "$self$" - Number of Clips: " $ m_iNbOfClips $ " Clip capacity: " $ m_iClipCapacity $" for weapon "$self);
    
	m_iCurrentNbOfClips = m_iNbOfClips;

    if(IsPumpShotGun())
    {
        m_iNbBulletsInWeapon = m_iClipCapacity;
    }
    else
    {
        m_iNbBulletsInWeapon = m_iClipCapacity;
        for (i = 0; i < m_iNbOfClips; i++)
        {
            m_aiNbOfBullets[i] = m_iClipCapacity;
        }
        if(!IsLMG() && !IsA('R6Gadget'))
        {
            //Add the extra bullet in the first magazine.
            m_iNbBulletsInWeapon++;
        }
    }

}

function FLOAT GetWeaponRange()
{
	return m_pBulletClass.default.m_fRange;
}

function FLOAT GetWeaponJump()
{
    return m_stAccuracyValues.fWeaponJump;
}

event SetIdentifyTarget(bool bIdentifyCharacter, bool bFriendly, string characterName)
{
    local R6GameOptions GameOptions;

	if(m_ReticuleInstance != none)
	{
        GameOptions = GetGameOptions();

		m_ReticuleInstance.m_bIdentifyCharacter = bIdentifyCharacter && (GameOptions.HUDShowPlayersName || R6PlayerController(Pawn(Owner).controller).m_bShowCompleteHUD);
		m_ReticuleInstance.m_CharacterName = characterName;
		m_ReticuleInstance.m_bAimingAtFriendly = bFriendly;
	}
}

// this sets the reticule instance
simulated function R6SetReticule(optional Controller LocalPlayerController)
{
    local class<Actor> ReticuleToSpawn;
    local R6GameOptions GameOptions;
    local R6PlayerController pPlayerCtrl;

    //Load the reticule only if the player is locally controlled and if it's a Rainbow
    if(Owner.IsA('R6Rainbow'))
    {
        if (m_szReticuleClass != "")
        {
            if(LocalPlayerController != none)
                pPlayerCtrl = R6PlayerController(LocalPlayerController);
            else
                pPlayerCtrl = R6PlayerController(Pawn(Owner).controller);

            if (m_ReticuleInstance != none)
            {
                m_ReticuleInstance.Destroy();
                m_ReticuleInstance = none;
            }

            GameOptions = class'Actor'.static.GetGameOptions();
            //Spawn the first person reticule unless no first person weapon is shown.
            ReticuleToSpawn = class'Actor'.static.GetModMgr().GetCurrentReticule(m_szWithWeaponReticuleClass);
            if ((m_eWeaponType == WT_Grenade) || (m_eWeaponType == WT_Gadget) ||
                ((GameOptions.HUDShowFPWeapon == false) && ((Level.NetMode == NM_Standalone) ||
                 ((R6GameReplicationInfo(pPlayerCtrl.GameReplicationInfo) != none) && (R6GameReplicationInfo(pPlayerCtrl.GameReplicationInfo).m_bFFPWeapon == false)))))
            {
                ReticuleToSpawn = class'Actor'.static.GetModMgr().GetCurrentReticule(m_szReticuleClass);
            }
            m_ReticuleInstance = R6Reticule(Spawn(ReticuleToSpawn, owner));

            if (Level.NetMode == NM_Standalone)
			{
				m_ReticuleInstance.m_bShowNames = true;
			}
			else
			{
				m_ReticuleInstance.m_bShowNames = R6GameReplicationInfo(pPlayerCtrl.GameReplicationInfo).m_bShowNames;
			}
        }
    }
}

function ServerWhoIsMyOwner()
{
    ClientYourOwnerIs(Owner);
}

function ClientYourOwnerIs(actor OwnerFromServer)
{
    if(OwnerFromServer == none)
    {
        ServerWhoIsMyOwner();
        return;
    }
    SetOwner(OwnerFromServer);
    LoadFirstPersonWeapon();

    if(R6Pawn(Owner).m_bChangingWeapon == true)
    {
        if(IsInState('RaiseWeapon'))
            BeginState();
        else
            GotoState('RaiseWeapon');
    }
    else 
    {
	    StartLoopingAnims();
    }
}

//Spawn the FP weapon class and attach it to the Hands
simulated function BOOL LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
    if((m_pFPWeaponClass != none) && (m_pFPHandsClass != none) && (m_FPHands == none) && (m_FPWeapon == none))
    {
        //in MP games owner is set here, it's not replicated fast enaugh
        if(NetOwner != none)
            SetOwner(NetOwner);
        else if(Owner == none)
        {
            ServerWhoIsMyOwner();
            return FALSE;
        }
        
        m_FPHands  = spawn(m_pFPHandsClass,Self);

        if(Owner.IsA('R6Rainbow'))
        {
            m_FPHands.Skins[0] = R6Rainbow(Owner).Skins[5];
        }
        
        m_FPWeapon = spawn(m_pFPWeaponClass,Self);

        R6AbstractFirstPersonHands(m_FPHands).SetAssociatedWeapon(m_FPWeapon);

        if((m_FPWeapon != none) && (m_FPHands != none))
        {

            if(NumberOfBulletsLeftInClip() == 0)
            {
                //Weapon is empty
                m_FPWeapon.m_WeaponNeutralAnim=m_FPWeapon.m_Empty;
            }

            //If the hands ever have a different relative location.
            if (m_SelectedWeaponGadget != none)
            {
                m_SelectedWeaponGadget.AttachFPGadget();
            }
            if (m_MuzzleGadget != none)
            {
                m_MuzzleGadget.AttachFPGadget();
            }

            AttachEmittersToFPWeapon();

            m_FPWeapon.PlayAnim(m_FPWeapon.m_WeaponNeutralAnim);
            
            m_FPHands.AttachToBone(m_FPWeapon, 'B_R_Wrist_A');
        }
        else
        {
            #ifdefDEBUG log("WEAPON - "$self$" - Could not spawn First Person Weapon: "$m_pFPWeaponClass$" or Hands: "$m_pFPHandsClass);    #endif
        }
    }
    else
    {
        // Load the class that uses sleep calls instead of EndAnim
        #ifdefDEBUG 
        log("Invalid First person Hands and/or Weapon Class Please check base class of "$self );    
        log("WClass : "$m_pFPWeaponClass$" HClass: "$m_pFPHandsClass$" FPH: "$m_FPHands$" FPW: "$m_FPWeapon);
        #endif
    }

    //Load the reticule for the weapon
    R6SetReticule(LocalPlayerController);
    return TRUE;
}

simulated function AttachEmittersToFPWeapon()
{
    if(m_pMuzzleFlashEmitter != none) 
    {
        m_pMuzzleFlashEmitter.m_bDrawFromBase=false;
        m_pMuzzleFlashEmitter.SetBase(none);
        m_FPWeapon.AttachToBone(m_pMuzzleFlashEmitter,'TagMuzzle');
        m_pMuzzleFlashEmitter.SetRelativeLocation(vect(0,0,0));
        m_pMuzzleFlashEmitter.SetRelativeRotation(rot(0,0,0));
    }
    if(m_pEmptyShellsEmitter != none)
    {
        m_pEmptyShellsEmitter.m_bDrawFromBase=false;
        m_pEmptyShellsEmitter.SetBase(none);
        m_FPWeapon.AttachToBone(m_pEmptyShellsEmitter,'TagCase');
        m_pEmptyShellsEmitter.SetRelativeLocation(vect(0,0,0));
        m_pEmptyShellsEmitter.SetRelativeRotation(rot(0,0,0));
        if(m_pEmptyShellsEmitter.Emitters.Length > 0)
        {
            m_pEmptyShellsEmitter.Emitters[0].LifetimeRange.Min=0.3;
            m_pEmptyShellsEmitter.Emitters[0].LifetimeRange.Max=0.3;
        }
    }
}

simulated function AttachEmittersTo3rdWeapon()
{
    local vector vTagLocation;
    local rotator rTagRotator;

    if(m_pMuzzleFlashEmitter != none) 
    {
        GetTagInformations( "TAGMuzzle", vTagLocation, rTagRotator);

        if(m_SelectedWeaponGadget != none)
            vTagLocation += m_SelectedWeaponGadget.GetGadgetMuzzleOffset();
    
        if(m_FPWeapon != none)
            m_FPWeapon.DetachFromBone(m_pMuzzleFlashEmitter);
        m_pMuzzleFlashEmitter.m_bDrawFromBase=true;
        m_pMuzzleFlashEmitter.SetBase( none );
        m_pMuzzleFlashEmitter.SetBase( self, Location );
        m_pMuzzleFlashEmitter.SetRelativeLocation(vTagLocation);
        m_pMuzzleFlashEmitter.SetRelativeRotation(rTagRotator);

    }

    //Reset the emitter location
    if(m_pEmptyShellsEmitter != none)
    {
        GetTagInformations( "TagCase", vTagLocation, rTagRotator);

        if(m_FPWeapon != none)
            m_FPWeapon.DetachFromBone(m_pEmptyShellsEmitter);
        m_pEmptyShellsEmitter.m_bDrawFromBase=true;
        m_pEmptyShellsEmitter.SetBase( none );
        m_pEmptyShellsEmitter.SetBase( self, Location );
        m_pEmptyShellsEmitter.SetRelativeLocation(vTagLocation);
        m_pEmptyShellsEmitter.SetRelativeRotation(rTagRotator);
        if(m_pEmptyShellsEmitter.Emitters.Length > 0)
        {
            m_pEmptyShellsEmitter.Emitters[0].LifetimeRange.Min=4;
            m_pEmptyShellsEmitter.Emitters[0].LifetimeRange.Max=4;
        }
    }
}

simulated event PawnIsMoving()
{
    m_bPawnIsWalking=true;
    m_FPHands.PlayWalkingAnimation();
}

simulated event PawnStoppedMoving()
{
    m_bPawnIsWalking=false;
    m_FPHands.StopWalkingAnimation();
}

//When changing charter, this is to start playing the wait animations.
function StartLoopingAnims()
{
    if(m_FPHands != none)
    {
        m_FPHands.SetDrawType(DT_Mesh);
        m_FPHands.GotoState('Waiting');
        m_FPHands.PlayAnim(R6AbstractFirstPersonHands(m_FPHands).m_WaitAnim1);
    }

    GotoState('');

    R6Pawn(Owner).m_bReloadingWeapon = false;
    R6Pawn(Owner).m_bPawnIsReloading = false;
    R6Pawn(Owner).m_bWeaponTransition = false;
    //Values are set here to remove the parameters of R6WeaponShake.
    R6Pawn(Owner).m_fWeaponJump = m_stAccuracyValues.fWeaponJump;
    R6Pawn(Owner).m_fZoomJumpReturn = 1.0;
}

//Delete the first person weapon.  To keep only one in memory
simulated function RemoveFirstPersonWeapon()
{
    local Actor temp;

    if(m_FPHands != none)
    {
        temp = m_FPHands;
        m_FPHands = none;
        temp.Destroy();
    }

    UpdateAllAttachments();
    AttachEmittersTo3rdWeapon();
    
    if(m_FPWeapon != none)
    {
        m_FPWeapon.DestroySM();
        temp = m_FPWeapon;
        m_FPWeapon = none;
        temp.Destroy();
    }
    
    if(m_ReticuleInstance != none)
    {
        temp = m_ReticuleInstance;
        m_ReticuleInstance = none;
        temp.Destroy();
    }

    if (m_SelectedWeaponGadget != none)
        m_SelectedWeaponGadget.DestroyFPGadget();

    if (m_MuzzleGadget != none)
        m_MuzzleGadget.DestroyFPGadget();
}

simulated function UpdateAllAttachments()
{
    if(m_SelectedWeaponGadget != none)
        m_SelectedWeaponGadget.UpdateAttachment(self);
    if(m_ScopeGadget != none)
        m_ScopeGadget.UpdateAttachment(self);
    if(m_MagazineGadget != none)
        m_MagazineGadget.UpdateAttachment(self);
    if(m_BipodGadget != none)
        m_BipodGadget.UpdateAttachment(self);
    if(m_MuzzleGadget != none)
        m_MuzzleGadget.UpdateAttachment(self);
}

simulated function TurnOffEmitters(BOOL bTurnOff)
{
    if(m_pEmptyShellsEmitter != none)
        m_pEmptyShellsEmitter.bHidden = bTurnOff;
    if(m_pMuzzleFlashEmitter != none)
        m_pMuzzleFlashEmitter.bHidden = bTurnOff;
}


function ReloadShotGun()
{
    #ifdefDEBUG Log("!~!~!~!~!~!~!~! RELOAD SHOTGUN !~!~!~!~!~!~!~!"); #endif
}

////////////////////////////
// RATE OF FIRE FUNCTIONS //
////////////////////////////
exec function SetNextRateOfFire()
{
    // Only play on the client 
	// Sound Stuff
    #ifdefDEBUG if (m_bSoundLog) LogSnd("SetNextRateOfFire :"@ m_ChangeROFSnd); #endif
	Owner.PlaySound(m_ChangeROFSnd, SLOT_Guns);

    ServerSetNextRateOfFire();
}

exec function ServerSetNextRateOfFire()
{
    switch(m_eRateOfFire)
    {
        case ROF_FullAuto:
            if (!SetRateOfFire(ROF_Single))
            {
                SetRateOfFire(ROF_ThreeRound);
            }
            break;
            
        case ROF_ThreeRound:
            if (!SetRateOfFire(ROF_FullAuto))
            {
                SetRateOfFire(ROF_Single);
            }
            break;
            
        case ROF_Single:
            if (!SetRateOfFire(ROF_ThreeRound))
            {
                SetRateOfFire(ROF_FullAuto);
            }
            break;
    }
    #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - New Rate of Fire: " $ m_eRateOfFire); #endif
}

//Change the rate fo fire to a valid one, called by ServerSetNextRateOfFire
function BOOL SetRateOfFire(eRateOfFire eNewRateOfFire)
{
    if ((m_stWeaponCaps.bFullAuto == 1) && (eNewRateOfFire == ROF_FullAuto))
    {
        m_eRateOfFire = ROF_FullAuto;
    }
    else if ((m_stWeaponCaps.bThreeRound == 1) && (eNewRateOfFire == ROF_ThreeRound))
    {
        m_eRateOfFire = ROF_ThreeRound;
    }
    else if ((m_stWeaponCaps.bSingle == 1) && (eNewRateOfFire == ROF_Single))
    {
        m_eRateOfFire = ROF_Single;
    }
    else
    {
        return false;
    }

    return true;
}

function eRateOfFire GetRateOfFire()
{
    return m_eRateOfFire;
}

function INT GetNbOfRoundsForROF()
{
    if(m_iNbBulletsInWeapon <= 0)
    {
        return 0;
    }
    else
    {
        switch(m_eRateOfFire)
        {
            case ROF_FullAuto:
                return m_iNbBulletsInWeapon; // If the player hold the trigger, the magazine will be empty at the end
            
            case ROF_ThreeRound:
                return Min(3,m_iNbBulletsInWeapon);

            case ROF_Single:
                return 1;
        }
    }
}
////////////////////////////////
// CLIPS MANAGEMENT FUNCTIONS //
////////////////////////////////
simulated function AddExtraClip()
{
    AddClips(m_iNbOfExtraClips);
}

simulated function ServerAddClips()
{
    AddClips(m_iNbOfExtraClips);
}

//Called on server and client
simulated function AddClips(INT iNbOfExtraClips)
{
    local int i;
    local int iNewClipCount;
       
    for (i = m_iNbOfClips; i < m_iNbOfClips + iNbOfExtraClips; i++)
    {
        if (m_iNbOfClips+1 < C_iMaxNbOfClips)
        {
            m_aiNbOfBullets[i] = m_iClipCapacity;
            iNewClipCount++;
        }
    }
    m_iNbOfClips += iNewClipCount;
    m_iCurrentNbOfClips += iNewClipCount;

	if(Level.NetMode == NM_Client)  //only client call this on a server
    {
        ServerAddClips();
    }
}

//Overloaded from R6AbstractWeapons
function SetTerroristNbOfClips(INT iNewNumber)
{
    //used only by terrorists, that's why I can change empty all clips here.
    m_iCurrentNbOfClips = iNewNumber; //
    m_bEmptyAllClips = true;
}
function INT GetNbOfClips()
{
	return m_iCurrentNbOfClips;
}

function BOOL HasAtLeastOneFullClip()
{
	local INT i;

    if(IsPumpShotGun() == true)
    {
        if(m_iNbBulletsInWeapon < m_iClipCapacity*0.5)
            return true;
    }
    else
    {
        for(i=0; i<m_iNbOfClips; i++)
        {
            if(m_aiNbOfBullets[i] == m_iClipCapacity)
			    return true;
        }
    }
	return false;
}

//Overloaded from R6AbstractWeapons
function FLOAT GetCurrentMaxAngle()
{
    return m_fMaxAngleError;
}

//Overloaded from R6AbstractWeapons
function BOOL IsAtBestAccuracy()
{
    return (m_fMaxAngleError <= m_stAccuracyValues.fBaseAccuracy);
}

simulated function WeaponInitialization( Pawn pawnOwner )
{
    // Don't spawn on dedicated server, we don't need any visual.
    if(Level.NetMode == NM_DedicatedServer)
        return;

    CreateWeaponEmitters();

    //Set the name of the weapon
    if (default.m_NameID != "")
    {
        if (IsA('R6Gadget'))
        {
            m_WeaponDesc = Localize(m_NameID,"ID_NAME","R6Gadgets");
			m_WeaponShortName = m_WeaponDesc;
        }
        else
        {
            m_WeaponDesc = Localize(m_NameID,"ID_NAME","R6Weapons");
			m_WeaponShortName = Localize(m_NameID,"ID_SHORTNAME","R6Weapons");
        }
    }
    else
    {
        m_WeaponDesc = "No Name Set";
    }

    #ifdefDEBUG if (bShowLog) log("Weapon Initialization ID = " $ m_NameID $ " Name = " $ m_WeaponDesc); #endif

}

simulated function CreateWeaponEmitters()
{
    // Spawn emitters
    if(m_pMuzzleFlashEmitter == none && m_pMuzzleFlash!=none) 
    {
        m_pMuzzleFlashEmitter = Spawn(m_pMuzzleFlash);

        if((m_pMuzzleFlashEmitter != none) && (m_pMuzzleFlashEmitter.Emitters.Length > 4))
        {
            m_pMuzzleFlashEmitter.Emitters[4].StartSizeRange.X.Min *= m_MuzzleScale;
            m_pMuzzleFlashEmitter.Emitters[4].StartSizeRange.X.Max *= m_MuzzleScale;
            if(m_FPMuzzleFlashTexture != none)
                m_pMuzzleFlashEmitter.Emitters[4].Texture = m_FPMuzzleFlashTexture;
        }
    }
    if(m_pEmptyShellsEmitter == none && m_pEmptyShells!=none)
    {
        m_pEmptyShellsEmitter = Spawn(m_pEmptyShells);
    }

    AttachEmittersTo3rdWeapon();
}

//////////////////////
// FIRING DIRECTION //
//////////////////////
function GetFiringDirection(out vector vOrigin, out rotator rRotation, optional INT iBulletNumber)
{
    local FLOAT fMaxAngleError;
	local FLOAT fRandValueOne;
	local FLOAT fRandValueTwo;
    local FLOAT fMaxError;
    local R6PlayerController PlayerOwner;
    local R6Pawn PawnOwner;

    PawnOwner = R6Pawn(Owner);
    PlayerOwner = R6PlayerController(PawnOwner.Controller);

	vOrigin = PawnOwner.GetFiringStartPoint();

    if( PlayerOwner!=none && PlayerOwner.m_targetedPawn != none )
	{
        //When on AutoAim, the direction goes directly towards the target's head
		rRotation = rotator(PlayerOwner.m_vAutoAimTarget - vOrigin);
	}
	else
    	rRotation = PawnOwner.GetFiringRotation();

    if(iBulletNumber == 0)
    {
        fMaxError = m_fMaxAngleError * 91.022; // The result applies on 180 degrees (32768) and One degree is 91.022,    32768 / 360 = 91.022
        //Random value determine how much the bullet is affected by the Max Angle Error.
        fRandValueOne = (FRand() * 2 * fMaxError) - fMaxError;  //Random Pitch value
        fRandValueTwo = (FRand() * 2 * fMaxError) - fMaxError;  //Random Pitch value

        rRotation.Pitch += fRandValueOne;
	    rRotation.Yaw += fRandValueTwo;

        if(m_eWeaponType == WT_ShotGun)
        {
            m_rBuckFirstBullet.Pitch = rRotation.Pitch;
            m_rBuckFirstBullet.Yaw = rRotation.Yaw;
        }

        if(PlayerOwner != none)
        {
            PlayerOwner.m_rLastBulletDirection.Pitch = fRandValueOne;
            PlayerOwner.m_rLastBulletDirection.Yaw = fRandValueTwo;
            PlayerOwner.m_rLastBulletDirection.Roll = 1;  //if max angle Error is 0
        }
        //if(bShowLog) log("IN: WEAPON - "$self$" - GETFIRINGDIRECTION: rRotation is "$rRotation$" vOrigin is "$vOrigin$" m_fMaxAngleError: " $ m_fMaxAngleError);
    }
    else
    {
        //Random value determine how much the bullet is affected by the Max Angle Error.
        rRotation.Pitch = m_rBuckFirstBullet.Pitch + ((Frand() * 550) - 275); // result applies on 3 degrees (-275, 275);
	    rRotation.Yaw = m_rBuckFirstBullet.Yaw + ((Frand() * 550) - 275);
        //if(bShowLog) log("IN: WEAPON - "$self$" - GETFIRINGDIRECTION: Bullet # "$iBulletNumber$" rRotation is "$rRotation$" Rand value one "$fRandValueOne$" Two "$fRandValueTwo);
    }
}

simulated event RenderOverlays( canvas Canvas )
{
    local R6PlayerController thePlayerController;
    local rotator rNewRotation;
    
    if(Level.m_bInGamePlanningActive == true)
        return;

    if ( (Owner == none) || (Pawn(Owner).Controller == none))
    {
        return;
    }

    thePlayerController = R6PlayerController(Pawn(Owner).controller);
    if(thePlayerController != none)
    {
        if((thePlayerController.bBehindView == false) &&
           (thePlayerController.m_bUseFirstPersonWeapon == true))
        {
			if(m_FPHands != none)
			{
				m_FPHands.SetLocation(R6Pawn(Owner).R6CalcDrawLocation(self, rNewRotation, m_vPositionOffset));
				//Rotate around root bone when available.
				m_FPHands.SetRotation(Pawn(Owner).GetViewRotation() + rNewRotation + thePlayerController.m_rHitRotation);

                if (thePlayerController.ShouldDrawWeapon())
                {
				    Canvas.DrawActor(m_FPHands, false, true);
                }
			}            
        }
    }
}

simulated function PostRender(canvas Canvas )
{
    local R6PlayerController aPC;

    if(Level.m_bInGamePlanningActive == true || Owner==none)
        return;

    aPC = R6PlayerController(Pawn(Owner).Controller);

	if( aPC!=none && m_ReticuleInstance!=none && !aPC.bBehindView)
	{
        // set the color of the reticule as well as information about target actor if appropriate
	    m_ReticuleInstance.SetReticuleInfo(canvas);

        if (GetGameOptions().HUDShowPlayersName || aPC.m_bShowCompleteHUD)
        {
            m_ReticuleInstance.SetIdentificationReticule(Canvas);
        }

        if ((GetGameOptions().HUDShowReticule || aPC.m_bShowCompleteHUD) && !aPC.m_bHideReticule )
        {
		    m_ReticuleInstance.PostRender(canvas);
        }
	}
}

// FiringSpeed is used in UW as the rate parameter in playanim.
function Fire( FLOAT fValue )
{
    #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - R6Weapons.NoState::Fire(" $ fValue $ ") for weapon "$self); #endif
    GotoState('NormalFire');
}

function ClientStartFiring()
{
    //log("Lapsus : ClientStartFiring | m_iNbOfRoundsToShoot=" $ m_iNbOfRoundsToShoot);

    if ((m_iNbOfRoundsToShoot == 0) && (m_iNbOfRoundsInBurst == 0) && R6Pawn(Owner).m_bIsPlayer) // The magazine is empty
        R6Pawn(Owner).PlayLocalWeaponSound(WSOUND_PlayTrigger);

    if (Level.NetMode == NM_Client)
        m_iNbOfRoundsInBurst = 0;//New Burst, Re-init the value on client
}

function ServerStartFiring()
{
    m_iNbOfRoundsToShoot = GetNbOfRoundsForROF();
    //log("Lapsus : ServerStartFiring | m_iNbOfRoundsToShoot=" $ m_iNbOfRoundsToShoot);

    if ((m_iNbOfRoundsToShoot == 0) && (m_iNbOfRoundsInBurst == 0)) // The magazine is empty
        R6Pawn(Owner).PlayWeaponSound(WSOUND_PlayTrigger);
    m_iNbOfRoundsInBurst = 0;//New Burst, Re-init the value on server

    if (R6PlayerController(Pawn(Owner).controller) == None || R6PlayerController(Pawn(Owner).controller).m_bWantTriggerLag)
        ClientStartFiring();
}

//Added when trigger lag became an option, non-replicated version of StopFire
function LocalStopFire(optional BOOL bSoundOnly)
{
    if (R6PlayerController(Pawn(Owner).controller) != None)
    {
        if(!R6PlayerController(Pawn(Owner).controller).m_bWantTriggerLag)
            ClientStopFire();

        ServerStopFire(bSoundOnly);
    }
    else
    {
        ServerStopFire(bSoundOnly);
    }
}

//Originally called when the fire button is released, not automacially anymore, see Timer()
//Never call directly.  Allways use localstopfire() instead.  Since trigger lag became an option.
function ServerStopFire(optional BOOL bSoundOnly)
{
    #ifdefDEBUG if(bShowLog) log("Server Stop Fire! "$m_iNbOfRoundsInBurst);  #endif

	if ( ((m_iNbOfRoundsInBurst < 3) && (m_eRateOfFire != ROF_Single)) || (m_iNbOfRoundsInBurst >= 3) )
        R6Pawn(Owner).PlayWeaponSound(WSOUND_StopFireFullAuto);

    if (R6PlayerController(Pawn(Owner).controller) == None || R6PlayerController(Pawn(Owner).controller).m_bWantTriggerLag )
        ClientStopFire(bSoundOnly);
}

//Was simply called StopFire() in the past
function ClientStopFire(optional BOOL bSoundOnly)
{
    #ifdefDEBUG if(bShowLog) log("Client Stop Fire! || "$m_FPHands$" || R6Pawn(Owner).m_bIsPlayer = " $ R6Pawn(Owner).m_bIsPlayer $ ", " $ m_iNbOfRoundsInBurst $ ", "$ m_eRateOfFire);  #endif

	if ( ((m_iNbOfRoundsInBurst < 3) && (m_eRateOfFire != ROF_Single)) || (m_iNbOfRoundsInBurst >= 3) )
        R6Pawn(Owner).PlayLocalWeaponSound(WSOUND_StopFireFullAuto);

    if (!bSoundOnly)
    {
        if(m_FPHands != none)
        {		
            //Dont stop/interrupt the animation if it's a three round burst
            if(m_iNbOfRoundsInBurst < 3)
            {
                if(Level.NetMode != NM_Standalone)
                {
                    m_FPHands.StopFiring();
                }
                else
                {
                    m_FPHands.InterruptFiring();
                }
            }
            else if((m_iNbOfRoundsInBurst > 3) || ((m_iNbOfRoundsInBurst == 3) && (m_eRateOfFire != ROF_ThreeRound)))
            {
                m_FPHands.StopFiring();
            }
        }
        else
        {
            GotoState('');
        }

        R6Pawn(Owner).PlayWeaponAnimation();
    }
}

//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order 
//has been sent to the server without having to wait for server response.
function StopFire(optional BOOL bSoundOnly)
{
    #ifdefDEBUG if (bShowLog) log("Stop Fire! "$m_FPHands$" : "$m_iNbOfRoundsInBurst);  #endif
    
    //Essentially a call to LocalStopFire replicated to the client.
    LocalStopFire(bSoundOnly);
}

simulated function BOOL HasAmmo()
{
    return (m_iNbBulletsInWeapon > 0) || (m_iCurrentNbOfClips > 1);
}

simulated function INT NumberOfBulletsLeftInClip()
{
    return m_iNbBulletsInWeapon;
}

function INT GetClipCapacity()
{
    return m_iClipCapacity;
}

simulated function BOOL GunIsFull()
{
    return m_iNbBulletsInWeapon >= m_iClipCapacity;
}

function FLOAT GetMuzzleVelocity()
{
    return m_fMuzzleVelocity;
}

// For Raven Shield weapons, AltFire will activate the gadget
simulated function BOOL ClientAltFire( FLOAT fValue )
{
    #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - "$self$" - ClientAltFire");   #endif

    R6Pawn(Owner).ToggleGadget();

    return true;
}

function R6AbstractBulletManager GetBulletManager()
{
    local R6Pawn pOwner;

    pOwner = R6Pawn(Owner);
    if(pOwner!=none)
        return pOwner.m_pBulletManager;
}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
simulated function AltFire( FLOAT fValue )
{
    #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - "$self$" - AltFire"); #endif
    ClientAltFire(fValue);
}

function ServerFireBullet(FLOAT fMaxAngleErrorFromClient)
{
    local vector vStartTrace;
    local rotator rBulletRot;
    local INT iCurrentBullet;
    local R6Pawn PawnOwner;
    local R6AbstractBulletManager BulletManager;

    #ifdefDEBUG if(bShowLog) log ("WEAPON - " $ self $ " - ServerFireBullet | "$m_iNbBulletsInWeapon $" | "$ m_iNbOfRoundsInBurst); #endif

    if(m_iNbBulletsInWeapon == 0)
    {
        return;
    }

    PawnOwner = R6Pawn(Owner);
    BulletManager = GetBulletManager();

    m_iNbOfRoundsInBurst++;
    m_iNbBulletsInWeapon--;

    if((m_iNbBulletsInWeapon == 0) && !IsPumpShotGun())
    {
        if(!((m_iCurrentNbOfClips == 1) && m_bUnlimitedClip))
        {
            m_iCurrentNbOfClips--;
        }
        else
        {
            m_bEmptyAllClips = true;
            if(R6Rainbow(Owner) != none)
                m_iClipCapacity = 5;
        }
    }    

    // flag for third person animation.
    bFiredABullet = TRUE;
    if((PawnOwner.m_bIsProne) && GotBipod())
        PawnOwner.UpdateBipodPosture();
    else
        PawnOwner.PlayWeaponAnimation();

    //Weird but it should fix the bug in MP.
    m_fMaxAngleError = fMaxAngleErrorFromClient;

    for(iCurrentBullet = 0; iCurrentBullet < NbBulletToShot(); iCurrentBullet++)
    {
        GetFiringDirection(vStartTrace, rBulletRot, iCurrentBullet);
        //if (bShowLog) log("WEAPON - "$self$" Error : "$fMaxAngleErrorFromClient$" - vStartTrace is : "$vStartTrace$" and rBulletRot is "$rBulletRot);
        BulletManager.SpawnBullet(vStartTrace, rBulletRot, m_fMuzzleVelocity, iCurrentBullet == 0);
    }

    // increment the round fired counter (for stats purposes)
	if(PawnOwner != none)  //&& (R6Pawn(owner).playerReplicationInfo != none))
    {
        R6AbstractGameInfo(Level.Game).IncrementRoundsFired(PawnOwner, false);
    }

    m_fCurrentFireJump += m_stAccuracyValues.fWeaponJump;

    // Third Person Sound & Muzzle Flash
	if(m_iNbBulletsInWeapon == 0)
	{   
		switch(m_eRateOfFire)
		{
			case ROF_Single:
                PawnOwner.PlayWeaponSound(WSOUND_PlayEmptyMag);
				break;
                
			case ROF_ThreeRound:
			case ROF_FullAuto:
				if (m_iNbOfRoundsInBurst == 1)
                    PawnOwner.PlayWeaponSound(WSOUND_PlayFireSingleShot);
				break;
		}
	}
	else
	{
		if (m_iNbOfRoundsInBurst == 1)
		{
			switch(m_eRateOfFire)
			{
				case ROF_Single:
                    PawnOwner.PlayWeaponSound(WSOUND_PlayFireSingleShot);
					break;

				case ROF_ThreeRound:
					if (m_iNbOfRoundsToShoot >= 3) 
                        PawnOwner.PlayWeaponSound(WSOUND_PlayFireThreeBurst);
					else // Switch to FullAuto sound mode
                        PawnOwner.PlayWeaponSound(WSOUND_PlayFireFullAuto);
					break;

				case ROF_FullAuto:
                    PawnOwner.PlayWeaponSound(WSOUND_PlayFireFullAuto);
					break;
			}
		}
	}
    
    ClientsFireBullet(m_iNbBulletsInWeapon);

    // The noise manager take care of weapon silenced or not
    R6MakeNoise( SNDTYPE_Gunshot );
}

//This functions is called *immediatly* when trigger is pulled.  It only displays shooting effects.
//The actual shooting of the bullet is done on the server in ServerFireBullet().
function ClientShowBulletFire()
{
    local vector vStartTrace;
    local rotator rBulletRot;
    local R6Pawn PawnOwner;
    local R6PlayerController PlayerOwner;

    if (Level.NetMode == NM_Client)
        m_iNbOfRoundsInBurst++;

    #ifdefDEBUG if(bShowLog) log ("WEAPON - "$self$" - ClientShowBulletFire | Bullet : " $ m_iNbOfRoundsInBurst $ "  ROF : " $ m_eRateOfFire); #endif

    PawnOwner = R6Pawn(Owner);
    PlayerOwner = R6PlayerController(PawnOwner.Controller);

    if (PawnOwner.m_bIsPlayer)
    {
        //First Person Shooting Animations
        if(m_FPHands != none && m_iNbBulletsInWeapon > 0)
        {
            // m_iNbOfRoundsInBurst == 1 at the first bullet.

            //Hands animations
            if(m_eRateOfFire == ROF_Single)
            {
                //Single Shot Animations
                m_FPHands.FireSingleShot();
            }
            //shoot a three round burst
            else if((m_eRateOfFire == ROF_ThreeRound) && (m_iNbOfRoundsInBurst == 1))
            {
                //Three bullets Animations
                m_FPHands.FireThreeShots();
            }
            else if(m_iNbOfRoundsInBurst == 1) //We assume ROF_FullAuto & Beginning of a Burst
            {
                //Three Shot burst, and beginning of long burst
                m_FPHands.StartBurst();
            }
            //Weapon Animations
            m_FPWeapon.PlayFireAnim();
        }

        // First Person Sound & Muzzle Flash
        if ( Viewport(PlayerOwner.Player) != None )
        {
            #ifdefDEBUG if(bShowLog) log ("WEAPON - "$self$" - ClientShowBulletFire | Playing 1st person sound and muzzle flash");    #endif

            if(m_iNbBulletsInWeapon == 0)
	        {   
		        switch(m_eRateOfFire)
		        {
			        case ROF_Single:
                        PawnOwner.PlayLocalWeaponSound(WSOUND_PlayEmptyMag);
				        break;
            
			        case ROF_ThreeRound:
			        case ROF_FullAuto:
				        if (m_iNbOfRoundsInBurst >= 1)
                            PawnOwner.PlayLocalWeaponSound(WSOUND_PlayFireSingleShot);
				        break;
				        //Note from orouleau : there is a slight possibility here that 2 bullets are fired before receiving 
				        //the 1st ClientShowBulletFire.  In that case, we will play WSOUND_PlayFireSingleShot anyway.
				        //we could play WSOUND_PlayFireFullAuto if m_iNbOfRoundsInBurst > 1 but I didn't check if it would
				        //get stoped apropriatly.  
		        }
	        }
	        else
	        {
		        if (m_iNbOfRoundsInBurst == 1)
		        {
			        switch(m_eRateOfFire)
			        {
				        case ROF_Single:
                            PawnOwner.PlayLocalWeaponSound(WSOUND_PlayFireSingleShot);
					        break;

				        case ROF_ThreeRound:
					        if (m_iNbBulletsInWeapon >= 3) 
                                PawnOwner.PlayLocalWeaponSound(WSOUND_PlayFireThreeBurst);
					        else // Switch to FullAuto sound mode
                                PawnOwner.PlayLocalWeaponSound(WSOUND_PlayFireFullAuto);
					        break;

				        case ROF_FullAuto:
                            PawnOwner.PlayLocalWeaponSound(WSOUND_PlayFireFullAuto);
					        break;
			        }
		        }
	        }
        }



    }

    //Shake the camera when firing the weapon.

    if (Role != ROLE_Authority)
    {
        // this is to do the side-effect so that we can skake the camera properly in multiplayer
        // this *looks* like old, not usefull, deprecated code but it's not, I does the weapon-jump even
        // if the 2 variables (vStartTrace & rBulletRot) ain't explicitly used.
        GetFiringDirection(vStartTrace,rBulletRot);
    }

    if(PlayerOwner != none)
    {
        PlayerOwner.R6WeaponShake();
    }    
}

//This function is called *after* the server has handled the shooting of the bullet.
function ClientsFireBullet(BYTE iBulletNbFired)
{
    local R6Pawn PawnOwner;
    local R6PlayerController PlayerOwner;

    if (R6PlayerController(Pawn(Owner).controller) == None || R6PlayerController(Pawn(Owner).controller).m_bWantTriggerLag)
        ClientShowBulletFire();

    #ifdefDEBUG if(bShowLog) log ("WEAPON - "$self$" - ClientsFireBullet | " $ iBulletNbFired); #endif

    PawnOwner = R6Pawn(Owner);
    PlayerOwner = R6PlayerController(PawnOwner.Controller);
    
    //Update the number of bullets remaining in the clip on the client side.
    m_iNbBulletsInWeapon = iBulletNbFired;
    
    //First Person Animations (The actual shooting of the weapon is done "live" in ClientShowBulletFire()
    if (PawnOwner.m_bIsPlayer)
    {
        if(m_FPHands != none)
        {
            if(IsLMG() == true)
            {
                if(m_iNbBulletsInWeapon < 8)
                {
                    m_FPWeapon.HideBullet(m_iNbBulletsInWeapon);
                }
            }

            if(iBulletNbFired == 0)
            {   
                #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - ClientsFireBullet | calling m_FPHands.FireLastBullet()"); #endif
                m_FPHands.FireLastBullet();
                //Weapon Animations
                m_FPWeapon.PlayFireLastAnim();
            }
        }
    }    
}

state NormalFire
{
    ignores SetNextRateOfFire;

    function Fire( float Value )
    {
        if(m_bFireOn == false)
        {
            StartFiring();
        }
    }
    
    function AltFire( float Value ) {}
    function StopAltFire() {}
    function PlayReloading() 
	{
		// safety...
		R6Pawn(Owner).ServerSwitchReloadingWeapon(FALSE);
	}
    
    function EndState()
    {
        R6Pawn(Owner).m_bIsFiringState = FALSE;
        #ifdefDEBUG if (bShowLog) Log("WEAPON - "$self$" - "$self$" - Leaving State Normal Fire : "$Pawn(Owner).Controller.bFire);  #endif

        if (m_bFireOn == TRUE)
        {
            #ifdefDEBUG if (bShowLog) Log("WEAPON - "$self$" - EndState [Normal Fire] - THE BURST WASN'T FINISHED !!!");    #endif
            m_bFireOn = FALSE;
            SetTimer(0, false);
            LocalStopFire(true);
        }
        Pawn(Owner).controller.m_bLockWeaponActions = false;
    }
    
    simulated function FirstPersonAnimOver()
    {
        #ifdefDEBUG if (bShowLog) Log("WEAPON - "$self$" - FirstPersonAnimOver in State Normal Fire "$m_iNbOfRoundsToShoot); #endif
        m_FPHands.StartTimer();
        
		if(R6GameReplicationInfo(R6PlayerController(Pawn(Owner).controller).GameReplicationInfo).m_bGameOverRep)
        {
            GotoState('');
        }
	    else if ( (Pawn(Owner).Controller.bFire == 1) && (m_eRateOfFire==ROF_FullAuto) )
        {
            LocalStopFire(true);
            StartFiring();
            return;
        }
        else if ( (m_iNbOfRoundsToShoot > 0) && (m_eRateOfFire == ROF_ThreeRound) )
        {
            //Wait for the FirstPersonAnimOver that will be triggered by the anim played in the StopFire() called in 
            //the Timer() of the last bullet of the burst to exit the state.  I.e.: Don't exit now.
            return;
        }
        else
        {
            GotoState('');
        }
    }

    simulated function BeginState()
    {
        Pawn(Owner).controller.m_bLockWeaponActions = true;
        R6Pawn(Owner).m_bIsFiringState = TRUE;
        #ifdefDEBUG if (bShowLog) log("WEAPON - "$self$" - Begin state Normal Fire");   #endif

        StartFiring();
    }

    simulated function StartFiring()
    {
        m_iNbOfRoundsToShoot = GetNbOfRoundsForROF();

        #ifdefDEBUG if (bShowLog) log("WEAPON - "$self$" - StartFiring in State Normal Fire | Number of rounds to shoot : " $ m_iNbOfRoundsToShoot $ " | ROF: " $ m_fRateOfFire); #endif

        ServerStartFiring();

        if (R6PlayerController(Pawn(Owner).controller) != None && !R6PlayerController(Pawn(Owner).controller).m_bWantTriggerLag)
            ClientStartFiring();

        if(R6PlayerController(Pawn(Owner).controller) != none)
        {
            R6PlayerController(Pawn(Owner).controller).ResetCameraShake();
        }

		if (m_iNbOfRoundsToShoot != 0) // Gun is not empty
		{
            if(m_FPHands != none)
            {
                m_FPHands.GotoState('FiringWeapon');
            }
            DoSingleFire();

    		if (m_iNbOfRoundsToShoot != 0) // if weapon has more than one bullet
            {

                #ifdefDEBUG if (bShowLog) Log("WEAPON - "$self$" - StartFiring : SetTimer in State Normal Fire | NbOfRoundsToShoot : " $ m_iNbOfRoundsToShoot $ " | ROF : " $ m_fRateOfFire );   #endif
                SetTimer(m_fRateOfFire, true);
                m_bFireOn = TRUE;
            }
            else
            {
                // for other characters than the player exit here
                if(m_FPHands == none)
                {
                    GotoState('');
                }
            }
		}
		else
		{
            if(m_FPHands.HasAnim('FireEmpty'))
            {
                m_FPHands.PlayAnim('FireEmpty');
            }
            GotoState('');
		}
    }

    simulated function Timer()
    {
        //log("Lapsus : TIMER called | m_iNbOfRoundsToShoot=" $ m_iNbOfRoundsToShoot $ " before decrementation");
        m_iNbOfRoundsToShoot--;
        if ((m_iNbOfRoundsToShoot > 0) && ((m_eRateOfFire == ROF_ThreeRound) || (Pawn(Owner).Controller.bFire == 1)))
		{
			//log("Lapsus : TIMER, doing single fire | m_iNbOfRoundsToShoot=" $ m_iNbOfRoundsToShoot);
			DoSingleFire();
		}
        else
        {
            #ifdefDEBUG if (bShowLog) log ("WEAPON - "$self$" - StopFire() called in Timer()");   #endif

            //Stop timer
            m_bFireOn = FALSE;
            SetTimer(0, false);
            StopFire(false);
        }
    }

    function DoSingleFire()
    {
        #ifdefDEBUG if (bShowLog) log ("WEAPON - "$self$" - DoSingleFire/NbOfBullets: " $ m_iNbBulletsInWeapon); #endif

        ServerFireBullet(m_fMaxAngleError);

        if (R6PlayerController(Pawn(Owner).controller) != None && !R6PlayerController(Pawn(Owner).controller).m_bWantTriggerLag)
            ClientShowBulletFire();
    }
}

function FullCurrentClip()
{
    m_iNbBulletsInWeapon = m_iClipCapacity;
}

function ClientStartChangeClip()
{
    if(R6Pawn(Owner).m_bIsPlayer)
    {
	    if (m_iNbBulletsInWeapon <= 0) // Check if the Reload Empty Sound was set
        {
            R6Pawn(Owner).PlayLocalWeaponSound(WSOUND_PlayReloadEmpty);
        }
	    else // Play the Reload sound
        {
            R6Pawn(Owner).PlayLocalWeaponSound(WSOUND_PlayReload);
        }
    }
}

function ServerStartChangeClip()
{
    if (m_iNbBulletsInWeapon <= 0) // Check if the Reload Empty Sound was set
    {
        R6Pawn(Owner).PlayWeaponSound(WSOUND_PlayReloadEmpty);
    }
    else // Play the Reload sound
    {
        R6Pawn(Owner).PlayWeaponSound(WSOUND_PlayReload);
    }
    
    if (R6PlayerController(Pawn(Owner).controller) == None || R6PlayerController(Pawn(Owner).controller).m_bWantTriggerLag)
        ClientStartChangeClip();
}

function ServerChangeClip()
{
	local INT i;
	local INT iClipNumber;
	local INT iMostFullClip;
	local INT iMaxNbOfRounds;
    local INT iBulletLeftInWeapon;

    R6MakeNoise( SNDTYPE_Reload );

	#ifdefDEBUG if (bShowLog) log("WEAPON - "$self$" - Changing Clip -> m_iCurrentClip: " $ m_iCurrentClip $ " m_iCurrentNbOfClips: " $ m_iCurrentNbOfClips $ " m_iNbOfClips: " $ m_iNbOfClips);    #endif

    //log("HERE : "$m_bUnlimitedClip$" : "$GetNbOfClips()$" : "$m_iCurrentClip$" : "$m_iNbBulletsInWeapon$" : "$m_iClipCapacity);
    if((m_bUnlimitedClip) && (GetNbOfClips() == 1) && (m_bEmptyAllClips == true))
    {
        // If unlimited clip, just add ammo to the current one
        m_iNbBulletsInWeapon = m_iClipCapacity;
    }
    else
    {
        //Transfer the number of bullets in the clip table.
        m_aiNbOfBullets[m_iCurrentClip] = m_iNbBulletsInWeapon;

	    // When a character changes his clip, he always changes it with a magazine with more rounds in it.
	    if (m_aiNbOfBullets[m_iCurrentClip] == 0)
	    {
            iBulletLeftInWeapon=0;
	    }
        else
        {
            //Changing clip and there's still bullets left in the mag.  Leave on in the gun.
            if(!IsPumpShotGun())
            {
                if(IsLMG())
                {
                    if((m_aiNbOfBullets[m_iCurrentClip] < 8) && (m_iCurrentNbOfClips != 1))
                    {
		                //For LMG, chains with less than 8 bullets won't be reloaded.
		                m_aiNbOfBullets[m_iCurrentClip] = 0;
                        m_iCurrentNbOfClips--;
                        iBulletLeftInWeapon=0;
                    }
                }
                else
                {
                    m_aiNbOfBullets[m_iCurrentClip] -= 1;
                    if(m_aiNbOfBullets[m_iCurrentClip] == 0)
                    {
                        //Do Not delete the very last clip
                        if(m_iCurrentNbOfClips != 1)
                            //Mag had only one bullet left
                            m_iCurrentNbOfClips--;
                    }
                    iBulletLeftInWeapon=1;
                }
            }
        }

        iMostFullClip = m_iCurrentClip;
	    for (i = 0; i < m_iNbOfClips; i++)
	    {
		    iClipNumber = (m_iCurrentClip + i);

		    if (iClipNumber >= m_iNbOfClips)
		    {
			    iClipNumber -= m_iNbOfClips;
		    }

		    // Switch with the clip with the most rounds (Even if it's the same one)
		    if (m_aiNbOfBullets[iClipNumber] > iMaxNbOfRounds)
		    {
			    iMaxNbOfRounds = m_aiNbOfBullets[iClipNumber];
			    iMostFullClip = iClipNumber;
		    }
        }

        m_iCurrentClip = iMostFullClip;
        m_aiNbOfBullets[m_iCurrentClip] += iBulletLeftInWeapon;
        m_iNbBulletsInWeapon = m_aiNbOfBullets[m_iCurrentClip];
    }

    //log("ServerChangeClip");
    R6Pawn(Owner).ServerSwitchReloadingWeapon(FALSE);
}

simulated function PlayReloading()
{
    #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - Play Reloading"); #endif
    GotoState('Reloading');
}

simulated function WeaponZoomSound(BOOL bFirstZoom)
{
	if (bFirstZoom)
	{
		if (m_SniperZoomFirstSnd != None)
			Owner.PlaySound(m_SniperZoomFirstSnd, SLOT_Guns);
		else if (m_CommonWeaponZoomSnd != None)
			Owner.PlaySound(m_CommonWeaponZoomSnd, SLOT_Guns);
	}
	else
	{
		if (m_SniperZoomSecondSnd != None)
			Owner.PlaySound(m_SniperZoomSecondSnd, SLOT_Guns);
	}
}

state Reloading
{
    ignores SetNextRateOfFire;

    function Fire( float Value ){}
    function AltFire( float Value ) {}
    function StopAltFire() {}
    function PlayReloading() {}
    
    function FirstPersonAnimOver()
    {
        local Pawn PawnOwner;
        PawnOwner = Pawn(Owner);
        //this event is called only in FirstPerson
        // weapon is done reloading, change the flag in the controller.
        //log("State Reloading FPAnimOver");
        if(PawnOwner.Controller != none)
            R6Pawn(Owner).ServerSwitchReloadingWeapon(FALSE);
        ServerChangeClip();
        
        if((PawnOwner.Controller != none) && (PawnOwner.Controller.bFire == 1))
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }

	simulated function ChangeClip()
	{
        //log("State Reloading ChangeClip");
        R6Pawn(Owner).ServerSwitchReloadingWeapon(FALSE);
        ServerChangeClip();

        if(Pawn(Owner).Controller.bFire == 1)
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }

    function EndState()
    {
        local R6PlayerController PlayerCtrl;
        PlayerCtrl = R6PlayerController(Pawn(Owner).controller);

        #ifdefDEBUG if (bShowLog) log("WEAPON - "$self$" - Leaving State Reloading");   #endif
        if(PlayerCtrl != none)
        {
            PlayerCtrl.m_iPlayerCAProgress = 0;
            PlayerCtrl.m_bHideReticule = FALSE;
            PlayerCtrl.m_bLockWeaponActions = FALSE;
        }
        // Reset the reloading flag!.
        R6Pawn(Owner).ServerSwitchReloadingWeapon(FALSE);
    }

    simulated function BeginState()
    {
        local R6PlayerController PlayerCtrl;
        PlayerCtrl = R6PlayerController(Pawn(Owner).controller);

        #ifdefDEBUG if (bShowLog) log("WEAPON - "$self$" - Begin State Reloading! : "$GetNbOfClips());  #endif

        // We must have at least 1 spare clip to be able to reload except in MP
        if( (GetNbOfClips() > 0) || ((Level.NetMode != NM_Standalone) && (m_eWeaponType == WT_Pistol)))
        {
            if(PlayerCtrl != none)
            {
                PlayerCtrl.m_bLockWeaponActions = true;
                if (!PlayerCtrl.m_bWantTriggerLag)
                    ClientStartChangeClip();
            }
            ServerStartChangeClip();

             //Play reload animations for gun and hands in First Person.
            if (R6Pawn(Owner).m_bIsPlayer)
            {
                if(PlayerCtrl.bBehindView == FALSE)
                {
                    if(m_iNbBulletsInWeapon <= 0)
                    {
                        m_FPHands.m_bReloadEmpty = true;
                    }

                    m_FPHands.GotoState('Reloading');
                    PlayerCtrl.m_iPlayerCAProgress = 0;
                    PlayerCtrl.m_bHideReticule = TRUE;
                }
            } 
        }
        else
        {
            GotoState('');
        }
    }

    function INT GetReloadProgress()
	{
		local name  anim;
		local FLOAT fFrame,fRate;
		
		m_FPHands.GetAnimParams(0, anim, fFrame, fRate);	
		return fFrame*110;
	}

	event Tick(FLOAT fDeltaTime)
	{
        local R6PlayerController PlayerCtrl;
        PlayerCtrl = R6PlayerController(Pawn(Owner).controller);
        if(PlayerCtrl != none && !PlayerCtrl.ShouldDrawWeapon())
    		PlayerCtrl.m_iPlayerCAProgress = GetReloadProgress();
	}
}

//DiscardWeapon is used when changing weapon
state DiscardWeapon
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
    function StopFire( optional BOOL bSoundOnly ) {}
    function StopAltFire() {}
    function PlayReloading() {}

    function FirstPersonAnimOver()
    {
        #ifdefDEBUG if(bShowLog) log("IN:"@self@"::DiscardWeapon::FirstPersonAnimOver()");  #endif

        if(Pawn(Owner).Controller != none)
           R6PlayerController(Pawn(Owner).controller).WeaponUpState();
    }

    simulated function BeginState()
    {
        local R6PlayerController PlayerCtrl;
        PlayerCtrl = R6PlayerController(Pawn(Owner).controller);

        #ifdefDEBUG  if(bShowLog) log("IN:"@self@"::DiscardWeapon::BeginState()");  #endif

        if(m_FPHands != none)
        {
            if(PlayerCtrl != none)
                PlayerCtrl.m_bHideReticule = true;
            m_FPHands.GotoState('DiscardWeapon');
        }
        if(PlayerCtrl != none)
            PlayerCtrl.m_bLockWeaponActions = true;
    }
    simulated function EndState()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$Self$" Leaving state DiscardWeapon");  #endif
    }
}

//Raise weapon is used when changing weapon
state RaiseWeapon
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
    function StopFire( optional BOOL bSoundOnly ) {}
    function StopAltFire() {}
    function PlayReloading() {}

    function EndState()
    {
        local R6PlayerController PlayerCtrl;
        local R6Rainbow          RainbowPawn;
        RainbowPawn = R6Rainbow(Owner);
        PlayerCtrl = R6PlayerController(RainbowPawn.controller);

        //Update the weapon position for the shadow
        #ifdefDEBUG if (bShowLog) log("WEAPON - "$self$" - EndState of RaiseWeapon for "$self); #endif
        RainbowPawn.AttachWeapon(self, m_AttachPoint);

        if(PlayerCtrl != none)
        {
            PlayerCtrl.m_bHideReticule = false;
            PlayerCtrl.m_bLockWeaponActions = false;
        }

        //Values are set here to remove the parameters of R6WeaponShake.
        RainbowPawn.m_fWeaponJump = m_stAccuracyValues.fWeaponJump;
        RainbowPawn.m_fZoomJumpReturn = 1.0;
    }

    function FirstPersonAnimOver()
    {
        #ifdefDEBUG if (bShowLog) log("WEAPON - "$self$" - FirstPersonAnimOver in RaiseWeapon for "$self);  #endif
        
        if(Pawn(Owner).Controller != none)
            R6PlayerController(Pawn(Owner).controller).ServerWeaponUpAnimDone();

        R6Pawn(Owner).m_bChangingWeapon = FALSE;

        if((Pawn(Owner).Controller != none) && (Pawn(Owner).Controller.bFire == 1))
        {
            #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - FirstPersonAnimOver in RaiseWeapon GotoNormalFire");  #endif
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }

    simulated function BeginState()
    {
        #ifdefDEBUG if (bShowLog) log("WEAPON - "$self$" - BeginState of RaiseWeapon for "$self);   #endif

        TurnOffEmitters(false);

        if(m_FPHands != none)
        {
            if(m_bPawnIsWalking == true)
                m_FPHands.PlayWalkingAnimation();
            else
                m_FPHands.StopWalkingAnimation();

            if(m_FPHands.IsInState('RaiseWeapon'))
                m_FPHands.BeginState();
            else
                m_FPHands.GotoState('RaiseWeapon');
        }
    }
}

//When the character has to use his hands before doing an action
state PutWeaponDown
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
    function StopFire( optional BOOL bSoundOnly ) {}
    function StopAltFire() {}
    function PlayReloading() {}

    function FirstPersonAnimOver(){}

    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - BeginState of PutWeaponDown for "$self);  #endif
        if(m_FPHands != none)
        {
			if(m_FPHands.IsInState('FiringWeapon'))
			{
				GotoState('');
				return;
			}
			m_FPHands.GotoState('PutWeaponDown');
        }
        R6Pawn(Owner).m_bWeaponTransition = false;
		if(Pawn(Owner).controller != none)
			Pawn(Owner).controller.m_bLockWeaponActions = true;
    }
}

//When the action is over, use this state to bring the weapon up.
state BringWeaponUp
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
    function StopFire( optional BOOL bSoundOnly ) {}
    function StopAltFire() {}
    function PlayReloading() {}

    function FirstPersonAnimOver()
    {
        if((Pawn(Owner).Controller != none) && (Pawn(Owner).Controller.bFire == 1))
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }

    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - BeginState of BringWeaponUp for "$self);  #endif
        if(m_FPHands != none)
        {
            m_FPHands.GotoState('BringWeaponUp');
        }
        else
        {
            FirstPersonAnimOver();
        }
    }
    simulated function EndState()
    {
        if(Pawn(Owner).controller != none)
        {
            Pawn(Owner).controller.m_bHideReticule = false;
            Pawn(Owner).controller.m_bLockWeaponActions = false;
        }
    }
}

state DeployBipod
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
//    function StopFire() {}
    function StopAltFire() {}
    function PlayReloading() {}

    function FirstPersonAnimOver()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - FirstPerson Anim Over DeployBipod");  #endif
        if((Pawn(Owner).Controller != none) && (Pawn(Owner).Controller.bFire == 1))
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }
    
    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - BeginState of DeployBipod for "$self);    #endif
        if(m_FPHands != none)
        {
            m_FPHands.GotoState('DeployBipod');
        }
    }
    function EndState()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - EndState of DeployBipod for "$self);  #endif
    }
}

state CloseBipod
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
//    function StopFire() {}
    function StopAltFire() {}
    function PlayReloading() {}

    function FirstPersonAnimOver()
    {
        if((Pawn(Owner).Controller != none) && (Pawn(Owner).Controller.bFire == 1))
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }
    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - BeginState of CloseBipod for "$self); #endif
        if(m_FPHands != none)
        {
            m_FPHands.GotoState('CloseBipod');
        }
    }
}

simulated event DeployWeaponBipod(BOOL bBipodOpen)
{
    if(m_BipodGadget != none)
    {
        m_BipodGadget.Toggle3rdBipod(bBipodOpen);
    }
}

state ZoomIn
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}
//    function StopFire() {}
    function StopAltFire() {}
    function PlayReloading() {}

    function FirstPersonAnimOver()
    {
        local Pawn PawnOwner;
        PawnOwner = Pawn(Owner);
        if(PawnOwner.Controller != none)
            R6PlayerController(PawnOwner.controller).DoZoom();

        if((PawnOwner.Controller != none) && (PawnOwner.Controller.bFire == 1))
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }
    
    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - ZOOM begin state");   #endif
        Pawn(Owner).controller.m_bLockWeaponActions = true;
		WeaponZoomSound(true);
        if(m_FPHands != none)
        {
            m_FPHands.GotoState('ZoomIn');
        }
    }
    simulated function EndState()
    {
        Pawn(Owner).controller.m_bLockWeaponActions = false;
    }
}

state ZoomOut
{

    function FirstPersonAnimOver()
    {
//        R6PlayerController(Pawn(Owner).controller).DoneZoomingOut();
        if((Pawn(Owner).Controller != none) && (Pawn(Owner).Controller.bFire == 1))
        {
            GotoState('NormalFire');
        }
        else
        {
            GotoState('');
        }
    }
    
    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - begin state ZoomOut");    #endif
        if(m_FPHands != none)
        {
            m_FPHands.GotoState('ZoomOut');
        }
    }
}

//Cheat/debug function
function FullAmmo()
{
    local INT iClip;

    //if this check is by-passed, the server will still know the correct number of bullets
    if (Level.NetMode!= NM_Standalone)
    {
        return;
    }

    m_iNbBulletsInWeapon = 250;

    for (iClip = 0; iClip < C_iMaxNbOfClips; iClip++)
    {
        m_aiNbOfBullets[iClip] = 250;
    }

    m_iCurrentClip = 0;
    m_iCurrentNbOfClips = C_iMaxNbOfClips;
}

//Cheat/debug function
function PerfectAim()
{
    m_stAccuracyValues.fAccuracyChange = 0;
    m_stAccuracyValues.fReticuleTime = 0.1;
    m_stAccuracyValues.fRunningAccuracy = 0;
    m_stAccuracyValues.fShuffleAccuracy = 0;
    m_stAccuracyValues.fWalkingAccuracy = 0;
    m_stAccuracyValues.fWalkingFastAccuracy = 0;
}


#ifdefDEBUG
// Cycle throu all the reticule defined in the switch case
// Only used for debug purpose
exec function DbgNextReticule()
{
    switch ( m_iDbgNextReticule )
    {
    case 0: m_pReticuleClass = Class'R6Weapons.R6CrossReticule';
        break;

    case 1: m_pReticuleClass = Class'R6Weapons.R6CircleReticule';
        break;

    case 2: m_pReticuleClass = Class'R6Weapons.R6CircleDotReticule';
        break;

    case 3: m_pReticuleClass = Class'R6Weapons.R6CircleDotLineReticule';
        break;

    case 4: m_pReticuleClass = Class'R6Weapons.R6RifleReticule';
        break;

    case 5: m_pReticuleClass = Class'R6Weapons.R6WReticule';
        break;

    case 6: m_pReticuleClass = Class'R6Weapons.R6GrenadeReticule';
        break;

    case 7: m_pReticuleClass = Class'R6Weapons.R6WithWeaponReticule';
        break;

    case 8: m_pReticuleClass = Class'R6Weapons.R6WithWeaponDotReticule';
        break;
    }
    ++m_iDbgNextReticule;

    if ( m_iDbgNextReticule > 8 )
        m_iDbgNextReticule = 0;

    if ( m_ReticuleInstance != None )
    {
        m_ReticuleInstance.destroy();
    }
    
    m_ReticuleInstance = Spawn(m_pReticuleClass);
    if (bShowLog) log( "New Reticule: " $m_pReticuleClass );
}
#endif

function GiveBulletToWeapon(string aBulletName)
{
    local class<R6Bullet> aBulletClass;

    aBulletClass = class<R6Bullet>(DynamicLoadObject(aBulletName, class'Class'));
    if(aBulletClass!=none)
        m_pBulletClass = aBulletClass;
}

function BOOL HasBulletType( name strBulletName )
{
	if(m_pBulletClass == none)
		return false;

    return strBulletName == m_pBulletClass.name;
}

function Texture Get2DIcon()
{
    return m_WeaponIcon;
}

function bool AffectActor(INT BulletGroup, actor ActorAffected)
{
    return GetBulletManager().AffectActor(BulletGroup, ActorAffected);
}

simulated function R6SetGadget(class<R6AbstractGadget> pWeaponGadgetClass)
{
    local R6AbstractGadget SelectedWeaponGadget;

    #ifdefDEBUG if(bShowLog) log("R6SetGadget class=" $ pWeaponGadgetClass $ " for weapon " $ Name $ " of " $ Owner );  #endif
    if (pWeaponGadgetClass == none)
    {
        m_SelectedWeaponGadget = none;
    }
    else
    {
        switch (pWeaponGadgetClass.default.m_eGadgetType)
        {
            case GAD_SniperRifleScope:
                if (m_ScopeGadget != none)
                    return;
                break;
            case GAD_Magazine:
                if (m_MagazineGadget != none)
                    return;
                break;
            case GAD_Bipod:
                if (m_BipodGadget != none)
                    return;
                break;
            case GAD_Muzzle:
                if (m_MuzzleGadget != none)
                    return;
                break;
            default:
                if (m_SelectedWeaponGadget != none)
                    return;
                break;
        }
        SelectedWeaponGadget = spawn(pWeaponGadgetClass);
        
        #ifdefDEBUG if(bShowLog) log("ServerSetGadget "$SelectedWeaponGadget$" Was spawned for "$self); #endif

        if (SelectedWeaponGadget != none)
        {
			SelectedWeaponGadget.InitGadget( Self, Pawn(Owner) );
            switch(SelectedWeaponGadget.m_eGadgetType)
            {
                case GAD_SniperRifleScope:
                    m_ScopeGadget = SelectedWeaponGadget;
                    break;
                case GAD_Magazine:
                    m_MagazineGadget = SelectedWeaponGadget;
                    break;
                case GAD_Bipod:
                    m_BipodGadget = SelectedWeaponGadget;
                    break;
                case GAD_Muzzle:
                    m_MuzzleGadget = SelectedWeaponGadget;
                    break;
                default:
                    m_SelectedWeaponGadget = SelectedWeaponGadget;
                    break;
            }
            #ifdefDEBUG if(bShowLog) log("R6SetGadget" @ owner @ Self @ SelectedWeaponGadget);  #endif
        }
#ifdefDEBUG
        else
			log("  IRREGULAR ERROR!!  Gadget spawn has failed for pWeaponGadgetClass="$pWeaponGadgetClass); 
#endif

    }
}

function FLOAT GetExplosionDelay()
{
	return 0.f;
}

function INT NbBulletToShot()
{
    return 1;
}

simulated event UpdateWeaponAttachment()
{
    local vector vTagLocation;
    local rotator rTagRotator;

    SetGadgets();
}

function SetRelevant( BOOL bNewAlwaysRelevant )
{
    bAlwaysRelevant = bNewAlwaysRelevant;

    if( m_MagazineGadget != none )
        m_MagazineGadget.bAlwaysRelevant = bAlwaysRelevant;

    if( m_SelectedWeaponGadget != none )
        m_SelectedWeaponGadget.bAlwaysRelevant = bAlwaysRelevant;
    
    if( m_ScopeGadget != none )
        m_ScopeGadget.bAlwaysRelevant = bAlwaysRelevant;

    if( m_BipodGadget != none )
        m_BipodGadget.bAlwaysRelevant = bAlwaysRelevant;

    if( m_MuzzleGadget != none )
        m_MuzzleGadget.bAlwaysRelevant = bAlwaysRelevant;
}

function SetTearOff( BOOL bNewTearOff )
{
    bTearOff = bNewTearOff;

    if( m_MagazineGadget != none )
        m_MagazineGadget.bTearOff = bTearOff;

    if( m_SelectedWeaponGadget != none )
        m_SelectedWeaponGadget.bTearOff = bTearOff;
    
    if( m_ScopeGadget != none )
        m_ScopeGadget.bTearOff = bTearOff;

    if( m_BipodGadget != none )
        m_BipodGadget.bTearOff = bTearOff;

    if( m_MuzzleGadget != none )
        m_MuzzleGadget.bTearOff = bTearOff;
}

/////////////////////////////////////////////////////////
//	#####    ###    ##      ##       ####   #   #    ####   
//	##      ##  #   ##      ##        ##    ##  #   ##      
//	####    #####   ##      ##        ##    # # #   ## ##   
//	##      ##  #   ##      ##        ##    #  ##   ##  #   
//	##      ##  #   #####   #####    ####   #   #    ####   
/////////////////////////////////////////////////////////

//============================================================================
// function HitWall - Bounce when the weapon fall of a dead pawn
//============================================================================
simulated function HitWall( vector HitNormal, actor Wall )
{
    #ifdefDEBUG if(bShowLog) log( name $ "Bounce of wall " $ Wall.name $ " at " $ HitNormal );  #endif

    m_wNbOfBounce++;
    RotationRate.Pitch = 0;
    RotationRate.Yaw   = RandRange(-65535, 65535);
    RotationRate.Roll  = RandRange(-65535, 65535);

    if(HitNormal.Z < 0.10)
    {
        // The weapon will bounce off the wall with 75% of it's original velocity
        //Velocity = 0.75 * MirrorVectorByNormal( Velocity, HitNormal );
        Velocity = 0.75 * VSize( Velocity ) * HitNormal;
    }
    else
    {
        // The weapon will bounce off the wall with 15% of it's original velocity in X and Y and 30% in Z
        Velocity = 0.15 * MirrorVectorByNormal( Velocity, HitNormal );
        Velocity.Z *= 2;

        if ( VSize(Velocity) < 10 )
        {
            if(CheckForPlaceToFall())
                return;
            else
                StopFallingAndSetCorrectRotation();
        }
    }

    // Security check.  If the weapon bounce repeatidly, hide the weapon
    if(m_wNbOfBounce>20)
        PutAtOwnerFeet();
}

//============================================================================
// function BOOL CheckForPlaceToFall - 
//============================================================================
simulated function BOOL CheckForPlaceToFall()
{
    local vector vNewLocation;
    local vector vHitLocation;
    local vector vNormal;
    local actor aTraced;

    // If we're on something in the middle, below the gun, stay there
    vNewLocation = Location - vect(0.f,0.f,10.f);
    aTraced = R6Trace( vHitLocation, vNormal, vNewLocation, Location, 0 );
    if( aTraced == none )
    {
        // Check if we can find a better spot lower
        if( FindSpot( vNewLocation) )
        {
            if(vNewLocation != Location)
            {
                SetLocation( vNewLocation );
                return true;
            }
        }
        else
        {
            vNewLocation = m_vPawnLocWhenKilled;
            vNewLocation.Z = Location.Z-10;
            if( FindSpot( vNewLocation) )
            {
                if(vNewLocation != Location)
                {
                    SetLocation( vNewLocation );
                    return true;
                }
            }
        }
    }

    return false;
}

//============================================================================
// function StopFallingAndSetCorrectRotation - 
//============================================================================
simulated function StopFallingAndSetCorrectRotation()
{
    #ifdefDEBUG if(bShowLog) log( name $ " StopFallingAndSetCorrectRotation" ); #endif

    SetPhysics(PHYS_Rotating);
    bBounce = false;
    bRotateToDesired = true;

    // Assure that the weapon stop in a correct rotation
    DesiredRotation.Yaw = Rotation.Yaw;
    if(Abs(Rotation.Roll-13384) > Abs(Rotation.Roll-49151))
        DesiredRotation.Roll = 49151;
    else
        DesiredRotation.Roll = 13384;

    if(DesiredRotation.Roll<Rotation.Roll)
        RotationRate = rot(0,0,-100000);
    else
        RotationRate = rot(0,0,100000);
}

//============================================================================
// function PutAtOwnerFeet - 
//============================================================================
simulated function PutAtOwnerFeet()
{
    SetLocation( m_vPawnLocWhenKilled, true );
    StopFallingAndSetCorrectRotation();
}

//============================================================================
// function StartFalling - 
//============================================================================
simulated function StartFalling()
{
    local vector  vLocation;
    local vector  vDir;
    local rotator rRot;

    if(Owner != none)
    {
        m_vPawnLocWhenKilled = Owner.Location;
        m_vPawnLocWhenKilled.Z -= Owner.CollisionHeight;
        Owner.DetachFromBone( Self );
    }
    else
    {
        m_vPawnLocWhenKilled = Location;
    }

    //Cancel emitters.
    m_iNbParticlesToCreate = 0;

    GotoState('');
    
    SetCollisionSize( 35, 5 );

    // Check if the weapon fits in the level
    vLocation = Location;

    // Keep the same pawn's lighting
    m_bLightingVisibility = true;

    if( FindSpot( vLocation) )
    {
        SetLocation( vLocation );
        SetCollision( true, false, false );
        bCollideWorld = true;
        bBounce = true;
        Enable('HitWall');

        setPhysics( PHYS_Falling );
       
        // Set acceleration in front of the pawn and add a little randomness
        vDir = vector(Rotation);
        vDir.X += RandRange(-0.40, 0.40);
        vDir.Y += RandRange(-0.40, 0.40);
        vDir *= RandRange(100,400);
        vDir.Z = -600;
        Acceleration = vDir;

        // Set rotation to random number, except for the pitch
        bFixedRotationDir = true;
        RotationRate.Pitch = 0;
        RotationRate.Yaw   = RandRange(-65535, 65535);
        RotationRate.Roll  = RandRange(-65535, 65535);

        rRot = Rotation;
        rRot.Pitch = 0;
        SetRotation( rRot );
    }
    else
        PutAtOwnerFeet();
}

function BOOL CanSwitchToWeapon()
{
    return true;
}

simulated event ShowWeaponParticules(EWeaponSound eWeaponSound)
{
    m_fTimeDisplayParticule = Level.TimeSeconds;
    switch(eWeaponSound)
    {
        case WSOUND_PlayEmptyMag:
        case WSOUND_PlayFireSingleShot:
            m_iNbParticlesToCreate = 1;
            break;
        case WSOUND_PlayFireThreeBurst:
            m_iNbParticlesToCreate = Min(3,m_iNbBulletsInWeapon);
            break;
        case WSOUND_PlayFireFullAuto:
            m_iNbParticlesToCreate = m_iNbBulletsInWeapon;
            break;
        default:
            m_iNbParticlesToCreate = 0;
            break;

    }

    #ifdefDEBUG if(bShowLog) log("WEAPON - "$self$" - ShowWeaponParticules | " $ m_iNbParticlesToCreate); #endif
}

function SetAccuracyOnHit()
{
    m_fEffectiveAccuracy = m_stAccuracyValues.fRunningAccuracy;
}

#ifdefDEBUG
simulated function DisplayWeaponDGBInfo()
{
    super.DisplayWeaponDGBInfo();
}

simulated function ShowInfo()
{
    super.ShowInfo();
    
    log("Controller.m_Pawn : "$R6PlayerController(R6Pawn(Owner).Controller).m_Pawn);
    log("Controller.Rotation : "$R6PlayerController(R6Pawn(Owner).Controller).Rotation);
    
    log("FPWeapon "$m_FPWeapon$" is in state : "$m_FPWeapon.GetStateName());
    log("FPHands "$m_FPHands$" is in state : "$m_FPHands.GetStateName());
    log("FPHands DT = "$m_FPHands.DrawType);
    log("ReloadingWeapon : "$R6Pawn(Owner).m_bReloadingWeapon);
    log("ChangingWeapon : "$R6Pawn(Owner).m_bChangingWeapon);      
    log("FiringState : "$R6Pawn(Owner).m_bIsFiringState);       
    log("PawnIsReloading : "$R6Pawn(Owner).m_bPawnIsReloading);     
    log("PawnIsChangingWeapon : "$R6Pawn(Owner).m_bPawnIsChangingWeapon);
    log("PawnWeaponTransition : "$R6Pawn(Owner).m_bWeaponTransition);
    log("PawnPostureTransition : "$R6Pawn(Owner).m_bPostureTransition);
    log("Pawn is using Hands : "$R6Pawn(Owner).m_ePlayerIsUsingHands);
    
    log("Lock : "$R6PlayerController(Pawn(Owner).controller).m_bLockWeaponActions);

    log("Pawn m_bPeekingLeft ......: " $ R6Pawn(Owner).m_bPeekingLeft$" : "$ R6Pawn(Owner).m_fPeekingGoal);
    log("Pawn m_fPeeking...........: " $ R6Pawn(Owner).m_fPeeking $ " / " $R6Pawn(Owner).C_fPeekMiddleMax );

    
    log("  ");
}
#endif

defaultproperties
{
     C_iMaxNbOfClips=20
     m_iClipCapacity=9999
     m_iNbOfClips=1
     m_bPlayLoopingSound=True
     m_fMuzzleVelocity=10000.000000
     m_fStablePercentage=0.500000
     m_fFireSoundRadius=700.000000
     m_fRateOfFire=0.100000
     m_fDisplayFOV=80.000000
     m_WeaponIcon=Texture'R6WeaponsIcons.Icons.IconTest'
     m_stAccuracyValues=(fBaseAccuracy=1.500000,fShuffleAccuracy=1.900000,fWalkingAccuracy=4.700000,fWalkingFastAccuracy=6.700000,fRunningAccuracy=11.500000,fReticuleTime=1.000000,fAccuracyChange=1.650000,fWeaponJump=3.310000)
     m_szWithWeaponReticuleClass="WITHWEAPON"
     m_ScopeAdd=Texture'Inventory_t.Scope.ScopeBlurTexAdd'
     m_CommonWeaponZoomSnd=Sound'CommonWeapons.Play_WeaponZoom'
     m_PawnWaitAnimLow="StandSubGunLow_nt"
     m_PawnWaitAnimHigh="StandSubGunHigh_nt"
     m_PawnWaitAnimProne="ProneSubGun_nt"
     m_PawnFiringAnim="StandFireSubGun"
     m_PawnFiringAnimProne="ProneFireSubGun"
     m_PawnReloadAnim="StandReloadSubGun"
     m_PawnReloadAnimTactical="StandTacReloadSubGun"
     m_PawnReloadAnimProne="ProneReloadSubGun"
     m_PawnReloadAnimProneTactical="ProneTacReloadSubGun"
     DrawType=DT_StaticMesh
     bReplicateInstigator=True
     bSkipActorPropertyReplication=True
     m_bForceBaseReplication=True
     m_bDeleteOnReset=True
     m_fSoundRadiusActivation=5600.000000
     StaticMesh=StaticMesh'R6Weapons.RedWeaponStaticMesh'
     DrawScale3D=(X=-1.000000,Y=-1.000000)
}
