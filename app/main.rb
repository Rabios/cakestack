# Written by Rabia Alhaffar in 14/November/2020
# Stacking game for teeny-tiny game jam
# I got cutting block logic from following repo: https://github.com/tma02/stack
# Background from freepik.com: https://www.freepik.com/free-vector/sweet-pastries-chalkboard_1529234.htm
# Stacking sound: https://freesound.org/people/kemitix/sounds/41869

def tick args
  # Load variables
  setup args
  
  # Check and render current scene
  if args.state.scene == 0
    game args
  elsif args.state.scene == 1
    lose args
  end
  
  # Draw FPS
  args.outputs.primitives << {
    x: 10,
	y: 10.from_top,
	text: args.gtk.current_framerate.to_i,
	size_enum: 8,
	r: 0,
	g: 255,
	b: 0,
	a: 255,
  }
  
  # ESC: Exit game
  if args.inputs.keyboard.escape
    $gtk.exit
  end
  
  # TAB or R key: Restart game
  if args.inputs.keyboard.tab || args.inputs.keyboard.r
    $gtk.reset seed: (Time.now.to_f * 100).to_i
  end
end

# Here variables loaded
def setup args
  args.state.scene  ||= 0   # Current scene
  args.state.score  ||= 0   # Score
  args.state.blocks ||= []  # Blocks stacked
  
  # Load base and movement block
  args.state.start_block ||= {
    speed: 0,
	x: 340,
	y: 0,
	w: 600,
	h: 100,
	path: "sprites/#{rand(4) + 1}.png"
  }
  
  args.state.current_block ||= {
    speed: 6,
	x: 340,
	y: 100,
	w: 600,
	h: 100, 
	path: "sprites/1.png"
  }
end

def game args
  # Move block by speed
  args.state.current_block.x += args.state.current_block[:speed]
  
  # Draw background, Score, and blocks...
  args.outputs.primitives << {
    x: 0,
	y: 0,
	w: 1280,
	h: 720,
	path: "sprites/background.jpg",
	a: 230
  }
  
  args.outputs.primitives << {
    x: 600,
	y: 10.from_top,
	text: args.state.score,
	size_enum: 32,
	r: 255,
	g: 0,
	b: 255,
	a: 255
  }
  
  args.outputs.primitives << args.state.start_block.sprite
  args.outputs.primitives << args.state.current_block.sprite
  
  args.state.blocks.each do |r|
    args.outputs.primitives << r.sprite
  end
  
  # If key space pressed or clicked, Stack!
  if args.inputs.keyboard.key_up.space || args.inputs.mouse.click
    
	# Get difference of x and width to make cut of them
    lastblock = (args.state.score == 0) ? args.state.start_block : args.state.blocks[args.state.blocks.length() - 1]
    if (args.state.current_block.x > lastblock.x)
      new_width = (lastblock.x + lastblock.w) - (args.state.current_block.x)
	  new_x = args.state.current_block.x
    else
      new_width = (args.state.current_block.x + args.state.current_block.w) - (lastblock.x);
      new_x = lastblock.x
    end
	
	# If smaller than or equal to 0, Game over!
    if (new_width <= 0)
      new_width = 0
	  args.state.scene = 1
	end
	
	# Push block
	args.state.blocks.push({
	  x: new_x,
	  y: args.state.current_block.y,
	  w: new_width,
	  h: 100,
	  path: args.state.current_block.path
    })
	
	# Setting width of movement block with last block stacked, With random cake image...
	args.state.current_block.w = args.state.blocks[args.state.blocks.length() - 1].w
	args.state.current_block.path = "sprites/#{rand(4) + 1}.png"
	
	# Increase score and play sound
	args.state.score += 1
	args.outputs.sounds << "audio/stack.wav"
	
	# If stack more than 4, Move game objects to up (This works like a 2D camera...)
    # Else, Keep with increasing y of movement block
	if args.state.score > 3
	  args.state.blocks.each do |r|
        r[:y] -= 100
      end
	  args.state.start_block.y -= 100
	else
	  args.state.current_block.y += 100
	end
	
	# Increase speed by 0.5, And reverse movement direction of movement block
	args.state.current_block[:speed] = -(args.state.current_block[:speed].abs + 0.5)
  end
  
  # Reverse movement direction of movement block if hit with left or right side of game window...
  if (args.state.current_block.x + args.state.current_block.w >= 1280) || (args.state.current_block.x <= 0)
    args.state.current_block[:speed] = -args.state.current_block[:speed]
  end
  
end

def lose args
  # Draw texts...
  args.outputs.primitives << {
    x: 360,
	y: 200.from_top,
	text: "YOU LOSE!!!",
	size_enum: 48,
	r: 255,
	g: 0,
	b: 0,
	a: 255
  }.label
  
  args.outputs.primitives << {
    x: 240,
	y: 400.from_top,
	text: "Your score is #{args.state.score}, Click anywhere to restart game!",
	size_enum: 8
  }.label
  
  # Restart game if user click...
  if args.inputs.mouse.click
    $gtk.reset seed: (Time.now.to_f * 100).to_i
  end
end