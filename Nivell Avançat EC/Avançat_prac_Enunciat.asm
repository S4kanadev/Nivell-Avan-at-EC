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
; en funci� de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funci� gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funci� gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els par�metres s'han de passar per la pila
      
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
; Mostrar un car�cter, guardat a la variable carac
; en la pantalla en la posici� on est� el cursor,  
; cridant a la funci� printChar_C.
; 
; Variables utilitzades: 
; carac : variable on est� emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqu�
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funci�  printch_C(char c) des d'assemblador, 
   ; el par�metre (carac) s'ha de passar per la pila.
 
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
; Llegir un car�cter de teclat   
; cridant a la funci� getch_C
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
; Posicionar el cursor a la pantalla, dins el tauler, en funci� de
; les variables row (int) i col (char), a partir dels
; valors de les variables RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 4
; i convertir el char de la columna (A..D) a un n�mero entre 0 i 3.
; Per calcular la posici� del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes f�rmules:
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
;	rowScreenIni : fila de la primera posici� de la matriu a la pantalla.
;	colScreenIni : columna de la primera posici� de la matriu a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreen proc
        push ebp
	mov  ebp, esp

	push eax
	push ebx
								;Al no poder accedir M,M utilitzem registres auxiliars
	mov  eax, 0					;Inicialitzacio del registre eax
	mov  ebx, 0					;Inicialitzacio del registre ebx

								;rowScreen formula (rowScreen=rowScreenIni+(row*2))
	mov  eax, [row]				;Carreguem el contingut de la variable [row] a eax
	dec  eax					;Restem 1 perqu� quedi entre 0 i 4 
	shl  eax, 1					;Multipliquem per 2
	add  eax, [rowScreenIni]	;Sumem el valor de eax amb el contingut de la variable [rowScreenIni]
	mov  [rowScreen], eax		;El resultat de eax el guardem a la variable [rowScreen]

								;colScreen formula (colScreen=colScreenIni+(col*4)
	mov  bl, [col]				;Carreguem el contingut de la variable [col] al registre de 8 bits bl
	sub  ebx, 65				;Restem la "A" per obtenir el numemro de columna 
	shl  ebx, 2					;Multipliquem per 4 
	add  ebx, [colScreenIni]	;Sumem el valor de ebx amb el contingut de la variable [colScreenini]
	mov  [colScreen], ebx		;El resultat de ebx al guardem a la variable [colScreen]
								
	call gotoxy					;Cridar la subrutina gotoxy


	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret

posCurScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat cridant a la subrutina que us donem implementada getch.
; Verificar que el car�cter introdu�t es troba entre els car�cters �i� i �l�, 
; o b� correspon a les tecles espai � � o �s�, i deixar-lo a la variable tecla.
; Si la tecla pitjada no correspon a cap de les tecles permeses, 
; espera que pitgem una de les tecles permeses.
;
; Variables utilitzades:
; tecla : variable on s�emmagatzema el car�cter corresponent a la tecla pitjada
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMove proc
   push ebp
   mov  ebp, esp
   
   push eax

   mov  eax, 0					;Inicialitzacio del registre auxiliar eax

   bucle:
		call getch				;Crida subrutina getch (llegeix caracter)

   mov  al, [tecla]				;Copiar la tecla apretada al registre al (8 bits perque es char)

   cmp  al, 's'					;Comprobar si la tecla es igual a 's'
   je   fi						;Si es igual saltar a fi

   cmp  al, ' '					;Comprobar si la tecla es igual a ' ' (espai)
   je   fi						;Si es igual saltar a fi

   cmp  al, 'i'					;Comprobar si la tecla es igual o superior a 'i'
   jl   bucle					;Si es inferior saltar a bucle

   cmp  al, 'l'					;Comprobar si la tecla es igual o infrior a 'l'
   jg   bucle					;Si es major saltar a bucle

   jmp  fi						;Saltar a fi

   fi:
	   mov [tecla], al			;Copiar el valor del registre al a [tecla]
	
	pop eax

	mov esp, ebp
	pop ebp
	ret

getMove endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cridar a la subrutina getMove per a llegir una tecla
; Actualitzar les variables (row) i (col) en funci� de
; la tecla pitjada que tenim a la variable (tecla) 
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, 
; (row) i (col) nom�s poden 
; prendre els valors [1..5] i [A..D], respectivament. 
; Si al fer el moviment es surt del tauler, no fer el moviment.
; Posicionar el cursor a la nova posici� del tauler cridant a la subrutina posCurScreen
;
; Variables utilitzades:
; tecla : car�cter llegit de teclat
; �i�: amunt, �j�:esquerra, �k�:avall, �l�:dreta 
; row : fila del cursor a la matriu gameCards.
; col : columna del cursor a la matriu gameCards.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursor proc
   push ebp
   mov  ebp, esp

   push eax
   push ebx

   mov eax, 0;
   mov ebx, 0;

   call getMove						;Crida subrutina getMove (llegeix tecla)

   mov  eax, [row]					;Inicialitzacio del registre eax amb el valor de [row]
   mov  bl,  [col]					;Inicialitzacio del registre bl amb el valor de [col]

   cmp  [tecla], 'i'				;Comprobar si la tecla pitjada es igual a 'i'
   je   up							;Si es igual saltar a up
   
   cmp  [tecla], 'j'				;Comprobar si la tecla pitjada es igual a 'j'
   je   left						;Si es igual saltar a left

   cmp  [tecla], 'k'				;Comprobar si la tecla pitjada es igual a 'k'
   je   down						;Si es igual saltar a down

   cmp  [tecla], 'l'				;Comprobar si la tecla pitjada es igual a 'l'
   je   right						;Si es igual saltar a right

   cmp  [tecla], 's'				;Comprobar si la tecla pitjada es igual a 's'
   je   fi							;Si es igual saltar a fi

   cmp  [tecla], ' '				;Comprobar si la tecla pitjada es igual a ' ' (espai)
   je   fi

   up:								
		dec  eax					;Incrementar fila (Decrementar eax)
		jmp  check_range			;Saltar a check_range

   left:							
	   dec  bl						;Decrementar columna
	   jmp  check_range				;Saltar a check_range

   down:
	   inc  eax						;Decrementar fila (incrementar eax)
	   jmp  check_range				;Saltara a check_range

   right:
	   inc  bl						;Incrementar columna
	   jmp  check_range				;Saltar a check_range

   check_range:						;Comprovar que la fila i la columna estiguin dins dels limits
	   cmp  eax, 1					;limits: ([1..5] i ['A'..'D'])
	   jl   fi
	   cmp  eax, 5
	   jg   fi
	   cmp  bl, 'A'
	   jl   fi
	   cmp  bl, 'D'
	   jg   fi

	   mov  [row], eax				;Actualitzar valors de [row]
	   mov  [col], bl				;Actualitzar valors de [col]

	   jmp  posCur					;saltar a posCur 

   posCur:
	   call posCurScreen			;Cridar subrutina posCurScreen (posiciona cursor)
	   jmp fi						;Saltar a fi

   fi:
	   pop ebx
	   pop eax
	   mov esp, ebp
	   pop ebp
	   ret

moveCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continu
; del cursor fins que pitgem �s� o � espai � �
; S�ha d�anar cridant a la subrutina moveCursor
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorContinuous proc
	push ebp
	mov  ebp, esp

	bucle:
		call moveCursor				;Cridar subrutina movCursor

		cmp  [tecla], 's'			;Comprobar si la tecla pitjada es igual a 's'
		je   fi						;Si es igual saltar a fi
		cmp  [tecla], ' '			;Comprobar si la tecla pitjada es igual a ' ' (espai)
		je   fi						;Si es igual saltar a fi

		jmp bucle					;Si no es compleix saltar a bucle

	fi:
		mov esp, ebp
		pop ebp
		ret

moveCursorContinuous endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina serveix per a poder accedir a les components de la matriu
; i poder obrir les caselles
; Calcular l��ndex per a accedir a la matriu gameCards en assemblador.
; gameCards[row][col] en C, �es [gameCards+indexMat] en assemblador.
; on indexMat = ((row-1)*4 + col (convertida a n�mero))*4 .
;
; Variables utilitzades:
; row: fila per a accedir a la matriu gameCards
; col: columna per a accedir a la matriu gameCards
; indexMat: �ndex per a accedir a la matriu gameCards
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndex proc
	push ebp
	mov  ebp, esp

	push eax
	push ebx

	mov  eax, 0					;Inicialitzacio del registre eax
	mov  ebx, 0					;Inicialitzacio del registre ebx

	mov  eax, [row]				;Carreguem el contingut de [row] al registre eax
	dec  eax					;La fila es de 1 a 5 i la matriu de 0 a 4 (per aixo decrementem eax)
	mov  bl, [col]				;Carreguem el contingut de [col] al registre de 8 bits bl
								
								;indexMat = (row*4 + col (convertida a n�mero))*4
	sub  ebx, 65				;Convertir la columna a numero restant 'A'
	shl  eax, 2					;Multiplicar per 4 la fila
	add  eax, ebx				;Sumar fila mes columna

	shl  eax, 2					;Multiplicar per 4 la suma

	mov  [indexMat], eax		;El resultat de eax el guardem a la variable [indexMat]

	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret

calcIndex endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S�ha de cridar a movCursorContinuous per a triar la casella desitjada.
; Un cop som a la casella desitjada premem al tecla � � (espai per a veure el contingut)
; Calcular la posici� de la matriu corresponent a la
; posici� que ocupa el cursor a la pantalla, cridant a la subrutina calcIndexP1. 
; Mostrar el contingut de la casella corresponent a la posici� del cursor al tauler.
; Considerar que el valor de la matriu �s un  int (entre 0 i 9)
; que s�ha de �convertir� al codi ASCII corresponent. 
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
; row : fila per a accedir a la matriu gameCards
; col : columna per a accedir a la matriu gameCards
; indexMat : �ndex per a accedir a la matriu gameCards 
; gameCards : matriu 5x4 on tenim els valors de les cartes.
; carac : car�cter per a escriure a pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCard proc
	push ebp
	mov  ebp, esp

	push eax
	push ebx

	mov eax, 0						;Inicialitzacio del registre eax
	mov ebx, 0						;Inicialitzacio del registre ebx

	call moveCursorContinuous		;Cridar subrutina moveCursorContinuous (triar la casella desitjada)

	cmp  [tecla], 's'				;Comprobar que la tecla pitjada sigui igual a ' ' (espai)
	je   fi							;si es igual salta a mostraCarta

	mostrarCarta:
		call calcIndex				;Cridar subrutina calcIndex (accedir a les components de la matriu)

		mov  eax, [indexMat]		;Carreguem el valor de la variable [indexMat] al registre eax
		
		mov  ebx, [gameCards+eax]	;Carreguem el valor de la variable [gameCards+eax] al registre ebx
		add  ebx, 48				;48 = 0 per obtenir el numero al girar la carta
		mov  [carac], bl			;Guardem el resultat obtingut de 8 bits a la variable [carac]

		call printch				;Cridar subrutina printch

	fi: 
		pop ebx
		pop eax

		mov esp, ebp
		pop ebp
		ret

openCard endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S�ha d'anar cridant a openCard fins que pitgem la tecla 's'
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCardContinuous proc
	push ebp
	mov  ebp, esp

	bucle:
		call posCurScreen			;Cridar subrutina posCurScreen
		call openCard				;Cridar subrutina openCard

		cmp  [tecla], 's'			;Comprobar que la tecla pitjada sigui igual a 's'
		je   fi						;Si es igual saltar a fi

		jmp  bucle					;Si no es igual, saltar a bucle

	fi:
		mov esp, ebp
		pop ebp
		ret

openCardContinuous endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la posici� 3,30 de la pantalla cridant a la subturina gotoxy
; Mostrar el valor de la variable Num_Card (1 o 2)
; Posicionar el cursor a la posici� 3,41 de la pantalla cridant a la subrutina gotoxy
; Mostrar el valor de la variable Player (1 o 2)
; Posicionar el cursor al taulell de joc i moure�l de forma continua fins que pitgem �s� o � � 
; Quan pitgem � �, obrim la casella (comprovar que no est� oberta i marcar-la com oberta)
; Tornar a moure el cursor de forma continua fins que pitgem �s� o � �
; Quan pitgem � �, obrim la casella (comprovar que no est� oberta i marcar-la com oberta)
; Comprovar si els valors de les dues caselles coincideixen. Si coincideixen, posar un 1 a HitPair.
; Si no coincideixen, tancar les dues caselles i desmarcar-les com a obertes.
;
; Variables utilitzades:
; Num_Card: Variable que indica si estem obrint la primera o la segona casella de la parella.
; carac : car�cter a mostrar per pantalla
; row : fila del cursor a la matriu gameCards o Board.
; col : columna del cursor a la matriu gameCards o Board.
; rowScreen: Fila de la pantalla on volem posicionar el cursor.
; colScreen: Columna de la pantalla on volem posicionar el cursor.
; indexMat: �ndex per accedir a la posici� de la matriu.
; gameCards: Matriu amb els valors de les caselles del tauler.
; Board: Matriu que indica si la casella est� oberta o no.
; firstVal, firstRow, firstCol: Dades relatives a la primera casella de la parella.
; secondVal, secondRow, secondCol: Dades relatives a la segona casella de la parella.
; Player: Indica el jugador al que li correspon el torn.
; HitPair: Variable que indica si s�ha fet una parella (0 No parell � 1 Parella)
; tecla: Codi ascii de la tecla pitjada.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openPair proc
	push ebp
	mov  ebp, esp

	push eax						;no es perdi informacio
	push ebx
	push ecx
	push edx

	mov eax, 0						;inicialitzar tots els registres usats a 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	mov [HitPair], 0				;incialitzem variable a 0 (1-indica que hi ha parella)

	mov [Num_Card], 0				;inicialitzem la variable que indica el numero de carta

	mov  [rowScreen], 3				;Mostrar n�mero del jugador que toca
	mov  [colScreen], 41			;(rowScreeen i colScreen) indica on volem el cursor
	call gotoxy						;pociciona el cursor segons rowScreen i colScreen
	mov  eax, [Player]				;movem (1/2) a eax. numero de jugador
	add  eax, 48					;sumem el codi ascii per tenir el (1/2 en ascii)
	mov  [carac], al				;carac es de 8 bits, i conte el nuemro del jugador en ascii	
	call printch					;escriu per pantalla el carac

actualitzarCarta:
	mov  [rowScreen], 3				;Mostra quina carta s'ha d'obrir
	mov  [colScreen], 30			;(rowScreeen i colScreen) indica on volem el cursor
	call  gotoxy					;pociciona el cursor segons rowScreen i colScreen
	mov  eax, [Num_Card]			;movem el 0 de carta a eax
	inc  eax						;incrementem en 1 per tenir el numero de carta
	add  eax, 48					;sumem el codi ascii per tenir el (1/2 en ascii) 
	mov  [carac], al				;carac es de 8 bits, i conte el numero del jugador en ascii
	call printch					;escriu per pantalla el carac
	
	call posCurScreen				;Colocarse al tauler

bucle:
	call moveCursorContinuous		;Moure per tauler fins escollir casella

 	cmp  [tecla], 's'				;salta a fi si es clica s
	je   fi

mostrarCarta:						;comprovar carta 
	call calcIndex					;Cridar subrutina calcIndex (accedir a les components de la matriu)

	mov  eax, [indexMat]			;Carreguem el valor de la variable [indexMat] al registre eax
		
	shr eax, 2   ;prova (dividim pq board es char)

	mov bl, [Board+eax]				;Accedeix al contingut de la posicio
	cmp ebx, 'o'					;comprovem que estigui oberta
	je bucle						;Si la posici� est� oberta, saltar al bucle per escollir una altra casella
								
	mov [Board+eax], 'o'			;Sin�, mostrar valor per pantalla i marcar casella com a ocupada
	
	shl eax , 2  ;prova multipliquem pq gamecards es int

	mov  ebx, [gameCards+eax]		;Carreguem el valor de la variable [gameCards+eax] al registre ebx
	add  ebx, 48					;48 = 0 per obtenir el numero al girar la carta
	mov  [carac], bl				;Guardem el resultat obtingut de 8 bits a la variable [carac]
	mov ecx, [rowScreen]			;guardem posicio de la carta 1
	mov edx, [colScreen]

	call printch					;Cridar subrutina printch per mostrar carta 1 

guardarDadesCarta:

	cmp [Num_Card], 1				;Comprovar si �s la primera carta o la segona que s'obre (1 = segona carta)
	je compararCartes				;Si �s la segona carta, sortir del bucle
	
dadesCarta1:
	inc [Num_Card]					;Incrementar valor carta a escollir
	mov dl, [col]					;guardem la columna a la variable corresponet fisrtCol
	mov [firstCol],	dl				;Guardar valor primera columna
	mov ecx, [row]					;guardem la fila a la variable corresponent fistRow
	mov [firstRow], ecx				;Guardar valor primera fila
	mov [firstVal], ebx				;guardem el numero (en ascii) de la carta	
	jmp actualitzarCarta			;recorem el bucle un altre cop per la segona carta


compararCartes:
	cmp ebx, [firstVal]				;Comparar valor 1 amb valor 2		
	je tornarTrue					;Si s�n iguals, deixar impr�s a la taula i sortir

TreureCarta2:
	call getch						;esperar que premis una tecla 

	shr eax, 2 ;prova pq board es char

	mov [Board+eax], ' '			;Sin� s�n iguals, canviar estat de les caselles 
	mov [carac], ' '				;reestablir posicions del tauler a buides
	call posCurScreen				;posicionem el cursor a la carta 1
	call printch					;Posar en blanc segona casella escollida

TreureCarta1:						
	mov ecx, [firstRow]				;Carregar valors primera carta per eliminar
	mov dl, [firstCol]				;carreguem a registres
	mov [row], ecx					;movem a row i col per poder fer el calcIndex
	mov [col], dl

	call calcIndex					;Calcular posici� per posar a la matriu
	mov eax, [indexMat]				;posem la posicio de la matriu a eax
	
	shr eax, 2 ;proba dividim pq es char
	
	mov [Board+eax], ' '			;indiquem que no esta oberta

	mov [carac], ' '				;Carregar espai buit per tapar casella
	call posCurScreen
	call printch					;Posar en blanc segona casella escollida
	jmp fi

tornarTrue:
	mov [HitPair], 1
	

fi:
	pop edx							;retornar estat previ a la funci�
	pop ecx
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret
openPair endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina ha d�anar cridant a la subrutina anterior OpenPair,
; fins que pitgem la tecla �s�
;
; Variables utilitzades:
; tecla: Codi ascii de la tecla pitjada.

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openPairsContinuous proc
	push ebp
	mov  ebp, esp

bucle:
	call openPair

	cmp [tecla], 's'
	je fi
	jmp bucle

fi:
	mov esp, ebp
	pop ebp
	ret

openPairsContinuous endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la posici� 3,50 de la pantalla cridant a la subturina gotoxy
; Mostrar el valor de la variable pairsPlayer1 i mostrar les parelles aconseguides pel jugador 1.
; Posicionar el cursor a la posici� 3,57 de la pantalla cridant a la subturina gotoxy
; Mostrar el valor de la variable pairsPlayer2 i mostrar les parelles aconseguides pel jugador 2.
; Comen�a jugant el jugador 1 i cridem a openPair. 
; Mentre aconsegueixi parelles i no pitgi �s�
; seguir� jugant i s�anir� actualitzant el comptador de parelles
; Si no aconsegueix parella, el torn passa al jugador 2 que cridar� a openPair
; Mentre aconsegueixi parelles i no pitgi �s�
; seguir� jugant i s�anir� actualitzant el comptador de parelles
;
; Variables utilitzades:
; carac : car�cter a mostrar per pantalla
; rowScreen: Fila de la pantalla on volem posicionar el cursor.
; colScreen: Columna de la pantalla on volem posicionar el cursor.
; Player: Indica el jugador que te el torn.
; pairsPlayer1: Parelles aconseguides pel jugador 1
; pairsPlayer2: Parelles aconseguides pel jugador 2
; HitPair: Indica si s�ha aconseguit parella o no en una jugada
; tecla: Codi ascii de la tecla pitjada.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
open2Players proc
	push ebp
	mov  ebp, esp

	push eax							;Guardem el registre eax a la pila

	actualitzarParelles:
		;mostrar parelles conseguides pel jugador 1
		mov  [rowScreen], 3				;Indicar la fila on volem el cursor
		mov  [colScreen], 50			;Indicar la columna on volem el cursor
		call gotoxy						;Cridar subrutina gotoxy per posicionar (rowScreen i colScreen) el cursor 
		mov  eax, [pairsPlayer1]		;Copiem el valor de pairsPlayer1 al registre eax
		add  eax, 48					;Sumem 48 del codi ascii al registre eax
		cmp  eax, 58					;Comparem el registre eax amb el valor 58
		jne  seguir						;Si no es igual saltem a l'etiqueta seguir
		mov  [carac], 49				;Si es igual, copiem a [carac] el valor 49 (ascii) = '1'
		call printch					;Cridem a la subrutina printch per mostrar per pantalla el caracter
		mov [colScreen], 51				;Copiem a [colScreen] el valor 51
		mov [carac], 48					;Copiem a [carac] el valor 48 (ascii) = '0'
		call printch					;Cridem a la subrutina printch per mostrar per pantalla el caracter
		jmp bucle						;Saltem a l'etiqueta bucle

	seguir:
		mov  [carac], al				;Copiem a [carac] el contingut del registre al
		call printch					;Cridem a la subrutina printch per mostrar per pantalla


		;mostrar parelles conseguides pel jugador 2
		mov  [rowScreen], 3				;Indicar la fila on volem el cursor
		mov  [colScreen], 57			;Indicar la columna on volem el cursor
		call gotoxy						;Cridar subrutina gotoxy per posicionar (rowScreen i colScreen) el cursor
		mov  eax, [pairsPlayer2]		;Copiem el valor de pairsPlayer2 al registre eax
		add  eax, 48					;Sumem 48 del codi ascii al registre eax
		cmp  eax, 58					;Comparem el registre eax amb el valor 58
		jne  seguir2					;Si no es igual saltem a l'etiqueta seguir2
		mov  [carac], 49				;Si es igual, copiem a [carac] el valor 49 (ascii) = '1'
		call printch					;Cridem a la subrutina printch per mostrar per pantalla el caracter
		mov [colScreen], 58				;Copiem a [colScreen] el valor 58
		mov [carac], 48					;Copiem a [carac] el valor 48 (ascii) ='0'
		call printch					;Cridem a la subrutina printch per mostrar per pantalla el caracter
		jmp bucle						;Saltem a l'etiqueta bucle
		

	seguir2:
		mov  [carac], al				;Copiem a [carac] el contingut del registre al
		call printch					;Cridem a la subrutina printch per mostrar per pantalla
			
	call posCurScreen					;Cridem a la subrutina posCurScreen per posicionar el cursor a on era inicialment

	bucle:
		mov eax, [pairsPlayer1]			;Copiem al registre eax el contingut de [pairsPlayer1]
		add eax, [pairsPlayer2]			;Sumem a eax el contingut de [pairsPlayer2]
		cmp eax, 10						;Comparem el registre eax amb 10
		je fi							;Si es igual saltem a fi (significa que s'ha acabat la partida)

		call openPair					;Cridem a la subrutina openPair 

		cmp  [tecla], 's'				;Comparem que la [tecla] amb 's'
		je   fi							;Si es igual saltem a fi (acaba la partida perque abandona algun jugador)

		cmp [HitPair], 1				;Comparem HitPair amb 1 (si ha fet parella)
		jne actualitzarJugador			;Si no ha fet parella saltem a l'etiqueta actualitzarJugador

		cmp [Player], 1					;Comparem si el [Player] es 1 (jugador 1)
		jne player2						;Si no es saltem a l'etiqueta player2

		inc [pairsPlayer1]				;Incrementem [pairsPlayer1]
		mov [HitPair], 0				;Reiniciem la variable [HitPair]
		jmp actualitzarParelles			;Saltem a l'etiqueta actualitzarParelles

	player2:
		inc [pairsPlayer2]				;Incrementem pairsPlayer2
		mov [HitPair], 0				;Reiniciem la variable [HitPair]
		jmp actualitzarParelles			;Saltem a l'etiqueta actualitzarParelles
			
	actualitzarJugador:
		cmp [Player], 2					;Comparem que [Player] es major o igual a 2 (jugador 2 o major)
		jge  reiniciarPlayer			;Si es major o igual saltem a l'etiqueta reiniciarPlayer
		inc [Player]					;Sino incrementem [Player]
		jmp bucle						;Saltem al bucle

	reiniciarPlayer:
		mov [Player], 1					;Reiniciem la variable [Player] a 1 (jugador 1)
		jmp bucle						;Saltem al bucle

	fi:
	pop eax								;Recuperem la informaci� del registre eax guardada a la pila 
	mov esp, ebp
	pop ebp
	ret

open2Players endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina Play anir� cridant a la subrutina open2Players
; mentre no pitgem �s� i queden parelles per a descobrir. 
; Ha de posar a la variable Winner el jugador (1 o 2) que ha fet m�s parelles. 
; Si han fet les mateixes parelles, 
; ha de posar un 0. 
;
; Variables utilitzades:
; tecla: Codi ascii de la tecla pitjada.
; pairsPlayer1: Nombre de parelles aconseguides pel jugador 1
; pairsPlayer2: Nombre de parelles aconseguides pel jugador 2
; Winner: Jugador que ha aconseguit m�s parelles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Play proc
	push ebp
	mov  ebp, esp

	push eax							;Guardem el registre eax a la pila

	mov  eax, 0							;Inicialitzem el registre eax a 0

	call open2Players					;Cridem a la subrutina open2Players

	cmp [tecla], 's'					;Comparem si la [tecla] pitjada es s
	je  fi								;Si es igual saltem a fi

	mov eax, [pairsPlayer1]				;Copiem a eax la iformaci� de [pairsPlayer1]
	cmp eax, [pairsPlayer2]				;Comparem eax 
	je  empatats						;Si son iguals saltem a l'etiqueta empatats
	jg  player1							;Si eax es mes gran saltem a l'etiqueta player1
	
	mov [Winner], 2						;Sino el Winner es el jugador 2
	jmp fi								;Saltem a fi

	empatats:
		mov [Winner], 0					;Copiem a [Winner] el valor 0
		jmp fi							;Saltem a fi

	player1:
		mov [Winner], 1					;Copiem a [Winner] el valor 1

	fi:
	pop eax								;Recuperem la informaci� del registre eax guardada a la pila 
	mov esp, ebp
	pop ebp
	ret

Play endp

END