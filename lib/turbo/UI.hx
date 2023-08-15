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
	var item_rects:Map<String, Rectangle>;
	var colors:Colors;
	var font_model:FontModel;
	var style_bg:BoxStyle;
	final default_rect_key = "DEFAULT";
	var glyphs:Glyphs;

	public function new(display_rect:Rectangle, item_rects:Map<String, Rectangle>, colors:Colors, font_model:FontModel)
	{
		if(!item_rects.exists(default_rect_key)){
			throw 'ERROR! item_rects must contain entry for $default_rect_key key';
		}

		this.glyphs = new Glyphs(font_model);
		this.display_rect = display_rect;
		this.item_rects = item_rects;

		this.colors = colors;

		this.font_model = font_model;

		style_bg = {
			color: colors.bg_idle,
		}

		display = new PeoteUIDisplay(display_rect.x, display_rect.y, display_rect.width, display_rect.height, colors.bg_display, [style_bg]);
		display.addProgram(glyphs.program);
	}

	public function make(model:InteractiveModel, x:Int, y:Int):BaseInteractive
	{
		var key = Type.enumConstructor(model.role);
		var rect = item_rects.exists(key) ? item_rects[key] : item_rects[default_rect_key];

		var geometry:Rectangle = {
			x: x,
			y: y,
			width: rect.width,
			height: rect.height
		}

		var label = glyphs.make_line(x + 2, y + 2, model.label, colors.fg_idle);

		var interactive:BaseInteractive = switch model.role
		{
			case TOGGLE(is_toggled): new Toggle(model, geometry, style_bg, label, colors);
			case SLIDER(percent): {
					var slider = new Slider(model, geometry, style_bg, label, colors);
					display.add(slider.slider_element);
					slider.percent = percent;
					slider;
				};
			case STEPPER(slots, index): {
					var stepper = new Stepper(model, geometry, style_bg, label, colors);
					display.add(stepper.slider_element);
					stepper.index = index;
					stepper;
				}
			case _: new BaseInteractive(model, geometry, style_bg, label, colors);
		}

		display.add(interactive.bg_element);
		// display.add(interactive.label);

		return interactive;
	}

	public function make_toggle_group(models:Array<InteractiveModel>, x:Int, y:Int):ToggleGroup
	{
		var x:Int = x;
		var y:Int = y;
		var elements:Array<Toggle> = [
			for(model in models){
				var element:Toggle = cast make(model, x, y);
				y += item_rects[default_rect_key].height + 2;
				element;
			}
		];

		return new ToggleGroup(elements);
	}
}

enum InteractiveRole
{
	BUTTON;
	LABEL;
	TOGGLE(is_toggled:Bool);
	SLIDER(percent:Float);
	STEPPER(slots:Array<Float>, index:Int);
	TEXTINPUT;
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

	public static function combine(a:Rectangle, b:Null<Rectangle>):Rectangle
	{
		return {
			x: a.x + b?.x ?? 0,
			y: a.y + b?.y ?? 0,
			width: a.width + b?.width ?? 0,
			height: a.height + b?.height ?? 0,
		}
	}
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
	public var geometry_offset:Null<Rectangle> = null;
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
