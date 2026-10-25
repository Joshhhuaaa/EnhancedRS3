//============================================================================//
// Class            R6DecalsBase.uc 
// Created By       Jean-Francois Dube
// Date             14/11/2002
// Description      R6 base class for decals effect.
//============================================================================//
class R6DecalsBase extends Actor
	native;


simulated function PostBeginPlay()
{
    //bTearOff = true;
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_None
     bNetTemporary=True
     bReplicateMovement=False
     bNetInitialRotation=True
     bUnlit=True
     bGameRelevant=True
}
