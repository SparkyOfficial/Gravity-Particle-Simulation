package main

import (
	"fmt"
	"math"
	"math/rand"
	"os"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/vector"
)

const (
	screenWidth  = 800
	screenHeight = 600
	G            = 0.1
	dt           = 0.1
	numParticles = 50
)

type Particle struct {
	X, Y          float64
	VX, VY        float64
	AX, AY        float64
	Mass          float64
	Radius        float64
}

type Game struct {
	particles     []Particle
	stepCount     int
	startTime     time.Time
	simulationEnd time.Time
	finished      bool
	autoExit      bool
}

func NewGame(autoExit bool) *Game {
	rand.Seed(time.Now().UnixNano())
	
	particles := make([]Particle, numParticles)
	for i := 0; i < numParticles; i++ {
		particles[i] = Particle{
			X:      rand.Float64() * screenWidth,
			Y:      rand.Float64() * screenHeight,
			VX:     (rand.Float64() - 0.5) * 2,
			VY:     (rand.Float64() - 0.5) * 2,
			Mass:   rand.Float64()*40 + 10,
		}
		particles[i].Radius = math.Max(2, particles[i].Mass/5)
	}
	
	return &Game{
		particles: particles,
		startTime: time.Now(),
		autoExit:  autoExit,
	}
}

func (g *Game) Update() error {
	if g.finished {
		if g.autoExit {
			return ebiten.Termination
		}
		return nil
	}
	
	for i := range g.particles {
		g.particles[i].AX = 0
		g.particles[i].AY = 0
	}
	
	for i := 0; i < len(g.particles); i++ {
		for j := i + 1; j < len(g.particles); j++ {
			dx := g.particles[j].X - g.particles[i].X
			dy := g.particles[j].Y - g.particles[i].Y
			distance := math.Sqrt(dx*dx + dy*dy)
			
			if distance < 5 {
				distance = 5
			}
			
			force := G * g.particles[i].Mass * g.particles[j].Mass / (distance * distance)
			fx := force * dx / distance
			fy := force * dy / distance
			
			g.particles[i].AX += fx / g.particles[i].Mass
			g.particles[i].AY += fy / g.particles[i].Mass
			g.particles[j].AX -= fx / g.particles[j].Mass
			g.particles[j].AY -= fy / g.particles[j].Mass
		}
	}
	
	for i := range g.particles {
		p := &g.particles[i]
		p.VX += p.AX * dt
		p.VY += p.AY * dt
		p.X += p.VX * dt
		p.Y += p.VY * dt
		
		if p.X <= p.Radius || p.X >= screenWidth-p.Radius {
			p.VX = -p.VX * 0.8
		}
		if p.Y <= p.Radius || p.Y >= screenHeight-p.Radius {
			p.VY = -p.VY * 0.8
		}
		
		if p.X < p.Radius {
			p.X = p.Radius
		} else if p.X > screenWidth-p.Radius {
			p.X = screenWidth - p.Radius
		}
		
		if p.Y < p.Radius {
			p.Y = p.Radius
		} else if p.Y > screenHeight-p.Radius {
			p.Y = screenHeight - p.Radius
		}
	}
	
	g.stepCount++
	
	if g.stepCount > 1000 {
		g.finished = true
		g.simulationEnd = time.Now()
	}
	
	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	for _, p := range g.particles {
		colorValue := uint8(math.Min(255, p.Mass*5))
		vector.DrawFilledCircle(screen, float32(p.X), float32(p.Y), float32(p.Radius), 
			ebitenutil.ColorScale(colorValue, colorValue/2, 255-colorValue/3, 255), false)
	}
	
	ebitenutil.DebugPrint(screen, fmt.Sprintf("Particles: %d\nStep: %d", len(g.particles), g.stepCount))
	
	if g.finished {
		executionTime := g.simulationEnd.Sub(g.startTime)
		ebitenutil.DebugPrintAt(screen, 
			fmt.Sprintf("Simulation completed!\nExecution time: %.4f seconds\nAverage time per step: %.4f ms", 
				executionTime.Seconds(), 
				(executionTime.Seconds()/float64(g.stepCount))*1000), 
			10, 60)
	}
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return screenWidth, screenHeight
}

func main() {
	fmt.Println("Gravity Particle Simulation in Go")
	fmt.Printf("Particles: %d\n", numParticles)
	
	autoExit := false
	if len(os.Args) > 1 && os.Args[1] == "--auto-exit" {
		autoExit = true
	}
	
	ebiten.SetWindowSize(screenWidth, screenHeight)
	ebiten.SetWindowTitle("Gravity Particle Simulation")
	
	game := NewGame(autoExit)
	
	if err := ebiten.RunGame(game); err != nil && err != ebiten.Termination {
		panic(err)
	}
	
	if game.finished {
		executionTime := game.simulationEnd.Sub(game.startTime)
		fmt.Printf("Simulation completed!\n")
		fmt.Printf("Execution time: %.4f seconds\n", executionTime.Seconds())
		fmt.Printf("Average time per step: %.4f ms\n", (executionTime.Seconds()/float64(game.stepCount))*1000)
	}
}