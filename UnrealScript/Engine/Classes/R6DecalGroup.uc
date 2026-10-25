//============================================================================//
// Class            R6DecalGroup.uc 
// Created By       Cyrille Lauzon
// Date             2001/01/18
// Description      Defines a group of Decals for the manager
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6DecalGroup extends Actor
	native;

import class R6DecalManager;

var(R6DecalGroup) INT m_MaxSize;			//The maximum number of elements the group can contain
var INT m_iDecalPos;						//Position of the current element to remove/add
var(R6DecalGroup) R6DecalManager.eDecalType m_Type;		//Decal type it can contain

//Should not be manipulated directly!-------
var(R6DecalGroup) array<R6Decal> m_Decals;
var(R6DecalGroup) bool		     m_bActive; 

native(2902) final function AddDecal(vector position, rotator rotation, Texture decalTexture, INT iFov, FLOAT fDuration, FLOAT fStartTime, FLOAT fMaxTraceDistance, optional FLOAT fCullDistance);
native(2903) final function KillDecal();
native(2904) final function ActivateGroup();
native(2905) final function DeActivateGroup();

defaultproperties
{
     m_MaxSize=150
     bHidden=True
}
