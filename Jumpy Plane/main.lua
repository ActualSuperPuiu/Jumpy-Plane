setmetatable(_G, { __index = rl })
local screenWidth, screenHeight = 600, 500
local Began = false

local wallClock = os.clock()
local Walls = {}

InitWindow(screenWidth, screenHeight, "Jumpy Plane")
InitAudioDevice()

rl.InitPhysics()
SetTargetFPS(60)

local PlaneBody = CreatePhysicsBodyRectangle({screenWidth / 2, screenHeight / 2}, 40, 15, 1)

local playerImage = LoadTexture("Plane.png")
local background = LoadTexture("Background.png")
local jumpSound = LoadSound("Jump.wav")
local explodeSound = LoadSound("Explode.wav")

local logoX = screenWidth - MeasureText("Physac", 30) - 10
local logoY = 15

local function drawMenu()
    DrawText("PRESS W TO BEGIN", screenWidth / 2 - 150, screenHeight / 2 - 75, 30, GREEN)
end

local function generateWall()
    local number = math.random(0, 75)
    local data = {}
    print(number)

    local rect1 = new("Rectangle", screenWidth, 0 + number - 62, 40, 250)
    local rect2 = new("Rectangle", screenWidth, screenHeight / 2 + number + 20, 40, 255)

    data["Rect1"] = rect1
    data["Rect2"] = rect2
    Walls[#Walls + 1] = data
end

while not WindowShouldClose() do

    if IsKeyPressed(KEY_W) then
        if Began then
            PlaySound(jumpSound)
            PhysicsAddForce(PlaneBody, new("Vector2", 0, -100))
        else
            Walls = {}
            Began = true
        end
    end

    BeginDrawing()
    ClearBackground(BLACK)
    DrawTextureRec(background, new("Rectangle", 0, 0, 600, 500), new("Vector2", 0, 0), WHITE)

    DrawText("Physac", logoX, logoY, 30, WHITE)
	DrawText("Powered by", logoX + 50, logoY - 7, 10, WHITE)

    if Began then
    
    if os.clock() - wallClock > 2 then
        wallClock = os.clock()
        generateWall()
    end

    UpdatePhysics()

    for i = 1, #Walls do
        local Rect1, Rect2 = Walls[i]["Rect1"], Walls[i]["Rect2"]
        Rect1 = new("Rectangle", Rect1.x - 1, Rect1.y, Rect1.width, Rect1.height)
        Rect2 = new("Rectangle", Rect2.x - 1, Rect2.y, Rect2.width, Rect2.height)

        Walls[i]["Rect1"] = Rect1
        Walls[i]["Rect2"] = Rect2

        DrawRectangleRec(Rect1, GRAY)
        DrawRectangleRec(Rect2, GRAY)

        if CheckCollisionRecs(Rect1, new("Rectangle", PlaneBody.position.x, PlaneBody.position.y, 25, 25)) or CheckCollisionRecs(Rect2, new("Rectangle", PlaneBody.position.x, PlaneBody.position.y, 25, 25)) then
            print("Player died")
            Began = false
            PlaySound(explodeSound)
        elseif PlaneBody.position.y > screenHeight or PlaneBody.position.y < 0 then
            print("Player died")
            Began = false
            PlaySound(explodeSound)
        end
        
    end
    SetPhysicsGravity(0, 0.5)
else
    PlaneBody.position = new("Vector2", screenWidth/2, screenHeight/2)
    SetPhysicsGravity(0, 0)
    drawMenu()
end
    DrawTextureRec(playerImage, new("Rectangle", 0, 0, 40, 15), PlaneBody.position, WHITE)
    EndDrawing()
end

CloseAudioDevice()
ClosePhysics()
CloseWindow()
