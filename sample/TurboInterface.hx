import turbo.interactive.Elements.Toggle;
import turbo.interactive.Elements.BaseInteractive;
import turbo.UI.Rectangle;
import turbo.interactive.Elements;
import turbo.theme.Fonts;
import peote.text.Font;
import peote.ui.PeoteUIDisplay;
import peote.view.PeoteView;
import haxe.CallStack;
import lime.app.Application;
import turbo.UI;
import turbo.theme.Colors;

class TurboInterface extends Application
{
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

		var item_rects:Map<String, Rectangle> = ["DEFAULT" => default_item_rect];
		var colors:Colors = Themes.RAY_CHERRY();
		var font_model:FontModel = Fonts.PC_BIOS_8x14(font);

		ui = new UI(display_rect, item_rects, colors, font_model);

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

		add_element({
			label: "LABEL",
			role: LABEL,
		});

		add_element({
			label: "< LABEL",
			role: LABEL,
			label_text_align_override: LEFT
		});

		add_element({
			label: "LABEL >",
			role: LABEL,
			label_text_align_override: RIGHT
		});

		add_element({
			label: "BUTTON",
			role: BUTTON,
			interactions: {
				on_release: interactive -> trace('BUTTON release'),
				on_press: interactive -> trace('BUTTON press'),
			}
		});

		var is_toggled = true;
		add_element({
			label: "TOGGLE",
			role: TOGGLE(is_toggled),
			interactions: {
				on_change: interactive ->
				{
					var toggle:Toggle = cast interactive;
					trace('TOGGLE changed to ' + toggle.is_toggled);
				},
			}
		});

		var is_toggled = false;
		add_element({
			label: "TOGGLE YES",
			label_toggle_false: "TOGGLE NO",
			role: TOGGLE(is_toggled),
		});

		add_element({
			label: "SLIDE",
			role: SLIDER(0.5),
			interactions: {
				on_change: interactive ->
				{
					var slider:Slider = cast interactive;
					trace('SLIDER changed to ' + slider.percent);
				},
			}
		});

		add_element({
			label: "STEP",
			role: STEPPER([1, 2, 4, 8, 16], 2),
			interactions: {
				on_change: interactive ->
				{
					var stepper:Stepper = cast interactive;
					trace('STEPPER changed to ' + stepper.index);
				},
			},
			geometry_offset: {
				y: 10,
				width: 0,
				height: 0
			}
		});

		var x = 300;
		var y = 0;

		var on_toggle_item_change:BaseInteractive->Void = interactive ->
		{
			var toggle:Toggle = cast interactive;
			@:privateAccess
			var label = toggle.model.label;
			trace('$label : ${toggle.is_toggled}');
		}

		var group = ui.make_toggle_group([
			{
				label: "A",
				role: TOGGLE(true),
				interactions: {
					on_change: on_toggle_item_change
				}
			},
			{
				label: "B",
				role: TOGGLE(false),
				interactions: {
					on_change: on_toggle_item_change
				}
			},
			{
				label: "C",
				role: TOGGLE(false),
				interactions: {
					on_change: on_toggle_item_change
				}
			},
		], x, y);
		
		var auto = new AutoUi(ui);
		var c:Config = {}
		auto.build(c);
	}
}

class AutoUi{
	var ui:UI;
	public function new(ui:UI) {
		this.ui = ui;
	}

	public function build(obj:Dynamic){
		var fields = Reflect.fields(obj);
		for (s in fields) {
			var field = Reflect.field(obj, s);
			trace(field);
		}
	}
}


@:structInit
class Config {
	public var numeric:Int= 0;
	public var ratio:Float = 1.0;
}