class_name Layout
extends TileMapLayer



func get_texture() -> Image:
	var rect: Rect2i = get_used_rect()
	var img: Image = Image.new()
	var bounds: Vector2i = rect.size
	img.resize(16 * bounds.x,16 * bounds.y)
	for i in range(rect.position.x, rect.end.x):
		for j in range(rect.position.y, rect.end.y):
			var spot: Vector2i = Vector2i(i,j)
			var data: TileData = get_cell_tile_data(spot)
			get_cell_atlas_coords(spot)
			
	
	return img
