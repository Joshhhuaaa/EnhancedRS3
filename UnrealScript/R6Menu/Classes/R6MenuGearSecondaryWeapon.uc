//=============================================================================
//  R6MenuGearSecondaryWeapon.uc : This will display the current 2D model
//                        of the secondary weapon for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================


class R6MenuGearSecondaryWeapon extends UWindowDialogControl;

var     R6MenuAssignAllButton     m_AssignAll;
var     BOOL                      m_bAssignAllButton;
var     BOOL                      m_bCenterTexture;

var     R6WindowButtonGear              m_2DWeapon;
var     R6WindowButtonGear              m_2DBullet;
var     R6WindowButtonGear              m_2DWeaponGadget; //Weapon Gadget not to be confused with simple gadgets

//Lines separating items
var     Texture                     m_LinesTexture;
var     Region                      m_LinesRegion;
var     Color						m_InsideLinesColor;

var		FLOAT						m_2DWeaponWidth;
var     FLOAT                       m_2DWeaponHeight;
var     FLOAT                       m_2DBulletHeight;


function Created()
{
    local FLOAT m_2DWeaponGadgetHeight;
    
	m_InsideLinesColor = Root.Colors.GrayLight;
    m_BorderColor	   = Root.Colors.GrayLight;	

    if(m_bAssignAllButton == true)
    {
        m_AssignAll = R6MenuAssignAllButton(CreateWindow(class'R6MenuAssignAllButton',WinWidth - class'R6MenuAssignAllButton'.Default.UpRegion.W - 1, 0, class'R6MenuAssignAllButton'.Default.UpRegion.W, WinHeight, self));  
		m_AssignAll.ToolTipString	= Localize("Tip","GearRoomAssign","R6Menu");        
		m_AssignAll.ImageX			= 0;
		//m_AssignAll.ImageY			= 63;
        m_AssignAll.ImageY			= (WinHeight - class'R6MenuAssignAllButton'.Default.UpRegion.H) /2;
    }

    m_2DWeapon = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', 0, 0, m_2DWeaponWidth, m_2DWeaponHeight, self));
	m_2DWeapon.ToolTipString			= Localize("Tip","GearRoomSecWeapon","R6Menu");
    m_2DWeapon.bUseRegion               = true;
    m_2DWeapon.m_iDrawStyle             = 5;

    m_2DBullet = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', 0, m_2DWeapon.WinTop + m_2DWeapon.WinHeight, m_2DWeaponWidth, m_2DBulletHeight, self));
	m_2DBullet.ToolTipString			= Localize("Tip","GearRoomAmmo","R6Menu");
    m_2DBullet.bUseRegion               = true;
    m_2DBullet.m_iDrawStyle             = 5;

    m_2DWeaponGadgetHeight = WinHeight - m_2DWeapon.WinHeight - m_2DBullet.WinHeight;

    m_2DWeaponGadget = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', 0, m_2DBullet.WinTop + m_2DBullet.WinHeight, m_2DWeaponWidth, m_2DWeaponGadgetHeight, self));
	m_2DWeaponGadget.ToolTipString		= Localize("Tip","GearRoomAttach","R6Menu");
    m_2DWeaponGadget.bUseRegion         = true;
    m_2DWeaponGadget.m_iDrawStyle       = 5;   
    
  
}


function Register(UWindowDialogClientWindow	W)
{    
    Super.Register(W);
    if(m_bAssignAllButton == true)
        m_AssignAll.Register(W);
    m_2DWeapon.Register(W);
    m_2DBullet.Register(W);
    m_2DWeaponGadget.Register(W);
       
    
}

function SetWeaponTexture(Texture T, Region R)
{
    m_2DWeapon.DisabledTexture  = T;
    m_2DWeapon.DisabledRegion   = R;
    m_2DWeapon.DownTexture      = T;
    m_2DWeapon.DownRegion       = R;
    m_2DWeapon.OverTexture      = T;
    m_2DWeapon.OverRegion       = R;
    m_2DWeapon.UpTexture        = T;
    m_2DWeapon.UpRegion         = R;
    
    if(m_bCenterTexture)
    {
        m_2DWeapon.ImageX           = (m_2DWeapon.WinWidth - m_2DWeapon.UpRegion.W)/2;
        m_2DWeapon.ImageY           = (m_2DWeapon.WinHeight - m_2DWeapon.UpRegion.H)/2;
    }    

}

function SetWeaponGadgetTexture(Texture T, Region R)
{    
    m_2DWeaponGadget.DisabledTexture    = T;
    m_2DWeaponGadget.DisabledRegion     = R;
    m_2DWeaponGadget.DownTexture        = T;
    m_2DWeaponGadget.DownRegion         = R;
    m_2DWeaponGadget.OverTexture        = T;
    m_2DWeaponGadget.OverRegion         = R;
    m_2DWeaponGadget.UpTexture          = T;
    m_2DWeaponGadget.UpRegion           = R;

    if(m_bCenterTexture)
    {
        m_2DWeaponGadget.ImageX           = (m_2DWeaponGadget.WinWidth - m_2DWeaponGadget.UpRegion.W)/2;
        m_2DWeaponGadget.ImageY           = (m_2DWeaponGadget.WinHeight - m_2DWeaponGadget.UpRegion.H)/2;
    }    
}

function SetBulletTexture(Texture T, Region R)
{    
    m_2DBullet.DisabledTexture  = T;
    m_2DBullet.DisabledRegion   = R;
    m_2DBullet.DownTexture      = T;
    m_2DBullet.DownRegion       = R;
    m_2DBullet.OverTexture      = T;
    m_2DBullet.OverRegion       = R;
    m_2DBullet.UpTexture        = T;
    m_2DBullet.UpRegion         = R;

    if(m_bCenterTexture)
    {
        m_2DBullet.ImageX           = (m_2DBullet.WinWidth - m_2DBullet.UpRegion.W)/2;
        m_2DBullet.ImageY           = (m_2DBullet.WinHeight - m_2DBullet.UpRegion.H)/2;
    }    
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    //Draw Lines between elements
	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(m_InsideLinesColor.R, m_InsideLinesColor.G, m_InsideLinesColor.B);

	//Horizontal line
	DrawStretchedTextureSegment(C, 0, m_2DBullet.WinTop ,       m_2DWeaponWidth, m_LinesRegion.H , m_LinesRegion.X, m_LinesRegion.Y, m_LinesRegion.W, m_LinesRegion.H, m_LinesTexture);
	DrawStretchedTextureSegment(C, 0, m_2DWeaponGadget.WinTop , m_2DWeaponWidth, m_LinesRegion.H , m_LinesRegion.X, m_LinesRegion.Y, m_LinesRegion.W, m_LinesRegion.H, m_LinesTexture);

    DrawSimpleBorder(C); 
}

//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonsStatus( BOOL _bDisable)
{
	m_AssignAll.SetButtonStatus( _bDisable);
	
	m_2DWeapon.bDisabled		= _bDisable;
	m_2DBullet.bDisabled		= _bDisable;
	m_2DWeaponGadget.bDisabled	= _bDisable;

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
	m_2DWeapon.ForceMouseOver( _bForceMouseOver);
	m_2DBullet.ForceMouseOver( _bForceMouseOver);
	m_2DWeaponGadget.ForceMouseOver( _bForceMouseOver);
}

defaultproperties
{
     m_bAssignAllButton=True
     m_2DWeaponWidth=66.000000
     m_2DWeaponHeight=54.000000
     m_2DBulletHeight=35.000000
     m_LinesTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_LinesRegion=(X=64,Y=59,W=1,H=1)
}
