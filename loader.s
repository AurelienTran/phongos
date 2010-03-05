# making entry point visible to linker
.global loader

# setting up the Multiboot header
.set ALIGN,    1<<0             # align loaded modules on page boundaries
.set MEMINFO,  1<<1             # provide memory map
.set FLAGS,    ALIGN | MEMINFO  # this is the Multiboot 'flag' field
.set MAGIC,    0x1BADB002       # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS) # checksum required

.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# reserve initial kernel stack space
.set STACKSIZE, 0x4000          # this is 16k.
.comm stack, STACKSIZE, 32      # reserve 16k stack on a quadword boundary

loader:
	# Initilization
	mov  $(stack + STACKSIZE), %esp # set up the stack
	push %eax                       # Multiboot magic number
	push %ebx                       # Multiboot data structure

	# calling global variable constructor
	mov  $start_ctors, %ebx
	jmp  2f
1:
	call *(%ebx)
	add  $4, %ebx
2:
	cmp  $end_ctors, %ebx
	jb   1b

	call kmain                      # call kernel proper

	# calling global variable constructor
	mov  $start_dtors, %ebx
	jmp  4f
3:
	call *(%ebx)
	add  $4, %ebx
4:
	cmp  $end_dtors, %ebx
	jb   3b

	hlt

