.data

/* Note
   Calculting offset in a structure containing only function 
   pointers is equivalent to : 

     Number of functions pointers declared before the desired function
     pointer * Size in bytes of a function address (8 in 32-bit)

   However, note that such calculations are not necessary for the JNI
   as its documentation already provides the index of each of its
   functions. So you just have to multiply the offset provided by the
   documentation by 8.
   
   Example :
   
*/

msg:
  .asciz  "A wild Assembly appears !\n(Level 64)\n"
msg_len = . - msg

/* Note
   x19..x28 are callee-saved registers, meaning that :
   - We must save their values somewhere (in the stack most frequently)
     if we want to write in them.
   - Their value should be preserved after calling other procedures
     if they follow the ARMv8 64 bits Application Procedure Call
     Standard
   Avoid using x9..x15 as they are caller-saved registers, meaning that
   you have to save them before calling any sub-procedure since their
   value can be overwritten by these sub-procedures.
*/

/* This example gambles on the fact that unused arguments registers
   will actually be unused.
   Meaning that functions officially taking 3 arguments in x0, x1 and x2
   won't try to secretly read a potential argument stored in x3. */
.text
.align 4
.globl Java_your_pack_testactivity_TestActivity_testMe
.type Java_your_pack_testactivity_TestActivity_testMe, %function
Java_your_pack_testactivity_TestActivity_testMe:
  sub sp, sp,  32         // Generate some stack space to push x19..x21 and lr
                          // 4 registers of 8 bytes each -> 32 bytes needed
  stp x19, x20, [sp]      // Push x19, x20
  stp x21, lr, [sp,16]    // Push x21, lr (x30)

  // Useful passed parameters - x0 : *_JNIEnv
  mov x19, x0             // x19 <- *_JNIEnv - Save *_JNIEnv for the second method

  // Preparing to call NewByteArray(*_JNIEnv : x0, size_of_array : x1).
  // *_JNIEnv is already loaded.
  mov x1, #msg_len        // x1 <- msg_len value - Used to set requested byte array size
  ldr x20, [x0]           // Getting NewByteArray : Get *JNINativeInterface
                          // from *_JNIEnv.
                          // *JNINativeInterface is preserved for later use.
  ldr x2, [x20, 1408]     // Get *JNINativeInterface->NewByteArray.
                          // +1408 is NewByteArray 's offset

  blr x2                  // x0 : *bytearray <- NewByteArray(*_JNIEnv : x0,
                          //                            size_of_array : x1)  

  mov x21, x0             // x21 <- *bytearray
                          // We need to keep the returned *bytearray elsewhere
                          // as it will be returned by our procedure.
                          // Since we need to call other procedures before,
                          // x0 is needed for *_JNIEnv and x0 can be overwritten
                          // by any procedure called anyway, we keep that value
                          // safe in x21, which is callee-saved.
  /* Preparing to call 
     *JNativeInteface->SetByteArrayRegion(*_JNIEnv : x0, 
                                        *bytearray : x1, 
                                                 0 : x2, 
                                 int bytes_to_copy : x3, 
                                             *from : x4) */  
  ldr x5, [x20, 1664]     // x20 <- [x20, #1664] : 
                          // *JNativeInterface->SetByteArrayRegion (+1664).*/
                          
  mov x1, x0              // x1 <- *bytearray - Our Java byte array (address) to fill up
  mov x0, x19             // x0 <- *_JNIEnv - Previously saved in x19  
  mov x2, 0               // x2 <- 0 - The source array offset. We copy the
                          //           entire message (msg) so we start from 0.
  mov x3, #msg_len        // x3 <- bytes_to_copy = msg_len  
  adr x4, msg             // x4 <- *from = msg address (aka. *msg in C)
                          //       Our ASCII message we wish to store inside
                          //       the created Java byte[] array
  blr x5                  // SetByteArrayRegion(*_JNIEnv : x0, 
                          //                  *bytearray : x1, 
                          //                           0 : x2, 
                          //                     msg_len : x3, 
                          //                        *msg : x4)  

  mov x0, x21             // x0 <- *bytearray : The Java byte array
                          //       (address), now filled with our message.

  ldp x19, x20, [sp]      // Pop the registers : Load their previously saved values.
  ldp x21, lr, [sp, 16]   // See the first instructions of this routine.
  add sp, sp, 32
  
  ret
