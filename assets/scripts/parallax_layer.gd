extends TextureRect

var pivot_goal: Vector2 = Vector2.ZERO


func _process(delta):
	pivot_offset.x = lerpf(pivot_offset.x, pivot_goal.x, 1 * delta)
	pivot_offset.y = lerpf(pivot_offset.y, pivot_goal.y, 1 * delta)

func set_pivot_goal(goal: Vector2):
	pivot_goal = goal
