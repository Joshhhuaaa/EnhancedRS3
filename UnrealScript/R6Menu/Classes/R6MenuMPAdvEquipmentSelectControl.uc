//=============================================================================
//  R6MenuMPAdvEquipmentSelectControl.uc : This control should provide functionalities
//                                      needed to show 2d representations of equipment
//                                      multi-player adverserial    
//                                      
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================


class R6MenuMPAdvEquipmentSelectControl extends R6MenuEquipmentSelectControl;


//Display variables

var FLOAT                       m_fPrimaryGadgetWindowWidth;


//Debug
var BOOL                        bShowLog;


function Created()
{
    m_DisableColor = Root.Colors.GrayLight;
	m_EnableColor  = Root.Colors.White;    

	m_2DWeaponPrimary   = R6MenuMPAdvGearPrimaryWeapon(CreateControl(class'R6MenuMPAdvGearPrimaryWeapon',       
                                                                                    0,  
                                                                                    0,  
                                                                                    WinWidth,   
                                                                                    m_fPrimaryWindowHeight, 
                                                                                    self));
    
    m_2DWeaponSecondary = R6MenuMPAdvGearSecondaryWeapon(CreateControl(class'R6MenuMPAdvGearSecondaryWeapon', 
                                                                                    0,  
                                                                                    m_fPrimaryWindowHeight-1 ,  
                                                                                    WinWidth, 
                                                                                    m_fSecondaryWindowHeight +1, 
                                                                                    self));

    
    m_2DGadgetPrimary   = R6MenuMPAdvGearGadget(CreateControl(class'R6MenuMPAdvGearGadget',      
                                                                                    0, 
                                                                                    m_fPrimaryWindowHeight + m_fSecondaryWindowHeight -1,
                                                                                    WinWidth / 2, 
                                                                                    WinHeight - m_fPrimaryWindowHeight - m_fSecondaryWindowHeight +1, 
                                                                                    self));
    
    m_2DGadgetSecondary = R6MenuMPAdvGearGadget(CreateControl(class'R6MenuMPAdvGearGadget',                   
                                                                                    m_2DGadgetPrimary.WinLeft + m_2DGadgetPrimary.WinWidth -1,
                                                                                    m_2DGadgetPrimary.WinTop,
                                                                                    WinWidth - m_2DGadgetPrimary.WinLeft - m_2DGadgetPrimary.WinWidth +1,         
                                                                                    m_2DGadgetPrimary.WinHeight, 
                                                                                    self));
 

    
}

function Init()
{
    R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Primary_Weapon);
    setHighLight(m_2DWeaponPrimary.m_2DWeapon);
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

function TexRegion GetCurrentGadgetTex(Bool _Primary)
{
    if(_Primary == true)
        return R6MenuMPAdvGearWidget(OwnerWindow).GetGadgetTexture(R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstGadgetDesc);
    else 
        return R6MenuMPAdvGearWidget(OwnerWindow).GetGadgetTexture(R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondGadgetDesc);
}

function BOOL CenterGadgetTexture(Bool _Primary)
{
    return true;
}


function Notify(UWindowDialogControl C, byte E)
{
	if(E == DE_Click)
	{
		switch(C)
		{	
            
        //First Weapon Equipment Click		
        case m_2DWeaponPrimary.m_2DWeapon:							
            if(bShowLog)log("m_2DWeaponPrimary.m_2DWeapon");
            R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Primary_Weapon);
            setHighLight(m_2DWeaponPrimary.m_2DWeapon);
			break;
        case m_2DWeaponPrimary.m_2DBullet:							
            if(bShowLog)log("m_2DWeaponPrimary.m_2DBullet");
            R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Primary_Bullet);
            setHighLight(m_2DWeaponPrimary.m_2DBullet);
			break;
        case m_2DWeaponPrimary.m_2DWeaponGadget:							
            if(bShowLog)log("m_2DWeaponPrimary.m_2DWeaponGadget");
            R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Primary_WeaponGadget);
            setHighLight(m_2DWeaponPrimary.m_2DWeaponGadget);
			break;


        //Secondary Weapon Equipment Click		
        case m_2DWeaponSecondary.m_2DWeapon:							
            if(bShowLog)log("m_2DWeaponSecondary.m_2DWeapon");
            R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Secondary_Weapon);
            setHighLight(m_2DWeaponSecondary.m_2DWeapon);
			break;
        case m_2DWeaponSecondary.m_2DBullet:							
            if(bShowLog)log("m_2DWeaponSecondary.m_2DBullet");
            R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Secondary_Bullet);
            setHighLight(m_2DWeaponSecondary.m_2DBullet);
			break;
        case m_2DWeaponSecondary.m_2DWeaponGadget:							
            if(bShowLog)log("m_2DWeaponSecondary.m_2DWeaponGadget");
            R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Secondary_WeaponGadget);
            setHighLight(m_2DWeaponSecondary.m_2DWeaponGadget);
			break;
        
        //Primary Gadget control pressed        
        case m_2DGadgetPrimary.m_2DGadget:		
            if(bShowLog)log("m_2DGadgetPrimary.m_2DGadget");
            R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Primary_Gadget);
            setHighLight(m_2DGadgetPrimary.m_2DGadget);
			break;       

        //Secondary Gadget control pressed        
        case m_2DGadgetSecondary.m_2DGadget:		
            if(bShowLog)log("m_2DGadgetSecondary.m_2DGadget");
            R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(Secondary_Gadget);
            setHighLight(m_2DGadgetSecondary.m_2DGadget);
			break;        

		}
	}
}

defaultproperties
{
     m_fPrimaryWindowHeight=138.000000
     m_fSecondaryWindowHeight=84.000000
}
