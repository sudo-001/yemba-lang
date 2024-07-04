extern printf, scanf 
section .data
; declaration des variables en memoire
a: dd 0
b: dd 0
c: dd 0
d: dd 0
fmt:db "%d", 10, 0 
fmtlec:db "%d", 0
section .text
global_start

_start:

push 5
 ;affectation
pop eax
mov [a], eax

push 10
 ;affectation
pop eax
mov [b], eax

push 0
 ;affectation
pop eax
mov [c], eax

push 15
 ;affectation
pop eax
mov [d], eax

;afficher
mov eax, [a] 
push eax
push dword fmt
call printf

;afficher
mov eax, [b] 
push eax
push dword fmt
call printf

;afficher
mov eax, [c] 
push eax
push dword fmt
call printf

;afficher
mov eax, [d] 
push eax
push dword fmt
call printf

 ;recuperation en memoire
mov eax, [a] 
push eax
push 5
;Teste d'égalité
pop ebx
pop eax
cmp eax, ebx

jne test1
push 1
jmp fintest1 
test1:
push 0
fintest1:


;Reduction du alors1
pop eax
cmp eax,1
jne sinon1
;afficher
mov eax, [b] 
push eax
push dword fmt
call printf

mov eax,1 ; sys_exit 
mov ebx,0; Exit with return code of 0 (no error)
int 80h