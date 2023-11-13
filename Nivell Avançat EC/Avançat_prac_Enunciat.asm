.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C


;Subrutines cridades des de C
public C posCurScreen, getMove, moveCursor, moveCursorContinuous, openCard, openCardContinuous, openPair, openPairsContinuous, open2Players, Play
                         
;Variables utilitzades - declarades en C
extern C row:DWORD, col: BYTE, rowScreen: DWORD, colScreen: DWORD, RowScreenIni: DWORD, ColScreenIni: DWORD 
extern C carac: BYTE, tecla: BYTE, gameCards: DWORD, indexMat: DWORD
extern C Board: BYTE, firstVal: DWORD, firstRow: DWORD, firstCol: BYTE, secondVal: DWORD, secondRow: DWORD, secondCol: BYTE
extern C Player: DWORD, Num_Card: DWORD, HitPair: DWORD
extern C pairsPlayer1: Dword, pairsPlayer2:DWORD, Winner: DWORD;


.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable tecla.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch proc
   push ebp
   mov  ebp, esp
    
   ;push eax
   Push_all

   call getch_C
   
   mov [tecla],al
   
   ;pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables row (int) i col (char), a partir dels
; valors de les variables RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 4
; i convertir el char de la columna (A..D) a un número entre 0 i 3.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
;            rowScreen=rowScreenIni+(row*2)
;            colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor a la pantalla cridar a la subrutina gotoxy 
; que us donem implementada
;
; Variables utilitzades:	
;	row       : fila per a accedir a la matriu sea
;	col       : columna per a accedir a la matriu sea
;	rowScreen : fila on volem posicionar el cursor a la pantalla.
;	colScreen : columna on volem posicionar el cursor a la pantalla.
;	rowScreenIni : fila de la primera posició de la matriu a la pantalla.
;	colScreenIni : columna de la primera posició de la matriu a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreen proc
    push ebp
	mov  ebp, esp




	mov esp, ebp
	pop ebp
	ret

posCurScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat cridant a la subrutina que us donem implementada getch.
; Verificar que el caràcter introduït es troba entre els caràcters ’i’ i ’l’, 
; o bé correspon a les tecles espai ’ ’ o ’s’, i deixar-lo a la variable tecla.
; Si la tecla pitjada no correspon a cap de les tecles permeses, 
; espera que pitgem una de les tecles permeses.
;
; Variables utilitzades:
; tecla : variable on s’emmagatzema el caràcter corresponent a la tecla pitjada
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMove proc
   push ebp
   mov  ebp, esp




   mov esp, ebp
   pop ebp
   ret

getMove endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cridar a la subrutina getMove per a llegir una tecla
; Actualitzar les variables (row) i (col) en funció de
; la tecla pitjada que tenim a la variable (tecla) 
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, 
; (row) i (col) només poden 
; prendre els valors [1..5] i [A..D], respectivament. 
; Si al fer el moviment es surt del tauler, no fer el moviment.
; Posicionar el cursor a la nova posició del tauler cridant a la subrutina posCurScreen
;
; Variables utilitzades:
; tecla : caràcter llegit de teclat
; ’i’: amunt, ’j’:esquerra, ’k’:avall, ’l’:dreta 
; row : fila del cursor a la matriu gameCards.
; col : columna del cursor a la matriu gameCards.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursor proc
   push ebp
   mov  ebp, esp 




   mov esp, ebp
   pop ebp
   ret

moveCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continu
; del cursor fins que pitgem ‘s’ o ‘ espai ‘ ‘
; S’ha d’anar cridant a la subrutina moveCursor
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorContinuous proc
	push ebp
	mov  ebp, esp




	mov esp, ebp
	pop ebp
	ret

moveCursorContinuous endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina serveix per a poder accedir a les components de la matriu
; i poder obrir les caselles
; Calcular l’índex per a accedir a la matriu gameCards en assemblador.
; gameCards[row][col] en C, ´es [gameCards+indexMat] en assemblador.
; on indexMat = (row*4 + col (convertida a número))*4 .
;
; Variables utilitzades:
; row: fila per a accedir a la matriu gameCards
; col: columna per a accedir a la matriu gameCards
; indexMat: índex per a accedir a la matriu gameCards
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndex proc
	push ebp
	mov  ebp, esp
	



	mov esp, ebp
	pop ebp
	ret

calcIndex endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S’ha de cridar a movCursorContinuous per a triar la casella desitjada.
; Un cop som a la casella desitjada premem al tecla ‘ ‘ (espai per a veure el contingut)
; Calcular la posició de la matriu corresponent a la
; posició que ocupa el cursor a la pantalla, cridant a la subrutina calcIndexP1. 
; Mostrar el contingut de la casella corresponent a la posició del cursor al tauler.
; Considerar que el valor de la matriu és un  int (entre 0 i 9)
; que s’ha de “convertir” al codi ASCII corresponent. 
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
; row : fila per a accedir a la matriu gameCards
; col : columna per a accedir a la matriu gameCards
; indexMat : índex per a accedir a la matriu gameCards 
; gameCards : matriu 5x4 on tenim els valors de les cartes.
; carac : caràcter per a escriure a pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCard proc
	push ebp
	mov  ebp, esp





	mov esp, ebp
	pop ebp
	ret

openCard endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S’ha d'anar cridant a openCard fins que pitgem la tecla 's'
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCardContinuous proc
	push ebp
	mov  ebp, esp




	mov esp, ebp
	pop ebp
	ret

openCardContinuous endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la posició 3,30 de la pantalla cridant a la subturina gotoxy
; Mostrar el valor de la variable Num_Card (1 o 2)
; Posicionar el cursor a la posició 3,41 de la pantalla cridant a la subrutina gotoxy
; Mostrar el valor de la variable Player (1 o 2)
; Posicionar el cursor al taulell de joc i moure’l de forma continua fins que pitgem ‘s’ o ‘ ‘ 
; Quan pitgem ‘ ‘, obrim la casella (comprovar que no està oberta i marcar-la com oberta)
; Tornar a moure el cursor de forma continua fins que pitgem ‘s’ o ‘ ‘
; Quan pitgem ‘ ‘, obrim la casella (comprovar que no està oberta i marcar-la com oberta)
; Comprovar si els valors de les dues caselles coincideixen. Si coincideixen, posar un 1 a HitPair.
; Si no coincideixen, tancar les dues caselles i desmarcar-les com a obertes.
;
; Variables utilitzades:
; Num_Card: Variable que indica si estem obrint la primera o la segona casella de la parella.
; carac : caràcter a mostrar per pantalla
; row : fila del cursor a la matriu gameCards o Board.
; col : columna del cursor a la matriu gameCards o Board.
; rowScreen: Fila de la pantalla on volem posicionar el cursor.
; colScreen: Columna de la pantalla on volem posicionar el cursor.
; indexMat: Índex per accedir a la posició de la matriu.
; gameCards: Matriu amb els valors de les caselles del tauler.
; Board: Matriu que indica si la casella està oberta o no.
; firstVal, firstRow, firstCol: Dades relatives a la primera casella de la parella.
; secondVal, secondRow, secondCol: Dades relatives a la segona casella de la parella.
; Player: Indica el jugador al que li correspon el torn.
; HitPair: Variable que indica si s’ha fet una parella (0 No parell – 1 Parella)
; tecla: Codi ascii de la tecla pitjada.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openPair proc
	push ebp
	mov  ebp, esp






	mov esp, ebp
	pop ebp
	ret
openPair endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina ha d’anar cridant a la subrutina anterior OpenPair,
; fins que pitgem la tecla ‘s’
;
; Variables utilitzades:
; tecla: Codi ascii de la tecla pitjada.

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openPairsContinuous proc
	push ebp
	mov  ebp, esp




	mov esp, ebp
	pop ebp
	ret

openPairsContinuous endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la posició 3,50 de la pantalla cridant a la subturina gotoxy
; Mostrar el valor de la variable pairsPlayer1 i mostrar les parelles aconseguides pel jugador 1.
; Posicionar el cursor a la posició 3,57 de la pantalla cridant a la subturina gotoxy
; Mostrar el valor de la variable pairsPlayer2 i mostrar les parelles aconseguides pel jugador 2.
; Comença jugant el jugador 1 i cridem a openPair. 
; Mentre aconsegueixi parelles i no pitgi ‘s’
; seguirà jugant i s’anirà actualitzant el comptador de parelles
; Si no aconsegueix parella, el torn passa al jugador 2 que cridarà a openPair
; Mentre aconsegueixi parelles i no pitgi ‘s’
; seguirà jugant i s’anirà actualitzant el comptador de parelles
;
; Variables utilitzades:
; carac : caràcter a mostrar per pantalla
; rowScreen: Fila de la pantalla on volem posicionar el cursor.
; colScreen: Columna de la pantalla on volem posicionar el cursor.
; Player: Indica el jugador que te el torn.
; pairsPlayer1: Parelles aconseguides pel jugador 1
; pairsPlayer2: Parelles aconseguides pel jugador 2
; HitPair: Indica si s’ha aconseguit parella o no en una jugada
; tecla: Codi ascii de la tecla pitjada.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
open2Players proc
	push ebp
	mov  ebp, esp




	mov esp, ebp
	pop ebp
	ret

open2Players endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina Play anirà cridant a la subrutina open2Players
; mentre no pitgem ‘s’ i queden parelles per a descobrir. 
; Ha de posar a la variable Winner el jugador (1 o 2) que ha fet més parelles. 
; Si han fet les mateixes parelles, 
; ha de posar un 0. 
;
; Variables utilitzades:
; tecla: Codi ascii de la tecla pitjada.
; pairsPlayer1: Nombre de parelles aconseguides pel jugador 1
; pairsPlayer2: Nombre de parelles aconseguides pel jugador 2
; Winner: Jugador que ha aconseguit més parelles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Play proc
	push ebp
	mov  ebp, esp




	mov esp, ebp
	pop ebp
	ret

Play endp

END