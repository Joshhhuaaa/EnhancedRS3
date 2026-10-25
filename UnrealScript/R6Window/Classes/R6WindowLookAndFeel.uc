//=============================================================================
//  R6WindowLookAndFeel.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowLookAndFeel extends UWindowLookAndFeel;

var RegionButton    m_SBUp;
var RegionButton    m_SBDown;
var RegionButton    m_SBRight;
var RegionButton    m_SBLeft;
var Region	        m_SBBackground;


//R6ScrollBar

var texture m_R6ScrollTexture;
var Region m_SBVBorder;
var Region m_SBHBorder;
var Region m_SBScroller;


var Region	m_CloseBoxUp;
var Region	m_CloseBoxDown;
var INT		m_iCloseBoxOffsetX;
var INT		m_iCloseBoxOffsetY;

var INT     m_iListHPadding, m_iListVPadding;
var INT     m_iSize_ScrollBarFrameW;
var INT     m_iVScrollerWidth, m_iScrollerOffset;

//CheckBox and Radio Buttons
var Texture m_TButtonBackGround; 
var Region  m_RButtonBackGround;
var Color  m_CBorder;


function List_DrawBackground(UWindowListControl W, Canvas C);
function R6List_DrawBackground(R6WindowListBox W, Canvas C);
function DrawWinTop(R6WindowHSplitter W, Canvas C);
function DrawHSplitterT(R6WindowHSplitter W, Canvas C);
function DrawHSplitterB(R6WindowHSplitter W, Canvas C);
function Texture R6GetTexture(R6WindowFramedWindow W);
function R6FW_DrawWindowFrame(R6WindowFramedWindow W, Canvas C);
function R6FW_SetupFrameButtons(R6WindowFramedWindow W, Canvas C);
function Region R6FW_GetClientArea(R6WindowFramedWindow W);
function DrawSpecialButtonBorder(R6WindowButton B, Canvas C, FLOAT X, FLOAT Y);
function DrawButtonBorder(UWindowWindow W, Canvas C, optional bool _bDefineBorderColor);
function FrameHitTest R6FW_HitTest(R6WindowFramedWindow W, float X, float Y);
function DrawPopUpFrameWindow( R6WindowPopUpBox W, Canvas C);
function Button_SetupEnumSignChoice(UWindowButton W, INT eRegionId);
function DrawBox(UWindowWindow W, Canvas C, float X, float Y, float Width, float Height);
function DrawBGShading(UWindowWindow W, Canvas C, float X, float Y, float Width, float Height);
function DrawInGamePlayerStats( UWindowWindow W, Canvas C, INT _iPlayerStats, FLOAT _fX, FLOAT _fY, FLOAT _fHeight, FLOAT _fWidth);
function DrawMPFavoriteIcon ( UWindowWindow W, Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fHeight);
function DrawMPLockedIcon   ( UWindowWindow W, Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fHeight);
function DrawMPDedicatedIcon( UWindowWindow W, Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fHeight);
function DrawMPSpectatorIcon( UWindowWindow W, Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fHeight);
function DrawPopUpTextBackGround( UWindowWindow W, Canvas C, FLOAT _fHeight );

defaultproperties
{
}
