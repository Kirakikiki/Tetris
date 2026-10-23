extends Node
# Registra este script como tipo global "Board"
class_name Board

signal tetromino_locked
signal game_over
@onready var panel_container = $"../PanelContainer"
@onready var line_container = $"../score/LineLabel"
@onready var score_container = $"../score/ScoreLabel"

# Escena de una "línea" (fila): un nodo que agrupa los bloques de la misma altura
@onready var line_scene = preload("res://Scenes/line.tscn")
@export var tetromino_scene: PackedScene
const ROW_COUNT = 20
# Una fila está llena cuando tiene este número de bloques
const COLUMN_COUNT = 10
var next_tetromino
var tetrominos:Array[Tetromino] = []
# líneas borradas en total
var lines_cleared = 0
# segundos que tarda la pieza en bajar una casilla
var fall_time = BASE_FALL_TIME

var score = 0 #puntaje total

# tiempo inicial (ponlo igual al Wait Time actual de tu Timer)
const BASE_FALL_TIME = 1.0
# la caída nunca será más rápida que esto
const MIN_FALL_TIME = 0.5
# cada cuántas líneas sube el nivel
const LINES_PER_LEVEL = 1

func _ready():
	update_score_label()

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
		# Le pasa los bloques ya fijados (para detectar colisiones)
		var other_pieces = get_all_pieces()
		tetromino.other_tetrominoes_pieces = other_pieces
		tetromino.lock_tetromino.connect(on_tetromino_locked)
		tetromino.fall_time = fall_time
		add_child(tetromino)
	else:
		tetromino.scale = Vector2(0.5, 0.5)
		panel_container.add_child(tetromino)
		# calcula el centro de la pieza en celdas (según su forma)
		var cells = Shared.cells[type]
		var min_c = cells[0]
		var max_c = cells[0]
		for c in cells:
			min_c = Vector2(min(min_c.x, c.x), min(min_c.y, c.y))
			max_c = Vector2(max(max_c.x, c.x), max(max_c.y, c.y))
		var center_cells = (min_c + max_c) / 2.0
		# spawn_position ahora es el CENTRO del recuadro (48 = tamaño de bloque, 0.5 = escala)
		tetromino.position = spawn_position - center_cells * 48 * 0.5
		next_tetromino = tetromino

# Se ejecuta cuando una pieza se fija. Aquí empieza todo el proceso de borrado.
func on_tetromino_locked(tetromino: Tetromino):
	next_tetromino.queue_free()
	tetrominos.append(tetromino)
	# PASO 1: reparte los 4 bloques de la pieza en sus filas
	add_tetromino_to_lines(tetromino)
	# PASO 2: busca filas llenas y las borra
	remove_full_lines()
	tetromino_locked.emit()
	check_game_over()
	

# Si algún bloque fijo llegó a la fila superior (y = -456), se acaba el juego
func check_game_over():
		for piece in get_all_pieces():
			var y_location = piece.global_position.y
			if is_equal_approx(y_location, -456.0):
				game_over.emit()

# PASO 1: saca cada bloque de la pieza y lo mete en la fila (Line) de su altura.
# Así una fila es un nodo que contiene todos los bloques de esa altura.
func add_tetromino_to_lines(tetromino: Tetromino):
	# Toma solo los hijos que son bloques (Piece)
	var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece)

	for piece in tetromino_pieces:
		# altura del bloque en el mundo
		var y_position = piece.global_position.y
		var does_line_for_piece_exists = false
		# si ya existe una fila a esa altura, el bloque se muda a ella
		for line in get_lines():
			if is_equal_approx(line.global_position.y, y_position):
				piece.reparent(line)
				does_line_for_piece_exists = true

		# si no existe, crea una fila nueva a esa altura y mete el bloque
		if !does_line_for_piece_exists:
			var piece_line = line_scene.instantiate() as Line
			piece_line.global_position = Vector2(0, y_position)
			add_child(piece_line)
			piece.reparent(piece_line)

# devuelve todas las filas (nodos Line) que hay en el tablero
func get_lines():
	return get_children().filter(func (c): return c is Line)

# PASO 2: revisa cada fila; si está llena (10 bloques), la elimina
func remove_full_lines():
	var linesThisPiece = 0
	for line in get_lines():
		# is_line_full cuenta los bloques de la fila (está en line.gd)
		if line.is_line_full(COLUMN_COUNT):
			# PASO 3: baja todas las filas que están ENCIMA de esta
			move_lines_down(line.global_position.y)
			# PASO 4: borra la fila completa 
			line.free()
			# PASO 5: suma la línea y recalcula la velocidad
			lines_cleared += 1
			linesThisPiece += 1
			update_fall_time()
	_add_score(linesThisPiece)

# calcula el tiempo de caída según el nivel actual
func update_fall_time():
	var level = lines_cleared / LINES_PER_LEVEL
	fall_time = max(MIN_FALL_TIME, BASE_FALL_TIME * pow(0.9, level))

# PASO 3: baja 48 px (un bloque) las filas que están arriba de la borrada.
func move_lines_down(y_position):
	for line in get_lines():
		if line.global_position.y < y_position:
			line.global_position.y += 48

# Devuelve todos los bloques fijos del tablero (para colisiones y game over)
func get_all_pieces():
	var pieces = []
	for line in get_lines():
		pieces.append_array(line.get_children())
	return pieces

func _add_score(lines):
	if lines >0:
		score += 200 * lines - 100
		update_score_label()

func update_score_label ():
	score_container.text = "Puntos: " + str(score)
	line_container.text = "Lineas eliminadas:" + str(lines_cleared)
