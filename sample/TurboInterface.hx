import turbo.interactive.Elements;
import turbo.theme.Fonts;
import peote.ui.style.FontStyleTiled;
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
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
				{
					new Font<FontStyleTiled>("assets/fonts/tiled/PC-BIOS-437-8x8.json").load(start_sample);
				} catch (_)
				{
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public function start_sample(font:Font<FontStyleTiled>)
	{
		peoteView = new PeoteView(window);

		var display_rect:Rectangle = {
			x: 20,
			y: 20,
			width: window.width - 40,
			height: window.height - 40
		}

		var item_rect:Rectangle = {
			x: 0,
			y: 0,
			width: 100,
			height: 20
		}

		var colors:Colors = Themes.RAY_CHERRY();
		var font_model:FontModel = Fonts.PC_BIOS_8x8(font);

		ui = new UI(display_rect, item_rect, colors, font_model);

		peoteView.addDisplay(ui.display);
		PeoteUIDisplay.registerEvents(window);

		var x = 0;
		var y = 0;
		var space = 22;

		var add_element = (model:InteractiveModel) ->
		{
			ui.make(model, x, y);
			y += space;
		};

		/*

			{
				label: label,
				role: role,
				label_text_align_override: label_text_align_override,
				interactions: interactions,
				label_change: label_change,
				conditions: conditions,
				sort_order: sort_order
			}

		 */

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
	}
}
