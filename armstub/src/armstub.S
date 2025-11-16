
// !!!!!!!!!! the below script works and we dont enter drop_to_el3 
// !!!!!!!!!! because the system enters in exception level 3 so no need to branch to drop_to_el3

.text
.globl _start
_start:
    // Check current exception level
    mrs x0, CurrentEL
    and x0, x0, #0b1100
    
    // If we're in EL3, continue to boot
    cmp x0, #0b1100
    b.eq continue_boot
    
    // If we're in EL2, drop to EL3
    //cmp x0, #0b1000
    //b.eq drop_to_el3
    
    // If we're in EL1, also drop to EL3  
    //cmp x0, #0b0100
    //b.eq drop_to_el3
    
    // Otherwise, continue
    //b continue_boot

drop_to_el3:
    // Configure Secure Configuration Register
    mov x0, #0x531        // NS=1, IRQ=1, FIQ=1, EA=1
    msr scr_el3, x0
    
    // Set return state to EL2h with all interrupts masked
    mov x0, #0x3c5        // DAIF=1111, M=EL2h
    msr spsr_el3, x0
    
    // Set return address
    adr x0, continue_boot
    msr elr_el3, x0
    
    // Return to EL2 (which will execute continue_boot)
    eret

continue_boot:
    // Load kernel address and jump to it
    ldr x0, =0x80000      // Standard RPi4 kernel load address
    br x0

// Padding to reach required positions
.org 0xf0
.globl stub_magic
stub_magic:
    .word 0x5afe570b

.org 0xf4
.globl stub_version
stub_version:
    .word 0

.org 0xfc
.globl kernel_entry32
kernel_entry32:
    .word 0x0

//.text
//.globl _start
//_start:
//    // Check current exception level
//    mrs x0, CurrentEL
//    and x0, x0, #0b1100
//    
//    // If we're in EL3, continue to boot
//    cmp x0, #0b1100
//    b.eq continue_boot
//    
//    // If we're in EL2, drop to EL3
//    cmp x0, #0b1000
//    b.eq drop_to_el3
//    
//    // If we're in EL1, also drop to EL3  
//    cmp x0, #0b0100
//    b.eq drop_to_el3
//    
//    // Otherwise, continue
//    b continue_boot
//
//drop_to_el3:
//    // Configure Secure Configuration Register
//    mov x0, #0x531        // NS=1, IRQ=1, FIQ=1, EA=1
//    msr scr_el3, x0
//    
//    // Set return state to EL2h with all interrupts masked
//    mov x0, #0x3c5        // DAIF=1111, M=EL2h
//    msr spsr_el3, x0
//    
//    // Set return address
//    adr x0, continue_boot
//    msr elr_el3, x0
//    
//    // Return to EL2 (which will execute continue_boot)
//    eret
//
//continue_boot:
//    // Load kernel address and jump to it
//    ldr x0, =0x80000      // Standard RPi4 kernel load address
//    br x0
//
//// Padding to reach required positions
//.org 0xf0
//.globl stub_magic
//stub_magic:
//    .word 0x5afe570b
//
//.org 0xf4
//.globl stub_version
//stub_version:
//    .word 0
//
//.org 0xfc
//.globl kernel_entry32
//kernel_entry32:
//    .word 0x0//