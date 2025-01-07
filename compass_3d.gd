extends Node3D

# The existence of a root world is to be used for games which might have paralell dimension
# This way multiple "Norths" can exist. And for example 1 dimension can be rotated, so that north would be ever changing
@export var root_world_3D: Node3D 
@export_range(0, 360, 0.1, "radians_as_degrees") var north_as_angle: float

enum xyz_enum {x, y, z}
@export var axis : xyz_enum = xyz_enum.y
