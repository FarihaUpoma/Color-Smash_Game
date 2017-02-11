.MODEL SMALL
.STACK 100H
.DATA 

BLOCK DW 0,0,0,0,0
      DW 0,0,0,0,0
      DW 0,0,0,0,0
      DW 0,0,0,0,0
      DW 0,0,0,0,0
      
      
COLOR DW 4,3,6,5,4,5,2,6,4,5,6,4,2,4,2,4,1,6,6,2,4,3,2,5,6,6,6,3,5,4,5,3,5,2,6,2,2,4,3,2,3,6,4,2,4,1,3,2,6,1

INIT_SCORE DB 'SCORE: 0$'
SCOREBOARD DB 'SCORE: $' 
SCORES DW 100 DUP (?)
TEMP_SCORE DW 100 DUP (?)
SCORE DW 0 
DIG DW ?

;MENU
MSG_MENU DB 'OPTIONS$'
MSG_NG DB 'NEW GAME$'
MSG_EXIT DB 'EXIT$'
GAME_NAME DB 'THE TRI-WIZARD TOURNAMENT!$'
LOSER DB ?

;SCAN CODES
UP_ARROW = 72
DOWN_ARROW = 80
ENTER_KEY = 28

POINTER DB ?
ESC_FLAG DB 0 

CHK_FLAG DW ?
LF DW 0
RF DW 0
MF DW 0
RR DW ?
CC DW ?
TMP_RR DW ?
TMP_CC DW ?

IT DW 0
A DW ?
B DW ?
C DW ?
D DW ?
FLAG1 DW 0 
CHANGE_ROW DW ?
ROW DW ?
COLUMN DW ? 
TEMP_COL DW ? ;for moving The block
CM_ROW DW ?
CM_COLUMN DW ?
TEMP_CM_ROW DW ?
TMP DB ?
TEMP DW ?
BOXFLAG DW 0

GAME_OVER DB "GAME OVER !!$"
ESC_PRESS DB 'PRESS ESC TO GO BACK TO MENU$'
SCAN_CODE DB ?
ESC_KEY = 1
LEFT_ARROW = 75
RIGHT_ARROW = 77

INIT_CX DW ?
INIT_DX DW ?
INIT_C DW ?

DRAW_ROW MACRO X
    LOCAL L1
    MOV AH, 0CH
    
    MOV CX, 130
    MOV DX, X
L1:
    INT 10H
    INC CX
    CMP CX, 190
    JL L1    
ENDM

DRAW_COLUMN MACRO Y
    LOCAL L2
    MOV AH, 0CH
    
    MOV CX, Y
    MOV DX, 139
L2:
    INT 10H
    INC DX
    CMP DX, 199
    JL L2
ENDM

PUSH_ALL MACRO
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
ENDM

POP_ALL MACRO
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
ENDM

REPAINT_CURSOR MACRO
    MOV AH, 9
    MOV BH, 1
    MOV AL, 3EH
    MOV CX, 1
    MOV BL, 77H
    INT 10H
ENDM     

.CODE 

PRINT_BLOCK PROC
    
    PUSH AX
    PUSH BX 
    PUSH CX
    PUSH DX
    PUSH SI
    
    XOR BX,BX
    XOR SI,SI
    MOV CX,1
    
    MOV AH,2 
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H
    
    FOR1_2:
    CMP CX,6
    JE END1_2
    
    FOR2_2:
    CMP SI,10
    JE LOOP_FOR1_2
    
    XOR DX,DX
    MOV DX,BLOCK[BX][SI]
    ADD DX,'0'
    XOR AX,AX
    MOV AH,2
    INT 21H
    MOV DL,' '
    INT 21H
    ADD SI,2
    JMP FOR2_2
    
    LOOP_FOR1_2:
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H
    
    MOV AX,10
    INC CX
    MOV BX,CX
    SUB BX,1
    MUL BX
    MOV BX,AX
    XOR SI,SI
    JMP FOR1_2
    
    END1_2:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
    
    PRINT_BLOCK ENDP

PRINT_BLOCK2 PROC
    
    PUSH AX
    PUSH BX 
    PUSH CX
    PUSH DX
    PUSH SI
    
    XOR BX,BX
    XOR SI,SI
    MOV CX,1
    
    MOV AH,2 
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H
    
    FOR1_3:
    CMP CX,6
    JE END1_3
    
    FOR2_3:
    CMP SI,10
    JE LOOP_FOR1_3
    
    XOR DX,DX
    MOV DX,BLOCK[BX][SI]
    ADD DX,'0'
    XOR AX,AX
    MOV AH,2
    INT 21H
    MOV DL,' '
    INT 21H
    ADD SI,2
    JMP FOR2_3
    
    LOOP_FOR1_3:
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H
    
    MOV AX,10
    INC CX
    MOV BX,CX
    SUB BX,1
    MUL BX
    MOV BX,AX
    XOR SI,SI
    JMP FOR1_3
    
    END1_3:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
    
    PRINT_BLOCK2 ENDP  

CHECK_AGAIN PROC 
    
    PUSH_ALL
    ;MOV LF, 0
    MOV RF, 0 
    
CHK_ROW:    
    MOV BX,0
    MOV SI,0
    MOV CHK_FLAG, 0
    
LCS1:
    CMP BX,50
    JE CHK_COLUMN
    
LCS2:
    CMP SI,6
    JE LOOP_LCS1
    
CMP1:
    MOV DX,BLOCK[BX][SI]
    ADD SI,2
    CMP DX, 0
    JE LCS2
    CMP DX,BLOCK[BX][SI]
    JNE LCS2
    
CMP2:
    MOV DX,BLOCK[BX][SI]
    ADD SI,2
    CMP DX,BLOCK[BX][SI]
    JE CLEAR_BLOCK_AGAIN
    SUB SI,2
    JMP LCS2
    
LOOP_LCS1:
    ADD BX,10
    XOR SI,SI
    JMP LCS1
    
    CMP CHK_FLAG, 0
    JE CHK_COLUMN
    
CLEAR_BLOCK_AGAIN:
    ;ADD SCORE,1
    ;CALL SHOW_SCORE
    MOV CHK_FLAG, 1
    MOV RR, BX
    MOV CC, SI
    
    MOV BLOCK[BX][SI],0
    SUB SI,2
    MOV BLOCK[BX][SI],0
    SUB SI,2
    MOV BLOCK[BX][SI],0
    ADD SI,4
        
    CALL MOVE_ARRAY
    MOV RF, 1
    CALL UPDATE_ARRAY
    ADD SCORE,1
    CALL SHOW_SCORE
    JMP CHK_ROW

CHK_COLUMN:
   
    MOV BX,0
    MOV SI,0
    MOV CHK_FLAG, 0 
    
LIS1:
    CMP SI,10
    JE JMP_END
    
LIS2:
    CMP BX,30
    JE LOOP_LIS1
    
CMP3:
    MOV DX,BLOCK[BX][SI]
    ADD BX,10
    CMP DX,0
    JE LIS2
    CMP DX,BLOCK[BX][SI]
    JNE LIS2
    
CMP4:
    MOV DX,BLOCK[BX][SI]
    ADD BX,10
    CMP DX,BLOCK[BX][SI]
    JE CLEAR_BLOCK_AGAIN1
    SUB BX,10
    JMP LIS2
    
LOOP_LIS1:
    ADD SI,2
    XOR BX,BX
    JMP LIS1
JMP_END:    
    CMP CHK_FLAG, 0
    JE END_CHK

CLEAR_BLOCK_AGAIN1:
    MOV CHK_FLAG, 1
    MOV RR, BX
    MOV CC, SI
    
    MOV BLOCK[BX][SI],0
    SUB BX,10
    MOV BLOCK[BX][SI],0
    SUB BX,10
    MOV BLOCK[BX][SI],0
    ADD BX,20
    
    SUB RR,20    
    CALL MOVE_ARRAY
    ADD RR,10
    CALL MOVE_ARRAY
    ADD RR,10
    CALL MOVE_ARRAY
    ADD SCORE,1
    CALL SHOW_SCORE
    JMP CHK_COLUMN 
    
END_CHK:
    
    POP_ALL
    RET
    
CHECK_AGAIN ENDP
 

CHECK_COLOR_MATCH PROC
    
     PUSH_ALL
     
     MOV LF,0
     MOV RF,0
     MOV MF,0
     
     MOV CX,CHANGE_ROW
     MOV CM_ROW,CX
     ;MOV CX,COLUMN
     ;MOV CM_COLUMN,CX 
     
     MOV SI,COLUMN
     MOV BX,ROW 
     
CHECK_COL: 
     
     MOV DX,TEMP_COL
     
LEFTMOST:
     
     MOV DX,BLOCK[BX][SI]
     
L1:
     CMP SI,8
     JE RIGHTMOST
     CMP SI,6
     JE RIGHTMOST
     ADD SI,2
     CMP DX,BLOCK[BX][SI]
     JE L2
     SUB SI,2 
     MOV DX,BLOCK[BX][SI]
     JMP RIGHTMOST
     
L2:
     ADD SI,2
     CMP DX,BLOCK[BX][SI]
     JE JMP_LEFT 
     SUB SI,2
     SUB SI,2
     JMP RIGHTMOST
     
JMP_LEFT:
     JMP CLEAR_LEFTMOST
     
RIGHTMOST:
     
     MOV DX,BLOCK[BX][SI]
     
R1:
     CMP SI,0
     JE TOP
     CMP SI,2
     JE MIDDLE
     SUB SI,2 
     CMP DX,BLOCK[BX][SI]
     JE R2 
     ADD SI,2 
     MOV DX,BLOCK[BX][SI]
     JMP MIDDLE
     
R2:
     SUB SI,2
     CMP DX,BLOCK[BX][SI]
     JE JMP_RIGHT
     ADD SI,2
     ADD SI,2
     JMP MIDDLE
     
JMP_RIGHT:
     JMP CLEAR_RIGHTMOST
     
MIDDLE:
     CMP SI,0
     JE TOP
     CMP SI,8
     JE TOP
     MOV DX,BLOCK[BX][SI]
     
LM1:
     SUB SI,2
     CMP DX,BLOCK[BX][SI]
     JE RM1
     ADD SI,2 
     MOV DX,BLOCK[BX][SI]
     JMP TOP
     
RM1:
     ADD SI,2
     ADD SI,2
     CMP DX,BLOCK[BX][SI]
     JE JMP_MIDDLE
     SUB SI,2
     JMP TOP
     
JMP_MIDDLE:
     SUB SI,2
     JMP CLEAR_MIDDLE
     
TOP:
     CMP BX,40
     JE END_COL_TOP
     CMP BX,30
     JE END_COL_TOP
     
     MOV DX,BLOCK[BX][SI]
     
T1: 
     ADD BX,10
     CMP DX,BLOCK[BX][SI]
     JE T2
     SUB BX,10 
     MOV DX,BLOCK[BX][SI]
     JMP END_COL_MATCH
     
T2:
     ADD BX,10
     CMP DX,BLOCK[BX][SI] 
     JE JMP_TOP
     SUB BX,10
     SUB BX,10
     JMP END_COL_MATCH
     
JMP_TOP:
     JMP CLEAR_TOP 
     
END_COL_TOP:
     JMP END_COL_MATCH
     
CLEAR_BLOCK:
     
CLEAR_LEFTMOST:
     
     MOV BLOCK[BX][SI],0
     SUB SI,2           
     MOV BLOCK[BX][SI],0
     SUB SI,2
     MOV BLOCK[BX][SI],0
     
     MOV RR, BX
     MOV CC, SI
     ADD SCORE, 1
     CALL SHOW_SCORE
     
     MOV LF, 1
     CALL UPDATE_ARRAY
     CALL CHECK_AGAIN
     
     JMP END_COL_MATCH
     
CLEAR_RIGHTMOST:
     
     MOV BLOCK[BX][SI],0
     ADD SI,2           
     MOV BLOCK[BX][SI],0
     ADD SI,2
     MOV BLOCK[BX][SI],0
     
     MOV RR, BX
     MOV CC, SI
     ADD SCORE, 1
     CALL SHOW_SCORE
     
     
     MOV RF, 1
     CALL UPDATE_ARRAY
     CALL CHECK_AGAIN
     
     JMP END_COL_MATCH
     
CLEAR_MIDDLE:
     MOV RR, BX
     MOV CC, SI
     MOV BLOCK[BX][SI],0
     SUB SI,2           
     MOV BLOCK[BX][SI],0
     ADD SI,2
     ADD SI,2
     MOV BLOCK[BX][SI],0
     
     
     ADD SCORE, 1
     CALL SHOW_SCORE
     
     MOV MF, 1
     CALL UPDATE_ARRAY
     CALL CHECK_AGAIN
     
     JMP END_COL_MATCH
      
     
CLEAR_TOP:
     SUB BX,10
     SUB BX,10
     MOV BLOCK[BX][SI],0
     ADD BX,10
     MOV BLOCK[BX][SI],0
     ADD BX,10
     MOV BLOCK[BX][SI],0
     
     ADD SCORE, 1
     CALL SHOW_SCORE
     
     JMP END_COL_MATCH  
     
END_COL_MATCH:
     
     POP_ALL
     RET
     
CHECK_COLOR_MATCH ENDP
     
UPDATE_ARRAY PROC
    PUSH_ALL
    
    MOV CX, RR
    MOV TMP_RR, CX
    MOV CX, CC
    MOV TMP_CC, CX

LEFTMOST_CASE:    
    CMP LF, 1
    JNE RIGHTMOST_CASE
    ADD CC, 2
    CALL MOVE_ARRAY
    
    MOV CX, TMP_RR
    MOV RR, CX
    
    ADD CC, 2
    CALL MOVE_ARRAY
    MOV LF, 0
    JMP END_UA
RIGHTMOST_CASE:
    CMP RF, 1
    JNE MIDDLE_CASE
    SUB CC, 2
    CALL MOVE_ARRAY
    
    MOV CX, TMP_RR
    MOV RR, CX
    
    SUB CC, 2
    CALL MOVE_ARRAY
    MOV RF, 0
    JMP END_UA
MIDDLE_CASE:
    CMP MF, 1
    JNE END_UA
    ADD CC, 2
    CALL MOVE_ARRAY
    
    MOV CX, TMP_RR
    MOV RR, CX
    
    SUB CC, 4
    CALL MOVE_ARRAY
    MOV MF, 0
END_UA:
    POP_ALL
    RET
UPDATE_ARRAY ENDP

MOVE_ARRAY PROC
    PUSH_ALL
    
    MOV BX, RR
    MOV SI, CC
    
    SUB BX, 10
LOOP_MA:
    CMP BLOCK[BX][SI], 0
    JE END_MA
    MOV DX, BLOCK[BX][SI]
    MOV BLOCK[BX][SI], 0
    XCHG BX, RR
    XCHG SI, CC
    MOV BLOCK[BX][SI], DX
    XCHG BX, RR
    XCHG SI, CC
    SUB RR, 10
    SUB BX, 10
    JMP LOOP_MA
END_MA:
    POP_ALL
    RET
MOVE_ARRAY ENDP            

MOVEMENT PROC 
    
    PUSH_ALL

MOVE_BLOCK:    
    XOR AX,AX
    MOV SI,COLUMN
    ;MOV ROW,1
    ;XOR BX,BX
    MOV BX,ROW
    MOV DX,BLOCK[BX][SI]
    MOV TEMP_COL,DX    
    
    MOV AH,0
    INT 16H
    MOV SCAN_CODE, AH
    CMP AH,ESC_KEY
    JE BOTTOM
    
    CMP AH,LEFT_ARROW
    JE LEFT
    
    CMP AH,RIGHT_ARROW
    JE RIGHT   
    
    JMP DOWN
    
BOTTOM:
    JMP END_ESC
    
DOWN:
    ADD BX,10 
    CMP BLOCK[BX][SI],0
    JE MOV_DOWN
    SUB BX,10
    JMP END_MOVE
    
MOV_DOWN:
    SUB BX,10
    MOV BLOCK[BX][SI],0
    MOV TEMP_COL,DX
    ;INC CHANGE_ROW
    ;SUB CHANGE_ROW,1
    ;MOV BX,CHANGE_ROW
    INC CHANGE_ROW
    ;MOV AX,10
    ADD BX,10
    ;MOV BX,AX
    MOV DX,TEMP_COL
    MOV BLOCK[BX][SI],DX       
    
    JMP END_MOVE
    
LEFT:
    CMP SI,0
    JE END_MOVE       
    SUB SI,2 
    CMP BLOCK[BX][SI],0
    JE MOV_LEFT
    ADD SI,2
    JMP END_MOVE
    
MOV_LEFT:
    ADD SI,2
    MOV BLOCK[BX][SI],0
    SUB SI,2
    MOV BLOCK[BX][SI],DX
    JMP END_MOVE
    
RIGHT:
    CMP SI,8
    JE END_MOVE 
    ADD SI,2
    CMP BLOCK[BX][SI],0
    JE MOV_RIGHT
    SUB SI,2
    JMP END_MOVE
    
MOV_RIGHT:
    SUB SI,2
    MOV BLOCK[BX][SI],0
    ADD SI,2
    MOV BLOCK[BX][SI],DX 
    JMP END_MOVE
    
END_MOVE:   
    
    MOV ROW,BX
    MOV COLUMN,SI
    
    ;CALL PRINT_BLOCK2
    CALL DRAW_ARRAY
     
    CMP BX,40
    JE END_MOV_FINAL
    ADD BX,10
    CMP BLOCK[BX][SI],0
    JE JMP_MOVE
    JMP END_MOV_FINAL
    
JMP_MOVE:
    JMP MOVE_BLOCK
    
END_MOV_FINAL:
    
    MOV BX,ROW
    MOV SI,COLUMN
    
    MOV DX,BLOCK[BX][SI]
    MOV TEMP_COL,DX
    
    CALL CHECK_COLOR_MATCH
    ;CALL PRINT_BLOCK2
END_ESC:    
    POP_ALL
    RET
    
MOVEMENT ENDP  
    
YOU_LOSE PROC
    PUSH_ALL
    
    MOV AH, 2
    MOV DH, 5
    MOV DL, 15
    MOV BH, 0
    INT 10H
    MOV AH, 9
    LEA DX, GAME_OVER
    INT 21H
    
    MOV AH, 2
    MOV DH, 8
    MOV DL, 6
    MOV BH, 0
    INT 10H
    MOV AH, 9
    LEA DX, ESC_PRESS
    INT 21H
    
    MOV LOSER, 1
    POP_ALL  
    RET
YOU_LOSE ENDP     
    

NEW_BLOCK_GENERATION PROC
    
    PUSH_ALL
                   
    MOV SI, 4
    XOR BX, BX
    CMP BLOCK[BX][SI],0
    JNE LONGBOTTOM
    LEA DI, COLOR
    ADD DI, IT
    MOV AX, [DI]
    MOV BLOCK[BX][SI],AX 
    
    ;CALL PRINT_BLOCK
    CALL DRAW_ARRAY
    
    MOV ROW,BX
    MOV CHANGE_ROW,BX
    INC CHANGE_ROW
    MOV COLUMN,SI
    
    JMP END_BOT
    
LONGBOTTOM:
    
    CALL YOU_LOSE
    
END_BOT:    

    POP_ALL    
    RET
    
NEW_BLOCK_GENERATION ENDP

DRAW_ARRAY PROC
    PUSH_ALL
    
    XOR BX, BX
    XOR SI, SI
    ;LEA BX, BLOCK
    MOV CX, 131
    MOV DX, 140
    MOV INIT_CX, CX
LOOP1_DA:    
    CMP SI, 10
    JE LOOP2_DA
    MOV AX, BLOCK[BX][SI]
    MOV TEMP, AX
    CALL DRAW_BLOCK
    ADD SI, 2
    ADD CX, 12
    JMP LOOP1_DA
LOOP2_DA:
    ADD BX, 10    
    XOR SI, SI
    ADD DX, 12
    MOV CX, INIT_CX
    CMP BX, 50
    JE END_DA
    JMP LOOP1_DA
END_DA:
    POP_ALL
    RET
DRAW_ARRAY ENDP

DRAW_BLOCK PROC
    PUSH_ALL
      
    ADD CX, 10
    MOV C, CX
    SUB CX, 10
    ADD DX, 10
    MOV D, DX
    SUB DX, 10
    MOV INIT_C, CX
    MOV INIT_DX, DX
    
    ;MOV AX, TEMP 
    ;MOV BL, 4 
    ;DIV BL
    
    MOV DX, INIT_DX
    MOV AX, TEMP
    XOR AH, AH
    MOV TMP, AL
    
    MOV AH, 0BH   
    MOV BH, 1
    MOV BL, 1
    INT 10H
  
    MOV AH, 0CH
    MOV AL, TMP
    MOV BH, 0
    
LOOP1_DB:
    CMP DX, D
    JE END1_DB
LOOP2_DB:
    CMP CX, C
    JE L1_DB
    INT 10H
    INC CX
    JMP LOOP2_DB
L1_DB:
    INC DX
    MOV CX, INIT_C 
    JMP LOOP1_DB        
END1_DB:
    POP_ALL
    RET
DRAW_BLOCK ENDP                
 
SHOW_SCORE PROC
    PUSH_ALL
    
    MOV AX,SCORE
    XOR CX,CX
    MOV BX,10
    
    LEA SI,TEMP_SCORE
    
REP1: 
    
    XOR DX,DX
    DIV BX
    MOV [SI],DX
    ADD SI,2
    INC CX
    
    OR AX,AX
    JNE REP1 
    
    MOV DIG,CX
    SUB SI,2
    
    MOV AX,2
    MUL CX
    MOV CX,AX
    SUB CX,2
    
    LEA DI,SCORES
    ;ADD DI,CX
    
    MOV DX,SCORE 
    
REP2:   
    
    CMP CX,0
    JE END_REP2
    
    MOV DX,[SI]
    ADD DX,'0'
    MOV WORD PTR [DI],DX
    ADD DI,2
    SUB CX,2
    SUB SI,2
    JMP REP2   
    
END_REP2:
    MOV DX,[SI]
    ADD DX,'0'
    MOV WORD PTR [DI],DX
    MOV CX,DIG
    MOV AX,2
    MUL CX
    MOV CX,AX
    ADD DI,CX
    MOV SCORES[DI],'$'
    
    MOV AH, 2
    MOV DH, 2
    MOV DL, 16
    MOV BH, 0
    INT 10H
    MOV AH, 9
    LEA DX, SCOREBOARD
    INT 21H
    LEA DX,SCORES
    INT 21H 
          
    POP_ALL  
    RET
SHOW_SCORE ENDP     

SET_DISPLAY_MODE PROC
    MOV AH, 0
    MOV AL, 13H
    INT 10H  
    
BACKGROUND:
    MOV AL, 1
    DRAW_ROW 139
    DRAW_ROW 199
    DRAW_COLUMN 130
    DRAW_COLUMN 190
    MOV AL, 15
    MOV BX, 151
 
DRAWING_ROW:    
    DRAW_ROW BX
    ADD BX, 12
    CMP BX, 199
    JNE DRAWING_ROW
    MOV BX, 142
    
DRAWING_COLUMN:    
    DRAW_COLUMN BX
    ADD BX, 12
    CMP BX, 190
    JNE DRAWING_COLUMN
INITIAL_SCORE:
    MOV AH, 2
    MOV DH, 2
    MOV DL, 16
    MOV BH, 0
    INT 10H
    MOV AH, 9
    LEA DX, INIT_SCORE
    INT 21H    
    
    RET
SET_DISPLAY_MODE ENDP

MENU_SCREEN PROC
    PUSH_ALL
SET_MODE:    
    MOV AX, 03h
    INT 10H
DIS_PAGE:
    MOV AH, 5
    MOV AL, 1
    INT 10H
HIDE_CURSOR:
    MOV AH, 1
    ADD CH, 20H
    INT 10H    
MOVE_CURSOR:
    MOV AH, 2
    MOV DX, 021CH
    MOV BH, 1
    INT 10H        
COLOR_CRUSH:
    MOV AH, 9
    LEA DX, GAME_NAME 
    INT 21H        
SCROLL_WINDOW_BLUE:    
    MOV AH, 6
    MOV CX, 519H
    MOV DX, 1637H
    MOV BH, 30H
    MOV AL, 0
    INT 10H
MOVE_CURSOR1:
    MOV AH, 2
    MOV DX, 0625H
    MOV BH, 1
    INT 10H        
MENU:
    MOV AH, 9
    LEA DX, MSG_MENU 
    INT 21H 
SCROLL_WINDOW_GRAY:
    MOV AH, 6
    MOV CX, 0A23H
    MOV DX, 122DH
    MOV BH, 70H
    MOV AL, 0
    INT 10H
  
MOVE_CURSOR2:
    MOV AH, 2
    MOV DX, 0B25H
    MOV BH, 1
    INT 10H
                   
DIS_MSG1:
    MOV AH, 9
    ;MOV BH, 1
    ;MOV BL, 0C3H
    LEA DX, MSG_NG
    INT 21H
    
    
MOVE_CURSOR3:
    MOV AH, 2
    MOV DX, 0E25H
    MOV BH, 1
    INT 10H
DIS_MSG2:
    MOV AH, 9
    ;MOV BH, 1
    ;MOV BL, 0C3H
    LEA DX, MSG_EXIT
    INT 21H
POINTER1:
    MOV POINTER, 2
    JMP MOVE_NG    
KEYBOARD:
    MOV AH, 0
    INT 16H
    CMP AH, 48H
    JE MOVE_NG
    CMP AH, 50H
    JE MOVE_EXIT
    CMP AH, 1CH
    JE PRESS_ENTER    

MOVE_NG:
    CMP POINTER, 1
    JE POINT
    DEC POINTER
    REPAINT_CURSOR
    MOV AH, 2
    MOV DX, 0B24H
    MOV BH, 1
    INT 10H
    JMP POINT
         
MOVE_EXIT:
    CMP POINTER, 2
    JE POINT
    INC POINTER
    
    REPAINT_CURSOR
           
    MOV AH, 2
    MOV DX, 0E24H
    MOV BH, 1
    INT 10H
    
POINT:
    MOV AH, 9
    MOV BH, 1
    MOV AL, 3EH
    MOV CX, 1
    MOV BL, 0F8H
    INT 10H
    JMP KEYBOARD    
    
PRESS_ENTER:
    CMP POINTER, 2
    JNE END_MENU
             
ESCAPE:
    MOV ESC_FLAG, 1    
END_MENU:    
    POP_ALL
    RET
MENU_SCREEN ENDP

CLEAR_ARRAY PROC
    PUSH_ALL
    
    XOR BX, BX
    XOR SI, SI
    
LOOP1_CA:
    CMP SI, 10
    JE LOOP2_CA
    MOV BLOCK[BX][SI], 0
    ADD SI, 2
    JMP LOOP1_CA
LOOP2_CA:
    CMP BX, 40
    JE END_CA
    ADD BX, 10  
    XOR SI, SI
    JMP LOOP1_CA    
END_CA:
    POP_ALL
    RET
CLEAR_ARRAY ENDP        
        

MAIN PROC
     
    MOV AX,@DATA
    MOV DS,AX
    
GET_MENU:
    MOV SCORE, 0 
    MOV ESC_FLAG, 0
    MOV LOSER, 0
    MOV IT, 0    
    CALL MENU_SCREEN
    CMP ESC_FLAG, 1
    JE END_MAIN
    CALL SET_DISPLAY_MODE
    CALL CLEAR_ARRAY
    CALL DRAW_ARRAY    
    
GAME_START:
    MOV AX, 98
    CMP IT, AX
    JE SET_IT

CALLING:        
    CALL NEW_BLOCK_GENERATION  
    CMP LOSER, 1
    JE PRESS_ESC
    
    ADD IT, 2
    
    JMP MOVEMENT_START
    
SET_IT:
    MOV AX, 0
    MOV IT, AX
    JMP CALLING     
    
MOVEMENT_START:
    CALL MOVEMENT
    CMP SCAN_CODE, ESC_KEY
    JE GET_MENU
    ;CALL PRINT_BLOCK2
    
    JMP GAME_START
    
PRESS_ESC:
    MOV AH, 0
    INT 16H
    CMP AH, ESC_KEY
    JE GET_MENU
    JMP PRESS_ESC    
    
END_MAIN:
    MOV AX,3
    INT 10H
    
    MOV AH, 5
    MOV AL, 0
    INT 10H
    
    MOV AH,4CH
    INT 21H 
    
MAIN ENDP
END MAIN


    
    
        