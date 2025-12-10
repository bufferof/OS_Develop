[BITS 16]
[ORG 0x7C00]

KERNEL_OFFSET equ 0x1000 ;커널 로드될 메모리 주소

start:
    mov [BOOT_DRIVE], dl ;BIOS가 전달한 부트 드라이브 번호

    mov bp, 0x9000
    mov sp, bp

    mov bx, MSG_MODE_REAL
    call print_string_16bit

    call load_kernel

print_string_16bit:
    pusha
    mov ah, 0x0e ;텔레타입


load_kernel: ;디스크 -> 커널 메모리에 로드
    mov bx, MSG_LOAD_KERNEL
    call print_string_16bit

    mov bx, KERNEL_OFFSET
    mov dh, 15
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

disk_load:
    push dx

    mov ah, 0x02 ;BIOS read 함수
    mov al, dh ;읽을 섹터 수
    mov ch, 0x00 ;실린더 0
    mov dh, 0x00 ;헤드 번호
    mov cl, 0x02 ;섹터 2(1 : 부트섹터)

    int 0x13 ;BIOS Disk Service

    jc disk_error ;에러 발생시

    pop dx
    cmp al, dh ;읽은 섹터 수 확인
    jne disk_error
    ret

disk_error:
    mov bx, MSG_DISK_ERROR
    call print_string_16bit
    jmp $

switch_to_protect_mode:
    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:init_protect_mode


[BITS 32]
init_protect_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ;스택 재지정
    mov esp, ebp
    
    call BEGIN_PROTECT_MODE ;C 커널 불러오기

BEGIN_PROTECT_MODE:
    mov ebx, MSG_PROTECT_MODE
    call print_string_32bit

print_string_16bit:
    pusha
    mov ebx, VIDEO_MEMORY ;메모리 지정 필요
.loop:
    mov al, [ebx]
    mov ah, WHITE_ON_BLACK
    

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f
BOOT_DRIVE db 0

; 메시지들
MSG_DISK_ERROR db "Disk got error :<", 0
MSG_LOAD_KERNEL db "Kernel is now loading...", 0
MSG_MODE_REAL db "Started > 16bit Real Mode", 0
MSG_PROTECT_MODE db "Started > 32-bit Protected Mode", 0