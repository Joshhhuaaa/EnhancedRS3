//=============================================================================
//  R6AbstractNoiseMgr.uc : Store value for sound loudness of MakeNoise
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Created by Guillaume Borgia
//=============================================================================
class R6AbstractNoiseMgr extends Object
	config(sound)
    native
    abstract;

event R6MakeNoise( Actor.ESoundType eType, Actor source );
function R6MakePawnMovementNoise( R6AbstractPawn pawn );
function Init();

defaultproperties
{
}
