//=============================================================================
// UdpLink: An Internet UDP connectionless socket.
//=============================================================================
class UdpLink extends InternetLink
	native
	transient;

//-----------------------------------------------------------------------------
// Variables.

var() const int BroadcastAddr;

//-----------------------------------------------------------------------------
// Natives.

//#ifdef R6CODE // added by John Bennett - May 2002
native function float GetPlayingTime( string szIPAddr );
native function SetPlayingTime( string szIPAddr, float fLoginTime, float fCurrentTime );
native function CheckForPlayerTimeouts();
native(1221) static final function INT GetMaxAvailPorts();
//#endif R6CODE 

// BindPort: Binds a free port or optional port specified in argument one.
native function int BindPort( optional int Port, optional bool bUseNextAvailable 
//#ifdef R6CODE 
                             , optional out String szLocalBoundIpAddress  
//#endif R6CODE 
                             );

// SendText: Sends text string.  
// Appends a cr/lf if LinkMode=MODE_Line .
native function bool SendText( IpAddr Addr, coerce string Str );

// SendBinary: Send data as a byte array.
native function bool SendBinary( IpAddr Addr, int Count, byte B[255] );

// ReadText: Reads text string.
// Returns number of bytes read.  
native function int ReadText( out IpAddr Addr, out string Str );

// ReadBinary: Read data as a byte array.
native function int ReadBinary( out IpAddr Addr, int Count, out byte B[255] );

//-----------------------------------------------------------------------------
// Events.

// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText( IpAddr Addr, string Text );

// ReceivedLine: Called when data is received and connection mode is MODE_Line.
event ReceivedLine( IpAddr Addr, string Line );

// ReceivedBinary: Called when data is received and connection mode is MODE_Binary.
event ReceivedBinary( IpAddr Addr, int Count, byte B[255] );

defaultproperties
{
     BroadcastAddr=-1
     bAlwaysTick=True
}
