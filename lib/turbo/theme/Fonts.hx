package turbo.theme;

import peote.view.Color;
import peote.text.Font;
import peote.ui.style.interfaces.FontStyle;

@:structInit
class FontStyleRetro implements FontStyle
{
	public var color:Color = Color.WHITE;
	public var bgColor:Color = 0x00000000;
	public var width:Float = 8.0;
	public var height:Float = 8.0;
	public var tilt:Float = 0.0;
	public var letterSpace:Float = 0.0;
}

@:structInit
class FontModel
{
	public var font:Font<FontStyleRetro>;
	public var style:FontStyleRetro = {};
}

class Fonts
{
	public static function PC_BIOS_8x8(font:Font<FontStyleRetro>):FontModel
	{
		return {
			font: font
		}
	}

	public static function PC_BIOS_8x14(font:Font<FontStyleRetro>):FontModel
	{
		return {
			style: {
				height: 14,
			},
			font: font
		}
	}
}
