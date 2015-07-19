package synckha;

#if sys_ios
@:headerCode('
#include <SyncKore.h>
')
#end

class Sync {

	// TODO: use __cpp__
	#if sys_ios
	@:functionCode('SyncKore::init();')
	#end
	public static function init():Void {
	}

	#if sys_ios
	@:functionCode('SyncKore::toggleSync();')
	#end
	public static function toggleSync():Void {
	}

	#if sys_ios
	@:functionCode('return SyncKore::getStrData();')
	#end
	public static function getStrData():cpp.ConstCharStar {
		return "";
	}

	#if sys_ios
	@:functionCode('return SyncKore::getDataReceived();')
	#end
	public static function getDataReceived():Bool {
		return false;
	}
}
