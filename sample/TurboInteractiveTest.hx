package sample;

import turbo.theme.Colors;
import haxe.CallStack;
import turbo.theme.Fonts;
import peote.text.Font;
import turbo.UI;
import peote.ui.PeoteUIDisplay;
import peote.view.PeoteView;
import peote.view.Display;
import lime.app.Application;

class TurboInteractiveTest extends Application{
	var peoteView:PeoteView;
	var uiDisplay:PeoteUIDisplay;
	var ui:UI;

	override function onWindowCreate():Void
	{
		#if html5
		// see https://github.com/openfl/lime/pull/1692
		@:privateAccess
		var html5Window:lime._internal.backend.html5.HTML5Window = window.__backend;
		@:privateAccess
		html5Window.resizeElement = true;
		#end
		
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
				{
					new Font<FontStyleRetro>("assets/fonts/tiled/PC-BIOS-437-8x14.json").load(start_sample);
				} catch (_)
				{
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public function start_sample(font:Font<FontStyleRetro>)
	{
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


		/**

		TODO ! use own sprite based font for labels


		**/

		// var item_rects:Map<String, Rectangle> = ["DEFAULT" => default_item_rect];
		var colors:Colors = Themes.RAY_CHERRY();
		// var font_model:FontModel = Fonts.PC_BIOS_8x14(font);

		ui = new UI(display_rect, item_rects, colors, font_model);

		peoteView.addDisplay(ui.display);
		PeoteUIDisplay.registerEvents(window);


		
	}

}
