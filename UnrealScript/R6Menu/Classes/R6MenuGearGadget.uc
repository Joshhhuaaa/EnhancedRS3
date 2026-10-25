//=============================================================================
//  R6MenuGearGadget.uc : This will display the current 2D model
//                        of one of the 2 gadgets selected for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================


class R6MenuGearGadget extends UWindowDialogControl;

var     R6MenuAssignAllButton		m_AssignAll;
var     R6WindowButtonGear			m_2DGadget; 

var		FLOAT						m_2DGadgetWidth;

var     BOOL						m_bAssignAllButton;
var     BOOL                        m_bCenterTexture;

function Created()
{
	m_BorderColor = Root.Colors.GrayLight;

    if(m_bAssignAllButton == true)
    {
		m_AssignAll = R6MenuAssignAllButton(CreateWindow(class'R6MenuAssignAllButton',WinWidth - class'R6MenuAssignAllButton'.Default.UpRegion.W -1, 0, class'R6MenuAssignAllButton'.Default.UpRegion.W, WinHeight, self));       
		m_AssignAll.ToolTipString	= Localize("Tip","GearRoomItemAll","R6Menu");		
		m_AssignAll.ImageX			= 0;
		//m_AssignAll.ImageY			= 25;
        m_AssignAll.ImageY = (WinHeight - class'R6MenuAssignAllButton'.Default.UpRegion.H) /2;
    }
    
    m_2DGadget = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', 0, 0, m_2DGadgetWidth, WinHeight ,self));
	m_2DGadget.ToolTipString		= Localize("Tip","GearRoomItem","R6Menu");
    m_2DGadget.bUseRegion           = true;
    m_2DGadget.m_iDrawStyle         = 5;  
    
}


function Register(UWindowDialogClientWindow	W)
{    
    Super.Register(W);
    if(m_bAssignAllButton == true)
        m_AssignAll.Register(W);   
    m_2DGadget.Register(W);   
}

function SetGadgetTexture(Texture T, Region R)
{    
    m_2DGadget.DisabledTexture  = T;
    m_2DGadget.DisabledRegion   = R;
    m_2DGadget.DownTexture      = T;
    m_2DGadget.DownRegion       = R;
    m_2DGadget.OverTexture      = T;
    m_2DGadget.OverRegion       = R;
    m_2DGadget.UpTexture        = T;
    m_2DGadget.UpRegion         = R;
    
    if(m_bCenterTexture)
    {
        m_2DGadget.ImageX           = (m_2DGadget.WinWidth - m_2DGadget.UpRegion.W)/2;
        m_2DGadget.ImageY           = (m_2DGadget.WinHeight - m_2DGadget.UpRegion.H)/2;
    }
    else
    {
        m_2DGadget.ImageX           = m_2DGadget.Default.ImageX;
        m_2DGadget.ImageY           = m_2DGadget.Default.ImageY;
    }
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
   DrawSimpleBorder( C);   
}

//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonsStatus( BOOL _bDisable)
{
	m_AssignAll.SetButtonStatus( _bDisable);
	
	m_2DGadget.bDisabled  = _bDisable;

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
	m_2DGadget.ForceMouseOver( _bForceMouseOver);
}

defaultproperties
{
     m_bAssignAllButton=True
     m_2DGadgetWidth=66.000000
}
