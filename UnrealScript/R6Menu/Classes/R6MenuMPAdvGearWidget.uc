//=============================================================================
//  R6MenuMPAdvGearWidget.uc : GearRoomMenu for multi-player adverserial
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/24 * Created by Alexandre Dionne
//=============================================================================

class R6MenuMPAdvGearWidget extends R6MenuWidget;


enum e2DEquipment
{
    Primary_Weapon,
    Primary_WeaponGadget,
    Primary_Bullet,
    Primary_Gadget,
    Secondary_Weapon,
    Secondary_WeaponGadget,
    Secondary_Bullet,
    Secondary_Gadget
};

var R6MenuMPAdvEquipmentSelectControl	m_Equipment2dSelect; //Left part where we can take a look a selected equipment 
var R6MenuMPAdvEquipmentDetailControl   m_EquipmentDetails;  //Right side when looking at an equipment item

var R6Operative                         m_currentOperative;

var R6Operative m_BkpOperative;

var class<R6PrimaryWeaponDescription>   m_OpFirstWeaponDesc;    //Equipment of the selected Operative          
var class<R6SecondaryWeaponDescription> m_OpSecondaryWeaponDesc;
var class<R6WeaponGadgetDescription>    m_OpFirstWeaponGadgetDesc,  m_OpSecondWeaponGadgetDesc;
var class<R6BulletDescription>          m_OpFirstWeaponBulletDesc,  m_OpSecondWeaponBulletDesc;
var class<R6GadgetDescription>          m_OpFirstGadgetDesc,        m_OpSecondGadgetDesc;

var e2DEquipment						m_e2DCurEquipmentSel;

//debug
var INT	m_iCounter;
var bool        bshowlog;

var string PrimaryGadgetDesc; //MissionPack1   // MPF1
var R6DescPrimaryMags	m_PrimaryMagsGadget;

function Created()
{
	local int LabelWidth;
    local Region R;    

	local INT i,j;
	local R6Mod	pCurrentMod;
	local class<R6DescPrimaryMags> ExtraMags;

    m_currentOperative = new(None) class'R6Operative'; 
    
	m_BkpOperative = new (none) Class'R6Game.R6Operative';
    m_Equipment2dSelect = R6MenuMPAdvEquipmentSelectControl(CreateWindow(class'R6MenuMPAdvEquipmentSelectControl', 0, 0, 241, WinHeight, self));
    m_EquipmentDetails  = R6MenuMPAdvEquipmentDetailControl(CreateWindow(class'R6MenuMPAdvEquipmentDetailControl', m_Equipment2dSelect.WinWidth -1, 0, WinWidth - m_Equipment2dSelect.WinWidth +1, WinHeight, self));
    GetMenuComEquipment( true);
    m_Equipment2dSelect.Init();
	m_PrimaryMagsGadget = new(none) class'R6Description.R6DescPrimaryMags';

	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod; 
	for (i = 0; i < pCurrentMod.m_aDescriptionPackage.Length; i++)
	{
		if(pCurrentMod.m_aDescriptionPackage[i] != "R6Description")
		{
			ExtraMags = class<R6DescPrimaryMags>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[i]$".u", class'R6DescPrimaryMags'));
			while((ExtraMags != None))
			{
				for(j = 0; j < ExtraMags.Default.m_iNewTagsToAdd; j++)
				{
					m_PrimaryMagsGadget.m_Mags[m_PrimaryMagsGadget.m_Mags.Length] = ExtraMags.Default.m_Mags[j];
					m_PrimaryMagsGadget.m_MagTags[m_PrimaryMagsGadget.m_MagTags.Length] = ExtraMags.Default.m_MagTags[j];
				}
				ExtraMags = class<R6DescPrimaryMags>(GetNextClass());
			}
		}  
	}
}

function ShowWindow()
{  
    Super.ShowWindow();
   
    GetMenuComEquipment( false);        
    m_Equipment2dSelect.UpdateDetails();    
}

function GetMenuComEquipment(bool _bCkeckEquipment)
{
    local R6MenuInGameMultiPlayerRootWindow r6Root;

    r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
    if(_bCkeckEquipment)
    {
        m_currentOperative.m_szPrimaryWeaponBullet = r6Root.m_R6GameMenuCom.m_szPrimaryWeaponBullet;
        m_currentOperative.m_szSecondaryWeaponBullet = r6Root.m_R6GameMenuCom.m_szSecondaryWeaponBullet;
        m_currentOperative.m_szArmor = r6Root.m_R6GameMenuCom.m_szArmor;
        VerifyAllEquipment(r6Root.m_R6GameMenuCom.m_szPrimaryWeapon, r6Root.m_R6GameMenuCom.m_szPrimaryWeaponGadget, r6Root.m_R6GameMenuCom.m_szPrimaryGadget, r6Root.m_R6GameMenuCom.m_szSecondaryWeapon, r6Root.m_R6GameMenuCom.m_szSecondaryWeaponGadget, r6Root.m_R6GameMenuCom.m_szSecondaryGadget);
    }
    r6Root.m_R6GameMenuCom.m_szPrimaryWeapon = m_currentOperative.m_szPrimaryWeapon;
    r6Root.m_R6GameMenuCom.m_szPrimaryWeaponGadget = m_currentOperative.m_szPrimaryWeaponGadget;
    r6Root.m_R6GameMenuCom.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;
    r6Root.m_R6GameMenuCom.m_szSecondaryWeapon = m_currentOperative.m_szSecondaryWeapon;
    r6Root.m_R6GameMenuCom.m_szSecondaryWeaponGadget = m_currentOperative.m_szSecondaryWeaponGadget;
    r6Root.m_R6GameMenuCom.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;
    SetOperativeEquipment(false);
    SetClassEquipment();
}

function VerifyAllEquipment(string _szPrimaryWeapon, string _szPrimaryWeaponGadget, string _szPrimaryGadget, string _szSecondaryWeapon, string _szSecondaryWeaponGadget, string _szSecondaryGadget)
{
    m_currentOperative.m_szPrimaryWeapon = VerifyEquipment(e2DEquipment.Primary_Weapon, _szPrimaryWeapon);
    m_currentOperative.m_szPrimaryWeaponGadget = VerifyEquipment(e2DEquipment.Primary_WeaponGadget, _szPrimaryWeaponGadget);
    m_currentOperative.m_szPrimaryGadget = VerifyEquipment(e2DEquipment.Primary_Gadget, _szPrimaryGadget);
    m_currentOperative.m_szSecondaryWeapon = VerifyEquipment(e2DEquipment.Secondary_Weapon, _szSecondaryWeapon);
    m_currentOperative.m_szSecondaryWeaponGadget = VerifyEquipment(e2DEquipment.Secondary_WeaponGadget, _szSecondaryWeaponGadget);
    m_currentOperative.m_szSecondaryGadget = VerifyEquipment(e2DEquipment.Secondary_Gadget, _szSecondaryGadget);
}

function string VerifyEquipment( INT _equipmentType, string _szEquipmentToValid) // this could be done in BuildAvailableEquipment
{
    local R6MenuInGameMultiPlayerRootWindow r6Root;
	local string szEquipmentFind;
	local INT i;
    local class<R6PrimaryWeaponDescription>            PriWpnClass;
	local string szClassName;
	local BOOL   bFound;
	local class<R6GadgetDescription> replacedGadgetClass; // MissionPack1 // MPF1

    r6Root = R6MenuInGameMultiPlayerRootWindow(Root);    

	switch( _equipmentType)
	{
		case e2DEquipment.Primary_Weapon:
			szEquipmentFind = _szEquipmentToValid;

			bFound = FALSE;
			for ( i = 0; i < m_EquipmentDetails.m_APrimaryWeapons.Length && !bFound; i++ )
			{
				szClassName = ""$m_EquipmentDetails.m_APrimaryWeapons[i];

				if ( szClassName ~= _szEquipmentToValid )
				{
					bFound = TRUE;
				}
			}
			if ( !bFound )
				szEquipmentFind = "R6Description.R6DescPrimaryWeaponNone";
			break;
		case e2DEquipment.Primary_WeaponGadget:
			szEquipmentFind = _szEquipmentToValid;

			bFound = FALSE;
			for ( i = 0; i < m_EquipmentDetails.m_APriWpnGadget.Length && !bFound; i++ )
			{
				szClassName = ""$m_EquipmentDetails.m_APriWpnGadget[i];
				
				if ( szClassName ~= _szEquipmentToValid )
				{
					bFound = TRUE;
				}
			}
			
			if ( !bFound )
				szEquipmentFind = "R6Description.R6DescWeaponGadgetNone";
			break;
		case e2DEquipment.Primary_Gadget:
			szEquipmentFind = _szEquipmentToValid;

                        // MPF1
			// If the gametype doesn't allow some gadget, replace it with something else
			if(CheckGadget(szEquipmentFind,self, false,replacedGadgetClass))// MissionPack1
				szEquipmentFind = string(replacedGadgetClass);
			PrimaryGadgetDesc = szEquipmentFind; 
		    //End MissionPack1	

			bFound = FALSE;
			for ( i = 0; i < m_EquipmentDetails.m_AGadgets.Length && !bFound; i++ )
			{
				szClassName = ""$m_EquipmentDetails.m_AGadgets[i];

                                // MPF1
				if ( szClassName ~= szEquipmentFind /*MissionPack1 _szEquipmentToValid*/) 		
				{
					bFound = TRUE;
				}
			}
			if ( !bFound )
				szEquipmentFind = "R6Description.R6DescGadgetNone";
			break;
		case e2DEquipment.Secondary_Weapon:
			szEquipmentFind = _szEquipmentToValid;

			bFound = FALSE;
			for ( i = 0; i < m_EquipmentDetails.m_ASecondaryWeapons.Length && !bFound; i++ )
			{
				szClassName = ""$m_EquipmentDetails.m_ASecondaryWeapons[i];

				if ( szClassName ~= _szEquipmentToValid )
				{
					bFound = TRUE;
				}
			}
			if ( !bFound )
			{
				szEquipmentFind = "R6Description.R6DescPistol92FS";
				r6Root.m_R6GameMenuCom.m_szSecondaryWeaponGadget = "R6Description.R6DescGadgetNone";
			}
			break;
		case e2DEquipment.Secondary_WeaponGadget:
			szEquipmentFind = _szEquipmentToValid;

			bFound = FALSE;
			for ( i = 0; i < m_EquipmentDetails.m_ASecWpnGadget.Length && !bFound; i++ )
			{
				szClassName = ""$m_EquipmentDetails.m_ASecWpnGadget[i];

				if ( szClassName ~= _szEquipmentToValid )
				{
					bFound = TRUE;
				}
			}
			if ( !bFound )
				szEquipmentFind = "R6Description.R6DescWeaponGadgetNone";
			break;
		case e2DEquipment.Secondary_Gadget:
			szEquipmentFind = _szEquipmentToValid;

		        // MPF1
			// If the gametype doesn't allow some gadget, replace it with something else
			if(CheckGadget(szEquipmentFind,self, false,replacedGadgetClass,PrimaryGadgetDesc))// MissionPack1
				szEquipmentFind = string(replacedGadgetClass);

			bFound = FALSE;
			for ( i = 0; i < m_EquipmentDetails.m_AGadgets.Length && !bFound; i++ )
			{
				szClassName = ""$m_EquipmentDetails.m_AGadgets[i];
				// MPF1
				if ( szClassName ~= szEquipmentFind /*MissionPack1 _szEquipmentToValid*/) 		
				{
					bFound = TRUE;
				}
			}
			if ( !bFound )
				szEquipmentFind = "R6Description.R6DescGadgetNone"; 
			break;
		default:
			break;
	}

	return szEquipmentFind;
}

function setMenuComEquipment()
{
    //Save player choose of equipment on server and in ini file
    local R6MenuInGameMultiPlayerRootWindow r6Root;
  
    r6Root = R6MenuInGameMultiPlayerRootWindow(Root);    

	// force a refresh on gear -- update in the same time .ini
	if(r6Root.m_R6GameMenuCom == none)
	{
		if(bShowLog)
		{
			log("setMenuComEquipment() GameMenuCom is no more valid");
		}
		return;
	}

    r6Root.m_R6GameMenuCom.m_szPrimaryWeapon = m_currentOperative.m_szPrimaryWeapon;
    r6Root.m_R6GameMenuCom.m_szPrimaryWeaponGadget = m_currentOperative.m_szPrimaryWeaponGadget;
    r6Root.m_R6GameMenuCom.m_szPrimaryWeaponBullet = m_currentOperative.m_szPrimaryWeaponBullet;
    r6Root.m_R6GameMenuCom.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;
    r6Root.m_R6GameMenuCom.m_szSecondaryWeapon = m_currentOperative.m_szSecondaryWeapon;
    r6Root.m_R6GameMenuCom.m_szSecondaryWeaponGadget = m_currentOperative.m_szSecondaryWeaponGadget;
    r6Root.m_R6GameMenuCom.m_szSecondaryWeaponBullet = m_currentOperative.m_szSecondaryWeaponBullet;
    r6Root.m_R6GameMenuCom.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;
    r6Root.m_R6GameMenuCom.m_szArmor = m_currentOperative.m_szArmor;

#ifdefDEBUG
	if (bShowLog)
	{
		log("setMenuComEquipment");
		log("m_currentOperative.m_szPrimaryWeapon"@m_currentOperative.m_szPrimaryWeapon);
		log("m_currentOperative.m_szPrimaryWeaponGadget		"@m_currentOperative.m_szPrimaryWeaponGadget);
		log("m_currentOperative.m_szPrimaryWeaponBullet		"@m_currentOperative.m_szPrimaryWeaponBullet);
		log("m_currentOperative.m_szPrimaryGadget			"@m_currentOperative.m_szPrimaryGadget);
		log("m_currentOperative.m_szSecondaryWeapon			"@m_currentOperative.m_szSecondaryWeapon);
		log("m_currentOperative.m_szSecondaryWeaponGadget	"@m_currentOperative.m_szSecondaryWeaponGadget);
		log("m_currentOperative.m_szSecondaryWeaponBullet	"@m_currentOperative.m_szSecondaryWeaponBullet);
		log("m_currentOperative.m_szSecondaryGadget			"@m_currentOperative.m_szSecondaryGadget);
		log("m_currentOperative.m_szArmor					"@m_currentOperative.m_szArmor);
	}
#endif


    r6Root.m_R6GameMenuCom.SavePlayerSetupInfo();
    
}

function SetOperativeEquipment(bool _bCopyBkpToCurrent)
{
    if(_bCopyBkpToCurrent)
    {
        m_currentOperative.m_szPrimaryWeapon = m_BkpOperative.m_szPrimaryWeapon;
        m_currentOperative.m_szPrimaryWeaponGadget = m_BkpOperative.m_szPrimaryWeaponGadget;
        m_currentOperative.m_szPrimaryWeaponBullet = m_BkpOperative.m_szPrimaryWeaponBullet;
        m_currentOperative.m_szPrimaryGadget = m_BkpOperative.m_szPrimaryGadget;
        m_currentOperative.m_szSecondaryWeapon = m_BkpOperative.m_szSecondaryWeapon;
        m_currentOperative.m_szSecondaryWeaponGadget = m_BkpOperative.m_szSecondaryWeaponGadget;
        m_currentOperative.m_szSecondaryWeaponBullet = m_BkpOperative.m_szSecondaryWeaponBullet;
        m_currentOperative.m_szSecondaryGadget = m_BkpOperative.m_szSecondaryGadget;
        m_currentOperative.m_szArmor = m_BkpOperative.m_szArmor;        
    }
    else
    {
        m_BkpOperative.m_szPrimaryWeapon = m_currentOperative.m_szPrimaryWeapon;
        m_BkpOperative.m_szPrimaryWeaponGadget = m_currentOperative.m_szPrimaryWeaponGadget;
        m_BkpOperative.m_szPrimaryWeaponBullet = m_currentOperative.m_szPrimaryWeaponBullet;
        m_BkpOperative.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;
        m_BkpOperative.m_szSecondaryWeapon = m_currentOperative.m_szSecondaryWeapon;
        m_BkpOperative.m_szSecondaryWeaponGadget = m_currentOperative.m_szSecondaryWeaponGadget;
        m_BkpOperative.m_szSecondaryWeaponBullet = m_currentOperative.m_szSecondaryWeaponBullet;
        m_BkpOperative.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;
        m_BkpOperative.m_szArmor = m_currentOperative.m_szArmor;
    }
}

function SetClassEquipment()
{
    m_OpFirstWeaponDesc = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(m_currentOperative.m_szPrimaryWeapon, Class'Core.Class'));
    m_OpFirstWeaponGadgetDesc = class'R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(m_OpFirstWeaponDesc, m_currentOperative.m_szPrimaryWeaponGadget);
    m_OpFirstWeaponBulletDesc = class'R6DescriptionManager'.static.GetPrimaryBulletDesc(m_OpFirstWeaponDesc, m_currentOperative.m_szPrimaryWeaponBullet);
    m_OpSecondaryWeaponDesc = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(m_currentOperative.m_szSecondaryWeapon, Class'Core.Class'));
    m_OpSecondWeaponGadgetDesc = class'R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(m_OpSecondaryWeaponDesc, m_currentOperative.m_szSecondaryWeaponGadget);
    m_OpSecondWeaponBulletDesc = class'R6DescriptionManager'.static.GetSecondaryBulletDesc(m_OpSecondaryWeaponDesc, m_currentOperative.m_szSecondaryWeaponBullet);
    m_OpFirstGadgetDesc = Class<R6GadgetDescription>(DynamicLoadObject(m_currentOperative.m_szPrimaryGadget, Class'Core.Class'));
    m_OpSecondGadgetDesc = Class<R6GadgetDescription>(DynamicLoadObject(m_currentOperative.m_szSecondaryGadget, Class'Core.Class'));
}

function AcceptSelection()
{
    if(bShowLog)
    {
        log("MPGearWidget AcceptSelection()");
    }
    RefreshGearInfo(true);
    setMenuComEquipment();
    SetOperativeEquipment(false);
}

function CancelSelection()
{
    if(bShowLog)
    {
        log("MPGearWidget CancelSelection()");
    }
    SetOperativeEquipment(true);
    SetClassEquipment();
    m_EquipmentDetails.m_listBox.DropSelection();
}


function EquipmentSelected(e2DEquipment equipmentSelected)
{   
    local   R6WindowListBoxItem         TempItem;

    //This occurs when a 2d equipment is clicked
	m_e2DCurEquipmentSel = equipmentSelected;
    m_EquipmentDetails.ShowWindow();
    m_EquipmentDetails.FillListBox(equipmentSelected);

    // Sort the list.
    // #ifdef R6PATCH_FOR_E3
    // NB (gborgia) The sort algorythm is broken.  The result looks fine except that the last items of the
    // list is placed in front of the list rather than at its correct place.  For now, add a temp at the end
    // end remove it after the sort.  After E3, we will need to fix the sort algorythm.
    /*
    TempItem = R6WindowListBoxItem( m_EquipmentDetails.m_ListBox.Items.Append( class'R6WindowListBoxItem' ) );
    m_EquipmentDetails.m_ListBox.Sort();
    TempItem.Remove();
    m_EquipmentDetails.m_ListBox.MakeSelectedVisible();
    */
}

function EquipmentChanged(INT equipmentSelected, class<R6Description> DecriptionClass )
{   
    local class<R6Description> inDescriptionClass;
    //This occurs when a new Item has been selected from the list
    
    //TODO : Change current Roster equipment and make sure 2d image change
    
        switch(equipmentSelected)
        {
        case 0 :

            inDescriptionClass = DecriptionClass;
            if( m_OpFirstWeaponDesc != class<R6PrimaryWeaponDescription>(DecriptionClass))
            {
                //Primary Weapon Changed
                m_currentOperative.m_szPrimaryWeapon = string(DecriptionClass);
                m_OpFirstWeaponDesc = class<R6PrimaryWeaponDescription>(DecriptionClass);
                if(bshowlog)log("Changing Primary Weapon for "@m_currentOperative.m_szPrimaryWeapon);           
            
                //Primary Weapon Gadget Changed
                DecriptionClass = class'R6DescWeaponGadgetNone';
                m_currentOperative.m_szPrimaryWeaponGadget = DecriptionClass.Default.m_NameID;
                m_OpFirstWeaponGadgetDesc = class<R6WeaponGadgetDescription>(DecriptionClass);
                if(bshowlog)log("Changing Primary Weapon Gadget for "@m_currentOperative.m_szPrimaryWeaponGadget);
            
                //Primary Weapon Bullets Changed
                DecriptionClass = class'R6DescriptionManager'.static.findPrimaryDefaultAmmo(class<R6PrimaryWeaponDescription>(inDescriptionClass));
                m_currentOperative.m_szPrimaryWeaponBullet = DecriptionClass.Default.m_NameTag;
                m_OpFirstWeaponBulletDesc = class<R6BulletDescription>(DecriptionClass);
                if(bshowlog)log("Changing Primary Weapon Bullets for "@m_currentOperative.m_szPrimaryWeaponBullet);
            }
            break;
        case 1 :
            //Primary Weapon Gadget Changed
            m_currentOperative.m_szPrimaryWeaponGadget = DecriptionClass.Default.m_NameID;
            m_OpFirstWeaponGadgetDesc = class<R6WeaponGadgetDescription>(DecriptionClass);
            if(bshowlog)log("Changing Primary Weapon Gadget for "@m_currentOperative.m_szPrimaryWeaponGadget);
            break;
        case 2 :            
            //Primary Weapon Bullets Changed
            m_currentOperative.m_szPrimaryWeaponBullet = DecriptionClass.Default.m_NameTag;
            m_OpFirstWeaponBulletDesc = class<R6BulletDescription>(DecriptionClass);
            if(bshowlog)log("Changing Primary Weapon Bullets for "@m_currentOperative.m_szPrimaryWeaponBullet);
            break;
        case 3 :
            //Primary Gadget
            m_currentOperative.m_szPrimaryGadget = string(DecriptionClass);
            m_OpFirstGadgetDesc = class<R6GadgetDescription>(DecriptionClass);
            if(bshowlog)log("Changing Primary Gadget for "@m_currentOperative.m_szPrimaryWeapon);
            break;
        case 4 :

            inDescriptionClass = DecriptionClass;             

            if(m_OpSecondaryWeaponDesc != class<R6SecondaryWeaponDescription>(DecriptionClass))
            {
                //Secondary Weapon Changed    
                m_currentOperative.m_szSecondaryWeapon = string(DecriptionClass);
                m_OpSecondaryWeaponDesc = class<R6SecondaryWeaponDescription>(DecriptionClass);
                if(bshowlog)log("Changing Secondary Weapon for "@m_currentOperative.m_szSecondaryWeapon);

                 //Secondary Weapon Gadget Changed
                DecriptionClass = class'R6DescWeaponGadgetNone';
                m_currentOperative.m_szSecondaryWeaponGadget = DecriptionClass.Default.m_NameID;
                m_OpSecondWeaponGadgetDesc = class<R6WeaponGadgetDescription>(DecriptionClass);
                if(bshowlog)log("Changing Secondary Weapon Gadget for "@m_currentOperative.m_szSecondaryWeaponGadget);

                //Secondary Weapon Bullets Changed
                DecriptionClass = class'R6DescriptionManager'.static.findSecondaryDefaultAmmo(class<R6SecondaryWeaponDescription>(inDescriptionClass));
                m_currentOperative.m_szSecondaryWeaponBullet = DecriptionClass.Default.m_NameTag;
                m_OpSecondWeaponBulletDesc = class<R6BulletDescription>(DecriptionClass);
                if(bshowlog)log("Changing Secondary Weapon Bullets for "@m_currentOperative.m_szSecondaryWeaponBullet);
            }            
            break;
        case 5 :
            //Secondary Weapon Gadget Changed
            m_currentOperative.m_szSecondaryWeaponGadget = DecriptionClass.Default.m_NameID;
            m_OpSecondWeaponGadgetDesc = class<R6WeaponGadgetDescription>(DecriptionClass);
            if(bshowlog)log("Changing Secondary Weapon Gadget for "@m_currentOperative.m_szSecondaryWeaponGadget);
            break;
        case 6 :
            //Secondary Weapon Bullets Changed
            m_currentOperative.m_szSecondaryWeaponBullet = DecriptionClass.Default.m_NameTag;
            m_OpSecondWeaponBulletDesc = class<R6BulletDescription>(DecriptionClass);
            if(bshowlog)log("Changing Secondary Weapon Bullets for "@m_currentOperative.m_szSecondaryWeaponBullet);
            break;
        case 7 :
            //Secondary Gadget
            m_currentOperative.m_szSecondaryGadget = string(DecriptionClass);
            m_OpSecondGadgetDesc = class<R6GadgetDescription>(DecriptionClass);
            if(bshowlog)log("Changing Secondary Gadget for "@m_currentOperative.m_szSecondaryGadget);
            break;       
        }           
        m_Equipment2dSelect.UpdateDetails();
}


//MAKE SURE THIS FUNCTION IS THE SAME AS THE ONE IN THE SINGLEPLAYER GEAR ROOM
function TexRegion GetGadgetTexture(class<R6GadgetDescription> _CurrentGadget)
{
    local bool bfound;
    local String Tag;
    local int i;
    local TexRegion TR;

    if( class'R6DescPrimaryMags' == _CurrentGadget )
    {
        if(m_OpFirstWeaponGadgetDesc.Default.m_NameTag == "CMAG")
        {
            bfound = true;  
            TR.T = m_OpFirstWeaponGadgetDesc.Default.m_2DMenuTexture;
            TR.X = m_OpFirstWeaponGadgetDesc.Default.m_2dMenuRegion.X;
            TR.Y = m_OpFirstWeaponGadgetDesc.Default.m_2dMenuRegion.Y;
            TR.W = m_OpFirstWeaponGadgetDesc.Default.m_2dMenuRegion.W;
            TR.H = m_OpFirstWeaponGadgetDesc.Default.m_2dMenuRegion.H;
        }
        else
            Tag = m_OpFirstWeaponDesc.Default.m_MagTag;
    }
        
	
    else if(class'R6DescSecondaryMags' == _CurrentGadget )
    {
        if(m_OpSecondWeaponGadgetDesc.Default.m_NameTag == "CMAG")
        {
            bfound = true;  
            TR.T = m_OpSecondWeaponGadgetDesc.Default.m_2DMenuTexture;
            TR.X = m_OpSecondWeaponGadgetDesc.Default.m_2dMenuRegion.X;
            TR.Y = m_OpSecondWeaponGadgetDesc.Default.m_2dMenuRegion.Y;
            TR.W = m_OpSecondWeaponGadgetDesc.Default.m_2dMenuRegion.W;
            TR.H = m_OpSecondWeaponGadgetDesc.Default.m_2dMenuRegion.H;

        }
        else
            Tag = m_OpSecondaryWeaponDesc.Default.m_MagTag;
    }
        

	
    //Let's start searching for the right mag Texture
    if( Tag != "")
    {
        i= 0;
		while( (i < m_PrimaryMagsGadget.m_MagTags.Length) && (bfound == false))
        {
			if( m_PrimaryMagsGadget.m_MagTags[i] == Tag)
            {
                bfound = true;
				TR = m_PrimaryMagsGadget.m_Mags[i];      
            }                
            else
                i++;
        }
    } 
   
    //No mag found or the gadget is not an extra mag
    if(bfound == false)
    {
        TR.T = _CurrentGadget.Default.m_2DMenuTexture;
        TR.X = _CurrentGadget.Default.m_2dMenuRegion.X;
        TR.Y = _CurrentGadget.Default.m_2dMenuRegion.Y;
        TR.W = _CurrentGadget.Default.m_2dMenuRegion.W;
        TR.H = _CurrentGadget.Default.m_2dMenuRegion.H;

    }
    

    return TR;
}

//=========================================================================================
// RefreshGearInfo: Refresh all the gear according the new restriction kit
//=========================================================================================
function RefreshGearInfo( BOOL _bForceUpdate)
{
	if ((m_iCounter > 10) || (_bForceUpdate))
	{
#ifdefDEBUG
		if (bShowLog)
			log("RefreshGearInfo refresh gear");
#endif
		m_iCounter = 0;

		// update the lists with the current restriction
		m_EquipmentDetails.BuildAvailableEquipment();

		// check if current selection in the list is valid now 
		m_EquipmentDetails.FillListBox(m_e2DCurEquipmentSel);  // fill the list of equipment again

		// check for all the current equipment
		VerifyAllEquipment(m_currentOperative.m_szPrimaryWeapon, m_currentOperative.m_szPrimaryWeaponGadget, m_currentOperative.m_szPrimaryGadget, m_currentOperative.m_szSecondaryWeapon, m_currentOperative.m_szSecondaryWeaponGadget, m_currentOperative.m_szSecondaryGadget);
		SetClassEquipment();

    


		m_Equipment2dSelect.UpdateDetails();

#ifdefDEBUG
		if (bShowLog)
		{
			log("RefreshGearInfo");
			log("m_currentOperative.m_szPrimaryWeapon			"@m_currentOperative.m_szPrimaryWeapon);
			log("m_currentOperative.m_szPrimaryWeaponGadget		"@m_currentOperative.m_szPrimaryWeaponGadget);
			log("m_currentOperative.m_szPrimaryWeaponBullet		"@m_currentOperative.m_szPrimaryWeaponBullet);
			log("m_currentOperative.m_szPrimaryGadget			"@m_currentOperative.m_szPrimaryGadget);
			log("m_currentOperative.m_szSecondaryWeapon			"@m_currentOperative.m_szSecondaryWeapon);
			log("m_currentOperative.m_szSecondaryWeaponGadget	"@m_currentOperative.m_szSecondaryWeaponGadget);
			log("m_currentOperative.m_szSecondaryWeaponBullet	"@m_currentOperative.m_szSecondaryWeaponBullet);
			log("m_currentOperative.m_szSecondaryGadget			"@m_currentOperative.m_szSecondaryGadget);
			log("m_currentOperative.m_szArmor					"@m_currentOperative.m_szArmor);
		}
#endif

	}

	m_iCounter++;
}


//MissionPack1
/* parameters:
	_gadgetDesc = name of the gadget to check
	_caller = a UWindowWindow object (necessary only to call instanced methods inside a static method)
	_isSecondGadget = true if the gadget is the secondary one
	(optional OUT) _replaceGadgetClass = the class description of the gadget to be used instead
	(optional) _otherGadget = name of the other gadget (the Secondary if the gadget to check is primary and viceversa)

   return: true if the gadget must be replaced
*/

static function bool CheckGadget(string _gadgetDesc, UWindowWindow _caller , bool _isSecondGadget, optional out class<R6GadgetDescription> _replaceGadgetClass, optional string _otherGadget)
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;

	R6Root = R6MenuInGameMultiPlayerRootWindow(_caller.Root);
	if(R6Root != none)
	{
	    if (R6Root.m_szCurrentGameType == "RGM_CaptureTheEnemyAdvMode")
		{
			if(_gadgetDesc == "R6Description.R6DescFragGrenadeGadget" ||
			 	_gadgetDesc == "R6Description.R6DescBreachingChargeGadget" ||
			 	_gadgetDesc == "R6Description.R6DescClaymoreGadget" ||
			 	_gadgetDesc == "R6Description.R6DescRemoteChargeGadget"
			 	)
	    	{
		        if(_isSecondGadget)
	        	{
	                if(_otherGadget == "R6Description.R6DescSmokeGrenadeGadget")
                    	_replaceGadgetClass = class'R6Description.R6DescFlashBangGadget';
                	else
	                    _replaceGadgetClass = class'R6Description.R6DescSmokeGrenadeGadget';
            	}
            	else
	        	{
	                if(_otherGadget == "R6Description.R6DescFlashBangGadget")
                    	_replaceGadgetClass = class'R6Description.R6DescSmokeGrenadeGadget';
                	else
	                    _replaceGadgetClass = class'R6Description.R6DescFlashBangGadget';
            	}
            	return true;
			}
        }
        // MPF_Milan_8_25_2003 - No HB Sensor in Kamikaze
        else if (R6Root.m_szCurrentGameType == "RGM_KamikazeMode")
	    {
    		if(_gadgetDesc == "R6Description.R6DescHBSGadget" ||
		    _gadgetDesc == "R6Description.R6DescHBSJammerGadget" ||
	    	_gadgetDesc == "R6Description.R6DescHBSSAJammerGadget" ||
    		_gadgetDesc == "R6Description.R6DescFalseHBGadget" 
		    )
	    		return true;
        }
    }
	// End MPF_Milan_8_25_2003
    return false;
}
// End MissionPack1

defaultproperties
{
}
