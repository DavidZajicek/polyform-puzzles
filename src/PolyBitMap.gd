class_name PolyBitMap
extends BitMap

func get_all_inner_walls():
	var points: PackedVector2Array
	for x in self.get_size().x:
		for y in self.get_size().y:
			if self.get_bit(x, y):
				points.append(Vector2i(x, y))
	return points
