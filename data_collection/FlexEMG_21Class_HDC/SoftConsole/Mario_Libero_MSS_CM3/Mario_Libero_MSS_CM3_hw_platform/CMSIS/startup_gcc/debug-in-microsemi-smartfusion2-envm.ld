/*******************************************************************************
 * (c) Copyright 2012-2014 Microsemi SoC Products Group.  All rights reserved.
 * 
 * SmartFusion2 Cortex-M3 linker script for creating a SoftConsole downloadable
 * debug image executing in SmartFusion2 internal eNVM.
 *
 * SVN $Revision: 6693 $
 * SVN $Date: 2014-07-08 12:22:53 +0100 (Tue, 08 Jul 2014) $
 */

OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
GROUP(-lc -lgcc -lm)
OUTPUT_ARCH(arm)
ENTRY(Reset_Handler)
SEARCH_DIR(.)
__DYNAMIC  =  0;

/*******************************************************************************
 * Start of board customization.
 *******************************************************************************/
MEMORY
{
  /*
   * WARNING: The words "SOFTCONSOLE", "FLASH", and "USE", the colon ":", and
   *          the name of the type of flash memory are all in a specific order.
   *          Please do not modify that comment line, in order to ensure
   *          debugging of your application will use the flash memory correctly.
   */

  /* SOFTCONSOLE FLASH USE: microsemi-smartfusion2-envm */
  rom (rx)  : ORIGIN = 0x60000000, LENGTH = 256k
  
  /* SmartFusion2 internal eNVM mirrored to 0x00000000 */
  romMirror (rx) : ORIGIN = 0x00000000, LENGTH = 256k

  /* SmartFusion2 internal eSRAM */
  ram (rwx) : ORIGIN = 0x20000000, LENGTH = 64k
}

RAM_START_ADDRESS = 0x20000000;     /* Must be the same value MEMORY region ram ORIGIN above. */
RAM_SIZE = 64k;                     /* Must be the same value MEMORY region ram LENGTH above. */
MAIN_STACK_SIZE = 8k;               /* Cortex main stack size. */
PROCESS_STACK_SIZE = 4k;            /* Cortex process stack size (only available with OS extensions).*/

/*******************************************************************************
 * End of board customization.
 *******************************************************************************/
 
PROVIDE (__main_stack_start = RAM_START_ADDRESS + RAM_SIZE);
PROVIDE (__process_stack_start = __main_stack_start - MAIN_STACK_SIZE);
PROVIDE (_estack = __main_stack_start);
PROVIDE (__mirrored_nvm = 1);   /* Indicate to startup code that NVM is mirrored to VMA address and no text copy is required. */

/*
 * Remap instruction for startup code and debugger:
 *  0: remap eNVM to address 0x00000000
 *  1: remap eSRAM to address 0x00000000
 *  2: remap external DDR memory to address 0x00000000
 */
PROVIDE (__smartfusion2_memory_remap = 0);

SECTIONS
{
  .vector_table :
  {
    __vector_table_load = LOADADDR(.vector_table);
    __vector_table_start = .;
    __vector_table_vma_base_address = .;
    KEEP(*(.isr_vector))
    . = ALIGN(0x10);
    _evector_table = .;
  } >romMirror AT>rom
  
  .text :
  {
    CREATE_OBJECT_SYMBOLS
    __text_load = LOADADDR(.text);
    __text_start = .;
    
    *(.text .text.* .gnu.linkonce.t.*)
    *(.plt)
    *(.gnu.warning)
    *(.glue_7t) *(.glue_7) *(.vfp11_veneer)

    . = ALIGN(0x4);
    /* These are for running static constructors and destructors under ELF.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*crtend.o(.ctors))
    KEEP (*crtbegin.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*crtend.o(.dtors))

    *(.rodata .rodata.* .gnu.linkonce.r.*)

    *(.ARM.extab* .gnu.linkonce.armextab.*)
    *(.gcc_except_table) 
    *(.eh_frame_hdr)
    *(.eh_frame)

    KEEP (*(.vector_table))
    KEEP (*(.init))
    KEEP (*(.fini))

    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array))
    PROVIDE_HIDDEN (__init_array_end = .);
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(.fini_array))
    KEEP (*(SORT(.fini_array.*)))
    PROVIDE_HIDDEN (__fini_array_end = .);
    . = ALIGN(0x10);
  } >romMirror AT>rom

  /* .ARM.exidx is sorted, so has to go in its own output section.  */
   __exidx_start = .;
  .ARM.exidx :
  {
    *(.ARM.exidx* .gnu.linkonce.armexidx.*)
  } >ram AT>rom
  __exidx_end = .;
  _etext = .;

  .data :
  {
    __data_load = LOADADDR(.data);
    _sidata = LOADADDR (.data);
    __data_start = .;
    _sdata = .;
    KEEP(*(.jcr))
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.* .gnu.linkonce.d.*)
    . = ALIGN (0x10);
    _edata = .;
  } >ram AT>rom

  .bss :
  {
    __bss_start__ = . ;
    _sbss = .;
    *(.shbss)
    *(.bss .bss.* .gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(0x10);
    __bss_end__ = .;
    _end = .;
    __end = _end;
    _ebss = .;
    PROVIDE(end = .);
  } >ram AT>rom

  .heap :
  {
    __heap_start__ = .;
    . += (RAM_START_ADDRESS + RAM_SIZE - PROCESS_STACK_SIZE - MAIN_STACK_SIZE - _end);
    . = ALIGN(0x10);
    _eheap = .;
  } >ram

  .stack :
  {
    __stack_start__ = .;
    . += PROCESS_STACK_SIZE;
    . = ALIGN(4);
    . += MAIN_STACK_SIZE;
    . = ALIGN(0x10);
    _estack = .;
  } >ram
  
  .stab 0 (NOLOAD) :
  {
    *(.stab)
  }

  .stabstr 0 (NOLOAD) :
  {
    *(.stabstr)
  }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
  .note.gnu.arm.ident 0 : { KEEP (*(.note.gnu.arm.ident)) }
  .ARM.attributes 0 : { KEEP (*(.ARM.attributes)) }
  /DISCARD/ : { *(.note.GNU-stack)  }
}
