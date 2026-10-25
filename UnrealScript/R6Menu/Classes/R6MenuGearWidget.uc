//=============================================================================
//  R6MenuGearWidget.uc : GearRoomMenu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/21 * Created by Alexandre Dionne
//=============================================================================

class R6MenuGearWidget extends R6MenuLaptopWidget;

var R6WindowTextLabel			m_CodeName, m_DateTime, m_Location;

var float       m_fPaddingBetweenElements;
var INT         m_IRosterListLeftPad;
var Font        m_labelFont;
var bool        bshowlog;           //debug


var R6MenuDynTeamListsControl       m_RosterListCtrl;    //Lists on the left of the menu
var R6MenuOperativeDetailControl    m_OperativeDetails;  //Right side when looking at an operative details
var R6MenuEquipmentSelectControl    m_Equipment2dSelect; //Middle part where we can take a look a selected equipment 
var R6MenuEquipmentDetailControl    m_EquipmentDetails;  //Right side when looking at an equipment item

#ifdefDEBUG
var BOOL m_bRebuildAllPlan;
#endif

enum e2DEquipment
{
    Primary_Weapon,
    Primary_WeaponGadget,
    Primary_Bullet,
    Primary_Gadget,
    Secondary_Weapon,
    Secondary_WeaponGadget,
    Secondary_Bullet,
    Secondary_Gadget,
    Armor,
    All_Primary,
    All_Secondary,
    All_PrimaryGadget,
    All_SecondaryGadget,
    All_Armor,
    All_ToAll
};

enum eOperativeTeam
{    
    Red_Team,
    Green_Team,
    Gold_Team,    
    No_Team
};

var R6Operative                             m_currentOperative;     //Current Selected Operative
var eOperativeTeam                          m_currentOperativeTeam; //list in witch the current operative has been added

var class<R6PrimaryWeaponDescription>       m_OpFirstWeaponDesc;    //Equipment of the selected Operative          
var class<R6SecondaryWeaponDescription>     m_OpSecondaryWeaponDesc;
var class<R6WeaponGadgetDescription>        m_OpFirstWeaponGadgetDesc,  m_OpSecondWeaponGadgetDesc;
var class<R6BulletDescription>              m_OpFirstWeaponBulletDesc,  m_OpSecondWeaponBulletDesc;
var class<R6GadgetDescription>              m_OpFirstGadgetDesc,        m_OpSecondGadgetDesc;
var class<R6ArmorDescription>               m_OpArmorDesc;

var R6DescPrimaryMags						m_PrimaryMagsGadget;

function Created()
{
	local int LabelWidth;
    local Region R;
	local INT i,j;
	local R6Mod	pCurrentMod;
	local class<R6DescPrimaryMags> ExtraMags;
        
    Super.Created();
	
	m_labelFont = Root.Fonts[F_IntelTitle];
			
	//Title Labels
	LabelWidth = int(m_Right.WinLeft - m_left.WinWidth )/3;

    //*******************************************************************************************
    //                                 Title Labels
    //*******************************************************************************************
	LabelWidth = int(m_Right.WinLeft - m_left.WinWidth )/3;
    // CODE NAME
	m_CodeName = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_left.WinWidth, 
                                                m_Top.WinHeight, 
		                                        LabelWidth, 
                                                18,
                                                self));
    

    // DATE TIME
	m_DateTime = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_CodeName.WinLeft + m_CodeName.WinWidth,
                                                m_Top.WinHeight, 
                                                LabelWidth,
                                                18,
                                                self));
    

    // LOCATION
	m_Location = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_DateTime.WinLeft + m_DateTime.WinWidth, 
                                                m_Top.WinHeight, 
                                        		m_DateTime.WinWidth, 
                                                18,
                                                self));

    //Left Part of the three part screen
    m_RosterListCtrl = R6MenuDynTeamListsControl(CreateWindow(class'R6MenuDynTeamListsControl', m_left.WinWidth + m_IRosterListLeftPad, m_CodeName.WinTop + m_CodeName.WinHeight, 199, m_HelpTextBar.WinTop - (m_CodeName.WinTop + m_CodeName.WinHeight) - 2, self));
    
    m_OperativeDetails  = R6MenuOperativeDetailControl(CreateWindow(class'R6MenuOperativeDetailControl', 430, m_RosterListCtrl.WinTop, 189, 339, self));
    m_OperativeDetails.HideWindow();

    m_EquipmentDetails  = R6MenuEquipmentDetailControl(CreateWindow(class'R6MenuEquipmentDetailControl', 430, m_RosterListCtrl.WinTop, 189, 339, self));
    m_EquipmentDetails.HideWindow();

    m_Equipment2dSelect = R6MenuEquipmentSelectControl(CreateWindow(class'R6MenuEquipmentSelectControl', 222, m_RosterListCtrl.WinTop, 206, 339, self));
    
    m_NavBar.m_GearButton.bDisabled = true;

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
    local R6GameOptions pGameOptions;
    
    Super.ShowWindow();

   if(R6MenuRootWindow(Root).m_bPlayerPlanInitialized == false)
   {
        pGameOptions = class'Actor'.static.GetGameOptions();
        if( pGameOptions.PopUpLoadPlan == true)
        {
            R6MenuRootWindow(Root).m_ePopUpID = EPopUpID_LoadPlanning;
            R6MenuRootWindow(Root).PopUpMenu(true);      
        }   
   }  
 

}
function Reset()
{   
 
    local R6MissionDescription  CurrentMission;        
    
    CurrentMission = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission);

 
    m_CodeName.SetProperties( Localize(CurrentMission.m_MapName,"ID_CODENAME",CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);

    m_DateTime.SetProperties( Localize(CurrentMission.m_MapName,"ID_DATETIME",CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);
    
    m_Location.SetProperties( Localize(CurrentMission.m_MapName,"ID_LOCATION",CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);
    
    m_EquipmentDetails.BuildAvailableMissionArmors();
    m_RosterListCtrl.FillRosterList();
}


function OperativeSelected( R6Operative selectedOperative, eOperativeTeam _selectedTeam, optional UWindowWindow _pActiveWindow)
{
    //This occurs when an operative has been selected in a list
    m_EquipmentDetails.HideWindow();
    m_currentOperative = selectedOperative;

    m_OpFirstWeaponDesc         =  class<R6PrimaryWeaponDescription>( DynamicLoadObject( m_currentOperative.m_szPrimaryWeapon, class'Class' ) );   
	if(m_OpFirstWeaponDesc == none)
	{
		m_OpFirstWeaponDesc		=  class<R6PrimaryWeaponDescription>( DynamicLoadObject( m_currentOperative.default.m_szPrimaryWeapon, class'Class' ) );   
		m_currentOperative.m_szPrimaryWeapon = m_currentOperative.default.m_szPrimaryWeapon;
	}
	m_OpFirstWeaponGadgetDesc   =  class'R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(m_OpFirstWeaponDesc, m_currentOperative.m_szPrimaryWeaponGadget);
	if(m_OpFirstWeaponGadgetDesc == none)
	{
		m_OpFirstWeaponGadgetDesc   =  class'R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(m_OpFirstWeaponDesc, m_currentOperative.default.m_szPrimaryWeaponGadget);
		m_currentOperative.m_szPrimaryWeaponGadget = m_currentOperative.default.m_szPrimaryWeaponGadget;
	}
	m_OpFirstWeaponBulletDesc   =  class'R6DescriptionManager'.static.GetPrimaryBulletDesc(m_OpFirstWeaponDesc, m_currentOperative.m_szPrimaryWeaponBullet);
	if(m_OpFirstWeaponBulletDesc == none)
	{
		m_OpFirstWeaponBulletDesc   =  class'R6DescriptionManager'.static.GetPrimaryBulletDesc(m_OpFirstWeaponDesc, m_currentOperative.default.m_szPrimaryWeaponBullet);
		m_currentOperative.m_szPrimaryWeaponBullet = m_currentOperative.default.m_szPrimaryWeaponBullet;
	}
    
    m_OpSecondaryWeaponDesc     =  class<R6SecondaryWeaponDescription>( DynamicLoadObject( m_currentOperative.m_szSecondaryWeapon, class'Class' ) );
	if(m_OpSecondaryWeaponDesc == none)
	{
		m_OpSecondaryWeaponDesc =  class<R6SecondaryWeaponDescription>( DynamicLoadObject( m_currentOperative.default.m_szSecondaryWeapon, class'Class' ) );
		m_currentOperative.m_szSecondaryWeapon = m_currentOperative.default.m_szSecondaryWeapon;
	}
    m_OpSecondWeaponGadgetDesc  =  class'R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(m_OpSecondaryWeaponDesc, m_currentOperative.m_szSecondaryWeaponGadget);
	if(m_OpSecondWeaponGadgetDesc == none)
	{
		m_OpSecondWeaponGadgetDesc  =  class'R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(m_OpSecondaryWeaponDesc, m_currentOperative.default.m_szSecondaryWeaponGadget);
		m_currentOperative.m_szSecondaryWeaponGadget = m_currentOperative.default.m_szSecondaryWeaponGadget;
	}
	m_OpSecondWeaponBulletDesc  =  class'R6DescriptionManager'.static.GetSecondaryBulletDesc(m_OpSecondaryWeaponDesc, m_currentOperative.m_szSecondaryWeaponBullet);
	if(m_OpSecondWeaponBulletDesc == none)
	{
		m_OpSecondWeaponBulletDesc  =  class'R6DescriptionManager'.static.GetSecondaryBulletDesc(m_OpSecondaryWeaponDesc, m_currentOperative.default.m_szSecondaryWeaponBullet);
		m_currentOperative.m_szSecondaryWeaponBullet = m_currentOperative.default.m_szSecondaryWeaponBullet;
	}

    m_OpFirstGadgetDesc         =  class<R6GadgetDescription>( DynamicLoadObject( m_currentOperative.m_szPrimaryGadget, class'Class' ) );
	if(m_OpFirstGadgetDesc == none)
	{
		m_OpFirstGadgetDesc     =  class<R6GadgetDescription>( DynamicLoadObject( m_currentOperative.default.m_szPrimaryGadget, class'Class' ) );
		m_currentOperative.m_szPrimaryGadget = m_currentOperative.default.m_szPrimaryGadget;
	}
    m_OpSecondGadgetDesc        =  class<R6GadgetDescription>( DynamicLoadObject( m_currentOperative.m_szSecondaryGadget, class'Class' ) );
	if(m_OpSecondGadgetDesc == none)
	{
		m_OpSecondGadgetDesc    =  class<R6GadgetDescription>( DynamicLoadObject( m_currentOperative.default.m_szSecondaryGadget, class'Class' ) );
		m_currentOperative.m_szSecondaryGadget = m_currentOperative.default.m_szSecondaryGadget;
	}
#ifndefSPDEMO
    m_OpArmorDesc               =  class<R6ArmorDescription>( DynamicLoadObject( m_currentOperative.m_szArmor, class'Class' ) );
	if(m_OpArmorDesc == none)
	{
		m_OpArmorDesc           =  class<R6ArmorDescription>( DynamicLoadObject( m_currentOperative.default.m_szArmor, class'Class' ) );
		m_currentOperative.m_szArmor = m_currentOperative.default.m_szArmor;
	}
#endif
#ifdefSPDEMO    
    m_OpArmorDesc               =  class<R6ArmorDescription>( DynamicLoadObject( "R6Description.R6DescHeavy", class'Class' ) );
#endif

    m_OperativeDetails.ShowWindow();
    m_OperativeDetails.UpdateDetails();
    m_Equipment2dSelect.UpdateDetails();
    m_currentOperativeTeam = _selectedTeam;

    m_Equipment2dSelect.DisableControls(m_currentOperativeTeam == No_Team);

    if ( (bWindowVisible) && (_pActiveWindow != None) )
	{
		_pActiveWindow.ActivateWindow( 0, false); // activatewindow to re-build acceptsfocus chain destroy by m_OperativeDetails.ShowWindow(); in this fct
	}
}

function SetupOperative( OUT R6Operative OpToChek)
{
    //This functions Makes sure an operative has a valid equipment
    local class<R6ArmorDescription> currentArmor;

    currentArmor = class<R6ArmorDescription>( DynamicLoadObject( OpToChek.m_szArmor, class'Class' ) );
        
    if( m_EquipmentDetails.IsAmorAvailable(currentArmor, OpToChek) == false )
        OpToChek.m_szArmor = string(m_EquipmentDetails.GetDefaultArmor());

}

function EquipmentSelected(e2DEquipment equipmentSelected)
{   
    local R6WindowTextIconsListBox listboxes[3];
    local R6Operative               tmpOperative;
    local R6WindowListBoxItem       tmpItem;
    local INT                       i;

    //Ordering of the list box is important
    listboxes[0]   = m_RosterListCtrl.m_RedListBox.m_listBox;
    listboxes[1]   = m_RosterListCtrl.m_GreenListBox.m_listBox;
    listboxes[2]   = m_RosterListCtrl.m_GoldListBox.m_listBox;


    switch(equipmentSelected)    
    {
    case All_Primary:         
        //Affect all primary equipment to all team members 
       tmpItem = R6WindowListBoxItem(listboxes[m_currentOperativeTeam].Items.Next);
       
       while( tmpItem != None)
       {
            tmpOperative = R6Operative(tmpItem.m_Object);
            if(tmpOperative != None)
            {                            
                tmpOperative.m_szPrimaryWeapon          = m_currentOperative.m_szPrimaryWeapon;                 
                tmpOperative.m_szPrimaryWeaponBullet    = m_currentOperative.m_szPrimaryWeaponBullet;                 
                tmpOperative.m_szPrimaryWeaponGadget    = m_currentOperative.m_szPrimaryWeaponGadget;                 
            }              

            tmpItem = R6WindowListBoxItem(tmpItem.Next);
        }
        break;
    case All_Secondary:
       //Affect all secondary equipment to all team members 
       tmpItem = R6WindowListBoxItem(listboxes[m_currentOperativeTeam].Items.Next);
       
       while( tmpItem != None)
       {
            tmpOperative = R6Operative(tmpItem.m_Object);
            if(tmpOperative != None)
            {                            
                tmpOperative.m_szSecondaryWeapon          = m_currentOperative.m_szSecondaryWeapon;                 
                tmpOperative.m_szSecondaryWeaponBullet    = m_currentOperative.m_szSecondaryWeaponBullet;                 
                tmpOperative.m_szSecondaryWeaponGadget    = m_currentOperative.m_szSecondaryWeaponGadget;                 
            }              

            tmpItem = R6WindowListBoxItem(tmpItem.Next);
        }
        break;
    case All_PrimaryGadget:
       //Affect primary gadget to all team members 
       tmpItem = R6WindowListBoxItem(listboxes[m_currentOperativeTeam].Items.Next);
       
       while( tmpItem != None)
       {
            tmpOperative = R6Operative(tmpItem.m_Object);
            if(tmpOperative != None)
            {                            
                tmpOperative.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;                 
            }              

            tmpItem = R6WindowListBoxItem(tmpItem.Next);
       }      
       break;
        
    case All_SecondaryGadget:
             //Affect secondary gadget to all team members 
       tmpItem = R6WindowListBoxItem(listboxes[m_currentOperativeTeam].Items.Next);
       
       while( tmpItem != None)
       {
            tmpOperative = R6Operative(tmpItem.m_Object);
            if(tmpOperative != None)
            {                            
                tmpOperative.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;                 
            }              

            tmpItem = R6WindowListBoxItem(tmpItem.Next);
       }      
       

        break;
    case All_Armor:

       //Affect Armor to all team members 
       tmpItem = R6WindowListBoxItem(listboxes[m_currentOperativeTeam].Items.Next);
       
       while( tmpItem != None)
       {
            tmpOperative = R6Operative(tmpItem.m_Object);
            if(tmpOperative != None)
            {                            
                tmpOperative.m_szArmor = m_currentOperative.m_szArmor;                 
            }              

            tmpItem = R6WindowListBoxItem(tmpItem.Next);
       }      
       break;    
    case All_ToAll:
        for(i=0; i<3; i++) 
        {
          tmpItem = R6WindowListBoxItem(listboxes[i].Items.Next);
       
           while( tmpItem != None)
           {
                tmpOperative = R6Operative(tmpItem.m_Object);
                if(tmpOperative != None)
                { 
                    tmpOperative.m_szPrimaryWeapon          = m_currentOperative.m_szPrimaryWeapon;                 
                    tmpOperative.m_szPrimaryWeaponBullet    = m_currentOperative.m_szPrimaryWeaponBullet;                 
                    tmpOperative.m_szPrimaryWeaponGadget    = m_currentOperative.m_szPrimaryWeaponGadget;  
                    tmpOperative.m_szSecondaryWeapon        = m_currentOperative.m_szSecondaryWeapon;                 
                    tmpOperative.m_szSecondaryWeaponBullet  = m_currentOperative.m_szSecondaryWeaponBullet;                 
                    tmpOperative.m_szSecondaryWeaponGadget  = m_currentOperative.m_szSecondaryWeaponGadget;   
                    tmpOperative.m_szPrimaryGadget          = m_currentOperative.m_szPrimaryGadget;                 
                    tmpOperative.m_szSecondaryGadget        = m_currentOperative.m_szSecondaryGadget;               
                    tmpOperative.m_szArmor                  = m_currentOperative.m_szArmor;                 
                }              

                tmpItem = R6WindowListBoxItem(tmpItem.Next);
           }  
            
        }
        break;
    default:
            //This occurs when a 2d equipment is clicked
        m_OperativeDetails.HideWindow();    
        m_EquipmentDetails.ShowWindow();
        m_EquipmentDetails.FillListBox(equipmentSelected);
        break;

    }   
       
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
    
            if(m_OpFirstWeaponDesc != class<R6PrimaryWeaponDescription>(DecriptionClass))
            {                
                //Primary Weapon Changed
                m_currentOperative.m_szPrimaryWeapon = string(DecriptionClass);
                m_OpFirstWeaponDesc = class<R6PrimaryWeaponDescription>(DecriptionClass);
                if(bshowlog)log("Changing"@m_currentOperative.class@" Primary Weapon for "@m_currentOperative.m_szPrimaryWeapon);           
            
                //Primary Weapon Gadget Changed
                DecriptionClass = class'R6DescWeaponGadgetNone';
                m_currentOperative.m_szPrimaryWeaponGadget = DecriptionClass.Default.m_NameID;
                m_OpFirstWeaponGadgetDesc = class<R6WeaponGadgetDescription>(DecriptionClass);
                if(bshowlog)log("Changing"@m_currentOperative.class@" Primary Weapon Gadget for "@m_currentOperative.m_szPrimaryWeaponGadget);
            
                //Primary Weapon Bullets Changed
                DecriptionClass = class'R6DescriptionManager'.static.findPrimaryDefaultAmmo(class<R6PrimaryWeaponDescription>(inDescriptionClass));
                m_currentOperative.m_szPrimaryWeaponBullet = DecriptionClass.Default.m_NameTag;
                m_OpFirstWeaponBulletDesc = class<R6BulletDescription>(DecriptionClass);
                if(bshowlog)log("Changing"@m_currentOperative.class@" Primary Weapon Bullets for "@m_currentOperative.m_szPrimaryWeaponBullet);
            }
            break;
        case 1 :
            //Primary Weapon Gadget Changed
            m_currentOperative.m_szPrimaryWeaponGadget = DecriptionClass.Default.m_NameID;
            m_OpFirstWeaponGadgetDesc = class<R6WeaponGadgetDescription>(DecriptionClass);
            if(bshowlog)log("Changing"@m_currentOperative.class@" Primary Weapon Gadget for "@m_currentOperative.m_szPrimaryWeaponGadget);
            break;
        case 2 :            
            //Primary Weapon Bullets Changed
            m_currentOperative.m_szPrimaryWeaponBullet = DecriptionClass.Default.m_NameTag;
            m_OpFirstWeaponBulletDesc = class<R6BulletDescription>(DecriptionClass);
            if(bshowlog)log("Changing"@m_currentOperative.class@" Primary Weapon Bullets for "@m_currentOperative.m_szPrimaryWeaponBullet);
            break;
        case 3 :
            //Primary Gadget
            m_currentOperative.m_szPrimaryGadget = string(DecriptionClass);
            m_OpFirstGadgetDesc = class<R6GadgetDescription>(DecriptionClass);              
            if(bshowlog)log("Changing"@m_currentOperative.class@" Primary Gadget for "@m_currentOperative.m_szPrimaryWeapon);
            break;
        case 4 :

            inDescriptionClass = DecriptionClass;

            if(m_OpSecondaryWeaponDesc != class<R6SecondaryWeaponDescription>(DecriptionClass))
            {
                //Secondary Weapon Changed
                m_currentOperative.m_szSecondaryWeapon = string(DecriptionClass);
                m_OpSecondaryWeaponDesc = class<R6SecondaryWeaponDescription>(DecriptionClass);
                if(bshowlog)log("Changing"@m_currentOperative.class@" Secondary Weapon for "@m_currentOperative.m_szSecondaryWeapon);

                 //Secondary Weapon Gadget Changed
                DecriptionClass = class'R6DescWeaponGadgetNone';
                m_currentOperative.m_szSecondaryWeaponGadget = DecriptionClass.Default.m_NameID;
                m_OpSecondWeaponGadgetDesc = class<R6WeaponGadgetDescription>(DecriptionClass);
                if(bshowlog)log("Changing"@m_currentOperative.class@" Secondary Weapon Gadget for "@m_currentOperative.m_szSecondaryWeaponGadget);

                //Secondary Weapon Bullets Changed
                DecriptionClass = class'R6DescriptionManager'.static.findSecondaryDefaultAmmo(class<R6SecondaryWeaponDescription>(inDescriptionClass));
                m_currentOperative.m_szSecondaryWeaponBullet = DecriptionClass.Default.m_NameTag;
                m_OpSecondWeaponBulletDesc = class<R6BulletDescription>(DecriptionClass);
                if(bshowlog)log("Changing"@m_currentOperative.class@" Secondary Weapon Bullets for "@m_currentOperative.m_szSecondaryWeaponBullet);
            }            
            break;
        case 5 :
            //Secondary Weapon Gadget Changed
            m_currentOperative.m_szSecondaryWeaponGadget = DecriptionClass.Default.m_NameID;
            m_OpSecondWeaponGadgetDesc = class<R6WeaponGadgetDescription>(DecriptionClass);
            if(bshowlog)log("Changing"@m_currentOperative.class@" Secondary Weapon Gadget for "@m_currentOperative.m_szSecondaryWeaponGadget);
            break;
        case 6 :
            //Secondary Weapon Bullets Changed
            m_currentOperative.m_szSecondaryWeaponBullet = DecriptionClass.Default.m_NameTag;
            m_OpSecondWeaponBulletDesc = class<R6BulletDescription>(DecriptionClass);
            if(bshowlog)log("Changing"@m_currentOperative.class@" Secondary Weapon Bullets for "@m_currentOperative.m_szSecondaryWeaponBullet);
            break;
        case 7 :
            //Secondary Gadget
            m_currentOperative.m_szSecondaryGadget = string(DecriptionClass);
            m_OpSecondGadgetDesc = class<R6GadgetDescription>(DecriptionClass);              
            if(bshowlog)log("Changing"@m_currentOperative.class@" Secondary Gadget for "@m_currentOperative.m_szSecondaryGadget);
            break;
        case 8 :
            //Armor
            m_currentOperative.m_szArmor = string(DecriptionClass);
            m_OpArmorDesc = class<R6ArmorDescription>(DecriptionClass);
            if(bshowlog)log("Changing"@m_currentOperative.class@" Armor for "@m_currentOperative.m_szArmor);
            break;
        }           
        m_Equipment2dSelect.UpdateDetails();
}

//MAKE SURE THIS FUNCTION IS THE SAME AS THE ONE IN THE MULTIPLAYER GEAR ROOM
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


function SetStartTeamInfo()
{
    //This function fills the startTeamInfo struct need to spawn the player and the AI
    local R6StartGameInfo           StartGameInfo;
    local INT                       i, j, k, rainbowAdded;
    local R6WindowTextIconsListBox  tmpListBox[3], currentListBox;
    //local BOOL                      PlayerTeamSet;
    local R6Operative               tmpOperative;
    local R6WindowListBoxItem       tmpItem;
    local string                    Tag;

    local   class<R6PrimaryWeaponDescription>   PrimaryWeaponClass;
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
    local   class<R6BulletDescription>          PrimaryWeaponBulletClass,   SecondaryWeaponBulletClass;
    local   class<R6GadgetDescription>          PrimaryGadgetClass,         SecondaryGadgetClass;
    local   class<R6WeaponGadgetDescription>    PrimaryWeaponGadgetClass,   SecondaryWeaponGadgetClass;
    local   class<R6ArmorDescription>           ArmorDescriptionClass;
    local   BOOL                                Found;  
    
     
    StartGameInfo = R6Console(Root.console).master.m_StartGameInfo;
    
    tmpListBox[0] = m_RosterListCtrl.m_RedListBox.m_listBox;
    tmpListBox[1] = m_RosterListCtrl.m_GreenListBox.m_listBox;
    tmpListBox[2] = m_RosterListCtrl.m_GoldListBox.m_listBox;
    //PlayerTeamSet = false;

    //Parse Lists Boxes and fill teamsInfo
    for(j=0; j<3; j++)
    {
        currentListBox = tmpListBox[j];
        tmpItem = R6WindowListBoxItem(currentListBox.Items.Next);
        rainbowAdded =0;

        for(i=0; i< currentListBox.Items.Count(); i++)
        {
            
            tmpOperative = R6Operative(tmpItem.m_Object);
        
            if(tmpOperative != None)    
            {
                //Fill R6RainbowStartInfo structure
                PrimaryWeaponClass          = class<R6PrimaryWeaponDescription>( DynamicLoadObject( tmpOperative.m_szPrimaryWeapon, class'Class' ) );
                PrimaryWeaponBulletClass    = class'R6DescriptionManager'.static.GetPrimaryBulletDesc(PrimaryWeaponClass, tmpOperative.m_szPrimaryWeaponBullet);
                PrimaryWeaponGadgetClass    = class'R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(PrimaryWeaponClass, tmpOperative.m_szPrimaryWeaponGadget);

                SecondaryWeaponClass        = class<R6SecondaryWeaponDescription>( DynamicLoadObject( tmpOperative.m_szSecondaryWeapon, class'Class' ) );            
                SecondaryWeaponBulletClass  = class'R6DescriptionManager'.static.GetSecondaryBulletDesc(SecondaryWeaponClass, tmpOperative.m_szSecondaryWeaponBullet);
                SecondaryWeaponGadgetClass  = class'R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(SecondaryWeaponClass, tmpOperative.m_szSecondaryWeaponGadget);

                PrimaryGadgetClass          = class<R6GadgetDescription>( DynamicLoadObject( tmpOperative.m_szPrimaryGadget, class'Class' ) );
                SecondaryGadgetClass        = class<R6GadgetDescription>( DynamicLoadObject( tmpOperative.m_szSecondaryGadget, class'Class' ) );

#ifndefSPDEMO
                ArmorDescriptionClass       = class<R6ArmorDescription>( DynamicLoadObject( tmpOperative.m_szArmor, class'Class' ) );
#endif
#ifdefSPDEMO
                ArmorDescriptionClass       = class<R6ArmorDescription>( DynamicLoadObject( "R6Description.R6DescHeavy", class'Class' ) );
#endif

                
                //Character name is needed to load plans
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_CharacterName        =  tmpOperative.GetShortName();

                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_ArmorName            =  ArmorDescriptionClass.Default.m_ClassName;               
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[0]  =  PrimaryWeaponGadgetClass.Default.m_ClassName;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[1]  =  SecondaryWeaponGadgetClass.Default.m_ClassName;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[0]        =  PrimaryGadgetClass.Default.m_ClassName;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[1]        =  SecondaryGadgetClass.Default.m_ClassName;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iHealth              =  tmpOperative.m_iHealth;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID         =  tmpOperative.m_iUniqueID;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceTexture          =  tmpOperative.m_TMenuFaceSmall;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceCoords.X         =  tmpOperative.m_RMenuFaceSmallX;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceCoords.Y         =  tmpOperative.m_RMenuFaceSmallY;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceCoords.Z         =  tmpOperative.m_RMenuFaceSmallW;
                StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceCoords.W         =  tmpOperative.m_RMenuFaceSmallH;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID		=  tmpOperative.m_szSpecialityID;

				// skills of each operative
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillAssault		= tmpOperative.m_fAssault * 0.01;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillDemolitions	= tmpOperative.m_fDemolitions * 0.01;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillElectronics	= tmpOperative.m_fElectronics * 0.01;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillSniper			= tmpOperative.m_fSniper * 0.01;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillStealth		= tmpOperative.m_fStealth * 0.01;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillSelfControl	= tmpOperative.m_fSelfControl * 0.01;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillLeadership		= tmpOperative.m_fLeadership * 0.01;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillObservation	= tmpOperative.m_fObservation * 0.01;				

                if(tmpOperative.m_szGender == "M")
                    StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_bIsMale = true;
                else
                    StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_bIsMale = false;
                
                //Search for the right PrimaryWeaponClass to spawn depending on the type of gadget and bullet
                Found = false;
                for(k=0; (k < PrimaryWeaponClass.Default.m_WeaponTags.Length) && (Found == False); k++)
                {
                    if(PrimaryWeaponClass.Default.m_WeaponTags[k] == PrimaryWeaponGadgetClass.Default.m_NameTag)
                    {
                        Found = true;
                        StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0]    =  PrimaryWeaponClass.Default.m_WeaponClasses[k];
                        Tag = PrimaryWeaponClass.Default.m_WeaponTags[k];
                    }                                           
                    else if(PrimaryWeaponClass.Default.m_WeaponTags[k] == PrimaryWeaponBulletClass.Default.m_NameTag )
                    {
                        //This is a special case for shotguns where bullets determine the weapon to spawn
                        Found = true;
                        StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0]    =  PrimaryWeaponClass.Default.m_WeaponClasses[k];
                        Tag = PrimaryWeaponClass.Default.m_WeaponTags[k];
                    }                    
                        
                }

				if(Found == false)
                {
                    StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0]    =  PrimaryWeaponClass.Default.m_WeaponClasses[0];
                    Tag = PrimaryWeaponClass.Default.m_WeaponTags[0];
                }
                //If necessary spawn subsonic bullets
                if(Tag == "SILENCED")
                    StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[0]        =  PrimaryWeaponBulletClass.Default.m_SubsonicClassName;                
                else
                    StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[0]        =  PrimaryWeaponBulletClass.Default.m_ClassName;                
                
                //Search for the right SecondaryWeaponClass to spawn depending on the type of gadget and bullet
                Found = false;
                for(k=0; (k < SecondaryWeaponClass.Default.m_WeaponTags.Length) && (Found == False); k++)
                {
                    if(SecondaryWeaponClass.Default.m_WeaponTags[k] == SecondaryWeaponGadgetClass.Default.m_NameTag)
                    {
                        Found = true;
                        StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1]    =  SecondaryWeaponClass.Default.m_WeaponClasses[k];
                        Tag = SecondaryWeaponClass.Default.m_WeaponTags[k];
                    }                                           
                    else if(SecondaryWeaponClass.Default.m_WeaponTags[k] == SecondaryWeaponBulletClass.Default.m_NameTag )
                    {
                        //Don't think this could occur for a secondary weapon

                        Found = true;
                        StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1]    =  SecondaryWeaponClass.Default.m_WeaponClasses[k];
                        Tag = SecondaryWeaponClass.Default.m_WeaponTags[k];
                    }   

                } 
                if(Found == false)
                {
                    StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1]    =  SecondaryWeaponClass.Default.m_WeaponClasses[0];
                    Tag = SecondaryWeaponClass.Default.m_WeaponTags[0];
                }                    

                //If necessary spawn subsonic bullets
                if(Tag == "SILENCED")
                    StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[1]        =  SecondaryWeaponBulletClass.Default.m_SubsonicClassName;                
                else
                    StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[1]        =  SecondaryWeaponBulletClass.Default.m_ClassName;                                
                
               
                tmpItem = R6WindowListBoxItem(tmpItem.Next);
                rainbowAdded++;
            }          
        
        }
        StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers=rainbowAdded;

    }          

}

#ifdefDEBUG
function RebuildAllPlanningFile()
{
    local R6Console             r6console;
	local R6MissionDescription  mission;
	local LevelInfo				pLevel;
    local string                szGameTypeDirName, szMapName, szFileName;
    local string                szEnglishGTDirectory;
    local string				szLoadErrorMsgMapName;
    local string				szLoadErrorMsgGameType;
	local string				szFileNameExt[2];
	local INT                   i, j;

	pLevel = GetLevel();
    r6console = R6Console( Root.Console );

	m_bRebuildAllPlan = true;

	GetLevel().GetGameTypeSaveDirectories( szGameTypeDirName, szEnglishGTDirectory );

	switch(szGameTypeDirName)
	{
		case "Mission":	szFileNameExt[0] = "_MISSION"; break;
		case "Lone Wolf":	szFileNameExt[0] = "_LONE"; break;
		case "Terrorist Hunt":	szFileNameExt[0] = "_TERRORIST"; break;
		case "Hostage Rescue":	szFileNameExt[0] = "_HOSTAGE"; break;
		default: 
			log("NameExt not valid");
			return;
	}

	szFileNameExt[1] = szFileNameExt[0] $ "_ACTION";

	for ( j = 0; j < 2; j++)
	{
		// from the main list, get all mission who can be played
		for ( i = 0; i < r6console.m_aMissionDescriptions.Length; i++ )
		{
			mission = r6console.m_aMissionDescriptions[i];

			szMapName = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );

			if (szMapName != "")
			{

				//Empty the list before loading a new one.
				R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();

				szFileName = mission.m_ShortName $ szFileNameExt[j]; 

				if(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.LoadPlanning(
									mission.m_MapName,
									szMapName,
									szEnglishGTDirectory,
									szGameTypeDirName,
									szFileName,
									Root.console.Master.m_StartGameInfo,
									szLoadErrorMsgMapName,
									szLoadErrorMsgGameType) == true)
				{
					log("LOAD SUCCESS"@szFileName);
					LoadRosterFromStartInfo();

					// save the file
					R6PlanningCtrl(GetPlayerOwner()).ResetAllID(); 
    
					SetStartTeamInfoForSaving();          

					R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;

					if( R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.SavePlanning(
						mission.m_MapName,
						szMapName,
						szEnglishGTDirectory,
						szGameTypeDirName,
						szFileName,
						Root.console.Master.m_StartGameInfo) == true )
					{
						log("SAVE SUCCESS"@szFileName);
					}
				}

			}
		}
	}

	m_bRebuildAllPlan = false;
}
#endif

function SetStartTeamInfoForSaving()
{    
    local R6StartGameInfo           StartGameInfo;
    local INT                       i, j, k;
    local R6WindowTextIconsListBox  tmpListBox[3], currentListBox;    
    local R6Operative               tmpOperative;
    local R6WindowListBoxItem       tmpItem;
    

    local   BOOL                                Found;
    
    
    StartGameInfo = R6Console(Root.console).master.m_StartGameInfo;
    
    tmpListBox[0] = m_RosterListCtrl.m_RedListBox.m_listBox;
    tmpListBox[1] = m_RosterListCtrl.m_GreenListBox.m_listBox;
    tmpListBox[2] = m_RosterListCtrl.m_GoldListBox.m_listBox;
    

     for(j=0; j<3; j++)
        {
            currentListBox = tmpListBox[j];
            tmpItem = R6WindowListBoxItem(currentListBox.Items.Next);
            StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers = 0;
            
            for(i=0; i< currentListBox.Items.Count(); i++)
            {    
                tmpOperative = R6Operative(tmpItem.m_Object);

                 if(tmpOperative != None)
                 {
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_ArmorName       = tmpOperative.m_szArmor;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0]   = tmpOperative.m_szPrimaryWeapon;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1]   = tmpOperative.m_szSecondaryWeapon;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[0]   = tmpOperative.m_szPrimaryWeaponBullet;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[1]   = tmpOperative.m_szSecondaryWeaponBullet;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[0] = tmpOperative.m_szPrimaryWeaponGadget;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[1] = tmpOperative.m_szSecondaryWeaponGadget;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[0]   = tmpOperative.m_szPrimaryGadget;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[1]   = tmpOperative.m_szSecondaryGadget;
                     StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID    = tmpOperative.m_iUniqueID;
					 StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID	= tmpOperative.m_szSpecialityID;
                     StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers++;
                 }              

                  tmpItem = R6WindowListBoxItem(tmpItem.Next);
            }            

        }        

}

function LoadRosterFromStartInfo()
{
    local R6StartGameInfo               StartGameInfo;
    local int                           i,j,k,l;
	local INT							TeamIDs[8];
    local R6WindowTextIconsSubListBox   tmpListBox[3], currentListBox;
    local bool                          found, bOperativeIsNotReady, bRookieCase, bIDMatch;
    local R6WindowListBoxItem           TempItem , SelectedItem, bkpValidItem;
    local R6Operative                   tmpOperative;

    //Making the correct Selection after a reload
    local R6WindowListBoxItem           selectedOperativeItem;
    local int                           selectedOperativeTeamId;

    //this is usefull when we load a roster from a plan
    //it fills the operative lists trying to recreate the
    //teams as they were when the player saved it's planning

    StartGameInfo = R6Console(Root.console).master.m_StartGameInfo;    
    tmpListBox[0] = m_RosterListCtrl.m_RedListBox;
    tmpListBox[1] = m_RosterListCtrl.m_GreenListBox;
    tmpListBox[2] = m_RosterListCtrl.m_GoldListBox;

    //Reset lists box
    //m_RosterListCtrl.FillRosterList();
    Reset();

	// fill all the exact team with the info in StartGameInfo, this will be use to do a difference with available operative
	k = 0;
    for(j=0; j<3; j++)
    {
        //Go through each team
        for(i=0; i< StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers ; i++)
        {
			TeamIDs[k] = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID;
			k++;
		}
	}

    //Parse startinfo team struct and try to fill the team listbox with the operatives

    for(j=0; j<3; j++)
    {
        
        currentListBox = tmpListBox[j];       

        //Go through each team
        for(i=0; i< StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers ; i++)
        {

            k=0;
            found = false;   
			bOperativeIsNotReady = false;
			bRookieCase  = false;
			bIDMatch	 = false;
			bkpValidItem = None;
            SelectedItem = R6WindowListBoxItem(m_RosterListCtrl.m_ListBox.Items.next);
            
			//if we get some rookie operative the last mission (-5 : 5 type of rookies) 
			if ( StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID > m_RosterListCtrl.m_ListBox.Items.Count() - 5)
			{
				bRookieCase  = true;
			}

            //Parse the main listbox to find the operatives we want to update
            while( found == false && k < m_RosterListCtrl.m_ListBox.Items.Count())
            {                
                tmpOperative = R6Operative(SelectedItem.m_Object);
#ifdefDEBUG
				if (bShowLog) log("tmpOperative: "@tmpOperative);
#endif

				if (tmpOperative != None)
				{
					//let's see if we have a match
					bIDMatch = (StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID == tmpOperative.m_iUniqueID);

					if (bIDMatch)
					{
#ifdefDEBUG	
						if(bShowLog)
						{
							log("--> from pln: "@StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID);
							log("--> from list: "@tmpOperative.m_szSpecialityID);
						}
#endif

						// if it's a rookie, check if the specialty is the same. because the unique ID differ depending the creation of rookies
						if (tmpOperative.m_iRookieID != -1)
						{
							if (!(StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID ~= tmpOperative.m_szSpecialityID))
							{
#ifdefDEBUG	
								if(bShowLog)log("IDMatch, it's a rookie case!!!");
#endif
								bRookieCase = true;
							}
						}
					}

					if ((bIDMatch) && (!bRookieCase))
					{
						// if the operative is not ready, mean that is Wounded, Incapacitated or Dead --> see R6OperativeClass
						// or if it's already in the list, take a new one by using bOperativeIsNotReady
						if ((!tmpOperative.IsOperativeReady()) || (SelectedItem.m_addedToSubList))
						{
#ifdefDEBUG	
						if(bShowLog)log("IDMatch, operative is not ready"@SelectedItem.HelpText);
#endif
							bOperativeIsNotReady = true;
						}
						else
						{
							found = true;
						}
					}
					else if (StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID ~= tmpOperative.m_szSpecialityID)
					{
						if ((bkpValidItem == None) && (tmpOperative.IsOperativeReady() && (!SelectedItem.m_addedToSubList)))
						{
							bkpValidItem = SelectedItem; // get a valid operative in bkp
#ifdefDEBUG	
							if(bShowLog)log("bkpValidItem is now: "$SelectedItem.HelpText);
#endif
							// check if this operative is not already assign in an another team by the planning
							for (l =0; l < 8; l++)
							{
								if (TeamIDs[l] == tmpOperative.m_iUniqueID)
								{
#ifdefDEBUG
									if (bShowLog) log("This operative is already in a team, select a new one");
#endif
									bkpValidItem = None;
									break;
								}
							}
						}
					}

					if ((bOperativeIsNotReady) || (bRookieCase))
					{
						if ( bkpValidItem != None)
						{
							//this operative replace the dead operative
							SelectedItem = bkpValidItem;
							tmpOperative = R6Operative(SelectedItem.m_Object);
							found = true;
#ifdefDEBUG	
						if(bShowLog)log("bOperativeIsNotReady is"@bOperativeIsNotReady@"bRookieCase is"@bRookieCase@"tmpOperative is "@SelectedItem.HelpText);
#endif
						}
					}
				}

				if (found)
				{
#ifdefDEBUG	
						if(bShowLog)log("Found is true and operative = "@tmpOperative.getName());
#endif
					tmpOperative.m_szArmor                 = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_ArmorName;
					tmpOperative.m_szPrimaryWeapon         = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0];
					tmpOperative.m_szSecondaryWeapon       = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1];
					tmpOperative.m_szPrimaryWeaponBullet   = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[0];
					tmpOperative.m_szSecondaryWeaponBullet = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[1];
					tmpOperative.m_szPrimaryWeaponGadget   = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[0];
					tmpOperative.m_szSecondaryWeaponGadget = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[1];
					tmpOperative.m_szPrimaryGadget         = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[0];
					tmpOperative.m_szSecondaryGadget       = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[1];
#ifdefDEBUG
					if (!m_bRebuildAllPlan)
#endif
					SetupOperative(tmpOperative);

					TempItem = R6WindowListBoxItem(currentListBox.m_listBox.Items.Append( class'R6WindowListBoxItem'));
					if( (TempItem != None))
					{
						TempItem.m_Icon                 = SelectedItem.m_Icon;
						TempItem.m_IconRegion           = SelectedItem.m_IconRegion;
						TempItem.m_IconSelectedRegion   = SelectedItem.m_IconSelectedRegion;
						TempItem.HelpText               = SelectedItem.HelpText;
						TempItem.m_ParentListItem       = SelectedItem;
						TempItem.m_Object               = SelectedItem.m_Object;
						SelectedItem.m_addedToSubList   = true;
					}

                    if(selectedOperativeItem == None)
                    {
                        //recall the good item to select
                        selectedOperativeItem = TempItem;
                        selectedOperativeTeamId = j;
                    }
				}
				else
				{
					k++;
#ifdefDEBUG
					if ((bShowLog) && (SelectedItem.m_Object != None))
					{
						log("No match"@StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_CharacterName@"!="@string( SelectedItem.m_Object.class)@SelectedItem.HelpText);
						log("=========================================================");
					}
#endif

					SelectedItem = R6WindowListBoxItem(SelectedItem.next);
				}
            }          

        }
    }

#ifdefDEBUG
	if (!m_bRebuildAllPlan)
	{
#endif
		m_RosterListCtrl.RefreshButtons();
		m_RosterListCtrl.ResizeSubLists();

		//Make the sub list selection
		if(selectedOperativeItem != None)
			tmpListBox[selectedOperativeTeamId].m_listBox.SetSelectedItem(selectedOperativeItem);
		else 
			OperativeSelected(m_currentOperative, m_currentOperativeTeam, m_RosterListCtrl.m_ListBox);

#ifdefDEBUG
	}
#endif
}


function bool IsTeamConfigValid()
{
    //This is called for single player
    
    if( (m_RosterListCtrl == None))
        return false;
    
    if(
    (m_RosterListCtrl.m_RedListBox.m_listBox.Items.Count() +
    m_RosterListCtrl.m_GreenListBox.m_listBox.Items.Count() +
    m_RosterListCtrl.m_GoldListBox.m_listBox.Items.Count()) 
    <= 0 )
        return false; //No operative Has been added to a team
    else
        return true;
    
}

defaultproperties
{
     m_currentOperativeTeam=No_Team
     m_IRosterListLeftPad=1
     m_fPaddingBetweenElements=3.000000
}
