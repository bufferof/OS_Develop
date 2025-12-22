[BITS 32]

[EXTERN kernel_main]    ; C 함수 선언

[GLOBAL _start]         ; 링커가 찾을 엔트리 포인트

_start:
    ; 스택이 이미 부트로더에서 설정됨 (ESP = 0x90000)
    
    ; C 커널 호출
    call kernel_main
    
    ; 커널이 리턴하면 무한 루프
    cli
    hlt
    jmp $