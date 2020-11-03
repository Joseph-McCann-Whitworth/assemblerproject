TITLE MASM Template	(main.asm)
; Description:  Final Project
; Author: Joseph McCann        
; Date:   4/30/2020  
INCLUDE C:\Irvine\Lib32\Irvine32.inc ; Do INCLUDE Irvine32.inc if this doesn't work
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
Player STRUCT ; this is a struct that will hold all the players data
playername BYTE 50 DUP(0) ;this is the player's name and stores the string the user inputs
playerhealth DWORD 100 ; the player's health used to determine if the player is alive or not
playermaxhealth DWORD 100 ; this is used to upgrade the player's health after winning a battle
playerdamage DWORD 20 ; this is the amount of damage the player can do to an enemy each turn
playermaxdamage DWORD 20 ;this is used to upgrade the player's damage after they win a battle

Player ENDS
Enemy STRUCT; this is a struct that will hold all the enemy's data
enemyname BYTE 50 DUP(0) ;this stores the current enemy's name
enemyhealth DWORD 100;this stores the health the enemy has before they fall
enemydamage DWORD 10 ;this is how much damage the enemy does to the player each turn(this is randomized)
enemycounter BYTE 0 ;the current enemy you're at(important to store this for their name)
Enemy ENDS
.data
; all of the welcome strings are for the intro to be displayed to the console
welcome BYTE "Welcome to this exciting game, what is your name?", 0
welcome2 BYTE "Hello:", 0
welcome3 BYTE "How this game is going to work is that you'll go through areas and fight monsters to the reach the end." , 0
welcome4 BYTE "You'll also be able to get random upgrades throughout the whole game to your characters health and damage.", 0
welcome5 BYTE "Have fun with the game and good luck to you on your quest to save the world!", 0
; victory is displayed after the player wins a battle and defeat is displayed after the player loses a battle
Victory BYTE "You win!",0
Defeat BYTE "The night will last forever......",0
;all the attackresult strings are for the attack result to display what the player and enemy did to each other with 
;their health remaining being shown
attackresult BYTE " did ",0
attackresult_1 BYTE " damage to ",0
attackresult_2 BYTE " has fallen.",0
healthleft BYTE " has ", 0
healthleft_1 BYTE " health remaining", 0
;this text is to be displayed after the player wins the game by defeating all the enemies
GoodEnding_0 BYTE "Congratulations ", 0
GoodEnding_1 BYTE " you managed to fight to the end and save the world from the darkness.", 0
GoodEnding_2 BYTE " Thanks for playing!!", 0
;this is displayed after the player loses one battle and is basically game over
BadEnding_0 BYTE "The darkness has taken over.", 0
BadEnding_1 BYTE "The worlds impending doom is approaching with no one left to save it.", 0
;these are all of the enemy names 
Enemy_0 BYTE "The Mighty Hotdog" ,0
Enemy_1 BYTE "Running man",0
Enemy_2 BYTE "Hardcore gamer",0
Enemy_3 BYTE "Kool-Aid Man",0
Enemy_4 BYTE "Person with glasses",0
Enemy_5 BYTE "Person behind Window",0
Enemy_6 BYTE "Goat",0
Enemy_7 BYTE "Burger Mascot",0 
Enemy_8 BYTE "Devil",0
Playermove BYTE "What will you do? 0 for attack and 1 for endturn.",0 ; this is to tell the player what they can do during their turn
;player and enemy structs to be used
play Player < , , >
evil Enemy < , , >
.code
main proc
 call intro
 ;mov eax,  OFFSET evil.enemyname
 ;movzx eax, Enemy_0
 ;mov evil.enemyname, eax
 mov esi,0
 mov ecx, SIZEOF Enemy_0
 
 mov ecx, 9
 Game: ; this label holds the loop of the game
        mov eax, play.playerhealth ;if the player's health is 0, then its game over and bad ending commences
        cmp eax,0
        JLE Bad
        call Namegenerator
        call Gameplay
    LOOP Game
    call Good_Ending
    invoke ExitProcess,0
    Bad:
        call Bad_Ending
invoke ExitProcess,0
main endp

intro proc ; this displays the basics of the game and asks for your name to the screen and will store your name
    mov edx, OFFSET welcome ;this like all the other welcome offsets allow the string to be displayed
    call WriteString
    mov edx, OFFSET play.playername ;these allow the user to input a string and it will get stored in play.playername's memory location
    mov ecx, SIZEOF play.playername
    call ReadString
    mov edx, OFFSET welcome2
    call WriteString
    mov edx, OFFSET play.playername  
    call WriteString
    call Crlf
    mov edx, OFFSET welcome3 
    call WriteString
    call Crlf
    mov edx, OFFSET welcome4
    call WriteString
    call Crlf
    mov edx, OFFSET welcome5
    call WriteString
    call WaitMsg
    call Clrscr
    ret
intro endp

Gameplay proc; this procedure is where the gameplay loop occurs
call randomizeEnemystats
Fight:
    mov edx, OFFSET Playermove
    call WriteString
    call ReadDec
    cmp eax,0 ;this compares the decimal value you put and 0, to determine if you're attacking or not
    JG Noattack
    call playerattack ;this commences the players attack
   ; call WaitMsg
    call Crlf
    mov eax,evil.enemyhealth ;this compares the signed enemyhealth to 0
    ; and if its less than or equal to 0 then that means the player defeated the enemy and will jump to the win label
    Noattack: ;this label is used if the player doesn't attack, otherwise it runs normal
    cmp eax, 0
     JLE Win
     call enemyattack
    ; call WaitMsg
     call Crlf
     mov eax,play.playerhealth
     cmp eax, 0
     JG Fight; if neither the player or the enemy died, it'll go back to the beginning
    JLE Lose;if the player dies they'll go here

Win:
    mov edx, OFFSET Victory
    call WriteString
    call victoryaward
    call Clrscr
    ret
Lose:
        mov edx, OFFSET Defeat
         call WriteString
         call Clrscr
         ret
ret
Gameplay endp

playerattack proc ; this function will do the players attack and take health off of the enemy, while also displaying the damage dealt and the health left of the enemy
mov eax,  evil.enemyhealth
mov ebx,  play.playerdamage 
sub eax, ebx
mov evil.enemyhealth, eax
call playerattackresult ;this will call this function to display the results of the players attack
ret


playerattack endp
playerattackresult proc ;this will display how much damage the player did to the enemy and how much health the enemy has left
    mov eax,evil.enemyhealth
    cmp eax, 0 ;if the enemy died from the resulting attack it will go into enemy_dead, otherwise it'll go to still alive
    JG Still_Alive
    JLE Enemy_Dead
    Still_Alive: ;this displays the result of the attack with the enemy's remaining health
        mov edx, OFFSET play.playername
        call WriteString
        mov edx, OFFSET attackresult
        call WriteString
        mov eax, play.playerdamage
        call WriteDec
        mov edx, OFFSET attackresult_1
        call WriteString
        mov edx, OFFSET evil.enemyname
        call WriteString
        call Crlf
        mov edx, OFFSET evil.enemyname
        call WriteString
        mov edx, OFFSET healthleft
        call WriteString
        mov eax, evil.enemyhealth
        call WriteDec
        mov edx, OFFSET healthleft_1
        call WriteString

        call Crlf
        ret
    Enemy_Dead: ; this displays the result of the player's attack and that the enemy died from the attack
         mov edx, OFFSET play.playername
        call WriteString
        mov edx, OFFSET attackresult
        call WriteString
        mov eax, play.playerdamage
        call WriteDec
        mov edx, OFFSET attackresult_1
        call WriteString
        mov edx, OFFSET evil.enemyname
        call WriteString
        call Crlf
        mov edx, OFFSET evil.enemyname
        call WriteString
        mov edx, OFFSET attackresult_2
        call WriteString
        call Crlf
        ret



playerattackresult endp

enemyattack proc; this function will do the enemies attack and take health off of the player, while also displaying the damage dealt and the health left of the player
mov eax,  play.playerhealth
mov ebx,  evil.enemydamage
sub eax, ebx
mov play.playerhealth, eax
call enemyattackresult
ret

enemyattack endp

enemyattackresult proc ;this will display the result of the enemy's attack on the player
    mov eax,play.playerhealth
     cmp eax, 0 ;if the player is still alive it'll display the enemy attack and the player's health
     JG Still_Alive
    JLE Player_Dead
    Still_Alive:
        mov edx, OFFSET evil.enemyname
        call WriteString
        mov edx, OFFSET attackresult
        call WriteString
        mov eax, evil.enemydamage
        call WriteDec
        mov edx, OFFSET attackresult_1
        call WriteString
        mov edx, OFFSET play.playername
        call WriteString
        call Crlf
        mov edx, OFFSET play.playername
        call WriteString
        mov edx, OFFSET healthleft
        call WriteString
        mov eax, play.playerhealth
        call WriteDec
        mov edx, OFFSET healthleft_1
        call WriteString
        call Crlf
        ret
    Player_Dead:
         mov edx, OFFSET evil.enemyname
        call WriteString
        mov edx, OFFSET attackresult
        call WriteString
        mov eax, evil.enemydamage
        call WriteDec
        mov edx, OFFSET attackresult_1
        call WriteString
        mov edx, OFFSET play.playername
        call WriteString
        call Crlf
        mov edx, OFFSET play.playername
        call WriteString
        mov edx, OFFSET attackresult_2
        call WriteString
        call Crlf
        ret

enemyattackresult endp
setenemystats proc

setenemystats endp

victoryaward proc ; this procedure is going to increase the player's health and damage for winning the fight
     ;this will increase the player's attack from 1 to 5
        mov eax, 1
		mov ebx, 5
		sub ebx,eax
		xchg ebx,eax
		call RandomRange
		neg ebx
		sub eax, ebx
        add play.playermaxdamage, eax
       mov eax, play.playermaxdamage
       mov play.playerdamage, eax
        ;this will increase the player's health from 5 to 10
        mov eax, 5
		mov ebx, 10
		sub ebx,eax
		xchg ebx,eax
		call RandomRange
		neg ebx
		sub eax, ebx
        add play.playermaxhealth, eax
       mov eax, play.playermaxhealth
       mov play.playerhealth, eax
        ret

victoryaward endp
randomizeEnemystats proc ; this procedure will randomize the enemy stats between the range in the function
    mov eax, 10 ; attack goes from 10 to 20 
		mov ebx, 20
		sub ebx,eax
		xchg ebx,eax
		call RandomRange
		neg ebx
		sub eax, ebx
        mov evil.enemydamage, eax
      
    mov eax, 100 ; health goes from 100 to 120
		mov ebx, 120
		sub ebx,eax
		xchg ebx,eax
		call RandomRange
		neg ebx
		sub eax, ebx
        mov evil.enemyhealth, eax
    ret
        



randomizeEnemystats endp
Good_Ending proc ; this will display text to the screen resulting from the good ending
mov edx, OFFSET GoodEnding_0
call WriteString
mov edx, OFFSET play.playername
call WriteString
mov edx, OFFSET GoodEnding_1
call WriteString
mov edx, OFFSET GoodEnding_2
call WriteString
ret

Good_Ending endp
Bad_Ending proc ; this will display text to the screen resulting from the bad ending
mov edx, OFFSET BadEnding_0
call WriteString
mov edx, OFFSET BadEnding_1
call WriteString
ret

Bad_Ending endp
Namegenerator proc ; this will assign the name to the enemy based off where you are in the game
mov bl, evil.enemycounter
cmp bl,0 ;this is to compare the enemy counter with 0 meaning the first enemy
JLE Enemy1 ;if the enemy counter is equal to 0, then it'll go into Enemy1
jmp Check1 ; otherwise it'll keep jumping past the labels till bl equals the signed integer
Enemy1:
        mov esi,0
        mov eax, SIZEOF Enemy_0
        namemaker: ; this will put all of the characters in the Enemy byte into the enemyname variable for the evil instance of the enemy struct
            mov al, Enemy_0[esi* TYPE Enemy_0]
            mov evil.enemyname[esi * TYPE Enemy_0], al
            add esi,1
            cmp esi, eax ; this is comparing to see if all of the enemyname byte got put into the enemy name by checking esi and comparing it to the size of the byte
            JLE namemaker
        inc bl
        mov evil.enemycounter, bl
        ret
Check1:
cmp bl,1
JLE Enemy2
jmp Check2
Enemy2:
        mov esi,0
         mov eax, SIZEOF Enemy_1
        namemaker1:
            mov al, Enemy_1[esi* TYPE Enemy_1]
            mov evil.enemyname[esi * TYPE Enemy_1], al
            add esi,1
            cmp esi, eax
            JLE namemaker1
        inc bl
        mov evil.enemycounter, bl
        ret
Check2:
cmp bl,2
JLE Enemy3
jmp Check3
Enemy3:
        mov esi,0
        mov eax, SIZEOF Enemy_2
        namemaker2:
            mov al, Enemy_2[esi* TYPE Enemy_2]
            mov evil.enemyname[esi * TYPE Enemy_2], al
            add esi,1
            cmp esi, eax
            JLE namemaker2
        inc bl
        mov evil.enemycounter, bl
        ret
Check3:
cmp bl,3
JLE Enemy4
jmp Check4
Enemy4:
        mov esi,0
        mov eax, SIZEOF Enemy_3
        namemaker3:
            mov al, Enemy_3[esi* TYPE Enemy_3]
            mov evil.enemyname[esi * TYPE Enemy_3], al
            add esi,1
            cmp esi, eax
            JLE namemaker3
        inc bl
        mov evil.enemycounter, bl
        ret
Check4:
cmp bl,4
JLE Enemy5
jmp Check5
Enemy5:
        mov esi,0
        mov eax, SIZEOF Enemy_4
        namemaker4:
            mov al, Enemy_4[esi* TYPE Enemy_4]
            mov evil.enemyname[esi * TYPE Enemy_4], al
            add esi,1
            cmp esi, eax
            JLE namemaker4
        inc bl
        mov evil.enemycounter, bl
        ret
Check5:
cmp bl,5
JLE Enemy6
jmp Check6
Enemy6:
        mov esi,0
        mov eax, SIZEOF Enemy_5
        namemaker5:
            mov al, Enemy_5[esi* TYPE Enemy_5]
            mov evil.enemyname[esi * TYPE Enemy_5], al
            add esi,1
            cmp esi, eax
            JLE namemaker5
        inc bl
        mov evil.enemycounter, bl
        ret
Check6:
cmp bl,6
JLE Enemy7
jmp Check7
Enemy7:
        mov esi,0
         mov eax, SIZEOF Enemy_6
        namemaker6:
            mov al, Enemy_6[esi* TYPE Enemy_6]
            mov evil.enemyname[esi * TYPE Enemy_6], al
            add esi,1
            cmp esi, eax
            JLE namemaker6
        inc bl
        mov evil.enemycounter, bl
        ret
Check7:
cmp bl,7
JLE Enemy8
jmp Check8
Enemy8:
        mov esi,0
         mov eax, SIZEOF Enemy_7
        namemaker7:
            mov al, Enemy_7[esi* TYPE Enemy_7]
            mov evil.enemyname[esi * TYPE Enemy_7], al
            add esi,1
            cmp esi, eax
            JLE namemaker7
        inc bl
        mov evil.enemycounter, bl
        ret
Check8: 
        mov esi,0
         mov eax, SIZEOF Enemy_8
        namemaker8:
            mov al, Enemy_8[esi* TYPE Enemy_8]
            mov evil.enemyname[esi * TYPE Enemy_8], al
            add esi,1
            cmp esi, eax
            JLE namemaker8
        ret
Namegenerator endp
end main
