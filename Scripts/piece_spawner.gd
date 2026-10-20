extends Node
# Tipo de pieza actual (I, O, T, J, L, S o Z)
var current_tetromino
# Referencia al nodo Board
@onready var board = $"../Board" as Board

func _ready():
	# Elige un tipo de pieza al azar del enum
	current_tetromino = Shared.Tetromino.values().pick_random()
	# Pide al tablero crear esa pieza (activa, sin posición manual)
	board.spawn_tetromino(current_tetromino, false, null)
	board.tetromino_locked.connect(on_tetromino_locked)
	
func on_tetromino_locked():
	var new_tetromino = Shared. Tetromino.values().pick_random()
	board.spawn_tetromino(new_tetromino,false,null)
