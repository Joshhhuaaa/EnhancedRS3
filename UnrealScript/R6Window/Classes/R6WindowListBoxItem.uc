//=============================================================================
//  R6WindowListBoxItem.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/25 * Created by Alexandre Dionne
//=============================================================================


class R6WindowListBoxItem extends UWindowListBoxItem;

var texture	            m_Icon;
var region 	            m_IconRegion;
var region 	            m_IconSelectedRegion;   //To get icons to higlight when selected
var bool                m_IsSeparator;
var int                 m_iSeparatorID;         //To help manage insertions and removal of
                                                //items between Separators;
var bool                    m_addedToSubList;   //Item as been added to a sub List
var R6WindowListBoxItem     m_ParentListItem;   //Item from wich this one has been added to a sub list
var Object              m_Object;               //Object or actor associated with this element    

var string				m_szMisc;				// a misc purpose string

//If this functions returns None well it could'nt find the designated separator
function R6WindowListBoxItem AppendAfterSeparator(Class<R6WindowListBoxItem> C, int iSeparatorID)
{
	local UWindowList NewElement, tempItem;
    local R6WindowListBoxItem workItem;
	   
        
    //This is not cost effective
    tempItem = Next;
    while(tempItem != None && (NewElement == None))
    {
        workItem = R6WindowListBoxItem(tempItem);

        if( (workItem != None) &&  workItem.m_IsSeparator && (workItem.m_iSeparatorID == iSeparatorID) )    
            NewElement = workItem.InsertAfter(class'R6WindowListBoxItem');
        
        tempItem = tempItem.Next;
    }
        
	return R6WindowListBoxItem(NewElement);

}


//If this functions returns None well it could'nt find the designated separator
function R6WindowListBoxItem InsertLastAfterSeparator(Class<R6WindowListBoxItem> C, int iSeparatorID)
{
	local UWindowList NewElement, tempItem, LastItem;
    local R6WindowListBoxItem workItem, Separator;
    local bool bSeparatorFound;
	   
        
    //This is not cost effective
    //Finding the Separator First
    tempItem = Next;
    while(tempItem != None && (bSeparatorFound == false))
    {
        workItem = R6WindowListBoxItem(tempItem);

        if( (workItem != None) &&  workItem.m_IsSeparator && (workItem.m_iSeparatorID == iSeparatorID) )    
        {
            Separator       = workItem;
            bSeparatorFound = true;
        }    

        LastItem = tempItem;
        tempItem = tempItem.Next;
    }

    //Finding the right spot for insertion
    while(tempItem != None && R6WindowListBoxItem(tempItem).m_IsSeparator == false)
    {        
        LastItem = tempItem;
        tempItem = tempItem.Next;
    }


    NewElement = LastItem.InsertAfter(class'R6WindowListBoxItem');

        
	return R6WindowListBoxItem(NewElement);

}

//Call this on the sentinel
function int FindItemIndex(UWindowList item)
{
	local UWindowList l;
	local int i;

	l = Next;
	for(i=0; i < Count() ;i++) 
	{
        if(l==item) return i;
		l = l.Next;
		
	}
	return -1;
}

/*
function int Compare(UWindowList T, UWindowList B)
{
	local string TS, BS;

	TS = R6WindowListBoxItem(T).HelpText;
	BS = R6WindowListBoxItem(B).HelpText;

    if(TS == "NONE")
        return -1;
    else if ( BS == "NONE" )
        return 1;

	if(TS == BS)
		return 0;

	if(TS < BS)
		return -1;

	return 1;
}
*/

defaultproperties
{
}
