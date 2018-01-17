; Orginal MASM source - win32.c
; This file is just monkey translation from MASM to NASM syntax

DEFAULT REL

section .text

global _ffi_call_x86
_ffi_call_x86:
    push ebp
    mov ebp, esp

    push esi ; NEW: this register must be preserved across function calls
; XXX SAVE ESP NOW!
    mov esi, esp        ; save stack pointer before the call

; Make room for all of the new args.
    mov ecx, [ebp+16]
    sub esp, ecx        ; sub esp, bytes

    mov eax, esp

; Place all of the ffi_prep_args in position
    push dword [ebp + 12] ; ecif
    push eax
    call [ebp + 8] ; prepfunc

; Return stack to previous state and call the function
    add esp, 8
; FIXME: Align the stack to a 128-bit boundary to avoid
; potential performance hits.
    call [ebp + 28]

; Load ecif->cif->abi
    mov ecx, [ebp + 12]
    mov ecx, [ecx] ; ecif.cif
    mov ecx, [ecx] ; ecif.cif.abi

    cmp ecx, 2 ; FFI_STDCALL
    je .noclean
; STDCALL: Remove the space we pushed for the args
    mov ecx, [ebp + 16]
    add esp, ecx
; CDECL: Caller has already cleaned the stack
.noclean:
; Check that esp has the same value as before!
    sub esi, esp

; Load %ecx with the return type code
        mov ecx, [ebp + 20]

; If the return value pointer is NULL, assume no return value.
;
;  Intel asm is weird. We have to explicitely specify 'DWORD PTR' in the nexr instruction,
;  otherwise only one BYTE will be compared (instead of a DWORD)!

    cmp dword [ebp + 24], 0
    jne .sc_retint

; Even if there is no space for the return value, we are
; obliged to handle floating-point values.
    cmp ecx, 2 ; FFI_TYPE_FLOAT
    jne .sc_noretval
    ; fstp  %st(0)
    fstp st0

    jmp .sc_epilogue

.sc_retint:
    cmp ecx, 1 ; FFI_TYPE_INT
    jne .sc_retfloat
    ; # Load %ecx with the pointer to storage for the return value
    mov ecx, [ebp + 24]
    mov [ecx + 0], eax
    jmp .sc_epilogue

.sc_retfloat:
    cmp ecx, 2 ; FFI_TYPE_FLOAT
    jne .sc_retdouble
; Load %ecx with the pointer to storage for the return value
    mov ecx, [ebp+24]
    ; fstps (%ecx)
    fstp dword [ecx]
    jmp .sc_epilogue

.sc_retdouble:
    cmp ecx, 3 ; FFI_TYPE_DOUBLE
    jne .sc_retint64
    ; movl  24(%ebp),%ecx
    mov ecx, [ebp+24]
    fstp qword [ecx]
    jmp .sc_epilogue

.sc_retint64:
    cmp ecx, 12 ; FFI_TYPE_SINT64
    jne .sc_retstruct
; Load %ecx with the pointer to storage for the return value
    mov ecx, [ebp+24]
    mov [ecx+0], eax
    mov [ecx+4], edx

.sc_retstruct:
; Nothing to do!

.sc_noretval:
.sc_epilogue:
    mov eax, esi
    pop esi ; NEW restore: must be preserved across function calls
    mov esp, ebp
    pop ebp
    ret
