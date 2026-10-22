extends Node
# Tipo de pieza actual (I, O, T, J, L, S o Z)
var current_tetromino
var next_tetromino
# Referencia al nodo Board
@onready var board = $"../Board" as Board
@onready var ui = $"../UI"
var is_game_over = false

func _ready():
	# Elige un tipo de pieza al azar del enum
	current_tetromino = Shared.Tetromino.values().pick_random()
	next_tetromino = Shared.Tetromino.values().pick_random()
	# Pide al tablero crear esa pieza (activa, sin posición manual)
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(next_tetromino, true, Vector2(100,50))
	board.tetromino_locked.connect(on_tetromino_locked)
	board.game_over.connect(on_game_over)
	
func on_tetromino_locked():
	if is_game_over:
		return
	current_tetromino = next_tetromino
	next_tetromino = Shared.Tetromino.values().pick_random()
	var new_tetromino = Shared. Tetromino.values().pick_random()
	board.spawn_tetromino(new_tetromino,false,null)
	board.spawn_tetromino(next_tetromino, true, Vector2(100,50))
	
fun on_game_over():
	is_game_over = true
	ui.show_game_over()
