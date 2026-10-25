//=============================================================================
// Object: The base class all objects.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Object
	native
	noexport;

//=============================================================================
// UObject variables.

// Internal variables.
var native private const int ObjectInternal[6];
var native const object Outer;
var native const int ObjectFlags;
var(Object) native const editconst name Name;
var native const editconst class Class;

// ***********************************************************************************************
// * BEGIN UBI MODIF joel tremblay (16 juil 2003)
// ***********************************************************************************************
var native private const int DName;
// ***********************************************************************************************
// * END UBI MODIF 
// ***********************************************************************************************

//=============================================================================
// Unreal base structures.

// Object flags.
const RF_Transactional	= 0x00000001; // Supports editor undo/redo.
const RF_Public         = 0x00000004; // Can be referenced by external package files.
const RF_Transient      = 0x00004000; // Can't be saved or loaded.
const RF_NotForClient	= 0x00100000; // Don't load for game client.
const RF_NotForServer	= 0x00200000; // Don't load for game server.
const RF_NotForEdit		= 0x00400000; // Don't load for editor.

// #ifdef R6CODE
enum EGoCode
{
    GOCODE_Alpha,
    GOCODE_Bravo,
    GOCODE_Charlie,
    GOCODE_Zulu,
    GOCODE_None
};
enum EMovementMode
{
    MOVE_Assault,
    MOVE_Infiltrate,
    MOVE_Recon
};
enum EMovementSpeed
{
    SPEED_Blitz,
    SPEED_Normal,
    SPEED_Cautious
};
enum EPlanAction
{
    PACT_None,
    PACT_Frag,
    PACT_Flash,
    PACT_Gas,
    PACT_Smoke,
    PACT_SnipeGoCode,
    PACT_Breach,
    PACT_OpenDoor
};
enum EPlanActionType
{
    PACTTYP_Normal,
    PACTTYP_Milestone,
    PACTTYP_GoCodeA,
    PACTTYP_GoCodeB,
    PACTTYP_GoCodeC,
    PACTTYP_Delete
};
enum ENodeNotify
{
    NODEMSG_NewAction,
    NODEMSG_NewMode,
    NODEMSG_NewSpeed,
    NODEMSG_NewNode,
    NODEMSG_GoCodeLaunched,
    NODEMSG_ActionNodeCompleted,
    NODEMSG_WaitingGoCode,
    NODEMSG_NodeReached,
    NODEMSG_PlayerLeft,
    NODEMSG_SnipeUntilGoCode,
    NODEMSG_BreachDoorAtGoCode
};

enum ePlayerTeamSelection
{
    PTS_UnSelected,
    PTS_AutoSelect,
    PTS_Alpha,
    PTS_Bravo,
    PTS_Spectator
}; 

// #endif R6CODE

// A globally unique identifier.
struct Guid
{
	var int A, B, C, D;
};

// A point or direction vector in 3d space.
struct Vector
{
	var() config float X, Y, Z;
};

// A plane definition in 3d space.
struct Plane extends Vector
{
	var() config float W;
};

// An orthogonal rotation in 3d space.
struct Rotator
{
	var() config int Pitch, Yaw, Roll;
};

// An arbitrary coordinate system in 3d space.
struct Coords
{
	var() config vector Origin, XAxis, YAxis, ZAxis;
};

// Used to generate random values between Min and Max
struct Range
{
	var() config float Min;
	var() config float Max;
};

// Vector of Ranges
struct RangeVector
{
	var() config range X;
	var() config range Y;
	var() config range Z;
};

// A scale and sheering.
struct Scale
{
	var() config vector Scale;
	var() config float SheerRate;
	var() config enum ESheerAxis
	{
		SHEER_None,
		SHEER_XY,
		SHEER_XZ,
		SHEER_YX,
		SHEER_YZ,
		SHEER_ZX,
		SHEER_ZY,
	} SheerAxis;
};

// Camera orientations for Matinee
enum ECamOrientation
{
	CAMORIENT_None,
	CAMORIENT_LookAtActor,
	CAMORIENT_FacePath,
	CAMORIENT_Interpolate,
	CAMORIENT_Dolly,
};

// A color.
struct Color
{
	var() config byte B, G, R, A;
};

// A bounding box.
struct Box
{
	var vector Min, Max;
	var byte IsValid;
};

// A bounding box sphere together.
struct BoundingVolume extends Box
{
	var plane Sphere;
};

// a 4x4 matrix
struct Matrix
{
	var() Plane XPlane;
	var() Plane YPlane;
	var() Plane ZPlane;
	var() Plane WPlane;
};

// A interpolated function
struct InterpCurvePoint
{
	var() float InVal;
	var() float OutVal;
};

struct InterpCurve
{
	var() array<InterpCurvePoint>	Points;
};

// +R6CODE 
// defined originaly in UWindowBase but needed for R6MissionDescription
struct Region
{
	var() int X;
	var() int Y;
	var() int W;
	var() int H;
};
// -R6CODE

//UT2K3
struct CompressedPosition
{
	var vector Location;
	var rotator Rotation;
	var vector Velocity;
};

// --- gam
//=============================================================================
// Constants.

const MaxInt = 0x7fffffff;
const Pi     = 3.1415926535897932;

//=============================================================================
// Basic native operators and functions.

// Bool operators.
native(129) static final preoperator  bool  !  ( bool A );
native(242) static final operator(24) bool  == ( bool A, bool B );
native(243) static final operator(26) bool  != ( bool A, bool B );
native(130) static final operator(30) bool  && ( bool A, skip bool B );
native(131) static final operator(30) bool  ^^ ( bool A, bool B );
native(132) static final operator(32) bool  || ( bool A, skip bool B );

// Byte operators.
native(133) static final operator(34) byte *= ( out byte A, byte B );
native(134) static final operator(34) byte /= ( out byte A, byte B );
native(135) static final operator(34) byte += ( out byte A, byte B );
native(136) static final operator(34) byte -= ( out byte A, byte B );
native(137) static final preoperator  byte ++ ( out byte A );
native(138) static final preoperator  byte -- ( out byte A );
native(139) static final postoperator byte ++ ( out byte A );
native(140) static final postoperator byte -- ( out byte A );

// Integer operators.
native(141) static final preoperator  int  ~  ( int A );
native(143) static final preoperator  int  -  ( int A );
native(144) static final operator(16) int  *  ( int A, int B );
native(145) static final operator(16) int  /  ( int A, int B );
native(146) static final operator(20) int  +  ( int A, int B );
native(147) static final operator(20) int  -  ( int A, int B );
native(148) static final operator(22) int  << ( int A, int B );
native(149) static final operator(22) int  >> ( int A, int B );
native(196) static final operator(22) int  >>>( int A, int B );
native(150) static final operator(24) bool <  ( int A, int B );
native(151) static final operator(24) bool >  ( int A, int B );
native(152) static final operator(24) bool <= ( int A, int B );
native(153) static final operator(24) bool >= ( int A, int B );
native(154) static final operator(24) bool == ( int A, int B );
native(155) static final operator(26) bool != ( int A, int B );
native(156) static final operator(28) int  &  ( int A, int B );
native(157) static final operator(28) int  ^  ( int A, int B );
native(158) static final operator(28) int  |  ( int A, int B );
native(159) static final operator(34) int  *= ( out int A, float B );
native(160) static final operator(34) int  /= ( out int A, float B );
native(161) static final operator(34) int  += ( out int A, int B );
native(162) static final operator(34) int  -= ( out int A, int B );
native(163) static final preoperator  int  ++ ( out int A );
native(164) static final preoperator  int  -- ( out int A );
native(165) static final postoperator int  ++ ( out int A );
native(166) static final postoperator int  -- ( out int A );

// Integer functions.
native(167) static final Function     int  Rand  ( int Max );
native(249) static final function     int  Min   ( int A, int B );
native(250) static final function     int  Max   ( int A, int B );
native(251) static final function     int  Clamp ( int V, int A, int B );

// Float operators.
native(169) static final preoperator  float -  ( float A );
native(170) static final operator(12) float ** ( float A, float B );
native(171) static final operator(16) float *  ( float A, float B );
native(172) static final operator(16) float /  ( float A, float B );
native(173) static final operator(18) float %  ( float A, float B );
native(174) static final operator(20) float +  ( float A, float B );
native(175) static final operator(20) float -  ( float A, float B );
native(176) static final operator(24) bool  <  ( float A, float B );
native(177) static final operator(24) bool  >  ( float A, float B );
native(178) static final operator(24) bool  <= ( float A, float B );
native(179) static final operator(24) bool  >= ( float A, float B );
native(180) static final operator(24) bool  == ( float A, float B );
native(210) static final operator(24) bool  ~= ( float A, float B );
native(181) static final operator(26) bool  != ( float A, float B );
native(182) static final operator(34) float *= ( out float A, float B );
native(183) static final operator(34) float /= ( out float A, float B );
native(184) static final operator(34) float += ( out float A, float B );
native(185) static final operator(34) float -= ( out float A, float B );

// Float functions.
native(186) static final function     float Abs   ( float A );
native(187) static final function     float Sin   ( float A );
native      static final function	  float Asin  ( float A );
native(188) static final function     float Cos   ( float A );
native      static final function     float Acos  ( float A );
native(189) static final function     float Tan   ( float A );
native(190) static final function     float Atan  ( float A );
native(191) static final function     float Exp   ( float A );
native(192) static final function     float Loge  ( float A );
native(193) static final function     float Sqrt  ( float A );
native(194) static final function     float Square( float A );
native(195) static final function     float FRand ();
native(244) static final function     float FMin  ( float A, float B );
native(245) static final function     float FMax  ( float A, float B );
native(246) static final function     float FClamp( float V, float A, float B );
native(247) static final function     float Lerp  ( float Alpha, float A, float B );
native(248) static final function     float Smerp ( float Alpha, float A, float B );

// Vector operators.
native(211) static final preoperator  vector -     ( vector A );
native(212) static final operator(16) vector *     ( vector A, float B );
native(213) static final operator(16) vector *     ( float A, vector B );
native(296) static final operator(16) vector *     ( vector A, vector B );
native(214) static final operator(16) vector /     ( vector A, float B );
native(215) static final operator(20) vector +     ( vector A, vector B );
native(216) static final operator(20) vector -     ( vector A, vector B );
native(275) static final operator(22) vector <<    ( vector A, rotator B );
native(276) static final operator(22) vector >>    ( vector A, rotator B );
native(217) static final operator(24) bool   ==    ( vector A, vector B );
native(218) static final operator(26) bool   !=    ( vector A, vector B );
native(219) static final operator(16) float  Dot   ( vector A, vector B );
native(220) static final operator(16) vector Cross ( vector A, vector B );
native(221) static final operator(34) vector *=    ( out vector A, float B );
native(297) static final operator(34) vector *=    ( out vector A, vector B );
native(222) static final operator(34) vector /=    ( out vector A, float B );
native(223) static final operator(34) vector +=    ( out vector A, vector B );
native(224) static final operator(34) vector -=    ( out vector A, vector B );

// Vector functions.
native(225) static final function float  VSize  ( vector A );
native(226) static final function vector Normal ( vector A );
native(227) static final function        Invert ( out vector X, out vector Y, out vector Z );
native(252) static final function vector VRand  ( );
native(300) static final function vector MirrorVectorByNormal( vector Vect, vector Normal );

// Rotator operators and functions.
native(142) static final operator(24) bool ==     ( rotator A, rotator B );
native(203) static final operator(26) bool !=     ( rotator A, rotator B );
native(287) static final operator(16) rotator *   ( rotator A, float    B );
native(288) static final operator(16) rotator *   ( float    A, rotator B );
native(289) static final operator(16) rotator /   ( rotator A, float    B );
native(290) static final operator(34) rotator *=  ( out rotator A, float B  );
native(291) static final operator(34) rotator /=  ( out rotator A, float B  );
native(316) static final operator(20) rotator +   ( rotator A, rotator B );
native(317) static final operator(20) rotator -   ( rotator A, rotator B );
native(318) static final operator(34) rotator +=  ( out rotator A, rotator B );
native(319) static final operator(34) rotator -=  ( out rotator A, rotator B );
native(229) static final function GetAxes         ( rotator A, out vector X, out vector Y, out vector Z );
native(230) static final function GetUnAxes       ( rotator A, out vector X, out vector Y, out vector Z );
native(320) static final function rotator RotRand ( optional bool bRoll );
native      static final function rotator OrthoRotation( vector X, vector Y, vector Z );
native      static final function rotator Normalize( rotator Rot );
native		static final operator(24) bool ClockwiseFrom( int A, int B );
//#ifdef R6CODE
// Return the shortest angle (between 0 and 32767) between two parts of a rotator (ie, two yaw)
native(1851) static final function INT ShortestAngle2D( INT iAngle1, INT iAngle2 );
native(1854) static final function BOOL GetRegistryKey( String Dir, String Key, out String Value );
native(1855) static final function BOOL SetRegistryKey( String Dir, String Key, String Value );
//#endif // #ifdef R6CODE

// String operators.
native(112) static final operator(40) string $  ( coerce string A, coerce string B );
native(168) static final operator(40) string @  ( coerce string A, coerce string B );
native(115) static final operator(24) bool   <  ( string A, string B );
native(116) static final operator(24) bool   >  ( string A, string B );
native(120) static final operator(24) bool   <= ( string A, string B );
native(121) static final operator(24) bool   >= ( string A, string B );
native(122) static final operator(24) bool   == ( string A, string B );
native(123) static final operator(26) bool   != ( string A, string B );
native(124) static final operator(24) bool   ~= ( string A, string B );

// String functions.
native(125) static final function int    Len    ( coerce string S );
native(126) static final function int    InStr  ( coerce string S, coerce string t );
native(127) static final function string Mid    ( coerce string S, int i, optional int j );
native(128) static final function string Left   ( coerce string S, int i );
native(234) static final function string Right  ( coerce string S, int i );
native(235) static final function string Caps   ( coerce string S );
native(236) static final function string Chr    ( int i );
native(237) static final function int    Asc    ( string S );
// #ifdef R6CODE
native(238)  static final function string RemoveInvalidChars ( string S );
native(1227) static final function string Itoa  (int i);
native(1228) static final function int Atoi     (coerce string S);
native(1306) static final function int Strnicmp (coerce string A, coerce string B, int iCount);

// #endif

// Object operators.
native(114) static final operator(24) bool == ( Object A, Object B );
native(119) static final operator(26) bool != ( Object A, Object B );

// Name operators.
native(254) static final operator(24) bool == ( name A, name B );
native(255) static final operator(26) bool != ( name A, name B );

// InterpCurve operator
native		static final function float InterpCurveEval( InterpCurve curve, float input );

//=============================================================================
// General functions.

// Logging.
native(2718) final static function LogSnd( coerce string S, optional name Tag );
native(231) final static function Log( coerce string S, optional name Tag );
native(232) final static function Warn( coerce string S );
// #ifdef R6CODE
native static function string Localize( string SectionName, string KeyName, string PackageName, optional bool bNoDebug, optional bool bMultipleToken, optional bool bForceEnglish);
// #else
// native static function string Localize( string SectionName, string KeyName, string PackageName );
// #endif

// Goto state and label.
native(113) final function GotoState( optional name NewState, optional name Label );
native(281) final function bool IsInState( name TestState );
native(284) final function name GetStateName();

// Objects.
native(258) static final function bool ClassIsChildOf( class TestClass, class ParentClass );
native(303) final function bool IsA( name ClassName );

// Probe messages.
native(117) final function Enable( name ProbeFunc );
native(118) final function Disable( name ProbeFunc );

// Properties.
native final function string GetPropertyText( string PropName );
native final function SetPropertyText( string PropName, string PropValue );
native static final function name GetEnum( object E, int i );
native static final function object DynamicLoadObject( string ObjectName, class ObjectClass, optional bool MayFail );
native static final function object FindObject( string ObjectName, class ObjectClass );

// Configuration.
// #ifdef R6CODE
native(536) final function SaveConfig(optional string FileName);
// #else
// native(536) final function SaveConfig();
//#endif

native static final function StaticSaveConfig();
// #ifdef R6CODE
native(1010) final function LoadConfig(optional string FileName);
native static final function ResetConfig( optional string VarNameToReset);
// #else
//native static final function ResetConfig();
// #endif

// Return a random number within the given range.
final function float RandRange( float Min, float Max )
{
    return Min + (Max - Min) * FRand();
}

//R6DESCRIPTIONS
//Make sure you call FreePackageObjects after your last GetNextObject() call
native(1005) static final function class GetFirstPackageClass(string Package, class ObjectClass);
native(1006) static final function class GetNextClass();
native(1301) static final function class RewindToFirstClass();
native(1007) static final function FreePackageObjects();

// R6CODE
native(1850) static final function ClearOuter();
native(1852) static final function Clock(INT iCounter);
native(1853) static final function Unclock(INT iCounter);

//=============================================================================
// Engine notification functions.

//
// Called immediately when entering a state, while within
// the GotoState call that caused the state change.
//
event BeginState();

//
// Called immediately before going out of the current state,
// while within the GotoState call that caused the state change.
// 
event EndState();

defaultproperties
{
}
