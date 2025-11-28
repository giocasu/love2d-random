-- LÖVE2D Mini Tutorial
-- File principale: main.lua
-- Variabili globali
local SCREEN_WIDTH = 0
local SCREEN_HEIGHT = 0
local ENEMY_MARGIN = 50
local POWERUP_MARGIN = 60

local player = {
    x = SCREEN_WIDTH / 2,
    y = SCREEN_HEIGHT / 2,
    baseSpeed = 200,
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
local menuMusic = nil
local ufoImages = {} -- Immagini degli UFO
local enemyTypes = {} -- Tipi di nemici con scale diverse
local backgroundImage = nil
local gameBackgroundImage = nil
local powerUpImage = nil
local powerUp = nil
local powerUpScale = 0.5
local pickupsSinceLastPowerUp = 0
local powerUpStacks = 0
local powerUpTimer = 0
local SAVE_IDENTITY = "love2d-random"
local menuOptions = {"Gioca", "Esci"}
local menuIndex = 1
local createEnemy

-- Funzioni per caricare e salvare l'high score
local highScore = 0
local newHighScore = false

local POWERUP_SPAWN_THRESHOLD = 5
local POWERUP_DURATION = 10
local POWERUP_STACK_MAX = 3
local POWERUP_MULTIPLIER_PER_STACK = 0.2
local POWERUP_DESPAWN_TIME = 10

-- Salva l'high score su file
local function loadHighScore()
    love.filesystem.setIdentity(SAVE_IDENTITY, true)
    local contents, err = love.filesystem.read("highscore.txt")
    if contents then
        highScore = tonumber(contents) or 0
        print("High Score caricato:", highScore, "da", love.filesystem.getSaveDirectory())
    elseif err then
        print("High Score non trovato, uso 0. Dir:", love.filesystem.getSaveDirectory())
        highScore = 0
    end
end

local function saveHighScore()
    love.filesystem.setIdentity(SAVE_IDENTITY, true)
    love.filesystem.write("highscore.txt", tostring(highScore))
end

local function playMenuMusic()
    if menuMusic and not menuMusic:isPlaying() then
        menuMusic:play()
    end
end

local function stopMenuMusic()
    if menuMusic and menuMusic:isPlaying() then
        menuMusic:stop()
    end
end

local function startGame()
    stopMenuMusic()
    start = love.timer.getTime()
    gameState = "playing"
    score = 0
    player.x = SCREEN_WIDTH / 2
    player.y = SCREEN_HEIGHT / 2
    powerUp = nil
    powerUpTimer = 0
    powerUpStacks = 0
    pickupsSinceLastPowerUp = 0
    newHighScore = false
    menuIndex = 1

    enemies = {}
    for i = 1, 5 do
        table.insert(enemies, createEnemy())
    end
end

local function updateHighScore()
    if score > highScore then
        highScore = score
        saveHighScore()
        newHighScore = true
    else
        newHighScore = false
    end
end

-- Disegna l'immagine di sfondo ripetuta per coprire tutta la finestra
local function drawTiledBackground(img)
    local iw, ih = img:getWidth(), img:getHeight()
    for y = 0, SCREEN_HEIGHT - 1, ih do
        for x = 0, SCREEN_WIDTH - 1, iw do
            love.graphics.draw(img, x, y)
        end
    end
end

-- Disegna l'immagine centrata lasciando bande vuote ai lati
local function drawCenteredBackground(img)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setColor(1, 1, 1)
    local x = (SCREEN_WIDTH - img:getWidth()) / 2
    local y = (SCREEN_HEIGHT - img:getHeight()) / 2
    love.graphics.draw(img, x, y)
end

-- Genera un power-up di velocità in posizione casuale
local function spawnPowerUp()
    local x = math.random(POWERUP_MARGIN, SCREEN_WIDTH - POWERUP_MARGIN)
    local y = math.random(POWERUP_MARGIN, SCREEN_HEIGHT - POWERUP_MARGIN)
    powerUp = {
        x = x,
        y = y,
        size = powerUpImage:getWidth() * powerUpScale,
        lifetime = 0
    }
end

-- Funzione helper per creare un nemico casuale
function createEnemy()
    local enemyType = enemyTypes[math.random(#enemyTypes)]
    local imgWidth = enemyType.image:getWidth()
    local size = imgWidth * enemyType.scale * 0.8 -- Hitbox all'80% della dimensione visiva
    local x = math.random(ENEMY_MARGIN, SCREEN_WIDTH - ENEMY_MARGIN)
    local y = math.random(ENEMY_MARGIN, SCREEN_HEIGHT - ENEMY_MARGIN * 2) -- margine extra in basso per l'oscillazione sinusoidale
    return {
        x = x,
        y = y,
        size = size,
        image = enemyType.image,
        scale = enemyType.scale,
        speed = math.random(30, 80), -- Velocità orizzontale per movimento sinusoidale
        time = 0,
        baseY = y
    }
end

-- love.load() viene chiamata una sola volta all'avvio
function love.load()
    -- Imposta il titolo della finestra
    love.window.setTitle("LÖVE2D Mini Tutorial")
    -- Usa le dimensioni definite in conf.lua
    SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getWidth(), love.graphics.getHeight()
    player.x = SCREEN_WIDTH / 2
    player.y = SCREEN_HEIGHT / 2
    collisionSound = love.audio.newSource("assets/sounds/collision1.wav", "static")
    alarmSound = love.audio.newSource("assets/sounds/alarm.wav", "static")
    menuMusic = love.audio.newSource("assets/music/menuOutThere.ogg", "stream")
    menuMusic:setLooping(true)
    menuMusic:setVolume(0.4)

    -- Catica lo sfondo
    backgroundImage = love.graphics.newImage("assets/images/sfondo3.png")
    gameBackgroundImage = love.graphics.newImage("assets/images/gameBackground.png")
    -- Carica il giocatore
    playerShipImage = love.graphics.newImage("assets/images/playerShipBlue.png")
    player.size = playerShipImage:getWidth() * player.scale

    -- Carica le immagini degli UFO
    ufoImages.red = love.graphics.newImage("assets/images/ufoRed.png")
    ufoImages.green = love.graphics.newImage("assets/images/ufoGreen.png")
    ufoImages.blue = love.graphics.newImage("assets/images/ufoBlue.png")
    ufoImages.yellow = love.graphics.newImage("assets/images/ufoYellow.png")
    powerUpImage = love.graphics.newImage("assets/images/boltGold.png")

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

    -- Carica l'high score
    loadHighScore()
    playMenuMusic()
end

-- love.update(dt) viene chiamata continuamente, dt è il delta time
function love.update(dt)
    if gameState == "playing" then
        -- Aggiorna velocità del giocatore in base ai power-up attivi
        player.speed = player.baseSpeed * (1 + powerUpStacks * POWERUP_MULTIPLIER_PER_STACK)

        -- Timer del power-up attivo
        if powerUpTimer > 0 then
            powerUpTimer = powerUpTimer - dt
            if powerUpTimer <= 0 then
                powerUpTimer = 0
                powerUpStacks = 0
            end
        end

        -- controlla se è passato un minuto dall'inizio del gioco
        if love.timer.getTime() - start >= 60 then
            gameState = "gameover"
            start = 0
            updateHighScore()
            playMenuMusic()
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
        player.x = math.max(player.size / 2, math.min(SCREEN_WIDTH - player.size / 2, player.x))
        player.y = math.max(player.size / 2, math.min(SCREEN_HEIGHT - player.size / 2, player.y))

        -- Controlla collisioni con i nemici
        local hitboxRadius = player.size * 0.4 -- Hitbox più piccola per compensare aree trasparenti
        for i = #enemies, 1, -1 do
            local enemy = enemies[i]

            -- Movimento sinusoidale
            enemy.time = enemy.time + dt
            enemy.x = enemy.x + enemy.speed * dt
            enemy.y = enemy.baseY + math.sin(enemy.time * 3) * 50 -- oscilla di 50px

            -- Rimbalza orizzontalmente sui bordi
            if enemy.x < 0 or enemy.x > SCREEN_WIDTH then
                enemy.speed = -enemy.speed
            end

            local distance = math.sqrt((player.x - enemy.x) ^ 2 + (player.y - enemy.y) ^ 2)

            if distance < (hitboxRadius + enemy.size / 2) then
                -- Raccogli il nemico (in questo caso è un pickup)
                table.remove(enemies, i)
                score = score + 10
                pickupsSinceLastPowerUp = pickupsSinceLastPowerUp + 1
                collisionSound:clone():play() -- Clona per permettere suoni multipli
                -- Aggiungi un nuovo nemico
                table.insert(enemies, createEnemy())

                if pickupsSinceLastPowerUp >= POWERUP_SPAWN_THRESHOLD and not powerUp then
                    spawnPowerUp()
                    pickupsSinceLastPowerUp = 0
                end
            end
        end

        -- Gestisci power-up sul campo
        if powerUp then
            powerUp.lifetime = powerUp.lifetime + dt
            if powerUp.lifetime >= POWERUP_DESPAWN_TIME then
                powerUp = nil
                pickupsSinceLastPowerUp = 0
            else
                local distance = math.sqrt((player.x - powerUp.x) ^ 2 + (player.y - powerUp.y) ^ 2)
                if distance < (hitboxRadius + powerUp.size / 2) then
                    powerUp = nil
                    powerUpStacks = math.min(POWERUP_STACK_MAX, powerUpStacks + 1)
                    powerUpTimer = POWERUP_DURATION
                    pickupsSinceLastPowerUp = 0
                end
            end
        end
    end

end

-- love.draw() viene chiamata per disegnare tutto sullo schermo
function love.draw()
    -- Disegna lo sfondo
    love.graphics.setColor(1, 1, 1)
    if gameState == "playing" then
        drawTiledBackground(gameBackgroundImage)
    else
        drawCenteredBackground(backgroundImage)
    end
    if gameState == "menu" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("LÖVE2D Mini Tutorial", 0, 200, SCREEN_WIDTH, "center")
        love.graphics.printf("Usa FRECCE su/giù per navigare, INVIO/SPAZIO per selezionare", 0, 240, SCREEN_WIDTH,
            "center")
        for i, option in ipairs(menuOptions) do
            local y = 280 + (i - 1) * 30
            if i == menuIndex then
                love.graphics.setColor(1, 1, 0)
                love.graphics.printf("> " .. option .. " <", 0, y, SCREEN_WIDTH, "center")
            else
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(option, 0, y, SCREEN_WIDTH, "center")
            end
        end

    elseif gameState == "playing" then
        -- Disegna il giocatore con rotazione
        local imgWidth = playerShipImage:getWidth()
        local imgHeight = playerShipImage:getHeight()
        love.graphics.draw(playerShipImage, player.x, player.y, -- posizione
        player.rotation, -- rotazione in radianti
        player.scale, player.scale, -- scala x, y
        imgWidth / 2, imgHeight / 2 -- origine (centro dell'immagine)
        )

        -- Disegna il power-up se presente
        if powerUp then
            local imgWidth = powerUpImage:getWidth()
            local imgHeight = powerUpImage:getHeight()
            love.graphics.draw(powerUpImage, powerUp.x, powerUp.y, 0, powerUpScale, powerUpScale, imgWidth / 2,
                imgHeight / 2)
        end

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
        -- Mostra l'high score
        love.graphics.print("High Score: " .. highScore, SCREEN_WIDTH - 200, 10)
        love.graphics.print("Score: " .. score, 10, 10)
        local timeLeft = math.max(0, 60 - math.floor(love.timer.getTime() - start))
        love.graphics.print("Time Left: " .. timeLeft .. "s", 10, 20)
        love.graphics.print("ESC per tornare al menu", 10, 30)
        -- Icone power-up in alto a destra
        if powerUpStacks > 0 then
            local iconScale = 0.25
            local iconWidth = powerUpImage:getWidth() * iconScale
            local margin = 10
            local startX = love.graphics.getWidth() - margin - iconWidth
            local y = margin
            for i = 1, powerUpStacks do
                local x = startX - (i - 1) * (iconWidth + 4)
                love.graphics.draw(powerUpImage, x, y, 0, iconScale, iconScale)
            end
        end

    elseif gameState == "gameover" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over!", 0, 250, SCREEN_WIDTH, "center")
        love.graphics.printf("Score finale: " .. score, 0, 280, SCREEN_WIDTH, "center")
        if newHighScore then
            love.graphics.printf("Nuovo High Score: " .. highScore .. "!", 0, 310, SCREEN_WIDTH, "center")
        else
            love.graphics.printf("High Score: " .. highScore, 0, 310, SCREEN_WIDTH, "center")
        end
        love.graphics.printf("Premi SPAZIO per ricominciare", 0, 340, SCREEN_WIDTH, "center")
    end
end

-- love.keypressed(key) viene chiamata quando si preme un tasto
function love.keypressed(key)
    if gameState == "menu" then
        if key == "up" then
            menuIndex = (menuIndex - 2) % #menuOptions + 1
        elseif key == "down" then
            menuIndex = menuIndex % #menuOptions + 1
        elseif key == "return" or key == "space" then
            local selected = menuOptions[menuIndex]
            if selected == "Gioca" then
                startGame()
            elseif selected == "Esci" then
                love.event.quit()
            end
        end
    elseif gameState == "gameover" then
        if key == "space" or key == "return" then
            startGame()
        elseif key == "escape" then
            gameState = "menu"
            playMenuMusic()
        end
    elseif gameState == "playing" then
        if key == "escape" then
            gameState = "menu"
            playMenuMusic()
        end
    end
end
