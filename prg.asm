.model tiny
.code
.386
org 0100h


print_string macro
    push ax
    push dx

    mov ah, 09h
    int 21h

    pop dx
    pop ax
endm


write_str macro str
    push ax
    push dx

    mov ah, 09h
    mov dx, offset str

    int 21h

    pop dx
    pop ax
endm




fmt macro ; Макрос, который выполняет форматирование чётных строк
    push ax
    push bx
    push cx
    push dx

    lea si, string
    lea di, fmtstr
    mov ax, 1

    mov cx, 0FFFh
    mloop:
        push ax
        xor ax, ax
        mov ax, count
        inc ax
        mov count, ax
        pop ax

        xor bx, bx
        mov bx, [si]

        cmp bx, 0
        je next

        cmp bx, 2573
        je next

        continue:
        inc si

        loop mloop

    next:
    push bx
    push ax

    xor dx, dx
    div divt
    cmp dx, zero

    je reverse
    jmp straight

    reverse:
        pop ax
        inc ax

        push si
        dec si

        push cx
        mov cx, count
        rloop:
            mov bx, [si]
            mov [di], bx

            inc di
            dec si
            loop rloop

        mov bx, ' '
        mov [di], bx

        inc di
        mov bx, 0Ah
        mov [di], bx
        inc di

        push ax
        xor ax, ax
        mov ax, -1
        mov count, ax
        pop ax

        pop cx

        pop si
        inc si

        pop bx
        cmp bx, 0
        je ex
        jmp continue

    straight:
        pop ax
        inc ax

        push si
        dec si

        push cx
        mov cx, count
        sloop:
            mov bx, [si]
            push bx
            dec si
            loop sloop

        mov cx, count
        swloop:
            pop bx
            mov [di], bx

            inc di
            loop swloop

        pop cx
        pop si
        inc si

        inc di
        mov bx, 0Ah
        mov [di], bx
        inc di

        push ax
        xor ax, ax
        mov ax, -1
        mov count, ax
        pop ax

        pop bx
        cmp bx, 0
        je ex
        jmp continue

    ex:

    pop dx
    pop cx
    pop bx
    pop ax
endm




main:
mov ax, 0600h
mov bh, 00000010b
mov cx, 0
mov dx, 185fh
int 10h

mov ah, 02h
mov dx, 0h
mov bh, 0

int 10h

;открытие файла
mov ah, 3Dh
xor al, al ;открыть файл для чтения
mov dx, offset FileName ;адрес имени файла
xor cx, cx ;открыть файл без указания атрибутов
int 21h ;выполнить прерывание

mov FDescr, ax ;получить дескриптор файла
jnc M1 ;eсли ошибок нет, выполнить программу дальше
jmp Er1 ;файл не был открыт

M1:
;создание нового файла
mov ah, 3ch ;создать новый файл
xor cx, cx
mov dx, offset NewFile ;адрес имени файла
int 21h ;выпонить
mov FDescrNew, ax ;дискриптор файла
jnc M2 ;если ошибок нет, выполнить программу дальше
jmp Er3 ;файл не был создан

M2:
;чтение файла
mov ah, 3fh ;чтение из файла
mov bx, FDescr ;дескриптор нужного файла
mov cx, 1 ;количество считываемых символов
mov dx, offset Buffer ;адрес буфера для приема
int 21h ;выполнить
jnc M3 ;если нет ошибки -> продолжить чтение
jmp Er2 ;если ошибка -> выход

M3:
cmp ax, 0 ;если ax=0(число считанных байтов) -> файл кончился -> выход
je M4 ;если ax=0 -> sf=1
mov ax, Buffer
mov bx, index
mov String[bx], ax
inc bx
mov index, bx
jmp M2

M4:
;Обработка строк и их запись в файл
fmt

write_str fam
call sd
write_str inp
call sd
write_str string
call sd
call sd
write_str outp
call sd
write_str fmtstr

mov ah, 40h
mov bx, FDescrNew
mov cx, index
mov dx, offset fmtstr
int 21h
jnc M5
jmp Er4

sd proc
    push dx
    push ax
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    pop ax
    pop dx
    ret
sd endp

M5:
;закрытие исходного файла
mov ah, 3eh ;функция закрытия файла
mov bx, FDescr
int 21h

;закрытие нового файла
mov ah, 3eh ;функция закрытия файла
mov bx, FDescrNew
int 21h

jmp Exit

Er1:
;файл не был найден
cmp ax, 02h
jne M6
lea dx, MessageError3
print_string
jmp Exit

M6:
;файл не был открыт
lea dx, MessageError1
print_string
jmp Exit

Er2:
;файл не был прочтен
lea dx, MessageError2
print_string
jmp Exit

Er3:
;файл не был создан
lea dx, MessageError4
print_string
jmp Exit

Er4:
;ошибка при записи в файл
lea dx, MessageError5
print_string
jmp Exit

Exit:
mov ah, 07h ;задержка экрана
int 21h

;завершение программы
mov ax, 4c00h
int 21h

datas:
    fmtstr dw 80 dup(0), '$' ;буфер для хранения форматированной строки
    divt dw 2
    zero dw 0
    count dw -1
    fam db '---------------------------------Rows Reverser---------------------------------', '$'
    inp db 'Input File:', '$'
    outp db 'Output File:', '$'

    FileName db "SRC.txt0", "$" ;имя файла в формате ASCIIZ строки
    FDescr dw ? ;ячейка для хранения дисриптора
    NewFile db "DST.txt0", "$"
    FDescrNew dw ? ;для хранения дискриптора нового
    Buffer dw ? ;буфер для хранения символа строки
    String dw 80 dup(0), '$' ;буфер для хранения строки
    index dw 0 ;впомогательная переменная
    MessageError1 db 0Dh, 0Ah, "File was not opened !", "$"
    MessageError2 db 0Dh, 0Ah, "File was not read !", "$"
    MessageError3 db 0Dh, 0Ah, "File was not founded!", "$"
    MessageError4 db 0Dh, 0Ah, "File was not created!", "$"
    MessageError5 db 0Dh, 0Ah, "Error in writing in the file!", "$"

end main
