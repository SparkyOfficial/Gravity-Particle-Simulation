#include <iostream>
#include <vector>
#include <cmath>
#include <random>
#include <chrono>
#include <iomanip>

struct Particle {
    double x, y;
    double vx, vy;
    double ax, ay;
    double mass;
    char symbol;
};

class GravitySimulation {
private:
    std::vector<Particle> particles;
    int width, height;
    double G;
    std::mt19937 rng;
    std::uniform_real_distribution<double> pos_dist;
    std::uniform_real_distribution<double> vel_dist;
    std::uniform_real_distribution<double> mass_dist;

public:
    GravitySimulation(int w, int h, int num_particles) 
        : width(w), height(h), G(0.1), rng(std::random_device{}()), 
          pos_dist(0.0, 1.0), vel_dist(-0.5, 0.5), mass_dist(1.0, 10.0) {
        initializeParticles(num_particles);
    }

    void initializeParticles(int num_particles) {
        particles.clear();
        for (int i = 0; i < num_particles; ++i) {
            Particle p;
            p.x = pos_dist(rng) * width;
            p.y = pos_dist(rng) * height;
            p.vx = vel_dist(rng);
            p.vy = vel_dist(rng);
            p.ax = 0.0;
            p.ay = 0.0;
            p.mass = mass_dist(rng);
            
            if (p.mass < 3.0) p.symbol = '.';
            else if (p.mass < 6.0) p.symbol = 'o';
            else p.symbol = 'O';
            
            particles.push_back(p);
        }
    }

    void calculateForces() {
        for (auto& p : particles) {
            p.ax = 0.0;
            p.ay = 0.0;
        }

        for (size_t i = 0; i < particles.size(); ++i) {
            for (size_t j = i + 1; j < particles.size(); ++j) {
                double dx = particles[j].x - particles[i].x;
                double dy = particles[j].y - particles[i].y;
                double distance = std::sqrt(dx*dx + dy*dy);

                if (distance < 0.1) distance = 0.1;

                double force = G * particles[i].mass * particles[j].mass / (distance * distance);

                double fx = force * dx / distance;
                double fy = force * dy / distance;

                particles[i].ax += fx / particles[i].mass;
                particles[i].ay += fy / particles[i].mass;
                particles[j].ax -= fx / particles[j].mass;
                particles[j].ay -= fy / particles[j].mass;
            }
        }
    }

    void updateParticles(double dt) {
        for (auto& p : particles) {
            p.vx += p.ax * dt;
            p.vy += p.ay * dt;
            p.x += p.vx * dt;
            p.y += p.vy * dt;

            if (p.x <= 0 || p.x >= width) {
                p.vx = -p.vx * 0.8;
                p.x = (p.x <= 0) ? 0 : width;
            }
            if (p.y <= 0 || p.y >= height) {
                p.vy = -p.vy * 0.8;
                p.y = (p.y <= 0) ? 0 : height;
            }
        }
    }

    void simulateStep(double dt) {
        calculateForces();
        updateParticles(dt);
    }

    void display(int display_width = 80, int display_height = 25) {
        std::vector<std::vector<char>> grid(display_height, std::vector<char>(display_width, ' '));

        for (const auto& p : particles) {
            int x = static_cast<int>(p.x / width * display_width);
            int y = static_cast<int>(p.y / height * display_height);

            if (x >= 0 && x < display_width && y >= 0 && y < display_height) {
                grid[y][x] = p.symbol;
            }
        }

        std::cout << "\033[2J\033[1;1H";
        for (int y = 0; y < display_height; ++y) {
            for (int x = 0; x < display_width; ++x) {
                std::cout << grid[y][x];
            }
            std::cout << '\n';
        }
        std::cout << std::flush;
    }

    size_t getParticleCount() const {
        return particles.size();
    }
};

int main() {
    const int WIDTH = 1000;
    const int HEIGHT = 1000;
    const int NUM_PARTICLES = 100;
    const double TIME_STEP = 0.1;
    const int DISPLAY_WIDTH = 80;
    const int DISPLAY_HEIGHT = 25;
    const int SIMULATION_STEPS = 1000;

    std::cout << "Gravity Particle Simulation\n";
    std::cout << "Particles: " << NUM_PARTICLES << "\n";
    std::cout << "Simulation Steps: " << SIMULATION_STEPS << "\n\n";

    GravitySimulation sim(WIDTH, HEIGHT, NUM_PARTICLES);

    auto start_time = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < SIMULATION_STEPS; ++i) {
        sim.simulateStep(TIME_STEP);
        
        if (i % 10 == 0) {
            sim.display(DISPLAY_WIDTH, DISPLAY_HEIGHT);
            std::cout << "Step: " << i << "/" << SIMULATION_STEPS << std::endl;
        }
    }

    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);

    std::cout << "\nSimulation completed!\n";
    std::cout << "Execution time: " << duration.count() << " microseconds\n";
    std::cout << "Average time per step: " << static_cast<double>(duration.count()) / SIMULATION_STEPS << " microseconds\n";

    return 0;
}