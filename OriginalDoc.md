

# Example of calling the JNI directly from ARM Assembly on Android

Author : **Myy**

This document demonstrates how to generate a library, with an assembly procedure that will be called through the Java Native Interface, using an Android project as an example. The procedure will return a Java byte[] array object containing the content of a static string, defined in the library. In most cases, C/C++ will do a far better job. However, for the record, this document provide informations about how to do that without a C compiler.

This document complements Example of calling Java methods through the JNI, in ARM Assembly, on Android.

### The example

#### Coding the library

This example is heavily commented as I wrote it while learning assembly. This should provide a clear understanding of this example for people new to ARM Assembly.

**wild.s**

```

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

```


Then assemble and link this example library :

```

# cross compiler prefix. Remove if you're assembling from an ARM machine
export PREFIX="armv7a-hardfloat-linux-gnueabi"
export DEST="/path/to/your/TestActivityProject/app/src/main/jniLibs"
$PREFIX-as -o wild.o wild.s
$PREFIX-ld.gold -shared --dynamic-linker=/system/bin/linker -shared --hash-style=sysv -o libwildAssembly.so wild.o
cp libwildAssembly.so $DEST/armeabi/libwildAssembly.so
cp libwildAssembly.so $DEST/armeabi-v7a/libwildAssembly.so

```


##### Calling this from Android

Generate a project with :
* the same package name you used in the assembly (your.pack.testactivity),
* an activity named `TestActivity` .

And define `native byte[] testMe()` in it.**TestActivity.java**

```

package your.pack.testactivity;  
  
import android.support.v7.app.AppCompatActivity;  
import android.os.Bundle;  
import android.widget.TextView;  
  
public class TestActivity extends AppCompatActivity {  
  
  /* Basically, the android system will look for a "libwildAssembly.so" in the  
     app's private and public folders. */  
  static { System.loadLibrary("wildAssembly"); }  
  
  /* And then look for a symbol named : 
    Java_package_name_ClassName_methodName. 
      
    The current package name is : your.pack.testactivity 
    The current class name is : TestActivity  
    The method name is testMe 
    So the android linker will look for a symbol named : 
    Java_your_pack_testactivity_TestActivity_testMe  
      
    There is no signature or return value check in assembly, so your 
    java compiler will compile this class EVEN if the library is not 
    there or if the symbol name is invalid. 
    There is no such things as "return type" or "parameters type" in  
    assembly so no such check will be performed ever. */  
  static native byte[] testMe();  
    
  @Override  
  protected void onCreate(Bundle savedInstanceState) {  
    super.onCreate(savedInstanceState);  
  
    setContentView(R.layout.activity_test);  
  
    TextView mContentView = (TextView) findViewById(R.id.fullscreen_content);  
    mContentView.setText(new String(testMe()));  
  
  }  
  
  /* Try it : Redeclare testMe() as 'native int testMe()' and  
      new String(testMe()) by String.format(Locale.C, "%d", testMe()) */  
}

```
**activity_test.xml**

```

<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"  
              xmlns:tools="http://schemas.android.com/tools"  
              android:layout_width="match_parent"  
              android:layout_height="match_parent"  
              android:background="#0099cc"  
              tools:context="your.pack.testactivity.TestActivity"  
  >  
  
  <!-- The primary full-screen view. This can be replaced with whatever view  
          is needed to present your content, e.g. VideoView, SurfaceView,  
          TextureView, etc. -->  
  <TextView  
    android:id="@+id/fullscreen_content"  
    android:layout_width="match_parent"  
    android:layout_height="match_parent"  
    android:gravity="center"  
    android:keepScreenOn="true"  
    android:text="@string/dummy_content"  
    android:textColor="#33b5e5"  
    android:textSize="50sp"  
    android:textStyle="bold"  
    />  
  
</FrameLayout>

```


Create a directory named **jniLibs** in **$YourProjectRootFolder/app/src/main** if it doesn&amp;#39;t exist

Then create two directories **armeabi** and **armeabi-v7a** in it so you have :
* **$YourProjectRootFolder/app/src/main/jniLibs/armeabi**
* **$YourProjectRootFolder/app/src/main/jniLibs/armeabi-v7a**

Copy your library **libwildAssembly.so** in those folders

##### How it works, basically

For what I understand, when you define the following in a Java class :

```java

package your.package

public class YourClass ... {  
  ... {  
  System.loadLibrary("name");   
  }  
  ...  
  native return_type methodName(parameters...)  
  ...  
}

```

*  The JVM (or Dalvik) will first search for the library **name** in a way typical to the current system.**libname.so** in places referenced by the current `LD_LIBRARY_PATH`.
* Then, it will look for a symbol following this pattern in the library found : `Java_your_package_YourClass_methodName`

Once the symbol found, it will execute the instructions at the symbol address, passing the following arguments using the standard procedure call convention :
* the address of the data structure representing the current Java environment (_JNIEnv* in C programs) (in r0 on ARM)
* the address of the data structure representing the current Java object (this) on which the method is called (jobject thisObj) (in r1)
* the other arguments (in r2, r3 and the stack)

If you look in the **jni.h** file provided with your NDK, you&amp;#39;ll see that `_JNIEnv` is a data structure defined like this :

```

struct _JNIEnv {    
    const struct JNINativeInterface* functions;    
  /* C++ specific hacks around 'functions' */  
}

```


The `JNINativeInterface` is a data structure composed only by function pointers, plus a starting padding (of 4 void* pointers).

So basically, `_JNIEnv*` equates to :
* `_JNIEnv *`
   * `JNINativeInterface *`
      * paddingx4
      * `GetVersion *`
      * `DefineClass *`
      * …

Getting the address offset of a function pointer defined in `JNINativeInterface` tends to boil down to :

    Size of a procedure address (4) * number of statements preceding the statement defining the function pointer

For example, the offset of `NewByteArray`, preceded by 176 statements, is 176*4 = 704.

> This assumes that `void*` and function pointers are of the same size.

Since the argument provided by the JNI to the native procedure is a pointer to `_JNIEnv`, calling NewByteArray requires to :
* Get the data structure pointed by **r0**
* Get the data structure pointed in result + 704
* Call the result

However, note that most of the JNI functions require `_JNIEnv*`, so you&amp;#39;ll have to save **r0** somewhere in order to call the different functions correctly.

Once you know that, the rest is kinda easy.

Look up the appropriate functions to call in the JNI documentation and call them with the right arguments.
