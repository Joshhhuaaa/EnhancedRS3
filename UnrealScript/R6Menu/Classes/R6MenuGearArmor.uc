//=============================================================================
//  R6MenuGearArmor.uc : This will display the current 2D model
//                        of the Armor for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================


class R6MenuGearArmor extends UWindowDialogControl;

var     R6WindowButtonGear        m_2DArmor; 
var     R6MenuAssignAllButton     m_AssignAll;




function Created()
{ 
	m_BorderColor = Root.Colors.GrayLight;

    m_AssignAll = R6MenuAssignAllButton(CreateWindow(class'R6MenuAssignAllButton',WinWidth - class'R6MenuAssignAllButton'.Default.UpRegion.W - 1, 0, class'R6MenuAssignAllButton'.Default.UpRegion.W, WinHeight, self));       
	m_AssignAll.ToolTipString	= Localize("Tip","GearRoomArmorAll","R6Menu");    
	m_AssignAll.ImageX			= 0;
	//m_AssignAll.ImageY			= 122;
    m_AssignAll.ImageY			= (WinHeight - class'R6MenuAssignAllButton'.Default.UpRegion.H) /2;

    m_2DArmor = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', 0, 0, WinWidth - m_AssignAll.WinWidth, WinHeight ,self));
	m_2DArmor.ToolTipString		= Localize("Tip","GearRoomArmor","R6Menu");
    m_2DArmor.bUseRegion        = true;
    m_2DArmor.m_iDrawStyle      = 5;  
    
}


function Register(UWindowDialogClientWindow	W)
{    
	Super.Register(W);
    m_AssignAll.Register(W);
    
    m_2DArmor.Register(W);   
}

function SetArmorTexture(Texture T, Region R)
{    
    m_2DArmor.DisabledTexture  = T;
    m_2DArmor.DisabledRegion   = R;
    m_2DArmor.DownTexture      = T;
    m_2DArmor.DownRegion       = R;
    m_2DArmor.OverTexture      = T;
    m_2DArmor.OverRegion       = R;
    m_2DArmor.UpTexture        = T;
    m_2DArmor.UpRegion         = R;
    
    //m_2DArmor.ImageX           = (m_2DArmor.WinWidth - m_2DArmor.UpRegion.W)/2;
    //m_2DArmor.ImageY           = (m_2DArmor.WinHeight - m_2DArmor.UpRegion.H)/2;
}



function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	DrawSimpleBorder(C);
}

//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonsStatus( BOOL _bDisable)
{
	m_AssignAll.SetButtonStatus( _bDisable);
	
	m_2DArmor.bDisabled		= _bDisable;

}

//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor( Color _NewColor)
{
	m_AssignAll.SetBorderColor( _NewColor);

	m_BorderColor = _NewColor;
}

//=================================================================
// ForceMouseOver: Force mouse over on all the window on this page
//=================================================================
function ForceMouseOver( BOOL _bForceMouseOver)
{
	m_2DArmor.ForceMouseOver( _bForceMouseOver);
}

defaultproperties
{
}
