//=============================================================================
//  R6MenuDynTeamListsControl.uc : Control that will allow
//                                  Dynamic Selections of Team Rosters
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/21 * Created by Alexandre Dionne
//=============================================================================

///////////////////////////////////////////////////////////////////////////////
// Please take note that this control can not display right 
// If not initalized with th right size
///////////////////////////////////////////////////////////////////////////////

class R6MenuDynTeamListsControl extends UWindowDialogClientWindow;

var     R6WindowListBoxAnchorButton   m_AssaultButton;
var     R6WindowListBoxAnchorButton   m_ReconButton;
var     R6WindowListBoxAnchorButton   m_SniperButton;
var     R6WindowListBoxAnchorButton   m_DemolitionButton;
var     R6WindowListBoxAnchorButton   m_ElectronicButton;

var     Texture                         m_TButtonTexture;

var     Region                          m_RAssaultUp,    
                                        m_RAssaultOver,
                                        m_RAssaultDown,
                                        m_RAssaultDisabled,

                                        m_RReconUp,
                                        m_RReconOver,
                                        m_RReconDown,
                                        m_RReconDisabled,

                                        m_RSniperUp,
                                        m_RSniperOver,
                                        m_RSniperDown,
                                        m_RSniperDisabled,

                                        m_RDemolitionUp,
                                        m_RDemolitionOver,
                                        m_RDemolitionDown,
                                        m_RDemolitionDisabled,

                                        m_RElectronicUp,
                                        m_RElectronicOver,
                                        m_RElectronicDown,
                                        m_RElectronicDisabled;
var FLOAT                               m_fButtonTabWidth, m_fButtonTabHeight;

//Small icons in the list
var   Region                      RAssault, RRecon, RSniper, RDemo, RElectro;
var   Region                      RSAssault, RSRecon, RSSniper, RSDemo, RSElectro;



var     R6WindowTextIconsListBox		m_ListBox;
var     R6WindowTextIconsSubListBox		m_RedListBox,m_GreenListBox,m_GoldListBox;

var     int								m_SubListTopHeight;  //For size calculations == Top label and offset

var     Texture							m_BorderTexture;   
var     Region							m_BorderRegion;
var     float							m_MinSubListHeight, m_SubListByItemHeight, TotalSublistsHeight;


var     float							m_fVPadding;   //Vertical Padding Between Controls 
var     float							m_fFirsButtonOffset, m_fHButtonPadding, m_fHButtonOffset;

var     int								m_iMaxOperativeCount;

//Debug
var     bool                          bshowlog;

function Created()
{
  
    m_BorderTexture	= Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", class'Texture'));
    
    CreateAnchoredButtons();
    CreateRosterListBox();   
}


function Notify(UWindowDialogControl C, byte E)
{
    local int                           itemPos;
    local R6WindowListBoxItem           SelectedItem, ListItem;
    local UWindowList                   UListItem;
    local R6MenuGearWidget              gearWidget;
    local R6Operative                   selectedOperative;
    local R6WindowTextIconsSubListBox   tmpSubListBox;


    gearWidget = R6MenuGearWidget(OwnerWindow);

    if(E == DE_DoubleClick)
    {
        switch(C)		
        {
            //Operatives returns to th main List               
        case m_RedListBox.m_listBox:
        case m_GreenListBox.m_listBox:
        case m_GoldListBox.m_listBox:      
            
                tmpSubListBox = R6WindowTextIconsSubListBox(C.OwnerWindow);

                SelectedItem = R6WindowListBoxItem(tmpSubListBox.m_listBox.m_SelectedItem);
                
				if (SelectedItem != None) // in case of a empty list
				{
					//This is to select the next operative in the team we are remove the current selected operative
					if( SelectedItem.Next != none)
						ListItem = R6WindowListBoxItem(SelectedItem.Next);
					else if( SelectedItem.Prev != tmpSubListBox.m_listBox.Items ) //make sure there is an element
					{
						ListItem = R6WindowListBoxItem(SelectedItem.Prev);
					}
                    

					RemoveOperativeInSubList(tmpSubListBox);
					if(ListItem != none)
						tmpSubListBox.m_listBox.SetSelectedItem(ListItem);
					RefreshButtons();
					ResizeSubLists();
				}
            break;        

        case m_ListBox  :                                
            //AddOperativeToSubList will make sure we don't add to many operative
            if( m_RedListBox.m_listBox.Items.Count() < m_RedListBox.m_maxItemsCount )
                AddOperativeToSubList(m_RedListBox);
            else if ( m_GreenListBox.m_listBox.Items.Count() < m_GreenListBox.m_maxItemsCount )
                AddOperativeToSubList(m_GreenListBox);
            else
                AddOperativeToSubList(m_GoldListBox);

            RefreshButtons();
            ResizeSubLists();
            break;
        }
    }
	else if(E == DE_Click)
	{
        if(bShowLog)log("R6MenuDynTeamListsControl Notify DE_Click");
		switch(C)
		{
            //Cases for the link buttons
		case m_AssaultButton:
        case m_ReconButton:
        case m_SniperButton:						
        case m_DemolitionButton:
        case m_ElectronicButton:

            itemPos =  R6WindowListBoxItem(m_ListBox.Items).FindItemIndex(R6WindowListBoxAnchorButton(C).AnchoredElement);
            if(itemPos >= 0)
            {
                m_ListBox.m_VertSB.Pos = 0;         
                
                //Position the scroll bar on the element desired
                m_ListBox.m_VertSB.Scroll(itemPos);

                //Select The first Operative after
                m_ListBox.SetSelectedItem(UWindowListBoxItem(R6WindowListBoxItem(m_ListBox.Items).FindEntry(itemPos+1)));   

            }
        
		break;
        //Making a list selection
        case m_RedListBox.m_listBox:        
                
                selectedOperative = R6Operative(R6WindowListBoxItem(m_RedListBox.m_listbox.m_SelectedItem).m_Object);
                if((gearWidget != None) && (selectedOperative != None))                     
                    gearWidget.OperativeSelected(selectedOperative, Red_Team, m_RedListBox.m_listBox);

                m_GreenListBox.m_listBox.DropSelection();                
                m_GoldListBox.m_listBox.DropSelection();                
                m_listBox.DropSelection();
                RefreshButtons();
            break;

        case m_GreenListBox.m_listBox:

                selectedOperative = R6Operative(R6WindowListBoxItem(m_GreenListBox.m_listbox.m_SelectedItem).m_Object);
                if((gearWidget != None) && (selectedOperative != None))                     
                    gearWidget.OperativeSelected(selectedOperative, Green_Team, m_GreenListBox.m_listBox);

                m_RedListBox.m_listBox.DropSelection();                
                m_GoldListBox.m_listBox.DropSelection();                
                m_listBox.DropSelection();
                RefreshButtons();
            break;        

        case m_GoldListBox.m_listBox:                
                
                selectedOperative = R6Operative(R6WindowListBoxItem(m_GoldListBox.m_listbox.m_SelectedItem).m_Object);
                if((gearWidget != None) && (selectedOperative != None))                     
                    gearWidget.OperativeSelected(selectedOperative, Gold_Team, m_GoldListBox.m_listBox);

                m_GreenListBox.m_listBox.DropSelection();                
                m_RedListBox.m_listBox.DropSelection();                
                m_listBox.DropSelection();
                RefreshButtons();
            break;        

        case m_ListBox  :                
                selectedOperative = R6Operative(R6WindowListBoxItem(m_listbox.m_SelectedItem).m_Object);
                if((gearWidget != None) && (selectedOperative != None))                     
                    gearWidget.OperativeSelected(selectedOperative, No_Team, m_ListBox);

                m_RedListBox.m_listBox.DropSelection();                
                m_GreenListBox.m_listBox.DropSelection();                
                m_GoldListBox.m_listBox.DropSelection();                
                RefreshButtons();

            break;

        case m_RedListBox.m_AddButton:                                          
        case m_GreenListBox.m_AddButton:        
        case m_GoldListBox.m_AddButton:                                          
                AddOperativeToSubList(R6WindowTextIconsSubListBox(C.OwnerWindow));                
                RefreshButtons();
                ResizeSubLists();
            break;
        case m_RedListBox.m_RemoveButton:                  
        case m_GreenListBox.m_RemoveButton:                                
        case m_GoldListBox.m_RemoveButton:  

                tmpSubListBox = R6WindowTextIconsSubListBox(C.OwnerWindow);
                SelectedItem = R6WindowListBoxItem(tmpSubListBox.m_listBox.m_SelectedItem);
                
                //This is to select the next operative in the team we are remove the current selected operative
                if( SelectedItem.Next != none)
                    ListItem = R6WindowListBoxItem(SelectedItem.Next);
                else if( SelectedItem.Prev != tmpSubListBox.m_listBox.Items ) //make sure there is an element
                {
                    ListItem = R6WindowListBoxItem(SelectedItem.Prev);
                }
                    

                RemoveOperativeInSubList(tmpSubListBox);
                if(ListItem != none)
                    tmpSubListBox.m_listBox.SetSelectedItem(ListItem);
                RefreshButtons();
                ResizeSubLists();
            break;
            
        case m_RedListBox.m_UpButton:                          
        case m_GreenListBox.m_UpButton:                
        case m_GoldListBox.m_UpButton:
            SelectedItem = R6WindowListBoxItem(R6WindowTextIconsSubListBox(C.OwnerWindow).m_listBox.m_SelectedItem);
            UListItem = SelectedItem.Prev;
            SelectedItem.Remove();
            UListItem.InsertItemBefore(SelectedItem);
            RefreshButtons();
            break;

        case m_RedListBox.m_DownButton:                          
        case m_GreenListBox.m_DownButton:                
        case m_GoldListBox.m_DownButton:
            SelectedItem = R6WindowListBoxItem(R6WindowTextIconsSubListBox(C.OwnerWindow).m_listBox.m_SelectedItem);
            UListItem = SelectedItem.Next;
            SelectedItem.Remove();
            UListItem.InsertItemAfter(SelectedItem);
            RefreshButtons();
            break;

		}
	}
}

//Remove an Item from a SubList
function RemoveOperativeInSubList(R6WindowTextIconsSubListBox _SubListBox)
{
    local R6WindowListBoxItem           SelectedItem;
    local R6Operative                   selectedOperative;
    local R6MenuGearWidget              gearWidget;

    gearWidget = R6MenuGearWidget(OwnerWindow);
    
    SelectedItem = R6WindowListBoxItem(_SubListBox.m_listBox.m_SelectedItem);
    if((SelectedItem != None) && (SelectedItem.m_ParentListItem != None))
    {
        _SubListBox.m_listBox.DropSelection();
        SelectedItem.m_ParentListItem.m_addedToSubList   = false;
        SelectedItem.Remove();                            
        m_ListBox.SetSelectedItem(SelectedItem.m_ParentListItem);
        selectedOperative = R6Operative(SelectedItem.m_Object);
        gearWidget.OperativeSelected(selectedOperative, No_Team);

    }       
}

//Adding an item to a sub list
function AddOperativeToSubList(R6WindowTextIconsSubListBox _SubListBox)
{
    local int                           totalCount;
    local R6WindowListBoxItem           TempItem , SelectedItem;
    local R6Operative                   selectedOperative;
    local R6MenuGearWidget              gearWidget;
    local bool                          bfound;

    //Let's try adding an operative to a sub List
    gearWidget = R6MenuGearWidget(OwnerWindow);

    //Before adding An op to a sub list make sur he's not in another sub list
    // if so remove him from there
    if( gearWidget.m_currentOperativeTeam == Red_Team)
            RemoveOperativeInSubList(m_RedListBox);

    else if( gearWidget.m_currentOperativeTeam == Green_Team)
            RemoveOperativeInSubList(m_GreenListBox);

    else if( gearWidget.m_currentOperativeTeam == Gold_Team)
            RemoveOperativeInSubList(m_GoldListBox);

    
    totalCount =  m_RedListBox.m_listBox.Items.Count() + 
        m_GreenListBox.m_listBox.Items.Count() + 
        m_GoldListBox.m_listBox.Items.Count();
    
    if(bshowlog) //Debug
    {
        log("m_RedListBox count :"@m_RedListBox.m_listBox.Items.Count());
        log("m_GreenListBox count :"@m_GreenListBox.m_listBox.Items.Count());
        log("m_GoldListBox count :"@m_GoldListBox.m_listBox.Items.Count());
        if(_SubListBox == m_RedListBox)
            log("m_RedListBox Adding operative");
        if(_SubListBox == m_GreenListBox)
            log("m_GreenListBox Adding operative");
        if(_SubListBox == m_GoldListBox)
            log("m_GoldListBox Adding Operative");
    }            
    
    SelectedItem = R6WindowListBoxItem(m_listbox.m_SelectedItem);
    if( (totalCount < m_iMaxOperativeCount) && (SelectedItem != None) 
        && ( SelectedItem.m_addedToSubList == false ) 
        && (_SubListBox.m_listBox.Items.Count() < _SubListBox.m_maxItemsCount) )
    {
       TempItem = R6WindowListBoxItem(_SubListBox.m_listBox.Items.Append( class'R6WindowListBoxItem'));
       if( (TempItem != None))
        {
            TempItem.m_Icon                 = SelectedItem.m_Icon;
            TempItem.m_IconRegion           = SelectedItem.m_IconRegion;
            TempItem.m_IconSelectedRegion   = SelectedItem.m_IconSelectedRegion;
            TempItem.HelpText               = SelectedItem.HelpText;
            TempItem.m_ParentListItem       = SelectedItem;
            TempItem.m_Object               = SelectedItem.m_Object;
            SelectedItem.m_addedToSubList   = true;
            m_listBox.DropSelection();
            _SubListBox.m_ListBox.SetSelectedItem(TempItem);

            selectedOperative = R6Operative(SelectedItem.m_Object);
            if(_SubListBox == m_RedListBox)
                gearWidget.OperativeSelected(selectedOperative, Red_Team);
            else if(_SubListBox == m_GreenListBox)
                gearWidget.OperativeSelected(selectedOperative, Green_Team);
            else //(C == m_GoldListBox.m_AddButton)
                gearWidget.OperativeSelected(selectedOperative, Gold_Team);
        }
    }
    else if(bshowlog)
        log(totalCount@"<"@m_iMaxOperativeCount);

    //Let's try to select the next availlable operative in the main list

    TempItem = SelectedItem;
    while(TempItem != none && bfound == false)
    {
        if( (TempItem.m_isSeparator == false) && (TempItem.m_addedToSubList == false) )
        {
            m_ListBox.SetSelectedItem(TempItem);
            m_ListBox.MakeSelectedVisible();
            bfound = true;
        }
        else
            TempItem = R6WindowListBoxItem(TempItem.next);
    }
}


function RefreshButtons()
{
        local   int                         iShowAdd, totalCount;
        local   R6WindowListBoxItem         SelectedItem;
        local R6MenuGearWidget              gearWidget;

        
        gearWidget = R6MenuGearWidget(OwnerWindow);
        
        //Let's update the buttons with the right states
    
        totalCount =  m_RedListBox.m_listBox.Items.Count() + 
                    m_GreenListBox.m_listBox.Items.Count() + 
                    m_GoldListBox.m_listBox.Items.Count();

        switch(gearWidget.m_currentOperativeTeam)
        {
        case No_Team: //The selected operative is in the main list
            
                if(totalCount < m_iMaxOperativeCount)
                    iShowAdd =1; //Display Add Buttom
                else    
                    iShowAdd =0; //don't display Add Buttom
                
                m_RedListBox.UpdateButtons(iShowAdd);      
                m_GreenListBox.UpdateButtons(iShowAdd);    
                m_GoldListBox.UpdateButtons(iShowAdd);     
            break;
        case Red_Team:
                m_RedListBox.UpdateButtons(0);      
                m_GreenListBox.UpdateButtons(1);    
                m_GoldListBox.UpdateButtons(1);     
            break;
        case Green_Team:
                m_RedListBox.UpdateButtons(1);      
                m_GreenListBox.UpdateButtons(0);    
                m_GoldListBox.UpdateButtons(1);     
            break;
        case Gold_Team:
                m_RedListBox.UpdateButtons(1);      
                m_GreenListBox.UpdateButtons(1);    
                m_GoldListBox.UpdateButtons(0);     
            break;
        }




}

function CreateRosterListBox()
{
    local   color                       co;    
    local   font                        listBoxTitleFont;
    
   
    listBoxTitleFont = Root.Fonts[F_ListItemBig]; 

    m_ListBox           = R6WindowTextIconsListBox(CreateControl(class'R6WindowTextIconsListBox', 0, m_ElectronicButton.Wintop + m_ElectronicButton.WinHeight, WinWidth, 143, self));
	m_ListBox.ToolTipString			   = Localize("Tip","GearRoomOpListBox","R6Menu");
	m_ListBox.m_SeparatorTextColor	   = Root.Colors.BlueLight;
	m_ListBox.m_BorderColor			   = Root.Colors.GrayLight;
    m_listBox.m_IgnoreAllreadySelected = false;
    m_listBox.m_VertSB.SetEffect(true);
    
    m_RedListBox        = R6WindowTextIconsSubListBox(CreateControl(class'R6WindowTextIconsSubListBox', 0, m_ListBox.Wintop + m_ListBox.WinHeight + m_fVPadding, WinWidth, 47, self));
    m_GreenListBox      = R6WindowTextIconsSubListBox(CreateControl(class'R6WindowTextIconsSubListBox', 0, m_RedListBox.Wintop + m_RedListBox.WinHeight + m_fVPadding, WinWidth, 47, self));
    m_GoldListBox       = R6WindowTextIconsSubListBox(CreateControl(class'R6WindowTextIconsSubListBox', 0, m_GreenListBox.Wintop + m_GreenListBox.WinHeight + m_fVPadding, WinWidth, 73, self));
   
      
    m_RedListBox.m_ListBox.SetScrollable(false);
    m_GreenListBox.m_ListBox.SetScrollable(false);
    m_GoldListBox.m_ListBox.SetScrollable(false);
    
    
    
    m_RedListBox.SetColor(Root.Colors.TeamColor[0]); //Root.Colors.Red;
    m_GreenListBox.SetColor(Root.Colors.TeamColor[1]); //Root.Colors.Green;    
    m_GoldListBox.SetColor(Root.Colors.TeamColor[2]); //Root.Colors.Gold;

        		
    Co = Root.Colors.White;

    
	m_RedListBox.m_Title.Align = TA_Center;
	m_RedListBox.m_Title.m_Font = listBoxTitleFont;
	m_RedListBox.m_Title.TextColor = Co;
    m_RedListBox.m_Title.SetNewText(Localize("GearRoom","team1","R6Menu"), true);

    
	m_GreenListBox.m_Title.Align = TA_Center;
	m_GreenListBox.m_Title.m_Font = listBoxTitleFont;
	m_GreenListBox.m_Title.TextColor = Co;
    m_GreenListBox.m_Title.SetNewText(Localize("GearRoom","team2","R6Menu"), true);

	m_GoldListBox.m_Title.Align = TA_Center;
	m_GoldListBox.m_Title.m_Font = listBoxTitleFont;
	m_GoldListBox.m_Title.TextColor = Co;
    m_GoldListBox.m_Title.SetNewText(Localize("GearRoom","team3","R6Menu"), true);
    
    m_RedListBox.SetTip(Localize("Tip","GearRoomRedListBox","R6Menu"));
    m_GreenListBox.SetTip(Localize("Tip","GearRoomGreenListBox","R6Menu"));     
    m_GoldListBox.SetTip(Localize("Tip","GearRoomGoldListBox","R6Menu"));
}

function CreateAnchoredButtons()
{    
    
    m_AssaultButton     = R6WindowListBoxAnchorButton(CreateControl(class'R6WindowListBoxAnchorButton', m_fFirsButtonOffset, m_fHButtonOffset, m_fButtonTabWidth, m_fButtonTabHeight));    
	m_AssaultButton.ToolTipString   = Localize("Tip","GearRoomButAssault","R6Menu");
    m_AssaultButton.UpRegion        = m_RAssaultUp;    
    m_AssaultButton.OverRegion      = m_RAssaultOver;    
    m_AssaultButton.DownRegion      = m_RAssaultDown;
    m_AssaultButton.DisabledRegion  = m_RAssaultDisabled;
    m_AssaultButton.m_iDrawStyle    =5; //STY_Alpha  
   
    m_ReconButton       = R6WindowListBoxAnchorButton(CreateControl(class'R6WindowListBoxAnchorButton', m_AssaultButton.WinLeft + m_AssaultButton.WinWidth + m_fHButtonPadding, m_AssaultButton.WinTop, m_AssaultButton.WinWidth, m_AssaultButton.WinHeight));    
	m_ReconButton.ToolTipString   = Localize("Tip","GearRoomButRecon","R6Menu");
    m_ReconButton.UpRegion        = m_RReconUp;    
    m_ReconButton.OverRegion      = m_RReconOver;    
    m_ReconButton.DownRegion      = m_RReconDown;
    m_ReconButton.DisabledRegion  = m_RReconDisabled;
    m_ReconButton.m_iDrawStyle    =5; //STY_Alpha

    m_SniperButton      = R6WindowListBoxAnchorButton(CreateControl(class'R6WindowListBoxAnchorButton', m_ReconButton.WinLeft + m_ReconButton.WinWidth + m_fHButtonPadding, m_AssaultButton.WinTop,  m_AssaultButton.WinWidth, m_AssaultButton.WinHeight));    
	m_SniperButton.ToolTipString   = Localize("Tip","GearRoomButSniper","R6Menu");
    m_SniperButton.UpRegion        = m_RSniperUp;    
    m_SniperButton.OverRegion      = m_RSniperOver;    
    m_SniperButton.DownRegion      = m_RSniperDown;
    m_SniperButton.DisabledRegion  = m_RSniperDisabled;
    m_SniperButton.m_iDrawStyle    =5; //STY_Alpha

    m_DemolitionButton  = R6WindowListBoxAnchorButton(CreateControl(class'R6WindowListBoxAnchorButton', m_SniperButton.WinLeft + m_SniperButton.WinWidth + m_fHButtonPadding, m_AssaultButton.WinTop,  m_AssaultButton.WinWidth, m_AssaultButton.WinHeight));    
	m_DemolitionButton.ToolTipString   = Localize("Tip","GearRoomButDemol","R6Menu");
    m_DemolitionButton.UpRegion        = m_RDemolitionUp;    
    m_DemolitionButton.OverRegion      = m_RDemolitionOver;    
    m_DemolitionButton.DownRegion      = m_RDemolitionDown;
    m_DemolitionButton.DisabledRegion  = m_RDemolitionDisabled;
    m_DemolitionButton.m_iDrawStyle    =5; //STY_Alpha

    m_ElectronicButton  = R6WindowListBoxAnchorButton(CreateControl(class'R6WindowListBoxAnchorButton', m_DemolitionButton.WinLeft + m_DemolitionButton.WinWidth + m_fHButtonPadding, m_AssaultButton.WinTop,  m_AssaultButton.WinWidth, m_AssaultButton.WinHeight));    
	m_ElectronicButton.ToolTipString   = Localize("Tip","GearRoomButElec","R6Menu");
    m_ElectronicButton.UpRegion        = m_RElectronicUp;    
    m_ElectronicButton.OverRegion      = m_RElectronicOver;    
    m_ElectronicButton.DownRegion      = m_RElectronicDown;
    m_ElectronicButton.DisabledRegion  = m_RElectronicDisabled;
    m_ElectronicButton.m_iDrawStyle    =5; //STY_Alpha

}

function FillRosterList()
{

    local   R6WindowListBoxItem         TempItem;
    local   texture                     ButtonTexture;
    local   region                      R, RS;   

    local   int                         i, SeparatorID, iUniqueID;

    local R6MenuRootWindow              R6Root;
    local R6Operative                   tmpOperative;
    local R6MenuGearWidget              gearWidget;
        

    local bool                          found;

    
    ButtonTexture = Texture(DynamicLoadObject("R6MenuTextures.Tab_Icon00", class'Texture'));
    R6Root = R6MenuRootWindow(Root);
    gearWidget = R6MenuGearWidget(OwnerWindow);

	m_iMaxOperativeCount = 	R6GameInfo(GetLevel().Game).m_iMaxOperatives;

    //Make sure everything is empty first
    EmptyRosterList();

     //Filling the separators first
        
    TempItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    TempItem.HelpText       = Localize("GearRoom","ButtonAssault","R6Menu");
    TempItem.m_IsSeparator  = true;
    TempItem.m_iSeparatorID =1;
    m_AssaultButton.AnchoredElement     = TempItem;

    TempItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    TempItem.HelpText       = Localize("GearRoom","ButtonSniper","R6Menu");
    TempItem.m_IsSeparator  = true;
    TempItem.m_iSeparatorID =2;
    m_SniperButton.AnchoredElement      = TempItem;

    TempItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    TempItem.HelpText       = Localize("GearRoom","ButtonDemolition","R6Menu");
    TempItem.m_IsSeparator  = true;
    TempItem.m_iSeparatorID =3;
    m_DemolitionButton.AnchoredElement  = TempItem;

        TempItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    TempItem.HelpText       = Localize("GearRoom","ButtonElectronic","R6Menu");
    TempItem.m_IsSeparator  = true;
    TempItem.m_iSeparatorID =4;
    m_ElectronicButton.AnchoredElement  = TempItem;

    TempItem                = R6WindowListBoxItem( m_ListBox.Items.Append( class'R6WindowListBoxItem'));
    TempItem.HelpText       = Localize("GearRoom","ButtonRecon","R6Menu");
    TempItem.m_IsSeparator  = true;
    TempItem.m_iSeparatorID =5;
    m_ReconButton.AnchoredElement       = TempItem;   

    




    if(bshowlog)
    {
        log("R6MenuDynTeamListsControl:FillRosterListBox");
        log("m_ListBox.Items.Count()"@m_ListBox.Items.Count());
        log("R6Root.m_GameOperatives.Length"@R6Root.m_GameOperatives.Length);
    }
    
	iUniqueID = -1;
    for(i=0; i< R6Root.m_GameOperatives.Length; i++)
    {
        tmpOperative  = R6Root.m_GameOperatives[i];
        if(bshowlog)
        log("tmpOperative"@tmpOperative);
        if(tmpOperative != None)
        {
			iUniqueID+=1;
			if (tmpOperative.m_iUniqueID == -1)
			{
				// it's a rookie, the UniqueID is not save in campaign file, only in planning (.pln)!
				tmpOperative.m_iUniqueID = iUniqueID; // the array is sequential, so just add iUniqueID
			}

           //This makes me thinks maybe this Id should be a numeric value
            if(tmpOperative.m_szSpecialityID == "ID_ASSAULT")
            {
                R=RAssault;
                RS=RSAssault;
                SeparatorID=1;
            }
               else if(tmpOperative.m_szSpecialityID == "ID_SNIPER")
            {
                R=RSniper;
                RS=RSSniper;
                SeparatorID=2;

            }
            else if(tmpOperative.m_szSpecialityID == "ID_DEMOLITIONS")
            {
                R=RDemo;
                RS=RSDemo;
                SeparatorID=3;

            }
            else if(tmpOperative.m_szSpecialityID == "ID_ELECTRONICS")
            {
                R=RElectro;
                RS=RSElectro;
                SeparatorID=4;

            }
            else if(tmpOperative.m_szSpecialityID == "ID_RECON")
            {
                R=RRecon;
                RS=RSRecon;
                SeparatorID=5;

            }                 
          

            TempItem = R6WindowListBoxItem(m_ListBox.Items).InsertLastAfterSeparator( class'R6WindowListBoxItem', SeparatorID);
            if(TempItem != None)
            {
                TempItem.m_Icon = ButtonTexture;        
                TempItem.m_IconRegion           = R;
                TempItem.m_IconSelectedRegion   = RS; 
                TempItem.HelpText = tmpOperative.GetName();
                //Check Health Status
                if(tmpOperative.m_iHealth > 1)
                    TempItem.m_addedToSubList = true;
                TempItem.m_Object = tmpOperative; 
                gearWidget.SetupOperative(tmpOperative);
                
            }        
        }
    }   
    
    //Set First Operative in list selected
    TempItem = R6WindowListBoxItem(m_ListBox.Items.Next);
    while(TempItem != None && found == false)
    {
        if(TempItem.m_IsSeparator  == false)
        {              
           //Select The first Operative after           
           m_ListBox.SetSelectedItem(TempItem);
           m_ListBox.MakeSelectedVisible();
           
           found = true;
        }
        else
        {           
            TempItem = R6WindowListBoxItem(TempItem.Next);
    
        }
    }   

}

function EmptyRosterList()
{
    
    m_ListBox.Items.Clear();
    m_RedListBox.m_ListBox.Items.Clear();
    m_GreenListBox.m_ListBox.Items.Clear();
    m_GoldListBox.m_ListBox.Items.Clear();

}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{

    R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, m_ListBox.WinLeft,m_ListBox.Wintop, m_ListBox.WinWidth, m_ListBox.WinHeight);

    C.Style = ERenderStyle.STY_Alpha;    
	C.SetDrawColor( Root.Colors.GrayLight.R, Root.Colors.GrayLight.G, Root.Colors.GrayLight.B);

    //Top
    DrawStretchedTextureSegment(C, 0, 0, WinWidth, m_BorderRegion.H , m_BorderRegion.X, m_BorderRegion.Y, m_BorderRegion.W, m_BorderRegion.H, m_BorderTexture);
    //Bottom
    DrawStretchedTextureSegment(C, 0, m_AssaultButton.WinHeight + m_AssaultButton.WinTop, WinWidth, m_BorderRegion.H , m_BorderRegion.X, m_BorderRegion.Y, m_BorderRegion.W, m_BorderRegion.H, m_BorderTexture);
    //Left
    DrawStretchedTextureSegment(C, 0, 0, m_BorderRegion.W, m_AssaultButton.WinHeight + m_fHButtonOffset, m_BorderRegion.X, m_BorderRegion.Y, m_BorderRegion.W, m_BorderRegion.H, m_BorderTexture);
    //Right
    DrawStretchedTextureSegment(C, WinWidth-m_BorderRegion.W, 0, m_BorderRegion.W, m_AssaultButton.WinHeight +m_fHButtonOffset, m_BorderRegion.X, m_BorderRegion.Y, m_BorderRegion.W, m_BorderRegion.H, m_BorderTexture);


}

function ResizeSubLists()
{
	local INT iRedListBoxH, iGreenListBoxH, iGoldListBoxH;
	local INT iAddSpace, iMaxListHeigth, iAvailableSpace;

	// max size of a list
	iMaxListHeigth = (4 * m_SubListByItemHeight) + m_SubListTopHeight;

	// current size of each list
	iRedListBoxH   = (m_RedListBox.m_listBox.Items.Count()   * m_SubListByItemHeight) + m_SubListTopHeight;
	iGreenListBoxH = (m_GreenListBox.m_listBox.Items.Count() * m_SubListByItemHeight) + m_SubListTopHeight;
	iGoldListBoxH  = (m_GoldListBox.m_listBox.Items.Count()  * m_SubListByItemHeight) + m_SubListTopHeight;

	// calculate the space available to add item
	iAvailableSpace = TotalSublistsHeight - Min( iRedListBoxH + iGreenListBoxH + iGoldListBoxH, TotalSublistsHeight);

	// distribute the space between each list
	while( iAvailableSpace != 0)
	{
		// add available space equally between the 3 list
		iAddSpace = (iAvailableSpace/3);
		iAvailableSpace = iAvailableSpace - (3 * iAddSpace);

		if (iAddSpace == 0)
		{
			iAddSpace = iAvailableSpace; // less than 3 spaces
			iAvailableSpace = 0;

			iAddSpace = DistributeSpaces( iAddSpace, iRedListBoxH, iMaxListHeigth);
			iAddSpace = DistributeSpaces( iAddSpace, iGreenListBoxH, iMaxListHeigth);
			iAddSpace = DistributeSpaces( iAddSpace, iGoldListBoxH, iMaxListHeigth);
		}
		else
		{
			iAvailableSpace += DistributeSpaces( iAddSpace, iRedListBoxH, iMaxListHeigth);
			iAvailableSpace += DistributeSpaces( iAddSpace, iGreenListBoxH, iMaxListHeigth);
			iAvailableSpace += DistributeSpaces( iAddSpace, iGoldListBoxH, iMaxListHeigth);
		}
	}

    m_RedListBox.SetSize(m_RedListBox.Winwidth, iRedListBoxH);
    
    m_GreenListBox.Wintop = m_RedListBox.Wintop + m_RedListBox.WinHeight + m_fVPadding;
    m_GreenListBox.SetSize(m_GreenListBox.Winwidth, iGreenListBoxH);
    
    m_GoldListBox.Wintop = m_GreenListBox.Wintop + m_GreenListBox.WinHeight + m_fVPadding;
    m_GoldListBox.SetSize(m_GoldListBox.Winwidth, iGoldListBoxH);

    if(bshowlog)
    {
        log("//////////////////////////////////////////////////////");
        log("// R6MenuDynTeamListsControl.ResizeSubLists()");
        log("//m_RedListBox.WinHeight"@m_RedListBox.WinHeight);
        log("//m_GoldListBox.WinHeight"@m_GoldListBox.WinHeight);
        log("//m_GreenListBox.WinHeight"@m_GreenListBox.WinHeight);
        log("//yo "@WinHeight - TotalSublistsHeight - m_AssaultButton.WinHeight + m_fHButtonOffset - m_ListBox.WinHeight);
        log("//////////////////////////////////////////////////////");
    }
}

function INT DistributeSpaces( INT _iSpaceToAdd, out INT _iHList, INT _iMaxListHeigth)
{
	local INT iSpaceLeft;

	if ( _iHList + _iSpaceToAdd > _iMaxListHeigth)
	{
		iSpaceLeft = _iSpaceToAdd - (_iMaxListHeigth - _iHList);
		_iHList = _iMaxListHeigth;
	}
	else
	{
		_iHList += _iSpaceToAdd;
	}

	return iSpaceLeft;
}

defaultproperties
{
     m_SubListTopHeight=20
     m_iMaxOperativeCount=8
     m_fButtonTabWidth=37.000000
     m_fButtonTabHeight=20.000000
     m_MinSubListHeight=47.000000
     m_SubListByItemHeight=13.000000
     TotalSublistsHeight=167.000000
     m_fVPadding=2.000000
     m_fFirsButtonOffset=3.000000
     m_fHButtonPadding=2.000000
     m_fHButtonOffset=3.000000
     m_RASSAULTUp=(W=37,H=20)
     m_RASSAULTOver=(Y=21,W=37,H=20)
     m_RASSAULTDown=(Y=42,W=37,H=20)
     m_RAssaultDisabled=(Y=42,W=37,H=20)
     m_RReconUp=(X=114,W=37,H=20)
     m_RReconOver=(X=114,Y=21,W=37,H=20)
     m_RReconDown=(X=114,Y=42,W=37,H=20)
     m_RReconDisabled=(X=114,Y=42,W=37,H=20)
     m_RSNIPERUp=(X=152,W=37,H=20)
     m_RSNIPEROver=(X=152,Y=21,W=37,H=20)
     m_RSNIPERDown=(X=152,Y=42,W=37,H=20)
     m_RSniperDisabled=(X=152,Y=42,W=37,H=20)
     m_RDemolitionUp=(X=38,W=37,H=20)
     m_RDemolitionOver=(X=38,Y=21,W=37,H=20)
     m_RDemolitionDown=(X=38,Y=42,W=37,H=20)
     m_RDemolitionDisabled=(X=38,Y=42,W=37,H=20)
     m_RElectronicUp=(X=76,W=37,H=20)
     m_RElectronicOver=(X=76,Y=21,W=37,H=20)
     m_RElectronicDown=(X=76,Y=42,W=37,H=20)
     m_RElectronicDisabled=(X=76,Y=42,W=37,H=20)
     RAssault=(X=229,W=9,H=9)
     RRecon=(X=239,Y=20,W=9,H=9)
     RSniper=(X=229,Y=40,W=9,H=9)
     RDemo=(X=239,W=9,H=9)
     RElectro=(X=229,Y=20,W=9,H=9)
     RSAssault=(X=229,Y=10,W=9,H=9)
     RSRecon=(X=239,Y=30,W=9,H=9)
     RSSniper=(X=229,Y=50,W=9,H=9)
     RSDemo=(X=239,Y=10,W=9,H=9)
     RSElectro=(X=229,Y=30,W=9,H=9)
     m_BorderRegion=(X=64,Y=56,W=1,H=1)
}
