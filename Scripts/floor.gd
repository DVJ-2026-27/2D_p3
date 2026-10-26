extends StaticBody2D

const CRATER_RADIUS: float = 40.0
const CRATER_POINTS: int = 24

@onready var path: Path2D = $Path2D
@onready var ground_polygon: Polygon2D = $Polygon2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	set_points()


func set_points() -> void:
	var points: PackedVector2Array = path.curve.get_baked_points()

	ground_polygon.polygon = points
	collision_polygon.polygon = points


func update_polygon_2d(world_position: Vector2) -> void:
	# Convertir la posición global del impacto a coordenadas locales
	var local_position: Vector2 = ground_polygon.to_local(world_position)

	# Crear el polígono circular del cráter
	var crater := PackedVector2Array()

	for i in range(CRATER_POINTS):
		var angle: float = TAU * float(i) / float(CRATER_POINTS)
		crater.append(
			local_position + Vector2(cos(angle), sin(angle)) * CRATER_RADIUS
		)

	# Restar el cráter al terreno
	var result: Array[PackedVector2Array] = Geometry2D.clip_polygons(
		ground_polygon.polygon,
		crater
	)

	if result.is_empty():
		print("No se ha obtenido ningún polígono.")
		return

	# Elegir el polígono de mayor área
	var largest_polygon: PackedVector2Array = result[0]
	var largest_area: float = polygon_area(largest_polygon)

	for polygon: PackedVector2Array in result:
		var area: float = polygon_area(polygon)

		if area > largest_area:
			largest_area = area
			largest_polygon = polygon

	# Actualizar visual y colisión
	ground_polygon.polygon = largest_polygon
	collision_polygon.polygon = largest_polygon

	print("Cráter aplicado. Puntos del terreno: ", largest_polygon.size())


func polygon_area(polygon: PackedVector2Array) -> float:
	var area: float = 0.0

	for i in range(polygon.size()):
		var j: int = (i + 1) % polygon.size()
		area += polygon[i].x * polygon[j].y
		area -= polygon[j].x * polygon[i].y

	return abs(area) * 0.5
