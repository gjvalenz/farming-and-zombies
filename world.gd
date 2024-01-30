extends Node2D

@export var seed: int = 1
@export var terrain_noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_SIMPLEX
@export var terrain_noise_frequency: float = 0.0016
@export var structure_noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
@export var structure_noise_frequency: float = 1.0
@export var decoration_noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
@export var decoration_noise_frequency: float = 1.0

@export var decoration_cuttoff: float = 0.6
@export var structure_cutoff: float = 0.8

@onready var tilemap: TileMap = $TileMap
@onready var new_tilemap: TileMap

var player: CharacterBody2D = preload("res://player.tscn").instantiate()
var enemy: Node = preload("res://scenes/objects/Enemy.tscn").instantiate()
var tree_obj = preload("res://scenes/objects/Snow_Tree.tscn")

var Chunk = preload("res://chunk.tscn")

const chunk_width: int = 64
const chunk_height: int = 64

var terrain_noise_map: FastNoiseLite = FastNoiseLite.new()
var rare_structure_noise_map: FastNoiseLite = FastNoiseLite.new()
var decoration_noise_map: FastNoiseLite = FastNoiseLite.new()

var random_rare_structure: RandomWeightedList = RandomWeightedList.new([1, 4, 5, 9], [1, 1, 1, 10])

var chunks: Dictionary = {}
var added_chunks: Dictionary = {}

"""
func select_terrain_index(p: float):
	if p < -0.05:
		return 1
	if p < 0.05:
		return 4
	if p < 0.15:
		return 0
	if p < 0.5:
		return 2
	return 3

func select_rare_structure_index(p: float):
	return p > structure_cutoff
	
func select_decoration_index(p: float):
	return p > decoration_cuttoff

func generate_terrain_chunk(chunk: Vector2i):
	if (generated_terrain_chunks.get(chunk, false) == true):
		return
	var base_x: int = chunk.x * chunk_width
	var start_x: int = base_x - chunk_width/2
	var end_x: int = base_x + chunk_width/2
	var base_y: int = chunk.y * chunk_height
	var start_y: int = base_y - chunk_height/2
	var end_y: int = base_y + chunk_height/2
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			# split these up
			# structure > decoration (layer 1)
			# terrain
			var index: int = select_terrain_index(terrain_noise_map.get_noise_2d(x, y))
			#var is_structure: bool = select_rare_structure_index(rare_structure_noise_map.get_noise_2d(x, y))
			#var is_decoration: bool = select_decoration_index(decoration_noise_map.get_noise_2d(x, y))
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(index, 0))
			if is_structure:
				var seed_: int = ((x * y + 4930) >> 3) % 2049302;
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(3, 0))
			elif is_decoration:
				if true:
					tilemap.set_cell(1, Vector2i(x, y), 1, Vector2i(3, 9))
				else:
					#var tree_deco: Node2D = tree_obj.instantiate() as Node2D
					#tree_deco.position = Vector2(x*chunk_width/2, y*chunk_height/2)
					#get_tree().get_root().add_child(tree_deco)
					pass
	generated_terrain_chunks[chunk] = true

func generate_terrain_chunks_adjacent_to(chunk: Vector2i):
	var render_size = 5
	var start_x: int = chunk.x - render_size
	var end_x: int = chunk.x + render_size
	var start_y: int = chunk.y - render_size
	var end_y: int = chunk.y + render_size
	for x in range(start_x, end_x+1):
		for y in range(start_y, end_y+1):
			generate_terrain_chunk(Vector2i(x, y))

func generate_terrain_chunks_directly_adjacent_to(chunk: Vector2i, v: Vector2):
	var foreshadow_dist = 3
	var x = chunk.x
	var y = chunk.y
	var n = v.normalized()
	var heading = Vector2i(n.x, n.y) + chunk
	generate_terrain_chunk(Vector2i(x, y))
	generate_terrain_chunk(heading)
	if abs(n.x) > 0:
		var header = int(n.x)
		for i in range(0, foreshadow_dist+1):
			generate_terrain_chunk(heading + Vector2i(i*header, -1))
			generate_terrain_chunk(heading + Vector2i(i*header, 0))
			generate_terrain_chunk(heading + Vector2i(i*header, 1))
	elif abs(n.y) > 0:
		var header = int(n.y)
		for i in range(0, foreshadow_dist+1):
			generate_terrain_chunk(heading + Vector2i(-1, i*header))
			generate_terrain_chunk(heading + Vector2i(0, i*header))
			generate_terrain_chunk(heading + Vector2i(1, i*header))
"""

func generate_chunk(chunk_coord: Vector2i) -> void:
	var m_chunk: Chunk = Chunk.instantiate() as Chunk
	m_chunk.generate_chunk(chunk_coord, terrain_noise_map, decoration_noise_map)
	m_chunk.global_position = Vector2(chunk_coord.x*16*64, chunk_coord.y*16*64)
	m_chunk.player = player
	m_chunk.on_chunk_remove.connect(_on_chunk_remove)
	chunks[chunk_coord] = m_chunk
	
func preload_chunks(size: int) -> void:
	for x in range(-size, size):
		for y in range(-size, size):
			generate_chunk(Vector2i(x, y))

# Called when the node enters the scene tree for the first time.
func _ready():
	terrain_noise_map.seed = seed
	terrain_noise_map.noise_type = terrain_noise_type
	terrain_noise_map.frequency = terrain_noise_frequency
	rare_structure_noise_map.seed = seed
	rare_structure_noise_map.noise_type = structure_noise_type
	rare_structure_noise_map.frequency = structure_noise_frequency
	decoration_noise_map.seed = (seed % 50 * 30 + 48593 * 54) % 903943
	decoration_noise_map.frequency = decoration_noise_type
	decoration_noise_map.frequency = decoration_noise_frequency
	self.add_child(player)
	#generate_terrain_chunks_adjacent_to(Vector2i(0, 0))
	preload_chunks(1)
	#enemy.speed = 100
	#enemy.target = player
	#get_tree().get_root().add_child(enemy)

func chunk_processing(chunk_coord: Vector2i) -> void:
	if chunk_coord in added_chunks:
		return
	var m_chunk: Chunk
	if not chunks.has(chunk_coord):
		generate_chunk(chunk_coord)
	m_chunk = chunks[chunk_coord]
	added_chunks[chunk_coord] = m_chunk
	self.add_child(m_chunk)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var map_coords = tilemap.local_to_map(player.position)
	var x: int = map_coords.x - chunk_width/2 if map_coords.x < 0 else map_coords.x + chunk_width/2 # just sign * abs(x + chunk/2)
	var y: int = map_coords.y - chunk_height/2 if map_coords.y < 0 else map_coords.y + chunk_width/2 # just sign * abs(y + chunk/2)
	var chunk_x: int = x/chunk_width
	var chunk_y: int = y/chunk_height
	var chunk: Vector2i = Vector2i(chunk_x, chunk_y)
	chunk_processing(chunk)
	#generate_terrain_chunks_directly_adjacent_to(chunk, player.velocity)"""
	#var thread: Thread = Thread.new()
	#thread.start(generate_terrain_chunks_directly_adjacent_to.bind(chunk))
	#loading_threads.append(thread)
	#generate_terrain_chunks_directly_adjacent_to(chunk)
	#generate_terrain_chunks_directly_adjacent_to()


func _on_day_night_cycle_component_on_day():
	player.light_off()
	EnemySpawner.disable()


func _on_day_night_cycle_component_on_night():
	player.light_on()
	EnemySpawner.enable()
	

func _on_chunk_remove(chunk_coords: Vector2i, node: Chunk) -> void:
	added_chunks.erase(chunk_coords)
	var enemy_count = node.enemy_entities.size()
	self.remove_child(node)
	EnemySpawner.decrease_count(enemy_count)

func _exit_tree():
	pass
