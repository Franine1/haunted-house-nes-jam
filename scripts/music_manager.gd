extends AudioStreamPlayer


var player: AudioStreamInteractive
var music_refresher: Timer
var cue: GameCue

const sound_levels: Array[float] = [
	-15.0
	,-25.0
	,-35.0
	,-5.0
	,5.0
]

const silent_sound_level: float = -65.0

var db_goal: float = 0.0
var volume_setting: int = 0

func _ready() -> void:
	attach_stream()
	
	volume_db = sound_levels[0]
	
	music_refresher = Timer.new()
	add_child(music_refresher)
	music_refresher.one_shot = true
	music_refresher.timeout.connect(refresh_track)
	
	
	cue = GameCue.new()
	add_child(cue)
	
	cue.add_cue("music",change_track)
	cue.add_cue("volume",change_volume)

## changes the volume level
func change_volume(input: int) -> void:
	if input >= 0 and sound_levels.size() > input:
		volume_setting = input
		if volume_db <= -60.0:
			play()
		fadein()
	else:
		fadeout()


## gets the audio stream
func attach_stream() -> void:
	
	if stream is AudioStreamInteractive:
		player = stream

## changes to the correct audio track
func change_track(input: int, do_twice: bool = true) -> void:
	if !playing:
		play()
		get_tree().create_timer(0.05).timeout.connect(change_track.bind(input))
		return
	var pb: AudioStreamPlaybackInteractive = get_stream_playback()
	if !is_instance_valid(pb):
		get_tree().create_timer(0.05).timeout.connect(change_track.bind(input))
		return
	
	if player.clip_count > input and input >= 0:
		if input != pb.get_current_clip_index():
			pb.switch_to_clip(input)
		fadein()
	else:
		fadeout()
	
	pass
	
	if do_twice:
		music_refresher.start(1.0)


func refresh_track() -> void:
	change_track(GameCue.get_cue("music"),false)
	change_volume(GameCue.get_cue("volume"))

## fades out the audio
func fadeout() -> void:
	db_goal = silent_sound_level

## fades in the audio
func fadein() -> void:
	db_goal = sound_levels[volume_setting]

## manages audio fading
func _process(delta: float) -> void:
	if volume_db <= silent_sound_level:
		stop()
	elif !playing:
		play()
	
	if volume_db == db_goal:
		return
	
	var diff = db_goal - volume_db
	var lapse = (diff / abs(diff)) * delta * 10.0
	
	if abs(lapse) >= abs(diff):
		volume_db = db_goal
	else:
		volume_db += lapse
