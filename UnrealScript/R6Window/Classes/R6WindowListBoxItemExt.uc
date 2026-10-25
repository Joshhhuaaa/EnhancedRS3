class R6WindowListBoxItemExt extends UWindowListBoxItem;

struct stItemDesc
{
    var string    szText;
    var string    szMisc;
    var Font      TextFont;
    var FLOAT     fXPos;
    var FLOAT     fYPos;
    var FLOAT     fWidth;
    var FLOAT     fHeigth;
    var INT       iLineNumber;
    var TextAlign eAlignment;
    var BOOL      bDisplay;
};

var array<stItemDesc> m_AItemDesc;  // one description per text displayed in the item
var stItemDesc        m_DescTemp;   // set by SetItemDescriptionIndex

function ClearItem()
{
    log("+++++++++++++++++++++++++++++++++++++++++++++++ ClearItem()++++++++++++++++++++++++++++++");
    bSelected = false;
    m_bShowThisItem = false;
}

function SetItemParameters(INT _index, string _szText, Font _TextFont, FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH, INT _iLineNumber, optional TextAlign _eAlignement)
{
    local stItemDesc ItemDesc;

    if (_index <= m_AItemDesc.Length)
    {
        ItemDesc.szText      = _szText;
        ItemDesc.TextFont    = _TextFont;
        ItemDesc.fXPos       = _fX;
        ItemDesc.fYPos       = _fY;
        ItemDesc.fWidth      = _fW;
        ItemDesc.fHeigth     = _fH;
        ItemDesc.iLineNumber = _iLineNumber;
        ItemDesc.eAlignment  = _eAlignement;
        ItemDesc.bDisplay    = true;
        m_AItemDesc[_index] = ItemDesc;
    }
}

function SetItemParam(INT _index, stItemDesc _ItemParam)
{
    if (_index <= m_AItemDesc.Length)
        m_AItemDesc[_index] = _ItemParam;
}

function BOOL SetItemDescriptionIndex(INT _iIndex)
{
    if (_iIndex < m_AItemDesc.Length)
    {
        m_DescTemp = m_AItemDesc[_iIndex];
        return true;
    }
    return false;
}

function string GetItemText(INT _iIndex)
{
    if (_iIndex < m_AItemDesc.Length)
        return m_AItemDesc[_iIndex].szText;
    else
        return "";
}

function string GetItemMisc(INT _iIndex)
{
    if (_iIndex < m_AItemDesc.Length)
        return m_AItemDesc[_iIndex].szMisc;
    else
        return "";
}

function SetItemMisc(INT _index, string _szMisc)
{
    local stItemDesc ItemDesc;

    if (_index <= m_AItemDesc.Length)
    {
        ItemDesc = m_AItemDesc[_index];
        ItemDesc.szMisc = _szMisc;
        m_AItemDesc[_index] = ItemDesc;
    }
}

function SetItemText(INT _index, string _szText)
{
    local stItemDesc ItemDesc;

    if (_index <= m_AItemDesc.Length)
    {
        ItemDesc = m_AItemDesc[_index];
        ItemDesc.szText = _szText;
        m_AItemDesc[_index] = ItemDesc;
    }
}

function HideLine(INT _iLineNb)
{
    if (_iLineNb < m_AItemDesc.Length)
        m_AItemDesc[_iLineNb].bDisplay = false;
}

function INT Compare(UWindowList T, UWindowList B)
{
    local string TS, BS;

    TS = R6WindowListBoxItemExt(T).GetItemText(0);
    BS = R6WindowListBoxItemExt(B).GetItemText(0);

    // "NONE" is always first
    if (TS == "NONE")
        return -1;
    else if (BS == "NONE")
        return 1;

    if (TS == BS)
        return 0;

    if (TS < BS)
        return -1;

    return 1;
}
