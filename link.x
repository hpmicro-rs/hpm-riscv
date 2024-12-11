ENTRY(_start);

PROVIDE(_stack_size = 0x4000);
__stack_size = DEFINED(_stack_size) ? _stack_size : 0x4000;
ASSERT(__stack_size >= 0x400, "Stack size too small");

PROVIDE(_stext = ORIGIN(REGION_TEXT));
PROVIDE(_stack_start = ORIGIN(REGION_STACK) + LENGTH(REGION_STACK));
PROVIDE(_max_hart_id = 0);
PROVIDE(_hart_stack_size = 2K);
PROVIDE(_heap_size = 0);

PROVIDE(InstructionMisaligned = ExceptionHandler);
PROVIDE(InstructionFault = ExceptionHandler);
PROVIDE(IllegalInstruction = ExceptionHandler);
PROVIDE(Breakpoint = ExceptionHandler);
PROVIDE(LoadMisaligned = ExceptionHandler);
PROVIDE(LoadFault = ExceptionHandler);
PROVIDE(StoreMisaligned = ExceptionHandler);
PROVIDE(StoreFault = ExceptionHandler);;
PROVIDE(UserEnvCall = ExceptionHandler);
PROVIDE(SupervisorEnvCall = ExceptionHandler);
PROVIDE(MachineEnvCall = ExceptionHandler);
PROVIDE(InstructionPageFault = ExceptionHandler);
PROVIDE(LoadPageFault = ExceptionHandler);
PROVIDE(StorePageFault = ExceptionHandler);

PROVIDE(SupervisorSoft = DefaultCoreInterruptHandler);
PROVIDE(MachineSoft = DefaultCoreInterruptHandler);
PROVIDE(SupervisorTimer = DefaultCoreInterruptHandler);
PROVIDE(MachineTimer = DefaultCoreInterruptHandler);
PROVIDE(SupervisorExternal = DefaultCoreInterruptHandler);
PROVIDE(MachineExternal = DefaultCoreInterruptHandler);

PROVIDE(DefaultCoreInterruptHandler = DefaultInterruptHandler);
PROVIDE(DefaultHandler = DefaultInterruptHandler);
PROVIDE(ExceptionHandler = DefaultExceptionHandler);


SECTIONS
{
    .flash_config 0x80000400 :
    {
        KEEP(*(.flash_config));
    } > REGION_HEADER

    .boot_header 0x80001000 :
    {
        __boot_header_start__ = .;
        KEEP(*(.boot_header));
        KEEP(*(.fw_info_table));
    } > REGION_HEADER

    .start : {
        . = ALIGN(8);
        KEEP(*(.start))
    } > REGION_TEXT

    .vectors : ALIGN(8) {
       /* . = ALIGN(8); */
        __vector_ram_start__ = .;
        KEEP(*(.vector_table))
        KEEP(*(.vector_table.*))
        KEEP(*(.isr_vector))
        KEEP(*(.vector_s_table))
        KEEP(*(.isr_s_vector))
        . = ALIGN(8);
        __vector_ram_end__ = .;
    } > REGION_FASTTEXT AT > REGION_TEXT

    __vector_load_addr__ = LOADADDR(.vectors);


    .text : ALIGN(8) {
        . = ALIGN(8);
        *(.text)
        *(.text*)

        /* section information for usbh class */
        . = ALIGN(8);
        __usbh_class_info_start__ = .;
        KEEP(*(.usbh_class_info))
        __usbh_class_info_end__ = .;

        /* RT-Thread related sections - end */
        . = ALIGN(8);
    } > REGION_TEXT

    .rodata : ALIGN(8) {
        . = ALIGN(8);
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
        . = ALIGN(8);
    } > REGION_RODATA

    .data : ALIGN(8) {
        . = ALIGN(8);
        __data_start__ = .;

        __global_pointer$ = . + 0x800;
        *(.sdata .sdata.* .sdata2 .sdata2.*);
        *(.data .data.*);
    } > REGION_DATA AT > REGION_RODATA

    /* Allow sections from user `memory.x` injected using `INSERT AFTER .data` */
    . = ALIGN(8);
    __data_end__ = .;

    __data_load_addr__ = LOADADDR(.data);

    .fast : ALIGN(8) {
        . = ALIGN(8);
        __fast_text_start__ = .;
        *(.fast.text)
        *(.fast.text.*)
        . = ALIGN(8);
        __fast_text_end__ = .;
    } > REGION_FASTTEXT AT > REGION_TEXT

    __fast_text_load_addr__ = LOADADDR(.fast);

    .fastdata : ALIGN(8) {
        . = ALIGN(8);
        __fast_data_start__ = .;
        *(.fast.data)
        *(.fast.data.*)
        . = ALIGN(8);
        __fast_data_end__ = .;
    } > REGION_FASTDATA AT > REGION_RODATA

    __fast_data_load_addr__ = LOADADDR(.fastdata);

    .fastbss (NOLOAD) : ALIGN(8) {
        . = ALIGN(8);
        __fast_bss_start__ = .;
        *(.fast.bss)
        *(.fast.bss.*)
        . = ALIGN(8);
        __fast_bss_end__ = .;
    } > REGION_FASTDATA

    .bss (NOLOAD) : ALIGN(8) {
        . = ALIGN(8);
        __bss_start__ = .;

        *(.sbss .sbss.* .bss .bss.*);
    } > REGION_BSS

    . = ALIGN(8);
    __bss_end__ = .;

    /* Non-cacheable data and bss */
    .noncacheable.data : ALIGN(8) {
        . = ALIGN(8);
        __noncacheable_data_start__ = .;
        KEEP(*(.noncacheable.data))
        . = ALIGN(8);
        __noncacheable_data_end__ = .;
    } > REGION_NONCACHEABLE_RAM AT > REGION_RODATA

    __noncacheable_data_load_addr__ = LOADADDR(.noncacheable.data);

    .noncacheable.bss (NOLOAD) : {
        . = ALIGN(8);
        KEEP(*(.noncacheable))
        __noncacheable_bss_start__ = .;
        KEEP(*(.noncacheable.bss))
        __noncacheable_bss_end__ = .;
        . = ALIGN(8);
    } > REGION_NONCACHEABLE_RAM

    /*
    .sh_mem (NOLOAD) : {
        KEEP(*(.sh_mem))
    } > SHARE_RAM
    */

    .ahb_sram (NOLOAD) : {
        KEEP(*(.ahb_sram))
    } > AHB_SRAM

    .heap (NOLOAD) :
    {
        __heap_start__ = .;
        . += _heap_size;
        . = ALIGN(4);
        __heap_end__ = .;
    } > REGION_HEAP

    .stack (NOLOAD) :
    {
        . = ALIGN(16);
        __stack_end__ = .;
        . = ABSOLUTE(_stack_start);
        __stack_start__ = .;
        PROVIDE (__stack_safe = .);
    } > REGION_STACK

    .got (INFO) :
    {
        KEEP(*(.got .got.*));
    }

    .eh_frame (INFO) : { KEEP(*(.eh_frame)) }
    .eh_frame_hdr (INFO) : { *(.eh_frame_hdr) }

    .flash_end :
    {
        __flash_end__ = .;
    } > XPI0_APP

    __fw_size__ = __flash_end__ - _start;
    __fw_offset__ = _start - __boot_header_start__;
}

/* Do not exceed this mark in the error messages above                                    | */
ASSERT(ORIGIN(REGION_TEXT) % 4 == 0, "
ERROR(riscv-rt): the start of the REGION_TEXT must be 4-byte aligned");

ASSERT(ORIGIN(REGION_RODATA) % 4 == 0, "
ERROR(riscv-rt): the start of the REGION_RODATA must be 4-byte aligned");

ASSERT(ORIGIN(REGION_DATA) % 4 == 0, "
ERROR(riscv-rt): the start of the REGION_DATA must be 4-byte aligned");

ASSERT(ORIGIN(REGION_HEAP) % 4 == 0, "
ERROR(riscv-rt): the start of the REGION_HEAP must be 4-byte aligned");

ASSERT(ORIGIN(REGION_STACK) % 4 == 0, "
ERROR(riscv-rt): the start of the REGION_STACK must be 4-byte aligned");


ASSERT(SIZEOF(.stack) > (_max_hart_id + 1) * _hart_stack_size, "
ERROR(riscv-rt): .stack section is too small for allocating stacks for all the harts.
Consider changing `_max_hart_id` or `_hart_stack_size`.");

/* # Other checks */
ASSERT(SIZEOF(.got) == 0, "
ERROR(riscv-rt): .got section detected in the input files. Dynamic relocations are not
supported. If you are linking to C code compiled using the `cc` crate then modify your
build script to compile the C code _without_ the -fPIC flag. See the documentation of
the `cc::Build.pic` method for details.");



