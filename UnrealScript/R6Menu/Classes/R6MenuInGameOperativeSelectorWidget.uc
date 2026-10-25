//=============================================================================
//  R6MenuInGameWritableMapWidget.uc : Game Main Menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/04/05 * Created by Hugo Allaire
//=============================================================================
class R6MenuInGameOperativeSelectorWidget extends R6MenuWidget;

var const INT c_OutsideMarginX;
var const INT c_OutsideMarginY;
var const INT c_InsideMarginX;
var const INT c_InsideMarginY;
var const INT c_ColumnWidth;
var const INT c_RowHeight;

var BOOL m_bInitalized;
var BOOL m_bIsSinglePlayer;

var Sound m_OperativeOpenSnd;

var array<R6OperativeSelectorItem> aItems;
var R6GameOptions m_pGameOptions;

function UpdateOperativeItems()
{
    local R6GameReplicationInfo GameRepInfo;
    
    local INT iOperative;
    local INT iOperativeCount;
    local INT iOperativePos;
    local INT iPosX;
    local INT iPosY;
    
    local INT iTeam;

    // For multiplayer purpose
    local R6RainbowTeam MPTeam;
    local R6TeamMemberReplicationInfo pTeamMemberRepInfo;
    local R6Rainbow P;

    GameRepInfo = R6GameReplicationInfo(GetPlayerOwner().GameReplicationInfo);

    iOperativePos = 0;

    m_bIsSinglePlayer = GameRepInfo.Level.NetMode == NM_Standalone;

    // Fill the Operatives Info
    if (m_bIsSinglePlayer)
    {
        for (iTeam = 0; iTeam < 3; iTeam++)
        {
            iPosX = c_OutsideMarginX + c_InsideMarginX + (iTeam * (c_InsideMarginX + c_ColumnWidth));

            if (GameRepInfo.m_RainbowTeam[iTeam] != None)
            {
                iOperativeCount = GameRepInfo.m_RainbowTeam[iTeam].m_iMembersLost + GameRepInfo.m_RainbowTeam[iTeam].m_iMemberCount;
                for (iOperative = 0; iOperative <  iOperativeCount; iOperative++)
                {
                    iPosY = c_OutsideMarginY + c_InsideMarginY + (iOperative * (c_InsideMarginY + c_RowHeight));
                    if (!m_bInitalized)
                        aItems[iOperativePos] = R6OperativeSelectorItem(CreateWindow(class'R6OperativeSelectorItem', iPosX, iPosY, c_ColumnWidth, c_RowHeight)); 
                    aItems[iOperativePos].SetCharacterInfo(GameRepInfo.m_RainbowTeam[iTeam].m_Team[iOperative]);
                    aItems[iOperativePos].m_DarkColor = Root.Colors.TeamColorDark[iTeam];
                    aItems[iOperativePos].m_NormalColor = Root.Colors.TeamColor[iTeam];
                    
                    iOperativePos++;
                }
            }
        }
    }
    else
    {
        m_pGameOptions = class'Actor'.static.GetGameOptions();

        P = R6Rainbow(GetPlayerOwner().Pawn);

        iPosX = c_OutsideMarginX + c_InsideMarginX + (c_InsideMarginX + c_ColumnWidth);
        // Create all 4 windows and hide them
        for (iOperative = 0; iOperative < 4; iOperative++)
        {
            if (!m_bInitalized)
            {
                iPosY = c_OutsideMarginY + c_InsideMarginY + (iOperative * (c_InsideMarginY + c_RowHeight));

                aItems[iOperative] = R6OperativeSelectorItem(CreateWindow(class'R6OperativeSelectorItem', iPosX, iPosY, c_ColumnWidth, c_RowHeight)); 
            }

            aItems[iOperative].HideWindow();
        }

        ForEach P.AllActors(class'R6TeamMemberReplicationInfo', pTeamMemberRepInfo)
        {
            if (P.m_TeamMemberRepInfo.m_iTeamId == pTeamMemberRepInfo.m_iTeamId)
            {
                aItems[pTeamMemberRepInfo.m_iTeamPosition].SetCharacterInfoMP(pTeamMemberRepInfo);
                aItems[pTeamMemberRepInfo.m_iTeamPosition].m_DarkColor = m_pGameOptions.HUDMPDarkColor;
                aItems[pTeamMemberRepInfo.m_iTeamPosition].m_NormalColor = m_pGameOptions.HUDMPColor;
                aItems[pTeamMemberRepInfo.m_iTeamPosition].ShowWindow();
            }
        }
    }

    m_bInitalized = true;
}

function ShowWindow()
{
    Super.ShowWindow();
    UpdateOperativeItems();
    GetPlayerOwner().PlaySound(m_OperativeOpenSnd, SLOT_Menu);
}

function HideWindow()
{
    local INT iOperativePos;

    Super.HideWindow();

    for (iOperativePos = 0; iOperativePos < aItems.Length; iOperativePos++)
    {
        aItems[iOperativePos].m_Operative = none;
        aItems[iOperativePos].m_MemberRepInfo = none;
    }
}



function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    local INT iOperative;
    local INT iTeam;
    local INT iPosX;
    local INT iPosY;
    local String szTeam;
    local FLOAT fTeamPosX;
    local FLOAT fTeamPosY;

    local R6Rainbow P;

    local R6TeamMemberReplicationInfo pTeamMemberRepInfo;
	
    // Draw Team Headers
    if (m_bIsSinglePlayer)
    {
        for (iTeam = 0; iTeam < 3; iTeam++)
        {
            C.Style = ERenderStyle.STY_Alpha;
            iPosX = c_OutsideMarginX + c_InsideMarginX + (iTeam * (c_InsideMarginX + c_ColumnWidth));
            iPosY = 63 + c_InsideMarginY;
            C.DrawColor = Root.Colors.TeamColor[iTeam];
            C.DrawColor.A = 51;
            
            DrawStretchedTextureSegment(C, iPosX + 1, iPosY + 1, c_ColumnWidth - 2, 18, 0, 0, 1, 1, Texture'Color.Color.White');
            C.DrawColor.A = 255;
            C.SetPos(iPosX + (c_ColumnWidth / 2), iPosY + 2);
            
            switch(iTeam)
            {
            case 0:
                szTeam = Caps(Localize("COLOR", "ID_RED", "R6COMMON"));
                break;
                
            case 1:
                szTeam = Caps(Localize("COLOR", "ID_GREEN", "R6COMMON"));
                break;
                
            case 2:
                szTeam = Caps(Localize("COLOR", "ID_GOLD", "R6COMMON"));
                break;
            }
            
            TextSize(C, szTeam, fTeamPosX, fTeamPosY);
            
            C.SetPos(iPosX + (c_ColumnWidth - fTeamPosX) / 2, iPosY + 1);
            C.DrawText(szTeam);
            
            DrawStretchedTextureSegment(C, iPosX, iPosY, c_ColumnWidth, 1, 0, 0, 1, 1, Texture'Color.Color.White');
            DrawStretchedTextureSegment(C, iPosX, iPosY + 17 - 1, c_ColumnWidth, 1, 0, 0, 1, 1, Texture'Color.Color.White');
            DrawStretchedTextureSegment(C, iPosX, iPosY, 1, 17, 0, 0, 1, 1, Texture'Color.Color.White');
            DrawStretchedTextureSegment(C, iPosX + c_ColumnWidth - 1, iPosY, 1, 17, 0, 0, 1, 1, Texture'Color.Color.White');
            
            for (iOperative = 0; iOperative < aItems.Length; iOperative++)
            {
                aItems[iOperative].UpdatePosition();
            }
        }
    }
    else
    {
        C.Style = ERenderStyle.STY_Alpha;
        iPosX = c_OutsideMarginX + c_InsideMarginX + (c_InsideMarginX + c_ColumnWidth);
        iPosY = 63 + c_InsideMarginY;
        C.DrawColor = m_pGameOptions.HUDMPColor;
        C.DrawColor.A = 51;
        
        DrawStretchedTextureSegment(C, iPosX + 1, iPosY + 1, c_ColumnWidth - 2, 18, 0, 0, 1, 1, Texture'Color.Color.White');
        C.DrawColor.A = 255;
        C.SetPos(iPosX + (c_ColumnWidth / 2), iPosY + 2);
        
        szTeam = Caps(Localize("MISC", "Team", "R6Menu"));
        
        TextSize(C, szTeam, fTeamPosX, fTeamPosY);
        
        C.SetPos(iPosX + (c_ColumnWidth - fTeamPosX) / 2, iPosY + 1);
        C.DrawText(szTeam);
        
        DrawStretchedTextureSegment(C, iPosX, iPosY, c_ColumnWidth, 1, 0, 0, 1, 1, Texture'Color.Color.White');
        DrawStretchedTextureSegment(C, iPosX, iPosY + 17 - 1, c_ColumnWidth, 1, 0, 0, 1, 1, Texture'Color.Color.White');
        DrawStretchedTextureSegment(C, iPosX, iPosY, 1, 17, 0, 0, 1, 1, Texture'Color.Color.White');
        DrawStretchedTextureSegment(C, iPosX + c_ColumnWidth - 1, iPosY, 1, 17, 0, 0, 1, 1, Texture'Color.Color.White');
        
        for (iOperative = 0; iOperative < aItems.Length; iOperative++)
        {
            aItems[iOperative].UpdatePositionMP();
        }
    }
}

defaultproperties
{
     c_OutsideMarginX=19
     c_OutsideMarginY=83
     c_InsideMarginX=2
     c_InsideMarginY=3
     c_ColumnWidth=198
     c_RowHeight=89
     m_OperativeOpenSnd=Sound'SFX_Menus.Play_Rose_Open'
}
