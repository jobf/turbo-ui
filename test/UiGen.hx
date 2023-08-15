

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class UiGen
{
	macro static public function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		for (field in fields)
		{
			trace(field.name);
			// skip the constructor
			if (field.name == 'new')
				continue;

			switch (field.kind)
			{
				case FieldType.FFun(fn):
					// skip non-empty functions
					if (!isEmpty(fn.expr))
						continue;

					// empty function found, create a loop and set as function body
					var fname = field.name;
					var args = [for (arg in fn.args) macro $i{arg.name}];
					fn.expr = macro
						{
							for (listener in listeners)
								listener.$fname($a{args});
						}
				default:
			}
		}
		return fields;
	}

	static function isEmpty(expr:Expr)
	{
		if (expr == null)
			return true;
		return switch (expr.expr)
		{
			case ExprDef.EBlock(exprs): exprs.length == 0;
			default: false;
		}
	}
}
#end
