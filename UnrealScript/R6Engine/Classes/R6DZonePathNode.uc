//=============================================================================
//  R6DZonePathNode.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================

class R6DZonePathNode extends Actor
	placeable
    native;

var             R6DZonePath     m_pPath;
var(R6DZone)    FLOAT           m_fRadius;
var(R6DZone)    BOOL            m_bWait;
var(R6DZone)    name            m_AnimToPlay;
var(R6DZone)    INT             m_AnimChance;
var(R6DZone)    Sound           m_SoundToPlay;
var(R6DZone)    Sound           m_SoundToPlayStop;

event Destroyed()
{
}

defaultproperties
{
     m_bWait=True
     m_fRadius=50.000000
     bHidden=True
     m_bUseR6Availability=True
     CollisionRadius=40.000000
     CollisionHeight=85.000000
     Texture=Texture'R6Engine_T.Icons.DZoneTer'
}
