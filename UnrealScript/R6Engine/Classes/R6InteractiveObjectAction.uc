//=============================================================================
//  R6InteractiveObjectAction.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/16 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectAction extends Object
	editinlinenew
    abstract;

enum EActionType
{
    ET_Goto,
    ET_PlayAnim,
    ET_LookAt,
    ET_LoopAnim,
    ET_LoopRandomAnim,
    ET_ToggleDevice
};

var                 EActionType     m_eType;
var(Sound)          Sound           m_eSoundToPlay;
var(Sound)          Sound           m_eSoundToPlayStop;
var(Sound)          Range           m_SoundRange;

defaultproperties
{
     m_SoundRange=(Min=20.000000,Max=60.000000)
}
