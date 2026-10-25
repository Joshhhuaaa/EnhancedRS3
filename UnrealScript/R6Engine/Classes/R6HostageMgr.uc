class R6HostageMgr extends R6AbstractHostageMgr;

//------------------------------------------------------------------
// Threat & Reaction 
//------------------------------------------------------------------

enum EThreatType
{
    THREAT_none,        // do nothing
    THREAT_friend,      // is a friend and alive
    THREAT_sound,
    THREAT_surrender,
    THREAT_enemy,
    THREAT_underFire,
    THREAT_neutral,
    THREAT_misc
};


struct ThreatDefinition
{
    //todop: optimize loop search by using the groupname and exiting if no longer in the groupd
    var name          m_groupName;          // Civ / Freed / Guarded 
    var string        m_szName;             // "a rainbow"
    var EThreatType   m_eThreatType;        // THREAT_rainbow
    var ENoiseType    m_eNoiseType;         // NOISE_Grenade
    var INT           m_iThreatLevel;       // 0: no level... 
    var INT           m_iCaringDistance;    // distance to start to care about this threat
    var name          m_considerThreat;     // extra check for this threat. handle exception for a threat, if == none, yes.
};


struct ThreatInfo
{
    // **** if modified, update this struct in r6engine.h ****
    var INT           m_id;                 // index in m_aThreatDefinition
    var INT           m_iThreatLevel;       // directly copied from ThreatDefinition for quick access
    var Pawn          m_pawn;               // the actor
    var Actor         m_actorExt;           // the actor extention; ie like his grenade
    var INT           m_bornTime;           // born time
    var vector        m_originalLocation;   // original location
    var name          m_state;
    // **** if modified, update this struct in r6engine.h ****
};

var const INT         c_iSurrenderRadius;          // the hostage should surrender when they are X meter from Pawn
var const INT         c_iDetectUnderFireRadius;    // the hostage consider being under fire when in this radius
var const INT         c_iDetectThreatSound;     // distance from a sound that he react...
var const INT         c_iDetectGrenadeRadius;

var const name        c_ThreatGroup_Civ;
var const name        c_ThreatGroup_HstFreed;
var const name        c_ThreatGroup_HstGuarded;
var const name        c_ThreatGroup_HstBait;
var const name        c_ThreatGroup_HstEscorted;

var const INT         c_ThreatLevel_Surrender;

struct ReactionInfo
{
    var name    m_groupName; // same one used for ThreatDefinition
    var INT     m_iThreatLevel;
    var INT     m_iChance;
    var name    m_gotoState;
};

var  name                           m_noReactionName;


//------------------------------------------------------------------
//	Civilian / Hostage Sound Event
//------------------------------------------------------------------
const HSTSNDEvent_None                      = 0;
const HSTSNDEvent_HearShooting              = 1;
const HSTSNDEvent_CivSurrender              = 2;    // Civilian or Freed Hostage
const HSTSNDEvent_RunForCover               = 3;    // civilian or hostage
const HSTSNDEvent_CivRunTowardRainbow       = 4;    // Civilian or Freed Hostage
const HSTSNDEvent_HstRunTowardRainbow       = 5;  // Guarded Hostage
const HSTSNDEvent_SeeRainbowBaitOrGoFrozen  = 6;
const HSTSNDEvent_GoFoetal                  = 7;
const HSTSNDEvent_FollowRainbow             = 8;
const HSTSNDEvent_AskedToStayPut            = 9;
const HSTSNDEvent_InjuredByRainbow          = 10;
const HSTSNDEvent_Max                       = 11;

struct HstSndEventInfo 
{
    var int                          m_iHstSndEvent;
    var R6Pawn.EHostagePersonality   m_ePerso;
    var R6Pawn.EHostageVoices        m_eVoice;
};


var HstSndEventInfo         m_aHstSndEventInfo[24];

//------------------------------------------------------------------
//	Animation
//------------------------------------------------------------------
var INT ANIM_eBlinded;
var INT ANIM_eCrouchToProne; 
var INT ANIM_eCrouchToScaredStand;
var INT ANIM_eCrouchWait01; 
var INT ANIM_eCrouchWait02;     
var INT ANIM_eCrouchWalkBack;
var INT ANIM_eFoetusToCrouch;
var INT ANIM_eFoetusToKneel;
var INT ANIM_eFoetusToProne;
var INT ANIM_eFoetusToStand;
var INT ANIM_eFoetusWait01;
var INT ANIM_eFoetusWait02;
var INT ANIM_eFoetus_nt;
var INT ANIM_eGazed;
var INT ANIM_eKneelFreeze;
var INT ANIM_eKneelReact01;
var INT ANIM_eKneelReact02;
var INT ANIM_eKneelReact03;
var INT ANIM_eKneelToCrouch;
var INT ANIM_eKneelToFoetus;
var INT ANIM_eKneelToProne;
var INT ANIM_eKneelToStand;
var INT ANIM_eKneelWait01;	
var INT ANIM_eKneelWait02;	
var INT ANIM_eKneelWait03;	
var INT ANIM_eKneel_nt;	
var INT ANIM_eScaredStandWait01;
var INT ANIM_eScaredStandWait02;
var INT ANIM_eScaredStand_nt;
var INT ANIM_eStandHandUpFreeze;
var INT ANIM_eStandHandUpReact01;
var INT ANIM_eStandHandUpReact02;
var INT ANIM_eStandHandUpReact03;
var INT ANIM_eStandHandUpToDown;
var INT ANIM_eStandHandDownToUp;
var INT ANIM_eStandHandUpWait01;
var INT ANIM_eStandToFoetus;
var INT ANIM_eStandToKneel;
var INT ANIM_eStandWaitCough;
var INT ANIM_eStandWaitShiftWeight;
var INT ANIM_eProneToCrouch;
var INT ANIM_eProneWaitBreathe;
var INT ANIM_eMAX; // ** last one **

enum EPlayAnimType
{
    ePlayType_Default,  // play the anim like specified by his rate
    ePlayType_Random    // play the anim normal or in reverse
};

enum EGroupAnimType
{
    eGroupAnim_none,
    eGroupAnim_transition,
    eGroupAnim_wait,
    eGroupAnim_reaction
};

struct AnimInfo
{
    var name            m_name;         // name of the anim
    var INT             m_id;           // index in the array of m_aAnimInfo
    var float           m_fRate;        // the rate to play the anim
    var EPlayAnimType   m_ePlayType;    // play the anim normal or in reverse
    var EGroupAnimType  m_eGroupAnim;
};

var AnimInfo                m_aAnimInfo[40];

var bool                    bShowLog; 

var       INT               m_iThreatDefinitionIndex;
var       ThreatDefinition  m_aThreatDefinition[27];

var INT                     m_iReactionIndex;
var ReactionInfo            m_aReactions[24];

struct AnimTransInfo
{
    // **** if modified, update this struct in r6engine.h ****
    var name  m_AIState;
    var name  m_pawnState;
    var name  m_sourceAnimName;
    var INT   m_iSourceAnim;
    var name  m_targetAnimName;
    var INT   m_iTargetAnim;
    var float m_fTime;
    var float m_fTargetAnimRate;
    // **** if modified, update this struct in r6engine.h ****
};

enum EAnimTransType 
{
    eAnimTrans_none,
    eAnimTrans_animTransInfo,      // defined has a animation transition info
    eAnimTrans_groupTransition,    // the animation is of group sequence 'Transition'
    eAnimTrans_manual              // manually set to blend with what is playing right now
};

var INT                     m_iAnimTransIndex;
var AnimTransInfo           m_aAnimTransInfo[32];


//============================================================================
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//============================================================================
function logX( string szText, OPTIONAL int iSource )
{
    local string szSource;
	local string time;

    time = string(Level.TimeSeconds);
	time = Left(Time, InStr(Time, ".") + 3); // 2 digits after the dot
    
    szSource = "(" $time$ ":X) "; 

    log( szSource $ name $ "" $ szText );
}
//------------------------------------------------------------------
// InsertAnimTransInfo
//	
//------------------------------------------------------------------
function InsertAnimTransInfo( INT iSourceAnim, INT iTargetAnim, name pawnState, float fTime )
{
    if ( m_iAnimTransIndex >= ArrayCount(m_aAnimTransInfo) ) 
    {
        assert( false );
    }
    
    m_aAnimTransInfo[ m_iAnimTransIndex ].m_fTime            = fTime;
    m_aAnimTransInfo[ m_iAnimTransIndex ].m_pawnState        = pawnState;
    m_aAnimTransInfo[ m_iAnimTransIndex ].m_iSourceAnim      = iSourceAnim;
    m_aAnimTransInfo[ m_iAnimTransIndex ].m_sourceAnimName   = GetAnimInfo( iSourceAnim ).m_name;
    m_aAnimTransInfo[ m_iAnimTransIndex ].m_iTargetAnim      = iTargetAnim;
    m_aAnimTransInfo[ m_iAnimTransIndex ].m_targetAnimName   = GetAnimInfo( iTargetAnim ).m_name;
    m_aAnimTransInfo[ m_iAnimTransIndex ].m_fTargetAnimRate  = GetAnimInfo( iTargetAnim ).m_fRate;
    
    m_iAnimTransIndex++;
}

function string GetAnimTransInfoLog( AnimTransInfo info, OPTIONAL EAnimTransType eType )
{
    local string szLog;
    local string szType;

    
    if ( eType == eAnimTrans_animTransInfo )
    {
        szType = "data";
    }
    else if ( eType == eAnimTrans_groupTransition )
    {
        szType = "group";
    }
    else if ( eType == eAnimTrans_manual )
    {
        szType = "manual";
    }
    else
    {
        szType = "none";
    }

    szLog = "AnimTransType: "$szType$" src: "$info.m_sourceAnimName$" target: "$info.m_targetAnimName$" time: "$info.m_fTime$" rate: "$info.m_fTargetAnimRate$" toAIstate: "$info.m_aiState$" toPawnState: "$info.m_pawnState;

    return szLog;
}

//------------------------------------------------------------------
// GetAnimTransInfo: get the animTransiitionInfo for this source
//	and target, and it fills info. If not found return false
//------------------------------------------------------------------
function bool GetAnimTransInfo( name sourceAnimName, INT iTargetAnim, OUT AnimTransInfo info )
{
    local INT i;

    for ( i = 0; i < m_iAnimTransIndex; i++ )
    {
        if ( sourceAnimName == m_aAnimTransInfo[ i ].m_sourceAnimName &&
             iTargetAnim    == m_aAnimTransInfo[ i ].m_iTargetAnim )
        {
            info = m_aAnimTransInfo[ i ];
            return true;
        }
    }

    return false;
}

//------------------------------------------------------------------
// GetAnimInfo: workaround for "variable name is too long"
//	
//------------------------------------------------------------------
function AnimInfo GetAnimInfo( INT id ) 
{ 
    return m_aAnimInfo[id];
}

//------------------------------------------------------------------
// GetAnimIndex
//	
//------------------------------------------------------------------
function INT GetAnimIndex( name animName )
{
    local INT i;

    for ( i = 0; i < ArrayCount( m_aAnimInfo ); i++ )
    {
        if ( m_aAnimInfo[i].m_name == animName )
        {
            return i;        
        }
    }

    return 0;
}

//------------------------------------------------------------------
// GetAnimInfoSize: workaround for "variable name is too long"
//	
//------------------------------------------------------------------
function INT GetAnimInfoSize() 
{ 
    return ArrayCount(m_aAnimInfo);
}

//------------------------------------------------------------------
// InsertAnimInfo: insert an anim in m_aAnimInfo and sets all his
//	properties
//------------------------------------------------------------------
function InsertAnimInfo( name aName, OUT INT id, OPTIONAL EGroupAnimType eGroupAnim, OPTIONAL EPlayAnimType ePlayType, OPTIONAL float fRate )
{
    id = ANIM_eMAX; 
    ANIM_eMAX++;

    if ( fRate == 0 )
    {
        frate = 1; // set default
    }

    if ( m_aAnimInfo[ id ].m_name != '' )
    {
        log("ScriptWarning: Hostage anim " @aName@ " was not inserted. Conflict with " @m_aAnimInfo[id].m_name@ " at index " $id );
        return;
    }

    m_aAnimInfo[ id ].m_id          = id;
    m_aAnimInfo[ id ].m_name        = aName;
    m_aAnimInfo[ id ].m_fRate       = fRate;
    m_aAnimInfo[ id ].m_ePlayType   = ePlayType;
    m_aAnimInfo[ id ].m_eGroupAnim  = eGroupAnim;
}

//------------------------------------------------------------------
// ValidAnimInfo: do some validation of all animInfo. Called after the
//	last insertAnimInfo
//------------------------------------------------------------------
function ValidAnimInfo()
{
    local INT       i;
    local INT       j;
    local string    playType;
    if ( ArrayCount(m_aAnimInfo) != ANIM_eMAX )
    {
        log( "ScriptWarning: m_aAnimInfo wrong size. Array size is " @ArrayCount(m_aAnimInfo)@ " and ANIM_eMAX is " $ANIM_eMAX );
    }

    for ( i = 0; i < ArrayCount( m_aAnimInfo ); i++ )
    {
        // if none, it's wrong
        if ( m_aAnimInfo[i].m_name == '' )
        {
            log( "ScriptWarning: missing anim index: " $i );
        }
        else
        {
            if ( m_aAnimInfo[i].m_ePlayType == ePlayType_Random )
            {
                playType = "random";
            }
            else
            {
                playType = "default";
            }

            // list all anim
            #ifdefDEBUG if(bShowLog) log( "ANIM: " @m_aAnimInfo[i].m_name@ " index: "$m_aAnimInfo[i].m_id$ " playType: "$playType ); #endif
        }
    }

    // look for double
    for ( i = 0; i < ArrayCount( m_aAnimInfo ); i++ )
    {
        // skip if nothing
        if ( m_aAnimInfo[i].m_name == '' )
            continue;

        for ( j = 0; j < ArrayCount( m_aAnimInfo ); j++ )
        {
            // skip if the same index
            if ( i == j )
                continue;

            // same name
            if ( m_aAnimInfo[i].m_name == m_aAnimInfo[j].m_name )
            {
                // same rate
                if ( m_aAnimInfo[i].m_fRate == m_aAnimInfo[j].m_fRate )
                {
                    log ( "ScriptWarning: identical anim at index: " @i@ " and " $j );
                }
            }
        }
    }
}

//------------------------------------------------------------------
// PostBeginPlay: init and valid data for the manager
//	
//------------------------------------------------------------------
function PostBeginPlay()
{
    m_noReactionName = 'HostageMgrNone';

    InitSndEventInfo();
    InitThreatDefinition();
    if ( Level.m_bIsClassicMission )
        InitReactionForClassicMissionCivilian();
    else
        InitReaction();

    //------------------------------------------------------------------    
    InsertAnimInfo( 'Blinded',                  ANIM_eBlinded );
    InsertAnimInfo( 'CrouchToProne',            ANIM_eCrouchToProne,      eGroupAnim_transition );
    InsertAnimInfo( 'CrouchToScaredStand',      ANIM_eCrouchToScaredStand,eGroupAnim_transition );
    InsertAnimInfo( 'CrouchWait01',             ANIM_eCrouchWait01,       eGroupAnim_wait,      ePlayType_Random );
    InsertAnimInfo( 'CrouchWait02',             ANIM_eCrouchWait02,       eGroupAnim_wait );
    InsertAnimInfo( 'FoetusToCrouch',		    ANIM_eFoetusToCrouch,     eGroupAnim_transition );
    InsertAnimInfo( 'FoetusToKneel',		    ANIM_eFoetusToKneel,      eGroupAnim_transition );
    InsertAnimInfo( 'FoetusToProne',		    ANIM_eFoetusToProne,      eGroupAnim_transition );
    InsertAnimInfo( 'FoetusToStand',		    ANIM_eFoetusToStand,      eGroupAnim_transition );
    InsertAnimInfo( 'FoetusWait01',			    ANIM_eFoetusWait01,       eGroupAnim_wait, ePlayType_Random );
    InsertAnimInfo( 'FoetusWait02',			    ANIM_eFoetusWait02,       eGroupAnim_wait, ePlayType_Random );
    InsertAnimInfo( 'Foetus_nt',			    ANIM_eFoetus_nt );
    InsertAnimInfo( 'Gazed',			        ANIM_eGazed );
    InsertAnimInfo( 'KneelFreeze',			    ANIM_eKneelFreeze,,                          ePlayType_Random);
    InsertAnimInfo( 'KneelReact01',			    ANIM_eKneelReact01,     eGroupAnim_reaction, ePlayType_Random );
    InsertAnimInfo( 'KneelReact02',			    ANIM_eKneelReact02,     eGroupAnim_reaction, ePlayType_Random );
    InsertAnimInfo( 'KneelReact03',			    ANIM_eKneelReact03,     eGroupAnim_reaction, ePlayType_Random );
    InsertAnimInfo( 'KneelToCrouch',			ANIM_eKneelToCrouch,    eGroupAnim_transition );
    InsertAnimInfo( 'KneelToFoetus',		    ANIM_eKneelToFoetus,    eGroupAnim_transition );
    InsertAnimInfo( 'KneelToProne',			    ANIM_eKneelToProne,     eGroupAnim_transition );
    InsertAnimInfo( 'KneelToStand',			    ANIM_eKneelToStand,     eGroupAnim_transition );
    InsertAnimInfo( 'KneelWait01',			    ANIM_eKneelWait01,      eGroupAnim_wait, ePlayType_Random );
    InsertAnimInfo( 'KneelWait02',			    ANIM_eKneelWait02,      eGroupAnim_wait, ePlayType_Random );
    InsertAnimInfo( 'KneelWait03',			    ANIM_eKneelWait03,      eGroupAnim_wait, ePlayType_Random );
    InsertAnimInfo( 'Kneel_nt',				    ANIM_eKneel_nt );
    InsertAnimInfo( 'ScaredStandWait01',	    ANIM_eScaredStandWait01,    eGroupAnim_wait, ePlayType_Random);
    InsertAnimInfo( 'ScaredStandWait02',	    ANIM_eScaredStandWait02,    eGroupAnim_wait, ePlayType_Random);      
    InsertAnimInfo( 'StandHandUpFreeze',	    ANIM_eStandHandUpFreeze,                   , ePlayType_Random );
    InsertAnimInfo( 'StandHandUpReact01',	    ANIM_eStandHandUpReact01,   eGroupAnim_reaction,    ePlayType_Random );
    InsertAnimInfo( 'StandHandUpReact02',	    ANIM_eStandHandUpReact02,   eGroupAnim_reaction,    ePlayType_Random );
    InsertAnimInfo( 'StandHandUpReact03',	    ANIM_eStandHandUpReact03,   eGroupAnim_reaction,    ePlayType_Random );
    InsertAnimInfo( 'StandHandUpToDown',	    ANIM_eStandHandUpToDown,    eGroupAnim_transition );
    InsertAnimInfo( 'StandHandDownToUp',	    ANIM_eStandHandDownToUp,    eGroupAnim_transition ); 
    InsertAnimInfo( 'StandHandUpWait01',	    ANIM_eStandHandUpWait01,    eGroupAnim_wait,        ePlayType_Random );
    InsertAnimInfo( 'StandToFoetus',		    ANIM_eStandToFoetus,        eGroupAnim_transition );
    InsertAnimInfo( 'StandToKneel',			    ANIM_eStandToKneel,         eGroupAnim_transition  );
    InsertAnimInfo( 'StandWaitCough',		    ANIM_eStandWaitCough,       eGroupAnim_wait );
    InsertAnimInfo( 'StandWaitShiftWeight',	    ANIM_eStandWaitShiftWeight, eGroupAnim_wait,        ePlayType_Random );
    InsertAnimInfo( 'ProneToCrouch',			ANIM_eProneToCrouch,        eGroupAnim_transition );
    InsertAnimInfo( 'ProneWaitBreathe',			ANIM_eProneWaitBreathe,     eGroupAnim_wait  ); 
        
    ValidAnimInfo();
}

//------------------------------------------------------------------
// InsertThreatDefinition
//	
//------------------------------------------------------------------
function InsertThreatDefinition( name        groupName,
                                 string      szName, 
                                 EThreatType eThreatType, 
                                 ENoiseType  eNoiseType,
                                 INT         iThreatLevel,
                                 INT         iCaringDistance,
                                 OPTIONAL name considerThreat )
{
    assert( m_iThreatDefinitionIndex < ArrayCount(m_aThreatDefinition) );

    // check that all level are inserted in the right order after the second element
    if ( m_iThreatDefinitionIndex > 1 )
    {
        if ( m_aThreatDefinition[ m_iThreatDefinitionIndex-1 ].m_iThreatLevel < iThreatLevel
             && m_aThreatDefinition[ m_iThreatDefinitionIndex-1 ].m_groupName == groupName )
        {
            log("ScriptWarning: InsertThreatDefinition wrong ThreatLevel for " $szName );
        }
    }

    m_aThreatDefinition[ m_iThreatDefinitionIndex ].m_groupName       = groupName;
    m_aThreatDefinition[ m_iThreatDefinitionIndex ].m_szName          = szName;
    m_aThreatDefinition[ m_iThreatDefinitionIndex ].m_eThreatType     = eThreatType;
    m_aThreatDefinition[ m_iThreatDefinitionIndex ].m_eNoiseType      = eNoiseType;
    m_aThreatDefinition[ m_iThreatDefinitionIndex ].m_iThreatLevel    = iThreatLevel;
    m_aThreatDefinition[ m_iThreatDefinitionIndex ].m_iCaringDistance = iCaringDistance;
    m_aThreatDefinition[ m_iThreatDefinitionIndex ].m_considerThreat  = considerThreat;
        
    m_iThreatDefinitionIndex++; 
}

//------------------------------------------------------------------
// GetThreatInfoLog: 
//	
//------------------------------------------------------------------
function string GetThreatInfoLog( ThreatInfo info )
{
    local string    szOutput;
    local name      pawnName;
    local name      actorName;
    local int       index;

    index = Clamp( info.m_id, 0, info.m_id );

    if ( info.m_pawn == none )
    {
        pawnName = ' ';
    }
    else
    {
        pawnName = info.m_pawn.name;
    }

    if ( info.m_actorExt == none )
    {
        actorName = ' ';
    }
    else
    {
        actorName = info.m_actorExt.name;
    }

    szOutput = "" $m_aThreatDefinition[index].m_groupName$ ": "$GetThreatName(index)$", a:"$actorName$" "$info.m_iThreatLevel$ "s:" $info.m_state$ " a2:"$actorName;

    return szOutput;
}

//------------------------------------------------------------------
// GetThreatDefinition:  
//	
//------------------------------------------------------------------
function GetThreatDefinition( INT index, OUT ThreatDefinition oDefinition )
{
    oDefinition = m_aThreatDefinition[index];
}

//------------------------------------------------------------------
// getDefaulThreatInfo
//	
//------------------------------------------------------------------
function ThreatInfo getDefaulThreatInfo()
{
    local ThreatInfo info;
    
    info.m_bornTime         = 0;
    info.m_id               = 0;
    info.m_originalLocation = vect(0,0,0);
    info.m_pawn             = none;
    info.m_iThreatLevel     = 0;
    info.m_state            = '';
        
    return info;
}

//------------------------------------------------------------------
// GetThreatName
//------------------------------------------------------------------
function string GetThreatName( INT index )
{
    return m_aThreatDefinition[index].m_szName;
}


//------------------------------------------------------------------
// GetThreatInfoFromThreat: return the ThreatInfo associated with
//	the current info of threat based on the highest level of
//  of the threat (ie: the more dangerous to the civilian)
//------------------------------------------------------------------
function bool GetThreatInfoFromThreat( name             threatGroupName, 
                                       R6Hostage        hostage,           
                                       Actor            threat, 
                                       ENoiseType       eType, 
                                       OUT ThreatInfo   oThreatInfo )
{
    local bool          bRealThreat;
    local INT           i;
    local vector        vDistance;
    local name          threatClass;
    local bool          bCheckDistance;
    local R6Pawn        aPawn;
    
    #ifdefDEBUG  
    if ( bShowLog )
    {
        if ( eType != NOISE_None ) 
            hostage.logX( "THREAT: " $threat.name$ " sound: " $eType$ " source: " $threat.Instigator.name );
        else
            hostage.logX( "THREAT: " $threat.name );
    }
    #endif

    bRealThreat = false;    

    if ( eType != NOISE_None )  // the threat is a noise, made by this pawn
        aPawn = r6Pawn(threat.Instigator);
    else
        aPawn = r6Pawn(threat);

    // always start at 1, 0 is the default NOTHREAT
    for ( i = 1; i < ArrayCount( m_aThreatDefinition ); ++i )
    {
        bCheckDistance = false;
        if ( m_aThreatDefinition[i].m_groupName != threatGroupName )
        {
            continue;
        }
        else if ( eType != NOISE_None ) // noise
        {
            if ( m_aThreatDefinition[i].m_eNoiseType == eType  )
            {
                bCheckDistance = true;
            }
        }
        else if ( aPawn != none )    // pawn
        {
            if ( m_aThreatDefinition[i].m_eThreatType == THREAT_enemy )
            {
                if ( hostage.isEnemy( aPawn ) && aPawn.isAlive() && !aPawn.m_bIsKneeling )
                    bCheckDistance = true;
            }
            else if ( m_aThreatDefinition[i].m_eThreatType == THREAT_friend )
            {
                if ( hostage.isFriend( aPawn ) && aPawn.isAlive() )
                    bCheckDistance = true;
            }
            else if ( m_aThreatDefinition[i].m_eThreatType == THREAT_neutral )
            {
                if ( hostage.isNeutral( aPawn ) && aPawn.isAlive() )
                    bCheckDistance = true;
            }
        }

        if ( bCheckDistance )
        {
            // check distance: MAX distance or in the range
            if ( m_aThreatDefinition[i].m_iCaringDistance == MAXINT ||
                 VSize( hostage.location - threat.location ) <= m_aThreatDefinition[i].m_iCaringDistance  )
            {
                // check if needs an extra check 
                if ( m_aThreatDefinition[i].m_considerThreat != '' )
                {
                    if ( hostage.m_controller.CanConsiderThreat( aPawn, threat, m_aThreatDefinition[i].m_considerThreat ) )
                    {
                        bRealThreat = true;
                        break;
                    }
                }
                else
                {
                    bRealThreat = true;
                    break;
                }
            }
        }
    }

    // real threat, set the value of ThreatInfo
    if ( bRealThreat )
    {
        oThreatInfo.m_id               = i;
        oThreatInfo.m_bornTime         = Level.TimeSeconds;
        oThreatInfo.m_originalLocation = threat.location;
        oThreatInfo.m_iThreatLevel     = m_aThreatDefinition[i].m_iThreatLevel;
        
        if ( eType != NOISE_None )
        {
            oThreatInfo.m_pawn            = aPawn;
            
            // exception for grenade
            if ( m_aThreatDefinition[i].m_eNoiseType == NOISE_Grenade )
            {
                oThreatInfo.m_actorExt    = threat;
            }
        }
        else
        {
            oThreatInfo.m_pawn            = aPawn;
        }

        #ifdefDEBUG if(bShowLog) hostage.logX( "threatInfo: " $GetThreatInfoLog( oThreatInfo ) ); #endif
    }
    else
    {
        oThreatInfo.m_id = 0;
    }

    return bRealThreat;
}

//------------------------------------------------------------------
// GetThreatInfoFromThreatSurrender
//	
//------------------------------------------------------------------
function GetThreatInfoFromThreatSurrender( Pawn threat, OUT ThreatInfo oThreatInfo )
{
    oThreatInfo.m_id               = -1; // not in the index should be 2
    oThreatInfo.m_bornTime         = Level.TimeSeconds;
    oThreatInfo.m_originalLocation = threat.location;
    oThreatInfo.m_iThreatLevel     = c_ThreatLevel_Surrender;
    oThreatInfo.m_pawn             = threat;
    oThreatInfo.m_actorExt         = none;
    oThreatInfo.m_state            = '';
}

//------------------------------------------------------------------
// InsertReaction
//	
//------------------------------------------------------------------
function InsertReaction( name groupName, INT iLevel, INT iRoll, name stateName )
{
    assert( m_iReactionIndex < ArrayCount(m_aReactions) );

    m_aReactions[ m_iReactionIndex ].m_groupName      = groupName;
    m_aReactions[ m_iReactionIndex ].m_iThreatLevel   = iLevel;
    m_aReactions[ m_iReactionIndex ].m_iChance        = iRoll;
    m_aReactions[ m_iReactionIndex ].m_gotoState      = stateName;

    m_iReactionIndex++;
}


//------------------------------------------------------------------
// InitThreatDefinition: insert all the threat definition in an array
//	
//------------------------------------------------------------------
function InitThreatDefinition()
{
    local string        szName;
    local EThreatType   eThreatType;
    local name          groupName;
    local INT           i, iNoiseType, iCaringDistance, iThreatLevel;

    // important: first element must be no threat
    InsertThreatDefinition( c_ThreatGroup_Civ, "no threat",    THREAT_none,        NOISE_None,    0,                       0 );
    
    // sorted: highest importance  to lowest

    InsertThreatDefinition( c_ThreatGroup_Civ, "2m of enemy",  THREAT_enemy,       NOISE_None,    6,                       c_iSurrenderRadius );
    InsertThreatDefinition( c_ThreatGroup_Civ, "surrender",    THREAT_surrender,   NOISE_None,    c_ThreatLevel_Surrender, 0 );     
    InsertThreatDefinition( c_ThreatGroup_Civ, "near grenade", THREAT_underFire,   NOISE_Grenade, 4,                       c_iDetectGrenadeRadius );
    InsertThreatDefinition( c_ThreatGroup_Civ, "under fire",   THREAT_underFire,   NOISE_Threat,  4,                       c_iDetectUnderFireRadius ); 
    InsertThreatDefinition( c_ThreatGroup_Civ, "see enemy",    THREAT_enemy,       NOISE_None,    3,                       MAXINT );
    InsertThreatDefinition( c_ThreatGroup_Civ, "see friend",   THREAT_friend,      NOISE_None,    2,                       MAXINT );
    InsertThreatDefinition( c_ThreatGroup_Civ, "hear sound",   THREAT_sound,       NOISE_Threat,  1,                       MAXINT );
    InsertThreatDefinition( c_ThreatGroup_Civ, "hear sound",   THREAT_sound,       NOISE_Grenade, 1,                       MAXINT );
    InsertThreatDefinition( c_ThreatGroup_Civ, "hear sound",   THREAT_underFire,   NOISE_Investigate, 4,                   MAXINT );

    InsertThreatDefinition( c_ThreatGroup_HstEscorted, "hear sound",    THREAT_sound,       NOISE_Threat,  1, MAXINT, 'IsEnemySound' );
    InsertThreatDefinition( c_ThreatGroup_HstEscorted, "hear sound",    THREAT_sound,       NOISE_Grenade, 1, MAXINT, 'IsEnemySound' );
    InsertThreatDefinition( c_ThreatGroup_HstEscorted, "hear sound",    THREAT_sound,       NOISE_Dead,    1, MAXINT, 'IsEnemySound' );

    //InsertThreatDefinition( c_ThreatGroup_Civ, "surrender",    THREAT_surrender,   NOISE_None,    c_ThreatLevel_Surrender, 0 );     
    InsertThreatDefinition( c_ThreatGroup_HstFreed, "near grenade",  THREAT_underFire,   NOISE_Grenade, 4, c_iDetectGrenadeRadius );
    InsertThreatDefinition( c_ThreatGroup_HstFreed, "see enemy",     THREAT_enemy,       NOISE_None,    3, MAXINT );
    InsertThreatDefinition( c_ThreatGroup_HstFreed, "see friend",    THREAT_friend,      NOISE_None,    2, MAXINT,  'CanSeeFriend' );
    InsertThreatDefinition( c_ThreatGroup_HstFreed, "hear sound",    THREAT_sound,       NOISE_Threat,  1, MAXINT );
    InsertThreatDefinition( c_ThreatGroup_HstFreed, "hear sound",    THREAT_sound,       NOISE_Grenade, 1, MAXINT );
    InsertThreatDefinition( c_ThreatGroup_HstFreed, "hear sound",    THREAT_sound,       NOISE_Dead,    1, MAXINT );

    //InsertThreatDefinition( c_ThreatGroup_Civ, "surrender",    THREAT_surrender,   NOISE_None,    c_ThreatLevel_Surrender, 0 );     
    InsertThreatDefinition( c_ThreatGroup_HstGuarded, "near grenade",  THREAT_underFire,   NOISE_Grenade, 3, c_iDetectGrenadeRadius );
    InsertThreatDefinition( c_ThreatGroup_HstGuarded, "see friend",    THREAT_friend,      NOISE_None,    2, MAXINT, 'CanSeeFriend' );
    InsertThreatDefinition( c_ThreatGroup_HstGuarded, "hear sound",    THREAT_sound,       NOISE_Dead,    1, MAXINT );
    InsertThreatDefinition( c_ThreatGroup_HstGuarded, "hear sound",    THREAT_sound,       NOISE_Threat,  1, MAXINT );

    InsertThreatDefinition( c_ThreatGroup_HstBait, "near grenade", THREAT_underFire,   NOISE_Grenade, 2, c_iDetectGrenadeRadius );
    InsertThreatDefinition( c_ThreatGroup_HstBait, "see friend",   THREAT_friend,      NOISE_None,    1, MAXINT );
    InsertThreatDefinition( c_ThreatGroup_HstBait, "hear sound",   THREAT_sound,       NOISE_Threat,  1, MAXINT );
    InsertThreatDefinition( c_ThreatGroup_HstBait, "hear sound",   THREAT_sound,       NOISE_Dead,    1, MAXINT );

    // always the first element
    assert( m_aThreatDefinition[0].m_iThreatLevel == 0 ); 
    assert( m_iThreatDefinitionIndex == ArrayCount(m_aThreatDefinition) );


    #ifdefDEBUG if(bShowLog) 
    {
        log( "List of ThreatDefinition" );
        log( "threatLevel | debug name | distanceToCare | treatType | noiseType" );

        for ( i = 0; i < m_iThreatDefinitionIndex; ++i )
        {
            groupName       = m_aThreatDefinition[ i ].m_groupName;
            szName          = m_aThreatDefinition[ i ].m_szName;
            eThreatType     = m_aThreatDefinition[ i ].m_eThreatType;
            iNoiseType      = m_aThreatDefinition[ i ].m_eNoiseType;
            iThreatLevel    = m_aThreatDefinition[ i ].m_iThreatLevel; 
            iCaringDistance = m_aThreatDefinition[ i ].m_iCaringDistance;
            log( "  " @groupName$ ": " @iThreatLevel@ "|" @szName@ "|" @iCaringDistance@ "|" @eThreatType@ "|" $iNoiseType );
        }
    } #endif
}                          

//------------------------------------------------------------------
// InitReaction
//	
//------------------------------------------------------------------
function InitReaction()
{
    local R6Hostage     hostageDbg;
    local R6HostageAI   hostageAIDbg;
    local INT           i;

    // *** there's no validation, so be carefull when inserting element ***
    ///////////////////////////////////////////////////////////////////////////////////
    InsertReaction( c_ThreatGroup_Civ, 1,  33,  'CivRunForCover'       );
    InsertReaction( c_ThreatGroup_Civ, 1,  66,  'GoCivScareToDeath'    );
    InsertReaction( c_ThreatGroup_Civ, 1,  100, m_noReactionName       ); 
    InsertReaction( c_ThreatGroup_Civ, 2,  25,  'CivRunForCover'       );
    InsertReaction( c_ThreatGroup_Civ, 2,  50,  'GoCivScareToDeath'    );
    InsertReaction( c_ThreatGroup_Civ, 2,  100, 'CivRunTowardRainbow'  );
    InsertReaction( c_ThreatGroup_Civ, 3,  50,  'GoCivScareToDeath'    );
    InsertReaction( c_ThreatGroup_Civ, 3,  100, 'CivRunForCover'       );  
    InsertReaction( c_ThreatGroup_Civ, 4,  100, 'CivRunForCover'       );    
    InsertReaction( c_ThreatGroup_Civ, c_ThreatLevel_Surrender,  50,  'CivSurrender'   );    
    InsertReaction( c_ThreatGroup_Civ, c_ThreatLevel_Surrender,  100, 'CivRunForCover' );    
    InsertReaction( c_ThreatGroup_Civ, 6,  100, 'CivSurrender'         );    

    ///////////////////////////////////////////////////////////////////////////////////
    // hear noise
    InsertReaction( c_ThreatGroup_HstGuarded, 1,  100, 'GuardedPlayReaction'); // fire a function: react + noise
    // see a rainbow
    InsertReaction( c_ThreatGroup_HstGuarded, 2,  40,  'GoGuarded_foetus'   );    
    InsertReaction( c_ThreatGroup_HstGuarded, 2,  60,  'GoGuarded_frozen'   );    
    InsertReaction( c_ThreatGroup_HstGuarded, 2,  100, 'GoHstRunTowardRainbow'   );    
    // see grenade
    InsertReaction( c_ThreatGroup_HstGuarded, 3,  100, 'GoHstRunForCover' );    

    ///////////////////////////////////////////////////////////////////////////////////
    // Escorted
    InsertReaction( c_ThreatGroup_HstEscorted, 1,  100, 'HearShootingReaction' );

    ///////////////////////////////////////////////////////////////////////////////////
    // Freed
    InsertReaction( c_ThreatGroup_HstFreed, 1,  100, 'GoHstRunForCover' );        // hear threat sound
    InsertReaction( c_ThreatGroup_HstFreed, 2,  100, 'GoHstRunTowardRainbow' );   // see a friend
    InsertReaction( c_ThreatGroup_HstFreed, 3,  100, 'GoHstFreedButSeeEnemy' );      // see an enemy
    InsertReaction( c_ThreatGroup_HstFreed, 4,  100, 'GoHstRunForCover' );        // a grenade
    
    ///////////////////////////////////////////////////////////////////////////////////
    // hear / see friend
    InsertReaction( c_ThreatGroup_HstBait, 1,  100, 'BaitPlayReaction' );
    // see grenade
    InsertReaction( c_ThreatGroup_HstBait, 2,  100, 'GoHstRunForCover' ); 
    

    // should be same size
    assert( m_iReactionIndex == ArrayCount(m_aReactions) ); 
    #ifdefDEBUG  
    if(bShowLog) 
    {
        log( "** m_aReactions: " $m_iReactionIndex );
        log( "List of Reaction: group | level | roll | gotoState" );
        for ( i = 0; i < ArrayCount(m_aReactions); i++ )
        {
            log( "  " @m_aReactions[ i ].m_groupName@ "|" @m_aReactions[ i ].m_iThreatLevel@ "|" @m_aReactions[ i ].m_iChance@  "|" $m_aReactions[ i ].m_gotoState );
        }
    }
    #endif
}

function InitReactionForClassicMissionCivilian()
{
    local R6Hostage     hostageDbg;
    local R6HostageAI   hostageAIDbg;
    local INT           i;

    InsertReaction( c_ThreatGroup_Civ, 1,  33,  'm_noReactionName'     );
    InsertReaction( c_ThreatGroup_Civ, 1,  66,  'm_noReactionName'     );
    InsertReaction( c_ThreatGroup_Civ, 1,  100, m_noReactionName       ); 
    InsertReaction( c_ThreatGroup_Civ, 2,  25,  'm_noReactionName'     );
    InsertReaction( c_ThreatGroup_Civ, 2,  50,  'm_noReactionName'     );
    InsertReaction( c_ThreatGroup_Civ, 2,  100, 'm_noReactionName'     );
    InsertReaction( c_ThreatGroup_Civ, 3,  50,  'm_noReactionName'     );
    InsertReaction( c_ThreatGroup_Civ, 3,  100, 'm_noReactionName'     );  
    InsertReaction( c_ThreatGroup_Civ, 4,  100, 'CivRunForCover'       );    
    InsertReaction( c_ThreatGroup_Civ, c_ThreatLevel_Surrender,  50,  'm_noReactionName' );    
    InsertReaction( c_ThreatGroup_Civ, c_ThreatLevel_Surrender,  100, 'm_noReactionName' );    
    InsertReaction( c_ThreatGroup_Civ, 6,  100, 'm_noReactionName'     );    

    InsertReaction( c_ThreatGroup_HstGuarded, 1,  100, 'GuardedPlayReaction');
    InsertReaction( c_ThreatGroup_HstGuarded, 2,  40,  'GoGuarded_foetus'   );    
    InsertReaction( c_ThreatGroup_HstGuarded, 2,  60,  'GoGuarded_frozen'   );    
    InsertReaction( c_ThreatGroup_HstGuarded, 2,  100, 'GoHstRunTowardRainbow'   );    
    InsertReaction( c_ThreatGroup_HstGuarded, 3,  100, 'GoHstRunForCover' );    

    InsertReaction( c_ThreatGroup_HstEscorted, 1,  100, 'HearShootingReaction' );

    InsertReaction( c_ThreatGroup_HstFreed, 1,  100, 'GoHstRunForCover' );
    InsertReaction( c_ThreatGroup_HstFreed, 2,  100, 'GoHstRunTowardRainbow' );
    InsertReaction( c_ThreatGroup_HstFreed, 3,  100, 'GoHstFreedButSeeEnemy' );
    InsertReaction( c_ThreatGroup_HstFreed, 4,  100, 'GoHstRunForCover' );
    
    InsertReaction( c_ThreatGroup_HstBait, 1,  100, 'BaitPlayReaction' );
    InsertReaction( c_ThreatGroup_HstBait, 2,  100, 'GoHstRunForCover' ); 

    assert( m_iReactionIndex == ArrayCount(m_aReactions) ); 
}

//------------------------------------------------------------------
// GetReaction: return the state to go
//	if '' is return, do nothing
//------------------------------------------------------------------
function name GetReaction( name groupName, INT iLevel, INT iRoll )
{
    local INT   i;
    local bool  bFound;
    local name  stateName;

    bFound = false;
    for ( i = 0; i < ArrayCount(m_aReactions); i++ )
    {
        if ( m_aReactions[i].m_groupName == groupName )
        {
            if ( m_aReactions[i].m_iThreatLevel == iLevel )
            {
                if ( iRoll <= m_aReactions[ i ].m_iChance )
                {
                    bFound = true;
                    break;
                }
            }
            else if ( m_aReactions[i].m_iThreatLevel > iLevel )
            {
                break;
            }
        }
    }

    if ( bFound )
    {
        stateName = m_aReactions[ i ].m_gotoState;
    }
    else
    {
        stateName = m_noReactionName;
    }

    #ifdefDEBUG if(bShowLog) log( "GetReaction state:" @stateName@  "level:" @iLevel@ "roll:" @iRoll ); #endif

    return stateName;
}


//------------------------------------------------------------------
// ValidMgr: valid some data of manager. can be called only once
//	
//------------------------------------------------------------------
function ValidMgr( R6HostageAI ai )
{
    /*
    local name orgName;
    local INT  i;

    if ( !bDebug )
        return;

    orgName = ai.getStateName();

    ai = Spawn( class'R6HostageAI');   

    for ( i = 0; i < ArrayCount(m_aReactions); i++ )
    {
        ai.gotoState( m_aReactions[i].m_gotoState ); 
        if ( ai.getStateName() != m_aReactions[i].m_gotoState )
        {
            log( "ScriptWarning: InsertReaction unknown state name " $m_aReactions[i].m_gotoState );
        }
    }

    bDebug = false; // test only once
    ai.gotoState( orgName );

    */
}

//------------------------------------------------------------------
// GetHostageSndEventPlay
//	
//------------------------------------------------------------------
function R6Pawn.EHostageVoices GetHostageVoices( INT index )
{
    return m_aHstSndEventInfo[index].m_eVoice;
}

//------------------------------------------------------------------
// GetHostageSndEvent: depending of the snd event and the perso.
// Exception when hostage sees Rainbow but is also close to Terrorist,
// the personnality is not used
//------------------------------------------------------------------
function int GetHostageSndEvent( int iSndEvent, R6Hostage h )
{
    local R6Pawn.EHostagePersonality ePerso;
    local int   i;
    local bool  bFound;

    ePerso = h.m_ePersonality;
    
    // if bait, act like a coward
    if ( ePerso == HPERSO_Bait )
    {
        ePerso = HPERSO_Coward;
    }

    // loop throu all event
    for ( i = 0; i < ArrayCount(m_aHstSndEventInfo); i++ )
    {
        // find the snd event
        if ( m_aHstSndEventInfo[i].m_iHstSndEvent == iSndEvent )
        {
            bFound = true;
            break;
        }
    }

    // failed... wrong
    if ( !bFound )
        return 0;
    
    return i;
}

//------------------------------------------------------------------
// InsertSndEventInfo
//	
//------------------------------------------------------------------
function InsertSndEventInfo( int index, int iSndEvent, R6Pawn.EHostagePersonality ePerso, R6Pawn.EHostageVoices eVoice )
{
    local name a;

    m_aHstSndEventInfo[ index ].m_iHstSndEvent  = iSndEvent;
    m_aHstSndEventInfo[ index ].m_ePerso        = ePerso;
    m_aHstSndEventInfo[ index ].m_eVoice       = eVoice;
}

//------------------------------------------------------------------
// InitSndEventInfo
//	
//------------------------------------------------------------------
function InitSndEventInfo()
{
    local int index;
    
    InsertSndEventInfo( index++, HSTSNDEvent_HearShooting,              HPERSO_None,    HV_Hears_Shooting );  
    InsertSndEventInfo( index++, HSTSNDEvent_SeeRainbowBaitOrGoFrozen,  HPERSO_None,    HV_Frozen ); 
    InsertSndEventInfo( index++, HSTSNDEvent_HstRunTowardRainbow,       HPERSO_None,    HV_Run );
    InsertSndEventInfo( index++, HSTSNDEvent_GoFoetal,                  HPERSO_None,    HV_Foetal );
    InsertSndEventInfo( index++, HSTSNDEvent_FollowRainbow,             HPERSO_None,    HV_RnbFollow );
    InsertSndEventInfo( index++, HSTSNDEvent_AskedToStayPut,            HPERSO_None,    HV_RndStayPut );
    InsertSndEventInfo( index++, HSTSNDEvent_InjuredByRainbow,          HPERSO_Brave,   HV_RnbHurt );
}

defaultproperties
{
     c_iSurrenderRadius=200
     c_iDetectUnderFireRadius=500
     c_iDetectThreatSound=1000
     c_iDetectGrenadeRadius=1000
     c_ThreatLevel_Surrender=5
     c_ThreatGroup_Civ="Civ"
     c_ThreatGroup_HstFreed="Freed"
     c_ThreatGroup_HstGuarded="Guarded"
     c_ThreatGroup_HstBait="Bait"
     c_ThreatGroup_HstEscorted="Escorted"
     RemoteRole=ROLE_None
     bHidden=True
}
