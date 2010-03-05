extern "C" void kmain(void* mdb, unsigned int magic);

// Kernel main function
void kmain( void* mbd, unsigned int magic )
{
	if ( magic != 0x2BADB002 )
	{
		/* Something went not according to specs. Print an error */
		/* message and halt, but do *not* rely on the multiboot */
		/* data structure. */
		return;
	}

	/* You could either use multiboot.h */
	/* (http://www.gnu.org/software/grub/manual/multiboot/multiboot.html#multiboot_002eh) */
	/* or do your offsets yourself. The following is merely an example. */ 
	char* boot_loader_name =(char*)((long*)mbd)[16];
	(void)boot_loader_name;

	/* Print the famous hello world */
	char msg[] = "Hello world !";

	unsigned char *videoram = (unsigned char *) 0xb8000;

	for(unsigned int i=0; i<sizeof(msg); i++)
	{
		videoram[0] = msg[i]; // character
		videoram[1] = 0x07; // color
		videoram++;
		videoram++;
	}

	/* Write your kernel here. */
	return;
}
