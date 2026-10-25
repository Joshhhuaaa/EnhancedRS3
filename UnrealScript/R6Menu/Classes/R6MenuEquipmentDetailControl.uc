//=============================================================================
//  R6MenuEquipmentDetailControl.uc : This control should provide functionalities
//                                      needed to select armor, weapons, bullets
//                                      gadgets for an operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================


class R6MenuEquipmentDetailControl extends UWindowDialogClientWindow;

var   R6WindowTextLabel           m_Title;
var   R6WindowTextListBox         m_ListBox;

var   FLOAT                       m_fListBoxLabelHeight, m_fListBoxHeight;

var   R6WindowWrappedTextArea     m_EquipmentText;
var   Color                       m_DescriptionTextColor;  //For description Area
var   Font                        m_DescriptionTextFont;
var   INT                         m_CurrentEquipmentType;  //To notify the gear menu

var   R6MenuEquipmentAnchorButtons m_AnchorButtons;
var   FLOAT                        m_fAnchorAreaHeight;

var   Array<class>  m_APrimaryWeapons;      //class<R6PrimaryWeaponDescription>
var   Array<class>  m_ASecondaryWeapons;    //class<R6SecondaryWeaponDescription>
var   Array<class>  m_AGadgets;             //class<R6GadgetDescription>
var   Array<class>  m_AArmors;              //class<R6ArmorDescription>

var   R6MenuWeaponStats           m_WeaponStats;

var   R6MenuWeaponDetailRadioArea   m_Buttons;
var   BOOL                          m_bDrawListBg;


   
function Created()
{
    local color  labelFontColor, Co;    
    local Texture BorderTexture;
    
    
    m_BorderColor = Root.Colors.GrayLight;
    labelFontColor = Root.Colors.White;

    //List Box Title
    m_Title = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0,0, WinWidth, m_fListBoxLabelHeight, self ));    
	m_Title.Align = TA_Center;
	m_Title.m_Font = Root.Fonts[F_VerySmallTitle]; 
	m_Title.TextColor = labelFontColor;        
    m_Title.m_BGTexture = None;
    m_Title.m_BorderColor = m_BorderColor;

    //Creating List Box
    m_ListBox =  R6WindowTextListBox(CreateControl(class'R6WindowTextListBox', 0, m_fListBoxLabelHeight -1, WinWidth, m_fListBoxHeight, self));
    m_ListBox.ListClass=class'R6WindowListBoxItem';
    m_ListBox.m_VertSB.SetHideWhenDisable(true);    
    m_ListBox.m_font = m_Title.m_Font;   
    m_ListBox.SetCornerType(No_Corners);
    m_ListBox.m_BorderColor = m_BorderColor;    
    m_ListBox.m_fSpaceBetItem = 0;
    m_ListBox.m_VertSB.SetEffect(true);

    m_EquipmentText = R6WindowWrappedTextArea(CreateWindow(class'R6WindowWrappedTextArea', 0,m_ListBox.WinTop + m_ListBox.WinHeight -1, WinWidth, WinHeight - m_Title.WinHeight - m_ListBox.WinHeight +1, self ));
    m_EquipmentText.m_HBorderTexture	= m_Title.m_HBorderTexture;
	m_EquipmentText.m_VBorderTexture	= m_Title.m_VBorderTexture;
	m_EquipmentText.m_HBorderTextureRegion = m_Title.m_HBorderTextureRegion;
	m_EquipmentText.m_VBorderTextureRegion = m_Title.m_VBorderTextureRegion;
	m_EquipmentText.m_fHBorderHeight = m_Title.m_fHBorderHeight ;
	m_EquipmentText.m_fVBorderWidth = m_Title.m_fVBorderWidth ;
	m_EquipmentText.m_BorderColor = m_BorderColor;
    m_EquipmentText.SetScrollable(true);
    m_EquipmentText.m_fXOffset = 5;
    m_EquipmentText.m_fYOffset = 5;
    m_EquipmentText.VertSB.SetEffect(true);
    m_EquipmentText.m_bUseBGTexture = true;
    m_EquipmentText.m_BGTexture = Texture'UWindow.WhiteTexture';
    m_EquipmentText.m_BGRegion.X = 0;
    m_EquipmentText.m_BGRegion.Y = 0; 
	m_EquipmentText.m_BGRegion.W = m_EquipmentText.m_BGTexture.USize;       
    m_EquipmentText.m_BGRegion.H = m_EquipmentText.m_BGTexture.VSize;
    m_EquipmentText.m_bUseBGColor = true;
    m_EquipmentText.m_BGColor = Root.Colors.Black;
    m_EquipmentText.m_BGColor.A = Root.Colors.DarkBGAlpha;

    
    //Default Values for Drescription Box
    m_DescriptionTextColor = Root.Colors.White;
    m_DescriptionTextFont  = Root.Fonts[F_VerySmallTitle]; 
    m_CurrentEquipmentType = -1;

    BuildAvailableEquipment();

    //Build Anchor buttons area
    m_AnchorButtons = R6MenuEquipmentAnchorButtons(CreateControl(class'R6MenuEquipmentAnchorButtons', 0, 0, WinWidth, m_fAnchorAreaHeight, self));
    m_AnchorButtons.m_BorderColor = m_BorderColor;
    m_AnchorButtons.HideWindow();   
    
    m_Buttons = R6MenuWeaponDetailRadioArea(CreateWindow(class'R6MenuWeaponDetailRadioArea', 0, m_ListBox.WinTop + m_ListBox.WinHeight -1, WinWidth, m_fAnchorAreaHeight, self ));
    m_Buttons.m_BorderColor = m_BorderColor;
    m_Buttons.HideWindow();

    m_WeaponStats = R6MenuWeaponStats(CreateWindow(class'R6MenuWeaponStats', 0, m_Buttons.WinTop + m_Buttons.WinHeight -1, WinWidth, WinHeight - m_Buttons.WinTop - m_Buttons.WinHeight +1, self ));
    m_WeaponStats.m_BorderColor = m_BorderColor;
    m_WeaponStats.HideWindow();
}

function R6Operative GetCurrentOperative()
{  
    return R6MenuGearWidget(OwnerWindow).m_currentOperative;
}

function class<R6PrimaryWeaponDescription> GetCurrentPrimaryWeapon()
{
    return R6MenuGearWidget(OwnerWindow).m_OpFirstWeaponDesc;
}

function class<R6SecondaryWeaponDescription> GetCurrentSecondaryWeapon()
{
    return R6MenuGearWidget(OwnerWindow).m_OpSecondaryWeaponDesc;
}

function class<R6WeaponGadgetDescription> GetCurrentWeaponGadget(Bool _Primary)
{
    if(_Primary == true)
        return R6MenuGearWidget(OwnerWindow).m_OpFirstWeaponGadgetDesc;
    else 
        return R6MenuGearWidget(OwnerWindow).m_OpSecondWeaponGadgetDesc;
}

function class<R6BulletDescription> GetCurrentWeaponBullet(Bool _Primary)
{
    if(_Primary == true)
        return R6MenuGearWidget(OwnerWindow).m_OpFirstWeaponBulletDesc;
    else 
        return R6MenuGearWidget(OwnerWindow).m_OpSecondWeaponBulletDesc;
}

function class<R6GadgetDescription> GetCurrentGadget(Bool _Primary)
{
    if(_Primary == true)
        return R6MenuGearWidget(OwnerWindow).m_OpFirstGadgetDesc;
    else 
        return R6MenuGearWidget(OwnerWindow).m_OpSecondGadgetDesc;
}

function class<R6ArmorDescription> GetCurrentArmor()
{
    return R6MenuGearWidget(OwnerWindow).m_OpArmorDesc;
}

function NotifyEquipmentChanged(INT equipmentSelected, class<R6Description> DecriptionClass )
{
    R6MenuGearWidget(OwnerWindow).EquipmentChanged(equipmentSelected, DecriptionClass);
}

function FillListBox(int _equipmentType)
{
    local   class<R6PrimaryWeaponDescription>   PrimaryWeaponClass;
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
    local   class<R6BulletDescription>          WeaponBulletDescriptionClass;
    local   class<R6GadgetDescription>          GadgetClass;
    local   class<R6WeaponGadgetDescription>    WeaponGadgetDescriptionClass;
    local   class<R6ArmorDescription>           ArmorDescriptionClass;
	local   R6ArmorDescription					ArmorForAvailabilityTest;

    local   R6WindowListBoxItem                 NewItem, SelectedItem, FirstInsertedItem;
    local   R6Operative                         currentOperative;
    local   INT                                 i;

	// MPF - Eric
	

    currentOperative = GetCurrentOperative();
    SelectedItem        = None;  

    switch(_equipmentType)
    {
    case 0:        
        /////////////////////////////////////////////////////////////////////////////////
        ///////////        Filling Primary_Weapon List Box      /////////////////////////
        /////////////////////////////////////////////////////////////////////////////////
        m_Title.SetNewText(Localize("GearRoom","PrimaryWeapon","R6Menu"), true);        
        m_listbox.clear();   
        UpdateAnchorButtons(AET_Primary);

        //************************************************************************************************
        //Insert The None Value
        PrimaryWeaponClass = class'R6DescPrimaryWeaponNone';  
        NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
        NewItem.HelpText = Localize(PrimaryWeaponClass.Default.m_NameID,"ID_NAME","R6Weapons");
        NewItem.m_Object = PrimaryWeaponClass;
        if(GetCurrentPrimaryWeapon() == PrimaryWeaponClass)
                SelectedItem = NewItem;
        //************************************************************************************************

        FirstInsertedItem = CreatePrimaryWeaponsSeparators();
        
        //Parsing the available equipment
        for(i=0; i< m_APrimaryWeapons.Length; i++)
        {
            PrimaryWeaponClass = class<R6PrimaryWeaponDescription>(m_APrimaryWeapons[i]);           

             //We Insert weapons after Their respective separator
            if( class<R6SubGunDescription>(PrimaryWeaponClass) != None)
                NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 1);
            else if(class<R6AssaultDescription>(PrimaryWeaponClass) != None)
                NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 2);
            else if(class<R6ShotgunDescription>(PrimaryWeaponClass) != None)
                NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 3);
            else if(class<R6SniperDescription>(PrimaryWeaponClass) != None)
                NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 4);
            else if(class<R6LMGDescription>(PrimaryWeaponClass) != None)
                NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 5);
            else
                NewItem = R6WindowListBoxItem( FirstInsertedItem.InsertBefore( class'R6WindowListBoxItem'));

            NewItem.HelpText = Localize(PrimaryWeaponClass.Default.m_NameID,"ID_NAME","R6Weapons");
            NewItem.m_Object = PrimaryWeaponClass;
            if(GetCurrentPrimaryWeapon() == PrimaryWeaponClass)
                SelectedItem = NewItem;
        }

        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(true);
        /////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////
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
            if(  WeaponGadgetDescriptionClass != class'R6DescWeaponGadgetNone' )
            {                
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
        break;
    case 2:             //Primary_Bullet,
        m_Title.SetNewText(Localize("GearRoom","PrimaryAmmo","R6Menu"), true);

        m_listbox.clear();
        UpdateAnchorButtons(AET_None);

        PrimaryWeaponClass = class<R6PrimaryWeaponDescription>( DynamicLoadObject( currentOperative.m_szPrimaryWeapon, class'Class' ) );

        for(i=0;i < PrimaryWeaponClass.Default.m_Bullets.Length ; i++)
        {
            WeaponBulletDescriptionClass = class<R6BulletDescription>(PrimaryWeaponClass.Default.m_Bullets[i]);
            if(  WeaponBulletDescriptionClass != class'R6DescBulletNone')
            {                
                NewItem = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
                NewItem.HelpText = Localize(WeaponBulletDescriptionClass.Default.m_NameID,"ID_NAME","R6Ammo");
                NewItem.m_Object = WeaponBulletDescriptionClass;
                if(GetCurrentWeaponBullet(true) == WeaponBulletDescriptionClass)
                    SelectedItem = NewItem;
            }
            
        }
        m_listbox.Items.Sort();
        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(false);
        break;
    case 3:             
        //Primary_Gadget,
        m_Title.SetNewText(Localize("GearRoom","PrimaryGadget","R6Menu"), true);

        m_listbox.clear();
        UpdateAnchorButtons(AET_Gadget);

        //************************************************************************************************
        //Insert The None Value
        GadgetClass = class'R6DescGadgetNone';
        NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
        NewItem.HelpText = Localize(GadgetClass.Default.m_NameID,"ID_NAME","R6Gadgets");
        NewItem.m_Object = GadgetClass;  
            
        if(GetCurrentGadget(true) == GadgetClass)
            SelectedItem = NewItem;
        //************************************************************************************************

        FirstInsertedItem                = CreateGadgetsSeparators();

        
        for(i=0; i< m_AGadgets.Length; i++)
        {
            GadgetClass = class<R6GadgetDescription>(m_AGadgets[i]);
			if(!(class'R6MenuMPAdvGearWidget'.static.CheckGadget(string(GadgetClass),self,false)))
			{ // MPF_Milan2, disable gadgets for the current gametype
                if( class<R6GrenadeDescription>(GadgetClass) != None)
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 1);
                else if(class<R6ExplosiveDescription>(GadgetClass) != None)
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 2);
                else if(class<R6HBDeviceDescription>(GadgetClass) != None)
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 3);
                else if(class<R6KitDescription>(GadgetClass) != None)
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 4);
                else 
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 5);

			    NewItem.HelpText = Localize(GadgetClass.Default.m_NameID,"ID_NAME","R6Gadgets");
                NewItem.m_Object = GadgetClass;  
                
                if(GetCurrentGadget(true) == GadgetClass)
                        SelectedItem = NewItem;
			} // MPF_Milan_9_4_2003 moved "}" from above                         
        }

        
        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(false);
        break;

    case 4:                     
        /////////////////////////////////////////////////////////////////////////////////
        //////////////////////Filling Secondary_Weapon List Box   ///////////////////////
        /////////////////////////////////////////////////////////////////////////////////
        m_Title.SetNewText(Localize("GearRoom","SecondaryWeapon","R6Menu"),true);

        m_listbox.clear();
        UpdateAnchorButtons(AET_Secondary);

        FirstInsertedItem = CreateSecondaryWeaponsSeparators();

        for(i=0; i< m_ASecondaryWeapons.Length; i++)
        {
            SecondaryWeaponClass = class<R6SecondaryWeaponDescription>(m_ASecondaryWeapons[i]);            

            //We Insert weapons after Their respective separator
            if( class<R6PistolsDescription>(SecondaryWeaponClass) != None)
                NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 1);
            else if(class<R6MachinePistolsDescription>(SecondaryWeaponClass) != None)
                NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 2);
            else
                NewItem = R6WindowListBoxItem( FirstInsertedItem.InsertBefore( class'R6WindowListBoxItem'));


            if( NewItem != None )
            {
                NewItem.HelpText = Localize(SecondaryWeaponClass.Default.m_NameID,"ID_NAME","R6Weapons");
                NewItem.m_Object = SecondaryWeaponClass;
                if(GetCurrentSecondaryWeapon() == SecondaryWeaponClass)
                    SelectedItem = NewItem;
            }            
        }

        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(true);
        /////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////
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
            if(  WeaponGadgetDescriptionClass != class'R6DescWeaponGadgetNone')
            {                
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
        break;
    case 6:             //Secondary_Bullet,
        m_Title.SetNewText(Localize("GearRoom","SecondaryAmmo","R6Menu"), true);

        m_listbox.clear();       
        UpdateAnchorButtons(AET_None);
        
        SecondaryWeaponClass = class<R6SecondaryWeaponDescription>( DynamicLoadObject( currentOperative.m_szSecondaryWeapon, class'Class' ) );

        for(i=0;i < SecondaryWeaponClass.Default.m_Bullets.Length ; i++)
        {
            WeaponBulletDescriptionClass = class<R6BulletDescription>(SecondaryWeaponClass.Default.m_Bullets[i]);
            if(  WeaponBulletDescriptionClass != class'R6DescBulletNone' )
            {                
                NewItem = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
                NewItem.HelpText = Localize(WeaponBulletDescriptionClass.Default.m_NameID,"ID_NAME","R6Ammo");
                NewItem.m_Object = WeaponBulletDescriptionClass;
                if( GetCurrentWeaponBullet(false) == WeaponBulletDescriptionClass)
                    SelectedItem = NewItem;
            }
            
        }
        m_listbox.Items.Sort();
        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(false);
        break;
    case 7:             //Secondary_Gadget,
        m_Title.SetNewText(Localize("GearRoom","SecondaryGadget","R6Menu"), true);

        m_listbox.clear();
        UpdateAnchorButtons(AET_Gadget);
        //************************************************************************************************
        //Insert The None Value
        GadgetClass = class'R6DescGadgetNone';
        NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
        NewItem.HelpText = Localize(GadgetClass.Default.m_NameID,"ID_NAME","R6Gadgets");
        NewItem.m_Object = GadgetClass;  
            
        if(GetCurrentGadget(false) == GadgetClass)
            SelectedItem = NewItem;
        //************************************************************************************************


        FirstInsertedItem                = CreateGadgetsSeparators();

        
        for(i=0; i< m_AGadgets.Length; i++)
        {
            GadgetClass = class<R6GadgetDescription>(m_AGadgets[i]);
			if(!(class'R6MenuMPAdvGearWidget'.static.CheckGadget(string(GadgetClass),self,false)))
			{ // MPF_Milan2, disable gadgets for the current gametype
                if( class<R6GrenadeDescription>(GadgetClass) != None)
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 1);
                else if(class<R6ExplosiveDescription>(GadgetClass) != None)
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 2);
                else if(class<R6HBDeviceDescription>(GadgetClass) != None)
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 3);
                else if(class<R6KitDescription>(GadgetClass) != None)
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 4);
                else 
                    NewItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', 5);

			    NewItem.HelpText = Localize(GadgetClass.Default.m_NameID,"ID_NAME","R6Gadgets");
                NewItem.m_Object = GadgetClass;  
                if(GetCurrentGadget(false) == GadgetClass)
					SelectedItem = NewItem;
			} // MPF_Milan_9_4_2003 moved "}" from above                         
        }       
        
        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(false);
        break;
        
     case 8:             //Armor
        m_Title.SetNewText(Localize("GearRoom","Armor","R6Menu"), true);

        //Temporary Should take what's in the current mission description
        //Instead of all Armor description

        m_listbox.clear();
        UpdateAnchorButtons(AET_None);
        
        for(i=0; i< m_AArmors.Length; i++)
        {
            ArmorDescriptionClass = class<R6ArmorDescription>(m_AArmors[i]);
			ArmorForAvailabilityTest = new(none)ArmorDescriptionClass; //Have to spawn the class to call the function IsA() 
			if( (ArmorDescriptionClass.default.m_bHideFromMenu == false) &&
				GetCurrentOperative().IsA(ArmorDescriptionClass.default.m_LimitedToClass)
				&& ArmorForAvailabilityTest.IsA(GetCurrentOperative().m_CanUseArmorType)
			  )
			{
				NewItem = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
            NewItem.HelpText = Localize(ArmorDescriptionClass.Default.m_NameID,"ID_NAME","R6Armor");
				NewItem.m_Object = ArmorDescriptionClass;
				if(GetCurrentArmor()== ArmorDescriptionClass)
						SelectedItem = NewItem;
			}            
        }            
        
        //Update type of equipment
        m_CurrentEquipmentType = _equipmentType;
        enableWeaponStats(false);
        break;    
    }

    if(SelectedItem != None)
    {        
        m_ListBox.SetSelectedItem(SelectedItem);
        m_ListBox.MakeSelectedVisible();
    }    
}

//This Hides Or display Anchor buttons for equipment that support it
function UpdateAnchorButtons(R6MenuEquipmentAnchorButtons.eAnchorEquipmentType _AEType)
{    

    if(_AEType == AET_None )    
    {
        m_AnchorButtons.HideWindow();
        m_Title.WinTop   = 0;
        m_ListBox.WinTop = m_Title.WinTop + m_Title.WinHeight -1;
        m_ListBox.SetSize(m_ListBox.WinWidth, m_fListBoxHeight);
    }
    else
    {
        m_AnchorButtons.ShowWindow();
        m_AnchorButtons.DisplayButtons(_AEType);
        m_Title.WinTop = m_AnchorButtons.WinTop + m_AnchorButtons.WinHeight -1;
        m_ListBox.WinTop = m_Title.WinTop + m_Title.WinHeight -1;
        m_ListBox.SetSize(m_ListBox.WinWidth, m_fListBoxHeight - m_AnchorButtons.WinHeight +1);
    }

}


function BuildAvailableEquipment()
{
    local   class<R6PrimaryWeaponDescription>   PrimaryWeaponClass;
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
    local   class<R6GadgetDescription>          GadgetClass;   
    
    local   INT                                 i;
	
	// MPF - Eric
	local	R6Mod								pCurrentMod;
	local	INT									j;

    
    
    //This functions creates array of available weapons from wich we can populate
    //list boxes

    m_APrimaryWeapons.remove(0, m_APrimaryWeapons.Length);
    m_ASecondaryWeapons.remove(0, m_ASecondaryWeapons.Length);
    m_AGadgets.remove(0, m_AGadgets.Length);    
    
    
    /////////////////////////////////////////////////////////////////////////////////
    ///////////        Filling Primary_Weapons       /////////////////////////
    /////////////////////////////////////////////////////////////////////////////////      
    
       
    i=0;
    //Insert All Primary Descriptions except None
	// MPF - Eric
    pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod; 
	for (j = 0; j < pCurrentMod.m_aDescriptionPackage.Length; j++)
	{
		PrimaryWeaponClass = class<R6PrimaryWeaponDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[j]$".u", class'R6PrimaryWeaponDescription'));
		
		while((PrimaryWeaponClass != None))
		{
			if((PrimaryWeaponClass.Default.m_NameID != "NONE"))
			{                
				m_APrimaryWeapons[i]=PrimaryWeaponClass;
				i++;
			}
			PrimaryWeaponClass = class<R6PrimaryWeaponDescription>(GetNextClass());
			
		}  
		FreePackageObjects();     
	}

    SortDescriptions( true, m_APrimaryWeapons, "R6Weapons" );    
    
    /////////////////////////////////////////////////////////////////////////////////
    //Filling Gadgets
    /////////////////////////////////////////////////////////////////////////////////   
    
    i=0;
    //Insert All Primary Descriptions except None
	// MPF - Eric
	for (j = 0; j < pCurrentMod.m_aDescriptionPackage.Length; j++)
	{
		GadgetClass = class<R6GadgetDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[j]$".u", class'R6GadgetDescription'));
		
		while((GadgetClass != None))
		{
			if((GadgetClass.Default.m_NameID != "NONE"))
			{                
				m_AGadgets[i]=GadgetClass;
				i++;
			}
			GadgetClass = class<R6GadgetDescription>(GetNextClass());
			
		}  
		FreePackageObjects();
	}
     SortDescriptions( true, m_AGadgets, "R6Gadgets" );
     
    /////////////////////////////////////////////////////////////////////////////////
    //////////////////////Filling Secondary_Weapon ///////////////////////
    /////////////////////////////////////////////////////////////////////////////////
    
    i=0;
    //Insert All Secondary_Weapon Descriptions except None
	// MPF - Eric
	for (j = 0; j < pCurrentMod.m_aDescriptionPackage.Length; j++)
	{
		SecondaryWeaponClass = class<R6SecondaryWeaponDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[j]$".u", class'R6SecondaryWeaponDescription'));
		
		while((SecondaryWeaponClass != None))
		{
			if((SecondaryWeaponClass.Default.m_NameID != "NONE"))
			{                
				m_ASecondaryWeapons[i]=SecondaryWeaponClass;
				i++;
			}
			SecondaryWeaponClass = class<R6SecondaryWeaponDescription>(GetNextClass());
			
		}  
		FreePackageObjects();  
	}
    
    SortDescriptions( true, m_ASecondaryWeapons, "R6Weapons" );
    
    
}

function R6WindowListBoxItem CreatePrimaryWeaponsSeparators()
{

    local   R6WindowListBoxItem                 NewItem, FirstInsertedItem;
	// MPF - Eric


    //************************************************************************************************
    //                                      Filling List Separators
    //************************************************************************************************        
    FirstInsertedItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    FirstInsertedItem.HelpText       = Caps(Localize("SUBGUN","ID_NAME","R6Weapons"));
    FirstInsertedItem.m_IsSeparator  = true;
    FirstInsertedItem.m_iSeparatorID =1;
    m_AnchorButtons.m_SUBGUNButton.AnchoredElement  = FirstInsertedItem;

    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("ASSAULT","ID_NAME","R6Weapons"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID = 2;
    m_AnchorButtons.m_ASSAULTButton.AnchoredElement  = NewItem;

    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("SHOTGUN","ID_NAME","R6Weapons"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID = 3;
    m_AnchorButtons.m_SHOTGUNButton.AnchoredElement  = NewItem;

    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("SNIPER","ID_NAME","R6Weapons"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID = 4;
    m_AnchorButtons.m_SNIPERButton.AnchoredElement  = NewItem;
    
    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("LMG","ID_NAME","R6Weapons"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID = 5;
    m_AnchorButtons.m_LMGButton.AnchoredElement  = NewItem;

    //*************************************************************************************************

    return FirstInsertedItem;
}

function R6WindowListBoxItem CreateSecondaryWeaponsSeparators()
{

    local   R6WindowListBoxItem                 NewItem, FirstInsertedItem;
	// MPF - Eric


    //************************************************************************************************
    //                                      Filling List Separators
    //************************************************************************************************

    FirstInsertedItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    FirstInsertedItem.HelpText       = Caps(Localize("PISTOLS","ID_NAME","R6Weapons"));
    FirstInsertedItem.m_IsSeparator  = true;
    FirstInsertedItem.m_iSeparatorID = 1;        
    m_AnchorButtons.m_PISTOLSButton.AnchoredElement = FirstInsertedItem;        

    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("MACHINEPISTOLS","ID_NAME","R6Weapons"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID = 2;
    m_AnchorButtons.m_MACHINEPISTOLSButton.AnchoredElement = NewItem;        
    //*************************************************************************************************

    return FirstInsertedItem;
}

function R6WindowListBoxItem CreateGadgetsSeparators()
{

    local   R6WindowListBoxItem                 NewItem, FirstInsertedItem;
	// MPF - Eric


    //************************************************************************************************
    //                                      Filling List Separators
    //************************************************************************************************

    FirstInsertedItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    FirstInsertedItem.HelpText       = Caps(Localize("CATEGORIES","GRENADES","R6Gadgets"));
    FirstInsertedItem.m_IsSeparator  = true;
    FirstInsertedItem.m_iSeparatorID = 1;        
    m_AnchorButtons.m_GRENADESButton.AnchoredElement = FirstInsertedItem;

    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("CATEGORIES","EXPLOSIVES","R6Gadgets"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID = 2;
    m_AnchorButtons.m_EXPLOSIVESButton.AnchoredElement = NewItem;        

    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("CATEGORIES","HBDEVICE","R6Gadgets"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID = 3;
    m_AnchorButtons.m_HBDEVICEButton.AnchoredElement = NewItem;        

    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("CATEGORIES","KITS","R6Gadgets"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID = 4;
    m_AnchorButtons.m_KITSButton.AnchoredElement = NewItem;        

    NewItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    NewItem.HelpText       = Caps(Localize("CATEGORIES","GENERAL","R6Gadgets"));
    NewItem.m_IsSeparator  = true;
    NewItem.m_iSeparatorID =5;
    m_AnchorButtons.m_GENERALButton.AnchoredElement = NewItem;

    //*************************************************************************************************
        
    return FirstInsertedItem;
}

function BuildAvailableMissionArmors()
{
    local Class<R6ArmorDescription> ArmorDescriptionClass;
    local int i, nbArmor;
    local R6MissionDescription CurrentMission;
    local R6ModMgr pModManager;

    pModManager = class'Actor'.static.GetModMgr();
    m_AArmors.Remove(0, m_AArmors.Length);
    CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
    if(CurrentMission == none)
    {
        return;
    }
    nbArmor = 0;

    for(i = 0; i < CurrentMission.m_MissionArmorTypes.Length; i++)
    {
        ArmorDescriptionClass = Class<R6ArmorDescription>(CurrentMission.m_MissionArmorTypes[i]);
        if(ArmorDescriptionClass.default.m_NameID != "NONE")
        {
            m_AArmors[nbArmor] = ArmorDescriptionClass;
            nbArmor++;
        }
    }
    if(!pModManager.IsRavenShield())
    {

        for(i = 0; i < pModManager.m_pCurrentMod.m_aDescriptionPackage.Length; i++)
        {
            if(pModManager.m_pCurrentMod.m_aDescriptionPackage[i] != "R6Description")
            {

                for(ArmorDescriptionClass = Class<R6ArmorDescription>(GetFirstPackageClass(pModManager.m_pCurrentMod.m_aDescriptionPackage[i] $ ".u", Class'R6Description.R6ArmorDescription')); (ArmorDescriptionClass != none) && ArmorDescriptionClass.default.m_bHideFromMenu == false; ArmorDescriptionClass = Class<R6ArmorDescription>(GetNextClass()))
                {
                    if(ArmorDescriptionClass.default.m_NameID != "NONE")
                    {
                        m_AArmors[nbArmor] = ArmorDescriptionClass;
                        nbArmor++;
                    }
                }
            }
        }
    }
    if(pModManager.m_pCurrentMod.m_bUseCustomOperatives == true)
    {

        for(i = 0; i < pModManager.GetPackageMgr().GetNbPackage(); i++)
        {

            for(ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, Class'R6Description.R6ArmorDescription')); (ArmorDescriptionClass != none) && ArmorDescriptionClass.default.m_bHideFromMenu == false; ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetNextClassFromPackage()))
            {
                m_AArmors[nbArmor] = ArmorDescriptionClass;
                nbArmor++;
            }
        }
    }
    SortDescriptions(true, m_AArmors, "R6Armor", true);
}

function class<R6ArmorDescription> GetDefaultArmor()
{
    if(m_AArmors.Length > 0)
        return class<R6ArmorDescription>(m_AArmors[0]);    
    else 
        return none; //Should not Happen
}

function bool IsAmorAvailable(class<R6ArmorDescription> lookedUpArmor, R6Operative CurrentOperative)
{
    local INT i;
    local bool bArmorIsAvailble;

    bArmorIsAvailble = false;
    i = 0;

	if(!CurrentOperative.IsA(lookedUpArmor.default.m_LimitedToClass))
		return false;

	while( (bArmorIsAvailble == false) && (i < m_AArmors.Length )  )
    {
        if(lookedUpArmor == class<R6ArmorDescription>(m_AArmors[i]))    
            bArmorIsAvailble = true;
        i++;
    }

    return bArmorIsAvailble;
}


function Notify(UWindowDialogControl C, byte E)
{
    local   class<R6PrimaryWeaponDescription>   PrimaryWeaponClass;
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
    local   class<R6WeaponGadgetDescription>    WeaponGadgetDescriptionClass;
    local   class<R6BulletDescription>          WeaponBulletDescriptionClass;
    local   class<R6ArmorDescription>           ArmorDescriptionClass;
    local   class<R6GadgetDescription>          GadgetDescriptionClass;

    local   R6WindowListBoxItem SelectedItem;
    local   string              NewString;
    local	int itemPos, i;

	// MPF - Eric

	if(E == DE_Click)
	{
		switch(C)
		{		
        case m_ListBox:
            //Fill description Area and Notify The Gear Menu that a selection has been made
            switch(m_CurrentEquipmentType)
            {
            case 0 :
                //Primary weapons
                SelectedItem = R6WindowListBoxItem(m_listbox.m_SelectedItem);
                PrimaryWeaponClass = class<R6PrimaryWeaponDescription>(SelectedItem.m_Object);
                NewString    = Localize(PrimaryWeaponClass.Default.m_NameID,"ID_Description","R6Weapons", false, true);
                NotifyEquipmentChanged(m_CurrentEquipmentType, PrimaryWeaponClass);

				// set initial values of the weapon
                m_WeaponStats.m_fInitRangePercent   = PrimaryWeaponClass.Default.m_ARangePercent[0];
                m_WeaponStats.m_fInitDamagePercent  = PrimaryWeaponClass.Default.m_ADamagePercent[0];
                m_WeaponStats.m_fInitAccuracyPercent= PrimaryWeaponClass.Default.m_AAccuracyPercent[0];
                m_WeaponStats.m_fInitRecoilPercent  = PrimaryWeaponClass.Default.m_ARecoilPercent[0];
                m_WeaponStats.m_fInitRecoveryPercent= PrimaryWeaponClass.Default.m_ARecoveryPercent[0];

				// set current value of the weapon -- equal to init if you not have weapon gadget 
				m_WeaponStats.m_fRangePercent   = m_WeaponStats.m_fInitRangePercent;
				m_WeaponStats.m_fDamagePercent  = m_WeaponStats.m_fInitDamagePercent;
				m_WeaponStats.m_fAccuracyPercent= m_WeaponStats.m_fInitAccuracyPercent;
				m_WeaponStats.m_fRecoilPercent  = m_WeaponStats.m_fInitRecoilPercent;
				m_WeaponStats.m_fRecoveryPercent= m_WeaponStats.m_fInitRecoveryPercent;

				// get the primary weapon gadget class to see the influence on primary weapon stats
				WeaponGadgetDescriptionClass = GetCurrentWeaponGadget(true);
			    if(  WeaponGadgetDescriptionClass != class'R6DescWeaponGadgetNone')
	            {
					for (i =0; i < PrimaryWeaponClass.Default.m_WeaponTags.Length; i++)
					{
						if (PrimaryWeaponClass.Default.m_WeaponTags[i] == WeaponGadgetDescriptionClass.Default.m_NameTag)
						{
							m_WeaponStats.m_fRangePercent   = PrimaryWeaponClass.Default.m_ARangePercent[i];
							m_WeaponStats.m_fDamagePercent  = PrimaryWeaponClass.Default.m_ADamagePercent[i];
							m_WeaponStats.m_fAccuracyPercent= PrimaryWeaponClass.Default.m_AAccuracyPercent[i];
							m_WeaponStats.m_fRecoilPercent  = PrimaryWeaponClass.Default.m_ARecoilPercent[i];
							m_WeaponStats.m_fRecoveryPercent= PrimaryWeaponClass.Default.m_ARecoveryPercent[i];
							break;
						}
					}
				}

                m_WeaponStats.ResizeCharts();
                break;
            case 1 :    //Primary Weapon Gadgets
            case 5 :    //Secondary_WeaponGadget                
                SelectedItem = R6WindowListBoxItem(m_listbox.m_SelectedItem);
                WeaponGadgetDescriptionClass = class<R6WeaponGadgetDescription>(SelectedItem.m_Object);
                NewString    = Localize(WeaponGadgetDescriptionClass.Default.m_NameID,"ID_Description","R6WeaponGadgets", false, true);
                NotifyEquipmentChanged(m_CurrentEquipmentType, WeaponGadgetDescriptionClass);
                break;

            case 2 : //Primary_Bullet
            case 6 : //Secondary_Bullet    
                SelectedItem = R6WindowListBoxItem(m_listbox.m_SelectedItem);
                WeaponBulletDescriptionClass = class<R6BulletDescription>(SelectedItem.m_Object);
                NewString    = Localize(WeaponBulletDescriptionClass.Default.m_NameID,"ID_Description","R6Ammo", false, true);
                NotifyEquipmentChanged(m_CurrentEquipmentType, WeaponBulletDescriptionClass);                
                break;

            case 3 : //Primary_Gadget
            case 7 : //Secondary_Gadget
                SelectedItem = R6WindowListBoxItem(m_listbox.m_SelectedItem);
                GadgetDescriptionClass = class<R6GadgetDescription>(SelectedItem.m_Object);
                NewString    = Localize(GadgetDescriptionClass.Default.m_NameID,"ID_Description","R6Gadgets", false, true);
                NotifyEquipmentChanged(m_CurrentEquipmentType, GadgetDescriptionClass);
                break;

            case 4 :
                //Secondary_Weapon
                SelectedItem = R6WindowListBoxItem(m_listbox.m_SelectedItem);
                SecondaryWeaponClass = class<R6SecondaryWeaponDescription>(SelectedItem.m_Object);
                NewString    = Localize(SecondaryWeaponClass.Default.m_NameID,"ID_Description","R6Weapons", false, true);
                NotifyEquipmentChanged(m_CurrentEquipmentType, SecondaryWeaponClass);               

				// set initial values of the weapon
                m_WeaponStats.m_fInitRangePercent   = SecondaryWeaponClass.Default.m_ARangePercent[0];
                m_WeaponStats.m_fInitDamagePercent  = SecondaryWeaponClass.Default.m_ADamagePercent[0];
                m_WeaponStats.m_fInitAccuracyPercent= SecondaryWeaponClass.Default.m_AAccuracyPercent[0];
                m_WeaponStats.m_fInitRecoilPercent  = SecondaryWeaponClass.Default.m_ARecoilPercent[0];
                m_WeaponStats.m_fInitRecoveryPercent= SecondaryWeaponClass.Default.m_ARecoveryPercent[0];

				// set current value of the weapon -- equal to init if you not have weapon gadget
				m_WeaponStats.m_fRangePercent   = m_WeaponStats.m_fInitRangePercent;
				m_WeaponStats.m_fDamagePercent  = m_WeaponStats.m_fInitDamagePercent;
				m_WeaponStats.m_fAccuracyPercent= m_WeaponStats.m_fInitAccuracyPercent;
				m_WeaponStats.m_fRecoilPercent  = m_WeaponStats.m_fInitRecoilPercent;
				m_WeaponStats.m_fRecoveryPercent= m_WeaponStats.m_fInitRecoveryPercent;

				// get the secondary weapon gadget class to see the influence on primary weapon stats
				WeaponGadgetDescriptionClass = GetCurrentWeaponGadget(false);;
			    if(  WeaponGadgetDescriptionClass != class'R6DescWeaponGadgetNone')
	            {
					for (i =0; i < SecondaryWeaponClass.Default.m_WeaponTags.Length; i++)
					{
						if (SecondaryWeaponClass.Default.m_WeaponTags[i] == WeaponGadgetDescriptionClass.Default.m_NameTag)
						{
							m_WeaponStats.m_fRangePercent   = SecondaryWeaponClass.Default.m_ARangePercent[i];
							m_WeaponStats.m_fDamagePercent  = SecondaryWeaponClass.Default.m_ADamagePercent[i];
							m_WeaponStats.m_fAccuracyPercent= SecondaryWeaponClass.Default.m_AAccuracyPercent[i];
							m_WeaponStats.m_fRecoilPercent  = SecondaryWeaponClass.Default.m_ARecoilPercent[i];
							m_WeaponStats.m_fRecoveryPercent= SecondaryWeaponClass.Default.m_ARecoveryPercent[i];
							break;
						}
					}
				}

                m_WeaponStats.ResizeCharts();
                break;                              
               
            case 8 :
                 //Armor
                SelectedItem = R6WindowListBoxItem(m_listbox.m_SelectedItem);
                ArmorDescriptionClass = class<R6ArmorDescription>(SelectedItem.m_Object);
                NewString    = Localize(ArmorDescriptionClass.Default.m_NameID,"ID_Description","R6Armor", false, true);
                NotifyEquipmentChanged(m_CurrentEquipmentType, ArmorDescriptionClass);  
                break;
            }           
            break;
        
        case m_AnchorButtons.m_ASSAULTButton:
        case m_AnchorButtons.m_LMGButton:
        case m_AnchorButtons.m_SHOTGUNButton:
        case m_AnchorButtons.m_SNIPERButton:
        case m_AnchorButtons.m_SUBGUNButton:
        case m_AnchorButtons.m_PISTOLSButton:
        case m_AnchorButtons.m_MACHINEPISTOLSButton:
        case m_AnchorButtons.m_GRENADESButton:
        case m_AnchorButtons.m_EXPLOSIVESButton:
        case m_AnchorButtons.m_HBDEVICEButton:
        case m_AnchorButtons.m_KITSButton:
        case m_AnchorButtons.m_GENERALButton:
            itemPos =  R6WindowListBoxItem(m_ListBox.Items).FindItemIndex(R6WindowListBoxAnchorButton(C).AnchoredElement);
            if(itemPos >= 0)
            {
                m_ListBox.m_VertSB.Pos = 0;         
                
                //Position the scroll bar on the element desired
                m_ListBox.m_VertSB.Scroll(itemPos);

                //Select The first Operative after
                //m_ListBox.SetSelectedItem(UWindowListBoxItem(R6WindowListBoxItem(m_ListBox.Items).FindEntry(itemPos+1)));   

            }
            
            break;
		}

	}

    if( (m_EquipmentText != none ) && (NewString != ""))
    {
        m_EquipmentText.Clear( true, true);
        m_EquipmentText.AddText(NewString, m_DescriptionTextColor, m_DescriptionTextFont);
    }
}

function enableWeaponStats(bool _enable)
{
    //When disable we are not displaying a weapon information
    //When enable we pop up the buttons and the 2 weapon information page
    if(_enable)
    {        
        m_Buttons.ShowWindow();
        m_EquipmentText.Wintop      = m_WeaponStats.WinTop;
        m_EquipmentText.WinHeight   = m_WeaponStats.WinHeight;
        m_EquipmentText.Resize();   
        ChangePage(1);
    }   
    else
    {
        m_WeaponStats.HideWindow();
        m_EquipmentText.Wintop      = m_ListBox.WinTop + m_ListBox.WinHeight -1;
        m_EquipmentText.WinHeight   = WinHeight - m_EquipmentText.Wintop;
        m_EquipmentText.Resize();
        m_EquipmentText.ShowWindow();
        m_Buttons.HideWindow();
    }
        

}

function ChangePage(int _Page)
{
    //Cycle between weapon stats and description
    switch(_Page)
    {
    case 0:
        m_WeaponStats.HideWindow();
        m_EquipmentText.ShowWindow();
        break;
    case 1:
        m_WeaponStats.ShowWindow();
        m_EquipmentText.HideWindow();
        break;
    default:
        m_WeaponStats.HideWindow();
        m_EquipmentText.ShowWindow();
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    if(m_bDrawListBg)
    {  
        R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, m_ListBox.WinLeft, m_ListBox.Wintop, m_ListBox.WinWidth, m_ListBox.WinHeight);        
    }
}

//=============================================================================
// Simple bubble sort to list servers in alphabetical order of name 
//=============================================================================
static function SortDescriptions( BOOL _bAscending, OUT Array<class> Descriptions, string LocalizationFile, OPTIONAL BOOL bUseTags)
{
    local INT i;
    local INT j;
    local Class      Temp;
    local BOOL       bSwap;

    for ( i = 0; i < Descriptions.length - 1; i++)
    {
        for ( j = 0; j < Descriptions.length - 1 - i; j++ )
        {
            if(bUseTags)
            {
               if ( _bAscending )            
                    bSwap =  Caps(class<R6Description>(Descriptions[j]).Default.m_NameTag) > Caps(class<R6Description>(Descriptions[j+1]).Default.m_NameTag);                           
               else
                    bSwap =  Caps(class<R6Description>(Descriptions[j]).Default.m_NameTag) < Caps(class<R6Description>(Descriptions[j+1]).Default.m_NameTag);                           
            }
            else
            {
                if ( _bAscending )        
                    bSwap =  Caps(Localize(class<R6Description>(Descriptions[j]).Default.m_NameID,"ID_NAME",LocalizationFile)) > Caps(Localize(class<R6Description>(Descriptions[j+1]).Default.m_NameID,"ID_NAME",LocalizationFile));                           
                else
                    bSwap =  Caps(Localize(class<R6Description>(Descriptions[j]).Default.m_NameID,"ID_NAME",LocalizationFile)) < Caps(Localize(class<R6Description>(Descriptions[j+1]).Default.m_NameID,"ID_NAME",LocalizationFile));
            }
            

            if ( bSwap )
            {
                Temp                = Descriptions[j];
                Descriptions[j]     = Descriptions[j + 1];
                Descriptions[j + 1] = Temp;
            }
        }
    }    
}

//=================================================================================
// ShowWindow: This is call when an equipement was selected, force the keyfocus on the list box
//=================================================================================
function ShowWindow()
{
	m_ListBox.SetAcceptsFocus();

	Super.ShowWindow();
}

defaultproperties
{
     m_bDrawListBg=True
     m_fListBoxLabelHeight=17.000000
     m_fListBoxHeight=136.000000
     m_fAnchorAreaHeight=23.000000
}
