//=============================================================================
//  R6InteractiveObjectActionLookAt.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/19 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectActionLookAt extends R6InteractiveObjectAction;

var(LookAt)             Actor       m_Target;

defaultproperties
{
     m_eType=ET_LookAt
}
