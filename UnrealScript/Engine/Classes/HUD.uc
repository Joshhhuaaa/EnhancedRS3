//=============================================================================
// HUD: Superclass of the heads-up display.
//=============================================================================
class HUD extends Actor
	native
	config(user);

//R6CODE

//=============================================================================
// Variables.

#exec Texture Import File=Textures\Border.pcx

//#ifndef R6CODE
//#exec new TrueTypeFontFactory PACKAGE="Engine" Name=MediumFont FontName="Arial Bold" Height=16 AntiAlias=1 CharactersPerPage=128
//#exec new TrueTypeFontFactory PACKAGE="Engine" Name=SmallFont FontName="Terminal" Height=10 AntiAlias=0 CharactersPerPage=256
//#endif

// Stock fonts.
var font SmallFont;          // Small system font.
var font MedFont;            // Medium system font.
var font BigFont;            // Big system font.
var font LargeFont;            // Largest system font.


//#ifdef R6CODE
var R6GameColors Colors;
//#end R6CODE

var string HUDConfigWindowType;
var HUD nextHUD;	// list of huds which render to the canvas
var PlayerController PlayerOwner; // always the actual owner

//#ifndef R6CODE
//var ScoreBoard Scoreboard;
//#endif
var bool	bShowScores;
var bool	bShowDebugInfo;		// if true, show properties of current ViewTarget
var bool	bHideCenterMessages;	// don't draw centered messages (screen center being used)
var bool    bBadConnectionAlert;	// display warning about bad connection
//#ifndef R6CODE
//var() config bool bMessageBeep;
//#endif // #ifndef R6CODE

var localized string LoadingMessage;
var localized string SavingMessage;
var localized string ConnectingMessage;
var localized string PausedMessage;
var localized string PrecachingMessage;

var bool bHideHUD;		// Should the hud display itself.

struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};

//R6CODE: epic version
//var string TextMessages[4];
//var float MessageLife[4];
const c_iTextMessagesMax = 6;
var string TextMessages[6];
var float MessageLife[6];

//R6CODE
const c_iTextKillMessagesMax = 4;
var string TextKillMessages[4];
var float MessageKillLife[4];

const c_iTextServerMessagesMax = 3;
var string TextServerMessages[3];
var float MessageServerLife[3];
var byte MessageUseBigFont[3];

//R6CODE
var     font                    m_FontRainbow6_14pt;
var     font                    m_FontRainbow6_17pt;
var     font                    m_FontRainbow6_22pt;
var     font                    m_FontRainbow6_36pt;

//R6CONSOLE
var Color       m_ChatMessagesColor;
var Color       m_KillMessagesColor;
var Color       m_ServerMessagesColor;
var Material    m_ConsoleBackground;

/* Draw3DLine()
draw line in world space. Should be used when engine calls RenderWorldOverlays() event.
*/
native final function Draw3DLine(vector Start, vector End, color LineColor);

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayerOwner = PlayerController(Owner);

//#ifdef R6CODE
    Colors = new(None) class'R6GameColors';
    if (Level.NetMode==NM_DedicatedServer)
        return;

    SmallFont = Font(DynamicLoadObject("R6Font.SmallFont",class'Font'));
    MedFont=SmallFont;
    BigFont=SmallFont;
    LargeFont=SmallFont;

    m_FontRainbow6_14pt= Font(DynamicLoadObject("R6Font.Rainbow6_14pt",class'Font'));
    m_FontRainbow6_17pt= Font(DynamicLoadObject("R6Font.Rainbow6_17pt",class'Font'));
    m_FontRainbow6_22pt= Font(DynamicLoadObject("R6Font.Rainbow6_22pt",class'Font'));
    m_FontRainbow6_36pt= Font(DynamicLoadObject("R6Font.Rainbow6_36pt",class'Font'));

//#end R6CODE
}

//#ifndef R6CODE
//function SpawnScoreBoard(class<Scoreboard> ScoringType)
//{
//	if ( ScoringType != None )
//	{
//		Scoreboard = Spawn(ScoringType, PlayerOwner);
//		Scoreboard.OwnerHUD = self;
//	}
//}
//#end R6CODE

simulated event Destroyed()
{
//#ifndef R6CODE
//	if ( Scoreboard != None )
//		Scoreboard.Destroy();
//#endif
    
	PlayerOwner = none; // R6CODE
	Super.Destroyed();
}

//=============================================================================
// Execs

#ifdefDEBUG
/* toggles displaying scoreboard
*/
exec function ShowScores()
{
	bShowScores = !bShowScores;
}

/* toggles displaying properties of player's current viewtarget
*/
exec function ShowDebug()
{
	bShowDebugInfo = !bShowDebugInfo;
}
#endif//DEBUG

/* ShowUpgradeMenu()
Event called when the engine version is less than the MinNetVer of the server you are trying
to connect with.  
*/ 
event ShowUpgradeMenu();

function PlayStartupMessage(byte Stage);

//=============================================================================
// Message manipulation

function ClearMessage(out HUDLocalizedMessage M)
{
	M.Message = None;
	M.Switch = 0;
	M.RelatedPRI = None;
	M.OptionalObject = None;
	M.EndOfLife = 0;
	M.StringMessage = "";
	M.DrawColor = class'Canvas'.Static.MakeColor(255,255,255);
	M.XL = 0;
	M.bDrawing = false;
}

function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	M1.Message = M2.Message;
	M1.Switch = M2.Switch;
	M1.RelatedPRI = M2.RelatedPRI;
	M1.OptionalObject = M2.OptionalObject;
	M1.EndOfLife = M2.EndOfLife;
	M1.StringMessage = M2.StringMessage;
	M1.DrawColor = M2.DrawColor;
	M1.XL = M2.XL;
	M1.YL = M2.YL;
	M1.YPos = M2.YPos;
	M1.bDrawing = M2.bDrawing;
	M1.LifeTime = M2.LifeTime;
	M1.numLines = M2.numLines;
}

//=============================================================================
// Status drawing.

simulated event WorldSpaceOverlays()
{
	if ( bShowDebugInfo && Pawn(PlayerOwner.ViewTarget) != None )
		DrawRoute();
}

Event RenderFirstPersonGun(canvas Canvas)
{
    local Pawn P;

	if(!PlayerOwner.bBehindView/* && !PlayerOwner.bOnlySpectator*/)
    {
		P = Pawn(PlayerOwner.ViewTarget);

        if((P != None) && (P.EngineWeapon != None))
        {
			P.EngineWeapon.RenderOverlays(Canvas);
        }
	}
}

// R6CODE
simulated event PostFadeRender( canvas Canvas );



simulated event PostRender( canvas Canvas )
{
	local HUD H;
	local float YL,YPos;
	local Pawn P;

    DisplayMessages(Canvas);
//R6CODE	bHideCenterMessages = DrawLevelAction(Canvas);

	if ( !bHideCenterMessages && (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) )
		DisplayProgressMessage(Canvas);

	if ( bBadConnectionAlert )
		DisplayBadConnectionAlert();

	if ( bShowDebugInfo )
	{
		YPos = 5;
		UseSmallFont(Canvas);
		PlayerOwner.ViewTarget.DisplayDebug(Canvas,YL,YPos);
	}
	else for ( H=self; H!=None; H=H.NextHUD )
		H.DrawHUD(Canvas);
}

simulated function DrawRoute()
{
	local int i;
	local Controller C;
	local vector Start, End, RealStart;;
	local bool bPath;

	C = Pawn(PlayerOwner.ViewTarget).Controller;
	if ( C == None )
		return;
	if ( C.CurrentPath != None )
		Start = C.CurrentPath.Start.Location;
	else
	Start = PlayerOwner.ViewTarget.Location;
	RealStart = Start;

	if ( C.bAdjusting )
	{
		Draw3DLine(C.Pawn.Location, C.AdjustLoc, class'Canvas'.Static.MakeColor(255,0,255));
		Start = C.AdjustLoc;
	}

	// show where pawn is going
	if ( (C == PlayerOwner)
		|| (C.MoveTarget == C.RouteCache[0]) && (C.MoveTarget != None) )
	{
		if ( (C == PlayerOwner) && (C.Destination != vect(0,0,0)) )
		{
			if ( C.PointReachable(C.Destination) )
			{
				Draw3DLine(C.Pawn.Location, C.Destination, class'Canvas'.Static.MakeColor(255,255,255));
				return;
			}
			C.FindPathTo(C.Destination);
		}
		for ( i=0; i<16; i++ )
		{
			if ( C.RouteCache[i] == None )
				break;
			bPath = true;
			Draw3DLine(Start,C.RouteCache[i].Location,class'Canvas'.Static.MakeColor(0,255,0));
			Start = C.RouteCache[i].Location;
		}
		if ( bPath )
			Draw3DLine(RealStart,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));
	}
	else if ( PlayerOwner.ViewTarget.Velocity != vect(0,0,0) )
		Draw3DLine(RealStart,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));

	if ( C == PlayerOwner )
		return;

	// show where pawn is looking
	if ( C.Focus != None )
		End = C.Focus.Location;
	else
		End = C.FocalPoint;
//R6CODE	Draw3DLine(PlayerOwner.ViewTarget.Location + Pawn(PlayerOwner.ViewTarget).BaseEyeHeight * vect(0,0,1),End,class'Canvas'.Static.MakeColor(255,0,0));
}

/* DrawHUD() Draw HUD elements on canvas.
*/
function DrawHUD(canvas Canvas);

/*  Print a centered level action message with a drop shadow.
*/
/*R6CODE function PrintActionMessage( Canvas C, string BigMessage )
{
	local float XL, YL;

	if ( Len(BigMessage) > 10 )
		UseLargeFont(C);
	else
		UseHugeFont(C);
	C.bCenter = false;
	C.StrLen( BigMessage, XL, YL );
	C.SetPos(0.5 * (C.ClipX - XL) + 1, 0.66 * C.ClipY - YL * 0.5 + 1);
	C.SetDrawColor(0,0,0);
	C.DrawText( BigMessage, false );
	C.SetPos(0.5 * (C.ClipX - XL), 0.66 * C.ClipY - YL * 0.5);
	C.SetDrawColor(0,0,255);;
	C.DrawText( BigMessage, false );
}
*/

/* Display Progress Messages
display progress messages in center of screen
*/
simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float XL, YL, YOffset;
	local GameReplicationInfo GRI;

	PlayerOwner.ProgressTimeOut = FMin(PlayerOwner.ProgressTimeOut, Level.TimeSeconds + 8);
	Canvas.Style = ERenderStyle.STY_Alpha;	
	//R6CODE UseLargeFont(Canvas);
    Canvas.Font = m_FontRainbow6_22pt;
    if(Canvas.Font == none)
        UseLargeFont(Canvas);
	YOffset = 0.3 * Canvas.ClipY;

	for (i=0; i<4; i++)
	{
		Canvas.DrawColor = PlayerOwner.ProgressColor[i];
		Canvas.StrLen(PlayerOwner.ProgressMessage[i], XL, YL);
		Canvas.SetPos(0.5 * (Canvas.ClipX - XL), YOffset);
		Canvas.DrawText(PlayerOwner.ProgressMessage[i], false);
		YOffset += YL + 1;
	}
	Canvas.SetDrawColor(255,255,255);
}

/* Draw the Level Action
*/
/* R6CODE
function bool DrawLevelAction( canvas C )
{
	local string BigMessage;

//
//    if (Level.LevelAction == LEVACT_None )
//	{
//		if ( (Level.Pauser != None) && (Level.TimeSeconds > Level.PauseDelay + 0.2) )
//			BigMessage = PausedMessage; // Add pauser name?
//		else
//		{
//			BigMessage = "";
//			return false;
//		}
//	}
    
	if ( Level.LevelAction == LEVACT_Loading )
		BigMessage = LoadingMessage;
	else if ( Level.LevelAction == LEVACT_Saving )
		BigMessage = SavingMessage;
	else if ( Level.LevelAction == LEVACT_Connecting )
		BigMessage = ConnectingMessage;
	else if ( Level.LevelAction == LEVACT_Precaching )
		BigMessage = PrecachingMessage;
	
	if ( BigMessage != "" )
	{
		C.Style = ERenderStyle.STY_Normal;
		UseLargeFont(C);	
		PrintActionMessage(C, BigMessage);
		return true;
	}
	return false;
}
*/

/* DisplayBadConnectionAlert()
Warn user that net connection is bad
*/
function DisplayBadConnectionAlert();
//=============================================================================
// Messaging.

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
//#ifndef R6CODE
//	if ( bMessageBeep )
//		PlayerOwner.PlayBeepSound();
//#endif // #ifndef R6CODE
	if ( (MsgType == 'Say') || (MsgType == 'TeamSay') )
		Msg = PRI.PlayerName$": "$Msg;
	
    AddTextMessage(Msg,class'LocalMessage');
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString );

simulated function PlayReceivedMessage( string S, string PName, ZoneInfo PZone )
{
	PlayerOwner.ClientMessage(S);
//#ifndef R6CODE
//	if ( bMessageBeep )
//		PlayerOwner.PlayBeepSound();
//#endif // #ifndef R6CODE
}

function bool ProcessKeyEvent( int Key, int Action, FLOAT Delta )
{
	if ( NextHud != None )
		return NextHud.ProcessKeyEvent(Key,Action,Delta);
	return false;
}

/* DisplayMessages() - display current messages
*/
function DisplayMessages(canvas Canvas)
{
/* R6CODE (JFD: done at the end of frame in UnGame.cpp)
	local int i, j, YPos;
	local float XL, YL;

	// first, clean up messages
	for ( i=0; i<4; i++ )
	{
		if ( TextMessages[i] == "" )
			break;
		else if ( MessageLife[i] < Level.TimeSeconds )
		{
			TextMessages[i] = "";
			if ( i < 3 )
			{
				for ( j=i; j<3; j++ )
				{
					TextMessages[j] = TextMessages[j+1];
					MessageLife[j] = MessageLife[j+1];
				}
			}
			TextMessages[3] = "";
			break;
		}
	}	
//R6CODE+
	YPos = 50; // avoid to display a string under the HUD
	// UseSmallFont(Canvas);// font is set in r6hud
	// Canvas.SetDrawColor(0,255,255);
//R6CODE-
	for ( i=0; i<4; i++ )
	{
		if ( TextMessages[i] == "" )
			break;
		else
		{
			Canvas.StrLen( TextMessages[i], XL, YL );
			Canvas.SetPos(4, YPos);
			Canvas.DrawText( TextMessages[i], false );
			YPos += YL * (1 + int(XL/Canvas.ClipX));
		}
	}
*/
}

function AddTextMessage(string M, class<LocalMessage> MessageClass)
{
	local int i;
    local int iLifeTime; //R6CODE
    
    //R6CODE
    if(!PlayerOwner.ShouldDisplayIncomingMessages())
        return;

    iLifeTime = MessageClass.Default.LifeTime + 2; //R6CODE

    // R6CONSOLE
    class'Actor'.static.AddMessageToConsole(M, m_ChatMessagesColor);

	// look for empty spot
	for ( i=0; i<c_iTextMessagesMax; i++ )
		if ( TextMessages[i] == "" )
		{
			TextMessages[i] = M;
            //R6CODE
			//MessageLife[i] = Level.TimeSeconds + MessageClass.Default.LifeTime;
            MessageLife[i] = iLifeTime;
			return;
		}
		
	// force add message
	for ( i=0; i<c_iTextMessagesMax-1; i++ )
	{
		TextMessages[i] = TextMessages[i+1];
		MessageLife[i] = MessageLife[i+1];
	}
	
	TextMessages[c_iTextMessagesMax-1] = M;
    //R6CODE
	//MessageLife[3] = Level.TimeSeconds + MessageClass.Default.LifeTime;
    MessageLife[c_iTextMessagesMax-1] = iLifeTime;
}

//R6CODE
function AddDeathTextMessage(string M, class<LocalMessage> MessageClass)
{
	local int i;

    //R6CODE
    if(Level.NetMode != NM_Standalone && !PlayerOwner.ShouldDisplayIncomingMessages())
        return;

    // R6CONSOLE
    class'Actor'.static.AddMessageToConsole(M, m_KillMessagesColor);

	// look for empty spot
	for ( i=0; i<c_iTextKillMessagesMax; i++ )
		if ( TextKillMessages[i] == "" )
		{
			TextKillMessages[i] = M;
            MessageKillLife[i] = MessageClass.Default.LifeTime;
			return;
		}
		
	// force add message
	for ( i=0; i<c_iTextKillMessagesMax-1; i++ )
	{
		TextKillMessages[i] = TextKillMessages[i+1];
		MessageKillLife[i] = MessageKillLife[i+1];
	}
	
	TextKillMessages[c_iTextKillMessagesMax-1] = M;
    MessageKillLife[c_iTextKillMessagesMax-1] = MessageClass.Default.LifeTime;
}

//function AddTextServerMessage(string M, class<LocalMessage> MessageClass)
// R6CODE
function AddTextServerMessage(string M, class<LocalMessage> MessageClass, OPTIONAL int iLifeTime, OPTIONAL byte bMessageUseBigFont )
{
	local int i;

    // R6CONSOLE
    class'Actor'.static.AddMessageToConsole(M, m_ServerMessagesColor, bMessageUseBigFont);

	// look for empty spot
	for ( i=0; i<c_iTextServerMessagesMax; i++ )
		if ( TextServerMessages[i] == "" )
		{
			TextServerMessages[i] = M;
			MessageUseBigFont[i] = bMessageUseBigFont;
            if ( iLifeTime <= 0 )
                MessageServerLife[i] = MessageClass.Default.LifeTime;
            else
                MessageServerLife[i] = iLifeTime;
			return;
		}
		
	// force add message
	for ( i=0; i<c_iTextServerMessagesMax-1; i++ )
	{
		TextServerMessages[i] = TextServerMessages[i+1];
		MessageServerLife[i] = MessageServerLife[i+1];
		MessageUseBigFont[i] = MessageUseBigFont[i+1];
	}

	TextServerMessages[c_iTextServerMessagesMax-1] = M;
	MessageUseBigFont[c_iTextServerMessagesMax-1] = bMessageUseBigFont;
    MessageServerLife[c_iTextServerMessagesMax-1] = MessageClass.Default.LifeTime;
}



//=============================================================================
// Font Selection.

function UseSmallFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = SmallFont;
	else
		Canvas.Font = MedFont;
}

function UseMediumFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = MedFont;
	else
		Canvas.Font = BigFont;
}

function UseLargeFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = BigFont;
	else
		Canvas.Font = LargeFont;
}

function UseHugeFont(Canvas Canvas)
{
	Canvas.Font = LargeFont;
}

defaultproperties
{
     m_ChatMessagesColor=(B=255,G=255,R=255,A=255)
     m_KillMessagesColor=(B=128,G=128,R=255,A=255)
     m_ServerMessagesColor=(B=128,G=255,R=128,A=255)
     LoadingMessage="LOADING"
     SavingMessage="SAVING"
     ConnectingMessage="CONNECTING"
     PausedMessage="PAUSED"
     RemoteRole=ROLE_None
     bHidden=True
}
