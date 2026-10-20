extends Node
# Registra este script como tipo global "Board"
class_name Board
@export var tetromino_scene: PackedScene

# Crea una pieza (type: I, O, T...; is_next_piece: true si es la vista previa)
func spawn_tetromino(type: Shared.Tetromino, is_next_piece, spawn_position):
	# Obtiene los datos (.tres) de esta pieza
	var tetromino_data = Shared.data[type]
	# Crea una copia de la escena de la pieza
	var tetromino = tetromino_scene.instantiate() as Tetromino
	# Le pasa sus datos y si es vista previa o jugable
	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece

	# Solo la pieza activa se coloca y se añade al tablero
	if is_next_piece == false:
		tetromino.position = tetromino_data.spawn_position
		add_child(tetromino)
