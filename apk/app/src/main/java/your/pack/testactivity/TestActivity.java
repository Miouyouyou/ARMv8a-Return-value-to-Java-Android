package your.pack.testactivity;
	
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import java.util.Locale;

public class TestActivity extends AppCompatActivity {
	
	/* Basically, the android system will look for a "libwildAssembly.so" 
	   in the app's private and public folders. */
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

		TextView mContentView =
			(TextView) findViewById(R.id.fullscreen_content);
		/*new String(testMe())*/
		String string_displayed = new String(testMe());
		mContentView.setText(string_displayed);

	}
	
	/* Try it : 
	    - Redeclare testMe() as 'native int testMe()' and
	    - Change 'new String(testMe())'
	        with 'String.format(Locale.C, "%x", testMe())'
	*/
}

