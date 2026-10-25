//=============================================================================
//  R6PlanningPawn.uc : Pawn of the R6PlanningCtrl
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6PlanningPawn extends R6Pawn;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

var FLOAT               m_fSpeed;
var R6ArrowIcon         m_ArrowInPlanningView;
var R6PlanningInfo      m_PlanToFollow;
var actor               m_pActorToReach;
var rotator             m_rDirRot;

function ArrowReachedNavPoint(){}
function ArrowRotationIsOK(){}

event PostBeginPlay()
{
    m_ArrowInPlanningView = spawn(class'R6ArrowIcon',self);
}

simulated event ChangeAnimation()
{
}

function ClientReStart()
{
}

function FollowPlanning(R6PlanningInfo m_pTeamInfo)
{
    m_PlanToFollow = m_pTeamInfo;
    m_PlanToFollow.m_iCurrentPathIndex = -1;
    GotoState('FollowPlan');
}

function StopFollowingPlanning()
{

    GotoState('');
}

event Falling();
event Landed(vector HitNormal)
{
    m_bIsLanding = true;
    acceleration = vect(0,0,0);
    velocity = vect(0,0,0);
}

simulated function PlayDuck();

state FollowPlan
{
    function BOOL ChangeArrowParameters(Optional BOOL bFirstInit)
    {
        local vector vDir;
        local R6PlanningCtrl OwnerPlanningCtrl;
        OwnerPlanningCtrl = R6PlanningCtrl(Owner);

        m_pActorToReach = m_PlanToFollow.GetNextActionPoint();

        if((m_pActorToReach != none) && (m_PlanToFollow.PreviewNextActionPoint() != none))
        {
            //Init the arrow icon that will follow the planning.
            if(m_pActorToReach.IsA('R6Ladder') && (R6Ladder(m_pActorToReach).m_bIsTopOfLadder == false))
            {
                m_ArrowInPlanningView.SetLocation(m_pActorToReach.Location+vect(0,0,100));
            }
            else
            {
                m_ArrowInPlanningView.SetLocation(m_pActorToReach.Location);
            }

            m_ArrowInPlanningView.m_iPlanningFloor_0 = m_pActorToReach.m_iPlanningFloor_0;
            m_ArrowInPlanningView.m_iPlanningFloor_1 = m_pActorToReach.m_iPlanningFloor_1;
            if(m_pActorToReach.IsA('R6Stairs') && (R6Stairs(m_pActorToReach).m_bIsTopOfStairs == true))
            {
                OwnerPlanningCtrl.SetFloorToDraw(m_ArrowInPlanningView.m_iPlanningFloor_1);
                OwnerPlanningCtrl.m_iLevelDisplay = m_ArrowInPlanningView.m_iPlanningFloor_1;
            }
            else
            {
                OwnerPlanningCtrl.SetFloorToDraw(m_ArrowInPlanningView.m_iPlanningFloor_0);
                OwnerPlanningCtrl.m_iLevelDisplay = m_ArrowInPlanningView.m_iPlanningFloor_0;
            }

            m_ArrowInPlanningView.m_vPointToReach = m_PlanToFollow.PreviewNextActionPoint().Location;
            if(m_PlanToFollow.PreviewNextActionPoint().IsA('R6Ladder') && (R6Ladder(m_PlanToFollow.PreviewNextActionPoint()).m_bIsTopOfLadder == false))
            {
                //Add one meter for ladders.
                m_ArrowInPlanningView.m_vPointToReach.Z+=100;
                //Find the rotator between the two points.
                vDir = m_PlanToFollow.PreviewNextActionPoint().Location+vect(0,0,100) - m_pActorToReach.Location;
            }
            else
            {
                //Find the rotator between the two points.
                vDir = m_PlanToFollow.PreviewNextActionPoint().Location - m_pActorToReach.Location;
            }

            m_ArrowInPlanningView.m_vStartLocation = m_pActorToReach.Location;
            m_rDirRot = Rotator(vDir);

            if(bFirstInit == true)
            {
                m_ArrowInPlanningView.SetRotation(m_rDirRot);
                m_ArrowInPlanningView.SetPhysics(PHYS_Projectile);
                m_ArrowInPlanningView.m_u8SpritePlanningAngle = m_rDirRot.Yaw / 255 + 64;
                m_ArrowInPlanningView.DesiredRotation = m_rDirRot;

                if(m_PlanToFollow.GetNextPoint() != none)
                {
                    if(m_PlanToFollow.GetNextPoint().m_eMovementSpeed == SPEED_Blitz )
                    {
                        m_ArrowInPlanningView.RotationRate.Pitch = 15000;
                        m_ArrowInPlanningView.RotationRate.Yaw = 15000;
                        m_fSpeed = 600;
                    }
                    else if(m_PlanToFollow.GetNextPoint().m_eMovementSpeed == SPEED_Cautious)
                    {
                        m_ArrowInPlanningView.RotationRate.Pitch = 7500;
                        m_ArrowInPlanningView.RotationRate.Yaw = 7500;
                        m_fSpeed = 250;
                    }
                    else
                    {
                        m_ArrowInPlanningView.RotationRate.Pitch = 11000;
                        m_ArrowInPlanningView.RotationRate.Yaw = 11000;
                        m_fSpeed = 350;
                    }
                }
            }
            else
            {
                //The arrow will now rotate towards next point
                m_ArrowInPlanningView.SetPhysics(PHYS_Rotating);
                m_ArrowInPlanningView.DesiredRotation = m_rDirRot;
                m_ArrowInPlanningView.DesiredRotation.Pitch = m_rDirRot.Pitch & 65535;
                m_ArrowInPlanningView.DesiredRotation.Yaw = m_rDirRot.Yaw & 65535;
                m_ArrowInPlanningView.DesiredRotation.Roll = m_rDirRot.Roll;
            }

            m_ArrowInPlanningView.Velocity = m_fSpeed * vector(m_rDirRot);
        }
        else
        {
            WindowConsole(PlayerController(Controller).Player.Console).Root.StopPlayMode();
            OwnerPlanningCtrl.m_bPlayMode = FALSE;
            OwnerPlanningCtrl.StopPlayingPlanning();
            return false;  //following path is over
        }
        return true;
    }

    function ArrowRotationIsOK()
    {
        m_ArrowInPlanningView.SetRotation(m_rDirRot);
        m_ArrowInPlanningView.SetPhysics(PHYS_Projectile);
          
    }

    function ArrowReachedNavPoint()
    {
        // Reach the Next Point.
        if(m_PlanToFollow.m_iCurrentPathIndex == (m_PlanToFollow.GetPoint().m_PathToNextPoint.Length - 1))
        {
            m_PlanToFollow.m_iCurrentPathIndex = -1;
            m_PlanToFollow.SetToNextNode();
            
            if(m_PlanToFollow.GetNextPoint() != none)
            {
                if(m_PlanToFollow.GetNextPoint().m_eMovementSpeed == SPEED_Blitz )
                {
                    m_ArrowInPlanningView.RotationRate.Pitch = 15000;
                    m_ArrowInPlanningView.RotationRate.Yaw = 15000;
                    m_fSpeed = 600;
                }
                else if(m_PlanToFollow.GetNextPoint().m_eMovementSpeed == SPEED_Cautious)
                {
                    m_ArrowInPlanningView.RotationRate.Pitch = 7500;
                    m_ArrowInPlanningView.RotationRate.Yaw = 7500;
                    m_fSpeed = 250;
                }
                else
                {
                    m_ArrowInPlanningView.RotationRate.Pitch = 11000;
                    m_ArrowInPlanningView.RotationRate.Yaw = 11000;
                    m_fSpeed = 350;
                }
            }
        }
        else
        {
            m_PlanToFollow.m_iCurrentPathIndex++;
        }
        
        //Change the Arrow
        if(ChangeArrowParameters() == false)
        {
            GotoState('');
        }
    }

    function EndState()
    {
        //Hide and stop the arrow
        m_ArrowInPlanningView.GotoState('');
    }
    
    function BeginState()
    {
        m_ArrowInPlanningView.GotoState('FollowPath');
        ChangeArrowParameters(TRUE);
    }
}

defaultproperties
{
     m_fSpeed=300.000000
     m_bCanProne=False
     bCanStrafe=True
     MenuName="Planning Assistant"
     CollisionHeight=80.000000
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel283
         KConvulseSpacing=(Max=2.200000)
         KSkeleton="terroskel"
         KStartEnabled=True
         bHighDetailOnly=False
         KLinearDamping=0.500000
         KAngularDamping=0.500000
         KBuoyancy=1.000000
         KVelDropBelowThreshold=50.000000
         KFriction=0.600000
         KRestitution=0.300000
         KImpactThreshold=150.000000
         Name="KarmaParamsSkel283"
     End Object
     KParams=KarmaParamsSkel'R6Game.KarmaParamsSkel283'
}
