class R6WindowTextListBoxExt extends R6WindowTextListBox;

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
    local R6WindowListBoxItemExt pIt;
    local string szToDisplay;
    local FLOAT tW, tH, fYPos, fYAdjust;
    local INT i, j, k;

    if (Item.IsA('R6WindowListBoxItem'))
    {
        Super.DrawItem(C, Item, X, Y, W, H);
        return;
    }

    pIt = R6WindowListBoxItemExt(Item);
    if ((pIt != None) && (pIt.m_AItemDesc.Length == 0))
        return;

    if (pIt.bSelected)
    {
        if (m_BGSelTexture != None)
        {
            C.Style = m_BGRenderStyle;
            C.SetDrawColor(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B);
            DrawStretchedTextureSegment(C, X, Y, W, H - m_fSpaceBetItem, m_BGSelRegion.X, m_BGSelRegion.Y, m_BGSelRegion.W, m_BGSelRegion.H, m_BGSelTexture);
        }
    }

    for (i = 0; i < pIt.m_AItemDesc.Length; i++)
    {
        pIt.SetItemDescriptionIndex(i);
        if (!pIt.m_DescTemp.bDisplay)
            continue;

        C.Font = pIt.m_DescTemp.TextFont;
        C.SpaceX = m_fFontSpacing;

        if (m_bForceCaps)
            szToDisplay = TextSize(C, Caps(pIt.m_DescTemp.szText), tW, tH, pIt.m_DescTemp.fWidth);
        else
            szToDisplay = TextSize(C, pIt.m_DescTemp.szText, tW, tH, pIt.m_DescTemp.fWidth);

        if (pIt.m_bDisabled)
            C.SetDrawColor(m_DisableTextColor.R, m_DisableTextColor.G, m_DisableTextColor.B);
        else
            C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);

        // descriptions on later lines are drawn below the height of the lines before them
        fYPos = Y;
        if (pIt.m_DescTemp.iLineNumber > 0)
        {
            k = pIt.m_DescTemp.iLineNumber;
            for (j = 0; j < k; j++)
            {
                pIt.SetItemDescriptionIndex(j);
                fYPos += pIt.m_DescTemp.fHeigth;
            }
            pIt.SetItemDescriptionIndex(i);
        }

        fYAdjust = (pIt.m_DescTemp.fHeigth - tH) / 2;
        fYPos += FLOAT(INT(fYAdjust + 0.5));
        fYPos += pIt.m_DescTemp.fYPos;

        switch (pIt.m_DescTemp.eAlignment)
        {
            case TA_Right:
                C.SetPos(pIt.m_DescTemp.fXPos - tW, fYPos);
                break;
            case TA_Center:
                C.SetPos(pIt.m_DescTemp.fXPos - (tW / 2.0), fYPos);
                break;
            case TA_Left:
            default:
                C.SetPos(pIt.m_DescTemp.fXPos, fYPos);
                break;
        }

        C.DrawText(szToDisplay);
    }
}

function FLOAT GetSizeOfAnItem(UWindowList _pItem)
{
    local FLOAT fTotalHeight;
    local INT i, iLineNumber;

    if (_pItem.IsA('R6WindowListBoxItem'))
        return Super(R6WindowListBox).GetSizeOfAnItem(_pItem);

    iLineNumber = 0;
    fTotalHeight = m_fSpaceBetItem;
    for (i = 0; i < R6WindowListBoxItemExt(_pItem).m_AItemDesc.Length; i++)
    {
        if (R6WindowListBoxItemExt(_pItem).m_AItemDesc[i].iLineNumber == iLineNumber)
        {
            iLineNumber++;
            fTotalHeight += R6WindowListBoxItemExt(_pItem).m_AItemDesc[i].fHeigth;
        }
    }
    return fTotalHeight;
}

defaultproperties
{
     ListClass=Class'R6Window.R6WindowListBoxItemExt'
}
