import utest.Runner;
import utest.ui.Report;
import utest.Test;
import utest.Assert;

class RunTests
{
	public static function main()
	{
		var runner = new Runner();
		runner.addCase(new MacroTests());
		Report.create(runner);
		runner.run();
	}
}

class MacroTests extends Test
{
	function test_can_find_attribute() {
		var c:Config = {};
		// var fields = Reflect.fields(c);
		// trace('f ' + fields);
		var t = false;
		Assert.isTrue(t);
	}
}



@:structInit
class Config {
	public var numeric:Int= 0;
	public var ratio:Float = 1.0;
}

@:autoBuild(UiGen.build())
class AutoUi {
  var listeners:Array<Dynamic>;

  public function new() {
    listeners = [];
  }

  // addListener, removeListener,...
}