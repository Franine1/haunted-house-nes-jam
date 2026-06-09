extends AudioStreamPlayer


var player: AudioStreamInteractive
var cue: GameCue

const sound_levels: Array[float] = [
	-15.0
	,-25.0
	,-35.0
	,-5.0
	,5.0
]

const silent_sound_level: float = -80.0

var db_goal: float = 0.0
var volume_setting: int = 0

func _ready() -> void:
	attach_stream()
	
	volume_db = sound_levels[0]
	
	cue = GameCue.new()
	add_child(cue)
	
	cue.add_cue("music",change_track)
	cue.add_cue("volume",change_volume)

## changes the volume level
func change_volume(input: int) -> void:
	if input >= 0 and sound_levels.size() > input:
		volume_setting = input
		fadein()
	else:
		fadeout()


## gets the audio stream
func attach_stream() -> void:
	
	if stream is AudioStreamInteractive:
		player = stream

## changes to the correct audio track
func change_track(input: int) -> void:
	if !playing:
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

## fades out the audio
func fadeout() -> void:
	db_goal = silent_sound_level

## fades in the audio
func fadein() -> void:
	db_goal = sound_levels[volume_setting]

## manages audio fading
func _process(delta: float) -> void:
	if !playing:
		play()
	
	if volume_db == db_goal:
		return
	
	var diff = db_goal - volume_db
	var lapse = (diff / abs(diff)) * delta * 10.0
	
	if abs(lapse) >= abs(diff):
		volume_db = db_goal
	else:
		volume_db += lapse
