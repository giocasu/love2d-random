-- conf.lua - File di configurazione per LÖVE2D
-- Questo file è opzionale ma utile per configurare il gioco

function love.conf(t)
    -- Titolo della finestra
    t.window.title = "LÖVE2D Mini Tutorial"
    
    -- Dimensioni della finestra
    t.window.width = 800
    t.window.height = 600
    
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
end
