//=============================================================================
//  R6InteractiveObjectActionLoopRandomAnim.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/23 * Created by Guillaume Borgia
//=============================================================================
class R6InteractiveObjectActionLoopRandomAnim extends R6InteractiveObjectAction;

var(PlayAnim)   editinline array<name>  m_aAnimName;

function name GetNextAnim()
{
    return m_aAnimName[ Rand(m_aAnimName.Length) ];
}

defaultproperties
{
     m_eType=ET_LoopRandomAnim
}
