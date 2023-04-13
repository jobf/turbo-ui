package turbo.theme;

import peote.ui.style.FontStyleTiled;
import peote.text.Font;

@:structInit
class FontModel
{
	public var font:Font<FontStyleTiled>;
	public var style:FontStyleTiled;
}

class Fonts
{
	public static function PC_BIOS_8x8(font:Font<FontStyleTiled>):FontModel
	{
		var style = font.createFontStyle();

		// todo - why is height and width not loaded from JSON ?
		style.width = 8;
		style.height = 8;

		return {
			style: style,
			font: font
		}
	}
}
