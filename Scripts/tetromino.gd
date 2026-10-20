extends Node2D

class_name Tetromino
# Límites del tablero en píxeles (izquierda, derecha y suelo)
var bounds ={ 
	"min_x": -216,
	"max_x": 216,
	"max_y": 457
	 }
# tabla de wall kicks que usa esta pieza (I o JLOSTZ)
var wall_kicks
# datos de la pieza (.tres), textura, tipo y posición de aparición
var tetromino_data
# true si es la pieza de vista previa, false si es la jugable
var is_next_piece
# lista de los 4 bloques (Piece) que forman la pieza
var pieces = []

@onready var timer = $Timer
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

	# solo çla pieza activa se coloca y recibe wall kicks
	if is_next_piece == false:
		position = tetromino_data.spawn_position
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz
		
# lee los controles del jugador
func _input(event):
	# la pieza de vista previa no debe responder a controles
	if is_next_piece:
		return
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("hard_drop"):
		hard_drop()
	elif Input.is_action_just_pressed("rotate_left"):
		pass
	elif Input.is_action_just_pressed("rotate_right"):
		pass
		

#  mover la pieza, devuelve true si pudo moverse
func move(direction: Vector2) -> bool:
	var new_position = calculate_global_position(direction, global_position)
	if new_position != null:
		global_position = new_position
		return true
	return false
# calcula la nueva posicion si np devuelve null si el movimiento no es valido
func calculate_global_position(direction: Vector2, starting_global_position: Vector2):

	# Revisa que no se salga del tablero
	if !is_within_game_bounds(direction, starting_global_position):
		return null
	return starting_global_position + direction * pieces[0].get_size().x
# revisa que todos los bloques sigan dentro de los límites tras moverse
func is_within_game_bounds(direction: Vector2, starting_global_position: Vector2):
	for piece in pieces:
		var new_position = piece.position + starting_global_position + direction * piece.get_size()
		if new_position.x < bounds.get("min_x") || new_position.x > bounds.get("max_x") || new_position.y >= bounds.get("max_y"):
			return false
	return true

# baja la pieza hasta el fondo
func hard_drop():
	while(move(Vector2.DOWN)):
		continue
		
#cada vez que el timer termina, la pieza baja una casilla
func _on_timer_timeout():
	move(Vector2.DOWN)
	
