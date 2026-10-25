//=============================================================================
// Engine: The base class of the global application object classes.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Engine extends Subsystem
	native
	noexport
	transient;

// Drivers.
var(Drivers) config class<AudioSubsystem> AudioDevice;
var(Drivers) config class<Interaction>    Console;				// The default system console
//#ifndef R6CODE
//var(Drivers) config class<Interaction>	  DefaultMenu;			// The default system menu 
//var(Drivers) config class<Interaction>	  DefaultPlayerMenu;	// The default player menu
//#endif // #ifndef R6CODE
var(Drivers) config class<NetDriver>      NetworkDevice;
var(Drivers) config class<Language>       Language;

// Variables.
var primitive Cylinder;
var const client Client;
var const audiosubsystem Audio;
var const renderdevice GRenDev;

// Stats.
var int bShowFrameRate;
var int bShowRenderStats;
var int bShowHardwareStats;
var int bShowGameStats;
var int bShowAnimStats;		 // Show animation statistics.
var int bShowNetStats;
var int bShowHistograph;
var int bShowXboxMemStats;
var int bShowMatineeStats;	// Show Matinee specific information
var int bShowAudioStats;

var int TickCycles, GameCycles, ClientCycles;
var(Settings) config int CacheSizeMegs;
var(Settings) config bool UseSound;
var(Settings) float CurrentTickRate;

//R6CODE
var INT    m_iCurrentDelta;
var FLOAT  m_fDeltaTime;   // Frame delta time
var FLOAT  m_fTotalTime;   // Total engine run time


// Color preferences.
var(Colors) config color
	C_WorldBox,
	C_GroundPlane,
	C_GroundHighlight,
	C_BrushWire,
	C_Pivot,
	C_Select,
	C_Current,
	C_AddWire,
	C_SubtractWire,
	C_GreyWire,
	C_BrushVertex,
	C_BrushSnap,
	C_Invalid,
	C_ActorWire,
	C_ActorHiWire,
	C_Black,
	C_White,
	C_Mask,
	C_SemiSolidWire,
	C_NonSolidWire,
	C_WireBackground,
	C_WireGridAxis,
	C_ActorArrow,
	C_ScaleBox,
	C_ScaleBoxHi,
	C_ZoneWire,
	C_Mover,
	C_OrthoBackground,
	C_StaticMesh,
	C_VolumeBrush,
	C_ConstraintLine,
	C_AnimMesh,
    C_TerrainWire;

//#ifdef R6RASTERS
var BOOL m_bProfStatsFps;
var BOOL m_bProfStatsTimers;
//#endif//R6RASTERS

//#ifdef R6KARMA
var BOOL m_bKarmaMemoryStats;
//#endif // #ifdef R6KARMA

var BOOL m_bShowActorRenderStats;
var BOOL m_bShowActorTickStats;
var BOOL m_bShowActorTraceStats;
var BOOL m_bShowActorTracedStats;
var BOOL m_bFreezeActorStats;
var BOOL m_bShowStaticMeshSectionsDebugInfo;
var BOOL m_bUseStaticMeshBatcher;
var BOOL m_bShowNetChannelStats;

//#ifdef R6CHARLIGHTVALUE
var BOOL m_bShowLightValue;
//#endif//R6CHARLIGHTVALUE
    
//#ifdef R6CODE
var BOOL m_bRunningFromEditor;
var BOOL m_bDisplayVersionInfo;
var BOOL m_bMultiScreenShot;
var BOOL m_bEnableLoadingScreen;
var BOOL m_bIsRecording;
var BYTE m_szMovieFileName[256];
var float m_fFakeDeltaTime;
var INT m_lMovieFrame;
var INT m_iCurrentMapNum;
var Class m_TickedClassStats;
//#endif//R6CODE

//R6CONSOLE
const       C_ConsoleMaxStrings = 32;
var String  m_ConsoleStrings[C_ConsoleMaxStrings];
var Color   m_ConsoleStringsColors[C_ConsoleMaxStrings];
var byte    m_ConsoleUseBigFont[C_ConsoleMaxStrings];
var int     m_iConsoleNbStrings;

defaultproperties
{
     Console=Class'Engine.Console'
     CacheSizeMegs=2
     UseSound=True
     C_WorldBox=(B=107,A=255)
     C_GroundPlane=(B=63,A=255)
     C_GroundHighlight=(B=127,A=255)
     C_BrushWire=(B=63,G=63,R=255,A=255)
     C_Pivot=(G=255,A=255)
     C_Select=(B=127,A=255)
     C_Current=(A=255)
     C_AddWire=(B=255,G=127,R=127,A=255)
     C_SubtractWire=(B=63,G=192,R=255,A=255)
     C_GreyWire=(B=163,G=163,R=163,A=255)
     C_BrushVertex=(A=255)
     C_BrushSnap=(A=255)
     C_Invalid=(B=163,G=163,R=163,A=255)
     C_ActorWire=(G=63,R=127,A=255)
     C_ActorHiWire=(G=127,R=255,A=255)
     C_Black=(A=255)
     C_White=(B=255,G=255,R=255,A=255)
     C_Mask=(A=255)
     C_SemiSolidWire=(G=255,R=127,A=255)
     C_NonSolidWire=(B=32,G=192,R=63,A=255)
     C_WireBackground=(A=255)
     C_WireGridAxis=(B=119,G=119,R=119,A=255)
     C_ActorArrow=(R=163,A=255)
     C_ScaleBox=(B=11,G=67,R=151,A=255)
     C_ScaleBoxHi=(B=157,G=149,R=223,A=255)
     C_ZoneWire=(A=255)
     C_Mover=(B=255,R=255,A=255)
     C_OrthoBackground=(B=163,G=163,R=163,A=255)
     C_StaticMesh=(B=255,G=255,A=255)
     C_VolumeBrush=(B=225,G=196,R=255,A=255)
     C_ConstraintLine=(G=255,A=255)
     C_AnimMesh=(B=28,G=221,R=221,A=255)
     C_TerrainWire=(B=255,G=255,R=255,A=255)
     m_bUseStaticMeshBatcher=True
     m_bEnableLoadingScreen=True
}
