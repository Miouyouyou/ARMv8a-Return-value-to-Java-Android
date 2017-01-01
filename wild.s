.data

/* Note : Calculting offset in a structure containing only function 
          pointers is equivalent to : 

     Number of functions pointers declared before the desired function 
     pointer * Size in bytes of a function address (4 in 32-bit)

   However, note that such calculations are not necessary for the JNI
   as its documentation already provides the addresses of each 
   pointer.
*/

msg:
  .ascii  "A wild Assembly appears !\n"
msg_len = . - msg

.text
.align 2
.globl Java_your_pack_testactivity_TestActivity_testMe
.type Java_your_pack_testactivity_TestActivity_testMe, %function
Java_your_pack_testactivity_TestActivity_testMe:
  stmfd sp!, {r4-r6, lr} // Prologue. We will use r4 and r6.
                         // Is push more useful than stmfd ?

  // Useful passed parameters - r0 : *_JNIEnv
  mov r4, r0         // Save *_JNIEnv for the second method

  // Preparing to call NewByteArray(*_JNIEnv : r0, size_of_array : r1).
  // *_JNIEnv is already loaded.
  mov r1, #msg_len   // r1 : size_of_array = msg_len
  ldr r5, [r0]       // Getting NewByteArray : Get *JNINativeInterface
                     // from *_JNIEnv.
                     // *JNINativeInterface is preserved for later use.
  ldr r3, [r5, #704] // Get *JNINativeInterface->NewByteArray.
                     // +704 is NewByteArray 's offset
  blx r3             // r0 : *bytearray <- NewByteArray(*_JNIEnv : r0,
                     //                            size_of_array : r1)  
  mov r6, r0         // We need to keep *bytearray elsewhere as it will 
                     // be returned by our procedure.
                     // r0 is needed for *_JNIEnv
    
  /* Preparing to call 
     *JNativeInteface->SetByteArrayRegion(*_JNIEnv : r0, 
                                        *bytearray : r1, 
                                                 0 : r2, 
                                 int bytes_to_copy : r3, 
                                             *from : sp) */  
  
  mov r1, r0         // r1 : *bytearray - The return value of 
                     //      NewByteArray  
  mov r0, r4         // r0 : *_JNIEnv - Previously saved in r4  
  mov r2, #0         // r2 : 0 - Define the starting index for the 
                     //      array-copy procedure of SetByteArrayRegion  
  mov r3, #msg_len   // r3 : bytes_to_copy = msg_len  
  sub sp, sp, #4     // Preparing the stack in which we'll store the 
                     // address of msg  
  ldr r4, =msg       // We won't need our previous copy of *_JNIEnv 
                     // anymore, so we replace it by *msg.  
  str r4, [sp]       // sp : *from = msg address - the native byte array
                     // to copy inside the Java byte[] array  
  ldr r5, [r5, #832] // r5 <- [r5, #832] : 
                     // *JNativeInterface->SetByteArrayRegion (+832). 
                     // We don't need r5 after this so we store the 
                     // function address directly in it.  
  blx r5             // SetByteArrayRegion(*_JNIEnv : r0, 
                     //                  *bytearray : r1, 
                     //                           0 : r2, 
                     //                 size_of_msg : r3, 
                     //                        *msg : sp)  
    
  add sp, sp, #4         // Get our stack space back !  
  mov r0, r6             // *bytearray : Our return value  
  ldmfd sp!, {r4-r6, pc} // Restoring the scratch-registers and 
                         // returning by loading the link-register 
                         // into the program-counter
