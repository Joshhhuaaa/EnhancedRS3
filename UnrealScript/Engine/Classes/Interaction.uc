// ====================================================================
//  Class:  Engine.Interaction
//  
//  Each individual Interaction is a jumping point in UScript.  The should
//  be the foundatation for any subsystem that requires interaction with
//  the player (such as a menu).  
//
//  Interactions take on two forms, the Global Interaction and the Local
//  Interaction.  The GI get's to process data before the LI and get's
//  render time after the LI, so in essence the GI wraps the LI.
//
//  A dynamic array of GI's are stored in the InteractionMaster while
//  each Viewport contains an array of LIs.
//
//
// (c) 2001, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class Interaction extends Interactions;

var bool bActive;			// Is this interaction Getting Input
var bool bVisible;			// Is this interaction being Displayed
var bool bRequiresTick; 	// Does this interaction require game TICK

// These entries get filled out upon creation.

var Player ViewportOwner;		// Pointer to the ViewPort that "Owns" this interaction or none if it's Global
var InteractionMaster Master;	// Pointer to the Interaction Master

//-----------------------------------------------------------------------------
// natives.

native function Initialize();							// setup the state system and stack frame
native function bool ConsoleCommand( coerce string S );	// Executes a console command

// WorldToScreen converts a vector in the world 

// ====================================================================
// WorldToScreen - Returns the X/Y screen coordinates in to a viewport of a given vector
// in the world. 
// ====================================================================
native function vector WorldToScreen(vector Location, optional vector CameraLocation, optional rotator CameraRotation);

// ====================================================================
// ScreenToWorld - Converts an X/Y screen coordinate in to a world vector
// ====================================================================
native function vector ScreenToWorld(vector Location, optional vector CameraLocation, optional rotator CameraRotation); 

// ====================================================================
// Initialized - Called directly after an Interaction Object has been created
// and Initialized.  Should be subclassed
// ====================================================================

event Initialized(); 
event ServerDisconnected();
//#ifdef R6CODE
event UserDisconnected(); //The user asked to be disconnected
//#endif // #ifdef R6CODE
event ConnectionFailed();
//#ifdef R6CODE
event R6ConnectionFailed( string szError );
event R6ConnectionSuccess();
event R6ConnectionInterrupted();
event R6ConnectionInProgress();
event R6ProgressMsg( string _Str1, string _Str2, FLOAT Seconds);
function object SetGameServiceLinks(PlayerController _localPlayer);
event NotifyLevelChange();
event NotifyAfterLevelChange();
event MenuLoadProfile( BOOL _bServerProfile);
event LaunchR6MainMenu();
event string GetStoreGamePwd();
//#endif R6Code

function SendGoCode(EGoCode eGo);
// ====================================================================
// Message - This event allows interactions to receive messages
// ====================================================================

function Message( coerce string Msg, float MsgLife)
{
} // Message

// ====================================================================
// ====================================================================
// Input Routines - These two routines are the entry points for input.  They both
// return true if the data has been processed and should now discarded.

// Both functions should be handled in a subclass of Interaction
// ====================================================================
// ====================================================================

function bool KeyType( out EInputKey Key )
{
	return false;	
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	return false;
}

// ====================================================================
// ====================================================================
// Render Routines - All Interactions recieve both PreRender and PostRender
// calls.

// Both functions should be handled in a subclass of Interaction
// ====================================================================
// ====================================================================


function PreRender( canvas Canvas );
function PostRender( canvas Canvas );

// ====================================================================
// SetFocus - This function cases the Interaction to gain "focus" in the interaction
// system.  Global interactions's focus superceed locals.
// ====================================================================

function SetFocus()
{
	Master.SetFocusTo(self,ViewportOwner);

} // SetFocus
	
// ====================================================================
// Tick - By default, Interactions do not get ticked, but you can
// simply turn on bRequiresTick.
// ====================================================================

function Tick(float DeltaTime);

//#ifdef R6CODE
// ====================================================================
// ConvertKeyToLocalisation: This is convert a key to the name of the key localization
// Ex: english to french : A is A -- Space is Espace -- Backspace is reculer etc...
//	   the localization is in R6Menu.int 
// ====================================================================
event string ConvertKeyToLocalisation( BYTE _Key, string _szEnumKeyName)
{
	local string szResult;

	// number
	if (( _Key > EInputKey.IK_0 - 1) && ( _Key < EInputKey.IK_9 + 1))
	{
		szResult = string(_Key - EInputKey.IK_0);
	}
	// alphabet
	else if (( _Key > EInputKey.IK_A - 1) && ( _Key < EInputKey.IK_Z + 1))
	{
		szResult = Chr(_Key);
	}
	// F1 to F24
	else if (( _Key > EInputKey.IK_F1 - 1) && ( _Key < EInputKey.IK_F24 + 1))
	{
		szResult = "F"$(_Key - EInputKey.IK_F1 + 1); //+1 because of the substraction
	}
	else
	{
		szResult = Localize("Interactions", "IK_"$_szEnumKeyName, "R6Menu");
		
		// if the key is not define
		if ( szResult == Localize("Interactions", "IK_None", "R6Menu"))
		{
			szResult = "";
		}
	}

	return szResult;
}
//#endif R6CODE

defaultproperties
{
     bActive=True
}
