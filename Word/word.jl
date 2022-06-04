using Random, Colors

HEIGHT = 700
WIDTH = 1200
TARGET_SPEED1 = 3.5
TARGET_SPEED2 = 1.0

MIN_RAD = 200
MAX_RAD = 330

RAD_SPEED = 4.0
ANG_SPEED = 0.02

BOOST = 2.0
DAMP = 0.1

BASE_RADIUS = 23
PWD_LENGTH = 4
# CENTER = [764, 334]
CENTER = [787, 357]

HIT_POINT = 10
MISS_POINT = -10
INVALID_POINT = -5
COMBO_MULIPLIER = 1.5

GAME_STATUS = 1

function enemy_death_animation(targetted_enemy, frame)
    global enemies
    if frame < 15
        if frame % 2 == 0
            targetted_enemy.image = "enemy_damaged.png"
        else
            targetted_enemy.image = "enemy_empty.png"
        end
        schedule_once(() -> enemy_death_animation(targetted_enemy, frame + 1), 0.02 * (15 - frame))
    else
        filter!(e->e≠targetted_enemy, enemies)
    end
end

function get_status_display(STATUS)
    if(STATUS == "LOCATING")
        st = TextActor("LOCATING...", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=190, y = 484)
    elseif(STATUS == "MISS")
        st = TextActor("MISS", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=220, y = 484)
    elseif(STATUS == "HIT")
        st = TextActor("HIT", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=230, y = 484)
    elseif(STATUS == "INVALID")
        st = TextActor("INVALID CODE", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=177, y = 484)
    end

    return st
end

function status_change(status_start, frame)
    global STATUS_LABEL, STATUS
    
    if frame < 20 && status_start == STATUS
        if frame % 2 == 0
            STATUS_LABEL = get_status_display(STATUS)
        else
            STATUS_LABEL = TextActor(" ", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=220, y = 484)
        end

        schedule_once(() -> status_change(status_start, frame + 1), 0.1)

    elseif !(status_start == STATUS)
        STATUS_LABEL = get_status_display(STATUS)
    else
        STATUS = "LOCATING"
        STATUS_LABEL = TextActor("LOCATING...", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=190, y = 484)
    end
end

function wave_change_animation(num_enemies, delay, frame)
    global enemies, WAVE_NUMBER, WAVE_NUMBER_LABEL, IS_WAVE_TRANSITION

    if frame < delay
        WAVE_NUMBER_LABEL = TextActor("Wave $(WAVE_NUMBER) in $(delay - frame) secs...", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=400, y = 30)
        schedule_once(() -> wave_change_animation(num_enemies, delay, frame + 1), 1)
    else 
        WAVE_NUMBER_LABEL = TextActor("Wave $(WAVE_NUMBER)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=400, y = 30)
        
        IS_WAVE_TRANSITION = false
        enemies = [Actor("enemy", time_start = time(), time_passed = 0, time_delay = rand()/2) for i in 1:num_enemies]
        for enemy in enemies
            enemy.anchor = CENTER
            enemy.rad, enemy.ang = rand(MIN_RAD:MAX_RAD), 6.28 * rand()
            enemy.pos = set_target_pos!(enemy)
            enemy.speed = rand()/4
            enemy.rsize = 5.5
            enemy.status = "ACTIVE"
        end
    end
end

function boom_animation(frame)
    global IS_BOOM, BOOM_CIRCLE, enemies

    if frame < 65
        BOOM_CIRCLE = Circle(CENTER..., 5 * frame)
        
        for enemy in enemies 
            if(enemy.rad <= 5 * frame && rand() < 0.1)
                filter!(e->e≠enemy, enemies)
            end
        end
        schedule_once(() -> boom_animation(frame + 1), 0.01)
    else
        BOOM_CIRCLE = nothing
        IS_BOOM = false
    end
end

function base_damage_animation(frame)
    global BASE, base_health, GAME_STATUS
    
    if frame < (12 + (base_health <= 0))
        if frame % 2 == 0
            BASE.image = "enemy_empty.png"
        else
            BASE.image = "base.png"
        end
        schedule_once(() -> base_damage_animation(frame + 1), 0.1)
    elseif base_health <= 0
        boom_animation(0)
    end

    GAME_STATUS = 0
end

function update_inp(text)
    if(text == "") text = " " end
    return TextActor(text, "helvetica", font_size = 40, color = Int[106, 190, 48, 255], x=120, y=600)
end

function set_target_pos!(target)
    target.pos = (target.anchor[1] + target.rad * cos(target.ang), target.anchor[2] + target.rad * sin(target.ang))
end

function refresh_passwords!()
    global passwords, passwords_disp
    
    passwords_disp = vcat(
    [TextActor(">>> cat super_secret_codes.txt", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=20, y=10 + 20)],
    [TextActor("------------------------------------------------------------------", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=20, y=10 + 40)],
    [TextActor("$(pwd)", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=20, y=10 + 20 * (i+2)) for (i, pwd) in enumerate(passwords)],
    [TextActor("------------------------------------------------------------------", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=20, y = 10 + 20 * (length(passwords) + 3))] 
    )
end

function is_hit(target, enemy)
    return (target.pos[1] - enemy.pos[1])^2 + (target.pos[2] - enemy.pos[2])^2 <= (target.rsize + enemy.rsize)^2
end


# Background
background = Actor("background")

# Enemies
enemies = [Actor("enemy", time_start = time(), time_passed = 0, time_delay = rand()/2) for i in 1:5]
for enemy in enemies
    enemy.anchor = CENTER
    enemy.rad, enemy.ang = rand(MIN_RAD:MAX_RAD), 6.28 * rand()
    enemy.pos = set_target_pos!(enemy)
    enemy.speed = rand()/2
    enemy.rsize = 5.5
    enemy.status = "ACTIVE"
end

# Cross hair
target = Actor("crosshair")
target.rad, target.ang = 200, 120
target.anchor = [764, 334]
target.rsize = 7.0
set_target_pos!(target)

# Launch code input 
input_txt = ""
input_disp = update_inp(input_txt)

LABEL = TextActor("$(target.x), $(target.y)", "helvetica", font_size = 18, color = Int[255, 255, 255, 255], x=target.x, y=target.y)

# Launch codes
passwords = [randstring(['Q', 'W', 'E', 'A', 'S', 'D'], PWD_LENGTH) for _ in 1:5]
passwords_disp = vcat(
    [TextActor(">>> cat super_secret_codes.txt", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=20, y=10 + 20)],
    [TextActor("------------------------------------------------------------------", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=20, y=10 + 40)],
    [TextActor("$(pwd)", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=20, y=10 + 20 * (i+2)) for (i, pwd) in enumerate(passwords)],
    [TextActor("------------------------------------------------------------------", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=20, y = 10 + 20 * (length(passwords) + 3))] 
    )

# Base health
base_health = 5
BASE = Actor("base", x = 768, y = 338)
HEALTH_LABEL = TextActor("Structural Integrity: $(base_health * 20)%", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=1007, y = 80)
HEALTH_BAR = Actor("health-5", x = 1010, y = 30)

# Static elements
statics = [
    TextActor(">>> Status", "helvetica", font_size = 17, color = Int[106, 190, 48, 255], x=30, y = 484),
    TextActor(">>> Input launch code", "helvetica", font_size = 17, color = Int[106, 190, 48, 255], x=30, y=550)
    ]

# Status bar
STATUS_LABEL = TextActor("LOCATING...", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=190, y = 484)
STATUS = "LOCATING"

# Wave counter
WAVE_NUMBER = 1
WAVE_NUMBER_LABEL = TextActor("Wave $(WAVE_NUMBER)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=400, y = 30)
IS_WAVE_TRANSITION = false

# Score variables
COMBO_COUNT = 0
SCORE = 0
SCORE_LABEL = TextActor("Score: $(SCORE)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=400, y = 610)
COMBO_LABEL = TextActor("Combo: $(COMBO_COUNT)", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=402, y = 645)

# Special ability
BOOM_COUNT = 0
BOOM_FLAG = 1
BOOM_LABEL = TextActor("$(BOOM_COUNT)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=1150, y = 645)
IS_BOOM = false
BOOM_CIRCLE = nothing

function on_key_down(g, key)
    global input_txt, input_disp, enemies, target, passwords, passwords_disp, STATUS, COMBO_COUNT, SCORE, SCORE_LABEL, COMBO_LABEL, BOOM_COUNT, BOOM_FLAG, BOOM_LABEL, IS_BOOM

    elt = string(key)
    # if letter, type
    if(length(elt) == 1 && length(input_txt) < 4)
        input_txt *= elt

    # del letters
    elseif(elt == "BACKSPACE")
        input_txt = String(chop(input_txt))
    
    # submit input 
    elseif(elt == "RETURN")
        enemy_hit_count = 0

        if !(input_txt in passwords) 
            STATUS = "INVALID"
            status_change("INVALID", 0)
            SCORE += (COMBO_COUNT^2 * COMBO_MULIPLIER + INVALID_POINT)
            COMBO_COUNT = 0 
            BOOM_FLAG = 1
        end        

        for enemy in enemies
            if (input_txt in passwords && collide(target, enemy))
                enemy.status = "INACTIVE"

                STATUS = "HIT"
                status_change("HIT", 0)
                # enemy_death_animation(enemy, 0)
                filter!(e->e≠enemy, enemies)

                filter!(e->e≠input_txt, passwords)
                push!(passwords, randstring(['Q', 'W', 'E', 'A', 'S', 'D'], PWD_LENGTH))
                refresh_passwords!()

                enemy_hit_count += 1
                COMBO_COUNT += 1
                if(COMBO_COUNT > 5 * (BOOM_FLAG))  BOOM_COUNT += 1; BOOM_FLAG +=1 end
                SCORE += HIT_POINT
                break
            end
        end
        
        if(input_txt in passwords && enemy_hit_count == 0)
            STATUS = "MISS"
            status_change("MISS", 0)
            filter!(e->e≠input_txt, passwords)
            push!(passwords, randstring(['Q', 'W', 'E', 'A', 'S', 'D'], PWD_LENGTH))
            refresh_passwords!()
            
            SCORE += (COMBO_COUNT^2 * COMBO_MULIPLIER + MISS_POINT)
            COMBO_COUNT = 0 
            BOOM_FLAG = 1
        end
        
        BOOM_LABEL = TextActor("$(BOOM_COUNT)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=1150, y = 645)
        COMBO_LABEL = TextActor("Combo: $(COMBO_COUNT)", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=402, y = 645)
        SCORE_LABEL = TextActor("Score: $(SCORE)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=400, y = 610)
        input_txt = ""

    elseif(elt == "SPACE" && !IS_BOOM)
        if(BOOM_COUNT > 0)
            IS_BOOM = true
            BOOM_COUNT -= 1
            BOOM_LABEL = TextActor("$(BOOM_COUNT)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=1150, y = 645)
            boom_animation(0)
        end
    end

    input_disp = update_inp(input_txt)
end

function update(g::Game)
    global target 

    if(g.keyboard.K_1)
        ang_sp = DAMP * ANG_SPEED
        rad_sp = DAMP * RAD_SPEED
    elseif(g.keyboard.K_2)
        ang_sp = BOOST * ANG_SPEED
        rad_sp = BOOST * RAD_SPEED
    else
        ang_sp = ANG_SPEED
        rad_sp = RAD_SPEED
    end

    if(g.keyboard.UP)
        target.rad = clamp(target.rad + rad_sp, 0, MAX_RAD)
    end
    
    if(g.keyboard.DOWN)
        target.rad = clamp(target.rad - rad_sp, 0, MAX_RAD)
    end
    
    if(g.keyboard.LEFT)
        target.ang -= ang_sp
    end

    if(g.keyboard.RIGHT)
        target.ang += ang_sp
    end

    set_target_pos!(target)

    global base_health, HEALTH_LABEL, HEALTH_BAR, STATUS_LABEL, COMBO_COUNT

    for enemy in enemies
        
        if(collide(target, enemy) && enemy.status == "ACTIVE")
            enemy.image = "enemy_selected.png"
        elseif (enemy.status == "ACTIVE")
            enemy.image = "enemy.png"
        end

        enemy.rad = clamp(enemy.rad - enemy.speed, 0, MAX_RAD)
        set_target_pos!(enemy)

        if(enemy.rad < BASE_RADIUS)
            filter!(e->e≠enemy, enemies)
            base_health = clamp(base_health - 1, 0, 5)
            base_damage_animation(0)
            HEALTH_LABEL = TextActor("Structural Integrity: $(base_health * 20)%", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=1010, y = 80)
            HEALTH_BAR = Actor("health-$(base_health)", x = 1010, y = 30)
        end
    end
    
    global WAVE_NUMBER, IS_WAVE_TRANSITION, SCORE, COMBO_LABEL, SCORE_LABEL, BOOM_COUNT, BOOM_FLAG, BOOM_LABEL

    if (length(enemies) == 0 && !IS_WAVE_TRANSITION)
        # Enemies
        IS_WAVE_TRANSITION = true
        WAVE_NUMBER += 1
        
        SCORE += (COMBO_COUNT^2 * COMBO_MULIPLIER + MISS_POINT)
        if(COMBO_COUNT >= 5 * (BOOM_FLAG))  BOOM_COUNT += 1 end
        
        COMBO_COUNT = 0
        BOOM_FLAG = 1

        COMBO_LABEL = TextActor("Combo: $(COMBO_COUNT)", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=402, y = 645)
        SCORE_LABEL = TextActor("Score: $(SCORE)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=400, y = 610)
        BOOM_LABEL = TextActor("$(BOOM_COUNT)", "helvetica", font_size = 25, color = Int[106, 190, 48, 255], x=1150, y = 645)

        wave_change_animation(5 + 2 * (WAVE_NUMBER - 1), 5, 0)
    end

    if (COMBO_COUNT == 5)

    end

    global LABEL
    LABEL = TextActor("$(target.x), $(target.y)", "helvetica", font_size = 18, color = Int[255, 255, 255, 255], x=target.x, y=target.y)
end

function draw()
    if GAME_STATUS == 1
        draw(background)
        draw(BASE)

        for enemy in enemies
            draw(enemy)
        end
        
        draw(input_disp)

        for pwd in passwords_disp
            draw(pwd)
        end

        for static in statics
            draw(static)
        end
            
        draw(target)

        draw(HEALTH_BAR)

        if !isnothing(BOOM_CIRCLE)
            draw(BOOM_CIRCLE, colorant"green")
        end

        draw(HEALTH_LABEL)
        draw(STATUS_LABEL)
        draw(WAVE_NUMBER_LABEL)
        draw(SCORE_LABEL)
        draw(COMBO_LABEL)
        draw(BOOM_LABEL)
        draw(LABEL)
        
    elseif GAME_STATUS == 0
        pass
    end
end
