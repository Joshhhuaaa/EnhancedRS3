//=============================================================================
//  R6InteractiveObjectActionToggleDevice.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/16 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectActionToggleDevice extends R6InteractiveObjectAction;

var(ToggleDevice)           R6IODevice          m_iodevice;
var(ToggleDevice) editinline  Array<R6IOBomb>   m_aIOBombs;

defaultproperties
{
     m_eType=ET_ToggleDevice
}
