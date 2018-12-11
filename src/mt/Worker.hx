package mt;

class WorkerTask {

	@:allow(mt.Worker)
	var cancelled : Bool;

	@:allow(mt.Worker)
	var run : Void -> Void;

	public var onComplete : Null<Void -> Void>;

	public function new( run : Void -> Void ){
		this.run = run;
		this.cancelled = false;
	}

	public function cancel(){
		this.cancelled = true;
	}

}

class Worker {

	#if cpp
	var thread : cpp.vm.Thread;
	var todo : cpp.vm.Deque<WorkerTask>;
	var done : cpp.vm.Deque<WorkerTask>;
	#else
	var todo : Array<WorkerTask>;
	#end
	public var numTasks(default, null):Int;
	
	public function new(){
		#if cpp
		todo = new cpp.vm.Deque();
		done = new cpp.vm.Deque();
		thread = cpp.vm.Thread.create( mainLoop );
		#else
		todo = new Array();
		#end
		numTasks = 0;
	}
	
	#if !cpp
	public inline function isEmpty() 			return todo.length == 0;
	#end
	
	public function enqueue( task : WorkerTask ) : WorkerTask {
		#if cpp
		todo.add( task );
		#else
		todo.push( task );
		#end
		numTasks ++;
		return task;
	}

	public function stop(){
		#if cpp
		todo.push( null );
		#end
	}

	public function checkDone(){
		while( true ){
			#if cpp
			var task = done.pop( false );
			if( task == null )
				break;
			numTasks --;
			if( !task.cancelled && task.onComplete != null )
				task.onComplete();
			#else
			var task = todo.shift();
			if( task != null && !task.cancelled ){
				task.run();
				numTasks --;
				if( task.onComplete != null )
					task.onComplete();
			}
			break;
			#end
		}
	}

	#if cpp
	function mainLoop(){
		while( true ){
			var task = todo.pop( true );
			if( task == null )
				return;
			if( task.cancelled )
				continue;
			task.run();
			done.add( task );
		}
	}
	#end
}
