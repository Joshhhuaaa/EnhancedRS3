//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
	native
	placeable;

#exec Texture Import File=Textures\ZoneInfo.pcx Name=S_ZoneInfo Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Zone properties.

var skyzoneinfo SkyZone; // Optional sky zone containing this zone's sky.
var() name ZoneTag;

//-----------------------------------------------------------------------------
// Zone flags.

var() const bool   bFogZone;     // Zone is fog-filled.
var()		bool   bTerrainZone;	// There is terrain in this zone.
var()		bool   bDistanceFog;	// There is distance fog in this zone.
var()		bool   bClearToFogColor;	// Clear to fog color if distance fog is enabled.

var const array<TerrainInfo> Terrains;

//-----------------------------------------------------------------------------
// Zone light.

var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;

var(ZoneLight) color DistanceFogColor;
var(ZoneLight) float DistanceFogStart;
var(ZoneLight) float DistanceFogEnd;

var(ZoneLight) const texture EnvironmentMap;
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;

var(ZoneSound) editinline I3DL2Listener ZoneEffect;

// #ifdef R6ZONEBOUND
// Set in the editor  "UBOOL UEditorEngine::Exec_BSP( const TCHAR* Str, FOutputDevice& Ar )"
var Vector   m_vBoundLocation;  // the "Min" vertex position
var Vector   m_vBoundNormal;    // AA-oriented, Vect(0,0,1)
var Vector   m_vBoundScale;     // ... == size
// #endif R6ZONEBOUND

//#ifdef R6SOUND
var (R6Sound) BYTE          m_SoundZone;
var (R6Sound) Array<Sound>  m_StartingSounds;
var (R6Sound) Array<Sound>  m_EnterSounds;
var (R6Sound) Array<Sound>  m_ExitSounds;
var (R6Sound) Sound         m_SinglePlayerMusic;
var ()        BOOL          m_bInDoor;
var BOOL                    m_bAlreadyPlayMusic;
//#endif

// R6CODE
var            bool           m_bAlternateEmittersActive;
var(R6Weather) array<Emitter> m_AlternateWeatherEmitters;

//=============================================================================
// Iterator functions.

// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors( class<actor> BaseClass, out actor Actor );

simulated function LinkToSkybox()
{
	local skyzoneinfo TempSkyZone;

	// SkyZone.
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		SkyZone = TempSkyZone;
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		if( TempSkyZone.bHighDetail == Level.bHighDetailMode )
			SkyZone = TempSkyZone;
}

//=============================================================================
// Engine notification functions.

simulated function PreBeginPlay()
{

    Super.PreBeginPlay();

    // call overridable function to link this ZoneInfo actor to a skybox
	LinkToSkybox();

}

simulated function ResetOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();
    m_bAlreadyPlayMusic = false;
}

// When an actor enters this zone.
simulated event ActorEntered( actor Other )
{
//#ifdef R6CODE
    local INT iSoundNb;
    local Controller C;


    if (Level.m_bPlaySound && m_EnterSounds.Length != 0)
    {
        if (Other.IsA('R6Pawn'))
            C = Pawn(Other).Controller;
        else if (Other.IsA('R6PlayerController'))
            C = Controller(Other);

        if (C != none)
        {
            C.m_CurrentAmbianceObject = self;
            C.m_bUseExitSounds = FALSE;
            if ((PlayerController(C) != None)  && (Viewport(PlayerController(C).Player) != None))
            {
                for(iSoundNb = 0; iSoundNb < m_EnterSounds.Length; iSoundNb++)
                {            
                    PlaySound(m_EnterSounds[iSoundNb], SLOT_StartingSound);
                }
                
                if (Level.NetMode == NM_Standalone && !m_bAlreadyPlayMusic)
                {        
                    m_bAlreadyPlayMusic = true;
                    PlayMusic(m_SinglePlayerMusic);
                }
            }
        }
    }
//#endif R6CODE
}

// When an actor leaves this zone.
simulated event ActorLeaving( actor Other )
{
//#ifdef R6CODE
    local INT iSoundNb;
    local Controller C;

    if (Level.m_bPlaySound && m_ExitSounds.Length != 0)
    {
        if (Other.IsA('R6Pawn'))
            C = Pawn(Other).Controller;
        else if (Other.IsA('R6PlayerController'))
            C = Controller(Other);

        if (C != none)
        {
            C.m_CurrentAmbianceObject= self; 
            C.m_bUseExitSounds = TRUE;
            if ((PlayerController(C) != None)  && (Viewport(PlayerController(C).Player) != None))
            {
                for(iSoundNb = 0; iSoundNb < m_ExitSounds.Length; iSoundNb++)
                {
                    PlaySound(m_ExitSounds[iSoundNb], SLOT_StartingSound);
                }
            }
        }
    }
//#endif R6CODE
}

defaultproperties
{
     AmbientSaturation=255
     DistanceFogStart=3000.000000
     DistanceFogEnd=8000.000000
     TexUPanSpeed=1.000000
     TexVPanSpeed=1.000000
     DistanceFogColor=(B=128,G=128,R=128)
     bStatic=True
     bNoDelete=True
     m_b3DSound=False
     Texture=Texture'Engine.S_ZoneInfo'
}
