[BITS 16] ;16BIT REAL BOOT
[ORG 0x7C00] ;BIOS LOAD ADDRESS

start:
    mov si, message ;string address
    call print ;call ouputing function

hangon:
    jmp hangon ;infinity loop

print:
    mov ah, 0x0E ;BIOS teletype ouput funciton

.loop:
    lodsb ;SI -> AL
    cmp al, 0
    je .done
    int 0x10 ;BIOS interrupt
    jmp .loop

.done:
    ret

message db 'HeeHee', 0

times 510-($-$$) db 0 ;fill 0 the rest
dw 0xAA55 ;boot signature