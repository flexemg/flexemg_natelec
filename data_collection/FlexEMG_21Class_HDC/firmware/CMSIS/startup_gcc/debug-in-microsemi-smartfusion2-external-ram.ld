/*******************************************************************************
 * (c) Copyright 2012-2014 Microsemi SoC Products Group.  All rights reserved.
 * 
 * SmartFusion2 Cortex-M3 linker script for creating a SoftConsole downloadable
 * debug image executing in SmartFusion2 internal eSRAM.
 *
 * SVN $Revision: 6692 $
 * SVN $Date: 2014-07-08 12:14:10 +0100 (Tue, 08 Jul 2014) $
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
  /* SmartFusion2 internal eSRAM */
  esram (rwx) : ORIGIN = 0x20000000, LENGTH = 64k
  
  /* SmartFusion2 development board external RAM */
  external_ram (rwx) : ORIGIN = 0x00000000, LENGTH = 64m
  
  /* External MDDR RAM used for data section. */
  /* !!! This must not overlap with external_ram when MDDR is remapped to 0x00000000.!!! */
  data_external_ram (rw) : ORIGIN = 0xA0100000, LENGTH = 64m
}

ESRAM_START_ADDRESS = 0x20000000;   /* Must be the same value MEMORY region ram ORIGIN above. */
ESRAM_SIZE = 64k;                   /* Must be the same value MEMORY region ram LENGTH above. */
MAIN_STACK_SIZE = 60k;              /* Cortex main stack size. */
PROCESS_STACK_SIZE = 4k;            /* Cortex process stack size (only available with OS extensions).*/
TOP_OF_MDDR = 0xA4000000;           /* Top address of the external MDDR memory. */

/*******************************************************************************
 * End of board customization.
 *******************************************************************************/
PROVIDE (__main_ram_size = ESRAM_SIZE); 
PROVIDE (__main_stack_start = ESRAM_START_ADDRESS + ESRAM_SIZE);
PROVIDE (__process_stack_start = __main_stack_start - MAIN_STACK_SIZE);
PROVIDE (_estack = __main_stack_start);
PROVIDE (__mirrored_nvm = 0);   /* Indicate to startup code that NVM is not mirrored to VMA address .text copy is required. */

/*
 * Remap instruction for startup code and debugger:
 *  0: remap eNVM to address 0x00000000
 *  1: remap eSRAM to address 0x00000000
 *  2: remap external DDR memory to address 0x00000000
 */
PROVIDE (__smartfusion2_memory_remap = 2);


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
  } >external_ram
  
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
  } >external_ram
  /* .ARM.exidx is sorted, so has to go in its own output section.  */
   __exidx_start = .;
  .ARM.exidx :
  {
    *(.ARM.exidx* .gnu.linkonce.armexidx.*)
  } >external_ram
  __exidx_end = .;
  _etext = .;
  PROVIDE(__text_end = .);

  .data :
  {
    __data_load = LOADADDR (.data);
    _sidata = LOADADDR (.data);
    __data_start = .;
    _sdata = .;
    KEEP(*(.jcr))
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.* .gnu.linkonce.d.*)
    . = ALIGN(0x10);
    _edata = .;
  } >data_external_ram 

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
  } >data_external_ram 

  .heap :
  {
    __heap_start__ = .;
    . += (TOP_OF_MDDR - _end);
    . = ALIGN(0x10);
    _eheap = .;
  } >data_external_ram

  .stack :
  {
    __stack_start__ = .;
    . += PROCESS_STACK_SIZE;
    . = ALIGN(4);
    . += MAIN_STACK_SIZE;
    . = ALIGN(0x10);
    _estack = .;
  } >esram
  
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
  /DISCARD/ : { *(.note.GNU-stack) *(.isr_vector) }
}
