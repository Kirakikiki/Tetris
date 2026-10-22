extends Node2D

class_name Tetromino
signal lock_tetromino(tetromino: Tetromino)

# Límites del tablero en píxeles (izquierda, derecha y suelo)
var bounds ={ 
	"min_x": -216,
	"max_x": 216,
	"max_y": 457
	 }
var rotation_index = 0
# tabla de wall kicks que usa esta pieza (I o JLOSTZ)
var wall_kicks
# datos de la pieza (.tres), textura, tipo y posición de aparición
var tetromino_data
# true si es la pieza de vista previa, false si es la jugable
var is_next_piece
# lista de los 4 bloques (Piece) que forman la pieza
var pieces = []
# bloques sueltos (Piece) ya fijados en el tablero; los llena Board
var other_tetrominoes_pieces = []
# sombra que muestra dónde caerá la pieza
var ghost_tetromino
# segundos entre cada caída (la asigna Board)
var fall_time = 1.0

@onready var timer = $Timer
@onready var piece_scene = preload("res://Scenes/piece.tscn")
@onready var ghost_tetromino_scene = preload("res://Scenes/ghost_tetromino.tscn")

# posiciones relativas de los 4 bloques de esta pieza
var tetromino_cells
func _ready():
	# obtiene las celdas según el tipo de pieza
	tetromino_cells = Shared.cells[tetromino_data.tetromino_type].duplicate()
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
		# aplica la velocidad de caída y reinicia el timer con ella
		timer.start(fall_time)
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz
		ghost_tetromino = ghost_tetromino_scene.instantiate() as GhostTetromino
		ghost_tetromino.tetromino_data = tetromino_data
		get_tree().root.add_child.call_deferred(ghost_tetromino)
		hard_drop_ghost.call_deferred()
	else:
		# la vista previa no cae: se detiene su timer
		timer.stop()
		
# calcula dónde caería la pieza y coloca la sombra ahí
func hard_drop_ghost():
	if !is_instance_valid(ghost_tetromino):
		return
	var final_hard_drop_position = global_position
	var next_position = calculate_global_position(Vector2.DOWN, final_hard_drop_position)

	# sigue bajando mientras la posición sea válida
	while next_position != null:
			final_hard_drop_position = next_position
			next_position = calculate_global_position(Vector2.DOWN, final_hard_drop_position)

	# copia la posición local de cada bloque para dibujar la misma forma
	var pieces_position = []
	for piece in pieces:
		pieces_position.append(piece.position)

	ghost_tetromino.set_ghost_tetromino(final_hard_drop_position, pieces_position)
	return final_hard_drop_position

# lee los controles del jugador
func _input(_event):
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
		rotate_tetromino(-1)
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_tetromino(1)
		

#  mover la pieza, devuelve true si pudo moverse
func move(direction: Vector2) -> bool:
	var new_position = calculate_global_position(direction, global_position)
	if new_position != null:
		global_position = new_position
	# al moverse de lado, la sombra se recalcula (al bajar no cambia)
		if direction != Vector2.DOWN:
			hard_drop_ghost.call_deferred()
		return true
	return false
	
# calcula la nueva posicion si np devuelve null si el movimiento no es valido
func calculate_global_position(direction: Vector2, starting_global_position: Vector2):
	if is_colliding_with_other_tetrominos(direction,starting_global_position):
		return null
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
	
# revisa si algún bloque caería sobre un bloque de otra pieza fija
func is_colliding_with_other_tetrominos(direction: Vector2, starting_global_position: Vector2):
	for other_piece in other_tetrominoes_pieces:
		for piece in pieces:
			# posición destino de mi bloque contra la posición del bloque fijo
			var my_pos = starting_global_position + piece.position + direction * piece.get_size().x
			if my_pos.is_equal_approx(other_piece.global_position):
				return true
	return false

# rota la pieza
func rotate_tetromino(direction: int):
	var original_rotation_index = rotation_index
	# la pieza o no necesita rotar
	if tetromino_data.tetromino_type == Shared.Tetromino.O:
		return
		
	# gira los bloques y actualiza el estado de rotación (0 a 3)
	apply_rotation(direction)
	
	rotation_index = wrap(rotation_index + direction, 0, 4)
	
	# si ningún wall kick funciona, vuelve al estado anterior
	if !test_wall_kicks(rotation_index, direction):
		rotation_index = original_rotation_index
		apply_rotation(-direction)

	hard_drop_ghost.call_deferred()
	
# prueba los 5 desplazamientos del wall kick, true si alguno funciona
func test_wall_kicks(new_rotation_index: int, rotation_direction: int):
	var wall_kick_index = get_wall_kick_index(new_rotation_index, rotation_direction)
	for i in wall_kicks[0].size():
		var translation = wall_kicks[wall_kick_index][i]
		# move() solo mueve si la posición es válida
		if move(translation):
			return true
	return false

# elige la fila de la tabla de wall kicks según el giro realizado
func get_wall_kick_index(new_rotation_index: int, rotation_direction):
	var wall_kick_index = new_rotation_index * 2
	if rotation_direction < 0:
		wall_kick_index -= 1

	return wrap(wall_kick_index, 0, wall_kicks.size())

# gira las celdas 90° con la matriz de rotación y recoloca los bloques
func apply_rotation(direction: int):
	# horaria (1) o antihoraria (-1)
	var rotation_matrix = Shared.clockwise_rotation_matrix if direction == 1 else Shared.counter_clockwise_rotation_matrix
	# calcula la nueva posición de cada celda
	for i in tetromino_cells.size():
		var cell = tetromino_cells[i]
		var coordinates = rotation_matrix[0] * cell.x + rotation_matrix[1]* cell.y
		tetromino_cells[i] = coordinates
		
	# mueve cada bloque a su nueva celda
	for i in pieces.size():
		var piece = pieces[i]
		piece.position = tetromino_cells[i] * piece.get_size()

# baja la pieza hasta el fondo
func hard_drop():
	while(move(Vector2.DOWN)):
		continue
	lock()

# fija la pieza: detiene la caída, avisa al Board y quita la sombra
func lock():
	timer.stop()
	lock_tetromino.emit(self)
	set_process_input(false)
	# evita error si no hay sombra
	if is_instance_valid(ghost_tetromino):
		ghost_tetromino.queue_free()
	
#cada vez que el timer termina, la pieza baja una casilla
func _on_timer_timeout():
	# la vista previa no debe caer
	if is_next_piece:
		return
	var should_lock = !move(Vector2.DOWN)
	if should_lock:
		lock()
