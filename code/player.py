import pygame
import math  # Import math for the sine function
from laser import Laser

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

