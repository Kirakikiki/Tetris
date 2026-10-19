extends Node

enum Tetromino {
	I,O, T, J, L, S, Z
}

#celdas de cada pieza
# Diccionario: tipo de pieza -> lista de 4 posiciones (una por bloque).
# Las posiciones son RELATIVAS al punto de pivote de la pieza, que es (0, 0).
# Así, al mover la pieza solo sumas su posición en el tablero a cada celda.
var cells = {
	#cuatro bloques en línea horizontal
	Tetromino.I: [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
	#fila de 3 bloques y uno extra en el extremo izquierdo
	Tetromino.J: [Vector2(-1, 1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],
	#fila de 3 bloques y uno extra en el extremo derecho
	Tetromino.L: [Vector2(1, 1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],
	#cuadrado de 2x2
	Tetromino.O: [Vector2(0, 1), Vector2(1, 1), Vector2(0, 0), Vector2(1, 0)],
	#dos bloques arriba desplazados a la derecha, dos abajo a la izquierda
	Tetromino.S: [Vector2(0, 1), Vector2(1, 1), Vector2(-1, 0), Vector2(0, 0)],
	#fila de 3 bloques + uno en el centro
	Tetromino.T: [Vector2(0, 1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],
	# es un espejo de la S
	Tetromino.Z: [Vector2(-1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)]
}


# WALL KICKS 
# Cuando rotas una pieza junto a una pared o a otras piezas, la rotación podría
# chocar.Un "wall kick" prueba mover la pieza a posiciones alternativas hasta encontrar una donde quepa.

# Wall kicks exclusivos de la pieza I (es más larga, necesita desplazamientos distintos)
var wall_kicks_i = [
	[Vector2(0,0), Vector2(-2,0), Vector2(1,0), Vector2(-2,-1), Vector2(1,2)],
	[Vector2(0,0), Vector2(2,0), Vector2(-1, 0), Vector2(2,1), Vector2(-1, -2)],
	[Vector2(0,0), Vector2(-1, 0), Vector2(2,0), Vector2(-1,2), Vector2(2, -1)],
	[Vector2(0,0), Vector2(1,0), Vector2(-2, 0), Vector2(1, -2), Vector2(-2, 1)],
	[Vector2(0,0), Vector2(2,0), Vector2(-1, 0), Vector2(2,1), Vector2(-1, -2)],
	[Vector2(0,0), Vector2(-2,0), Vector2(1, 0), Vector2(-2, -1), Vector2(1, 2)],
	[Vector2(0,0), Vector2(1,0), Vector2(-2,0), Vector2(1, -2), Vector2(-2,1)],
	[Vector2(0,0), Vector2(-1, 0), Vector2(2, 0), Vector2(-1,2), Vector2(2, -1)]
]
# Wall kicks para J, L, S, T y Z 
var wall_kicks_jlostz = [
	[Vector2(0,0), Vector2(-1,0), Vector2(-1,1), Vector2(0,-2), Vector2(-1, -2)],
	[Vector2(0,0), Vector2(1,0), Vector2(1, -1), Vector2(0,2), Vector2(1, 2)],
	[Vector2(0,0), Vector2(1, 0), Vector2(1,-1), Vector2(0,2), Vector2(1, 2)],
	[Vector2(0,0), Vector2(-1,0), Vector2(-1, 1), Vector2(0, -2), Vector2(-1, -2)],
	[Vector2(0,0), Vector2(1,0), Vector2(1, 1), Vector2(0,-2), Vector2(1, -2)],
	[Vector2(0,0), Vector2(-1,0), Vector2(-1, -1), Vector2(0, 2), Vector2(-1, 2)],
	[Vector2(0,0), Vector2(-1,0), Vector2(-1,-1), Vector2(0, 2), Vector2(-1, 2)],
	[Vector2(0,0), Vector2(1, 0), Vector2(1, 1), Vector2(0,-2), Vector2(1, -2)]
]

# datos de cada pieza
# Diccionario: tipo de pieza 
# Aquí es donde se usan los recursos (i_piece_data.tres, etc.).
var data = {
	Tetromino.I: preload("res://Resources/i_piece_data.tres"),
	Tetromino.J: preload("res://Resources/j_piece_data.tres"),
	Tetromino.L: preload("res://Resources/l_piece_data.tres"),
	Tetromino.O: preload("res://Resources/o_piece_data.tres"),
	Tetromino.S: preload("res://Resources/s_piece_data.tres"),
	Tetromino.T: preload("res://Resources/t_piece_data.tres"),
	Tetromino.Z: preload("res://Resources/z_piece_data.tres")
}
#matrices de rotacion
# Matrices 2x2 para rotar 90° las celdas alrededor del pivote (0, 0).
var clockwise_rotation_matrix = [Vector2(0, -1), Vector2(1, 0)]
var counter_clockwise_rotation_matrix = [Vector2(0,1), Vector2(-1, 0)]
