package turbo;

import peote.ui.style.BoxStyle;
import peote.ui.PeoteUIDisplay;
import turbo.theme.Fonts;
import turbo.theme.Colors;
import turbo.interactive.Elements;

class UI
{
	public var display(default, null):PeoteUIDisplay;

	var display_rect:Rectangle;
	var item_rect:Rectangle;
	var colors:Colors;
	var font_model:FontModel;
	var style_bg:BoxStyle;

	public function new(display_rect:Rectangle, item_rect:Rectangle, colors:Colors, font_model:FontModel)
	{
		this.display_rect = display_rect;
		this.item_rect = item_rect;

		this.colors = colors;

		font_model.style.color = colors.fg_idle;
		this.font_model = font_model;

		style_bg = {
			color: colors.bg_idle
		}

		display = new PeoteUIDisplay(display_rect.x, display_rect.y, display_rect.width, display_rect.height, colors.bg_display, [style_bg, font_model.style]);
	}

	public function make(model:InteractiveModel, x:Int, y:Int)
	{
		var geometry:Rectangle = {
			x: x,
			y: y,
			width: item_rect.width,
			height: item_rect.height
		}

		var interactive:BaseInteractive = switch model.role
		{
			case TOGGLE(is_toggled): new Toggle(model, geometry, style_bg, font_model, colors);
			// case SLIDER(fraction):
			case _: new BaseInteractive(model, geometry, style_bg, font_model, colors);
		}

		display.add(interactive.element_bg);
		display.add(interactive.label);
	}
}

enum InteractiveRole
{
	BUTTON;
	LABEL;
	TOGGLE(is_toggled:Bool);
	SLIDER(fraction:Float);
}

enum Align
{
	CENTER;
	LEFT;
	RIGHT;
}

@:structInit
class Rectangle
{
	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int;
	public var height:Int;
}

@:structInit
class InteractiveModel
{
	public var label:String;
	public var label_toggle_false:Null<String> = null;
	public var role:InteractiveRole;
	public var interactions:Interactions = {};
	public var label_text_align_override:Null<Align> = null;
	public var label_change:Null<Void->String> = null;
	public var conditions:Null<() -> Bool> = null;
	public var sort_order:Int = 0;
}

@:structInit
class Interactions
{
	public var on_press:BaseInteractive->Void = (interactive:BaseInteractive) -> return;
	public var on_release:BaseInteractive->Void = (interactive:BaseInteractive) -> return;
	public var on_over:BaseInteractive->Void = (interactive:BaseInteractive) -> return;
	public var on_out:BaseInteractive->Void = (interactive:BaseInteractive) -> return;
	public var on_change:BaseInteractive->Void = (interactive:BaseInteractive) -> return;
}
