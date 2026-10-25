//=============================================================================
//  R6WindowTextIconsSubListBox.uc : This list is designed to be used
//                                      with th R6WindowDynTeamList
//                                   Instanciate this with the createControl
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/28 * Created by Alexandre Dionne
//=============================================================================


class R6WindowTextIconsSubListBox extends UWindowDialogControl;


var R6WindowTextIconsListBox    m_listBox;


//Top Label
var R6WindowButton              m_RemoveButton, m_AddButton;
var R6WindowButton              m_UpButton;
var R6WindowButton              m_DownButton;
var R6WindowTextLabel           m_Title;
var R6WindowBitmap              m_UpDownBg;
var R6WindowBitmap              m_AddRemoveBg;

var Region                      m_UpDownBgReg;
var Region                      m_AddRemoveBgReg;
var color                       m_LabelColor;
var Texture                     m_LabelTexture;
var Region                      m_LabelRegionTop;
var Region                      m_LabelRegionTile;
var Region                      m_LabelRegionBottom;
var int                         m_LabelDrawStyle;

var INT                         m_IAddRemoveXPos, m_IAddRemoveYPos, m_IAddRemoveBgXPos, m_IAddRemoveBgYPos;        

var INT                         m_IUpDownXPos, m_IUpDownBgXPos;           //X pos from right side
var INT                         m_IUpDownYPos, m_IUpDownBgYPos;

var INT                         m_IUpDownBetweenPadding;

var int                         m_maxItemsCount;

var RegionButton                m_UpReg, m_DownReg;




function Created()
{
    local region    normalReg,overReg,disabledReg, downReg;
    local float     ButtonBorderWidth,  ButtonBorderHeight , UpDownButtonWidth, UpDownButtonHeight, fLabelWidth; 
    local Texture	ButtonTexture;
        
    Super.Created();
    
    m_listBox           = R6WindowTextIconsListBox(CreateWindow(class'R6WindowTextIconsListBox', 0, m_LabelRegionTop.H, WinWidth, WinHeight - m_LabelRegionTop.H, self));
    m_listBox.SetCornerType(No_Borders);
    m_listBox.m_IgnoreAllreadySelected =false;
    
    ButtonTexture	= R6WindowLookAndFeel(LookAndFeel).m_R6ScrollTexture;
   
   
    //Add or substract an operative
	normalReg.X		=204;
	normalReg.Y		=0;
	normalReg.W		=18;
	normalReg.H		=12;
	overReg.X		=204;
	overReg.Y		=12;
	overReg.W		=18;
	overReg.H		=12;
	disabledReg.X	=204;
	disabledReg.Y	=24;
	disabledReg.W	=18;
	disabledReg.H	=12;

	ButtonBorderWidth       = normalReg.W;
	ButtonBorderHeight      = normalReg.H;

    UpDownButtonWidth       = m_UpReg.Up.W;
    UpDownButtonHeight      = m_UpReg.Up.H; 


	m_RemoveButton = R6WindowButton(CreateWindow( class'R6WindowButton', m_IAddRemoveXPos, m_IAddRemoveYPos, ButtonBorderWidth, ButtonBorderHeight, self));
	m_RemoveButton.ToolTipString		= Localize("Tip","GearRoomButRemove","R6Menu");
	m_RemoveButton.m_bDrawBorders		= false;	
	m_RemoveButton.bUseRegion			= true;    
	m_RemoveButton.DisabledTexture	    = ButtonTexture;
	m_RemoveButton.DisabledRegion       = disabledReg;
	m_RemoveButton.DownTexture		    = ButtonTexture;
	m_RemoveButton.DownRegion           = disabledReg;
	m_RemoveButton.OverTexture		    = ButtonTexture;
	m_RemoveButton.OverRegion           = overReg;
	m_RemoveButton.UpTexture		    = ButtonTexture;
	m_RemoveButton.UpRegion             = normalReg;	
	m_RemoveButton.m_iDrawStyle         = 5;
    m_RemoveButton.HideWindow();



	normalReg.X		=222;
	overReg.X		=222;
	disabledReg.X	=222;


	m_AddButton = R6WindowButton(CreateWindow( class'R6WindowButton', m_IAddRemoveXPos, m_IAddRemoveYPos, ButtonBorderWidth,ButtonBorderHeight, self));
	m_AddButton.ToolTipString		= Localize("Tip","GearRoomButAdd","R6Menu");
	m_AddButton.m_bDrawBorders		= false;
	m_AddButton.bUseRegion			= true;    
	m_AddButton.DisabledTexture	    = ButtonTexture;
	m_AddButton.DisabledRegion      = disabledReg;
	m_AddButton.DownTexture		    = ButtonTexture;
	m_AddButton.DownRegion          = disabledReg;
	m_AddButton.OverTexture		    = ButtonTexture;
	m_AddButton.OverRegion          = overReg;
	m_AddButton.UpTexture			= ButtonTexture;
	m_AddButton.UpRegion            = normalReg;	
	m_AddButton.m_iDrawStyle        = 5;
    //m_AddButton.HideWindow();

    
    m_AddRemoveBg = R6WindowBitmap(CreateWindow(class'R6WindowBitmap', m_IAddRemoveBgXPos, m_IAddRemoveBgYPos, m_AddRemoveBgReg.W, m_AddRemoveBgReg.H, self));       
    m_AddRemoveBg.bAlwaysBehind        = true;
    m_AddRemoveBg.m_bUseColor          = true;
    m_AddRemoveBg.m_iDrawStyle         = 5;
    m_AddRemoveBg.T                    = ButtonTexture;
    m_AddRemoveBg.R                    = m_AddRemoveBgReg;
    m_AddRemoveBg.SendToBack();
       
    m_UpButton = R6WindowButton(CreateWindow(class'R6WindowButton', WinWidth - m_IUpDownXPos, m_IUpDownYPos, UpDownButtonWidth, UpDownButtonHeight, self));  
	m_UpButton.ToolTipString			= Localize("Tip","GearRoomButUp","R6Menu");
    m_UpButton.m_bDrawBorders           = false;
	m_UpButton.bUseRegion               = true;
	m_UpButton.DisabledTexture	        = ButtonTexture;
	m_UpButton.DisabledRegion           = m_UpReg.Disabled;
	m_UpButton.DownTexture		        = ButtonTexture;
	m_UpButton.DownRegion               = m_UpReg.Down;
	m_UpButton.OverTexture		        = ButtonTexture;
	m_UpButton.OverRegion               = m_UpReg.Over;
	m_UpButton.UpTexture			    = ButtonTexture;
	m_UpButton.UpRegion                 = m_UpReg.Up;	
	m_UpButton.m_iDrawStyle             = 5;
    //m_UpButton.HideWindow();


    m_DownButton = R6WindowButton(CreateWindow(class'R6WindowButton', m_UpButton.Winleft + m_UpButton.WinWidth + m_IUpDownBetweenPadding, m_IUpDownYPos, UpDownButtonWidth, UpDownButtonHeight, self));       
	m_DownButton.ToolTipString			= Localize("Tip","GearRoomButDown","R6Menu");
    m_DownButton.m_bDrawBorders         = false;
	m_DownButton.bUseRegion             = true;    
	m_DownButton.DisabledTexture	    = ButtonTexture;
	m_DownButton.DisabledRegion         = m_DownReg.Disabled;
	m_DownButton.DownTexture		    = ButtonTexture;
	m_DownButton.DownRegion             = m_DownReg.Down;
	m_DownButton.OverTexture		    = ButtonTexture;
	m_DownButton.OverRegion             = m_DownReg.Over;
	m_DownButton.UpTexture			    = ButtonTexture;
	m_DownButton.UpRegion               = m_DownReg.Up;	    
	m_DownButton.m_iDrawStyle           = 5;
    //m_DownButton.HideWindow();


    m_UpDownBg = R6WindowBitmap(CreateWindow(class'R6WindowBitmap', WinWidth - m_IUpDownBgXPos, m_IUpDownBgYPos, m_UpDownBgReg.W, m_UpDownBgReg.H, self));       
    m_UpDownBg.bAlwaysBehind        = true;
    m_UpDownBg.m_bUseColor          = true;
    m_UpDownBg.m_iDrawStyle         = 5;
    m_UpDownBg.T                    = ButtonTexture;
    m_UpDownBg.R                    = m_UpDownBgReg;
    m_UpDownBg.SendToBack();
    

    fLabelWidth = m_UpButton.WinLeft - m_AddButton.WinLeft - m_AddButton.WinWidth - 1;
    //We add 1 for x coord and sub 1 for width just to make sure the label don't have the
    //click events of the button
    //m_Title = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_AddButton.WinLeft + m_AddButton.WinWidth +1, 0, fLabelWidth, m_LabelRegionTop.H, self));
    m_Title = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 0, WinWidth, m_LabelRegionTop.H, self));
    m_Title.bAlwaysBehind   = true;
    m_Title.m_BGTexture     = None;
    m_Title.m_bDrawBorders  = False;
    m_Title.m_bFixedYPos    = true;
    m_Title.TextY           = 4;
    m_Title.SendToBack();  
    
}

function Resized()
{
//    Super.Resized();
    m_listBox.SetSize( m_listBox.Winwidth ,WinHeight - m_LabelRegionTop.H);
}

function Register(UWindowDialogClientWindow	W)
{
	NotifyWindow = W;
	Notify(DE_Created);
    m_listBox.Register(W);
    
    m_AddButton.Register(W);
    m_RemoveButton.Register(W);

    m_UpButton.Register(W);
    m_DownButton.Register(W);
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    
    //Drawing Background
    C.Style= m_LabelDrawStyle;
    C.SetDrawColor(m_LabelColor.R, m_LabelColor.G, m_LabelColor.B);
    
    
	DrawStretchedTextureSegment( C, 0, 0, m_LabelRegionTop.W, m_LabelRegionTop.H , 
										m_LabelRegionTop.X, m_LabelRegionTop.Y, 
										m_LabelRegionTop.W, m_LabelRegionTop.H, m_LabelTexture );
	
	DrawStretchedTextureSegment( C, 0, m_LabelRegionTop.H, m_LabelRegionTile.W, WinHeight - m_LabelRegionTop.H - m_LabelRegionBottom.H, 
										m_LabelRegionTile.X, m_LabelRegionTile.Y, 
										m_LabelRegionTile.W, m_LabelRegionTile.H, m_LabelTexture );
    
	DrawStretchedTextureSegment( C, 0, WinHeight - m_LabelRegionBottom.H, m_LabelRegionBottom.W, m_LabelRegionBottom.H, 
										m_LabelRegionBottom.X, m_LabelRegionBottom.Y, 
										m_LabelRegionBottom.W, m_LabelRegionBottom.H, m_LabelTexture );
    
}

function SetColor(Color NewColor)
{
    m_LabelColor = NewColor;
    m_UpDownBg.m_TextureColor = NewColor;
    m_AddRemoveBg.m_TextureColor = NewColor;
}

function UpdateButtons( optional int addButton)
{

    local BOOL bDrawingAddOrRemove;

    //Cycle Up and Cycle Down Button
    //Hide buttons when selecting first and last element from list
    if(m_listBox.m_SelectedItem != None)
    {        
        m_UpButton.bDisabled    = false;
        m_DownButton.bDisabled  = false;
        
        if(m_listBox.m_SelectedItem.Next == None)        
        {               
            m_DownButton.bDisabled  = true;
        }            
        
        if(m_listBox.m_SelectedItem.Prev == m_listBox.Items)
        {         
            m_UpButton.bDisabled  = true;
        }      
        
    }
    else
    {
        //No elements selected        
        m_UpButton.bDisabled    = true;
        m_DownButton.bDisabled  = true;

    }   

       
    //Add and remove Buttons
    if(m_listBox.m_SelectedItem != None)
    {
        m_RemoveButton.ShowWindow();       
        bDrawingAddOrRemove = true;
    }
    else
    {
        m_RemoveButton.HideWindow();
    }

    if( ( addButton ==1) && ( m_listBox.Items.Count() < m_maxItemsCount))
    {
        m_AddButton.ShowWindow();
        bDrawingAddOrRemove = true;
    }
    else
        m_AddButton.HideWindow();
        
    if(bDrawingAddOrRemove == true)
    {
        m_AddRemoveBg.ShowWindow();
        m_AddRemoveBg.SendToBack();
    }        
    else 
        m_AddRemoveBg.HideWindow();
	
	if (bAcceptsFocus) // if the sublistbox have keyfocus on it
	{
		if (Root.FocusedWindow == m_listBox) // if the focusedwindow is the list of the sublistbox
		{
			// activate the list to re-build the chain of acceptfocus window 
			// note: the previous showwindow in this fct destroy the list of accept focus
			m_listBox.ActivateWindow( 0, false); 
		}
	}
}
//===================================================
// SetTip : set the tip string for thoses window
//===================================================
function SetTip( string _szTip)
{
	ToolTipString = _szTip;
	m_listBox.ToolTipString = _szTip;
	m_Title.ToolTipString	= _szTip;
}

defaultproperties
{
     m_LabelDrawStyle=5
     m_IAddRemoveXPos=6
     m_IAddRemoveYPos=5
     m_IAddRemoveBgXPos=4
     m_IAddRemoveBgYPos=3
     m_IUpDownXPos=41
     m_IUpDownBgXPos=43
     m_IUpDownYPos=5
     m_IUpDownBgYPos=3
     m_IUpDownBetweenPadding=1
     m_maxItemsCount=4
     m_LabelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_UpDownBgReg=(X=132,Y=36,W=39,H=16)
     m_AddRemoveBgReg=(X=216,Y=36,W=22,H=16)
     m_LabelColor=(B=255,G=255,R=255)
     m_LabelRegionTop=(Y=481,W=199,H=20)
     m_LabelRegionTile=(Y=504,W=199,H=2)
     m_LabelRegionBottom=(Y=507,W=199,H=2)
     m_UpReg=(Up=(X=132,W=17,H=12),Down=(X=132,Y=24,W=17,H=12),Over=(X=132,Y=12,W=17,H=12),Disabled=(X=132,Y=24,W=17,H=12))
     m_DownReg=(Up=(X=150,W=17,H=12),Down=(X=150,Y=24,W=17,H=12),Over=(X=150,Y=12,W=17,H=12),Disabled=(X=150,Y=24,W=17,H=12))
}
