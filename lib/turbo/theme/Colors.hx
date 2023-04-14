package turbo.theme;

import peote.view.Color;

@:structInit
class Colors
{
	public var bg_display:Color = 0x101010ff;
	public var bg_toggle_off:Color;
	public var bg_toggle_on:Color;

	public var bg_idle:Color;
	public var fg_idle:Color;

	public var bg_hover:Color;
	public var fg_hover:Color;

	public var bg_pressed:Color;
	public var fg_pressed:Color;

	public var bg_disabled:Color;
	public var fg_disabled:Color;
}

class Themes
{
	public static function RAY_CHERRY():Colors
	{
		return {
			bg_toggle_on: 0x5b1e20ff,
			bg_toggle_off: 0x3a1720ff,
			bg_idle: 0x753233ff,
			fg_idle: 0xe17373ff,
			bg_hover: 0xe06262ff,
			fg_hover: 0xfdb4aaff,
			bg_pressed: 0x5b1e20ff,
			fg_pressed: 0xc2474fff,
			bg_disabled: 0x706060ff,
			fg_disabled: 0x9e8585ff
		}
	}
}
