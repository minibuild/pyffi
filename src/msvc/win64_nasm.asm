; Orginal MASM source - win64.asm
; This file is just monkey translation from MASM to NASM syntax

DEFAULT REL

section .text

global ffi_closure_OUTER
extern ffi_closure_SYSV

;;; ffi_closure_OUTER will be called with these registers set:
;;;    rax points to 'closure'
;;;    r11 contains a bit mask that specifies which of the
;;;    first four parameters are float or double
;;;
;;; It must move the parameters passed in registers to their stack location,
;;; call ffi_closure_SYSV for the actual work, then return the result.
;;;
ffi_closure_OUTER:
    ;; save actual arguments to their stack space.
    test r11, 1
    jne .first_is_float
    mov [rsp+8], rcx
    jmp .second
.first_is_float:
    movlpd [rsp+8], xmm0

.second:
    test r11, 2
    jne .second_is_float
    mov [rsp+16], rdx
    jmp .third
.second_is_float:
    movlpd [rsp+16], xmm1

.third:
    test r11, 4
    jne .third_is_float
    mov [rsp+24], r8
    jmp .forth
.third_is_float:
    movlpd [rsp+24], xmm2

.forth:
    test r11, 8
    jne .forth_is_float
    mov [rsp+32], r9
    jmp .done
.forth_is_float:
    movlpd [rsp+32], xmm3

.done:
    sub rsp, 40
    mov rcx, rax    ; context is first parameter
    mov rdx, rsp    ; stack is second parameter
    add rdx, 40        ; correct our own area
    mov rax, ffi_closure_SYSV
    call rax        ; call the real closure function
    ;; Here, code is missing that handles float return values
    add rsp, 40
    movq xmm0, rax    ; In case the closure returned a float.
    ret

;;; ffi_chkstk_AMD64
;;; picked up from MSVS-2015 as disasm of __chkstk
ffi_chkstk_AMD64:
    sub rsp, 10h
    mov qword [rsp], r10
    mov qword [rsp+8], r11
    xor r11, r11
    lea r10, [rsp+18h]
    sub r10, rax
    cmovb r10,r11
    mov r11, qword [gs:10h]
    cmp r10, r11
    bnd jae .cs20
    and r10w, 0F000h
.cs10:
    lea r11,[r11-1000h]
    mov byte [r11], 0
    cmp r10,r11  
    bnd jne .cs10
.cs20:
    mov r10, qword [rsp]
    mov r11, qword [rsp+8]
    add rsp,10h  
    bnd ret


;;; ffi_call_AMD64

%define stack 0
%define prepfunc 32
%define ecif 40
%define bytes 48
%define flags 56
%define rvalue 64
%define fn 72

global ffi_call_AMD64

ffi_call_AMD64:
    mov [rsp+32], r9
    mov [rsp+24], r8
    mov [rsp+16], rdx
    mov [rsp+8], rcx
    push rbp
    sub rsp, 48
    lea rbp, [rsp+32]

    mov eax, dword [rbp+bytes]
    add rax, 15
    and rax, -16

    call ffi_chkstk_AMD64
    sub rsp, rax
    lea rax, [rsp+32]
    mov [rbp+stack], rax

    mov rdx, [rbp+ecif]
    mov rcx, [rbp+stack]
    call [rbp+prepfunc]

    mov rsp, [rbp+stack]

    movlpd xmm3, [rsp+24]
    movq r9, xmm3

    movlpd xmm2, [rsp+16]
    movq r8, xmm2

    movlpd xmm1, [rsp+8]
    movq rdx, xmm1

    movlpd xmm0, [rsp]
    movq rcx, xmm0

    call [rbp+fn]
.ret_int:
    cmp dword [rbp+flags], 1 ; FFI_TYPE_INT
    jne .ret_float

    mov rcx, [rbp+rvalue]
    mov dword [rcx], eax
    jmp .ret_nothing

.ret_float:
    cmp dword [rbp+flags], 2 ; FFI_TYPE_FLOAT
    jne .ret_double

    mov rax, [rbp+rvalue]
    movlpd [rax], xmm0
    jmp .ret_nothing

.ret_double:
    cmp dword [rbp+flags], 3 ; FFI_TYPE_DOUBLE
    jne .ret_int64

    mov rax, [rbp+rvalue]
    movlpd [rax], xmm0
    jmp .ret_nothing

.ret_int64:
    cmp dword [rbp+flags], 12 ; FFI_TYPE_SINT64
    jne .ret_nothing

    mov rcx, [rbp+rvalue]
    mov [rcx], rax
    jmp .ret_nothing

.ret_nothing:
    xor eax, eax
    lea rsp, [rbp+16]
    pop rbp
    ret
