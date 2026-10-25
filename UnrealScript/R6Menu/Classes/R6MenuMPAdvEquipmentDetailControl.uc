//=============================================================================
//  R6MenuMPAdvEquipmentDetailControl.uc : This control should provide functionalities
//                                      needed to select armor, weapons, bullets
//                                      gadgets for an operative for adversial multi-player
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================


class R6MenuMPAdvEquipmentDetailControl extends R6MenuEquipmentDetailControl;

var   Array<class>  m_ADefaultPrimaryWeapons;      //class<R6PrimaryWeaponDescription>
var   Array<class>  m_ADefaultSecondaryWeapons;    //class<R6SecondaryWeaponDescription>
var   Array<class>  m_ADefaultGadgets;             //class<R6GadgetDescription>
var   Array<string> m_ADefaultWpnGadget;

var   Array<string> m_APriWpnGadget;        // List of available primary weapon gadgets
var   Array<string> m_ASecWpnGadget;        // List of available secondary weapon gadgets

var	  INT			m_iLastListIndex;		// this is the last list index to know if your are in the same list

function Created()
{
    local color  labelFontColor, Co;   
    local Texture BorderTexture;

   

    labelFontColor = Root.Colors.White;

    //List Box Title
    m_Title = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0,0, WinWidth, m_fListBoxLabelHeight, self ));    
	m_Title.Align = TA_Center;
	m_Title.m_Font = Root.Fonts[F_VerySmallTitle]; 
	m_Title.TextColor = labelFontColor;    
    m_Title.m_BGTexture = None;

    //Creating List Box
    m_ListBox =  R6WindowTextListBox(CreateControl(class'R6WindowTextListBox', 0, m_Title.WinTop + m_Title.WinHeight -1, WinWidth, m_fListBoxHeight));
    m_ListBox.ListClass=class'R6WindowListBoxItem';
    m_ListBox.m_VertSB.SetHideWhenDisable(true);	
    m_ListBox.m_font                = m_Title.m_Font;
    m_ListBox.SetCornerType(No_Corners);

    
    m_WeaponStats = R6MenuWeaponStats(CreateWindow(class'R6MenuWeaponStats', 0, m_ListBox.WinTop + m_ListBox.WinHeight, WinWidth, WinHeight - m_ListBox.WinTop - m_ListBox.WinHeight, self ));
    m_WeaponStats.m_bDrawBorders = false;
    m_WeaponStats.m_bDrawBg      = false;
    m_WeaponStats.HideWindow();
    
    m_CurrentEquipmentType = -1;

    BuildAvailableEquipment();

    //Build Anchor buttons area
    m_AnchorButtons = R6MenuEquipmentAnchorButtons(CreateControl(class'R6MenuEquipmentAnchorButtons', 0, 0, WinWidth, m_fAnchorAreaHeight, self));
    m_AnchorButtons.m_bDrawBorders = false;    
    m_AnchorButtons.m_fPrimarWTabOffset = 3;
    m_AnchorButtons.m_fGrenadesOffset   = 3;
    m_AnchorButtons.m_fPistolOffset     = 3;
    m_AnchorButtons.Resize();
    m_AnchorButtons.HideWindow();

}

function R6Operative GetCurrentOperative()
{  
    return R6MenuMPAdvGearWidget(OwnerWindow).m_currentOperative;
}

function class<R6PrimaryWeaponDescription> GetCurrentPrimaryWeapon()
{
    return R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstWeaponDesc;
}

function class<R6SecondaryWeaponDescription> GetCurrentSecondaryWeapon()
{
    return R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondaryWeaponDesc;
}

function class<R6WeaponGadgetDescription> GetCurrentWeaponGadget(Bool _Primary)
{
    if(_Primary == true)
        return R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstWeaponGadgetDesc;
    else 
        return R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondWeaponGadgetDesc;
}

function class<R6BulletDescription> GetCurrentWeaponBullet(Bool _Primary)
{
    if(_Primary == true)
        return R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstWeaponBulletDesc;
    else 
        return R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondWeaponBulletDesc;
}

function class<R6GadgetDescription> GetCurrentGadget(Bool _Primary)
{
    if(_Primary == true)
        return R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstGadgetDesc;
    else 
        return R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondGadgetDesc;
}

function NotifyEquipmentChanged(INT equipmentSelected, class<R6Description> DecriptionClass )
{
    R6MenuMPAdvGearWidget(OwnerWindow).EquipmentChanged(equipmentSelected, DecriptionClass);
}

function FillListBox(int _equipmentType)
{
    local   class<R6PrimaryWeaponDescription>   PrimaryWeaponClass;
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
    local   class<R6BulletDescription>          WeaponBulletDescriptionClass;
    local   class<R6GadgetDescription>          GadgetClass;
    local   class<R6WeaponGadgetDescription>    WeaponGadgetDescriptionClass;
   

	local   UWindowList							FindItem;
    local   R6WindowListBoxItem                 NewItem, SelectedItem, FirstInsertedItem, OldSelectedItem;
    local   R6Operative                         currentOperative;
    local   INT                                 i,j, OldVertSBPos;
    

    local   BOOL                                bRestricted;
    local   R6MenuInGameMultiPlayerRootWindow   R6Root;

	// MPF - Eric

    R6Root              = R6MenuInGameMultiPlayerRootWindow(Root);
    
    currentOperative	= GetCurrentOperative();
    SelectedItem        = None;

	if (m_ListBox.m_SelectedItem != None)
	{
		if (m_iLastListIndex == _equipmentType)
		{
			// same equipment list
			// keep the old selection
			OldSelectedItem = R6WindowListBoxItem(m_ListBox.m_SelectedItem);
		}
	}

	OldVertSBPos = m_ListBox.m_VertSB.Pos;

	// MPF - Eric

    switch(_equipmentType)
    {
    case 0:      
        Super.FillListBox(0);
        break;
    case 1:             //Primary_WeaponGadget:
        m_Title.SetNewText(Localize("GearRoom","PrimaryWeaponGadget","R6Menu"), true);
        
        //Insert The None Value
        m_listbox.clear();
        UpdateAnchorButtons(AET_None);
        
        PrimaryWeaponClass = class<R6PrimaryWeaponDescription>( DynamicLoadObject( currentOperative.m_szPrimaryWeapon, class'Class' ) );

        for(i=0;i < PrimaryWeaponClass.Default.m_MyGadgets.Length ; i++)
        {
            WeaponGadgetDescriptionClass = class<R6WeaponGadgetDescription>(PrimaryWeaponClass.Default.m_MyGadgets[i]);

            // Check for restricted gadgets
            bRestricted = FALSE;
            for( j = 0; j < arraycount(R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgPrimaryRes); j++ )
            {
                if ( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgPrimaryRes[j] == WeaponGadgetDescriptionClass.Default.m_NameID)
                    bRestricted = TRUE;
            }

            if( WeaponGadgetDescriptionClass != class'R6DescWeaponGadgetNone' && 
				WeaponGadgetDescriptionClass.Default.m_bPriGadgetWAvailable &&
				!bRestricted )
            {             
#ifdefMPDEMO  
				if (!IsEquipmentAvailable( WeaponGadgetDescriptionClass, true))
					continue;
#endif
				NewItem = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
				NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.Default.m_NameID,"ID_NAME","R6WeaponGadgets");
				NewItem.m_Object = WeaponGadgetDescriptionClass;                
				if(GetCurrentWeaponGadget(true) == WeaponGadgetDescriptionClass)
					SelectedItem = NewItem;
            }
        }
        
        m_ListBox.Items.Sort();

        //************************************************************************************************
        //Insert The None Value
        WeaponGadgetDescriptionClass = class'R6DescWeaponGadgetNone';
        NewItem = R6WindowListBoxItem( m_ListBox.Items.InsertAfter( class'R6WindowListBoxItem'));
        NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.Default.m_NameID,"ID_NAME","R6WeaponGadgets");
        NewItem.m_Object = WeaponGadgetDescriptionClass;
        if(GetCurrentWeaponGadget(true) == WeaponGadgetDescriptionClass)
                    SelectedItem = NewItem;
        //************************************************************************************************        
       
        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(false);

		if (SelectedItem != None)
		{        
			m_ListBox.SetSelectedItem(SelectedItem);
			m_ListBox.MakeSelectedVisible(); 
		}
        break;
    case 2:             //Primary_Bullet,
        Super.FillListBox(2);
        break;
    case 3:       
        //Primary_Gadget,
        Super.FillListBox(3);
        break;
        
    case 4:                     
        Super.FillListBox(4);
        break;

    case 5:             //Secondary_WeaponGadget,
        m_Title.SetNewText(Localize("GearRoom","SecondaryWeaponGadget","R6Menu"), true);

        //Insert The None Value
        m_listbox.clear();       
        UpdateAnchorButtons(AET_None);
        
        SecondaryWeaponClass = class<R6SecondaryWeaponDescription>( DynamicLoadObject( currentOperative.m_szSecondaryWeapon, class'Class' ) );

        for(i=0;i < SecondaryWeaponClass.Default.m_MyGadgets.Length ; i++)
        {
            WeaponGadgetDescriptionClass = class<R6WeaponGadgetDescription>(SecondaryWeaponClass.Default.m_MyGadgets[i]);

            // Check for restricted gadgets
            bRestricted = FALSE;
            for( j = 0; j < arraycount(R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgSecondayRes); j++ )
            {
                if ( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgSecondayRes[j] == WeaponGadgetDescriptionClass.Default.m_NameID)
                    bRestricted = TRUE;
            }

            if( WeaponGadgetDescriptionClass != class'R6DescWeaponGadgetNone' && 
				WeaponGadgetDescriptionClass.Default.m_bSecGadgetWAvailable &&
				!bRestricted )
            {       
#ifdefMPDEMO  
				if (!IsEquipmentAvailable( WeaponGadgetDescriptionClass, true, true))
					continue;
#endif
				NewItem = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
				NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.Default.m_NameID,"ID_NAME","R6WeaponGadgets");
				NewItem.m_Object = WeaponGadgetDescriptionClass;                
				if(GetCurrentWeaponGadget(false) == WeaponGadgetDescriptionClass)
					SelectedItem = NewItem;
            }
            
        }
        
        m_ListBox.Items.Sort();
        
        //************************************************************************************************
        //Insert The None Value
        WeaponGadgetDescriptionClass = class'R6DescWeaponGadgetNone';
        NewItem = R6WindowListBoxItem( m_ListBox.Items.InsertAfter( class'R6WindowListBoxItem'));
        NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.Default.m_NameID,"ID_NAME","R6WeaponGadgets");
        NewItem.m_Object = WeaponGadgetDescriptionClass;
        if(GetCurrentWeaponGadget(false) == WeaponGadgetDescriptionClass)
            SelectedItem = NewItem;
        //************************************************************************************************
        
        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(false);

		if (SelectedItem != None)
		{        
			m_ListBox.SetSelectedItem(SelectedItem);
			m_ListBox.MakeSelectedVisible(); 
		}
        break;
    case 6:             //Secondary_Bullet,
        Super.FillListBox(6);
        break;
    case 7:             //Secondary_Gadget,
        Super.FillListBox(7);
        break;  
    case 8:        
        break;  
    }

	if (m_ListBox.m_SelectedItem != None)
	{
		if ( R6WindowListBoxItem(m_ListBox.m_SelectedItem) != OldSelectedItem)
		{
			if (OldSelectedItem != None)
			{
				// replace the selection by the old one, user not have to see the refresh
				FindItem = m_ListBox.FindItemWithName( OldSelectedItem.HelpText);

				if (FindItem != None)
				{
					SelectedItem = R6WindowListBoxItem(FindItem);
				}
			}
		}
	}

    if (SelectedItem != None)
    {        
        m_ListBox.SetSelectedItem(SelectedItem);
		m_ListBox.m_VertSB.Pos = OldVertSBPos;
    }    

	m_ListBox.ShowWindow(); // rebuild the list to have the listwindow on the top
	m_iLastListIndex = _equipmentType;
}

function enableWeaponStats(bool _enable)
{
    //When disable we are not displaying a weapon information
    //When enable we pop up the buttons and the 2 weapon information page
    if(_enable)
    {        
        m_WeaponStats.ShowWindow();        
        m_ListBox.SetSize(m_ListBox.WinWidth,  WinHeight - m_ListBox.WinTop - m_WeaponStats.WinHeight);
    }   
    else
    {
        m_WeaponStats.HideWindow();
        m_ListBox.SetSize(m_ListBox.WinWidth, WinHeight - m_ListBox.WinTop);
        
    }
        

}

//This Hides Or display Anchor buttons for equipment that support it
function UpdateAnchorButtons(R6MenuEquipmentAnchorButtons.eAnchorEquipmentType _AEType)
{    

    if(_AEType == AET_None )    
    {
        m_AnchorButtons.HideWindow();
        m_Title.WinTop   = 0;
        m_Title.m_bDrawBorders = false;
        m_ListBox.WinTop = m_Title.WinTop + m_Title.WinHeight -1;        
        m_ListBox.SetSize(m_ListBox.WinWidth, m_fListBoxHeight);
    }
    else
    {
        m_AnchorButtons.ShowWindow();
        m_AnchorButtons.DisplayButtons(_AEType);
        m_Title.WinTop = m_AnchorButtons.WinTop + m_AnchorButtons.WinHeight;
        m_Title.m_bDrawBorders = true;
        m_ListBox.WinTop = m_Title.WinTop + m_Title.WinHeight -1;
        m_ListBox.SetSize(m_ListBox.WinWidth, m_fListBoxHeight - m_AnchorButtons.WinHeight);
    }

}


function BuildAvailableEquipment()
{
    local   class<R6PrimaryWeaponDescription>   PrimaryWeaponClass;
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
    local   class<R6GadgetDescription>          GadgetClass;
    local   class<R6WeaponGadgetDescription>    WeaponGadgetClass;

    local   R6MenuInGameMultiPlayerRootWindow R6Root;

    local   INT                                 i,j,k;
    local   BOOL                                bFound;
	local	BOOL								bEquipValid;
	// MPF - Eric
	local	R6Mod								pCurrentMod;
	
    R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

	if ( (R6Root.m_R6GameMenuCom == None) || (R6Root.m_R6GameMenuCom.m_GameRepInfo == None) )
		return; // this could happen when a loadserver command is done

    //This functions creates array of available weapons from wich we can populate
    //list boxes

    m_APrimaryWeapons.remove(0, m_APrimaryWeapons.Length);
    m_ASecondaryWeapons.remove(0, m_ASecondaryWeapons.Length);
    m_AGadgets.remove(0, m_AGadgets.Length);
    m_APriWpnGadget.remove(0, m_APriWpnGadget.Length);
    m_ASecWpnGadget.remove(0, m_ASecWpnGadget.Length);

    /////////////////////////////////////////////////////////////////////////////////
    ///////////        Filling Primary_Weapons       /////////////////////////
    /////////////////////////////////////////////////////////////////////////////////      

	GetAllPrimaryWeapon();

    // Check for restricted weapons, remove from the list 

	CompareGearItemsWithServerRest( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szSubMachineGunsRes, m_APrimaryWeapons);
	CompareGearItemsWithServerRest( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szShotGunRes, m_APrimaryWeapons);
	CompareGearItemsWithServerRest( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szAssRifleRes, m_APrimaryWeapons);
	CompareGearItemsWithServerRest( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szMachGunRes, m_APrimaryWeapons);
	CompareGearItemsWithServerRest( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szSnipRifleRes, m_APrimaryWeapons);
	
    SortDescriptions( true, m_APrimaryWeapons, "R6Weapons" );    

    /////////////////////////////////////////////////////////////////////////////////
    ///////////        Filling Primary_Weapons Gadget       /////////////////////////
    /////////////////////////////////////////////////////////////////////////////////      

	GetAllWeaponGadget();

    // Check for restricted gadgets, remove from the list 

    for( i = 0; i < arraycount(R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgPrimaryRes); i++ )
    {
        for ( j = 0; j < m_APriWpnGadget.Length; j++ )
        {
            if ( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgPrimaryRes[i] ==  m_APriWpnGadget[j] )
                m_APriWpnGadget.remove(j,1);
        }
    }
   
    /////////////////////////////////////////////////////////////////////////////////
    //Filling Gadgets
    /////////////////////////////////////////////////////////////////////////////////
    
	GetAllGadgets();

    // Check for restricted gadgets, remove from the list 

	CompareGearItemsWithServerRest( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgMiscRes, m_AGadgets);
    
    SortDescriptions( true, m_AGadgets, "R6Gadgets" );
     
    /////////////////////////////////////////////////////////////////////////////////
    //////////////////////Filling Secondary_Weapon ///////////////////////
    /////////////////////////////////////////////////////////////////////////////////

    GetAllSecondaryWeapon();

    // Check for restricted weapons, remove from the list 

	CompareGearItemsWithServerRest( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szPistolRes, m_ASecondaryWeapons);
	CompareGearItemsWithServerRest( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szMachPistolRes, m_ASecondaryWeapons);

    SortDescriptions( true, m_ASecondaryWeapons, "R6Weapons" );

    /////////////////////////////////////////////////////////////////////////////////
    ///////////        Filling Secondary_Weapons Gadget       /////////////////////////
    /////////////////////////////////////////////////////////////////////////////////      

//	GetAllWeaponGadget(); // already done before

    // Check for restricted gadgets, remove from the list 

    for( i = 0; i < arraycount(R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgSecondayRes); i++ )
    {

        for ( j = 0; j < m_ASecWpnGadget.Length; j++ )
        {
            if ( R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgSecondayRes[i] == m_ASecWpnGadget[j] )
                m_ASecWpnGadget.remove(j,1);
        }
    }
}

function CompareGearItemsWithServerRest( string _AServerRest[32], OUT Array<class> _AGearItems)
{
	local INT i, j,
			  iSizeOfServRestArray;
	local BOOL bFound;

	iSizeOfServRestArray = arraycount( _AServerRest);

    for( i = 0; i < iSizeOfServRestArray; i++ )
    {
        bFound = FALSE;
        for ( j = 0; j < _AGearItems.Length && !bFound; j++ )
        {
            if ( _AServerRest[i] == class<R6Description>(_AGearItems[j]).Default.m_NameID )
            {
                bFound = TRUE;
                _AGearItems.remove(j,1);
            }
        }
    }
}

//===================================================================
// GetAllPrimaryWeapon: Get all the primary weapon
//===================================================================
function GetAllPrimaryWeapon()
{
    local   class<R6PrimaryWeaponDescription>   PrimaryWeaponClass;

    local   INT                                 i;
	local	BOOL								bEquipValid;
	// MPF - Eric
	local	INT									j;
	local	R6Mod								pCurrentMod;

	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod;

	if (m_ADefaultPrimaryWeapons.Length == 0)
	{
		i=0;
		//Insert All Primary Descriptions except None
		// MPF - Eric
		for ( j = 0; j < pCurrentMod.m_aDescriptionPackage.Length; j++)
		{
			PrimaryWeaponClass = class<R6PrimaryWeaponDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[j]$".u", class'R6PrimaryWeaponDescription'));
			
			while((PrimaryWeaponClass != None))
			{
#ifdefMPDEMO
				bEquipValid = IsEquipmentAvailable( PrimaryWeaponClass, false);
#endif
#ifndefMPDEMO
				bEquipValid = (PrimaryWeaponClass.Default.m_NameID != "NONE");
#endif
				if (bEquipValid)
				{
					m_APrimaryWeapons[i]=PrimaryWeaponClass;
					m_ADefaultPrimaryWeapons[i]=PrimaryWeaponClass;
					i++;
				}
				
				PrimaryWeaponClass = class<R6PrimaryWeaponDescription>(GetNextClass());
			}  
			
			FreePackageObjects();
		}
	}
	else
	{
		for( i =0 ; i < m_ADefaultPrimaryWeapons.Length; i++)
		{
			m_APrimaryWeapons[i] = m_ADefaultPrimaryWeapons[i];
		}
	}
}

//===================================================================
// GetAllSecondaryWeapon: Get all the secondary weapon
//===================================================================
function GetAllSecondaryWeapon()
{
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;

    local   INT                                 i;
	local	BOOL								bEquipValid;
	// MPF - Eric
	local   INT									j;
	local	R6Mod								pCurrentMod;

	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod;

	if (m_ADefaultSecondaryWeapons.Length == 0)
	{
		i=0;
		//Insert All Secondary_Weapon Descriptions except None
		// MPF - Eric
		for (j = 0; j < pCurrentMod.m_aDescriptionPackage.Length; j++)
		{
			SecondaryWeaponClass = class<R6SecondaryWeaponDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[j]$".u", class'R6SecondaryWeaponDescription'));
			
			while((SecondaryWeaponClass != None))
			{
#ifdefMPDEMO  
				bEquipValid = IsEquipmentAvailable( SecondaryWeaponClass, false);
#endif
#ifndefMPDEMO
				bEquipValid = (SecondaryWeaponClass.Default.m_NameID != "NONE");
#endif
				if (bEquipValid)
				{                
					m_ASecondaryWeapons[i]=SecondaryWeaponClass;
					m_ADefaultSecondaryWeapons[i]=SecondaryWeaponClass;
					i++;
				}
				
				SecondaryWeaponClass = class<R6SecondaryWeaponDescription>(GetNextClass());
			} 
			
			FreePackageObjects();
		}
	}
	else
	{
		for( i =0 ; i < m_ADefaultSecondaryWeapons.Length; i++)
		{
			m_ASecondaryWeapons[i] = m_ADefaultSecondaryWeapons[i];
		}
	}
}

//===================================================================
// GetAllGadgets: Get all gadgets
//===================================================================
function GetAllGadgets()
{
    local   class<R6GadgetDescription>          GadgetClass;

    local   INT                                 i;
	local	BOOL								bEquipValid;

	// MPF - Eric
	local   INT									j;
	local	R6Mod								pCurrentMod;

	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod;

	if (m_ADefaultGadgets.Length == 0)
	{
		i=0;
		//Insert All Gadget Descriptions except None
		// MPF - Eric
		for (j = 0; j < pCurrentMod.m_aDescriptionPackage.Length; j++)
		{
			GadgetClass = class<R6GadgetDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[j]$".u", class'R6GadgetDescription'));
			
			while((GadgetClass != None))
			{
#ifdefMPDEMO  
				bEquipValid = IsEquipmentAvailable( GadgetClass, true);
#endif
#ifndefMPDEMO
				bEquipValid = (GadgetClass.Default.m_NameID != "NONE");
#endif
				if (bEquipValid)
				{                
					m_AGadgets[i]=GadgetClass;
					m_ADefaultGadgets[i]=GadgetClass;
					i++;
				}
				GadgetClass = class<R6GadgetDescription>(GetNextClass());
				
			}  
			
			FreePackageObjects();
		}
	}
	else
	{
		for( i =0 ; i < m_ADefaultGadgets.Length; i++)
		{
			m_AGadgets[i] = m_ADefaultGadgets[i];
		}
	}
}

//===================================================================
// GetAllPrimaryWeaponGadget: Get All Primary Weapon Gadget
//===================================================================
function GetAllWeaponGadget()
{
	local   class<R6WeaponGadgetDescription>    WeaponGadgetClass;
	local   Array<string>						ATemp;

    local   INT                                 i, k;
	local	BOOL								bEquipValid, bFound;

	// MPF - Eric
	local   INT									j;
	local	R6Mod								pCurrentMod;

	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod;

	if (m_ADefaultWpnGadget.Length == 0)
	{
		//Insert The None Value
		WeaponGadgetClass = class'R6DescWeaponGadgetNone';    
		
		m_APriWpnGadget[0]   = WeaponGadgetClass.Default.m_NameID;
		m_ASecWpnGadget[0]	 = WeaponGadgetClass.Default.m_NameID;
		m_ADefaultWpnGadget[0] = m_APriWpnGadget[0];
		i=1;
		
		//Insert All Primary weapon gadgets except None
		// MPF - Eric
		for (j = 0; j < pCurrentMod.m_aDescriptionPackage.Length; j++)
		{
			WeaponGadgetClass = class<R6WeaponGadgetDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[j]$".u", class'R6WeaponGadgetDescription'));
			
			while((WeaponGadgetClass != None))
			{
#ifdefMPDEMO  
				bEquipValid = IsEquipmentAvailable( WeaponGadgetClass, true);
#endif
#ifndefMPDEMO
				bEquipValid = ((WeaponGadgetClass.Default.m_NameID != "NONE") && (WeaponGadgetClass.Default.m_bPriGadgetWAvailable));
#endif
				if (bEquipValid)
				{
					// Make sure the same gadget nameID does not appear in the list more than once
					bFound = FALSE;
					for ( k = 0; k < m_APriWpnGadget.length && !bFound; k++)
					{
						if ( WeaponGadgetClass.Default.m_NameID == m_APriWpnGadget[k] )
							bFound = TRUE;
					}
					if ( !bFound )
					{
						m_APriWpnGadget[i]=WeaponGadgetClass.Default.m_NameID;
						m_ASecWpnGadget[i]=WeaponGadgetClass.Default.m_NameID;
						m_ADefaultWpnGadget[i] = WeaponGadgetClass.Default.m_NameID;
						i++;
					}
				}
				WeaponGadgetClass = class<R6WeaponGadgetDescription>(GetNextClass());
			}  
			
			FreePackageObjects();
		}
	}
	else
	{
		for( i =0 ; i < m_ADefaultWpnGadget.Length; i++)
		{
			m_APriWpnGadget[i] = m_ADefaultWpnGadget[i];
			m_ASecWpnGadget[i] = m_ADefaultWpnGadget[i];
		}
	}
}

#ifdefMPDEMO        
function BOOL IsEquipmentAvailable( class<R6Description> pClassRestriction, BOOL _bGadget, optional BOOL _bSecWeaponGadgetOnly)
{
	local BOOL bEquipmentExist;

	if (_bGadget)
	{
		if (!_bSecWeaponGadgetOnly)
		{
			if (pClassRestriction.Default.m_NameID == "MINISCOPE")
			{
				bEquipmentExist = true;
			}
		}

		if ( 
			(pClassRestriction.Default.m_NameID == "SILENCER") ||
			(pClassRestriction.Default.m_NameID == "CLAYMOREGADGET") ||
			(pClassRestriction.Default.m_NameID == "FALSEHBGADGET") ||
			(pClassRestriction.Default.m_NameID == "FLASHBANGGADGET") ||
			(pClassRestriction.Default.m_NameID == "FRAGGRENADEGADGET") ||
			(pClassRestriction.Default.m_NameID == "GASMASK") ||
			(pClassRestriction.Default.m_NameID == "HBSGADGET") ||
			(pClassRestriction.Default.m_NameID == "HBSJAMMERGADGET") ||
			(pClassRestriction.Default.m_NameID == "HBSSAJAMMERGADGET") ||
			(pClassRestriction.Default.m_NameID == "PRIMARYMAGS") ||
			(pClassRestriction.Default.m_NameID == "REMOTECHARGEGADGET") ||
			(pClassRestriction.Default.m_NameID == "SECONDARYMAGS") ||
			(pClassRestriction.Default.m_NameID == "SMOKEGRENADEGADGET") ||
			(pClassRestriction.Default.m_NameID == "TEARGASGRENADEGADGET")
			)
		{
			bEquipmentExist = true;
		}
	}
	else
	{
		if (
			// Pistols
			(pClassRestriction.Default.m_NameID == "PISTOL92FS") ||
			(pClassRestriction.Default.m_NameID == "PISTOLAPARMY") ||
			(pClassRestriction.Default.m_NameID == "PISTOLUSP") ||
			(pClassRestriction.Default.m_NameID == "PISTOLMK23") ||
			(pClassRestriction.Default.m_NameID == "PISTOLMAC119") ||
			// SubMachineGuns
			(pClassRestriction.Default.m_NameID == "SUBMP5SD5") ||
			(pClassRestriction.Default.m_NameID == "SUBP90") ||
			(pClassRestriction.Default.m_NameID == "SUBMP5A4") ||
			// Assault
			(pClassRestriction.Default.m_NameID == "ASSAULTG36K") ||
			(pClassRestriction.Default.m_NameID == "ASSAULTM14") ||
			(pClassRestriction.Default.m_NameID == "ASSAULTM16A2") ||
			(pClassRestriction.Default.m_NameID == "ASSAULTTAR21") ||
			// Sniper
			(pClassRestriction.Default.m_NameID == "SNIPERSSG3000") ||
			(pClassRestriction.Default.m_NameID == "SNIPERVSSVINTOREZ") ||
			// LMachGun
			(pClassRestriction.Default.m_NameID == "LMGRPD") ||
			// WeaponGadget
			(pClassRestriction.Default.m_NameID == "MINISCOPE") ||
			(pClassRestriction.Default.m_NameID == "SILENCER")
			)
		{
			bEquipmentExist = true;
		}
	}

	return bEquipmentExist;
}
#endif

defaultproperties
{
     m_iLastListIndex=-1
     m_bDrawListBg=False
}
