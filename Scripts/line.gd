extends Node2D

class_name Line

# devuelve true si la fila tiene todos sus bloques (10)
func is_line_full(max_count):
	# cada bloque es un hijo de la fila, así que se cuentan los hijos
	return max_count == get_child_count()
