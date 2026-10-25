//=============================================================================
//  R6EnvironmentNode.uc : nodes that contain information about the environment,
//                          location of walls, corners, etc...
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/20 * Created by Rima Brek
//=============================================================================
class R6EnvironmentNode extends Actor
	native
    placeable;

var         vector          m_vLookDir;

function PostBeginPlay()
{
	Super.PostBeginPlay();
    m_vLookDir = vector(Rotation);
    m_vLookDir = normal(m_vLookDir);
}

function Touch(Actor other)
{
}

function UnTouch(Actor other)
{
}

defaultproperties
{
     bCollideActors=True
     bDirectional=True
}
