//=============================================================================
//  R6RagDoll.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/21 * Created by Guillaume Borgia
//=============================================================================

class R6Ragdoll extends R6AbstractCorpse
    native;


const NB_PARTICLES = 16;

struct STParticle
{
    var coords  cCurrentPos;
    var vector  vPreviousOrigin;
    var vector  vBonePosition;
    var FLOAT   fMass;
    var INT     iToward;
    var INT     iRefBone;
    var name    boneName;
};

struct STSpring
{
    var INT     iFirst;
    var INT     iSecond;
    var FLOAT   fMinSquared;
    var FLOAT   fMaxSquared;
};

var STParticle      m_aParticle[NB_PARTICLES];
var Array<STSpring> m_aSpring;
var R6AbstractPawn  m_pawnOwner;
var FLOAT           m_fAccumulatedTime;

function TakeAHit( INT iBone, vector vMomentum )
{
    AddImpulseToBone( iBone, vMomentum );
}

function RenderCorpseBones( Canvas c )
{
    RenderBones(c);
}

defaultproperties
{
     RemoteRole=ROLE_AutonomousProxy
     bAlwaysRelevant=True
     m_bShowInHeatVision=True
}
