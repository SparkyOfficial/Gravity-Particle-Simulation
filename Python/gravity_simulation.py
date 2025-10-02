import pygame
import sys
import math
import random
import time

class Particle:
    def __init__(self, x, y, vx, vy, mass):
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.ax = 0
        self.ay = 0
        self.mass = mass
        self.radius = max(2, int(mass / 2))
        
    def update(self, dt):
        self.vx += self.ax * dt
        self.vy += self.ay * dt
        self.x += self.vx * dt
        self.y += self.vy * dt
        
        if self.x <= self.radius or self.x >= WIDTH - self.radius:
            self.vx = -self.vx * 0.8
        if self.y <= self.radius or self.y >= HEIGHT - self.radius:
            self.vy = -self.vy * 0.8
            
        self.x = max(self.radius, min(WIDTH - self.radius, self.x))
        self.y = max(self.radius, min(HEIGHT - self.radius, self.y))

pygame.init()
WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Gravity Particle Simulation")
clock = pygame.time.Clock()

G = 0.5
NUM_PARTICLES = 50
DT = 0.1

particles = []
for _ in range(NUM_PARTICLES):
    x = random.uniform(50, WIDTH - 50)
    y = random.uniform(50, HEIGHT - 50)
    vx = random.uniform(-1, 1)
    vy = random.uniform(-1, 1)
    mass = random.uniform(10, 50)
    particles.append(Particle(x, y, vx, vy, mass))

start_time = time.perf_counter()

running = True
step_count = 0
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                running = False
    
    for p in particles:
        p.ax = 0
        p.ay = 0
    
    for i in range(len(particles)):
        for j in range(i + 1, len(particles)):
            p1, p2 = particles[i], particles[j]
            dx = p2.x - p1.x
            dy = p2.y - p1.y
            distance = max(5, math.sqrt(dx*dx + dy*dy))
            
            force = G * p1.mass * p2.mass / (distance * distance)
            fx = force * dx / distance
            fy = force * dy / distance
            
            p1.ax += fx / p1.mass
            p1.ay += fy / p1.mass
            p2.ax -= fx / p2.mass
            p2.ay -= fy / p2.mass
    
    for p in particles:
        p.update(DT)
    
    screen.fill((0, 0, 0))
    for p in particles:
        color = (min(255, int(p.mass * 5)), min(255, int(p.mass * 3)), min(255, int(p.mass * 2)))
        pygame.draw.circle(screen, color, (int(p.x), int(p.y)), p.radius)
    
    font = pygame.font.Font(None, 36)
    text = font.render(f"Particles: {len(particles)} Step: {step_count}", True, (255, 255, 255))
    screen.blit(text, (10, 10))
    
    pygame.display.flip()
    clock.tick(60)
    step_count += 1
    
    if step_count > 1000:
        break

end_time = time.perf_counter()
execution_time = end_time - start_time

print(f"Simulation completed!")
print(f"Execution time: {execution_time:.4f} seconds")
print(f"Average time per step: {execution_time/step_count*1000:.4f} milliseconds")

pygame.quit()
sys.exit()