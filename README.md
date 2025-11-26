# LÖVE2D Mini Tutorial 🎮

Un tutorial pratico per imparare le basi di LÖVE2D, un framework per creare giochi 2D in Lua.

## 📋 Prerequisiti

1. **Installa LÖVE2D**:
   - **macOS**: `brew install love` oppure scarica da [love2d.org](https://love2d.org)
   - **Windows**: Scarica l'installer da [love2d.org](https://love2d.org)
   - **Linux**: `sudo apt install love` o equivalente per la tua distro

2. **Verifica l'installazione**:
   ```bash
   love --version
   ```

## 🚀 Come eseguire il gioco

Dalla cartella del progetto, esegui:

```bash
love .
```

Oppure su macOS puoi anche trascinare la cartella sull'icona di LÖVE.

## 🎯 Controlli

- **SPAZIO**: Inizia il gioco / Riavvia dopo game over
- **FRECCE**: Muovi il giocatore
- **ESC**: Torna al menu principale

## 📚 Concetti principali di LÖVE2D

### 1. Struttura base

LÖVE2D utilizza tre funzioni callback principali:

- **`love.load()`**: Chiamata una volta all'avvio, usata per inizializzare variabili
- **`love.update(dt)`**: Chiamata continuamente, usata per la logica del gioco
- **`love.draw()`**: Chiamata continuamente, usata per disegnare sullo schermo

### 2. File main.lua

Il file `main.lua` è il punto di ingresso del gioco. LÖVE cerca automaticamente questo file.

### 3. File conf.lua (opzionale)

Il file `conf.lua` permette di configurare il gioco (dimensioni finestra, titolo, moduli, ecc.).

### 4. Delta Time (dt)

Il parametro `dt` in `love.update(dt)` rappresenta il tempo trascorso dall'ultimo frame (in secondi).
Usalo per rendere il movimento indipendente dal framerate:

```lua
player.x = player.x + speed * dt
```

### 5. Funzioni di disegno comuni

```lua
-- Imposta il colore (RGB, valori 0-1)
love.graphics.setColor(1, 0, 0)  -- rosso

-- Disegna forme
love.graphics.circle("fill", x, y, radius)
love.graphics.rectangle("fill", x, y, width, height)
love.graphics.line(x1, y1, x2, y2)

-- Disegna testo
love.graphics.print("Testo", x, y)
love.graphics.printf("Testo centrato", x, y, width, "center")
```

### 6. Input da tastiera

```lua
-- In love.update(dt) - per input continuo
if love.keyboard.isDown("space") then
    -- Fai qualcosa
end

-- In love.keypressed(key) - per singola pressione
function love.keypressed(key)
    if key == "space" then
        -- Fai qualcosa una volta
    end
end
```

### 7. Gestione dello stato del gioco

È buona pratica usare una variabile di stato per gestire menu, gameplay, game over, ecc.

## 🎓 Esercizi per migliorare

1. **✅ Aggiungi un timer**: Fai durare il gioco 60 secondi - **COMPLETATO!**
2. **✅ Aggiungi suoni**: Usa `love.audio` per aggiungere effetti sonori - **COMPLETATO!**
3. **✅ Aggiungi immagini**: Usa `love.graphics.newImage()` per caricare sprite - **COMPLETATO!**
4. **Nemici che si muovono**: Fai muovere i nemici casualmente
5. **Power-up**: Aggiungi oggetti speciali che aumentano la velocità
6. **High score**: Salva il punteggio migliore usando `love.filesystem`

### 🕐 Timer Implementation Details

Il timer è stato implementato usando `love.timer.getTime()`:

```lua
-- Variabile globale per memorizzare l'inizio del gioco
local start = 0

-- All'inizio del gioco
start = love.timer.getTime()

-- Durante il gioco (in love.update)
if love.timer.getTime() - start >= 60 then
    gameState = "gameover"
end

-- Per mostrare il conto alla rovescia (in love.draw)
local timeLeft = math.max(0, 60 - math.floor(love.timer.getTime() - start))
love.graphics.print("Time Left: " .. timeLeft .. "s", 10, 20)
```

**Concetti chiave:**
- `love.timer.getTime()` restituisce i secondi dall'avvio del gioco
- `math.floor()` arrotonda per difetto per avere secondi interi
- `math.max(0, ...)` evita che il timer diventi negativo

**Possibili miglioramenti:**

```lua
-- Timer colorato che diventa rosso negli ultimi 10 secondi
if timeLeft <= 10 then
    love.graphics.setColor(1, 0.2, 0.2)  -- rosso
else
    love.graphics.setColor(1, 1, 1)      -- bianco
end
love.graphics.print("Time Left: " .. timeLeft .. "s", 10, 20)

-- Oppure formato mm:ss più professionale
local minutes = math.floor(timeLeft / 60)
local seconds = timeLeft % 60
love.graphics.print(string.format("Time: %02d:%02d", minutes, seconds), 10, 20)
```

### 🔊 Audio Implementation Details

Gli effetti sonori sono stati aggiunti usando `love.audio`:

```lua
-- Variabile globale per memorizzare il suono
local collisionSound = nil

-- In love.load() - carica il file audio
collisionSound = love.audio.newSource("assets/sounds/collision1.wav", "static")

-- Quando c'è una collisione - riproduci il suono
collisionSound:play()
```

**Concetti chiave:**
- `love.audio.newSource(file, type)` carica un file audio
  - `"static"` = carica tutto il file in memoria (per effetti brevi)
  - `"stream"` = carica in streaming (per musica lunga)
- `:play()` riproduce il suono
- `:stop()` ferma il suono
- `:setVolume(0.5)` imposta il volume (0.0 - 1.0)
- `:isPlaying()` controlla se il suono è in riproduzione
- `:setPitch(value)` cambia il tono (1.0 = normale, >1.0 più acuto, <1.0 più grave)

**Esempio avanzato - Allarme con pitch dinamico:**

```lua
local alarmSound = love.audio.newSource("assets/sounds/alarm.wav", "static")

-- In love.update(dt), negli ultimi 10 secondi
local timeLeft = 60 - (love.timer.getTime() - start)
if timeLeft <= 10 and not alarmSound:isPlaying() then
    -- Aumenta il pitch man mano che il tempo scende
    alarmSound:setPitch(1.0 + (10 - timeLeft) * 0.1)
    alarmSound:setVolume(0.5)
    alarmSound:play()
end
```

Questo crea un effetto di tensione crescente! Il suono diventa sempre più acuto.

### 🖼️ Sprite Implementation Details

Gli sprite vengono caricati e disegnati con rotazione e scala:

```lua
-- In love.load() - carica l'immagine
playerShipImage = love.graphics.newImage("assets/images/playerShipBlue.png")

-- In love.draw() - disegna con rotazione e scala
local imgWidth = playerShipImage:getWidth()
local imgHeight = playerShipImage:getHeight()
love.graphics.draw(
    playerShipImage,
    player.x, player.y,           -- posizione
    player.rotation,               -- rotazione in radianti
    player.scale, player.scale,    -- scala x, y
    imgWidth/2, imgHeight/2        -- origine (centro dell'immagine)
)
```

**Concetti chiave:**
- `love.graphics.newImage(path)` carica un'immagine
- `:getWidth()` e `:getHeight()` restituiscono le dimensioni
- L'**origine** determina il punto di rotazione (default: angolo in alto a sinistra)
- Impostando l'origine al centro, lo sprite ruota su se stesso

**Rotazione basata sulla direzione:**

```lua
-- Calcola l'angolo dalla direzione di movimento
local dx, dy = 0, 0
if love.keyboard.isDown("right") then dx = 1 end
if love.keyboard.isDown("left") then dx = -1 end
if love.keyboard.isDown("up") then dy = -1 end
if love.keyboard.isDown("down") then dy = 1 end

if dx ~= 0 or dy ~= 0 then
    -- math.atan2 restituisce l'angolo in radianti
    -- +pi/2 perché lo sprite punta verso l'alto (non a destra)
    player.rotation = math.atan2(dy, dx) + math.pi/2
end
```

### 🛸 Movimento Nemici - Strategie

**1. Movimento con rimbalzo (consigliato per iniziare):**

```lua
-- Nella struttura del nemico
enemy = {
    x = math.random(50, 750),
    y = math.random(50, 550),
    vx = math.random(-100, 100),  -- velocità X
    vy = math.random(-100, 100),  -- velocità Y
    speed = math.random(50, 150),
}

-- In love.update(dt)
for _, enemy in ipairs(enemies) do
    enemy.x = enemy.x + enemy.vx * dt
    enemy.y = enemy.y + enemy.vy * dt
    
    -- Rimbalza sui bordi
    if enemy.x < 0 or enemy.x > 800 then
        enemy.vx = -enemy.vx
    end
    if enemy.y < 0 or enemy.y > 600 then
        enemy.vy = -enemy.vy
    end
end
```

**2. Cambio direzione periodico:**

```lua
enemy.changeTimer = 0
enemy.changeInterval = math.random(1, 3)

-- In love.update(dt)
enemy.changeTimer = enemy.changeTimer + dt
if enemy.changeTimer >= enemy.changeInterval then
    enemy.vx = math.random(-100, 100)
    enemy.vy = math.random(-100, 100)
    enemy.changeTimer = 0
    enemy.changeInterval = math.random(1, 3)
end
```

**3. Movimento sinusoidale/ondulatorio:**

```lua
enemy.time = 0
enemy.baseY = enemy.y

-- In love.update(dt)
enemy.time = enemy.time + dt
enemy.x = enemy.x + enemy.speed * dt
enemy.y = enemy.baseY + math.sin(enemy.time * 3) * 50  -- oscilla ±50px
```

**4. Inseguimento del player:**

```lua
local dx = player.x - enemy.x
local dy = player.y - enemy.y
local dist = math.sqrt(dx*dx + dy*dy)
if dist > 0 then
    enemy.x = enemy.x + (dx/dist) * enemy.speed * dt
    enemy.y = enemy.y + (dy/dist) * enemy.speed * dt
end
```

**Formati supportati:**
- `.wav` (raccomandato per effetti sonori)
- `.ogg` (raccomandato per musica)
- `.mp3` (supportato ma meno efficiente)

**Struttura cartelle suggerita:**
```
love2d-random/
├── main.lua
├── conf.lua
└── assets/
    └── sounds/
        └── collision1.wav
```

## 📖 Risorse utili

- [Documentazione ufficiale](https://love2d.org/wiki/Main_Page)
- [Tutorial ufficiali](https://love2d.org/wiki/Category:Tutorials)
- [Game examples](https://love2d.org/wiki/Category:Games)
- [Sheepolution's How to LÖVE](https://sheepolution.com/learn/book/contents)

## 🔧 Struttura del progetto

```
love2d-random/
├── main.lua       # File principale con il codice del gioco
├── conf.lua       # Configurazione (opzionale)
├── README.md      # Questo file
└── assets/        # Risorse del gioco
    ├── sounds/    # File audio
    │   ├── collision1.wav
    │   └── alarm.wav
    └── images/    # Sprite e immagini
        ├── sfondo.png
        ├── playerShipBlue.png
        ├── ufoRed.png
        ├── ufoGreen.png
        ├── ufoBlue.png
        └── ufoYellow.png
```

## 💡 Tips

- Usa `print()` per debug - l'output apparirà nella console
- Premi `Alt+F4` (Windows/Linux) o `Cmd+Q` (macOS) per uscire
- Puoi creare un file `.love` zippando la cartella del gioco
- LÖVE usa coordinate con origine in alto a sinistra (0,0)

Buon divertimento con LÖVE2D! 🎮✨
