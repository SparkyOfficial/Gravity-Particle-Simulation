use std::time::Instant;
use macroquad::prelude::*;

const SCREEN_WIDTH: f32 = 800.0;
const SCREEN_HEIGHT: f32 = 600.0;
const G: f32 = 0.1;
const DT: f32 = 0.1;
const NUM_PARTICLES: usize = 50;

#[derive(Clone)]
struct Particle {
    x: f32,
    y: f32,
    vx: f32,
    vy: f32,
    ax: f32,
    ay: f32,
    mass: f32,
    radius: f32,
}

impl Particle {
    fn new(x: f32, y: f32, vx: f32, vy: f32, mass: f32) -> Self {
        let radius = (mass / 5.0).max(2.0);
        Particle { x, y, vx, vy, ax: 0.0, ay: 0.0, mass, radius }
    }
    
    fn update(&mut self, dt: f32) {
        self.vx += self.ax * dt;
        self.vy += self.ay * dt;
        self.x += self.vx * dt;
        self.y += self.vy * dt;
    }
}

struct GravitySimulation {
    particles: Vec<Particle>,
    step_count: usize,
    start_time: Instant,
    finished: bool,
    execution_time: Option<f32>,
}

impl GravitySimulation {
    fn new() -> Self {
        let mut particles = Vec::with_capacity(NUM_PARTICLES);
        
        for _ in 0..NUM_PARTICLES {
            let x = rand::gen_range(50.0, SCREEN_WIDTH - 50.0);
            let y = rand::gen_range(50.0, SCREEN_HEIGHT - 50.0);
            let vx = rand::gen_range(-1.0, 1.0);
            let vy = rand::gen_range(-1.0, 1.0);
            let mass = rand::gen_range(10.0, 50.0);
            particles.push(Particle::new(x, y, vx, vy, mass));
        }
        
        GravitySimulation {
            particles,
            step_count: 0,
            start_time: Instant::now(),
            finished: false,
            execution_time: None,
        }
    }
    
    fn update(&mut self) {
        if self.finished {
            return;
        }
        
        for p in &mut self.particles {
            p.ax = 0.0;
            p.ay = 0.0;
        }
        
        for i in 0..self.particles.len() {
            for j in (i + 1)..self.particles.len() {
                let dx = self.particles[j].x - self.particles[i].x;
                let dy = self.particles[j].y - self.particles[i].y;
                let mut distance = (dx * dx + dy * dy).sqrt();
                
                if distance < 5.0 {
                    distance = 5.0;
                }
                
                let force = G * self.particles[i].mass * self.particles[j].mass / (distance * distance);
                let fx = force * dx / distance;
                let fy = force * dy / distance;
                
                self.particles[i].ax += fx / self.particles[i].mass;
                self.particles[i].ay += fy / self.particles[i].mass;
                self.particles[j].ax -= fx / self.particles[j].mass;
                self.particles[j].ay -= fy / self.particles[j].mass;
            }
        }
        
        for p in &mut self.particles {
            p.update(DT);
            
            if p.x <= p.radius || p.x >= SCREEN_WIDTH - p.radius {
                p.vx = -p.vx * 0.8;
            }
            if p.y <= p.radius || p.y >= SCREEN_HEIGHT - p.radius {
                p.vy = -p.vy * 0.8;
            }
            
            p.x = p.x.max(p.radius).min(SCREEN_WIDTH - p.radius);
            p.y = p.y.max(p.radius).min(SCREEN_HEIGHT - p.radius);
        }
        
        self.step_count += 1;
        
        if self.step_count > 1000 {
            self.finished = true;
            self.execution_time = Some(self.start_time.elapsed().as_secs_f32());
        }
    }
    
    fn draw(&self) {
        clear_background(BLACK);
        
        for p in &self.particles {
            let color_value = (p.mass * 5.0).min(255.0) as u8;
            let color = Color::new(
                color_value as f32 / 255.0,
                (color_value / 2) as f32 / 255.0,
                (255 - color_value / 3) as f32 / 255.0,
                1.0
            );
            draw_circle(p.x, p.y, p.radius, color);
        }
        
        draw_text(&format!("Particles: {}", self.particles.len()), 10.0, 20.0, 20.0, WHITE);
        draw_text(&format!("Step: {}", self.step_count), 10.0, 40.0, 20.0, WHITE);
        
        if self.finished {
            if let Some(exec_time) = self.execution_time {
                let avg_time = (exec_time / self.step_count as f32) * 1000.0;
                draw_text("Simulation completed!", 10.0, 60.0, 20.0, GREEN);
                draw_text(&format!("Execution time: {:.4} seconds", exec_time), 10.0, 80.0, 20.0, WHITE);
                draw_text(&format!("Average time per step: {:.4} ms", avg_time), 10.0, 100.0, 20.0, WHITE);
            }
        }
    }
}

#[macroquad::main("Gravity Particle Simulation")]
async fn main() {
    println!("Gravity Particle Simulation in Rust");
    println!("Particles: {}", NUM_PARTICLES);
    
    let mut simulation = GravitySimulation::new();
    
    loop {
        if is_key_down(KeyCode::Escape) {
            break;
        }
        
        simulation.update();
        simulation.draw();
        
        next_frame().await;
        
        std::thread::sleep(std::time::Duration::from_millis(16));
    }
    
    if simulation.finished {
        if let Some(exec_time) = simulation.execution_time {
            let avg_time = (exec_time / simulation.step_count as f32) * 1000.0;
            println!("Simulation completed!");
            println!("Execution time: {:.4} seconds", exec_time);
            println!("Average time per step: {:.4} ms", avg_time);
        }
    }
}