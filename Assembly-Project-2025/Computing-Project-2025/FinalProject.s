# LINK TO TEAM VIDEO
# https://

  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global Main
  .global SysTick_Handler
  .global EXTI0_IRQHandler

  @ Definitions are in definitions.s to keep this file "clean"
  .include "definitions.s"

@  .equ    BLINK_PERIOD, 3000
  .equ    DAMAGE_BLINK_PERIOD, 750

  .section .text

Main:
  PUSH  {R4-R5,LR}


  @
  @ Prepare GPIO Port E Pin 9 for output (LED LD3)
  @ We'll blink LED LD3 (the orange LED)
  @

  @ Enable GPIO port E by enabling its clock
  LDR     R4, =RCC_AHBENR
  LDR     R5, [R4]
  ORR     R5, R5, #(0b1 << (RCC_AHBENR_GPIOEEN_BIT))
  STR     R5, [R4]

  @ Configure LD3 for output
  @   by setting bits 27:26 of GPIOE_MODER to 01 (GPIO Port E Mode Register)
  @   (by BIClearing then ORRing)
  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD3_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD3_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD4_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD4_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD5_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD5_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD6_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD6_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD7_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD7_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD8_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD8_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD9_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD9_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 


  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD10_PIN*2))   @ Modify ...
  ORR     R5, #(0b01<<(LD10_PIN*2))   @ write 01 to bits 
  STR     R5, [R4]                    @ Write 


  @ Initialise the first countdown

  LDR     R4, =blink_countdown
  LDR     R5, =BLINK_PERIOD
  LDR     R6, [R5]
  STR     R6, [R4]

  @ Configure SysTick Timer to generate an interrupt every 1ms

  LDR     R4, =SCB_ICSR               @ Clear any pre-existing interrupts
  LDR     R5, =SCB_ICSR_PENDSTCLR     @
  STR     R5, [R4]                    @

  LDR     R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR     R5, =0                      @   by writing 0 to CSR
  STR     R5, [R4]                    @   CSR is the Control and Status Register
  
  LDR     R4, =SYSTICK_LOAD           @ Set SysTick LOAD for 1ms delay
  LDR     R5, =7999                   @ Assuming 8MHz clock
  STR     R5, [R4]                    @ 

  LDR     R4, =SYSTICK_VAL            @   Reset SysTick internal counter to 0
  LDR     R5, =0x1                    @     by writing any value
  STR     R5, [R4]

  LDR     R4, =SYSTICK_CSR            @   Start SysTick timer by setting CSR to 0x7
  LDR     R5, =0x7                    @     set CLKSOURCE (bit 2) to system clock (1)
  STR     R5, [R4]                    @     set TICKINT (bit 1) to 1 to enable interrupts
                                      @     set ENABLE (bit 0) to 1


  @
  @ Prepare external interrupt Line 0 (USER pushbutton)
  @ We'll count the number of times the button is pressed
  @

  @ Initialise count to zero
  LDR   R4, =button_count             @ count = 0;
  MOV   R5, #0                        @
  STR   R5, [R4]                      @

  @ Configure USER pushbutton (GPIO Port A Pin 0 on STM32F3 Discovery
  @   kit) to use the EXTI0 external interrupt signal
  @ Determined by bits 3..0 of the External Interrrupt Control
  @   Register (EXTIICR)
  LDR     R4, =SYSCFG_EXTIICR1
  LDR     R5, [R4]
  BIC     R5, R5, #0b1111
  STR     R5, [R4]

  @ Enable (unmask) interrupts on external interrupt Line0
  LDR     R4, =EXTI_IMR
  LDR     R5, [R4]
  ORR     R5, R5, #1
  STR     R5, [R4]

  @ Set falling edge detection on Line0
  LDR     R4, =EXTI_FTSR
  LDR     R5, [R4]
  ORR     R5, R5, #1
  STR     R5, [R4]

  @ Enable NVIC interrupt #6 (external interrupt Line0)
  LDR     R4, =NVIC_ISER
  MOV     R5, #(1<<6)
  STR     R5, [R4]

  MOV     R11, #0  @ Your current level
  MOV     R10, #3  @ Current light on  
  MOV     R9, #3   @ Player health
  MOV     R8, #0   @ Game State, 0 is playing, 1 is dead, 3 is win
  MOV     R7, #0   @ Checks if it is in damage loop

  @ Nothing else to do in Main
  @ Idle loop forever (welcome to interrupts!!)
Idle_Loop:
  B     Idle_Loop
  
End_Main:
  POP   {R4-R5,PC}



  .type  clear_lights, %function
clear_lights:                   @ Function to clear all the lights

  PUSH {R4, R5, R6, LR}

  CMP   R7, #2                  
  BGE   .LdamageLights          @ Making sure it only clears the appropriate lights

  LDR   R4, =GPIOE_BSRR
  LDR   R5, =(1<<(LD3_PIN+16))  @ The upper half of BSRR resets the pin
  STR   R5, [R4]

  LDR   R4, =GPIOE_BSRR
  LDR   R5, =(1<<(LD10_PIN+16)) @ The upper half of BSRR resets the pin
  STR   R5, [R4]

.LdamageLights:

  LDR   R4, =GPIOE_BSRR
  LDR   R5, =(1<<(LD4_PIN+16))  @ The upper half of BSRR resets the pin
  STR   R5, [R4]

  LDR   R4, =GPIOE_BSRR
  LDR   R5, =(1<<(LD5_PIN+16))  @ The upper half of BSRR resets the pin
  STR   R5, [R4]

  LDR   R4, =GPIOE_BSRR
  LDR   R5, =(1<<(LD6_PIN+16))  @ The upper half of BSRR resets the pin
  STR   R5, [R4]

  LDR   R4, =GPIOE_BSRR
  LDR   R5, =(1<<(LD7_PIN+16))  @ The upper half of BSRR resets the pin
  STR   R5, [R4]

  LDR   R4, =GPIOE_BSRR
  LDR   R5, =(1<<(LD8_PIN+16))  @ The upper half of BSRR resets the pin
  STR   R5, [R4]

  LDR   R4, =GPIOE_BSRR
  LDR   R5, =(1<<(LD9_PIN+16))  @ The upper half of BSRR resets the pin
  STR   R5, [R4]

  POP  {R4, R5, R6, PC}


  .type  SysTick_Handler, %function
SysTick_Handler:

  PUSH  {R4, R5, R6, LR}

  CMP   R8, #0                      @ Checks game state
  BNE   .LendIfDelay                @ If not currently playing skip

  LDR   R4, =blink_countdown        @ if (countdown != 0) {
  LDR   R5, [R4]                    @
  CMP   R5, #0                      @
  BEQ   .LelseFire                  @

  SUB   R5, R5, #1                  @   countdown = countdown - 1;
  STR   R5, [R4]                    @

  B     .LendIfDelay                @ }



.LelseFire:                         @ else {  DAMAGE_BLINK_PERIOD

  CMP     R7, #1                    @ checking to see if you are currently in a damage loop
  BLO     .LnoDamage

  BL      clear_lights

  LDR     R4, =GPIOE_ODR            @   Invert LD3
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD3_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =GPIOE_ODR            @   Invert LD3
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD10_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =DAMAGE_BLINK_PERIOD  @
  STR     R5, [R4]                  @

  ADD     R7, R7, #1                @ Increment damage loop count

  CMP     R7, #7                    @ If not 7 continue the damage loop
  BNE     .LendIfDelay

  MOV     R7, #0                    @ End damage loop

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @

  B       .LendIfDelay

.LnoDamage:                         @ Sort of a switch case for which light is on

  CMP     R10, #4
  BEQ     .Llight4
  CMP     R10, #5
  BEQ     .Llight6
  CMP     R10, #6
  BEQ     .Llight8
  CMP     R10, #7
  BEQ     .Llight10
  CMP     R10, #8
  BEQ     .Llight9
  CMP     R10, #9
  BEQ     .Llight7
  CMP     R10, #10
  BEQ     .Llight5


  LDR     R4, =GPIOE_ODR            @   Invert LED3
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD3_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @


  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD3_PIN)     @ Test if the LED pin is set (LED is on)
  BNE   .LendIfDelay            @ If LED is off, skip counting
  B     .Lincrement

.Llight4:

  LDR     R4, =GPIOE_ODR            @   Invert LED4
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD4_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @


  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD4_PIN)     @ Test if the LED pin is set (LED is on)
  BNE   .LendIfDelay            @ If LED is off, skip counting
  B     .Lincrement

.Llight5:

  LDR     R4, =GPIOE_ODR            @   Invert LED5
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD5_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD5_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @


  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD5_PIN)     @ Test if the LED pin is set (LED is on)
  BNE   .LendIfDelay            @ If LED is off, skip counting
  MOV   R10, #2
  B     .Lincrement

.Llight6:

  LDR     R4, =GPIOE_ODR            @   Invert LED6
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD6_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD6_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @


  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD6_PIN)     @ Test if the LED pin is set (LED is on)
  BNE   .LendIfDelay            @ If LED is off, skip counting
  B     .Lincrement

.Llight7:

  LDR     R4, =GPIOE_ODR            @   Invert LD7
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD7_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD7_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @


  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD7_PIN)     @ Test if the LED pin is set (LED is on)
  BNE   .LendIfDelay            @ If LED is off, skip counting
  B     .Lincrement

.Llight8:

  LDR     R4, =GPIOE_ODR            @   Invert LD8
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD8_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD8_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @


  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD8_PIN)     @ Test if the LED pin is set (LED is on)
  BNE   .LendIfDelay            @ If LED is off, skip counting
  B     .Lincrement

.Llight9:

  LDR     R4, =GPIOE_ODR            @   Invert LD9
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD9_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD9_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @


  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD9_PIN)     @ Test if the LED pin is set (LED is on)
  BNE   .LendIfDelay            @ If LED is off, skip counting
  B     .Lincrement

.Llight10:
 
  LDR     R4, =GPIOE_ODR            @   Invert LD10
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD10_PIN))    @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD10_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  STR     R6, [R4]                  @


  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD10_PIN)    @ Test if the LED pin is set (LED is on)
  BNE   .LendIfDelay            @ If LED is off, skip counting
  B     .Lincrement             



.Lincrement:
  ADD     R10, R10, #1              @ Change current light

.LendIfDelay:                       @ }

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  @ Return from interrupt handler
  POP  {R4, R5, R6, PC}



@
@ External interrupt line 0 interrupt handler
@   (count button presses)
@
  .type  EXTI0_IRQHandler, %function
EXTI0_IRQHandler:

  @ R8 represent if you have lost


  PUSH  {R4, R5, R6, LR}

  CMP   R7, #1                 @ Checking if you are currently in a damage loop
  BGE   .Lskip

  CMP   R8, #0                 @ Checking the state of the game
  BEQ   .Lcontinue             @ If still playing continue
  MOV   R8, #0                 @ Resetting stats
  MOV   R9, #3
  MOV   R10, #3             
  MOV   R11, #0

  BL    clear_lights

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @

  MOV     R6, #1000
  STR     R6, [R5]
  STR     R6, [R4]                  @

  B     .Lskip

.Lcontinue:
  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R6, [R4]                @ Load current state of Port E
  TST   R6, #(1 << LD3_PIN)     @ Test if the LED pin is set (LED is on)
  BEQ   .Ldamage                @ If LED is off, take damage

  @ LED is on: increment the button press count
  LDR   R4, =button_count
  LDR   R5, [R4]
  ADD   R5, R5, #1
  STR   R5, [R4]

  B     .LlevelUp


.LlevelUp:

  ADD     R11, R11, #1              @ Level up
  CMP     R11, #3                   @ If you reach level 5 you win
  BEQ     .Lwin

  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  LDR     R6, [R5]
  SUB     R6, R6, #300              @ Reduce the Blink Period so it's faster

  STR     R6, [R5]
  STR     R6, [R4]                  @

  B       .Lskip


.Ldamage:
  SUB     R9, R9, #1                @ Lower HP

  MOV     R10, #4                   @ Reset light loop so it starts from the beginning

  CMP     R9, #0                    @ Check if you are dead
  BNE     .LdamageLightsLoop        @ Otherwise you die

  MOV     R8, #1                    @ Set current state to death

  BL      clear_lights

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD3_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD5_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD8_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD10_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD4_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD9_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  B     .Lskip


.Lwin:
  
  MOV   R8, #2                  @ Set current state to win

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD3_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD4_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD5_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD6_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD7_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD8_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD9_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR

  LDR   R4, =GPIOE_ODR          @ Load address of GPIOE_ODR
  LDR   R5, [R4]                @ Load current state of GPIOE ODR
  ORR   R5, R5, #(1 << LD10_PIN) @ Set LD4 bit without changing other bits
  STR   R5, [R4]                @ Store the new value back to GPIOE ODR
  

  B     .Lskip


.LdamageLightsLoop:

  MOV   R7, #1                  @ Start damage loop

.Lskip:
  @ Clear (acknowledge) the external interrupt
  LDR   R4, =EXTI_PR
  MOV   R5, #(1 << 0)
  STR   R5, [R4]


  POP   {R4, R5, R6, PC}

  .section .data
  
button_count:
  .space  4

blink_countdown:
  .space  4

BLINK_PERIOD:
  .word 1000

  .end