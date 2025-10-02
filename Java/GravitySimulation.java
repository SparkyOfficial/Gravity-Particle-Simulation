import java.awt.*;
import java.awt.event.*;
import java.util.ArrayList;
import java.util.Random;
import javax.swing.*;

class Particle {
    double x, y;
    double vx, vy;
    double ax, ay;
    double mass;
    int radius;
    
    public Particle(double x, double y, double vx, double vy, double mass) {
        this.x = x;
        this.y = y;
        this.vx = vx;
        this.vy = vy;
        this.ax = 0;
        this.ay = 0;
        this.mass = mass;
        this.radius = Math.max(2, (int)(mass / 5));
    }
    
    public void update(double dt) {
        vx += ax * dt;
        vy += ay * dt;
        x += vx * dt;
        y += vy * dt;
    }
}

public class GravitySimulation extends JPanel implements ActionListener {
    private static final int WIDTH = 800;
    private static final int HEIGHT = 600;
    private static final double G = 0.1;
    private static final double DT = 0.1;
    private static final int NUM_PARTICLES = 50;
    
    private ArrayList<Particle> particles;
    private Timer timer;
    private int stepCount = 0;
    private long startTime;
    private boolean simulationRunning = true;
    private static boolean autoExit = false;
    
    public GravitySimulation() {
        particles = new ArrayList<>();
        Random rand = new Random();
        
        for (int i = 0; i < NUM_PARTICLES; i++) {
            double x = rand.nextDouble() * (WIDTH - 100) + 50;
            double y = rand.nextDouble() * (HEIGHT - 100) + 50;
            double vx = (rand.nextDouble() - 0.5) * 2;
            double vy = (rand.nextDouble() - 0.5) * 2;
            double mass = rand.nextDouble() * 40 + 10;
            particles.add(new Particle(x, y, vx, vy, mass));
        }
        
        timer = new Timer(16, this);
        startTime = System.nanoTime();
        timer.start();
    }
    
    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        Graphics2D g2d = (Graphics2D) g;
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        
        for (Particle p : particles) {
            int colorValue = Math.min(255, (int)(p.mass * 5));
            g2d.setColor(new Color(colorValue, colorValue/2, 255-colorValue/3));
            g2d.fillOval((int)(p.x - p.radius), (int)(p.y - p.radius), p.radius * 2, p.radius * 2);
        }
        
        g2d.setColor(Color.WHITE);
        g2d.drawString("Particles: " + particles.size(), 10, 20);
        g2d.drawString("Step: " + stepCount, 10, 40);
        
        if (!simulationRunning) {
            long endTime = System.nanoTime();
            double executionTime = (endTime - startTime) / 1_000_000_000.0;
            g2d.drawString("Simulation completed!", 10, 60);
            g2d.drawString(String.format("Execution time: %.4f seconds", executionTime), 10, 80);
            g2d.drawString(String.format("Average time per step: %.4f ms", (executionTime/stepCount)*1000), 10, 100);
            
            if (autoExit) {
                timer.stop();
                System.exit(0);
            }
        }
    }
    
    @Override
    public void actionPerformed(ActionEvent e) {
        if (!simulationRunning) return;
        
        for (Particle p : particles) {
            p.ax = 0;
            p.ay = 0;
        }
        
        for (int i = 0; i < particles.size(); i++) {
            for (int j = i + 1; j < particles.size(); j++) {
                Particle p1 = particles.get(i);
                Particle p2 = particles.get(j);
                
                double dx = p2.x - p1.x;
                double dy = p2.y - p1.y;
                double distance = Math.max(5, Math.sqrt(dx*dx + dy*dy));
                
                double force = G * p1.mass * p2.mass / (distance * distance);
                double fx = force * dx / distance;
                double fy = force * dy / distance;
                
                p1.ax += fx / p1.mass;
                p1.ay += fy / p1.mass;
                p2.ax -= fx / p2.mass;
                p2.ay -= fy / p2.mass;
            }
        }
        
        for (Particle p : particles) {
            p.update(DT);
            
            if (p.x <= p.radius || p.x >= WIDTH - p.radius) {
                p.vx = -p.vx * 0.8;
            }
            if (p.y <= p.radius || p.y >= HEIGHT - p.radius) {
                p.vy = -p.vy * 0.8;
            }
            
            p.x = Math.max(p.radius, Math.min(WIDTH - p.radius, p.x));
            p.y = Math.max(p.radius, Math.min(HEIGHT - p.radius, p.y));
        }
        
        stepCount++;
        
        if (stepCount > 1000) {
            simulationRunning = false;
            timer.stop();
        }
        
        repaint();
    }
    
    public static void main(String[] args) {
        if (args.length > 0 && args[0].equals("--auto-exit")) {
            autoExit = true;
        }
        
        JFrame frame = new JFrame("Gravity Particle Simulation");
        GravitySimulation simulation = new GravitySimulation();
        
        frame.add(simulation);
        frame.setSize(WIDTH, HEIGHT);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }
}