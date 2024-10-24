import pygame, sys
from player import Player
import obstacle
from alien import Alien, Extra
from random import choice, randint
from laser import Laser
 
class Game:
    def __init__(self):
        self.reset_game()

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
        self.shape = obstacle.shape
        self.block_size = 6
        self.blocks = pygame.sprite.Group()
        self.obstacle_amount = 4
        self.obstacle_x_positions = [num * (screen_width / self.obstacle_amount) for num in range(self.obstacle_amount)]
        self.create_multiple_obstacles(*self.obstacle_x_positions, x_start=screen_width / 15, y_start=480)

        # Alien setup
        self.aliens = pygame.sprite.Group()
        self.alien_lasers = pygame.sprite.Group()
        self.alien_setup(rows=6, cols=8)
        self.alien_direction = 1

        # Extra alien setup
        self.extra = pygame.sprite.GroupSingle()
        self.extra_spawn_time = randint(40, 80)

        # Game state
        self.game_active = True

        # Audio
        music = pygame.mixer.Sound('./audio/music.wav')
        music.set_volume(0.2)
        music.play(loops=-1)
        self.laser_sound = pygame.mixer.Sound('./audio/laser.wav')
        self.laser_sound.set_volume(0.5)
        self.explosion_sound = pygame.mixer.Sound('./audio/explosion.wav')
        self.explosion_sound.set_volume(0.3)

    def create_obstacle(self, x_start, y_start, offset_x):
        for row_index, row in enumerate(self.shape):
            for col_index, col in enumerate(row):
                if col == 'x':
                    x = x_start + col_index * self.block_size + offset_x
                    y = y_start + row_index * self.block_size
                    block = obstacle.Block(self.block_size, (255, 153, 0), x, y)
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

    def victory_message(self):
        if not self.aliens.sprites():
            victory_surf = self.font.render('You have won a special prize.', False, 'white')
            victory_rect = victory_surf.get_rect(center=(screen_width / 2, screen_height / 2))
            screen.blit(victory_surf, victory_rect)

    def game_over_screen(self):
        score_surf = self.font.render(f'score: {self.score}', False, 'white')
        score_rect = score_surf.get_rect(topleft=(10, -10))
        screen.blit(score_surf, score_rect)

        game_over_surf = self.font.render('Game Over. But you still get a special prize!', False, 'white')
        game_over_rect = game_over_surf.get_rect(center=(screen_width / 2, screen_height / 2))
        screen.blit(game_over_surf, game_over_rect)

        restart_surf = self.font.render('TAP to restart', False, 'white')
        restart_rect = restart_surf.get_rect(center=(screen_width / 2, screen_height / 2 + 50))
        screen.blit(restart_surf, restart_rect)

    def run(self):
        if self.game_active:
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
        else:
            self.game_over_screen()

if __name__ == '__main__':
    pygame.init()
    
    screen_info = pygame.display.Info()
    screen_width = screen_info.current_w
    screen_height = screen_info.current_h
    
    # Set the display mode before loading images
    screen = pygame.display.set_mode((screen_width, screen_height), pygame.FULLSCREEN)
    
    # Load and scale the background image
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
            if not game.game_active and event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
                game.reset_game()

        # Draw the background
        screen.blit(background, (0, 0))  # Blit the background at the top-left corner
        
        # Blit the semi-transparent overlay
        screen.blit(overlay, (0, 0))  # Blit the overlay at the top-left corner

        # Run the game logic
        game.run()

        pygame.display.flip()
        clock.tick(60)