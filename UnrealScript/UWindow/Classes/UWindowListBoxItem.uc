class UWindowListBoxItem extends UWindowList;

// struct for parameters for sub text under helptext
struct stSubTextBox
{
    var string          szGameTypeSelect;
	var FLOAT			fXOffset;
    var FLOAT           fHeight;				// the height of the section
    var Font            FontSubText;
};

struct stCoordItem
{
	var FLOAT			fXPos;
	var FLOAT			fWidth;
};

// new struct to set all properties for one item -- have to switch to this mode -- dynamic
struct stItemProperties
{
	var string			szText;
	var Font			TextFont;
	var FLOAT			fXPos;
	var FLOAT			fYPos;
	var FLOAT			fWidth;
	var FLOAT			fHeigth;
	var INT				iLineNumber;
	var TextAlign	    eAlignment;
};

var stSubTextBox    m_stSubText;			// if we need more than 1 sub text line, change this in a array

var array<stItemProperties> m_AItemProperties; // array of all properties of an item

var Color			m_vItemColor;			// the default item color

var string          HelpText;				// the text of the item (what's diplaying)
var string			m_szToolTip;			// the tooltipstring
// specific to input
var string			m_szFakeEditBoxValue;	// the value of the fake edit box to display
var string			m_szActionKey;			// the value of the action key in user.ini
//

var FLOAT			m_fXFakeEditBox;		// X pos , this is to fake and edit box -- see options/controls
var FLOAT			m_fWFakeEditBox;		// Width, this is to fake and edit box -- see options/controls

var INT				m_iFontIndex;			// the font see uwindowbase for value
var INT				m_iItemID;				// the item ID

var bool            bSelected;				// this item is selected or not
var bool            m_bUseSubText;			// use sub text -- and by the way sub text struct
var bool			m_bImALine;				// to draw a line at this item
var bool			m_bNotAffectByNotify;	// this item is not affected by notify
var BOOL			m_bDisabled;			// the item is disable but displaying

function int Compare(UWindowList T, UWindowList B)
{
	local string TS, BS;

	TS = UWindowListBoxItem(T).HelpText;
	BS = UWindowListBoxItem(B).HelpText;

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

//=====================================================================================
// ClearItem: clear the appropriate item values except the link with the list
//=====================================================================================
function ClearItem()
{
	bSelected = false;
	m_bShowThisItem = false;
}
function SetItemParameters( INT _Index, string _szText, Font _TextFont, FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH, INT _iLineNumber, OPTIONAL TextAlign _eAlignement)
{
	local stItemProperties stItemParam;

	if ( _Index <= m_AItemProperties.Length)
	{
		stItemParam.szText		= _szText;
		stItemParam.TextFont	= _TextFont;
		stItemParam.fXPos		= _fX;
		stItemParam.fYPos		= _fY;
		stItemParam.fWidth		= _fW;
		stItemParam.fHeigth		= _fH;
		stItemParam.iLineNumber	= _iLineNumber;
		stItemParam.eAlignment  = _eAlignement;

		m_AItemProperties[_Index] = stItemParam;
	}
}

defaultproperties
{
}
