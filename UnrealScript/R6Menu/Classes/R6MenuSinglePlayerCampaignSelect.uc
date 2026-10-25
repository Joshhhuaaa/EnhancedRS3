//=============================================================================
//  R6MenuSinglePlayerCampaignSelect.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSinglePlayerCampaignSelect extends UWindowDialogClientWindow;


var Texture m_BGTexture;


var R6WindowTextListBox			m_CampaignListBox;
var R6WindowTextLabelCurved     m_LCampaignTitle;

function Created()
{
	
			
	m_BGTexture	= Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", class'Texture'));
		
	
	m_LCampaignTitle = R6WindowTextLabelCurved(CreateWindow(class'R6WindowTextLabelCurved', 0, 0, WinWidth, 31, self));
	m_LCampaignTitle.Text = Localize("SinglePlayer","TitleCampaign","R6Menu");
	m_LCampaignTitle.Align = TA_Center;
	m_LCampaignTitle.m_Font = Root.Fonts[F_PopUpTitle];
	m_LCampaignTitle.TextColor = Root.Colors.White;

   	m_CampaignListBox = R6WindowTextListBox(CreateControl( class'R6WindowTextListBox', 0, 30, WinWidth, WinHeight - m_LCampaignTitle.WinHeight, self));
    m_CampaignListBox.ListClass=class'R6WindowListBoxItem';
	m_CampaignListBox.SetCornerType(Bottom_Corners);
    m_CampaignListBox.ToolTipString = Localize("Tip","CampaignListBox","R6Menu");
    m_CampaignListBox.m_fXItemRightPadding = 5;

}

/*
function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, m_CampaignListBox.WinLeft, m_CampaignListBox.WinTop, m_CampaignListBox.WinWidth, m_CampaignListBox.WinHeight);

}
*/

function RefreshListBox()
{
	local int iFiles, i;
	local String szFilename, szDir;	
    local R6PlayerCampaign PC;
    local R6MenuRootWindow RootWindow;

	m_CampaignListBox.Clear();

    RootWindow = R6MenuRootWindow(Root);

	if(RootWindow.m_pFileManager == NONE)
	{
		log("R6MenuRootWindow(Root).m_pFileManager == NONE");
		iFiles = 0;
	}
	else
	{
		//Filling the file list
		szDir = class'Actor'.static.GetModMgr().GetCampaignDir();
		iFiles = RootWindow.m_pFileManager.GetNbFile(szDir, "cmp");	
	}
	
	for(i=0; i<iFiles; i++)
	{
		RootWindow.m_pFileManager.GetFileName( i, szFilename);
		if(szFilename!="")
		{	
            LoadCampaign(szFilename);			
		}
	}
		
    if(m_CampaignListBox.Items.Count() > 0)
    {
        m_CampaignListBox.SetSelectedItem(R6WindowListBoxItem(m_CampaignListBox.Items.Next));
        m_CampaignListBox.MakeSelectedVisible();

        PC = R6PlayerCampaign(R6WindowListBoxItem(m_CampaignListBox.m_SelectedItem).m_Object);
            
        if( PC != None)
            R6MenuSinglePlayerWidget(OwnerWindow).UpdateSelectedCampaign( PC );


    }
    else
    {
        R6MenuSinglePlayerWidget(OwnerWindow).UpdateSelectedCampaign( NONE );
    }
	    
	
}

function DeleteCampaign()
{    

    local string temp, szDir;

    if(m_CampaignListBox.m_SelectedItem != None)        
    {
        szDir = class'Actor'.static.GetModMgr().GetCampaignDir();
        temp = szDir $m_CampaignListBox.m_SelectedItem.HelpText$".cmp";
        if(R6MenuRootWindow(Root).m_pFileManager.DeleteFile(temp))
            RefreshListBox();
    }
        
}


function LoadCampaign(string szCampaignName)
{
    local   R6PlayerCampaign            WorkCampaign;
    local   R6WindowListBoxItem         NewItem;

    if( (R6MenuRootWindow(Root) != NONE) && 
        (R6MenuSinglePlayerWidget(OwnerWindow).m_pFileManager !=None ) )
	{   
        WorkCampaign = new(None) class'R6PlayerCampaign';

		// The extension is always .cmp, take the complete name from there. Use Left and skip only the last 4 characters
		// ex: This is to be able to load campaign with . in the name. Like "my_campaign.1.2.cmp"
		WorkCampaign.m_FileName = Left(szCampaignName, Len(szCampaignName) - 4 ); //InStr(szCampaignName,"."));	              
        WorkCampaign.m_OperativesMissionDetails = None;
        WorkCampaign.m_OperativesMissionDetails = new(none) class'R6MissionRoster';
      
        if( R6MenuSinglePlayerWidget(OwnerWindow).m_pFileManager.LoadCampaign(WorkCampaign) )
        {
            NewItem = R6WindowListBoxItem(m_CampaignListBox.Items.Append(m_CampaignListBox.ListClass));		
            NewItem.HelpText = WorkCampaign.m_FileName;            
            NewItem.m_Object = WorkCampaign;
        }       

	}    	

}

function BOOL SetupCampaign()
{
    local R6PlayerCampaign PC;
 
    if( m_CampaignListBox.m_SelectedItem != None )
    {
            PC = R6PlayerCampaign(R6WindowListBoxItem(m_CampaignListBox.m_SelectedItem).m_Object);
            
            if( PC != None)
            {
                R6Console(Root.Console).m_PlayerCampaign = PC;
                return true;
            }
            else
                return false;
    }
    return false;
            
}

function Notify(UWindowDialogControl C, byte E)
{
    local R6PlayerCampaign PC;

    if( C == m_CampaignListBox && E == DE_CLICK)
    {
        if( m_CampaignListBox.m_SelectedItem != None )
        {
            PC = R6PlayerCampaign(R6WindowListBoxItem(m_CampaignListBox.m_SelectedItem).m_Object);
            
            if( PC != None)
                R6MenuSinglePlayerWidget(OwnerWindow).UpdateSelectedCampaign( PC );
        }
            
    }
}

defaultproperties
{
}
