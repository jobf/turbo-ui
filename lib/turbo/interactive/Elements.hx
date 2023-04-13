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
	var element_bg:UIElement;
	var geometry:Rectangle;
	var label:UITextLine<FontStyleTiled>;
	var is_pointer_hover:Bool;

	public function new(model:InteractiveModel, geometry:Rectangle, style_bg:Style, font:FontModel, colors:Colors)
	{
		this.model = model;
		this.colors = colors;
		this.geometry = geometry;
		is_pointer_hover = false;
		var z_index_bg = -100;
		var z_index_label = -10;

		element_bg = new UIElement(geometry.x, geometry.y, geometry.width, geometry.height, -z_index_bg, style_bg);

		label = new UITextLine<FontStyleTiled>(geometry.x, geometry.y, {
			width: geometry.width,
			height: geometry.height,
			hAlign: determine_h_align(),
			vAlign: determine_v_align(),
		}, z_index_label, model.label, font.font, font.style);

		if (model.role != LABEL)
		{
			element_bg.onPointerOver = on_pointer_over;
			element_bg.onPointerOut = on_pointer_out;
			element_bg.onPointerDown = on_pointer_down;
			element_bg.onPointerUp = on_pointer_up;
		}
	}

	function determine_h_align():HAlign
	{
		return switch model.label_text_align_override
		{
			case LEFT: HAlign.LEFT;
			case RIGHT: HAlign.RIGHT;
			case _: HAlign.CENTER;
		}
	}

	function determine_v_align():VAlign
	{
		return switch model.role
		{
			case SLIDER(fraction): VAlign.TOP;
			case _: VAlign.CENTER;
		}
	}

	function color_change(bg:Color, fg:Color)
	{
		element_bg.style.color = bg;
		element_bg.updateStyle();
		label.fontStyle.color = fg;
		label.updateStyle();
	}

	function on_pointer_over(element:UIElement, e:PointerEvent):Void
	{
		color_change(colors.bg_hover, colors.fg_hover);
		model.interactions.on_over(this);
	}

	function on_pointer_out(element:UIElement, e:PointerEvent):Void
	{
		color_change(colors.bg_idle, colors.fg_idle);
		model.interactions.on_out(this);
	}

	function on_pointer_down(element:UIElement, e:PointerEvent):Void
	{
		color_change(colors.bg_pressed, colors.fg_pressed);
		model.interactions.on_press(this);
	}

	function on_pointer_up(element:UIElement, e:PointerEvent):Void
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

	public function new(model:InteractiveModel, geometry:Rectangle, style_bg:Style, font:FontModel, colors:Colors)
	{
		super(model, geometry, style_bg, font, colors);

		is_toggled = switch model.role
		{
			case TOGGLE(enabled): enabled;
			case _: false; // should never be this
		};

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

	override function on_pointer_down(element:UIElement, e:PointerEvent):Void
	{
		is_toggled = !is_toggled;
		super.on_pointer_down(element, e);
	}

	override function color_change(bg:Color, fg:Color)
	{
		if (is_toggled)
		{
			super.color_change(bg, fg);
		}
		else
		{
			super.color_change(colors.bg_toggle_off, fg);
		}
	}
}
