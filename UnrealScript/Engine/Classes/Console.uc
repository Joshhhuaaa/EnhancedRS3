//=============================================================================
// Console - A quick little command line console that accepts most commands.

//=============================================================================
class Console extends Interaction;

//#ifndef R6CODE
//#exec new TrueTypeFontFactory PACKAGE="Engine" Name=ConsoleFont FontName="Verdana" Height=12 AntiAlias=1 CharactersPerPage=256
//#endif
#exec TEXTURE IMPORT NAME=ConsoleBK FILE=..\UWindow\TEXTURES\Black.PCX	
#exec TEXTURE IMPORT NAME=ConsoleBdr FILE=..\UWindow\TEXTURES\White.PCX	
	
// Constants.
const MaxHistory=16;		// # of command histroy to remember.

// Variables

var globalconfig byte ConsoleKey;			// Key used to bring up the console

var int HistoryTop, HistoryBot, HistoryCur;
var string TypedStr, History[MaxHistory]; 	// Holds the current command, and the history
var bool bTyping;							// Turn when someone is typing on the console							
var bool bIgnoreKeys;						// Ignore Key presses until a new KeyDown is received	

//R6CODE
var bool bShowLog;
var bool bShowConsoleLog;
var bool m_bStringIsTooLong;
var bool m_bStartedByGSClient;  // Flag to indicate if the game was launched by the ubi.com client
var bool m_bNonUbiMatchMaking;  // Flag to indicate that this game will not be using UBI.com
var bool m_bNonUbiMatchMakingHost;  // Flag to indicate that this host will not be using UBI.com
var bool m_bInterruptConnectionProcess; // Flag to indicate that a process is interrupted by user or not
var bool m_bAutoLoginFirstPass;
var bool m_bChangeModInProgress;

var globalconfig int     iBrowserMaxNbServerPerPage;


//R6CODE
#ifdefDEBUG
exec function ListMods()
{
    local R6ModMgr modMgr;
    local int i;
    local string s;

    modMgr = class'Actor'.static.GetModMgr();

    log( "MODS" );
    for ( i = 0; i < modMgr.m_aMods.Length; ++i )
    {
        s = modMgr.m_aMods[i].m_szName$ " Keyword=" $modMgr.m_aMods[i].m_szKeyWord;

        s = s$ "(";
        if ( modMgr.m_aMods[i].m_bInstalled ) 
            s = s $ Localize( "Misc", "Installed", "R6Mod" );
        else
            s = s $ Localize( "Misc", "NotInstalled", "R6Mod" );
        s = s $")";
        
        log( s );
    }
}

exec function ShowModInfo()
{
    class'Actor'.static.GetModMgr().m_pCurrentMod.LogInfo();
}

exec function ListRegObj()
{
    class'Actor'.static.GetModMgr().DebugRegisterObject( "list" );
}
#endif

function GetAllMissionDescriptions(string szCurrentMapDir);

//-----------------------------------------------------------------------------
// Exec functions accessible from the console and key bindings.

// Begin typing a command on the console.
exec function Type()
{
	TypedStr="";
    bShowConsoleLog=true;
	GotoState( 'Typing' );
}
 
exec function Talk()
{
    TypedStr="Say ";
    bShowConsoleLog=false;
	GotoState( 'Typing' );
}

exec function TeamTalk()
{
    local GameReplicationInfo gameinfo;

    // if not an adversarial team base game, return
    // R6CODE+
	if ( ViewportOwner.Actor != none )
    {
        gameinfo = ViewportOwner.Actor.GameReplicationInfo;
        if ( !ViewportOwner.Actor.Level.IsGameTypeTeamAdversarial( gameinfo.m_szGameTypeFlagRep ) )
        {
            return;
        }
    }
    // R6CODE-

    TypedStr="TeamSay ";
    bShowConsoleLog=false;
	GotoState( 'Typing' );
}

//-----------------------------------------------------------------------------
// Message - By default, the console ignores all output.
//-----------------------------------------------------------------------------

event Message( coerce string Msg, float MsgLife);

//-----------------------------------------------------------------------------
// Check for the console key.

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
    if(bShowLog)log("Console state \" KeyEvent eAction"@Action@"Key"@Key);
	if( Action!=IST_Press )
		return false;
	else if( Key==ConsoleKey )
	{
		GotoState('Typing');
		return true;
	}
	else 
		return false;

} 

function bool KeyType( EInputKey Key )
{
    if(bShowLog)log("Console state \" KeyType Key"@Key);
	
	return false;

}

//-----------------------------------------------------------------------------
// State used while typing a command on the console.

state Typing
{
	exec function Type()
	{
		TypedStr="";
		gotoState( '' );
	}
	function bool KeyType( EInputKey Key )
	{
        //R6CONSOLE
        local String OutStr;
        local float  xl,yl;

        if(bShowLog)log("Console state Typing KeyType Key"@Key);
		if (bIgnoreKeys)		
			return true;

        //R6CODE
        if(m_bStringIsTooLong)
            return true;
	
		if( Key>=0x20 && Key<0x100 && Key!=Asc("~") && Key!=Asc("`") )
		{
			TypedStr = TypedStr $ Chr(Key);

            //R6CONSOLE
            class'Actor'.static.GetCanvas().Font = class'Actor'.static.GetCanvas().SmallFont;
    		OutStr = "(>"@TypedStr$"_";
	    	class'Actor'.static.GetCanvas().Strlen(OutStr,xl,yl);
            if(xl > class'Actor'.static.GetCanvas().SizeX * 0.95)
                m_bStringIsTooLong = true;

			return true;
		}
	}
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;
		local int i;
        

	    if(bShowLog)log("Console state Typing KeyEvent Action"@Action@"Key"@Key);

		if (Action== IST_Press)
		{
			bIgnoreKeys=false;
		}
	
		if( Key==IK_Escape )
		{
			if( TypedStr!="" )
			{
				TypedStr="";
				HistoryCur = HistoryTop;
				return true;
			}
			else
			{
				GotoState( '' );
			}
		}
		else if( global.KeyEvent( Key, Action, Delta ) )
		{
			return true;
		}
		else if( Action != IST_Press )
		{
			return false;
		}
		else if( Key==IK_Enter )
		{
			if( TypedStr!="" )
			{
				// Print to console.
				Message( TypedStr, 6.0 );

				History[HistoryTop] = TypedStr;
				HistoryTop = (HistoryTop+1) % MaxHistory;
				
				if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
					HistoryBot = (HistoryBot+1) % MaxHistory;

				HistoryCur = HistoryTop;

				// Make a local copy of the string.
				Temp=TypedStr;
				TypedStr="";
				
				if( !ConsoleCommand( Temp ) )
					Message( Localize("Errors","Exec","R6Engine"), 6.0 );
					
				Message( "", 6.0 );
				GotoState('');
			}
			else
				GotoState('');
				
			return true;
		}
		else if( Key==IK_Up )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryBot)
					HistoryCur = HistoryTop;
				else
				{
					HistoryCur--;
					if (HistoryCur<0)
						HistoryCur = MaxHistory-1;
				}
				
				TypedStr = History[HistoryCur];
			}
			return True;
		}
		else if( Key==IK_Down )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryTop)
					HistoryCur = HistoryBot;
				else
					HistoryCur = (HistoryCur+1) % MaxHistory;
					
				TypedStr = History[HistoryCur];
			}			

		}
		else if( Key==IK_Backspace || Key==IK_Left )
		{
			if( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);

			return true;
		}
		return true;
	}
	
	function PostRender(Canvas Canvas)
	{
/* R6CONSOLE
		local float xl,yl;
		local string OutStr;

		// Blank out a space
		Canvas.Style = 1;
		
        //R6CONSOLE
		//Canvas.Font	 = font'ConsoleFont';
        Canvas.Font = Canvas.SmallFont;
		OutStr = "(>"@TypedStr$"_";
		Canvas.Strlen(OutStr,xl,yl);

		Canvas.SetPos(0,Canvas.ClipY-6-yl);
		Canvas.DrawTile( texture 'ConsoleBk', Canvas.ClipX, yl+6,0,0,32,32);

		Canvas.SetPos(0,Canvas.ClipY-8-yl);	
        //R6CONSOLE
        //Canvas.SetDrawColor(0,255,0);
        Canvas.SetDrawColor(128,128,128);
		Canvas.DrawTile( texture 'ConsoleBdr', Canvas.ClipX, 2,0,0,32,32);

        Canvas.SetDrawColor(255,255,255);//R6CONSOLE
		Canvas.SetPos(0,Canvas.ClipY-3-yl);
		Canvas.bCenter = False;
		Canvas.DrawText( OutStr, false );
*/
		local float xl,yl;
		local string OutStr;
		//R6CODE
		local float OrgX, OrgY;

		OrgX = Canvas.OrgX;
		OrgY = Canvas.OrgY;

		Canvas.SetOrigin( 0, 0);
		//END OF R6CODE

        //R6CONSOLE
        Canvas.ClipX = Canvas.SizeX;
        Canvas.ClipY = Canvas.SizeY;

		// Blank out a space
		Canvas.Style = 1;
		
        Canvas.Font = Canvas.SmallFont;
		OutStr = ">"@TypedStr$"_";
		Canvas.Strlen(OutStr,xl,yl);

		Canvas.SetPos(0,Canvas.SizeY-6-yl);
		Canvas.DrawTile(texture 'ConsoleBk', Canvas.SizeX, yl+6,0,0,32,32);

		Canvas.SetPos(0,Canvas.SizeY-8-yl);	
        Canvas.SetDrawColor(128,128,128);
		Canvas.DrawTile(texture 'ConsoleBdr', Canvas.SizeX, 2,0,0,32,32);

        Canvas.SetDrawColor(255,255,255);
		Canvas.SetPos(0,Canvas.SizeY-3-yl);
		Canvas.bCenter = False;
		Canvas.DrawText(OutStr, false);

		//R6CODE
		Canvas.SetOrigin(OrgX, OrgY);
		//END OF R6CODE
	}
	
	function BeginState()
	{
		bTyping = true;
		bVisible= true;
		bIgnoreKeys = true;
		HistoryCur = HistoryTop;
        //R6CODE
        m_bStringIsTooLong = false;
	}
	function EndState()
	{
		bTyping = false;
		bVisible = false;
	}
}

defaultproperties
{
     ConsoleKey=192
     HistoryBot=-1
     iBrowserMaxNbServerPerPage=400
     bRequiresTick=True
}
