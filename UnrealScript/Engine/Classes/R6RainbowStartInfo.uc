/********************************************************************
	created:	2001/06/19
	filename: 	R6RainbowStartInfo.uc
	author:		Joel Tremblay
	
	purpose:	Informations set by the menu 
                list all the selected equipment for characters
	
	Modification:

*********************************************************************/

class R6RainbowStartInfo extends actor
    native;

var   string m_CharacterName;
var   string m_ArmorName;
var   string m_szSpecialityID;
var   string m_WeaponName[2];
var   string m_BulletType[2];
var   string m_WeaponGadgetName[2];
var   string m_GadgetName[2];
var   FLOAT  m_fSkillAssault;		 // for the skills see definition in class r6pawn
var	  FLOAT  m_fSkillDemolitions;
var   FLOAT  m_fSkillElectronics;
var   FLOAT  m_fSkillSniper;
var   FLOAT  m_fSkillStealth;
var   FLOAT  m_fSkillSelfControl;
var   FLOAT  m_fSkillLeadership;
var   FLOAT  m_fSkillObservation;
var   int    m_iHealth; //0= Ready, 1=Wounded, 2=Incapacitated, 3=Dead
var   int    m_iOperativeID; //Allow us to retreive the corresponding R6Operative
var   bool   m_bIsMale;      //Sex of the operative
var   Plane  m_FaceCoords;
var   Material m_FaceTexture;

defaultproperties
{
     m_bIsMale=True
     bHidden=True
}
