//=============================================================================
// SavedMove is used during network play to buffer recent client moves,
// for use when the server modifies the clients actual position, etc.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class SavedMove extends Info;

// also stores info in Acceleration attribute
var SavedMove NextMove;		// Next move in linked list.
var float TimeStamp;		// Time of this move.
var float Delta;			// Distance moved.
var bool	bRun;
var bool	bDuck;
//rb var bool	bPressedJump;	
var EDoubleClickDir DoubleClickMove;	// Double click info.
// #ifdef R6PlayerMovements
var bool    m_bCrawl;
// #endif R6PlayerMovements


final function Clear()
{
	TimeStamp = 0;
	Delta = 0;
	DoubleClickMove = DCLICK_None;
	Acceleration = vect(0,0,0);
	bRun = false;
	bDuck = false;
//rb	bPressedJump = false;
// #ifdef R6PlayerMovements
    m_bCrawl = false;
// #endif R6PlayerMovements
}

final function SetMoveFor(PlayerController P, float DeltaTime, vector NewAccel, EDoubleClickDir InDoubleClick)
{
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	if ( Delta > 0 )
		Acceleration = (DeltaTime * NewAccel + Delta * Acceleration)/(Delta + DeltaTime);
	else
		Acceleration = NewAccel;
	Delta += DeltaTime;
	
	if ( DoubleClickMove == eDoubleClickDir.DCLICK_None )
		DoubleClickMove = InDoubleClick;
	bRun = (P.bRun > 0);
	bDuck = (P.bDuck > 0);
	//rb bPressedJump = P.bPressedJump || bPressedJump;
	TimeStamp = Level.TimeSeconds;
    // #ifdef R6PlayerMovements
    m_bCrawl = P.m_bCrawl;
    // #endif R6PlayerMovements
}

defaultproperties
{
}
