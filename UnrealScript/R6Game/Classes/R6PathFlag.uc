//=============================================================================
//  R6PathFlag.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/30 * Created by Chaouky Garram
//=============================================================================
class R6PathFlag extends R6ReferenceIcons
    notplaceable;

var Texture         m_pIconTex[3];       // EMovementSpeed

// Set Movement line texture
function SetModeDisplay(EMovementMode eMode)
{
    Texture=m_pIconTex[eMode];
}

// Set texture color 
function SetDrawColor(Color NewColor)
{
    m_PlanningColor = NewColor;
}

// Refresh my location to be between previous and next ActionPoint
function RefreshLocation()
{
    local FLOAT fEvenCheck;
    local vector vFirstVector;
    local vector vSecondVector;
    local INT iMiddleNodeIndex;
    local R6ActionPoint OwnerPoint;
    local Actor aMiddlePoint1, aMiddlePoint2, aMiddlePoint3;

    OwnerPoint = R6ActionPoint(owner);
    if(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length == 0)
    {
        //No nav points between the two nodes
        SetLocation((OwnerPoint.Location + OwnerPoint.prevActionPoint.Location) * 0.5f);
        m_iPlanningFloor_0 = owner.m_iPlanningFloor_0;
        m_iPlanningFloor_1 = OwnerPoint.prevActionPoint.m_iPlanningFloor_0; 
    }
    else
    {
        fEvenCheck = OwnerPoint.prevActionPoint.m_PathToNextPoint.Length % 2;

        if(fEvenCheck == 0)
        {
            aMiddlePoint1 = OwnerPoint.prevActionPoint.m_PathToNextPoint[ OwnerPoint.prevActionPoint.m_PathToNextPoint.Length / 2 ];
            if(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length > 1 )
            {
                aMiddlePoint2 = OwnerPoint.prevActionPoint.m_PathToNextPoint[ OwnerPoint.prevActionPoint.m_PathToNextPoint.Length / 2 - 1 ];
                if(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length > 3 )
                    aMiddlePoint3 = OwnerPoint.prevActionPoint.m_PathToNextPoint[ OwnerPoint.prevActionPoint.m_PathToNextPoint.Length / 2 - 2 ];
            }

           //even number of nodes,
            if((aMiddlePoint2.IsA('R6Ladder') && 
                aMiddlePoint1.IsA('R6Ladder')) ||
               (aMiddlePoint2.IsA('R6Door') && 
                aMiddlePoint1.IsA('R6Door')))
            {
                //Path flag is in the middle of two ladder or door icons. put it before the first icon.
                if(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length == 2)
                {
                    vFirstVector = OwnerPoint.prevActionPoint.Location;
                    vSecondVector = OwnerPoint.prevActionPoint.m_PathToNextPoint[0].Location;
                }
                else
                {
                    vFirstVector = aMiddlePoint3.Location;
                    vSecondVector = aMiddlePoint2.Location;
                }

            }
            else
            {
                vFirstVector = aMiddlePoint1.Location;
                vSecondVector = aMiddlePoint2.Location;
            }
            SetLocation((vFirstVector + vSecondVector) * 0.5f);

            if(aMiddlePoint2.IsA('R6Stairs') && 
               !aMiddlePoint1.IsA('R6Stairs'))
            {
                if(R6Stairs(aMiddlePoint2).m_bIsTopOfStairs == true)
                {
                    m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_1;
                    m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_1; 
                }
                else
                {
                    m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_0;
                    m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_0; 
                }
            }
            else if( aMiddlePoint2.IsA('R6Ladder') && 
                     aMiddlePoint1.IsA('R6Ladder'))
            {
                //Path flag is in the middle of two ladder icon. put it before the first ladder icon.
                if(R6Ladder(aMiddlePoint2).m_bIsTopOfLadder == true)
                {
                    m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_1;
                    m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_1;
                }
                else
                {
                    m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_0;
                    m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_0;
                }
            }
            else
            {
                m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_0;
                m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_1;
            }
        }
        else
        {
            //odd number of nodes. use position of the middle navpoint
            iMiddleNodeIndex = OwnerPoint.prevActionPoint.m_PathToNextPoint.Length / 2;

            aMiddlePoint1 = OwnerPoint.prevActionPoint.m_PathToNextPoint[ iMiddleNodeIndex ];
            if(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length > 1 )
            {
                aMiddlePoint2 = OwnerPoint.prevActionPoint.m_PathToNextPoint[ iMiddleNodeIndex + 1];
                aMiddlePoint3 = OwnerPoint.prevActionPoint.m_PathToNextPoint[ iMiddleNodeIndex - 1];
            }

            if( aMiddlePoint1.IsA('R6Ladder') )
            {
                if(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length == 1)
                {
                    vFirstVector = OwnerPoint.prevActionPoint.Location;
                    vSecondVector = aMiddlePoint1.Location;
                }
                else if(aMiddlePoint3.IsA('R6Ladder'))
                {
                    vFirstVector = aMiddlePoint1.Location;
                    vSecondVector = aMiddlePoint2.Location;
                }
                else
                {
                    vFirstVector = aMiddlePoint1.Location;
                    vSecondVector = aMiddlePoint3.Location;
                }
                SetLocation((vFirstVector + vSecondVector) * 0.5f);
            }
            if( aMiddlePoint1.IsA('R6Door') )
            {
                if(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length == 1)
                {
                    vFirstVector = OwnerPoint.prevActionPoint.Location;
                    vSecondVector = aMiddlePoint1.Location;
                }
                else if(aMiddlePoint3.IsA('R6Door'))
                {
                    vFirstVector = aMiddlePoint1.Location;
                    vSecondVector = aMiddlePoint2.Location;
                }
                else
                {
                    vFirstVector = aMiddlePoint1.Location;
                    vSecondVector = aMiddlePoint3.Location;
                }
                SetLocation((vFirstVector + vSecondVector) * 0.5f);
            }
            else
            {
                SetLocation(aMiddlePoint1.Location);
            }
            m_iPlanningFloor_0 = aMiddlePoint1.m_iPlanningFloor_0;
            m_iPlanningFloor_1 = aMiddlePoint1.m_iPlanningFloor_1;
        }
    }
}

defaultproperties
{
     m_pIconTex(0)=Texture'R6Planning.Icons.PlanIcon_Assault'
     m_pIconTex(1)=Texture'R6Planning.Icons.PlanIcon_Infiltrate'
     m_pIconTex(2)=Texture'R6Planning.Icons.PlanIcon_Recon'
     m_bSkipHitDetection=False
     m_bSpriteShowFlatInPlanning=False
     DrawScale=1.250000
}
