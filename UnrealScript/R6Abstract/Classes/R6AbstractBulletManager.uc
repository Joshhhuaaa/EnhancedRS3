//========================================================================================
//  R6AbstractBulletManager.uc :   Abstract class for bullet manager.
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    10/07/2002 * Created by Joel Tremblay
//=============================================================================
class R6AbstractBulletManager extends actor;

function SetBulletParameter( R6EngineWeapon aWeapon );
function InitBulletMgr( Pawn TheInstigator );
function bool AffectActor(INT BulletGroup, actor ActorAffected);
function SpawnBullet(vector vPosition, Rotator rRotation, float fBulletSpeed, BOOL bFirstInShell);

defaultproperties
{
}
