/********************************************************************
	created:	2001/06/19
	filename: 	R6TeamStartInfo.uc
	author:		Joel Tremblay
	
	purpose:	Informations set by the menu 
                list all the selected equipment for characters
	
	Modification:

*********************************************************************/

class R6TeamStartInfo extends actor
    native;

var     INT                         m_iNumberOfMembers;
var     R6RainbowStartInfo          m_CharacterInTeam[4];
var     INT                         m_iSpawningPointNumber;

var     R6AbstractPlanningInfo      m_pPlanning;

defaultproperties
{
}
