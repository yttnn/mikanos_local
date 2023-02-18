; asmfunc.asm
;
; System V AMD64 Calling Convention
; Registers: RDI, RSI, RDX, RCX, R8, R9

bits 64
section .text

global IoOut32 ; void IoOut32(uint16_t addr, uint32_t data);
IoOut32:
  mov dx, di  ; dx = addr
  mov eax, esi  ; eax = data
  out dx, eax
  ret

global IoIn32  ; uint32_t IoIn32(uint16_t addr);
IoIn32:
  mov dx, di  ; dx = addr
  in eax, dx
  ret

global GetCS  ; uint16_t GetCS(void);
GetCS:
  xor eax, eax  ; also clears upper 32bits of rax
  mov ax, cs
  ret

global LoadIDT  ; void LoadIDT(uint16_t limit, uint64_t offset);
LoadIDT:
  push rbp
  mov rbp, rsp
  sub rsp, 10
  mov [rsp], di ; limit
  mov [rsp + 2], rsi  ; offset
  lidt [rsp]
  mov rsp, rbp
  pop rbp
  ret

global LoadGDT
LoadGDT:
  push rbp
  mov rbp, rsp
  sub rsp, 10
  mov [rsp], di
  mov [rsp + 2], rsi
  lgdt [rsp]
  mov rsp, rbp
  pop rbp
  ret

global SetCSSS
SetCSSS:
  push rbp
  mov rbp, rsp
  mov ss, si
  mov rax, .next
  push rdi
  push rax
  o64 retf

.next:
  mov rsp, rbp
  pop rbp
  ret

global SetDSAll
SetDSAll:
  mov ds, di
  mov es, di
  mov fs, di
  mov gs, di
  ret

global SetCR3
SetCR3:
  mov cr3, rdi
  ret

extern kernel_main_stack
extern KernelMainNewStack

global KernelMain
KernelMain:
  mov rsp, kernel_main_stack + 1024 * 1024
  call KernelMainNewStack
.fin:
  hlt
  jmp .fin
