extends Node
# Tipo de pieza actual (I, O, T, J, L, S o Z)
var current_tetromino
var next_tetromino
# Referencia al nodo Board
@onready var board = $"../Board" as Board
@onready var ui = $"../UI" as UI
# Referencia a la música de fondo
@onready var music = $"../Music" as AudioStreamPlayer
var is_game_over = false


func _ready():
	# elige un tipo de pieza al azar del enum
	current_tetromino = Shared.Tetromino.values().pick_random()
	next_tetromino = Shared.Tetromino.values().pick_random()
	# pide al tablero crear esa pieza 
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(next_tetromino, true, Vector2(75, 60))
	board.tetromino_locked.connect(on_tetromino_locked)
	board.game_over.connect(on_game_over)


func on_tetromino_locked():
	if is_game_over:
		return
	# la vista previa pasa a ser la pieza actual
	current_tetromino = next_tetromino
	next_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(next_tetromino, true, Vector2(75, 60))


# Se ejecuta al perder: marca el fin, detiene la música y muestra el panel
func on_game_over():
	is_game_over = true
	music.stop()
	ui.show_game_over()
