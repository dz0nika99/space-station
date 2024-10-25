import pygame, sys
from random import choice, randint
import math 
from PIL import Image
 
class Player(pygame.sprite.Sprite):
    def __init__(self, pos, constraint, speed):
        super().__init__()
        self.image = pygame.image.load('./graphics/spaceship.png').convert_alpha()
        self.rect = self.image.get_rect(midbottom=pos)
        self.speed = speed
        self.max_x_constraint = constraint
        self.ready = True
        self.laser_time = 0
        self.laser_cooldown = 600
        self.direction = 0
        self.screen_width = constraint

        self.lasers = pygame.sprite.Group()

        self.laser_sound = pygame.mixer.Sound('./audio/laser.wav')
        self.laser_sound.set_volume(0.2)

        # Variables for bobbing effect
        self.bob_height = 1  # The height of the bobbing effect
        self.bob_speed = 0.1  # Speed of bobbing
        self.bob_offset = 1  # Offset for the sine function

    def get_input(self):
        screen_width, screen_height = pygame.display.get_surface().get_size()
        keys = pygame.key.get_pressed()

        if keys[pygame.K_RIGHT]:
            self.rect.x += self.speed
        elif keys[pygame.K_LEFT]:
            self.rect.x -= self.speed

        if keys[pygame.K_SPACE] and self.ready:
            self.shoot_laser()
            self.ready = False
            self.laser_time = pygame.time.get_ticks()
            self.laser_sound.play()

        touch_input = pygame.mouse.get_pressed()

        if touch_input[0]:  # Detect touch
            touch_pos = pygame.mouse.get_pos()
            if touch_pos[0] < screen_width / 2:
                self.rect.x -= self.speed  # Move left
            elif touch_pos[0] > screen_width / 2 and touch_pos[1] < screen_height * 0.8:
                self.rect.x += self.speed  # Move right
            elif touch_pos[1] > screen_height * 0.8:  # Bottom 20% of the screen is for shooting
                if self.ready:
                    self.shoot_laser()
                    self.ready = False
                    self.laser_time = pygame.time.get_ticks()

    def recharge(self):
        if not self.ready:
            current_time = pygame.time.get_ticks()
            if current_time - self.laser_time >= self.laser_cooldown:
                self.ready = True

    def constraint(self):
        if self.rect.left <= 0:
            self.rect.left = 0
        if self.rect.right >= self.max_x_constraint:
            self.rect.right = self.max_x_constraint

    def shoot_laser(self):
        self.lasers.add(Laser(self.rect.center, -8, self.rect.bottom))

    def update(self):
        self.get_input()
        self.constraint()
        self.recharge()
        self.lasers.update()

        # Update bobbing effect
        self.bob_offset += self.bob_speed
        self.rect.y += math.sin(self.bob_offset) * self.bob_height  # Apply bobbing

class Alien(pygame.sprite.Sprite):
	def __init__(self,color,x,y):
		super().__init__()
		file_path = './graphics/' + color + '.png'
		self.image = pygame.image.load(file_path).convert_alpha()
		self.rect = self.image.get_rect(topleft = (x,y))
		self.bob_height = 1 
		self.bob_speed = 0.1 
		self.bob_offset = 0

		if color == 'red': self.value = 100
		elif color == 'green': self.value = 200
		else: self.value = 300

	def update(self,direction):
		self.rect.x += direction
		# Update bobbing effect
		self.bob_offset += self.bob_speed
		self.rect.y += math.sin(self.bob_offset) * self.bob_height  # Apply bobbing

class Extra(pygame.sprite.Sprite):
	def __init__(self,side,screen_width):
		super().__init__()
		self.image = pygame.image.load('./graphics/extra.png').convert_alpha()
		
		if side == 'right':
			x = screen_width + 50
			self.speed = - 3
		else:
			x = -50
			self.speed = 3

		self.rect = self.image.get_rect(topleft = (x,80))

	def update(self):
		self.rect.x += self.speed

class Laser(pygame.sprite.Sprite):
	def __init__(self,pos,speed,screen_height):
		super().__init__()
		self.image = pygame.Surface((4,20))
		self.image.fill('white')
		self.rect = self.image.get_rect(center = pos)
		self.speed = speed
		self.height_y_constraint = screen_height

	def destroy(self):
		if self.rect.y <= -50 or self.rect.y >= self.height_y_constraint + 50:
			self.kill()

	def update(self):
		self.rect.y += self.speed
		self.destroy()

class Block(pygame.sprite.Sprite):
	def __init__(self,size,color,x,y):
		super().__init__()
		self.image = pygame.Surface((size,size))
		self.image.fill(color)
		self.rect = self.image.get_rect(topleft = (x,y))

shape = [
'  xxxxxxx',
' xxxxxxxxx',
'xxxxxxxxxxx',
'xxxxxxxxxxx',
'xxxxxxxxxxx',
'xxx     xxx',
'xx       xx']
class Game:
    def __init__(self):
        self.home_screen_frames = []
        self.load_home_screen_gif()
        self.current_frame = 0
        self.clock = pygame.time.Clock()
        self.reset_game()
        self.game_won = False
        self.game_over = False  # New flag to track game over state

    def load_home_screen_gif(self):
        # Load the GIF using PIL
        gif_path = './graphics/home.gif'
        with Image.open(gif_path) as img:
            for frame in range(img.n_frames):
                img.seek(frame)
                # Convert the frame to a Pygame-compatible format
                frame_data = img.convert("RGBA").tobytes()  # Convert to RGBA
                frame_surface = pygame.image.frombuffer(frame_data, img.size, "RGBA")
                self.home_screen_frames.append(frame_surface)


    def reset_game(self):
        # Adjust screen size for mobile devices
        player_sprite = Player((screen_width / 2, screen_height), screen_width, 5)
        self.player = pygame.sprite.GroupSingle(player_sprite)

        # Health and score setup
        self.lives = 3
        self.live_surf = pygame.image.load('./graphics/spaceship.png').convert_alpha()
        self.live_x_start_pos = screen_width - (self.live_surf.get_size()[0] * 2)
        self.score = 0
        self.font = pygame.font.Font('./font/Pixeled.ttf', 20)

        # Obstacle setup
        self.shape = shape
        self.block_size = 6
        self.blocks = pygame.sprite.Group()
        self.obstacle_amount = 4
        self.obstacle_x_positions = [num * (screen_width / self.obstacle_amount) for num in range(self.obstacle_amount)]
        self.create_multiple_obstacles(*self.obstacle_x_positions, x_start=screen_width / 15, y_start=480)

        # Alien setup
        self.aliens = pygame.sprite.Group()
        self.alien_lasers = pygame.sprite.Group()
        self.alien_setup(rows=1, cols=1)
        self.alien_direction = 1

        # Extra alien setup
        self.extra = pygame.sprite.GroupSingle()
        self.extra_spawn_time = randint(40, 80)

        # Game state
        self.game_active = True
        self.game_over = False  # Reset game over state
        self.game_won = False  # Reset victory state

        # Audio
        music = pygame.mixer.Sound('./audio/music.wav')
        music.set_volume(0.2)
        music.play(loops=-1)
        self.laser_sound = pygame.mixer.Sound('./audio/laser.wav')
        self.laser_sound.set_volume(0.5)
        self.explosion_sound = pygame.mixer.Sound('./audio/explosion.wav')
        self.explosion_sound.set_volume(0.3)

    def display_home_screen(self):
        if self.home_screen_frames:
            screen.blit(self.home_screen_frames[self.current_frame], (0, 0))
            self.current_frame += 1
            if self.current_frame >= len(self.home_screen_frames):
                self.current_frame = 0
            
    def create_obstacle(self, x_start, y_start, offset_x):
        for row_index, row in enumerate(self.shape):
            for col_index, col in enumerate(row):
                if col == 'x':
                    x = x_start + col_index * self.block_size + offset_x
                    y = y_start + row_index * self.block_size
                    block = Block(self.block_size, (255, 153, 0), x, y)
                    self.blocks.add(block)

    def create_multiple_obstacles(self, *offset, x_start, y_start):
        for offset_x in offset:
            self.create_obstacle(x_start, y_start, offset_x)

    def alien_setup(self, rows, cols, x_distance=60, y_distance=48, x_offset=70, y_offset=100):
        for row_index in range(rows):
            for col_index in range(cols):
                x = col_index * x_distance + x_offset
                y = row_index * y_distance + y_offset
                alien_sprite = Alien('yellow' if row_index == 0 else 'green' if row_index <= 2 else 'red', x, y)
                self.aliens.add(alien_sprite)

    def alien_position_checker(self):
        all_aliens = self.aliens.sprites()
        for alien in all_aliens:
            if alien.rect.right >= screen_width:
                self.alien_direction = -1
                self.alien_move_down(2)
            elif alien.rect.left <= 0:
                self.alien_direction = 1
                self.alien_move_down(2)

    def alien_move_down(self, distance):
        if self.aliens:
            for alien in self.aliens.sprites():
                alien.rect.y += distance

    def alien_shoot(self):
        if self.aliens.sprites():
            random_alien = choice(self.aliens.sprites())
            laser_sprite = Laser(random_alien.rect.center, 6, screen_height)
            self.alien_lasers.add(laser_sprite)
            self.laser_sound.play()

    def extra_alien_timer(self):
        self.extra_spawn_time -= 1
        if self.extra_spawn_time <= 0:
            self.extra.add(Extra(choice(['right', 'left']), screen_width))
            self.extra_spawn_time = randint(400, 800)

    def collision_checks(self):
        if self.player.sprite.lasers:
            for laser in self.player.sprite.lasers:
                if pygame.sprite.spritecollide(laser, self.blocks, True):
                    laser.kill()
                aliens_hit = pygame.sprite.spritecollide(laser, self.aliens, True)
                if aliens_hit:
                    for alien in aliens_hit:
                        self.score += alien.value
                    laser.kill()
                    self.explosion_sound.play()
                if pygame.sprite.spritecollide(laser, self.extra, True):
                    self.score += 500
                    laser.kill()

        if self.alien_lasers:
            for laser in self.alien_lasers:
                if pygame.sprite.spritecollide(laser, self.blocks, True):
                    laser.kill()
                if pygame.sprite.spritecollide(laser, self.player, False):
                    laser.kill()
                    self.lives -= 1
                    if self.lives <= 0:
                        self.game_active = False

        if self.aliens:
            for alien in self.aliens:
                pygame.sprite.spritecollide(alien, self.blocks, True)
                if pygame.sprite.spritecollide(alien, self.player, False):
                    self.game_active = False

    def display_lives(self):
        for live in range(self.lives - 1):
            x = self.live_x_start_pos + (live * (self.live_surf.get_size()[0] + 10))
            screen.blit(self.live_surf, (x, 8))

    def display_score(self):
        score_surf = self.font.render(f'score: {self.score}', False, 'white')
        score_rect = score_surf.get_rect(topleft=(10, -10))
        screen.blit(score_surf, score_rect)

    def display_home_screen(self):
        if self.home_screen_frames:
            screen.blit(self.home_screen_frames[self.current_frame], (0, 0))
            self.current_frame += 1
            if self.current_frame >= len(self.home_screen_frames):
                self.current_frame = 0

    def victory_message(self):
        if not self.aliens.sprites():
            victory_surf = self.font.render('You have won a special prize.', False, 'white')
            victory_rect = victory_surf.get_rect(center=(screen_width / 2, screen_height / 2))
            screen.blit(victory_surf, victory_rect)
            self.game_won = True  # Set the game won flag

    def game_over_screen(self):
        score_surf = self.font.render(f'score: {self.score}', False, 'white')
        score_rect = score_surf.get_rect(topleft=(10, -10))
        screen.blit(score_surf, score_rect)

        game_over_surf = self.font.render('Game Over. But you still get a special prize!', False, 'white')
        game_over_rect = game_over_surf.get_rect(center=(screen_width / 2, screen_height / 2))
        screen.blit(game_over_surf, game_over_rect)

        restart_surf = self.font.render('TAP or SPACE to return to Home', False, 'white')
        restart_rect = restart_surf.get_rect(center=(screen_width / 2, screen_height / 2 + 50))
        screen.blit(restart_surf, restart_rect)

    def run(self):
        if self.game_active:
            # Normal game running logic...
            self.player.update()
            self.alien_lasers.update()
            self.extra.update()
            self.aliens.update(self.alien_direction)
            self.alien_position_checker()
            self.extra_alien_timer()
            self.collision_checks()

            self.player.sprite.lasers.draw(screen)
            self.player.draw(screen)
            self.blocks.draw(screen)
            self.aliens.draw(screen)
            self.alien_lasers.draw(screen)
            self.extra.draw(screen)
            self.display_lives()
            self.display_score()
            self.victory_message()
            if not self.game_active and not self.game_won:
                self.game_over_screen()  # Show game over screen
        else:
            self.display_home_screen()

if __name__ == '__main__':
    pygame.init()

    screen_info = pygame.display.Info()
    screen_width = screen_info.current_w
    screen_height = screen_info.current_h
    screen = pygame.display.set_mode((screen_width, screen_height), pygame.FULLSCREEN)

    background = pygame.image.load('./graphics/background.png').convert()
    background = pygame.transform.scale(background, (screen_width, screen_height))
    
    # Create a semi-transparent black surface
    overlay = pygame.Surface((screen_width, screen_height))
    overlay.fill((0, 0, 0))  # Fill it with black
    overlay.set_alpha(25)  # Set the alpha value (10% opacity)

    clock = pygame.time.Clock()
    game = Game()
    
    ALIENLASER = pygame.USEREVENT + 1
    pygame.time.set_timer(ALIENLASER, 700)

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == ALIENLASER and game.game_active:
                game.alien_shoot()
            # Handle home screen actions
            if not game.game_active:
                game.display_home_screen()
                if event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
                    game.reset_game()  # Restart the game when space is pressed
                if event.type == pygame.MOUSEBUTTONDOWN:  # On tap (mouse click)
                    game.reset_game()  # Restart the game

            # Check for game won condition
            if game.game_won:
                game.display_home_screen()
                if event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
                    game.reset_game()  # Reset the game when space is pressed
                    game.game_won = False  # Reset the victory flag
            
            # Check for game over condition
            if not game.game_active and event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
                game.reset_game()  # Reset the game if game over and space is pressed
            if not game.game_active and event.type == pygame.MOUSEBUTTONDOWN:  # On tap (mouse click)
                game.reset_game()  # Reset the game if game over and mouse is clicked

        screen.blit(background, (0, 0))
        if game.game_active:
            game.run()
        else:
            game.display_home_screen()  # Show home screen when game is not active

        pygame.display.flip()
        game.clock.tick(60)