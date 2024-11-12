extends CharacterBody2D

const GRAVITY : int = 4000#4200
const JUMP_SPEED : int = -2500 #-1800

var lvl_name : String
var lvl_number : int



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (lvl_number):
		lvl_name = "lvl" + str(lvl_number)
	else:
		lvl_name = "lvl1"
		
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play(lvl_name + "_idle")
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("left_click"):
				velocity.y = JUMP_SPEED
				#$JumpSound.play()
			#elif Input.is_action_pressed("ui_down") or Input.is_action_pressed("right_click"):
				#$AnimatedSprite2D.play("duck")
				#$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play(lvl_name + "_run")
	else:
		$AnimatedSprite2D.play(lvl_name + "_jump")
		
	move_and_slide()
