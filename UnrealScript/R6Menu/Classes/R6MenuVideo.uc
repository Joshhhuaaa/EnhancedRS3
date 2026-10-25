//=============================================================================
//  R6MenuVideo.uc : Draw a simple window (opportunity to create a empty box) and play a video inside it
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/26 * Created by Yannick Joly
//=============================================================================

class R6MenuVideo extends UWindowWindow;


var string m_szVideoFilename;   // the name of the video to play

var INT    m_iCentered;         // the video is center at 1, 0 none
var INT    m_iXStartPos;        // the start pos in x
var INT    m_iYStartPos;        // the start pos in y

var bool   m_bAlreadyStart;     // the video is is already playing
var bool   m_bPlayVideo;        // the video is playing 

var bool   bShowlog;

function PlayVideo( INT _iXStartPos, INT _iYStartPos, string _szVideoFileName)
{
    m_szVideoFilename = _szVideoFileName;

    // if the name is valid 
    if (m_szVideoFilename != "")
    {
        m_bPlayVideo = true;
        m_iXStartPos = _iXStartPos;
        m_iYStartPos = _iYStartPos;
//        log("m_iXStartPos :"$m_iXStartPos);
//        log("m_iYStartPos :"$m_iYStartPos);
    }

    if(bShowlog)
    {
        log("PlayVideo");
        log("m_szVideoFilename"@m_szVideoFilename@"m_bPlayVideo"@m_bPlayVideo);
    }
}

function StopVideo()
{
    local Canvas C;

    if(bShowlog)
    {
        log("StopVideo");
        log("m_bPlayVideo"@m_bPlayVideo);
    }

    if( m_bPlayVideo)
    {
        C = class'Actor'.static.GetCanvas();
        m_bPlayVideo = false;
        m_bAlreadyStart = false;
        C.VideoStop();        
    }

    if(bShowlog)
    {        
        log("m_bPlayVideo"@m_bPlayVideo);
        log("m_bAlreadyStart"@m_bAlreadyStart);
    }
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{

    if ( m_bPlayVideo)
    {
        if (!m_bAlreadyStart)
        {
            if(bShowlog)
            {
                log("Paint m_bPlayVideo = true m_bAlreadyStart = false");
            }
            // the video open close the previous one
            C.VideoOpen( m_szVideoFilename, 0);
            m_bAlreadyStart = true;

            // start the video
            C.VideoPlay( m_iXStartPos, m_iYStartPos, m_iCentered);
            
        }
    }

    DrawSimpleBorder(C);
}

defaultproperties
{
}
