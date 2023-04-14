package turbo.interactive;

import turbo.UI;
import turbo.theme.Colors;
import turbo.theme.Fonts;
import peote.view.Color;
import peote.ui.style.interfaces.*;
import peote.ui.style.*;
import peote.ui.interactive.*;
import peote.ui.event.*;
import peote.ui.util.*;

@:allow(turbo.UI)
class BaseInteractive
{
	var model:InteractiveModel;
	var colors:Colors;
	var bg_element:UIElement;
	var bg_style:BoxStyle;
	var bg_label_style:BoxStyle;

	var geometry:Rectangle;
	var label:UITextLine<FontStyleTiled>;

	public function new(model:InteractiveModel, geometry:Rectangle, style_bg:BoxStyle, font_model:FontModel, colors:Colors)
	{
		this.model = model;
		this.colors = colors;
		this.geometry = geometry;

		var z_index_bg = -1000;
		bg_style = style_bg.copy();

		bg_element = new UIElement(geometry.x, geometry.y, geometry.width, geometry.height, z_index_bg, bg_style);

		var z_index_label = -10;
		bg_label_style = bg_style.copy();

		label = new UITextLine<FontStyleTiled>(geometry.x + 2, geometry.y + 2, {
			width: geometry.width - 4,
			height: geometry.height - 4,
			hAlign: determine_h_align(),
			vAlign: determine_v_align(),
		}, z_index_label, model.label, font_model.font, font_model.style.copy(),
			bg_label_style);

		if (model.role == BUTTON || model.role.getName() == 'TOGGLE')
		{
			bg_element.onPointerOver = on_pointer_over;
			bg_element.onPointerOut = on_pointer_out;
			bg_element.onPointerDown = on_pointer_down;
			bg_element.onPointerUp = on_pointer_up;
		}
	}

	function determine_h_align():HAlign
	{
		var default_align:HAlign = switch model.role
		{
			case SLIDER(percent): HAlign.LEFT;
			case STEPPER(slots, index): HAlign.LEFT;
			case _: HAlign.CENTER;
		}

		return switch model.label_text_align_override
		{
			case LEFT: HAlign.LEFT;
			case RIGHT: HAlign.RIGHT;
			case _: default_align;
		}
	}

	function determine_v_align():VAlign
	{
		return switch model.role
		{
			case SLIDER(percent): VAlign.TOP;
			case STEPPER(slots, index): HAlign.LEFT;
			case _: VAlign.CENTER;
		}
	}

	function color_change(bg:Color, fg:Color)
	{
		bg_element.style.color = bg;
		bg_element.updateStyle();
		label.fontStyle.color = fg;
		label.updateStyle();
	}

	function on_pointer_over(element:Interactive, e:PointerEvent):Void
	{
		color_change(colors.bg_hover, colors.fg_hover);
		model.interactions.on_over(this);
	}

	function on_pointer_out(element:Interactive, e:PointerEvent):Void
	{
		color_change(colors.bg_idle, colors.fg_idle);
		model.interactions.on_out(this);
	}

	function on_pointer_down(element:Interactive, e:PointerEvent):Void
	{
		color_change(colors.bg_pressed, colors.fg_pressed);
		model.interactions.on_press(this);
	}

	function on_pointer_up(element:Interactive, e:PointerEvent):Void
	{
		color_change(colors.bg_hover, colors.fg_hover);
		model.interactions.on_release(this);
	}

	function on_change()
	{
		model.interactions.on_change(this);
	}
}

class Toggle extends BaseInteractive
{
	public var is_toggled(default, set):Bool;

	public function new(model:InteractiveModel, geometry:Rectangle, style_bg:BoxStyle, font:FontModel, colors:Colors)
	{
		super(model, geometry, style_bg, font, colors);

		is_toggled = Type.enumParameters(model.role)[0] == true;

		color_change(colors.bg_idle, colors.fg_idle);
	}

	function set_is_toggled(value:Bool):Bool
	{
		is_toggled = value;

		if (model.label_toggle_false != null)
		{
			if (is_toggled)
			{
				label.text = model.label;
			}
			else
			{
				label.text = model.label_toggle_false;
			}
			label.updateLayout();
		}
		on_change();

		return is_toggled;
	}

	override function on_pointer_down(element:Interactive, e:PointerEvent):Void
	{
		super.on_pointer_down(element, e);
		is_toggled = !is_toggled;
	}

	override function color_change(bg:Color, fg:Color)
	{
		label.backgroundStyle.color = is_toggled ? colors.bg_toggle_on : colors.bg_toggle_off;
		fg = is_toggled ? colors.fg_idle : colors.bg_idle;
		super.color_change(bg, fg);
	}
}

abstract class BaseSlider extends BaseInteractive
{
	public var slider_element(default, null):UISlider;

	public function new(model:InteractiveModel, geometry:Rectangle, style_bg:BoxStyle, font:FontModel, colors:Colors)
	{
		super(model, geometry, style_bg, font, colors);

		var slider_style:SliderStyle = {
			backgroundStyle: style_bg.copy(colors.bg_toggle_off),
			draggerStyle: style_bg.copy(colors.fg_idle),
			draggerSize: 16,
			draggSpace: 2,
			backgroundSpace: {
				left: 2,
				right: 2,
			},
		};

		var z_index_slider = 100;
		var slider_height = 16;
		var slider_y = Std.int(geometry.y + ((geometry.height / 2) - (slider_height / 2)));

		slider_element = new UISlider(geometry.x, slider_y, geometry.width, slider_height, z_index_slider, slider_style);

		slider_element.onChange = on_slider_change;
		slider_element.onDraggerPointerOver = on_dragger_over;
		slider_element.onDraggerPointerOut = on_dragger_out;
		slider_element.onPointerOver = on_slider_over;
		slider_element.onPointerOut = on_slider_out;
		slider_element.onPointerUp = on_slider_down;
	}

	function on_dragger_over(element:UISlider, e:PointerEvent):Void
	{
		element.draggerStyle.color = colors.fg_hover;
		element.updateStyle();
	}

	function on_dragger_out(element:UISlider, e:PointerEvent):Void
	{
		element.draggerStyle.color = colors.fg_idle;
		element.updateStyle();
	}

	abstract function on_slider_change(element:UISlider, value:Float, percent:Float):Void;

	function on_slider_over(element:UISlider, e:PointerEvent):Void
	{
		element.backgroundStyle.color = colors.bg_toggle_on;
		element.updateStyle();
	}

	function on_slider_out(element:UISlider, e:PointerEvent):Void
	{
		element.backgroundStyle.color = colors.bg_toggle_off;
		element.updateStyle();
	}

	abstract function on_slider_down(element:UISlider, e:PointerEvent):Void;
}

class Slider extends BaseSlider
{
	public var percent(default, set):Float;

	function set_percent(value:Float):Float
	{
		percent = value;
		slider_element.setPercent(percent, false, false);
		on_change();
		return percent;
	}

	function on_slider_down(element:UISlider, e:PointerEvent):Void
	{
		// todo - fix drag position glitch

		/*
		var position = element.localX(e.x);
		var total = element.width - element.backgroundSpace.left - element.backgroundSpace.right;
		trace('position $position / total $total');
		percent = position / total;
		*/
	}

	function on_slider_change(element:UISlider, value:Float, percent:Float):Void
	{
		this.percent = percent;
	}
}

// todo - CustomSlider implementation for better 'stepping'
class Stepper extends BaseSlider
{
	public var index(default, set):Int;

	var slots:Array<Float>;
	var total_positions:Int;
	var slot_size:Float;

	public function new(model:InteractiveModel, geometry:Rectangle, style_bg:BoxStyle, font:FontModel, colors:Colors)
	{
		super(model, geometry, style_bg, font, colors);
		var parameters = Type.enumParameters(model.role);
		slots = parameters[0];
		index = parameters[1];
		total_positions = slots.length - 1;
		slot_size = 1 / total_positions;
	}

	function set_index(value:Int):Int
	{
		index = value;
		var percent = slot_size * index;
		slider_element.setPercent(percent, false, false);
		on_change();
		return index;
	}

	function on_slider_change(element:UISlider, value:Float, percent:Float):Void
	{
		index = Std.int(slots.length * percent);
	}

	function on_slider_down(element:UISlider, e:PointerEvent):Void
	{
		var position = element.localX(e.x);
		var total = element.width; // - element.backgroundSpace.left - element.backgroundSpace.right;
		var percent = position / total;
		index = Std.int(slots.length * percent);
		trace('position $position / total $total');
	}
}
