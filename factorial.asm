default rel
bits 64

segment .data
    welcome_string db `Calculate factorial of (enter integer): \n`, 0 ; 
    output_string db "factorial of %ld is %ld", 0 ; 
    scanf_format db "%ld", 0                      ; 
    in_val dq 0

segment .text
global main
global factorial

extern printf
extern scanf

extern _CRT_INIT
extern ExitProcess

    
    a equ    0
    result equ 8

factorial:
    push    rbp                 ; 
    mov    rbp, rsp             ; 
    sub    rsp, 32              ; 

    n equ 16                    ; 

    
    mov    [rsp + a], rcx       ; 

    cmp    rcx, 1
    jg    if_greater            ; If n <= 1, return 1
    mov    eax, 1

    leave
    ret

if_greater:
    mov    [rsp + n], rcx          ; Save current accumulated value
    dec    rcx                     ; call factorial(n-1)
    call    factorial
    mov    rcx, [rsp + n]       ; Restore original accumulated value
    imul    rax, rcx            ; Multiply factoral(n -1) * n

    leave                       ; Undo the stack frame (it sets rsp to rbp, then pops rbp.)
    ret                         ; return to calling procedure (main).

main:
    call _CRT_INIT                 

    push    rbp                 ; Set up a stack frame
    mov    rbp, rsp             ; base pointer now points to stack frame
    sub    rsp, 32              ; Leave room for shadow parameters (4 for windows)

    lea    rcx, [welcome_string]
    call printf

    ; Read user input
    lea    rcx, [scanf_format]        ; 1st argument to scanf
    lea    rdx, [in_val]  ; 2nd  argument to scanf
    call scanf

    mov    rcx, [in_val]        ; Factorial only needs one argument
    call    factorial           ; Invoke function

    ; Print the result to stdout
    lea    rcx, [output_string] ; Load the 4 arguments for printf in the registers.
    mov    rdx, [in_val]       ; For Microsoft x64 calling convention, first 4 are RCX, RDX, R8 and R9.
    mov    r8, rax             ; Return value from ``factorial``should be in RAX.
    call    printf

    xor    eax, eax                ; return 0 for process exit code.
    leave                          ; Undo changes to the stack frame.

    call ExitProcess            ; On Windows, terminates the process.
