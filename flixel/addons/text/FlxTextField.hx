package flixel.addons.text;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;

/**
 * Extends FlxText for better support rendering text on cpp target.
 * Doesn't have multicamera support.
 * Displays over all other objects.
 */
class FlxTextField extends FlxText
{
	private var _camera:FlxCamera;
	
	/**
	 * Creates a new FlxText object at the specified position.
	 * @param	X				The X position of the text.
	 * @param	Y				The Y position of the text.
	 * @param	Width			The width of the text object (height is determined automatically).
	 * @param	Text			The actual text you would like to display initially.
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 * @param	Camera			Camera to display. FlxG.camera is used by default (if you pass null)
	 */
	public function new(X:Float, Y:Float, Width:Int, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true, ?Camera:FlxCamera)
	{
		super(X, Y, Width, Text, Size, EmbeddedFont);
		
		height = (Text == null || Text.length <= 0) ? 1 : textField.textHeight + 4;
		
		textField.multiline = false;
		textField.wordWrap = false;
		textField.mouseEnabled = false;
		updateDefaultFormat();
		
		if (Camera == null)
			Camera = FlxG.camera;
		
		camera = Camera;
		dirty = false;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		camera = null;
		super.destroy();
	}
	
	override public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void 
	{
		// This class doesn't support this operation
	}
	
	override public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
	{
		// This class doesn't support this operation
		return false;
	}
	
	override public function isSimpleRender(?camera:FlxCamera):Bool
	{
		// This class doesn't support this operation
		return true;
	}
	
	override private function get_pixels():BitmapData
	{
		calcFrame(true);
		return graphic.bitmap;
	}
	
	override private function set_pixels(Pixels:BitmapData):BitmapData
	{
		// This class doesn't support this operation
		return Pixels;
	}
	
	override private function set_alpha(value:Float):Float
	{
		alpha = FlxMath.bound(value, 0, 1);
		textField.alpha = alpha;
		return value;
	}
	
	override private function set_height(value:Float):Float
	{
		value = super.set_height(value);
		
		if (textField != null)
			textField.height = value;
		
		return value;
	}
	
	override private function set_visible(value:Bool):Bool
	{
		textField.visible = value;
		return super.set_visible(value);
	}
	
	override public function kill():Void 
	{
		visible = false;
		super.kill();
	}
	
	override public function revive():Void 
	{
		visible = true;
		super.revive();
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	@:access(flixel.FlxCamera)
	override public function draw():Void
	{
		textField.visible = (camera != null && camera.visible && camera.exists && isOnScreen(camera));
		
		if (!textField.visible)
			return;
		
		textField.x = x - offset.x;
		textField.y = y - offset.y;
		
		textField.scaleX = scale.x;
		textField.scaleY = scale.y;
		
		camera.transformObject(textField);
		
		#if FLX_DEBUG
		FlxBasic.visibleCount++;
		#end
	}
	
	override private function get_camera():FlxCamera 
	{
		return _camera;
	}
	
	override private function set_camera(value:FlxCamera):FlxCamera 
	{
		if (textField != null && textField.parent != null)
			textField.parent.removeChild(textField);
		
		if (value != null)
			value.view.display.addChild(textField);
		
		return _camera = value;
	}
}