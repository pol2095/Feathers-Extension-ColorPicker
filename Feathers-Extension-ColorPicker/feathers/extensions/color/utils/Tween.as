package feathers.extensions.color.utils
{
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class Tween extends EventDispatcher
	{
		private var tween:starling.animation.Tween;
		private var target:Object;
		private var time:Number;
		private var begin:Number;
		private var transition:Object;
		private var end:Number;
		private var rewind:Boolean;
		private var isTweenStartAtStart:Boolean = true;
		public var isTweenEndAtEnd:Boolean;
		
		public function Tween(target:Object, time:Number, transition:Object = "linear")
		{
			this.target = target;
			this.time = time;
			this.transition = transition;
			begin = target.alpha;
		}
		
		public function get isPlaying():Boolean
		{
			return Starling.juggler.containsTweens(target);
		}
		
		public function fadeTo(alpha:Number):void
		{
			end = alpha;
		}
		
		public function start():Object
		{
			var begin:Number = rewind ? this.end : this.begin;
			var end:Number = rewind ? this.begin : this.end;
			var transition:Object = rewind ? Transitions.EASE_IN : this.transition;
			var isPlaying:Boolean = this.isPlaying;
			if( ! isPlaying )
			{
				isTweenStartAtStart = target.alpha == this.end ? false : true;
				tween = new starling.animation.Tween(target, time, transition);
				tween.fadeTo(end);
				tween.onComplete = complete;
				Starling.juggler.add(tween);
			}
			else
			{
				var currentTime:Number = time - tween.currentTime;
				Starling.juggler.remove(tween);
				tween = new starling.animation.Tween(target, time, transition);
				target.alpha = begin;
				tween.fadeTo(end);
				tween.onComplete = complete;
				tween.advanceTime(currentTime);
				Starling.juggler.add(tween);
			}
			rewind = ! rewind;
			return { isPlaying:isPlaying, isTweenStartAtStart:isTweenStartAtStart };
		}
		
		private function complete():void
		{
			isTweenEndAtEnd = target.alpha == this.end ? true : false;
			dispatchEvent( new Event( Event.COMPLETE, false, { isTweenStartAtStart:isTweenStartAtStart, isTweenEndAtEnd:isTweenEndAtEnd } ) );
        }
	}
}