-- LÖVE2D Mini Tutorial
-- File principale: main.lua
-- Variabili globali
local player = {
    x = 400,
    y = 300,
    speed = 200,
    size = 50,
    rotation = 0, -- Angolo di rotazione in radianti (0 = su)
    scale = 0.5
}

local enemies = {}
local score = 0
local gameState = "menu" -- menu, playing, gameover
local start = 0
local collisionSound = nil
local alarmSound = nil
local ufoImages = {} -- Immagini degli UFO
local enemyTypes = {} -- Tipi di nemici con scale diverse

-- Funzione helper per creare un nemico casuale
local function createEnemy()
    local enemyType = enemyTypes[math.random(#enemyTypes)]
    local imgWidth = enemyType.image:getWidth()
    local size = imgWidth * enemyType.scale * 0.8 -- Hitbox all'80% della dimensione visiva
    local x = math.random(50, 750)
    local y = math.random(50, 500)  -- Margine di 100px dai bordi per l'oscillazione sinusoidale
    return {
        x = x,
        y = y,
        size = size,
        image = enemyType.image,
        scale = enemyType.scale,
        speed = math.random(30, 80),  -- Velocità orizzontale per movimento sinusoidale
        time = 0,
        baseY = y
    }
end

-- love.load() viene chiamata una sola volta all'avvio
function love.load()
    -- Imposta il titolo della finestra
    love.window.setTitle("LÖVE2D Mini Tutorial")

    -- Imposta la dimensione della finestra
    love.window.setMode(800, 600)
    collisionSound = love.audio.newSource("assets/sounds/collision1.wav", "static")
    alarmSound = love.audio.newSource("assets/sounds/alarm.wav", "static")

    -- Catica lo sfondo
    backgroundImage = love.graphics.newImage("assets/images/sfondo.png")
    -- Carica il giocatore
    playerShipImage = love.graphics.newImage("assets/images/playerShipBlue.png")
    player.size = playerShipImage:getWidth() * player.scale

    -- Carica le immagini degli UFO
    ufoImages.red = love.graphics.newImage("assets/images/ufoRed.png")
    ufoImages.green = love.graphics.newImage("assets/images/ufoGreen.png")
    ufoImages.blue = love.graphics.newImage("assets/images/ufoBlue.png")
    ufoImages.yellow = love.graphics.newImage("assets/images/ufoYellow.png")

    -- Definisci i tipi di nemici con scale diverse
    enemyTypes = {{
        image = ufoImages.red,
        scale = 0.4
    }, -- UFO rosso piccolo
    {
        image = ufoImages.green,
        scale = 0.3
    }, -- UFO verde piccolo
    {
        image = ufoImages.red,
        scale = 1.0
    }, -- UFO rosso grande
    {
        image = ufoImages.blue,
        scale = 0.5
    }, -- UFO blu medio
    {
        image = ufoImages.yellow,
        scale = 0.6
    } -- UFO giallo medio
    }

    -- Crea alcuni nemici di esempio
    for i = 1, 5 do
        table.insert(enemies, createEnemy())
    end

end

-- love.update(dt) viene chiamata continuamente, dt è il delta time
function love.update(dt)
    if gameState == "playing" then
        -- controlla se è passato un minuto dall'inizio del gioco
        if love.timer.getTime() - start >= 60 then
            gameState = "gameover"
            start = 0
        end
        -- se siamo negli ultimi 10 secondi, suona l'allarme
        local timeLeft = 60 - (love.timer.getTime() - start)
        if timeLeft <= 10 and not alarmSound:isPlaying() then
            alarmSound:setPitch(1.0 + (10 - timeLeft) * 0.1)
            alarmSound:setVolume(0.5)
            alarmSound:play()
        end
        -- Movimento del giocatore con le frecce
        local dx, dy = 0, 0
        if love.keyboard.isDown("right") then
            dx = 1
            player.x = player.x + player.speed * dt
        end
        if love.keyboard.isDown("left") then
            dx = -1
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown("up") then
            dy = -1
            player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown("down") then
            dy = 1
            player.y = player.y + player.speed * dt
        end

        -- Aggiorna la rotazione in base alla direzione
        if dx ~= 0 or dy ~= 0 then
            player.rotation = math.atan2(dy, dx) + math.pi / 2 -- +pi/2 perché lo sprite punta verso l'alto
        end

        -- Mantieni il giocatore dentro i bordi dello schermo
        player.x = math.max(player.size / 2, math.min(800 - player.size / 2, player.x))
        player.y = math.max(player.size / 2, math.min(600 - player.size / 2, player.y))

        -- Controlla collisioni con i nemici
        local hitboxRadius = player.size * 0.4 -- Hitbox più piccola per compensare aree trasparenti
        for i = #enemies, 1, -1 do
            local enemy = enemies[i]
            
            -- Movimento sinusoidale
            enemy.time = enemy.time + dt
            enemy.x = enemy.x + enemy.speed * dt
            enemy.y = enemy.baseY + math.sin(enemy.time * 3) * 50 -- oscilla di 50px
            
            -- Rimbalza orizzontalmente sui bordi
            if enemy.x < 0 or enemy.x > 800 then
                enemy.speed = -enemy.speed
            end
            
            local distance = math.sqrt((player.x - enemy.x) ^ 2 + (player.y - enemy.y) ^ 2)

            if distance < (hitboxRadius + enemy.size / 2) then
                -- Raccogli il nemico (in questo caso è un pickup)
                table.remove(enemies, i)
                score = score + 10
                collisionSound:clone():play() -- Clona per permettere suoni multipli
                -- Aggiungi un nuovo nemico
                table.insert(enemies, createEnemy())
            end
        end
    end

end

-- love.draw() viene chiamata per disegnare tutto sullo schermo
function love.draw()
    -- Disegna lo sfondo
    love.graphics.draw(backgroundImage, 0, 0)
    if gameState == "menu" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("LÖVE2D Mini Tutorial", 0, 200, 800, "center")
        love.graphics.printf("Premi SPAZIO per iniziare", 0, 250, 800, "center")
        love.graphics.printf("Usa le FRECCE per muoverti", 0, 280, 800, "center")
        love.graphics.printf("Raccogli i cerchi verdi!", 0, 310, 800, "center")

    elseif gameState == "playing" then
        -- Disegna il giocatore con rotazione
        local imgWidth = playerShipImage:getWidth()
        local imgHeight = playerShipImage:getHeight()
        love.graphics.draw(playerShipImage, player.x, player.y, -- posizione
        player.rotation, -- rotazione in radianti
        player.scale, player.scale, -- scala x, y
        imgWidth / 2, imgHeight / 2 -- origine (centro dell'immagine)
        )

        -- Disegna i nemici/pickup (UFO)
        love.graphics.setColor(1, 1, 1) -- Colore bianco per non alterare lo sprite
        for _, enemy in ipairs(enemies) do
            local imgWidth = enemy.image:getWidth()
            local imgHeight = enemy.image:getHeight()
            love.graphics.draw(enemy.image, enemy.x, enemy.y, 0, -- nessuna rotazione
            enemy.scale, enemy.scale, -- scala
            imgWidth / 2, imgHeight / 2 -- origine al centro
            )
        end

        -- Disegna il punteggio e timer
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Score: " .. score, 10, 10)
        local timeLeft = math.max(0, 60 - math.floor(love.timer.getTime() - start))
        love.graphics.print("Time Left: " .. timeLeft .. "s", 10, 20)
        love.graphics.print("ESC per tornare al menu", 10, 30)

    elseif gameState == "gameover" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over!", 0, 250, 800, "center")
        love.graphics.printf("Score finale: " .. score, 0, 280, 800, "center")
        love.graphics.printf("Premi SPAZIO per ricominciare", 0, 310, 800, "center")
    end
end

-- love.keypressed(key) viene chiamata quando si preme un tasto
function love.keypressed(key)
    if key == "space" then
        if gameState == "menu" or gameState == "gameover" then
            start = love.timer.getTime()
            -- Inizia/Riavvia il gioco
            gameState = "playing"
            score = 0
            player.x = 400
            player.y = 300

            -- Ricrea i nemici
            enemies = {}
            for i = 1, 5 do
                table.insert(enemies, createEnemy())
            end
        end
    elseif key == "escape" then
        if gameState == "playing" then
            gameState = "menu"
        end
    end
end
