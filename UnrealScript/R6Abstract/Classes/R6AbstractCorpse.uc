//=============================================================================
//  R6AbstractCorpse.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/12 * Created by Guillaume Borgia
//=============================================================================

class R6AbstractCorpse extends Actor
    native;

function RenderCorpseBones( Canvas c );
function TakeAHit( INT iBone, Vector vMomentum );

native(1802) final function RenderBones( Canvas c );
native(1803) final function FirstInit( R6AbstractPawn pawnOwner );
native(1804) final function AddImpulseToBone( INT iTracedBone, vector vMomentum );

defaultproperties
{
     bHidden=True
}
