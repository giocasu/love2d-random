-- conf.lua - File di configurazione per LÖVE2D
-- Questo file è opzionale ma utile per configurare il gioco

function love.conf(t)
    -- Disabilita l'alta risoluzione per evitare problemi di scala
    t.window.highdpi = true
    -- Cartella salvataggi (per high score, ecc.)
    t.identity = "love2d-random"
    -- Titolo della finestra
    t.window.title = "LÖVE2D Mini Tutorial"
    
    -- Dimensioni della finestra (usate solo se non in fullscreen)
    t.window.width = 1280
    t.window.height = 800
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    
    -- Permetti di ridimensionare la finestra
    t.window.resizable = false
    
    -- Abilita il vsync per evitare screen tearing
    t.window.vsync = 1
    
    -- Versione di LÖVE richiesta
    t.version = "11.4"
    
    -- Moduli da caricare
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
    t.modules.thread = true
    print("conf.lua caricato, identity:", t.identity)
end
