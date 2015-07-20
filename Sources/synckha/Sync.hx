package synckha;

#if (sys_ios || sys_osx)
@:headerCode('
#include <SyncKore.h>
')
#end

class Sync {

	// Receiving data
	// TODO: use __cpp__
	#if sys_ios
	@:functionCode('SyncKore::init();')
	public static function init():Void {
	}

	@:functionCode('SyncKore::toggleSync();')
	public static function toggleSync():Void {
	}

	@:functionCode('return SyncKore::getStrData();')
	public static function getStrData():cpp.ConstCharStar {
		return "";
	}

	@:functionCode('return SyncKore::getDataReceived();')
	public static function getDataReceived():Bool {
		return false;
	}
	#end

	// Sending data
	#if sys_osx
	@:functionCode('SyncKore::init();')
	public static function init():Void {
	}

	@:functionCode('SyncKore::discover();')
	public static function discover():Void {
	}

	@:functionCode('SyncKore::sync(str);')
	public static function sync(str:String):Void {
	}
	#end
}
