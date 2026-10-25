//=============================================================================
//  R6InteractiveObjectActionLoopAnim.uc
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/29 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectActionLoopAnim extends R6InteractiveObjectActionPlayAnim;

var(LoopAnim)   Range   m_LoopTime;

defaultproperties
{
     m_eType=ET_LoopAnim
}
