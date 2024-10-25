import pygame
import math  # Import math for the sine function

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