package turbo;

import peote.view.Texture;
import lime.utils.Assets;
import peote.view.Program;
import peote.view.Buffer;
import turbo.theme.Fonts.FontModel;
import peote.view.Color;
import peote.view.Element;

class Glyphs
{
	var font:FontModel;
	public var program:Program;
	var buffer:Buffer<Tile>;

	public function new(font:FontModel){
		this.font = font;
		buffer = new Buffer<Tile>(1024);
		program = new Program(buffer);
		var image = Assets.getImage(this.font.glyph_asset_path);
		var texture = new Texture(image.width, image.height);
		texture.tilesX = Std.int(image.width / font.glyph_width);
		texture.tilesY = Std.int(image.height / font.glyph_height);
		var cleaned = StringTools.replace(font.glyph_asset_path, "/", "_");
		trace(cleaned);
		cleaned = StringTools.replace(cleaned, "-", "_");
		cleaned = StringTools.replace(cleaned, ".", "_");
		trace(cleaned);
		texture.setImage(image, 0);
		program.addTexture(texture, cleaned);
	}

	public function make_line(x:Int, y:Int, text:String, tint:Color):GlyphLine{
		return [for(index in 0...text.length) 
			buffer_tile(x, y, index, text.charCodeAt(index), tint)
		];
	}

	function buffer_tile(x:Int, y:Int, index:Int, char_code:Int, tint:Color):Tile{
		var tile = new Tile(
			Std.int((index * font.glyph_width) + x),
			y,
			font.glyph_width,
			font.glyph_height,
			char_code,
			tint
		);

		buffer.addElement(tile);

		return tile;
	}
}

typedef GlyphLine = Array<Tile>;

class Tile  implements Element
{
	/**
		pixel position of the left edge
	**/
	@posX public var x:Int;

	/**
		pixel position of the top edge
	**/
	@posY public var y:Int;

	/**
		pixel width
	**/
	@varying @sizeX public var w:Int;

	/**
		pixel height
	**/
	@varying @sizeY public var h:Int;

	/**
		refers to the index of the tile within a large texture that has been partitioned
	**/
	@texTile() public var tile_index:Int;

	/**
		a color which tints the tile, for easy tinting the raw tile data to be tinted should be white
	**/
	@color public var tint:Color;

	public function new(x:Int, y:Int, width:Int, height:Int, tile_index:Int, tint:Color = 0xffffffff)
	{
		this.x = x;
		this.y = y;
		this.w = width;
		this.h = height;
		this.tile_index = tile_index;
		this.tint = tint;
	}
}