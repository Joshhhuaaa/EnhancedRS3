//=============================================================================
//  R6Operative.uc : This class describes a rainbow officer
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================


class R6Operative extends Object native;

var string          m_szOperativeClass;  //Used to get operative Localized info
var int             m_iUniqueID;         //According to the index of the operative in the operative collection
var int				m_iRookieID;		 //According to the index of the rockie operative

var string          m_szCountryID;
var string          m_szCityID;
var string          m_szStateID;
var string          m_szSpecialityID;
var string          m_szHairColorID;
var string          m_szEyesColorID;
var string          m_szGenderID;

var Texture         m_TMenuFace;
var INT             m_RMenuFaceX, m_RMenuFaceY, m_RMenuFaceW, m_RMenuFaceH; //God this is ugly, hack cuz Region is Uwindowbase

var Texture         m_TMenuFaceSmall;
var INT             m_RMenuFaceSmallX, m_RMenuFaceSmallY, m_RMenuFaceSmallW, m_RMenuFaceSmallH; 

var Array<Texture>  m_OperativeFaces;
var string 			m_szGender; 

//Skills
var FLOAT  m_fAssault;
var FLOAT  m_fDemolitions;
var FLOAT  m_fElectronics;
var FLOAT  m_fSniper;
var FLOAT  m_fStealth;
var FLOAT  m_fSelfControl;
var FLOAT  m_fLeadership;
var FLOAT  m_fObservation;

//Status
var int		m_iHealth; //0= Ready, 1=Wounded, 2=Incapacitated, 3=Dead

//Stats  

var int		m_iNbMissionPlayed;
var int		m_iTerrokilled;
var int		m_iRoundsfired;
var int		m_iRoundsOntarget;

//Weapons
var string      m_szPrimaryWeapon;            //R6PrimaryWeaponDescription class name
var string      m_szPrimaryWeaponGadget;      //Token representing type of weapon gadget
var string      m_szPrimaryWeaponBullet;      //Token representing type of bullets
var string      m_szPrimaryGadget;            //R6GadgetDescription class name
var string      m_szSecondaryWeapon;          //R6SecondaryWeaponDescription class name
var string      m_szSecondaryWeaponGadget;    //Token representing type of weapon gadget
var string      m_szSecondaryWeaponBullet;    ///Token representing type of bullets
var string      m_szSecondaryGadget;          //R6GadgetDescription class name
var string      m_szArmor;                    //R6ArmorDescription class name

var name        m_CanUseArmorType;			  //If the operative is limited to use specific armors

function string GetName()
{	
	if (m_iRookieID != -1)
	    return (Localize(m_szOperativeClass,"ID_NAME","R6Operatives",true,true) $ m_iRookieID);
	else
	    return Localize(m_szOperativeClass,"ID_NAME","R6Operatives",true,true);
}

function string GetShortName()
{	
	if (m_iRookieID != -1)
	    return (Localize(m_szOperativeClass,"ID_SHORTNAME","R6Operatives",true,true) $ m_iRookieID);
	else
	    return Localize(m_szOperativeClass,"ID_SHORTNAME","R6Operatives",true,true);
}

function string GetSpeciality() 
{
	return Localize("Speciality", m_szSpecialityID, "R6Operatives");
}

function string GetHistory()
{
	return Localize(m_szOperativeClass,"ID_HISTORY","R6Operatives", false, true);
}

function string GetGender()
{
    return Localize("Gender", m_szGenderID,"R6Common");
}

function string GetCountry()
{
    return Localize("Country", m_szCountryID ,"R6Common");
}

function string GetCity()
{
    return Localize("City", m_szCityID,"R6Common");
}

function string GetState()
{
    return Localize("State", m_szStateID, "R6Common");
}

function string GetHairColor()
{
    return Localize("Color", m_szHairColorID, "R6Common");
}

function string GetEyesColor()
{
    return Localize("Color", m_szEyesColorID, "R6Common");
}

function string GetIDNumber()
{	
	return Localize(m_szOperativeClass, "ID_IDNUMBER", "R6Operatives");
}

function string GetBirthDate()
{	
	return Localize(GetRealOperativeClass(), "ID_BIRTHDATE", "R6Operatives");
}

function string GetHeight()
{	
	return Localize(GetRealOperativeClass(), "ID_HEIGHT", "R6Operatives");
}

function string GetWeight()
{	
	return Localize(GetRealOperativeClass(), "ID_WEIGHT", "R6Operatives");
}

function string GetNbMissionPlayed()
{
    return string(m_iNbMissionPlayed);
}

function string GetNbTerrokilled()
{
    return string(m_iTerrokilled);
}

function string GetNbRoundsfired()
{
    return string(m_iRoundsfired);
}

function string GetNbRoundsOnTarget()
{
    return string(m_iRoundsOntarget);
}

function string GetShootPercent()
{
    if(m_iRoundsfired > 0)
        return string( INT(m_iRoundsOntarget / FLOAT(m_iRoundsfired) * 100));
    else return "0";
}

function string GetTextDescription()
{
    local string szDescription;
    local string szTemp;

    szDescription = Localize("IdentificationField","ID_IDNUMBER","R6Operatives") $ " " $ GetIDNumber() $ Chr(13);
    szDescription = szDescription $ Localize("IdentificationField", "ID_BIRTHPLACE","R6Operatives") $ " " $ GetCountry();
	
    szTemp = GetCountry();
    if (szTemp != "") 
        szDescription = szDescription $ szTemp;
    szTemp = GetCity();
    if (szTemp != "") 
        szDescription = szDescription $ ", " $ szTemp;
    szTemp = GetState();
    if (szTemp != "") 
        szDescription = szDescription $ ", " $ szTemp;
    
    szDescription = szDescription $ Chr(13);

    szDescription = szDescription $ Localize("IdentificationField", "ID_SPECIALITY", "R6Operatives") $ " " $ GetSpeciality() $ Chr(13);
    szDescription = szDescription $ Localize("IdentificationField", "ID_BIRTHDATE", "R6Operatives") $ " " $ GetBirthDate() $ Chr(13);
    szDescription = szDescription $ Localize("IdentificationField", "ID_HEIGHT", "R6Operatives") $ " " $ GetHeight() $ Chr(13);
    szDescription = szDescription $ Localize("IdentificationField", "ID_WEIGHT", "R6Operatives") $ " " $ GetWeight() $ Chr(13);
    szDescription = szDescription $ Localize("IdentificationField", "ID_HAIR", "R6Operatives") $ " " $ GetHairColor() $ Chr(13);
    szDescription = szDescription $ Localize("IdentificationField", "ID_EYES","R6Operatives") $ " " $ GetEyesColor() $ Chr(13);
    szDescription = szDescription $ Localize("IdentificationField", "ID_GENDER","R6Operatives") $ " " $ GetGender();

    return szDescription;
}

function string GetHealthStatus()
{
    local string result;

    switch(m_iHealth)
    {
        case 0:
            result = Localize("Health","ID_READY","R6Common");
            break;
        case 1:
            result = Localize("Health","ID_WOUNDED","R6Common");
            break;
        case 2:
            result = Localize("Health","ID_INCAPACITATED","R6Common");
            break;
        case 3:
            result = Localize("Health","ID_DEAD","R6Common");
            break;
        default :
            result = "UNKNOWN"; 
            break;            
    }    
    return  result;
}

//=============================================================
// IsOperativeReady: return true if operative health status is ready (0)
//=============================================================
function BOOL IsOperativeReady()
{
	return ( m_iHealth == 0);
}

function string GetRealOperativeClass()
{
	local INT iTemp;

	if (m_iRookieID == -1)
	{
		return m_szOperativeClass;
	}

	// 29 is the number of real operatives, backup op follow
	if ( m_iRookieID < 30)
	{
		iTemp = 29 - m_iRookieID;
	}
	else
	{
		iTemp = ( m_iRookieID / 30) - 1;
		iTemp = m_iRookieID - ( 29 + (iTemp * 30));
	}

	return ("R6Operative" $ iTemp);
}

function UpdateSkills()
{
    local INT iD5;
    local INT iD2;
    local FLOAT fDecision;
    local FLOAT fIncreaseSkill;  // The members that don't make part of the mission increase their skill with restriction

    fIncreaseSkill = 0.5;
    
    iD5 = rand(5) + 1; 
    iD2 = rand(2) + 1;
    fDecision = FRand();    // as soon as fDecision is used once, generate a new rand value...

    // -- Health --//

    if(m_iHealth == 1)  //Let's heal up this guy
        m_iHealth = 0;
    else if(m_iHealth > 1)
        return;         //Dead people don't improve :(

    // -- assault skill -- //
    if(m_szSpecialityID == "ID_ASSAULT")
    {
        m_fAssault += (fIncreaseSkill * (FLOAT(iD5+5)/100.f)*(100-m_fAssault));
    }
    else
    {
        m_fAssault += (fIncreaseSkill * (FLOAT(iD2+2)/100.f)*(100-m_fAssault));
    }

    // -- demolitions skill -- //
    if(m_szSpecialityID == "ID_DEMOLITIONS")
    {
        m_fDemolitions += (fIncreaseSkill * (FLOAT(iD5+5)/100.f)*(100-m_fDemolitions));
    }
    else 
    {
        if(fDecision <= 0.2)
        {
            m_fDemolitions += (fIncreaseSkill * (0.02*(100-m_fDemolitions)));
        }
        fDecision = FRand();
    }

    // -- electronics skill -- //
    if(m_szSpecialityID == "ID_ELECTRONICS")
    { 
        m_fElectronics += (fIncreaseSkill * (FLOAT(iD5+5)/100.f)*(100-m_fElectronics));
    }
    else 
    {
        if(fDecision <= 0.2)
        {
            m_fElectronics += (fIncreaseSkill * (0.02*(100-m_fElectronics)));
        }
        fDecision = FRand();
    }

    // -- stealth skill -- //
    if(m_szSpecialityID == "ID_STEALTH")
    {
        m_fStealth += (fIncreaseSkill * (FLOAT(iD5+5)/100.f)*(100-m_fStealth));
    }
    else
    {
        if(fDecision <= 0.2)
        {
            m_fStealth += (fIncreaseSkill * (0.02*(100-m_fStealth)));
        }
        fDecision = FRand();
    }

    // -- sniper skill -- //
    if(m_szSpecialityID == "ID_SNIPER")
    {
        m_fSniper += (fIncreaseSkill * (FLOAT(iD5+5)/100.f)*(100-m_fSniper));
    }
    else
    {
        if(fDecision <= 0.2)
        {
            m_fSniper += (fIncreaseSkill * (0.02*(100-m_fSniper)));    
        }
        fDecision = FRand();
    }

    // -- self control -- //
    if(fDecision <= 0.2)
    {
        m_fSelfControl += (fIncreaseSkill * (0.02*(100-m_fSelfControl)));
	}
    fDecision = FRand();
    
    // -- leadership -- //
    if(fDecision <= 0.2)
    {
        m_fLeadership += (fIncreaseSkill * (0.02*(100-m_fLeadership)));
    }
    fDecision = FRand();

    // -- observation -- //
    if(fDecision <= 0.2)
    {
        m_fObservation += (fIncreaseSkill * (0.02*(100-m_fObservation)));
    }
    fDecision = FRand();
}

function DisplayStats()
{
    log("------------------------");
    log(GetName());
    log("m_fAssault     ="@m_fAssault);
    log("m_fElectronics ="@m_fElectronics);
    log("m_fSniper      ="@m_fSniper);
    log("m_fStealth     ="@m_fStealth);
    log("m_fSelfControl ="@m_fSelfControl);
    log("m_fLeadership  ="@m_fLeadership);
    log("m_fObservation ="@m_fObservation);
    log("========================");
}

function CopyOperative(R6Operative aOperative)
{
    local INT i;

    aOperative.m_szOperativeClass = m_szOperativeClass;
    aOperative.m_szCountryID = m_szCountryID;
    aOperative.m_szCityID = m_szCityID;
    aOperative.m_szStateID = m_szStateID;
    aOperative.m_szSpecialityID = m_szSpecialityID;
    aOperative.m_szHairColorID = m_szHairColorID;
    aOperative.m_szEyesColorID = m_szEyesColorID;
    aOperative.m_szGenderID = m_szGenderID;

    aOperative.m_TMenuFace = m_TMenuFace;
    
    
    for (i=0;i<m_OperativeFaces.Length; i++)
    {
        aOperative.m_OperativeFaces[aOperative.m_OperativeFaces.Length] = m_OperativeFaces[i];
    }
    
    aOperative.m_szGender = m_szGender; 



    //Skills
    aOperative.m_fAssault = m_fAssault;
    aOperative.m_fDemolitions = m_fDemolitions;
    aOperative.m_fElectronics = m_fElectronics;
    aOperative.m_fSniper = m_fSniper;
    aOperative.m_fStealth = m_fStealth;
    aOperative.m_fSelfControl = m_fSelfControl;
    aOperative.m_fLeadership = m_fLeadership;
    aOperative.m_fObservation = m_fObservation;

    //Status
    aOperative.m_iHealth = m_iHealth;

    //Stats  

    aOperative.m_iNbMissionPlayed = m_iNbMissionPlayed;
    aOperative.m_iTerrokilled = m_iTerrokilled;
    aOperative.m_iRoundsfired = m_iRoundsfired;
    aOperative.m_iRoundsOntarget = m_iRoundsOntarget;

}

defaultproperties
{
     m_iUniqueID=-1
     m_iRookieID=-1
     m_RMenuFaceY=420
     m_RMenuFaceW=175
     m_RMenuFaceH=81
     m_RMenuFaceSmallX=456
     m_RMenuFaceSmallY=132
     m_RMenuFaceSmallW=38
     m_RMenuFaceSmallH=42
     m_TMenuFace=Texture'R6MenuOperative.RS6_Memeber_03'
     m_TMenuFaceSmall=Texture'R6MenuOperative.RS6_Memeber_01'
     m_CanUseArmorType="R6ArmorDescription"
     m_szOperativeClass="R6Operative"
     m_szCountryID="ID_SPAIN"
     m_szCityID="ID_MALAGA"
     m_szSpecialityID="ID_ASSAULT"
     m_szHairColorID="ID_BROWN"
     m_szEyesColorID="ID_BLUE"
     m_szGenderID="ID_MALE"
     m_szGender="M"
}
