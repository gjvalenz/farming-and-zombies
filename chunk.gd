extends TileMap
class_name Chunk

const chunk_width: int = 64
const chunk_height: int = 64
const decoration_cuttoff: float = 0.52
const structure_cutoff: float = 0.72
var terrain_chunk_data: Array
var decorations_chunk_data: Dictionary = {}
var chunk_coords: Vector2i
@export var player: CharacterBody2D
var enemy_entities: Array

static var CHUNK_DISTANCE_PX: int = chunk_width * 16

var decoration_rand: RandomNumberGenerator = RandomNumberGenerator.new() 
var decoration_rand_start_state: int = 0
var loaded: bool = false

enum Terrain { Water, Beach, Dirt, Plains, Snow }
enum Decoration { DTree, Foliage, Ore, Crop, Flower }

signal on_chunk_remove

func terrain_noise_to_terrain(p: float) -> Terrain:
	if p < -0.05:
		return Terrain.Water
	if p < 0.05:
		return Terrain.Beach
	if p < 0.15:
		return Terrain.Dirt
	if p < 0.5:
		return Terrain.Plains
	return Terrain.Snow

func select_terrain_atlas(t: Terrain) -> Vector2i:
	match t:
		Terrain.Water:
			return Vector2i(1, 0)
		Terrain.Beach:
			return Vector2i(4, 0)
		Terrain.Dirt:
			return Vector2i(0, 0)
		Terrain.Plains:
			return Vector2i(2, 0)
		Terrain.Snow:
			return Vector2i(3, 0)
		_:
			return Vector2i(1, 0)

func survives_decoration_cutoff(p: float):
	return p > decoration_cuttoff

func generate_decoration_kind() -> Decoration:
	var result = decoration_rand.randi_range(0, 10)
	if result == 0:
		return Decoration.DTree
	return Decoration.Foliage

func select_decoration_kind(terrain: Terrain, decoration: Decoration) -> Vector2i:
	match decoration:
		Decoration.DTree:
			match terrain:
				Terrain.Plains:
					return Vector2i(11, 9)
				Terrain.Beach:
					return Vector2i(13, 9)
				Terrain.Water:
					return Vector2i(8, 9)
				Terrain.Snow:
					return Vector2i(0, 9)
				Terrain.Dirt:
					return Vector2i(6, 9)
	return Vector2i(0, 0)

func generate_chunk(chunk: Vector2i, terrain_noise: FastNoiseLite, decoration_noise: FastNoiseLite) -> void:
	chunk_coords = chunk
	decoration_rand.seed = ((terrain_noise.seed & 0x0000FFFF) << 48)|(((chunk.x & 0x00FFFFFF) << 24) | (chunk.y & 0x00FFFFFF))
	decoration_rand.state = decoration_rand_start_state
	var base_x: int = chunk.x * chunk_width
	var start_x: int = base_x - chunk_width/2
	var end_x: int = base_x + chunk_width/2
	var base_y: int = chunk.y * chunk_height
	var start_y: int = base_y - chunk_height/2
	var end_y: int = base_y + chunk_height/2
	for x in range(start_x, end_x):
		var data: Array = []
		for y in range(start_y, end_y):
			var terrain: Terrain = terrain_noise_to_terrain(terrain_noise.get_noise_2d(x, y))
			var is_decoration: bool = survives_decoration_cutoff(decoration_noise.get_noise_2d(x, y))
			data.append(terrain)
			if is_decoration:
				var decoration = generate_decoration_kind()
				decorations_chunk_data[Vector2i(x-base_x, y-base_y)] = select_decoration_kind(terrain, decoration)
		terrain_chunk_data.append(data)
		
func render_chunk() -> void:
	var start_x: int = -chunk_width/2
	var end_x: int = chunk_width/2
	var start_y: int = -chunk_height/2
	var end_y: int = chunk_height/2
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			var terrain: Terrain = terrain_chunk_data[chunk_width/2+x][chunk_height/2+y]
			set_cell(0, Vector2i(x, y), 0, select_terrain_atlas(terrain))
			if Vector2i(x, y) in decorations_chunk_data:
				set_cell(1, Vector2i(x, y), 1, decorations_chunk_data[Vector2i(x, y)])
				
func create_drop(item: Item, global_pos: Vector2, spread: float) -> void:
	var entity = item.item_entity.instantiate()
	entity.item_key = item.serial_key
	entity.global_position = global_pos + Vector2(randf_range(-spread, spread), randf_range(-spread, spread))
	get_tree().get_root().add_child(entity)

func handle_drops(coords: Vector2i) -> void:
	var data = get_cell_tile_data(1, coords)
	var game_name = data.get_custom_data('game_name')
	if game_name != null:
		var loottable: Loot = Registries.get_drops(game_name) as Loot
		if loottable != null:
			var drops = loottable.get_drops()
			for d in drops:
				create_drop(d, to_global(map_to_local(coords)), 50)

# Called when the node enters the scene tree for the first time.
func _ready():
	render_chunk()
	loaded = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.global_position.distance_to(global_position) >= CHUNK_DISTANCE_PX:
		on_chunk_remove.emit(chunk_coords, self)
		loaded = false


func _on_timer_timeout():
	if not loaded:
		return
	var random_position = Vector2i(randi_range(-chunk_width/2+1, chunk_width/2-1), randi_range(-chunk_width/2+1, chunk_width/2-1))
	var terrain_data = get_cell_tile_data(0, random_position)
	var data_extra = get_cell_atlas_coords(1, random_position)
	if terrain_data == null:
		return
	if terrain_data.get_custom_data('spawnable') != true:
		return
	if data_extra != null:
		if data_extra.x > 0 or data_extra.y > 0:
			return
	var enemy = EnemySpawner.try_spawn_enemy()
	if enemy == null:
		return
	enemy.global_position = to_global(map_to_local(random_position))
	enemy.target = player
	get_tree().get_root().add_child(enemy)
