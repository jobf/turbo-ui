import sys.thread.Thread;
import turbo.theme.Colors;
import haxe.CallStack;
import turbo.theme.Fonts;
import peote.text.Font;
import turbo.UI;
import peote.ui.PeoteUIDisplay;
import peote.view.PeoteView;
import peote.view.Display;
import lime.app.Application;

class TurboThreadTest extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:PeoteUIDisplay;
	var ui:UI;
	var ticker:Ticker;


	// override function onWindowCreate():Void
	// {
	// 	#if html5
	// 	// see https://github.com/openfl/lime/pull/1692
	// 	@:privateAccess
	// 	var html5Window:lime._internal.backend.html5.HTML5Window = window.__backend;
	// 	@:privateAccess
	// 	html5Window.resizeElement = true;
	// 	#end

		
	// }

	override function onPreloadComplete() {
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
				{
					start_sample();
				} catch (_)
				{
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}


	public function start_sample()
	{
		var font:FontModel = {
			glyph_width: 8,
			glyph_height: 14, 
			glyph_asset_path: "assets/fonts/tiled/PC-BIOS-437-8x14.png",
			// glyph_asset_path: "assets/PC-BIOS-437-8x14.png",
		}

		peoteView = new PeoteView(window);

		var display_rect:Rectangle = {
			x: 20,
			y: 20,
			width: window.width - 40,
			height: window.height - 40
		}

		var default_item_rect:Rectangle = {
			x: 0,
			y: 0,
			width: 200,
			height: 50
		}

		var item_rects:Map<String, Rectangle> = ["DEFAULT" => default_item_rect];
		var colors:Colors = Themes.RAY_CHERRY();

		ui = new UI(display_rect, item_rects, colors, font);

		peoteView.addDisplay(ui.display);
		PeoteUIDisplay.registerEvents(window);

		var x = 0;
		var y = 0;
		var space = default_item_rect.height + 2;
		var add_element = (model:InteractiveModel) ->
		{
			ui.make(model, x, y);
			y += space;
		};


		ticker = new Ticker();
		
		add_element({
			label: "START",
			role: BUTTON,
			interactions: {
				on_release: interactive -> trace('BUTTON release'),
				on_press: interactive -> ticker.start(),
			}
		});


		add_element({
			label: "STOP",
			role: BUTTON,
			interactions: {
				on_release: interactive -> trace('BUTTON release'),
				on_press: interactive -> ticker.stop(),
			}
		});
	}
}

enum EventLoopMessage
{
	Tick;
	Tock;
	ProcResult(text:String);
}

class Ticker
{
	var mainThread:Thread;
	var tick:Float;

	public function new()
	{
		mainThread = Thread.current();

		var bpm = 128;
		var ppqn = 480;
		tick = 60.0 / bpm / ppqn;
		trace('$ppqn ppqn @ $bpm bpm = $tick seconds');
	}

	var is_ticking:Bool = false;

	public function start()
	{
		trace("start ticking");
		is_ticking = true;
		Thread.create(() ->
		{
			while (is_ticking)
			{
				mainThread.sendMessage(Tick);
				trace("tick");
				Sys.sleep(tick);
			}
		});
	}

	public function stop()
	{
		trace("stop ticking");
		is_ticking = false;
	}
}
