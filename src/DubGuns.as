package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.events.Event;
	
	import org.si.sound.BassSequencer;
	import org.si.sound.patterns.Note;
    import org.si.sion.*;
    import org.si.sion.events.*;
    import org.si.sion.effector.*;
    import org.si.sion.utils.SiONPresetVoice;
	
	public class DubGuns extends Sprite 
	{
		[Embed(source = 'Data/Ship.png')]	private var shipClass:Class;
		private var ship:Bitmap;
		
		private var timer:Timer;
		
        // driver
        public var driver:SiONDriver = new SiONDriver();

        // preset voice
        public var presetVoice:SiONPresetVoice = new SiONPresetVoice();
        
        // MML data
        public var drumLoop:SiONData;
        
        // low pass filter effector
        public var lpf:SiCtrlFilterLowPass = new SiCtrlFilterLowPass();
		
		private var bseq:BassSequencer;
		
		public function DubGuns():void 
		{
			super();
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			//Mouse.hide();
			ship = new shipClass() as Bitmap;
			addChild (ship);
            // compile mml. 
            drumLoop = driver.compile("t150; %6@0o3l8$c2rc.c.; %6@1o3$rcrc; %6@2v8l16$[crccrrcc]; %6@3v8o3$[rc8r8];")
            
            // set voices of "%6@0-3" from preset
            var percusVoices:Array = presetVoice["valsound.percus"];
            drumLoop.setVoice(0, percusVoices[0]);  // bass drum
            drumLoop.setVoice(1, percusVoices[27]); // snare drum
            drumLoop.setVoice(2, percusVoices[16]); // close hihat
            drumLoop.setVoice(3, percusVoices[21]); // open hihat
            
            // set parameters of low pass filter
            lpf.control(0.1, 0.5);
			
			bseq = new BassSequencer();
			bseq.coarseTune = -24;
			bseq.effectors = [lpf];
            
            // connect low pass filter on slot0.
            //driver.effector.slot0 = [lpf];
            
            // play with an argument of resetEffector = false.
            driver.play(drumLoop, false);
			bseq.play();
			
			timer = new Timer(1000 / 30);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, update);
			addEventListener(Event.ENTER_FRAME, update);
			
		}
		private var speedAngle:Number = 0.1;
		private var range:Number = 50;
		private var angle:Number = 0;
		
		private var tick:Number = 0;
		private var gate:Number = 0;
		private var lfo:Number = 0;
		private function update(e:Event):void
		{
			if (mouseX > 0 && mouseX < stage.stageWidth &&
				mouseY > 0 && mouseY < stage.stageHeight)
				{
					ship.x = mouseX - ship.width / 2;
					ship.y = mouseY - ship.height / 2;
				}
				
			var beamStartX:Number = ship.x + ship.width;
			var beamStartY:Number = ship.y + ship.height / 2;
			
			graphics.clear();
			tick += 0.016;
			lfo = Math.sin(tick) * 45;
			var lfoR:Number = (lfo +1) / 2;
			gate = ((Math.sin(lfo) + 1) / 2) * 0.8 + 0.1;
			lpf.control(gate, lfoR * gate + (1 - lfoR) * gate);
			//lpf.control(ship.x / stage.stageWidth, ship.y / stage.stageHeight);
			
			graphics.lineStyle (3 * gate, 0x00ff00);
			graphics.moveTo (beamStartX, beamStartY);
			graphics.lineTo (stage.stageWidth, beamStartY);
			
			graphics.lineStyle (5 * gate, 0x40A050);
			graphics.moveTo (beamStartX, beamStartY);
			
			for (var xpos:Number = beamStartX; xpos < stage.stageWidth; xpos ++)
			{
				xpos += 2;
				var pease:Number = (xpos - beamStartX) / (beamStartX + 100);
				var easeIn:Number = Math.min(pease, 1);
				var ypos:Number = beamStartY + Math.sin(angle) * (range / 2) * gate *easeIn;
				angle += speedAngle;	
				graphics.lineStyle (10 * gate * easeIn, 0x40FF50);
				graphics.lineTo (xpos, ypos);
			}
			
			graphics.lineStyle (10 * gate, 0x80ffa0);
			graphics.moveTo (beamStartX, beamStartY);
			
			for (xpos = beamStartX; xpos < stage.stageWidth; xpos ++)
			{
				xpos += 3;
				var pease:Number = (xpos - beamStartX) / (beamStartX + 100);
				var easeIn:Number = Math.min(pease, 1);
				var ypos:Number = beamStartY + Math.sin(angle) * range * gate *easeIn;
				angle += speedAngle;	
				graphics.lineStyle (10 * gate * easeIn, 0x80ffa0);
				graphics.lineTo (xpos, ypos);
			}
			
		}
	}
	
}