assume cs:code1, ds:data1, ss:stack1

data1 segment
args 				db 128 dup('$')																				;OK Maksymalnie moze byc 127 bajtów argumentow
first				db "W pierwszym argumencie podajemy tylko 0 lub 1!$"										;OK
second  			db "Liczby hexadecymalne zapisujemy za pomoc cyfr [0;9] i liter [a;f]!$"					;OK
onlyone				db "Podano tylko jeden argument!$"									 						;OK
noargs				db "Nie podano argumentow!$"																;OK
toomuchargs			db "Podano za duzo argumentow!$"															;OK
toolongfirsta 		db "Za dlugi pierwszy argument!$"															;OK
tooshortfirsta		db "Za krotki pierwszy argument!$"															;OK
toolongseconda 		db "Za dlugi drugi argument!$"  															;OK
tooshortseconda		db "Za krotki drugi argument!$" 															;OK
bin					db 64 dup(0)																				;OK wszystkie ruchy w dobrej kolejnosci 128 bitow/4=64
mapa				db 153 dup(0)																				;OK
znaki				db " .o+=*BOX@%&#/^SE"																		;OK
linia				db "+-----------------+",0ah,0dh,"$"														;OK
pozkon				db 0																						;OK
data1 ends

code1 segment

start:
	mov ax, seg data1
	mov ds, ax
	mov ax, seg stack1
	mov ss, ax
	mov sp, offset wsk


	mov bl,byte ptr es:[80h]
	cmp bl,0
	je noargss

	xor cx,cx
	xor di,di

	mov bl,81h; od znaku spacji szukamy niebiałych znakow
petla:
	jmp findnotwhite ;zwraca w bl niebiały znak
kopiuj:
	jmp copytowhite ;pobiera z bl niebiały znak i kopiuje do args a w di zwraca do ktorego miejsca skopiowal, cx zwraca nr (od 0) kopiowanego argumentu
kontpetle:
	cmp cx,2
	ja petla
	push di ; wrzucam (pozycje dla pierwszych dwoch arg) do ktorego skopiowal na stos
	jmp petla

koniecpetli:
	cmp cx,2
	ja check
	push di

check:
	pop di 
	mov dx,di ; dlugosc 1 i 2 argumentu + dwa dolary
	pop di 
	mov bx,di ; dlugosc 1 arg + dolar

	jmp checkargs
checked:
	jmp hextobin
hexed:
	mov dl,byte ptr ds:[args]
	cmp dl,'0'
	je moveverone
	cmp dl,'1'
	je movevertwo
moved:
	jmp drawmap	
quit:
	mov ah,4ch
	int 21h


;****************************************
;******wyszukiwanie niebialego znaku*****
;****************************************
;input bl - adres od ktorego szuka 
;output bl - adres pierwszego niebialego znaku

findnotwhite:
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
	jmp kopiuj
;****************************************
;******kopiowanie do białego znkau*******
;****************************************
;input bl - adres od ktorego kopiuje 
;output di - pozycja do ktorej jest uzyte args, bl adres nastepnego bialego znaku, cx ilosc skopiowanych argumentow

copytowhite:
	push dx
	xor bh,bh

copy:
	mov dl,byte ptr es:[bx]

	cmp dl,32d ;znak spacji
	je brcopy
	cmp dl,9d ;znak tabulatora
	je brcopy
	cmp dl,13d ;znak enetera
	je konieckopiowania

	mov byte ptr ds:[args+di],dl
	inc di
	inc bl
	jmp copy

brcopy:
	mov [args+di],'$'
	inc cx
	inc di
	pop dx
	jmp kontpetle

konieckopiowania:
	mov [args+di],'$'
	inc cx
	inc di
	pop dx
	jmp koniecpetli

;****************************************
;******sprawdzanie poprawnosci arg*******
;****************************************
;input dx,bx - dlugosci argumentow, cx - ilosc argumentow

checkargs:

	push ax
	push di

	cmp cx,1
	je onlyones
	cmp cx,2
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

	sub dx,bx
	dec dx ; dlugosc 2 argumentu (odejmuje dolara)
	dec bx ; dlugosc 1 argumentu (odejmuje dolara)

	cmp bx,1
	ja toolongfirst
	jb tooshortfirst

	cmp dx,32
	ja toolongsecond
	jb tooshortsecond

	jmp checkfirst

toolongfirst:
	mov dx,offset ds:[toolongfirsta]
	jmp wypiszblad
tooshortfirst:
	mov dx,offset ds:[tooshortfirsta]
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

	cmp dl,'1'
	je przesuwaj
	cmp dl,'2'
	je przesuwaj
	cmp dl,'3'
	je przesuwaj	
	cmp dl,'4'
	je przesuwaj
	cmp dl,'5'
	je przesuwaj
	cmp dl,'6'
	je przesuwaj
	cmp dl,'7'
	je przesuwaj
	cmp dl,'8'
	je przesuwaj
	cmp dl,'9'
	je przesuwaj
	cmp dl,'0'
	je przesuwaj		
	cmp dl,'a'
	je przesuwaj
	cmp dl,'b'
	je przesuwaj
	cmp dl,'c'
	je przesuwaj
	cmp dl,'d'
	je przesuwaj
	cmp dl,'e'
	je przesuwaj
	cmp dl,'f'
	je przesuwaj

wrongsecond:
	mov dx,offset ds:[second]
	jmp wypiszblad
zwroc:
	pop di
	pop ax
	jmp checked

wypiszblad:
	mov ah,9
	int 21h
	pop di
	pop ax
	jmp quit

;****************************************
;******zamiana hexa na bity**************
;****************************************
hextobin:
	push si
	push di
	push cx
	push dx

	mov si,0
	mov di,-2
	mov cx,0


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
	jmp hexed

;****************************************
;******rusza sie wersja 0****************
;****************************************
moveverone:
push ax
push bx
push di
push dx
push si

	mov di,76
	mov si,-1 ;

ruchvzero:
	inc si	
	cmp si,64
	je zakonczruchy
	
	mov dl,byte ptr [bin+si]

	cmp dl,0
	je zerozerovzero

	cmp dl,1
	je zerojedenvzero

	cmp dl,10
	je jedenzerovzero

	cmp dl,11
	je jedenjedenvzero
	
zerozerovzero:
	cmp di,0
	je ruchvzero

	mov ax,di
	mov bl,17
	div bl
	cmp al,0
	je wierszlvzero

	cmp ah,0
	je kolumnagvzero

	sub di,18
	jmp nastepnyruchv0

zerojedenvzero:
	cmp di,16
	je ruchvzero

	mov ax,di
	mov bl,17
	div bl
	cmp al,0
	je wierszpvzero

	cmp ah,16
	je kolumnadvzero

	sub di,16
	jmp nastepnyruchv0



jedenzerovzero:
	cmp di,136
	je ruchvzero

	mov ax,di
	mov bl,17
	div bl
	cmp al,8
	je wierszlvzero

	cmp ah,0
	je kolumnagvzero

	add di,16
	jmp nastepnyruchv0

jedenjedenvzero:
	cmp di,152
	je ruchvzero

	mov ax,di
	mov bl,17
	div bl
	cmp al,8
	je wierszpvzero

	cmp ah,16
	je kolumnadvzero

	add di,18
	jmp nastepnyruchv0

zakonczruchy:
	xor dx,dx
	mov dx,di
	mov [pozkon],dl

	pop si
	pop dx
	pop di
	pop bx
	pop ax

	jmp moved

	


kolumnagvzero:
	sub di,17
	jmp nastepnyruchv0

kolumnadvzero:
	add di,17
	jmp nastepnyruchv0

wierszlvzero:
	sub di,1
	jmp nastepnyruchv0

wierszpvzero:
	add di,1
	jmp nastepnyruchv0

nastepnyruchv0:	
	inc mapa[di]
	jmp ruchvzero
;****************************************
;******rusza sie wersja 0****************
;****************************************
movevertwo:
push ax
push bx
push di
push dx
push si

	mov di,76 ;pozycja
	mov si,-1 ;numer ruchu

ruchvjeden:
	inc si	
	cmp si,64
	je zakonczruchy ;wspolna dla obu wersji
	
	mov dl,byte ptr [bin+si]

	cmp dl,0
	je zerozerovjeden

	cmp dl,1
	je zerojedenvjeden

	cmp dl,10
	je jedenzerovjeden

	cmp dl,11
	je jedenjedenvjeden
	

zerozerovjeden:
	cmp di,0
	je ruchvjeden ; nie wykonuje ruchu

	cmp di,1
	je ojedenl ; jeden w lewo
	
	mov ax,di
	mov bl,17
	div bl

	cmp al,0 ;dzielenie
	je wierszlvjeden ; jezeli w 1 linii to przesuwam sie o 2 w lewo

	cmp ah,0 ;modulo
	je kolumnagvjeden ; jezeli w 1 kolumnie to przesuwam sie o jeden do gory

	cmp ah,1 ;modulo
	je kolumnagojedenvjeden ; jezeli w 2 kolumnie to jeden w lewo i jeden do gory

	sub di,19 ; normalyn ruch skoczka
	jmp nastepnyruchv1

zerojedenvjeden:
	cmp di,16
	je ruchvjeden ; brak ruchu

	cmp di,15
	je ojedenp ; jeden w prawo

	mov ax,di
	mov bl,17
	div bl

	cmp al,0 ;dzielenie
	je wierszpvjeden  ;1 linia - dwa w prawo

	cmp ah,16 ;modulo
	je kolumnagvjeden ;ostatnia kolumna - przeskakuje o jeden go gory

	cmp ah,15 ;modulo
	je kolumnaggojedenvjeden ; przedostatani kolumna - jeden w prawo i jeden w goe

	sub di,15 ; normalny ruch
	jmp nastepnyruchv1

jedenzerovjeden:
	cmp di,136
	je ruchvjeden ;brak ruchu

	cmp di,137
	je ojedenl ;ruch o jeden w lewo

	mov ax,di
	mov bl,17
	div bl


	cmp al,8 ;dzielenie
	je wierszlvjeden ; ruch o dwa w lewo w ostatnim wierszu

	cmp ah,0 ;modulo
	je kolumnadvjeden ; ruch o jeden do gory 

	cmp ah,1 ;modulo
	je kolumnaddojedenvjeden ; ruch jeden w lewo i jeden w dol


	add di,15
	jmp nastepnyruchv1

jedenjedenvjeden:
	cmp di,152
	je ruchvjeden ;pomijam

	cmp di,151
	je ojedenp ; jeden w prawo

	mov ax,di
	mov bl,17
	div bl


	cmp al,8 ;dzielenei
	je wierszpvjeden ;w ostatnim wierszu slizga sie o dwa w prawo

	cmp ah,16 ;modulo
	je kolumnadvjeden ; o jeden w dol

	cmp ah,15 ;modulo
	je kolumnadojedenvjeden ;ruch jeden w prawo jeden w dol

	add di,19 ;normalny ruch
	jmp nastepnyruchv1


ojedenl:
	sub di,1
	jmp nastepnyruchv1

ojedenp:
	add di,1
	jmp nastepnyruchv1

wierszlvjeden:
	sub di,2
	jmp nastepnyruchv1

wierszpvjeden:
	add di,2
	jmp nastepnyruchv1


kolumnaggojedenvjeden:
	sub di,16
	jmp nastepnyruchv1
kolumnagvjeden:
	sub di,17
	jmp nastepnyruchv1
kolumnagojedenvjeden:
	sub di,18
	jmp nastepnyruchv1


kolumnaddojedenvjeden:
	add di,16
	jmp nastepnyruchv1
kolumnadvjeden:
	add di,17
	jmp nastepnyruchv1
kolumnadojedenvjeden:
	add di,18
	jmp nastepnyruchv1

nastepnyruchv1:
	inc mapa[di]
	jmp ruchvjeden

;****************************************
;******rysuj mape************************
;****************************************
drawmap:
	push ax
	push dx
	push di
	push si

	xor bx,bx

	mov ah,9
	mov dx,offset linia
	int 21h
	mov ah,2

	mov di,0 ;ktore miejsce na mapie
	mov si,0 ;wrzucam wartosc tego miejsca
	mov cx,0 ;licze ilosc wypisanych znakow w linii

petlarysuj:
	mov dl,'|'
	int 21h
rysujznak:
	mov bl,byte ptr mapa[di]
	mov si,bx
	cmp di,76
	je znakstartu ; wrzucam S na miejsce startu
	push ax
	mov al,byte ptr pozkon
	xor ah,ah
	cmp di,ax
	pop ax
	je znakkonca ; wrzucam E na miejsce konca
	cmp si,14
	ja ostatniznak ;jezeli wartosc miejsca>14
cor:	
	mov dl,byte ptr znaki[si]		
	int 21h
	inc di ; przesuwam sie na nastepne miejsce na mapie
	inc cx ; inkrementuje wypisane znaki w linni
	cmp di,152
	ja zakonczrysowanie
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
jmp petlarysuj

zakonczrysowanie:
	mov dl,'|'
	int 21h
	mov dl,0ah
	int 21h
	mov dl,0dh
	int 21h
	mov ah,9
	mov dx,offset linia
	int 21h
	pop si
	pop di
	pop dx
	pop ax
	jmp quit

ostatniznak:
mov si,14
jmp cor

znakstartu:
mov si,15
jmp cor

znakkonca:
mov si,16
jmp cor	

code1 ends

stack1 segment stack
		dw 200 dup(?)
	wsk dw ?
stack1 ends

end start

