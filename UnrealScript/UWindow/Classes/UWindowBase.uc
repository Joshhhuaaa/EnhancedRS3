class UWindowBase extends Object;

// Fonts array constants
const F_Normal = 0;			// Normal font
const F_Bold = 1;			// Bold font
const F_Large = 2;			// Large font
const F_LargeBold = 3;		// Large, Bold font

//R6 Fonts
const F_ocraext17   = 0;
//const F_Rainbow12   = 1;
//const F_Rainbow14   = 2;
//const F_Rainbow17   = 3;

//Menu font
// title
const F_MenuMainTitle    = 4;   // 40pt the font for main title 
const F_SmallTitle       = 5;   // 14pt the font for small title
const F_VerySmallTitle   = 6;   // 12pt the font for very small title
const F_TabMainTitle     = 7;   // 15pt the font for tab main title
const F_PopUpTitle       = 8;   // 15pt the font for popup title
const F_IntelTitle       = 9;   // 17pt the font for intel title (ocra font... specific to this window)

// description
const F_ListItemSmall    = 10;  // 10pt the font for list of item
const F_ListItemBig      = 11;  // 14pt the font for list of item
const F_HelpWindow       = 12;  // 12pt the font for the help window

// button
const F_FirstMenuButton  = 14;  // 36pt the font for the button in first menu
const F_MainButton       = 15;  // 20pt the font for major button (like mainmenu, options, start, etc)
const F_PrincipalButton  = 16;  // 17pt the font for principal button (like Join in multi-player)
const F_CheckBoxButton   = 17;  // 12pt the font for common button ( like check box)


// R6CODE+ defined in epic code, but I moved that in Objet.uc
/*
struct Region
{
	var() int X;
	var() int Y;
	var() int W;
	var() int H;
};
*/
// R6CODE-

struct TexRegion
{
	var() int X;
	var() int Y;
	var() int W;
	var() int H;
	var() Texture T;
};

struct RegionButton
{
    var Region Up;
    var Region Down;
    var Region Over;
    var Region Disabled;
};

enum TextAlign
{
	TA_Left,
	TA_Right,
	TA_Center
};

enum FrameHitTest
{
	HT_NW,
	HT_N,
	HT_NE,
	HT_W,
	HT_E,
	HT_SW,
	HT_S,
	HT_SE,
	HT_TitleBar,
	HT_DragHandle,
	HT_None
};

enum MenuSound
{
	MS_MenuPullDown,
	MS_MenuCloseUp,
	MS_MenuItem,
	MS_WindowOpen,
	MS_WindowClose,
	MS_ChangeTab
};

enum MessageBoxButtons
{
	MB_YesNo,
	MB_OKCancel,
	MB_OK,
	MB_YesNoCancel,
	MB_Cancel,
    MB_None
};

enum MessageBoxResult
{
	MR_None,
	MR_Yes,
	MR_No,
	MR_OK,
	MR_Cancel	// also if you press the Close box.
};

enum PropertyCondition
{
	PC_None,
	PC_LessThan,
	PC_Equal,
	PC_GreaterThan,
	PC_NotEqual,
	PC_Contains,
	PC_NotContains
};

enum EButtonName
{
	EBN_None,
	// Counter Button
	EBN_RoundPerMatch,
	EBN_RoundTime,
	EBN_NB_Players,
	EBN_BombTimer,
	EBN_Spectator,
	EBN_RoundPerMission,
	EBN_TimeBetRound,
	EBN_NB_of_Terro,
	// Button Box
	EBN_InternetServer,
	EBN_DedicatedServer,
	EBN_FriendlyFire,
	EBN_AllowTeamNames,
	EBN_AutoBalTeam,
	EBN_TKPenalty,
	EBN_AllowRadar,
	EBN_RotateMap,
	EBN_AIBkp,
	EBN_ForceFPersonWp,
	EBN_Recruit,
	EBN_Veteran,
	EBN_Elite,
//#ifdefR6PUNKBUSTER
	EBN_PunkBuster,
//#endif
	// Combo Box
	EBN_DiffLevel,
	// camera
	EBN_CamFirstPerson,
	EBN_CamThirdPerson,
	EBN_CamFreeThirdP,
	EBN_CamGhost,
	EBN_CamFadeToBk,
	EBN_CamTeamOnly,
	// main multi page
	EBN_LogIn,
	EBN_LogOut,
    EBN_Join,
    EBN_JoinIP,
    EBN_Refresh,
    EBN_Create,
    EBN_Cancel,
    EBN_Launch,	
	// other
	EBN_EditMsg,
    EBN_CancelUbiCom,
    EBN_EditSkinSel,

	EBN_Max				// always the last one
};

enum EPopUpID
{
	EPopUpID_None,
	EPopUpID_MsgOfTheDay,
    EPopUpID_FileWriteError,
    EPopUpID_FileWriteErrorBackupPln,
	EPopUpID_SaveFileExist,
    EPopUpID_PlanDeleteError,
    EPopUpID_InvalidLoad,

	// MULTI
	EPopUpID_MPServerOpt,
	EPopUpID_MPKitRest,
	EPopUpID_MPGearRoom,
    EPopUpID_EnterIP,
    EPopUpID_JoinIPError,
    EPopUpID_JoinIPWait,
    EPopUpID_UbiAccount,
    EPopUpID_LoginError,
    EPopUpID_UbiComDisconnected,
    EPopUpID_CDKeyPleaseWait,
    EPopUpID_EnterCDKey,
    EPopUpID_Password,
    EPopUpID_JoinRoomError,
    EPopUpID_JoinRoomErrorCDKeyInUse,
    EPopUpID_JoinRoomErrorCDKeySrvNotResp,
    EPopUpID_JoinRoomErrorPassWd,
    EPopUpID_JoinRoomErrorSrvFull,
    EPopUpID_ErrorConnect,
    EPopUpID_PunkBusterOnlyError,
    EPopUpID_PunkBusterDisabledServerWarn,
	EPopUpID_InvalidPassword,
    EPopUpID_QueryServerWait,
    EPopUpID_QueryServerError,
	EPopUpID_TKPenalty,
	EPopUpID_LeaveInGameToMultiMenu,
    EPopUpID_RefreshServerList,
	EPopUpID_DownLoadingInProgress,
	EPopUpID_AdvFilters,
	EPopUpID_CoopFilters,
    EPopUpID_InvalidMod,
    EPopUp_ID_GSCoOpMaxError,
    EPopUpID_UniformSel,
//Single
    EPopUpID_QuickPlay,
    EPopUpID_LoadDelPlan,
    EPopUpID_SaveDelPlan,
    EPopUpID_DeleteCampaign,
    EPopUpID_OverWriteCampaign,
    EPopUpID_DelAllWayPoints,
    EPopUpID_DelAllTeamsWayPoints,
    EPopUpID_LeavePlanningToMain,
    EPopUpID_SavePlanning,
    EPopUpID_LoadPlanning,
    EPopUpID_PlanningIncomplete,
    EPopUpID_LeaveInGameToMain,
    EPopUpID_LeaveInGameToQuit,
    EPopUpID_AbortMissionRetryAction,
	EPopUpID_AbortMissionRetryPlan,
    EPopUpID_QuitTraining,
    EPopUpID_OptionsResetDefault,
    EPopUpID_TextOnly,              //Allow you to do a message box without buttons

	EPopUpID_Max		// always the last one
};

enum ERestKitID
{
	ERestKit_SubMachineGuns,
	ERestKit_Shotguns,
	ERestKit_AssaultRifle,
	ERestKit_MachineGuns,
	ERestKit_SniperRifle,
	ERestKit_Pistol,
	ERestKit_MachinePistol,
	ERestKit_PriWpnGadget,
	ERestKit_SecWpnGadget,
	ERestKit_MiscGadget,

	ERestKit_Max		// always the last one
};



//-----------------------------------------------------------------------------
// Display properties.

// Style for rendering sprites, meshes. THIS IS A COPY OF WHAT YOU CAN FIND IN ACTOR.UC
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Particle,
    STY_Highlight
} Style;


// This variable is used to enable/disble functrionality
// that will be used only for the multi-player demo version

//-----------------------------------------------------------------------------

struct HTMLStyle
{
	var int BulletLevel;			// 0 = no bullet depth
	var string LinkDestination;
	var Color TextColor;
	var Color BGColor;
	var bool bCenter;
	var bool bLink;
	var bool bUnderline;
	var bool bNoBR;
	var bool bHeading;
	var bool bBold;
	var bool bBlink;
};

function Region NewRegion(float X, float Y, float W, float H)
{
	local Region R;
	R.X = X;
	R.Y = Y;
	R.W = W;
	R.H = H;
	return R;
}

function TexRegion NewTexRegion(float X, float Y, float W, float H, Texture T)
{
	local TexRegion R;
	R.X = X;
	R.Y = Y;
	R.W = W;
	R.H = H;
	R.T = T;
	return R;
}

function Region GetRegion(TexRegion T)
{
	local Region R;

	R.X = T.X;
	R.Y = T.Y;
	R.W = T.W;
	R.H = T.H;

	return R;
}

static function int InStrAfter(string Text, string Match, int Pos)
{
	local int i;
	
	i = InStr(Mid(Text, Pos), Match);
	if(i != -1)
		return i + Pos;
	return -1;
}

static function Object BuildObjectWithProperties(string Text)
{
	local int i;
	local string ObjectClass, PropertyName, PropertyValue, Temp;
	local class<Object> C;
	local Object O;
	
	i = InStr(Text, ",");
	if(i == -1)
	{
		ObjectClass=Text;
		Text="";
	}
	else
	{
		ObjectClass=Left(Text, i);
		Text=Mid(Text, i+1);
	}
	
	//Log("Class: "$ObjectClass);

	C = class<Object>(DynamicLoadObject(ObjectClass, class'Class'));
	O = new C;

	while(Text != "")
	{
		i = InStr(Text, "=");
		if(i == -1)
		{
			Log("Missing value for property "$ObjectClass$"."$Text);
			PropertyName=Text;
			PropertyValue="";
		}
		else
		{
			PropertyName=Left(Text, i);
			Text=Mid(Text, i+1);
		}

		if(Left(Text, 1) == "\"")
		{
			i = InStrAfter(Text, "\"", 1);
			if(i == -1)
			{
				Log("Missing quote for "$ObjectClass$"."$PropertyName);
				return O;
			}
			PropertyValue = Mid(Text, 1, i-1);
			
			Temp = Mid(Text, i+1, 1);
			if(Temp != "" && Temp != ",")
				Log("Missing comma after close quote for "$ObjectClass$"."$PropertyName);
			Text = Mid(Text, i+2);	
		}
		else
		{
			i = InStr(Text, ",");
			if(i == -1)
			{
				PropertyValue=Text;
				Text="";
			}
			else
			{
				PropertyValue=Left(Text, i);
				Text=Mid(Text, i+1);
			}
		}
				
		//Log("Property: "$PropertyName$" => "$PropertyValue);
		O.SetPropertyText(PropertyName, PropertyValue);
	}

	return O;
}

#ifdefDEBUG
function string GetEPopUpID(EPopUpID _EPopUpID)
{
	local string szResult;

	switch( _EPopUpID)
	{
		case EPopUpID_None:						szResult = "EPopUpID_None"; break;
		case EPopUpID_MsgOfTheDay:				szResult = "EPopUpID_MsgOfTheDay"; break;
		case EPopUpID_FileWriteError:			szResult = "EPopUpID_FileWriteError"; break;
		case EPopUpID_FileWriteErrorBackupPln:	szResult = "EPopUpID_FileWriteErrorBackupPln"; break;
		case EPopUpID_SaveFileExist:			szResult = "EPopUpID_SaveFileExist"; break;
		case EPopUpID_InvalidLoad:				szResult = "EPopUpID_InvalidLoad"; break;

		// MULTI
		case EPopUpID_MPServerOpt:				szResult = "EPopUpID_MPServerOpt"; break;
		case EPopUpID_MPKitRest:				szResult = "EPopUpID_MPKitRest"; break;
		case EPopUpID_MPGearRoom:				szResult = "EPopUpID_MPGearRoom"; break;
		case EPopUpID_EnterIP:					szResult = "EPopUpID_EnterIP"; break;
		case EPopUpID_JoinIPError:				szResult = "EPopUpID_JoinIPError"; break;
		case EPopUpID_JoinIPWait:				szResult = "EPopUpID_JoinIPWait"; break;
		case EPopUpID_UbiAccount:				szResult = "EPopUpID_UbiAccount"; break;
		case EPopUpID_LoginError:				szResult = "EPopUpID_LoginError"; break;
		case EPopUpID_UbiComDisconnected:		szResult = "EPopUpID_UbiComDisconnected"; break;
		case EPopUpID_CDKeyPleaseWait:			szResult = "EPopUpID_CDKeyPleaseWait"; break;
		case EPopUpID_EnterCDKey:				szResult = "EPopUpID_EnterCDKey"; break;
		case EPopUpID_Password:					szResult = "EPopUpID_Password"; break;
		case EPopUpID_JoinRoomError:			szResult = "EPopUpID_JoinRoomError"; break;
		case EPopUpID_JoinRoomErrorCDKeyInUse:	szResult = "EPopUpID_JoinRoomErrorCDKeyInUse"; break;
		case EPopUpID_JoinRoomErrorCDKeySrvNotResp:	szResult = "EPopUpID_JoinRoomErrorCDKeySrvNotResp"; break;
		case EPopUpID_JoinRoomErrorPassWd:		szResult = "EPopUpID_JoinRoomErrorPassWd"; break;
		case EPopUpID_JoinRoomErrorSrvFull:		szResult = "EPopUpID_JoinRoomErrorSrvFull"; break;
		case EPopUpID_ErrorConnect:				szResult = "EPopUpID_ErrorConnect"; break;
		case EPopUpID_InvalidPassword:			szResult = "EPopUpID_InvalidPassword"; break;
		case EPopUpID_QueryServerWait:			szResult = "EPopUpID_QueryServerWait"; break;
		case EPopUpID_QueryServerError:			szResult = "EPopUpID_QueryServerError"; break;
		case EPopUpID_TKPenalty:				szResult = "EPopUpID_TKPenalty"; break;
		case EPopUpID_LeaveInGameToMultiMenu:	szResult = "EPopUpID_LeaveInGameToMultiMenu"; break;
        case EPopUpID_RefreshServerList:        szResult = "EPopUpID_RefreshServerList"; break;
		case EPopUpID_DownLoadingInProgress:	szResult = "EPopUpID_DownLoadingInProgress"; break;
		case EPopUpID_AdvFilters:				szResult = "EPopUpID_AdvFilters"; break;
		case EPopUpID_CoopFilters:				szResult = "EPopUpID_CoopFilters"; break;
		//Single            
        case EPopUpID_LoadDelPlan:			    szResult = "EPopUpID_LoadDelPlan"; break;
        case EPopUpID_SaveDelPlan:			    szResult = "EPopUpID_LoadDelPlan"; break;            
		case EPopUpID_DeleteCampaign:			szResult = "EPopUpID_DeleteCampaign"; break;
		case EPopUpID_DelAllWayPoints:			szResult = "EPopUpID_DelAllWayPoints"; break;
		case EPopUpID_DelAllTeamsWayPoints:		szResult = "EPopUpID_DelAllTeamsWayPoints"; break;
		case EPopUpID_LeavePlanningToMain:		szResult = "EPopUpID_LeavePlanningToMain"; break;
		case EPopUpID_SavePlanning:				szResult = "EPopUpID_SavePlanning"; break;
		case EPopUpID_LoadPlanning:				szResult = "EPopUpID_LoadPlanning"; break;
		case EPopUpID_PlanningIncomplete:		szResult = "EPopUpID_PlanningIncomplete"; break;
		case EPopUpID_LeaveInGameToMain:		szResult = "EPopUpID_LeaveInGameToMain"; break;
		case EPopUpID_LeaveInGameToQuit:		szResult = "EPopUpID_LeaveInGameToQuit"; break;
		case EPopUpID_AbortMissionRetryAction:	szResult = "EPopUpID_AbortMissionRetryAction"; break;
		case EPopUpID_AbortMissionRetryPlan:	szResult = "EPopUpID_AbortMissionRetryPlan"; break;            
        case EPopUpID_QuitTraining:	szResult = "EPopUpID_QuitTraining"; break;
		case EPopUpID_OptionsResetDefault:		szResult = "EPopUpID_OptionsResetDefault"; break;
		default:
			szResult = "POPUPID NOT DEFINE in GetEPopUpID()";
			break;
	}

	return szResult;
}
#endif

defaultproperties
{
}
