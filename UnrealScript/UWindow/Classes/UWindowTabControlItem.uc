class UWindowTabControlItem extends UWindowList;

var string					Caption;
var string					HelpText;

var UWindowTabControl		Owner;

// border and text have the same color (selected or not)
var Color                   m_vSelectedColor;
var Color                   m_vNormalColor;

var FLOAT					TabTop;
var FLOAT					TabLeft;
var FLOAT					TabWidth;
var FLOAT					TabHeight;
var FLOAT                   m_fFixWidth;    // a fix size for the tab, by default 0 (the tab size equal the the text size in this case)

var INT						RowNumber;
var INT                     m_iItemID;

var bool					bFlash;
var bool                    m_bMouseOverItem;

function SetCaption(string NewCaption)
{
	Caption=NewCaption;
}

function RightClickTab()
{
}

function SetFixTabSize( FLOAT _fFixTabWidth)
{
    m_fFixWidth = _fFixTabWidth;
}

function SetItemColor( Color _vSelected, Color _vNormal)
{
    m_vSelectedColor = _vSelected;
    m_vNormalColor   = _vNormal;
}

defaultproperties
{
}
