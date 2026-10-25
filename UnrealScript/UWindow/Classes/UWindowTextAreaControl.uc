class UWindowTextAreaControl extends UWindowDialogControl;

const szTextArraySize = 80;

var Font   TextFontArea[szTextArraySize];
var color  TextColorArea[szTextArraySize];
var string TextArea[szTextArraySize]; //array of string? 

var string Prompt;
var Font   AbsoluteFont;

var FLOAT  m_fXOffSet;
var FLOAT  m_fYOffSet;

var INT    Font;
var INT    BufSize;
var INT    Head, Tail, Lines, VisibleRows;

var bool   bCursor;
var bool   bScrollable;
var bool   bShowCaret;
var bool   bScrollOnResize;
var bool   m_bWrapClipText;                   // to know in before paint when the wrap clip the text is need

var UWindowVScrollBar VertSB;
var float LastDrawTime;

function Created()
{
	LastDrawTime = GetTime();
}

function SetScrollable(bool newScrollable)
{
	bScrollable = newScrollable;
	if(newScrollable)
	{
		VertSB = UWindowVScrollbar(CreateWindow(class'UWindowVScrollbar', WinWidth-LookAndFeel.Size_ScrollbarWidth, 0, LookAndFeel.Size_ScrollbarWidth, WinHeight));
		VertSB.bAlwaysOnTop = True;
	}
	else
	{
		if (VertSB != None)
		{
			VertSB.Close();
			VertSB = None;
		}
	}
}

function BeforePaint( Canvas C, float X, float Y )
{
	Super.BeforePaint(C, X, Y);

	if(VertSB != None)
	{
		VertSB.WinTop = 0;
		VertSB.WinHeight = WinHeight;
		VertSB.WinWidth = LookAndFeel.Size_ScrollbarWidth;
		VertSB.WinLeft = WinWidth - LookAndFeel.Size_ScrollbarWidth;
	}
}

function SetAbsoluteFont(Font F)
{
	AbsoluteFont = F;
}

function Paint( Canvas C, float X, float Y )
{
	local int i, j, Line;
	local int TempHead, TempTail;
	local float XL, YL;
	local float W, H;

	if(AbsoluteFont != None)
		C.Font = AbsoluteFont;
	else
		C.Font = Root.Fonts[Font];


	C.SetDrawColor(255,255,255);

	TextSize(C, "TEST", XL, YL);
	VisibleRows = WinHeight / YL;

	TempHead = Head;
	TempTail = Tail;
	Line = TempHead;
//	TextArea[Line] = Prompt;

	if(Prompt == "")
	{
		Line--;
		if(Line < 0)
			Line += BufSize;
	}

	if(bScrollable)
	{
		if (VertSB.MaxPos - VertSB.Pos >= 0)
		{
			Line -= VertSB.MaxPos - VertSB.Pos;
			TempTail -= VertSB.MaxPos - VertSB.Pos;

			if(Line < 0)
				Line += BufSize;
			if(TempTail < 0)
				TempTail += BufSize;
		}
	}

	if(!bCursor)
	{
		bShowCaret = False;
	}
	else
	{
		if((GetTime() > LastDrawTime + 0.3) || (GetTime() < LastDrawTime))
		{
			LastDrawTime = GetTime();
			bShowCaret = !bShowCaret;
		}
	}

	for(i=0; i<VisibleRows+1; i++)
	{
		ClipText(C, 2, WinHeight-YL*(i+1), TextArea[Line]);
		if(Line == Head && bShowCaret)
		{
			// Draw cursor..
			TextSize(C, TextArea[Line], W, H);
			ClipText(C, W, WinHeight-YL*(i+1), "|");
		}

		if(TempTail == Line)
			break;

		Line--;
		if(Line < 0)
			Line += BufSize;
	}
}


function AddText(string _szNewLine, Color _TextColor, Font _Font)
{

    TextColorArea[Lines] = _TextColor;
    TextFontArea[Lines] = _Font;
    TextArea[Lines] = _szNewLine;
    Lines += 1;
    /*
	local int i;

	TextArea[Head] = NewLine;
	Head = (Head + 1)%BufSize;

	if(Head == Tail)
		Tail = (Tail + 1)%BufSize;

	// Calculate lines for scrollbar.
	Lines = Head - Tail;

	if(Lines < 0)
		Lines += BufSize;


	if(bScrollable)
	{
		VertSB.SetRange(0, Lines, VisibleRows);
		VertSB.Pos = VertSB.MaxPos;
	}
    */
}


function AddTextWithCanvas( Canvas C, FLOAT _fXOffSet, FLOAT _fYOffset, string NewLine, Font _Font, Color FontColor)
{
    // the reason to fill an array of string, it's because you don't want to clip the text every frame, do it the 
    // first time and use the array after that

    local string szTempTextArea[szTextArraySize];
	local string Out, Temp, szTSResult;
    local FLOAT XWordPos, fWidthToReduce, fTotalWToReduce;
	local FLOAT WordWidth, WordHeight;
	local INT WordPos, TotalPos, PrevPos, TotalLinePos;
	local INT NumLines, PrevNumLines;
	local INT i, iRealSizeOfWord;
    local INT iNbLineTemp, iNbLineTempTotal;
	local BOOL bSentry;

    m_fXOffSet = _fXOffSet;
    m_fYOffSet = _fYOffset;

	fWidthToReduce  = _fXOffSet + 11; // 10 is the size of the scroll bar + 1 pixel -- should be a param
	fTotalWToReduce = (2 * _fXOffSet) + 11;

	//========================================================================
	// for each string verify if you not find \N  (indicate a carriage return)
	//========================================================================
	iNbLineTemp = 0;

    Temp = Caps(NewLine); // convert all caracter in capital, only for the special search (\N)
    szTempTextArea[iNbLineTemp] = NewLine;

    i = InStr(Temp, "\\N"); // \N means carriage return 

	while (i != -1)
	{
        // take the right part of the string (after the \N)
        Temp = Mid(szTempTextArea[iNbLineTemp], i + 2); //2 number of space that \N take
        // replace the test string by the left part
        szTempTextArea[iNbLineTemp] = Left(szTempTextArea[iNbLineTemp], i);

        iNbLineTemp+=1; // increase to next string to check
        szTempTextArea[iNbLineTemp] = Temp;

        Temp = Caps(Temp);

        i = InStr(Temp, "\\N"); // another \N find?
	}

    iNbLineTempTotal = iNbLineTemp;

	//========================================================================
	// parse all the temp array and wrap the text
	//========================================================================

	Out = "";
   	bSentry = True;
    iNbLineTemp = 0;
    XWordPos= _fXOffSet;		// at the beginning of the window + X

	while( bSentry )
	{
		// Get the line to be drawn.
		if(Out == "")
		{
            // Initialization
        	i = 0;
            PrevPos = 0;
            TotalLinePos = 0;
            TotalPos = 0;
        	NumLines = 1;
            PrevNumLines = 1;

			i++;
			Out = szTempTextArea[iNbLineTemp];
//            log("Out: "$Out);
		}

		// Find the word boundary.
		WordPos = InStr(Out, " ");
		
		// Get the current word.
		if(WordPos == -1)
        {
 			Temp = Out;
            WordPos = Len(Temp);
        }
		else
			Temp = Left(Out, WordPos)$" ";
   
        // specify this font for this word (in fact, the same font is keep for all the line)
        // if we need to add different font in the same line, a new design is need in this fct
        C.Font = _Font;
		szTSResult = TextSize(C, Temp, WordWidth, WordHeight, WinWidth - fTotalWToReduce);

        // the word is too big for the allow space? line is complete go to the next one
        if (WordWidth + XWordPos + fTotalWToReduce > WinWidth - _fXOffSet) // 10 is the size of the scroll bar + 1 pixel
		{
			if (XWordPos == _fXOffSet) // this happen if the word is too big for the width of the window
			{
				Temp = szTSResult;			// textsize already cut the word for available space
				WordPos = Len(Temp);		
				Out = Mid( Out, WordPos);	// remove the word from current sentence
	    		TotalPos += WordPos;
	            TotalLinePos += WordPos;
			}

			XWordPos = _fXOffSet;
			NumLines++;
		}
        else // go to next word
        {
            XWordPos += WordWidth;
    		TotalPos += (WordPos + 1);
            TotalLinePos += (WordPos + 1);
    		Out = Mid(Out, Len(Temp));
        }

		if ((Out == "") && (i > 0))
        {
   			bSentry = False;
        }


        if ((NumLines != PrevNumLines) || (!bSentry))
        {
            if (Lines >= szTextArraySize)
            {
                log("Small problem over here, string array overloaded in UWindowTextAreaControl.uc");
                break;
            }
            else
            {
                PrevNumLines = NumLines;

//                log("Prev Pos: "$PrevPos);
//                log("Total line pos: "$TotalLinePos);
                Temp = Mid(szTempTextArea[iNbLineTemp], PrevPos);//Mid(NewLine, PrevPos);
                TextArea[Lines] = left(Temp, TotalLinePos);

//                log("TextArea[] : "$TextArea[Lines]);
                TextColorArea[Lines] = FontColor;
                TextFontArea[Lines] = C.Font;
                PrevPos = TotalPos;
                TotalLinePos = 0;
                Lines += 1;
//                log("Lines: "$Lines);

                if ( (iNbLineTemp < iNbLineTempTotal) && (!bSentry) )
                {
                    iNbLineTemp+=1;
            	    Out = "";
                	bSentry = True;
                    XWordPos = _fXOffSet;
                }
            }
        }

//         log("===========================================");
	}
}

function Resized()
{
	if(bScrollable)
	{
		VertSB.SetRange(0, Lines, VisibleRows);
		if(bScrollOnResize)
			VertSB.Pos = VertSB.MaxPos;
	}
}

function SetPrompt(string NewPrompt)
{
	Prompt = NewPrompt;
}

function Clear( optional bool _bClearArrayOnly, optional bool _bWrapText)
{
    local INT i;

    if (Lines != 0)
    {
        for (i = 0; i < szTextArraySize; i++)
        {
            TextArea[i] = "";
            TextFontArea[i] = None;

            // substrack nb of lines
            Lines -= 1;

            if (Lines == 0) // if we have empty the array
                break;
        }
    }

	TextArea[0] = "";
    TextFontArea[0] = None;

    if (bScrollable) // if a scroll bar exist
        VertSB.Pos = 0; // if you change the text, the scroll bar need to be place at top at beginning
    
    if (_bWrapText)
    {
        m_bWrapClipText = true;
    }

    if (!_bClearArrayOnly)
    {
    	Head = 0;
    	Tail = 0;

        m_fXOffSet = 0;
        m_fYOffSet = 0;

        m_bWrapClipText = true;
    }
}

defaultproperties
{
     BufSize=200
     bScrollOnResize=True
     m_bWrapClipText=True
}
