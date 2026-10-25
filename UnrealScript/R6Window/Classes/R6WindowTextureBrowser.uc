//=============================================================================
//  R6WindowTextureBrowser.uc : Small widget allowing user to select a texture 
//                              from a texture collection
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/04 * Created by Alexandre Dionne
//=============================================================================


class R6WindowTextureBrowser extends UWindowDialogClientWindow;

var Array<Texture>          m_TextureCollection;
var Array<Region>           m_TextureRegionCollection;

var R6WindowBitMap          m_CurrentSelection;
var UWindowHScrollBar       m_HSB;
var R6WindowTextLabelExt	m_pTextLabel;

var BOOL                    m_bSBInitialized;
var BOOL                    m_bBitMapInitialized;
var int                     m_iNbDisplayedElement;  //1 for now


var bool                    bShowLog;



//================================================================
//	CreateBitmap : Create the Bitmap where you want it make sure you leave enough room for the scroll bar
//================================================================
function CreateBitmap(int X, int Y, int W, int H)
{
    if(m_CurrentSelection == None)
        m_CurrentSelection = R6WindowBitMap(CreateControl(class'R6WindowBitMap', X, Y, W, H,self));

    m_bBitMapInitialized = true;
}


function SetBitmapProperties(bool _bStretch, bool _bCenter, INT _iDrawStyle, bool _bUseColor, OPTIONAL color _TextureColor)
{
    if(m_CurrentSelection != None)
    {
        m_CurrentSelection.m_bUseColor      = _bUseColor;        
        m_CurrentSelection.m_TextureColor   = _TextureColor;
        m_CurrentSelection.bStretch         = _bStretch;
        m_CurrentSelection.bCenter          = _bCenter;
        m_CurrentSelection.m_iDrawStyle     = _iDrawStyle;
    }
}

function SetBitmapBorder(bool _bDrawBorder, color _borderColor)
{
    if(m_CurrentSelection != None)
    {        
        m_CurrentSelection.m_bDrawBorder  = _bDrawBorder;
        m_CurrentSelection.m_borderColor  = _borderColor;        
    }
}


//================================================================
//	Created: Creates the Horizontal scroll bar
//================================================================
function CreateSB( int X, int Y, int W, int H)
{
    
    m_HSB = UWindowHScrollBar(CreateControl(class'UWindowHScrollBar', X, Y, W, LookAndFeel.Size_ScrollbarWidth, self));

    m_HSB.SetRange(0, m_TextureCollection.length, m_iNbDisplayedElement);
    m_bSBInitialized = true;
}

function CreateTextLabel( int X, int Y, int W, int H, string _szText, string _szToolTip)
{
	// create the text part
	m_pTextLabel = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', X, Y, W, H, self));
	m_pTextLabel.bAlwaysBehind = true;
	m_pTextLabel.SetNoBorder(); 

	// add text label
	m_pTextLabel.m_Font = Root.Fonts[F_SmallTitle];  
	m_pTextLabel.m_vTextColor = Root.Colors.White;

	m_pTextLabel.AddTextLabel( _szText, 0, 0, 150, TA_Left, false);


	ToolTipString = _szToolTip;
}

function Notify(UWindowDialogControl C, byte E)
{
    if( E == DE_Click )
    {
        switch(C)
        {
        case m_HSB.LeftButton:
        case m_HSB.RightButton:      
            if(bShowLog)log("Yo1 m_HSB.Pos"@m_HSB.Pos);
            if(m_TextureCollection.Length >0)
            {
                m_CurrentSelection.T = m_TextureCollection[m_HSB.Pos];
                m_CurrentSelection.R = m_TextureRegionCollection[m_HSB.Pos];
            }            
            break;    
        }
    }  
    
    if( E == DE_Change )
    {
        switch(C)
        {
        case m_HSB:
            if(bShowLog)log("Yo2 m_HSB.Pos"@m_HSB.Pos);
            if(bShowLog)log("Yo2 m_TextureCollection.length"@m_TextureCollection.length);           
            if(m_TextureCollection.length > 0)
            {
                m_CurrentSelection.T = m_TextureCollection[m_HSB.Pos];
                m_CurrentSelection.R = m_TextureRegionCollection[m_HSB.Pos];
                if(bShowLog)log("m_CurrentSelection.T "@m_CurrentSelection.T );
                if(bShowLog)log("m_CurrentSelection.R.W"@m_CurrentSelection.R.W );
            }            
            break;        
        }
    }  
    
    if( E == DE_MouseEnter)
    {
        switch(C)
        {
        case m_CurrentSelection:
        case m_HSB:  
            if (m_pTextLabel != None)
            {
                m_pTextLabel.ChangeColorLabel( Root.Colors.ButtonTextColor[2], 0);	
            }
            if( m_CurrentSelection != None)
            {
                m_CurrentSelection.m_borderColor  = Root.Colors.ButtonTextColor[2];        
            }  
            if(m_HSB != None)
            {
                m_HSB.m_NormalColor = Root.Colors.ButtonTextColor[2];
            }  
            break;
            
        }
        
    }
    
    if(E == DE_MouseLeave)
    {
        
        switch(C)
        {
        case m_CurrentSelection:
        case m_HSB:  
            if (m_pTextLabel != None)
            {
                m_pTextLabel.ChangeColorLabel( Root.Colors.White, 0);	
            }
            if( m_CurrentSelection != None)
            {
                m_CurrentSelection.m_borderColor  = Root.Colors.White;        
            }
            if(m_HSB != None)
            {
                m_HSB.m_NormalColor = Root.Colors.White;
            }            
            break;
            
        }
        
        
    }
    
}

//================================================================
//	
//================================================================
function int AddTexture(Texture _Texture, Region _Region)
{
    if(bShowLog)log("AddTexture inserting at"@m_TextureCollection.length);
    if( _Texture != None)    
    {
        

        m_TextureRegionCollection[m_TextureCollection.length] = _Region;
        m_TextureCollection[m_TextureCollection.length] = _Texture;

        if(m_HSB != none)
            m_HSB.SetRange(0, m_TextureCollection.length, m_iNbDisplayedElement);

        
       if(bShowLog)log("m_TextureCollection[m_TextureCollection.length -1]"@m_TextureCollection[m_TextureCollection.length -1]);       
       if(bShowLog)log("m_TextureRegionCollection[m_TextureCollection.length -1].W"@m_TextureRegionCollection[m_TextureCollection.length -1].W);       
       if(bShowLog)log("m_TextureCollection.length"@m_TextureCollection.length);

        return m_TextureCollection.length -1;
    }
   
    
    return -1;
}

//================================================================
//	
//================================================================
function RemoveTexture(Texture _Texture)
{
    if(m_HSB != none)
    {
        m_HSB.SetRange(0, max(0,m_TextureCollection.length-1), m_iNbDisplayedElement);
    }
        

    return;
}

//================================================================
//	
//================================================================
function RemoveTextureFromIndex(int _index)
{    
    m_TextureCollection.remove(_index, _index); 
    m_TextureRegionCollection.remove(_index, _index); 

    if(m_HSB != none)
    {                       
        m_HSB.SetRange(0, max(0,m_TextureCollection.length-1), m_iNbDisplayedElement);
    }
        

}

//================================================================
//	
//================================================================
function int GetTextureIndex(Texture _Texture)
{
    return -1;
}


//================================================================
//	Returns current selected texture index
//================================================================
function int GetCurrentTextureIndex()
{
    if(m_TextureCollection.length > 0)
    {
        if(m_HSB != none)
            return m_HSB.Pos;
        else 
            return 0;

    }        
    else
        return -1;
}

//================================================================
//	Sets current selectd texture if possible
//================================================================
function SetCurrentTextureFromIndex( int _Index)
{
    if(m_TextureCollection.length > _Index)
    {
        m_HSB.Show(_Index);
    }            
}

//================================================================
//	
//================================================================
function Texture GetTextureAtIndex(int _Index)
{
    return None;
}

//================================================================
//	
//================================================================
function GetCurrentSelectedTexture()
{
    return ;
}

//================================================================
//	
//================================================================
function Clear()
{
    m_TextureCollection.remove(0, m_TextureCollection.length); 
    m_TextureRegionCollection.remove(0, m_TextureCollection.length); 

    m_HSB.SetRange(0, 0, m_iNbDisplayedElement);
}

defaultproperties
{
     m_iNbDisplayedElement=1
}
