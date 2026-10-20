extends Node2D

class_name Tetromino
# tabla de wall kicks que usa esta pieza (I o JLOSTZ)
var wall_kicks
# datos de la pieza (.tres), textura, tipo y posición de aparición
var tetromino_data
# true si es la pieza de vista previa, false si es la jugable
var is_next_piece
# lista de los 4 bloques (Piece) que forman la pieza
var pieces = []

@onready var piece_scene = preload("res://Scenes/piece.tscn")
# posiciones relativas de los 4 bloques de esta pieza
var tetromino_cells
func _ready():
	# obtiene las celdas según el tipo de pieza
	tetromino_cells = Shared.cells[tetromino_data.tetromino_type]

	# crea un bloque por cada celda
	for cell in tetromino_cells:
		var piece = piece_scene.instantiate() as Piece
		pieces.append(piece)
		add_child(piece)
		# aplica la textura y coloca el bloque
		piece.set_texture(tetromino_data.piece_texture)
		piece.position = cell * piece.get_size()

	# solo la pieza activa se coloca y recibe wall kicks
	if is_next_piece == false:
		position = tetromino_data.spawn_position
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
