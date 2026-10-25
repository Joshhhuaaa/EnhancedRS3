//=============================================================================
//  R6Door.uc : One of these actors should be placed on either side of each door
//              used for detection of pawns and for maintaining info about the 
//              surroundings.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/31 * Created by Rima Brek
//=============================================================================
class R6Door extends NavigationPoint
	native
    notplaceable;

#exec Texture Import File=Textures\S_DoorNavP.bmp Name=S_DoorNavP Mips=Off MASKED=1

var     vector          m_vLookDir;
var()   R6Door          m_CorrespondingDoor;
var()   R6IORotatingDoor  m_RotatingDoor;

var     bool            m_bCloseOnUntouch;

var()   enum eRoomLayout
{
    ROOM_OpensCenter,
    ROOM_OpensLeft,       
    ROOM_OpensRight,
    ROOM_None
} m_eRoomLayout;

function PostBeginPlay()
{
	Super.PostBeginPlay();
    m_vLookDir = vector(Rotation);
    m_vLookDir = normal(m_vLookDir);
}

function Touch(Actor other)
{
	local   R6Pawn      pawn;
    local   rotator     rPawnRot;

	pawn = R6Pawn(other);    
    if(pawn == none)
        return;

    if ( pawn.m_ePawnType == PAWN_Hostage || pawn.m_ePawnType == PAWN_Terrorist )
        return;

    //log( "[" $ Level.TimeSeconds $ "]" $ name $ " Touch actor.  Door closed: " $ m_RotatingDoor.m_bIsDoorClosed );

	rPawnRot = pawn.rotation;
	rPawnRot.pitch = 0;  	
	pawn.PotentialOpenDoor(self);

    super.Touch(other);
}

function UnTouch(Actor other)
{
	local R6Pawn pawn;

  	pawn = R6Pawn(other);
    if(pawn == none)
        return;

    //log( "[" $ Level.TimeSeconds $ "]" $ name $ " Untouch actor.  Door closed: " $ m_RotatingDoor.m_bIsDoorClosed );

    pawn.RemovePotentialOpenDoor(self);
    super.UnTouch(other);
}

defaultproperties
{
     ExtraCost=300
     m_bExactMove=True
     bCollideWhenPlacing=False
     bCollideActors=True
     bDirectional=True
     CollisionRadius=96.000000
     CollisionHeight=90.000000
     Texture=Texture'R6Engine.S_DoorNavP'
}
