[BITS 16]
[ORG 0x7C00]

KERNEL_OFFSET equ 0x1000

start:
    xor ax, ax              ; ✅ 세그먼트 레지스터 초기화
    mov ds, ax
    mov es, ax
    
    mov [BOOT_DRIVE], dl
    mov bp, 0x9000
    mov sp, bp
    
    mov bx, MSG_MODE_REAL
    call print_string_16bit
    
    call load_kernel
    call switch_to_protect_mode
    jmp $

; === 16비트 함수들 ===
print_string_16bit:
    pusha
    mov ah, 0x0e
.loop:
    mov al, [bx]
    cmp al, 0
    je .done
    int 0x10
    inc bx
    jmp .loop
.done:
    popa
    ret

; ✅ 16진수 출력 함수 추가 (디버깅용)
print_hex:
    pusha
    mov cx, 4               ; 4자리
.loop:
    mov ax, dx
    shr dx, 4
    and ax, 0x0f
    add al, '0'
    cmp al, '9'
    jle .print
    add al, 7               ; A-F
.print:
    mov bx, HEX_OUT + 5
    sub bx, cx
    mov [bx], al
    loop .loop
    
    mov bx, HEX_OUT
    call print_string_16bit
    popa
    ret

load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string_16bit
    
    ; ✅ 디스크 리셋 먼저 수행
    mov ah, 0x00
    mov dl, [BOOT_DRIVE]
    int 0x13
    
    ; ✅ 커널 크기에 맞게 섹터 읽기
    mov bx, KERNEL_OFFSET
    mov dh, 15              ; ✅ 15섹터 (7.5KB) - 필요하면 조정
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

disk_load:
    pusha
    push dx
    
    mov di, 3               ; ✅ 재시도 3번
    
.retry:
    ; ✅ LBA 모드 사용 (더 안정적)
    mov ah, 0x42            ; Extended Read
    mov si, disk_packet
    mov dl, [BOOT_DRIVE]
    
    int 0x13
    jnc .success            ; ✅ 성공
    
    ; 실패 시 재시도
    dec di
    jz disk_error
    
    ; 디스크 리셋
    push dx
    mov ah, 0x00
    mov dl, [BOOT_DRIVE]
    int 0x13
    pop dx
    jmp .retry
    
.success:
    pop dx
    popa
    ret

; ✅ LBA 디스크 주소 패킷
disk_packet:
    db 0x10                 ; 패킷 크기
    db 0                    ; 예약
    dw 15                   ; 읽을 섹터 수
    dw KERNEL_OFFSET        ; 오프셋
    dw 0                    ; 세그먼트
    dd 1                    ; LBA 시작 (섹터 1 = 두 번째 섹터)
    dd 0                    ; LBA 상위

disk_error:
    mov bx, MSG_DISK_ERROR
    call print_string_16bit
    
    ; ✅ AH만 출력 (에러 코드는 AH에 있음)
    xor dx, dx              ; DX 초기화
    mov dl, ah              ; DL = 에러 코드
    call print_hex
    
    jmp $

sectors_error:
    mov bx, MSG_SECTORS_ERROR
    call print_string_16bit
    jmp $

switch_to_protect_mode:
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:init_protect_mode

; === 32비트 함수들 ===
[BITS 32]
init_protect_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000
    mov esp, ebp
    
    call BEGIN_PROTECT_MODE

BEGIN_PROTECT_MODE:
    mov ebx, MSG_PROTECT_MODE
    call print_string_32bit
    
    call KERNEL_OFFSET
    jmp $

print_string_32bit:
    pusha
    mov edx, VIDEO_MEMORY
.loop:
    mov al, [ebx]
    mov ah, WHITE_ON_BLACK
    cmp al, 0
    je .done
    
    mov [edx], ax
    add ebx, 1
    add edx, 2
    jmp .loop
.done:
    popa
    ret

; === 상수 및 데이터 ===
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

BOOT_DRIVE db 0

MSG_MODE_REAL db "Started > 16bit Real Mode", 13, 10, 0
MSG_LOAD_KERNEL db "Kernel is now loading...", 13, 10, 0
MSG_DISK_ERROR db "Disk error! Code: ", 0
MSG_SECTORS_ERROR db "Sectors mismatch!", 13, 10, 0
MSG_PROTECT_MODE db "Started > 32-bit Protected Mode", 0

HEX_OUT db "0x0000", 13, 10, 0

; === GDT ===
gdt_start:

gdt_null:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; === 부트 시그니처 ===
times 510-($-$$) db 0
dw 0xaa55