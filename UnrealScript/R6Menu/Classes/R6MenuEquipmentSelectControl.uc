//=============================================================================
//  R6MenuEquipmentSelectControl.uc : This control should provide functionalities
//                                      needed to show 2d representations of equipment
//                                      
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================


class R6MenuEquipmentSelectControl extends UWindowDialogClientWindow;

var R6MenuGearPrimaryWeapon     m_2DWeaponPrimary;
var R6MenuGearSecondaryWeapon   m_2DWeaponSecondary;
var R6MenuGearGadget            m_2DGadgetPrimary;
var R6MenuGearGadget            m_2DGadgetSecondary;
var R6MenuGearArmor             m_2DArmor;

var R6MenuAssignAllButton       m_AssignAllToAllButton; //Assign All equimnent to all assigned operatives
var Texture                     m_TAssignAllToAllButton;
var Region                      m_RAssignAllToAllUp, m_RAssignAllToAllOver, m_RAssignAllToAllDown, m_RAssignAllToAllDisable;

//Display variables
var FLOAT                       m_fArmorWindowWidth;
var FLOAT                       m_fPrimaryWindowHeight;
var FLOAT                       m_fSecondaryWindowHeight;
var FLOAT                       m_fPrimaryGadgetWindowHeight;


var R6WindowButtonGear			m_HighlightedButton;

var Color                       m_DisableColor;
var Color						m_EnableColor;

var BOOL                        m_bDisableControls;

//Debug
var BOOL                        bShowLog;


function Created()
{
	m_DisableColor = Root.Colors.GrayLight;
	m_EnableColor  = Root.Colors.White;

	m_2DWeaponPrimary   = R6MenuGearPrimaryWeapon(CreateControl(class'R6MenuGearPrimaryWeapon',       
                                                                                    0,  
                                                                                    0,  
                                                                                    WinWidth,   
                                                                                    m_fPrimaryWindowHeight, 
                                                                                    self));
    
    m_2DWeaponSecondary = R6MenuGearSecondaryWeapon(CreateControl(class'R6MenuGearSecondaryWeapon', 
                                                                                    m_fArmorWindowWidth-1,  
                                                                                    m_fPrimaryWindowHeight-1 ,  
                                                                                    WinWidth - m_fArmorWindowWidth+1, 
                                                                                    m_fSecondaryWindowHeight, 
                                                                                    self));

    
    m_2DGadgetPrimary   = R6MenuGearGadget(CreateControl(class'R6MenuGearGadget',      
                                                                                    m_fArmorWindowWidth-1, 
                                                                                    m_2DWeaponSecondary.WinTop + m_2DWeaponSecondary.WinHeight -1,
                                                                                    m_2DWeaponSecondary.WinWidth, 
                                                                                    m_fPrimaryGadgetWindowHeight, 
                                                                                    self));
    
    m_2DGadgetSecondary = R6MenuGearGadget(CreateControl(class'R6MenuGearGadget',                   
                                                                                    m_fArmorWindowWidth-1,
                                                                                    m_2DGadgetPrimary.WinTop + m_2DGadgetPrimary.WinHeight -1,
                                                                                    m_2DWeaponSecondary.WinWidth,         
                                                                                    m_fPrimaryGadgetWindowHeight,//WinHeight - m_2DGadgetPrimary.WinTop - m_2DGadgetPrimary.WinHeight, 
                                                                                    self));
    
    m_2DArmor           = R6MenuGearArmor(CreateControl(class'R6MenuGearArmor',     
                                                                                    0,  
                                                                                    m_2DWeaponPrimary.WinHeight -1, 
                                                                                    m_fArmorWindowWidth,        
                                                                                    247, //WinHeight - m_2DWeaponPrimary.WinHeight, 
                                                                                    self));

	m_AssignAllToAllButton = R6MenuAssignAllButton(CreateControl(class'R6MenuAssignAllButton', 0, WinHeight - 12, WinWidth, 12, self));
    m_AssignAllToAllButton.bAlwaysOnTop			= True;
    m_AssignAllToAllButton.ToolTipString		= Localize("GearRoom","AssignAllToAll","R6Menu");
    m_AssignAllToAllButton.m_iDrawStyle			= ERenderStyle.STY_Alpha;	
	m_AssignAllToAllButton.SetCompleteAssignAllButton();
	
}


function DisableControls(BOOL _Disable)
{
        //Lock All Controls
        m_AssignAllToAllButton.SetButtonStatus( _Disable);
		m_2DWeaponPrimary.SetButtonsStatus( _Disable);
		m_2DWeaponSecondary.SetButtonsStatus( _Disable);
		m_2DGadgetPrimary.SetButtonsStatus( _Disable);
		m_2DGadgetSecondary.SetButtonsStatus( _Disable);
		m_2DArmor.SetButtonsStatus( _Disable);

        m_bDisableControls = _Disable;

        //Drop current selection
        if( (_Disable == true) && (m_HighlightedButton != None) )
        {        
            m_HighlightedButton.m_HighLight = false;
            m_HighlightedButton.OwnerWindow.SetBorderColor(m_DisableColor);                      
            m_HighlightedButton = None;
        }
        
}



function setHighLight( R6WindowButtonGear newButton)
{
    if(m_HighlightedButton != None)
    {
        m_HighlightedButton.m_HighLight = false;
        m_HighlightedButton.OwnerWindow.SetBorderColor(m_DisableColor);
    }        
    
    if(newButton != None)
    {        
        m_HighlightedButton=newButton;
        m_HighlightedButton.m_HighLight = true;
        m_HighlightedButton.OwnerWindow.SetBorderColor(m_EnableColor);
        m_HighlightedButton.OwnerWindow.BringToFront();
    }

}

function Notify(UWindowDialogControl C, byte E)
{    
	
	if (m_bDisableControls)         
        return;
	

	if (E == DE_MouseEnter)
	{
		switch(C.OwnerWindow)
		{
			case self:
				if (C == m_AssignAllToAllButton)
                {					
    				m_2DWeaponPrimary.ForceMouseOver( true);
	    			m_2DWeaponSecondary.ForceMouseOver( true);
		    		m_2DGadgetPrimary.ForceMouseOver( true);
    		    	m_2DGadgetSecondary.ForceMouseOver( true);
			        m_2DArmor.ForceMouseOver( true);
                }

				break;
			case m_2DWeaponPrimary:				
				m_2DWeaponPrimary.ForceMouseOver( (C == m_2DWeaponPrimary.m_AssignAll));
				break;
			case m_2DWeaponSecondary:
				m_2DWeaponSecondary.ForceMouseOver( (C == m_2DWeaponSecondary.m_AssignAll));
				break;
			case m_2DGadgetPrimary:
				m_2DGadgetPrimary.ForceMouseOver( (C == m_2DGadgetPrimary.m_AssignAll));
				break;
			case m_2DGadgetSecondary:				
				m_2DGadgetSecondary.ForceMouseOver( (C == m_2DGadgetSecondary.m_AssignAll));
				break;
			case m_2DArmor:
				m_2DArmor.ForceMouseOver( (C == m_2DArmor.m_AssignAll));
				break;
		}
	}
	else if (E == DE_MouseLeave)
	{			
		m_2DWeaponPrimary.ForceMouseOver( false);
		m_2DWeaponSecondary.ForceMouseOver( false);
		m_2DGadgetPrimary.ForceMouseOver( false);
		m_2DGadgetSecondary.ForceMouseOver( false);
		m_2DArmor.ForceMouseOver( false);
	}
	else if (E == DE_Click)
	{
#ifdefDEBUG
		if (bShowLog)
		{
			switch(C)
			{	
				//First Weapon Equipment Click
				case m_2DWeaponPrimary.m_AssignAll: log("m_2DWeaponPrimary.m_AssignAll"); break;
				case m_2DWeaponPrimary.m_2DWeapon:  log("m_2DWeaponPrimary.m_2DWeapon"); break;
				case m_2DWeaponPrimary.m_2DBullet:	log("m_2DWeaponPrimary.m_2DBullet"); break;
				case m_2DWeaponPrimary.m_2DWeaponGadget: log("m_2DWeaponPrimary.m_2DWeaponGadget"); break;
				//Secondary Weapon Equipment Click
				case m_2DWeaponSecondary.m_AssignAll: log("m_2DWeaponSecondary.m_AssignAll"); break;
				case m_2DWeaponSecondary.m_2DWeapon: log("m_2DWeaponSecondary.m_2DWeapon"); break;
				case m_2DWeaponSecondary.m_2DBullet: log("m_2DWeaponSecondary.m_2DBullet"); break;
				case m_2DWeaponSecondary.m_2DWeaponGadget: log("m_2DWeaponSecondary.m_2DWeaponGadget"); break;
				//Primary Gadget control pressed
				case m_2DGadgetPrimary.m_AssignAll: log("m_2DGadgetPrimary.m_AssignAll"); break;  
				case m_2DGadgetPrimary.m_2DGadget: log("m_2DGadgetPrimary.m_2DGadget"); break;       
				//Secondary Gadget control pressed
				case m_2DGadgetSecondary.m_AssignAll: log("m_2DGadgetSecondary.m_AssignAll"); break;
				case m_2DGadgetSecondary.m_2DGadget: log("m_2DGadgetSecondary.m_2DGadget"); break;
				//Armor control pressed
				case m_2DArmor.m_AssignAll:	log("m_2DArmor.m_AssignAll"); break;
				case m_2DArmor.m_2DArmor: log("m_2DArmor.m_2DArmor"); break;
				default: log("button"@C@"is not assign in R6MenuEquipmentSelectControl"); break;
			}
		}
#endif

		switch(C)
		{	
			// assign to all team members
			case m_AssignAllToAllButton:
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(All_ToAll);
				break;

			//First Weapon Equipment Click
			case m_2DWeaponPrimary.m_AssignAll:							
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(All_Primary);
				break;
			case m_2DWeaponPrimary.m_2DWeapon:							
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Primary_Weapon);
				setHighLight(m_2DWeaponPrimary.m_2DWeapon);
				break;
			case m_2DWeaponPrimary.m_2DBullet:							
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Primary_Bullet);
				setHighLight(m_2DWeaponPrimary.m_2DBullet);
				break;
			case m_2DWeaponPrimary.m_2DWeaponGadget:							
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Primary_WeaponGadget);
				setHighLight(m_2DWeaponPrimary.m_2DWeaponGadget);
				break;

			//Secondary Weapon Equipment Click
			case m_2DWeaponSecondary.m_AssignAll:	
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(All_Secondary);
				break;
			case m_2DWeaponSecondary.m_2DWeapon:							
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Secondary_Weapon);
				setHighLight(m_2DWeaponSecondary.m_2DWeapon);
				break;
			case m_2DWeaponSecondary.m_2DBullet:							
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Secondary_Bullet);
				setHighLight(m_2DWeaponSecondary.m_2DBullet);
				break;
			case m_2DWeaponSecondary.m_2DWeaponGadget:							
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Secondary_WeaponGadget);
				setHighLight(m_2DWeaponSecondary.m_2DWeaponGadget);
				break;
        
			//Primary Gadget control pressed
			case m_2DGadgetPrimary.m_AssignAll:		
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(All_PrimaryGadget);
				break;  
			case m_2DGadgetPrimary.m_2DGadget:		
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Primary_Gadget);
				setHighLight(m_2DGadgetPrimary.m_2DGadget);
				break;       

			//Secondary Gadget control pressed
			case m_2DGadgetSecondary.m_AssignAll:	
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(All_SecondaryGadget);
				break;
			case m_2DGadgetSecondary.m_2DGadget:		
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Secondary_Gadget);
				setHighLight(m_2DGadgetSecondary.m_2DGadget);
				break;

			//Armor control pressed
			case m_2DArmor.m_AssignAll:				
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(All_Armor);
				break;
			case m_2DArmor.m_2DArmor:		
				R6MenuGearWidget(OwnerWindow).EquipmentSelected(Armor);
				setHighLight(m_2DArmor.m_2DArmor);
				break;
		}
	}
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

function TexRegion GetCurrentGadgetTex(Bool _Primary)
{
    if(_Primary == true)    
        return R6MenuGearWidget(OwnerWindow).GetGadgetTexture(R6MenuGearWidget(OwnerWindow).m_OpFirstGadgetDesc);    
    else     
        return R6MenuGearWidget(OwnerWindow).GetGadgetTexture(R6MenuGearWidget(OwnerWindow).m_OpSecondGadgetDesc);    
        
}

function BOOL CenterGadgetTexture(Bool _Primary)
{
    local BOOL Result;
    local R6MenuGearWidget GearRoom;

    GearRoom = R6MenuGearWidget(OwnerWindow);

    if(_Primary == true) 
    {
        if( class'R6DescPrimaryMags' == GearRoom.m_OpFirstGadgetDesc )
        {
            if(GearRoom.m_OpFirstWeaponGadgetDesc.Default.m_NameTag == "CMAG")
            {
                Result = true;
            }
        }
        
    }        
    else     
    {
        if(class'R6DescSecondaryMags' == GearRoom.m_OpSecondGadgetDesc )
        {
            if(GearRoom.m_OpSecondWeaponGadgetDesc.Default.m_NameTag == "CMAG")
            {                
                Result = true;
            }
        }

    }        
        
    return Result;
}

function class<R6ArmorDescription> GetCurrentArmor()
{
    return R6MenuGearWidget(OwnerWindow).m_OpArmorDesc;
}

function UpdateDetails()
{       
    
    local TexRegion                             TR;
          
    ///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////  Setting First Weapon          ///////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////

    m_2DWeaponPrimary.SetWeaponTexture( GetCurrentPrimaryWeapon().Default.m_2DMenuTexture, 
                                        GetCurrentPrimaryWeapon().Default.m_2dMenuRegion);
    
    
    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////   Setting First Weapon Gadget   ///////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    
    m_2DWeaponPrimary.SetWeaponGadgetTexture(   GetCurrentWeaponGadget(true).Default.m_2DMenuTexture, 
                                                GetCurrentWeaponGadget(true).Default.m_2dMenuRegion);

    
    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////  Setting First Weapon Bullet //////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    
    m_2DWeaponPrimary.SetBulletTexture( GetCurrentWeaponBullet(true).Default.m_2DMenuTexture, 
                                        GetCurrentWeaponBullet(true).Default.m_2dMenuRegion);
        

    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////  Setting Secondary Weapon      ///////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    
    m_2DWeaponSecondary.SetWeaponTexture( GetCurrentSecondaryWeapon().Default.m_2DMenuTexture, 
                                          GetCurrentSecondaryWeapon().Default.m_2dMenuRegion);
    
    
    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////   Setting Secondary Weapon Gadget   ///////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
        
    m_2DWeaponSecondary.SetWeaponGadgetTexture(   GetCurrentWeaponGadget(false).Default.m_2DMenuTexture, 
                                                  GetCurrentWeaponGadget(false).Default.m_2dMenuRegion);
    
    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////  Setting Secondary Weapon Bullet //////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    
    m_2DWeaponSecondary.SetBulletTexture( GetCurrentWeaponBullet(false).Default.m_2DMenuTexture, 
                                          GetCurrentWeaponBullet(false).Default.m_2dMenuRegion);
    
    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////  Setting Up Primary  Gadget    ///////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    
    TR = GetCurrentGadgetTex(true);
    m_2DGadgetPrimary.m_bCenterTexture = CenterGadgetTexture(true);
    m_2DGadgetPrimary.SetGadgetTexture( TR.T,  GetRegion(TR) );
    

    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////  Setting Up Secondary  Gadget  ///////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    
    TR = GetCurrentGadgetTex(false);
    m_2DGadgetPrimary.m_bCenterTexture = CenterGadgetTexture(false);
    m_2DGadgetSecondary.SetGadgetTexture(   TR.T,  GetRegion(TR) );
    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////  Setting Up Armor  ///////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    if(m_2DArmor != none)
    {
          m_2DArmor.SetArmorTexture( GetCurrentArmor().Default.m_2DMenuTexture, 
                               GetCurrentArmor().Default.m_2dMenuRegion);
    }
    ///////////////////////////////////////////////////////////////////////////////////////

  

}

defaultproperties
{
     m_fArmorWindowWidth=131.000000
     m_fPrimaryWindowHeight=79.000000
     m_fSecondaryWindowHeight=133.000000
     m_fPrimaryGadgetWindowHeight=58.000000
}
