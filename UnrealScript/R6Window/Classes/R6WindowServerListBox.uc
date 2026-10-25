//=============================================================================
//  R6WindowServerListBox.uc : Class used to manage the "list box" of servers.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/27 * Created by John Bennett
//=============================================================================

class R6WindowServerListBox extends R6WindowListBox;

var Color   m_BGSelColor;			// BackGround color when selected
var Texture m_BGSelTexture;			// BackGround texture under item when selected
var Region  m_BGSelRegion;			// BackGround texture Region under item when selected

var ERenderStyle m_BGRenderStyle;

var Color   m_SelTextColor;			// color for selected text

var Font    m_Font;

var bool    m_bDrawBorderAndBkg;	// draw the border and the background
var INT     m_iPingTimeOut;			// Time at which the ping time times out

function Created()
{
	Super.Created();
	
    m_VertSB.SetHideWhenDisable(true);

    TextColor           = Root.Colors.m_LisBoxNormalTextColor;
    m_SelTextColor      = Root.Colors.m_LisBoxSelectedTextColor;
    m_BGSelColor        = Root.Colors.m_LisBoxSelectionColor;
    m_BGRenderStyle     = ERenderStyle.STY_Alpha;

}

//function DoubleClick(FLOAT X, FLOAT Y)
//{
//	Super.DoubleClick(X, Y);
//
//    if ( GetItemAt( X, Y ) == m_SelectedItem && R6WindowListServerItem(m_SelectedItem).bSameVersion )
//        Notify( DE_DoubleClick );
//}

function BeforePaint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
    m_VertSB.SetBorderColor(m_BorderColor);
    Super.BeforePaint(C, fMouseX, fMouseY);
}

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
    if (m_bDrawBorderAndBkg)
    {
        
        R6WindowLookAndFeel(LookAndFeel).R6List_DrawBackground(self,C);
        
    }

    Super.Paint( C, fMouseX, fMouseY);
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local R6WindowListServerItem pSItem;
	local float TextY, fYPos, fTemp, 
				TW,TH;
	local string szTemp;

	pSItem = R6WindowListServerItem(Item);

	if(pSItem.bSelected)
	{        
		if(m_BGSelTexture != NONE)
		{
            C.Style = m_BGRenderStyle;
			// We draw the selected highlight			
			C.SetDrawColor(m_BGSelColor.R,m_BGSelColor.G,m_BGSelColor.B);
			

		    DrawStretchedTextureSegment( C, X, Y, W, H, m_BGSelRegion.X, m_BGSelRegion.Y, 
											m_BGSelRegion.W, m_BGSelRegion.H,	m_BGSelTexture );
				
		}		
	
        C.SetDrawColor(m_SelTextColor.r,m_SelTextColor.g,m_SelTextColor.b);
	}
	else
	{
		C.SetDrawColor(TextColor.r,TextColor.g,TextColor.b);

	}

	C.Font = m_Font;//Root.Fonts[F_Normal];
    C.Style = ERenderStyle.STY_Alpha;

    if ( !pSItem.bSameVersion )
        C.SetDrawColor( Root.Colors.GrayLight.R, Root.Colors.GrayLight.G, Root.Colors.GrayLight.B);

	TextSize(C, "A", TW, TH);	

	TextY = (H - TH) / 2;
    TextY = FLOAT(INT(TextY+0.5));;

	fYPos = Y + TextY;

    // Draw the text

	// FAVORITES
    if ( pSItem.bFavorite )
    {
		DrawIcon( C, pSItem.eServerItem.eSI_Favorites, 
					 pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Favorites].fXPos, fYPos, 
					 pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Favorites].fWidth, TH);
	}

	// LOCKED
    if ( pSItem.bLocked )
    {        
		DrawIcon( C, pSItem.eServerItem.eSI_Locked, 
					 pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Locked].fXPos, fYPos, 
					 pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Locked].fWidth, TH);     
    }

	// DEDICATED
    if ( pSItem.bDedicated )
    {       
		DrawIcon( C, pSItem.eServerItem.eSI_Dedicated, 
					 pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Dedicated].fXPos, fYPos, 
					 pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Dedicated].fWidth, TH);        
    }

//#ifdefR6PUNKBUSTER
	// PUNKBUSTER
    if ( pSItem.bPunkBuster )
    {       
		DrawIcon( C, pSItem.eServerItem.eSI_PunkBuster, 
					 pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_PunkBuster].fXPos, fYPos, 
					 pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_PunkBuster].fWidth, TH);
    }
//#endif

	// SERVER NAME
	if (pSItem.m_bNewItem) // reset at the end of the fct
	{
		pSItem.szName = TextSize( C, pSItem.szName, TW, TH, INT(pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_ServerName].fWidth));
	}
    C.SetPos( pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_ServerName].fXPos + 2, fYPos ); // + 2 corresponding to the margin, to be align with the title
	C.DrawText( pSItem.szName); 

	// PING TIME
    // If the ping time is not valid, print a "-" in the field.
    if ( pSItem.iPing < m_iPingTimeOut )
		szTemp = string(pSItem.iPing);
    else
        szTemp = "-";

    TextSize(C, szTemp, TW, TH);
    fTemp = pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Ping].fXPos + GetCenterXPos( pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Ping].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(szTemp);

	// GAME TYPE 
    pSItem.szGameType = TextSize(C, pSItem.szGameType, TW, TH, pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_GameType].fWidth);
    fTemp = pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_GameType].fXPos + GetCenterXPos( pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_GameType].fWidth, TW);
    C.SetPos( fTemp, fYPos );
    C.DrawText(pSItem.szGameType); //ClipTextWidth

	// GAME MODE
    pSItem.szGameMode = TextSize(C, pSItem.szGameMode, TW, TH, pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_GameMode].fWidth);
    fTemp = pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_GameMode].fXPos + GetCenterXPos( pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_GameMode].fWidth, TW);
    C.SetPos( fTemp, fYPos );
    C.DrawText(pSItem.szGameMode); //ClipTextWidth

	// MAP
    pSItem.szMap = TextSize(C, pSItem.szMap, TW, TH, pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Map].fWidth);
    fTemp = pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Map].fXPos + GetCenterXPos( pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Map].fWidth, TW);
    C.SetPos( fTemp, fYPos );
    C.DrawText(pSItem.szMap); //ClipTextWidth

	// PLAYERS
//  Make sure values make sense before they are displayed
    if ( ( pSItem.iMaxPlayers > 0) && ( pSItem.iNumPlayers >= 0) )
	{
		szTemp = pSItem.iNumPlayers $ "/" $ pSItem.iMaxPlayers;
		TextSize(C, szTemp, TW, TH);
		fTemp = pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Players].fXPos + GetCenterXPos( pSItem.m_stServerItemPos[pSItem.eServerItem.eSI_Players].fWidth, TW);
		C.SetPos( fTemp,  fYPos);
        C.DrawText(szTemp);
	}

	pSItem.m_bNewItem = false;
}


function DrawIcon( Canvas C, INT _iPlayerStats, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    local Region RIconRegion, RIconToDraw;

	switch( _iPlayerStats)
	{
		case 0: // eServerItem.eSI_Favorites
			RIconToDraw.X = 0;
			RIconToDraw.Y = 42;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			break;
		case 1: // eServerItem.eSI_Locked
			RIconToDraw.X = 13;
			RIconToDraw.Y = 42;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			break;
		case 2: // eServerItem.eSI_Dedicated
			RIconToDraw.X = 0;
			RIconToDraw.Y = 53;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			break;
//#ifdefR6PUNKBUSTER
		case 3: // eServerItem.eSI_PunkBuster
			RIconToDraw.X = 26;
			RIconToDraw.Y = 53;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			break;
//#endif
		default:
			log("R6WindowServerListBox DrawIcon() --> This icon "@_iPlayerStats@"don't exist");
			break;
	}	

	RIconRegion = CenterIconInBox( _fX, _fY, _fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                    RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);
}
   
    
//=============================================================================
// RMouseDown - If the user right clicks on a server, we call the notify
// function so that the right-click menu can be displayed.
//=============================================================================
function RMouseDown(float X, float Y)
{
	Super.RMouseDown(X, Y);

    if ( GetItemAt( X, Y ) != None )
    {
	    SetSelected(X, Y);
        Notify( DE_RClick );
    }
}  

//=============================================================================
// SetSelectedItem - We were getting recursion problems caused by
// the Notify(DE_Click) function, so this function was overloaded and the 
// call to Notify(DE_Click) was removed (not needed in this application).
//=============================================================================
function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	if(NewSelected != None && m_SelectedItem != NewSelected)
	{
		if(m_SelectedItem != None)
        {
			m_SelectedItem.bSelected = False;
        }

		m_SelectedItem = NewSelected;

		if(m_SelectedItem != None)
        {
			m_SelectedItem.bSelected = True;
        }
		
//		Notify(DE_Click);
	}
}

defaultproperties
{
     m_iPingTimeOut=1000
     m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_BGSelColor=(B=128)
     m_BGSelRegion=(X=253,W=2,H=13)
     m_SelTextColor=(B=255,G=255,R=255)
     m_fItemHeight=14.000000
     ListClass=Class'R6Window.R6WindowListServerItem'
}
