extends Node
class_name TickMan

########## vars & funcs users should interface with ############
var tick_stamp: TickStamp:
	get = _get_tickstamp
var engine_tick: int: 
	get = _get_engine_tick
var game_tick: int: 
	get = _get_game_tick
var observer_tick: int:
	get = _get_observer_tick
func reset_to(game_tick: int):
	start_fastforward()
	self.reset_stamp = reset_db_generate(game_tick)
	reset_db_insert(reset_stamp)
################################################################

####### TickMan DataClasses ########
class TickStamp:
	var engine_tick: int  
	var game_tick: int
	var observer_tick: int 
	func _init(engine_tick, game_tick, observer_tick):
		self.engine_tick = engine_tick 
		self.game_tick = game_tick
		self.observer_tick = observer_tick
	func _to_string():
		return "engine: {engine} | game: {game} | observer: {observer}".\
			format({"engine":self.engine_tick, "game":self.game_tick, "observer":self.observer_tick})
class ResetStamp:
	var offset: int
	var prior_offset: int
	var started_fastforward_tick: int
	func _init(offset:int, prior_offset: int, started_fastforward_tick: int):
		self.started_fastforward_tick = started_fastforward_tick
		self.prior_offset = prior_offset
		self.offset = offset
	func _to_string():
		return "offset: {offset} | prior_offset: {prior_offset} | fastforward_start: {ff_start}".\
			format(
				{"offset":self.offset, 
				"prior_offset": self.prior_offset, 
				"ff_start": self.started_fastforward_tick}
				)
####################################

########## Reset db ################
var reset_stamp: ResetStamp
var reset_db: Array[ResetStamp] = []
func reset_db_init() -> void:
	reset_stamp = ResetStamp.new(self.engine_tick,0,0)
func reset_db_generate(game_tick: int) -> ResetStamp:
	var offset : int = self.engine_tick - game_tick + 1
	var prior_offset : int = (
			reset_stamp.prior_offset if should_currently_be_fastforwarding()
			else reset_stamp.offset
		)
	var ff_start_engine_tick = (
			reset_stamp.started_fastforward_tick if should_currently_be_fastforwarding()
			else self.engine_tick
		)
	return ResetStamp.new(offset, prior_offset, ff_start_engine_tick)
func reset_db_insert(reset_stamp: ResetStamp) -> void:
	reset_db.append(reset_stamp)
####################################

####### Fast Forward logic #########
var fastforward_state: bool = false
func should_currently_be_fastforwarding() -> bool:
	return self.game_tick <= self.observer_tick
func start_fastforward() -> void:
	Engine.time_scale = 2.0
	Engine.physics_ticks_per_second = 120
	fastforward_state = true
func end_fastforward() -> void:
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 60
	fastforward_state = false
####################################

####### Property Functions #########
func _get_observer_tick() -> int:
	if fastforward_state:
		var game_tick_when_fastforward_started = reset_stamp.started_fastforward_tick -  reset_stamp.prior_offset
		var half_steps_since_fastforward_started = (self.engine_tick - reset_stamp.started_fastforward_tick + 1)/2 
		var observer_base_tick = game_tick_when_fastforward_started + half_steps_since_fastforward_started
		return observer_base_tick
	else:
		return self.game_tick
func _get_game_tick() -> int:
	return self.engine_tick - reset_stamp.offset
func _get_engine_tick() -> int:
		return Engine.get_physics_frames()
func _get_tickstamp() -> TickStamp:
	return TickStamp.new(self.engine_tick, self.game_tick, self.observer_tick)
####################################

func _init():
	reset_db_init()
func _physics_process(delta):
	if fastforward_state and not should_currently_be_fastforwarding():
		end_fastforward()
