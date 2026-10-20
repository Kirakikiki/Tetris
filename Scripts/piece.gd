extends Area2D

class_name Piece

# referencias a los nodos hijos
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D
# asigna la textura al sprite del bloque
func set_texture(texture: Texture2D):
	sprite_2d. texture = texture
# devuelve el tamaño del bloque
func get_size():
	return collision_shape_2d.shape.get_rect().size
