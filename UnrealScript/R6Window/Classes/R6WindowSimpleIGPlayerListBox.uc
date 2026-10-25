//=============================================================================
//  R6WindowSimpleIGPlayerListBox.uc : This version of the list box is for single player
//                                      Rainbow team stats, the parent class is for multi-player
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/19 * Created by Alexandre Dionne
//=============================================================================


class R6WindowSimpleIGPlayerListBox extends R6WindowIGPlayerInfoListBox;



function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local float TextY, TW,TH, fTemp, fYPos;
    local color co;
	local R6WindowListIGPlayerInfoItem pListIGPlayerInfoItem;
	local R6WindowLookAndFeel pLookAndFeel;

	pListIGPlayerInfoItem = R6WindowListIGPlayerInfoItem(Item);
	pLookAndFeel = R6WindowLookAndFeel(LookAndFeel);
    
    if( pListIGPlayerInfoItem.bSelected )
	{

		if(m_BGSelTexture != NONE)
		{	
            C.Style = m_BGRenderStyle;
            
			C.SetDrawColor(m_BGSelColor.R,m_BGSelColor.G,m_BGSelColor.B, m_BGSelColor.A);
		    
            fYPos = Y + (H - m_BGSelRegion.H) /2;
            	
			DrawStretchedTextureSegment( C, X, fYPos, W, m_BGSelRegion.H, m_BGSelRegion.X, m_BGSelRegion.Y, 
						m_BGSelRegion.W, m_BGSelRegion.H,	m_BGSelTexture );			
		}
        
    }
    
    C.Style = ERenderStyle.STY_Alpha;
	C.Font = m_Font;//Root.Fonts[F_Normal];

	TextSize(C, pListIGPlayerInfoItem.szPlName, TW, TH);
	

	TextY = (H - TH) / 2;
    TextY = FLOAT(INT(TextY+0.5));

    fYPos = Y+TextY;

       // Draw the icon   

    if( pListIGPlayerInfoItem.bSelected )
	{    
        co = Root.Colors.TeamColorLight[pListIGPlayerInfoItem.m_iRainbowTeam];
	}
	else
	{	
        co = Root.Colors.TeamColor[pListIGPlayerInfoItem.m_iRainbowTeam];
	}
    
    C.SetDrawColor(co.R, co.G, co.B, co.A);

    pLookAndFeel.DrawInGamePlayerStats( self, C, 4,
                                                pListIGPlayerInfoItem.stTagCoord[0].fXPos, Y, H,
                                                pListIGPlayerInfoItem.stTagCoord[0].fWidth);

        
    // Draw the icon   
    switch ( pListIGPlayerInfoItem.eStatus )
    {
        case ePlayerStatus_Alive:
            pLookAndFeel.DrawInGamePlayerStats( self, C, 1,
                                                pListIGPlayerInfoItem.stTagCoord[2].fXPos, Y, H,
                                                pListIGPlayerInfoItem.stTagCoord[2].fWidth);
            break;
        case ePlayerStatus_Wounded:
            pLookAndFeel.DrawInGamePlayerStats( self, C, 2,
                                                pListIGPlayerInfoItem.stTagCoord[2].fXPos, Y, H,
                                                pListIGPlayerInfoItem.stTagCoord[2].fWidth);
            break;
        case ePlayerStatus_Incapacitated:    
        case ePlayerStatus_Dead:
            pLookAndFeel.DrawInGamePlayerStats( self, C, 3,
                                                pListIGPlayerInfoItem.stTagCoord[2].fXPos, Y, H,
                                                pListIGPlayerInfoItem.stTagCoord[2].fWidth);
            break;
    }

    if( pListIGPlayerInfoItem.bSelected )
	{    
        C.SetDrawColor(m_SelTextColor.r,m_SelTextColor.g,m_SelTextColor.b);
	}
	else
	{
		C.SetDrawColor(TextColor.r,TextColor.g,TextColor.b);

	}

    // Draw the text
    C.SetPos( pListIGPlayerInfoItem.stTagCoord[1].fXPos, fYPos );
    C.DrawText(pListIGPlayerInfoItem.szPlName);    

	TextSize(C, string(pListIGPlayerInfoItem.iKills), TW, TH);
    fTemp = pListIGPlayerInfoItem.stTagCoord[3].fXPos + GetCenterXPos( pListIGPlayerInfoItem.stTagCoord[3].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(pListIGPlayerInfoItem.iKills);

	TextSize(C, string(pListIGPlayerInfoItem.iEfficiency), TW, TH);
    fTemp = pListIGPlayerInfoItem.stTagCoord[4].fXPos + GetCenterXPos( pListIGPlayerInfoItem.stTagCoord[4].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(pListIGPlayerInfoItem.iEfficiency);

	TextSize(C, string(pListIGPlayerInfoItem.iRoundsFired), TW, TH);
    fTemp = pListIGPlayerInfoItem.stTagCoord[5].fXPos + GetCenterXPos( pListIGPlayerInfoItem.stTagCoord[5].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(pListIGPlayerInfoItem.iRoundsFired);

	TextSize(C, string(pListIGPlayerInfoItem.iRoundsHit), TW, TH);
    fTemp = pListIGPlayerInfoItem.stTagCoord[6].fXPos + GetCenterXPos( pListIGPlayerInfoItem.stTagCoord[6].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(pListIGPlayerInfoItem.iRoundsHit);
    
   
}

defaultproperties
{
     m_fItemHeight=14.000000
}
