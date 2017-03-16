assume cs:code1, ds:data1, ss:stack1
data1 segment
argslength			db 16 dup(0)																				;OK Ograniczenie do 16 argumentow
argscounter			dw 0																						;OK
args 				db 128 dup('$')																				;OK Maksymalnie moze byc 127 bajtów argumentow
noargs				db "Nie podano argumentow!$"																;OK					
onlyone				db "Podano tylko jeden argument!$"									 						;OK
toomuchargs			db "Podano za duzo argumentow!$"															;OK
toolongfirsta 		db "Za dlugi pierwszy argument!$"															;OK
toolongseconda 		db "Za dlugi drugi argument!$"  															;OK
tooshortseconda		db "Za krotki drugi argument!$" 															;OK
first				db "W pierwszym argumencie podajemy tylko 0 lub 1!$"										;OK
second  			db "Liczby hexadecymalne zapisujemy za pomoc cyfr [0;9] i liter [a;f]!$"					;OK
bin					db 64 dup(0)																				;OK
mapa				db 153 dup(0)																				;OK
pozkon				db 0																						;OK
znaki				db " .o+=*BOX@%&#/^SE"																		;OK
linia				db "+-----------------+",0ah,0dh,"$"														;OK
data1 ends

code1 segment

start:
	mov ax, seg data1
	mov ds, ax
	mov ax, seg stack1
	mov ss, ax
	mov sp, offset wsk

	mov ah,62h
	int 21h
	mov es,bx

	xor di,di
	mov bl,81h; od znaku spacji szukamy niebiałych znakow
petla:
	call findnotwhite ;zwraca w bl niebiały znak
	call copytowhite ;pobiera z bl niebiały znak, zwraca w di - ostatnie miejsce w args do ktorego skopiowano

	call checkargs
	call hextobin
	call checkver
	call drawmap
quit:
	mov ah,4ch
	int 21h
;****************************************
;******wyszukiwanie niebialego znaku*****
;****************************************
;input bl - adres od ktorego szuka 
;output bl - adres pierwszego niebialego znaku

findnotwhite proc
	push dx
	xor bh,bh
comp1:
	mov dl,byte ptr es:[bx]
	cmp dl,32d ;znak spacji
	je white
	cmp dl,9d ;znak tabulatora
	je white
	jmp foundnotwhite

white:
	inc bl
	jmp comp1

foundnotwhite:
	pop dx
	ret
findnotwhite endp
;****************************************
;******kopiowanie do białego znkau*******
;****************************************
;input bl - adres od ktorego kopiuje 
;output bl - adres nastepnego bialego znaku, di do którego miejsca uzyte args

copytowhite proc
	push dx
	push si
	
	xor bh,bh

	mov si,argscounter

copy:
	mov dl,byte ptr es:[bx]

	cmp dl,32d ;znak spacji
	je brcopy
	cmp dl,9d ;znak tabulatora
	je brcopy
	cmp dl,13d ;znak enetera
	je konieckopiowania

	mov byte ptr ds:[args+di],dl
	inc argslength[si]
	inc di
	inc bl
	jmp copy

brcopy:
	mov byte ptr ds:[args+di],'.'
	inc di
	inc argscounter
	jmp petla

konieckopiowania:
	mov byte ptr ds:[args+di],'$'
	inc di
	inc argscounter


	pop si
	pop dx
	ret
copytowhite endp
;****************************************
;******sprawdzanie poprawnosci arg*******
;****************************************

checkargs proc
	push ax
	push di

	cmp byte ptr es:[80h],0
	je noargss
	cmp argscounter,1
	je onlyones
	cmp argscounter,2
	ja toomuchargss

	jmp checklength

	noargss:
	mov dx,offset ds:[noargs]
	jmp wypiszblad

	onlyones:
	mov dx,offset ds:[onlyone]
	jmp wypiszblad

	toomuchargss:
	mov dx,offset ds:[toomuchargs]
	jmp wypiszblad

checklength:

	cmp argslength[0],1
	ja toolongfirst

	cmp argslength[1],32
	ja toolongsecond
	jb tooshortsecond

	jmp checkfirst

toolongfirst:
	mov dx,offset ds:[toolongfirsta]
	jmp wypiszblad
toolongsecond:
	mov dx,offset ds:[toolongseconda]
	jmp wypiszblad
tooshortsecond:
	mov dx,offset ds:[tooshortseconda]
	jmp wypiszblad	

checkfirst:
	mov dl,byte ptr ds:[args]
	cmp dl,'0'
	je checksecond
	cmp dl,'1'
	je checksecond

wrongfirst:
	mov dx,offset ds:[first]
	jmp wypiszblad

checksecond:
	mov di,2

przesuwaj:
	mov dl,byte ptr ds:[args+di]
	
	cmp di,34
	je zwroc

	inc di

	cmp dl,'9'
	jbe cyfry

	cmp dl,'f'
	jbe literki	

cyfry:
	cmp dl,'0'
	jb wrongsecond
	jmp przesuwaj

literki:
	cmp dl,'a'
	jb wrongsecond
	jmp przesuwaj

wrongsecond:
	mov dx,offset ds:[second]
	jmp wypiszblad

zwroc:
	pop di
	pop ax
	ret

wypiszblad:
	mov ah,9
	int 21h
	pop di
	pop ax
	jmp quit
checkargs endp
;****************************************
;******zamiana hexa na bity**************
;****************************************

hextobin proc
	push si
	push di
	push cx
	push dx

	mov si,0 ;wskaznik na miejsce w arg
	mov di,-2 ;wskaznik na miejsce w bin
	mov cx,0 ;ilosc przerobionych ruchow

zamien:
	add di,2
	cmp cx,32
	je zamienzwroc

	push cx
	and cx,1 ;sprawdzam parzystosc zeby dobrze przesuwac sie po argumentach (od najmlodszego do najstarszego)
	cmp cx,0 ;jesli parzysty
	pop cx
	je jpp

jnpp:
	dec si
	jmp porownaj

jpp:
	add si,3
	jmp porownaj


porownaj:
	inc cx
	mov dl,args[si]
	cmp dl,'0'
	je zero
	cmp dl,'1'
	je jeden
	cmp dl,'2'
	je dwa
	cmp dl,'3'
	je trzy
	cmp dl,'4'
	je cztery
	cmp dl,'5'
	je piec
	cmp dl,'6'
	je szesc
	cmp dl,'7'
	je siedem
	cmp dl,'8'
	je osiem
	cmp dl,'9'
	je dziewiec
	cmp dl,'a'
	je a
	cmp dl,'b'
	je b
	cmp dl,'c'
	je cc
	cmp dl,'d'
	je d
	cmp dl,'e'
	je e
	cmp dl,'f'
	je f


zero:
mov bin[di],00
mov bin[di+1],00
jmp zamien

jeden:
mov bin[di],01
mov bin[di+1],00
jmp zamien

dwa:
mov bin[di],10
mov bin[di+1],00
jmp zamien

trzy:
mov bin[di],11
mov bin[di+1],00
jmp zamien

cztery:
mov bin[di],00
mov bin[di+1],01
jmp zamien

piec:
mov bin[di],01
mov bin[di+1],01
jmp zamien

szesc:
mov bin[di],10
mov bin[di+1],01
jmp zamien

siedem:
mov bin[di],11
mov bin[di+1],01
jmp zamien

osiem:
mov bin[di],00
mov bin[di+1],10
jmp zamien

dziewiec:
mov bin[di],01
mov bin[di+1],10
jmp zamien

a:
mov bin[di],10
mov bin[di+1],10
jmp zamien

b:
mov bin[di],11
mov bin[di+1],10
jmp zamien

cc:
mov bin[di],00
mov bin[di+1],11
jmp zamien

d:
mov bin[di],01
mov bin[di+1],11
jmp zamien

e:
mov bin[di],10
mov bin[di+1],11
jmp zamien

f:
mov bin[di],11
mov bin[di+1],11
jmp zamien

zamienzwroc:
	pop dx
	pop cx
	pop di
	pop si
	ret
hextobin endp
;****************************************
;******sprawdz wersje********************
;****************************************
checkver proc
	mov dl,args
	cmp dl,'0'
	je vers1
	cmp dl,'1'
	je vers2

	vers1:
	call moveverone
	ret

	vers2:
	call movevertwo
	ret

checkver endp
;****************************************
;******rusza sie wersja 0****************
;****************************************
moveverone proc
push ax
push bx
push dx
push di
push si

	mov di,76 ;pozycja
	mov si,-1 ;

ruchvzero:
	inc si	
	cmp si,64
	je zakonczruchy
	
	mov dl,byte ptr [bin+si]

	cmp dl,0
	je zerozero

	cmp dl,1
	je zerojeden

	cmp dl,10
	je jedenzero

	cmp dl,11
	je jedenjeden
	
zerozero:
	cmp di,0 ; pomijam rog
	je ruchvzero

	mov ax,di
	mov bl,17
	div bl


	cmp al,0 
	je wierszl ;slizgam sie w wierszu w lewo

	cmp ah,0
	je kolumnag ;slizgam sie w kolumnie do gory 

	sub di,18
	jmp nastepnyruch

zerojeden:
	cmp di,16; pomijam rog
	je ruchvzero

	mov ax,di
	mov bl,17
	div bl
	cmp al,0
	je wierszp ;slizgam sie w wierszu w prawo

	cmp ah,16
	je kolumnad ;slizgam sie w kolumnie do dolu 

	sub di,16
	jmp nastepnyruch



jedenzero:
	cmp di,136; pomijam rog
	je ruchvzero

	mov ax,di
	mov bl,17
	div bl
	cmp al,8
	je wierszl ;slizgam sie w wierszu w lewo

	cmp ah,0
	je kolumnag ;slizgam sie w kolumnie do gory

	add di,16
	jmp nastepnyruch

jedenjeden:
	cmp di,152; pomijam rog
	je ruchvzero

	mov ax,di
	mov bl,17
	div bl
	cmp al,8
	je wierszp ;slizgam sie w wierszu w prawo

	cmp ah,16
	je kolumnad ;slizgam sie w kolumnie do dolu

	add di,18
	jmp nastepnyruch

zakonczruchy:
	mov dx,di
	mov pozkon,dl

	pop si
	pop di
	pop dx
	pop bx
	pop ax
	ret


kolumnag:
	sub di,17
	jmp nastepnyruch

kolumnad:
	add di,17
	jmp nastepnyruch

wierszl:
	sub di,1
	jmp nastepnyruch

wierszp:
	add di,1
	jmp nastepnyruch

nastepnyruch:	
	inc mapa[di]
	jmp ruchvzero
moveverone endp

;****************************************
;******rusza sie wersja 0****************
;****************************************
movevertwo proc
push ax
push bx
push dx
push di
push si

	mov di,76 ;pozycja
	mov si,-1 ;numer ruchu

ruchvjeden:
	inc si	
	cmp si,64
	je zakonczruchy
	
	mov dl,byte ptr [bin+si]

	cmp dl,0
	je zerozero

	cmp dl,1
	je zerojeden

	cmp dl,10
	je jedenzero

	cmp dl,11
	je jedenjeden
	

zerozero:
	cmp di,0
	je ruchvjeden ; nie wykonuje ruchu

	cmp di,1
	je ojedenl ; jeden w lewo
	
	mov ax,di
	mov bl,17
	div bl

	cmp al,0 ;dzielenie
	je odwal ; jezeli w 1 linii to przesuwam sie o 2 w lewo

	cmp ah,0 ;modulo
	je ojedeng ; jezeli w 1 kolumnie to przesuwam sie o jeden do gory

	cmp ah,1 ;modulo
	je jedlewjedgor ; jezeli w 2 kolumnie to jeden w lewo i jeden do gory

	sub di,19 ; normalyn ruch skoczka
	jmp nastepnyruch

zerojeden:
	cmp di,16
	je ruchvjeden ; brak ruchu

	cmp di,15
	je ojedenp ; jeden w prawo

	mov ax,di
	mov bl,17
	div bl

	cmp al,0 ;dzielenie
	je odwap  ;1 linia - dwa w prawo

	cmp ah,16 ;modulo
	je ojedeng ;ostatnia kolumna - przeskakuje o jeden go gory

	cmp ah,15 ;modulo
	je jedprajedgor ; przedostatani kolumna - jeden w prawo i jeden w goe

	sub di,15 ; normalny ruch
	jmp nastepnyruch

jedenzero:
	cmp di,136
	je ruchvjeden ;brak ruchu

	cmp di,137
	je ojedenl ;ruch o jeden w lewo

	mov ax,di
	mov bl,17
	div bl


	cmp al,8 ;dzielenie
	je odwal ; ruch o dwa w lewo w ostatnim wierszu

	cmp ah,0 ;modulo
	je ojedend; ruch o jeden do dolu 

	cmp ah,1 ;modulo
	je jedlewjeddol ; ruch jeden w lewo i jeden w dol


	add di,15
	jmp nastepnyruch

jedenjeden:
	cmp di,152
	je ruchvjeden ;pomijam

	cmp di,151
	je ojedenp ; jeden w prawo

	mov ax,di
	mov bl,17
	div bl


	cmp al,8 ;dzielenie
	je odwap ;w ostatnim wierszu slizga sie o dwa w prawo

	cmp ah,16 ;modulo
	je ojedend ; o jeden w dol

	cmp ah,15 ;modulo
	je jedprajeddol ;ruch jeden w prawo jeden w dol

	add di,19 ;normalny ruch
	jmp nastepnyruch


ojedenl:
	sub di,1
	jmp nastepnyruch
ojedenp:
	add di,1
	jmp nastepnyruch
odwal:
	sub di,2
	jmp nastepnyruch
odwap:
	add di,2
	jmp nastepnyruch


jedprajedgor:
	sub di,16
	jmp nastepnyruch
ojedeng:
	sub di,17
	jmp nastepnyruch
jedlewjedgor:
	sub di,18
	jmp nastepnyruch


jedlewjeddol:
	add di,16
	jmp nastepnyruch
ojedend:
	add di,17
	jmp nastepnyruch
jedprajeddol:
	add di,18
	jmp nastepnyruch

nastepnyruch:
	inc mapa[di]
	jmp ruchvjeden

	zakonczruchy:
	xor dx,dx
	mov dx,di
	mov pozkon,dl

	pop si
	pop di
	pop dx
	pop bx
	pop ax
	ret
movevertwo endp
;****************************************
;******rysuj mape************************
;****************************************
drawmap proc
	push ax
	push bx
	push cx
	push dx
	push di
	push si

	xor bx,bx

	mov ah,9
	mov dx,offset linia
	int 21h

	mov ah,2
	xor di,di ;ktore miejsce na mapie
	xor si,si ;wrzucam wartosc tego miejsca
	xor cx,cx ;licze ilosc wypisanych znakow w linii

petlarysuj:
	mov dl,'|'
	int 21h
rysujznak:
	mov bl,byte ptr mapa[di]
	mov si,bx
	cmp di,76
	je znakstartu ; wrzucam S na miejsce startu
	mov bl,byte ptr pozkon
	cmp di,bx
	je znakkonca ; wrzucam E na miejsce konca
	cmp si,14
	ja ostatniznak ;jezeli wartosc miejsca>14
cor:	
	mov dl,byte ptr znaki[si]		
	int 21h
	inc di ; przesuwam sie na nastepne miejsce na mapie
	inc cx ; inkrementuje wypisane znaki w linni
	cmp cx,17
	je nowalinia
	
	jmp rysujznak

nowalinia:
	mov cx,0
	mov dl,'|'
	int 21h
	mov dl,0ah ;enter
	int 21h
	mov dl,0dh ;powrot karetki
	int 21h
	cmp di,153
	je zakonczrysowanie
jmp petlarysuj

zakonczrysowanie:
	mov ah,9
	mov dx,offset linia
	int 21h
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret

ostatniznak:
mov si,14
jmp cor

znakstartu:
mov si,15
jmp cor

znakkonca:
mov si,16
jmp cor	

drawmap endp

code1 ends

stack1 segment stack
		dw 200 dup(?)
	wsk dw ?
stack1 ends
end start