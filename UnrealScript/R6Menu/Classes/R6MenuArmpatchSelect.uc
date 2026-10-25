//=============================================================================
//  R6MenuArmpatchSelect.uc : Armpatch chooser for option menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/10 * Created by Alexandre Dionne
//=============================================================================

class R6MenuArmpatchSelect extends UWindowDialogClientWindow;

var R6WindowTextListBox			m_ArmPatchListBox;
var R6WindowTextLabelExt	    m_pTextLabel;
var UWindowBitmap               m_ArmpatchBitmap;

var Texture                     m_TDefaultTexture;
var Texture                     m_TBlankTexture;
var Texture                     m_TInvalidTexture;

var Region                      m_RBlankTexture;
var string                      m_Path, m_Ext;

var R6WindowListBoxItem         m_DefaultItem;

var R6FileManager				m_pFileManager;

function CreateListBox(int X,int Y,int W,int H)    
{		
	if(m_ArmPatchListBox != none)
        return;

    m_pFileManager                              = new class'R6FileManager';

   	m_ArmPatchListBox = R6WindowTextListBox(CreateControl( class'R6WindowTextListBox', X, Y, W, H, self));
    m_ArmPatchListBox.ListClass=class'R6WindowListBoxItem';
	m_ArmPatchListBox.SetCornerType(No_Corners);	    

}

function CreateTextLabel( int X, int Y, int W, int H, string _szText, string _szToolTip)
{
    if(m_pTextLabel != none)
        return;

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

function CreateArmPatchBitmap(int X, int Y, int W, int H)
{
    
    if(m_ArmpatchBitmap != none)
        return;
    m_ArmpatchBitmap = UWindowBitMap(CreateWindow(class'UWindowBitMap', X, Y, W, H, self));
    m_ArmpatchBitmap.m_iDrawStyle = 1; //Normal
    m_ArmpatchBitmap.T = m_TBlankTexture;
    m_ArmpatchBitmap.R = m_RBlankTexture;

}
    

function RefreshListBox()
{
	local int iFiles, i;
	local String szFilename;
	local R6WindowListBoxItem NewItem;

    if( m_ArmPatchListBox == none)
        return;

	m_ArmPatchListBox.Items.Clear();

	if(m_pFileManager == NONE)
	{
		log("m_pFileManager == NONE");
		iFiles = 0;
	}
	else
	{
		//Filling the file list
		iFiles = m_pFileManager.GetNbFile(m_Path, m_Ext);	
	}

    m_DefaultItem = R6WindowListBoxItem(m_ArmPatchListBox.Items.Append(m_ArmPatchListBox.ListClass));		
	m_DefaultItem.HelpText = Localize("Options","DEFAULT","R6Menu");
    m_DefaultItem.m_szToolTip = "";
	
	for(i=0; i<iFiles; i++)
	{
		m_pFileManager.GetFileName( i, szFilename);
		if(szFilename!="")
		{			
			NewItem = R6WindowListBoxItem(m_ArmPatchListBox.Items.Append(m_ArmPatchListBox.ListClass));		
			NewItem.HelpText = Left(szFilename,Len(szFilename)-4) ; 
            NewItem.m_szToolTip = Caps(szFilename);
		}
	}
		
    if(m_ArmPatchListBox.Items.Count() > 0)
    {
        m_ArmPatchListBox.SetSelectedItem(R6WindowListBoxItem(m_ArmPatchListBox.Items.Next));
        m_ArmPatchListBox.MakeSelectedVisible(); 
    }    	    
	
}

function SetDesiredSelectedArmpatch(string _ArmPatchName)
{
    
    local int       i;
    local bool      found;
    local R6WindowListBoxItem CurItem;
    local String    inString;

    if(m_ArmPatchListBox.Items == None)
        return;

    inString = Caps(_ArmPatchName);   

        
    CurItem = R6WindowListBoxItem(m_ArmPatchListBox.Items.Next);

    for(i= 0; (i < m_ArmPatchListBox.Items.Count()) && (found == false);i++)
	{
		if(CurItem.m_szToolTip == inString)	
			found = true;		
		else
			CurItem = R6WindowListBoxItem(CurItem.Next);
	}

    if(found)
        m_ArmPatchListBox.SetSelectedItem(CurItem);

}


function string GetSelectedArmpatch()
{
    if(m_ArmPatchListBox.m_SelectedItem != none)
    {
        if ( class'Actor'.static.ReplaceTexture(m_Path$m_ArmPatchListBox.m_SelectedItem.m_szToolTip, m_ArmpatchBitmap.T ) == true)                            
            return m_ArmPatchListBox.m_SelectedItem.m_szToolTip;
        else
            return "";
    }        
    else
        return "";
}

function Notify(UWindowDialogControl C, byte E)
{
    switch( E)
    {
        case DE_MouseEnter:
            if(C == m_ArmPatchListBox)
                m_pTextLabel.ChangeColorLabel( Root.Colors.ButtonTextColor[2], 0);	
            break;
        case DE_MouseLeave:
            if(C == m_ArmPatchListBox)
                m_pTextLabel.ChangeColorLabel( Root.Colors.White, 0);	
            break; 
        case DE_Click:
            if(C == m_ArmPatchListBox)
            {               
                if( m_ArmPatchListBox.m_SelectedItem != none)
                {
                    if( R6WindowListBoxItem(m_ArmPatchListBox.m_SelectedItem) == m_DefaultItem)
                        m_ArmpatchBitmap.T = m_TDefaultTexture;
                    else
                        {
                            m_ArmpatchBitmap.T = m_TBlankTexture;
                            if ( class'Actor'.static.ReplaceTexture(m_Path$m_ArmPatchListBox.m_SelectedItem.m_szToolTip, m_ArmpatchBitmap.T ) == false)                            
                                m_ArmpatchBitmap.T = m_TInvalidTexture;       
                                                           
                        }                      
                        
                }                
            }                
            break;                      
    }    

}

function SetToolTip(string _InString)
{
    m_ArmPatchListBox.ToolTipString = _InString;
}

#ifdefDEBUG
function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	local BOOL bDrawBorder;

	if (bDrawBorder)
	{
		m_BorderColor = Root.Colors.Yellow;
		DrawSimpleBorder(C);
	}
}
#endif

defaultproperties
{
     m_TDefaultTexture=Texture'R6Characters_T.Rainbow.R6armpatch'
     m_TBlankTexture=Texture'R6MenuTextures.R6armpatchblank'
     m_TInvalidTexture=Texture'R6MenuTextures.NotValid'
     m_RBlankTexture=(W=64,H=64)
//   m_path="..\ArmPatches\"
// Joshua - UCC reads \" as an escaped quote and drops the value
     m_path="..\\ArmPatches\\"
     m_Ext="TGA"
}
