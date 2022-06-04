using Random

HEIGHT = 700
WIDTH = 1200
TARGET_SPEED1 = 3.5
TARGET_SPEED2 = 1.0

MIN_RAD = 100
MAX_RAD = 320

RAD_SPEED = 4.0
ANG_SPEED = 0.02

BOOST = 2.0
DAMP = 0.1

BASE_RADIUS = 20
PWD_LENGTH = 4

SPAWN_LIMS = [400, 1100, 30, 600]
# [376, 1128, 8, 628]
MOVE_LIMS = [0, 1128, 8, 628]
CENTER = [764, 334]

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

function status_change(status, frame)
    global STATUS_LABEL
    
    if(status == "MISS")
        st = TextActor("MISS", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=220, y = 484)
    elseif(status == "HIT")
        st = TextActor("HIT", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=230, y = 484)
    end

    if frame < 20
        if frame % 2 == 0
            STATUS_LABEL = st
        else
            STATUS_LABEL = TextActor(" ", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=220, y = 484)
        end
        schedule_once(() -> status_change(status, frame + 1), 0.1)
    else
        STATUS_LABEL = TextActor("LOCATING...", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=190, y = 484)
    end
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
enemies = [Actor("enemy", time_start = time(), time_passed = 0, time_delay = rand()/2) for i in 1:20]
for enemy in enemies
    enemy.anchor = CENTER
    enemy.rad, enemy.ang = rand(MIN_RAD:MAX_RAD), 6.28 * rand()
    enemy.pos = set_target_pos!(enemy)
    enemy.speed = rand()/4
    enemy.rsize = 5.5
    enemy.status = "ACTIVE"
end

# Cross hair
target = Actor("crosshair")
target.rad, target.ang = 200, 120
target.anchor = CENTER
target.rsize = 7.0
set_target_pos!(target)

# Launch code input 
input_txt = ""
input_disp = update_inp(input_txt)

# LABEL = TextActor("$(target.x), $(target.y)", "helvetica", font_size = 18, color = Int[255, 255, 255, 255], x=target.x, y=target.y)

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
HEALTH_LABEL = TextActor("Structural Integrity: $(base_health * 20)%", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=1007, y = 80)
HEALTH_BAR = Actor("health-5", x = 1010, y = 30)

# Static elements
statics = [
    TextActor(">>> Status", "helvetica", font_size = 17, color = Int[106, 190, 48, 255], x=30, y = 484),
    TextActor(">>> Input launch code", "helvetica", font_size = 17, color = Int[106, 190, 48, 255], x=30, y=550)
    ]
    
STATUS_LABEL = TextActor("LOCATING...", "helvetica", font_size = 20, color = Int[106, 190, 48, 255], x=190, y = 484)

function on_key_down(g, key)
    global input_txt, input_disp, enemies, target, passwords, passwords_disp

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
        for enemy in enemies
            if (input_txt in passwords && collide(target, enemy))
                enemy.status = "INACTIVE"
                status_change("HIT", 0)
                # enemy_death_animation(enemy, 0)
                filter!(e->e≠enemy, enemies)

                filter!(e->e≠input_txt, passwords)
                push!(passwords, randstring(['Q', 'W', 'E', 'A', 'S', 'D'], PWD_LENGTH))
                refresh_passwords!()

                enemy_hit_count += 1
                break
            end
        end
        
        if(enemy_hit_count == 0) 
            status_change("MISS", 0)
            filter!(e->e≠input_txt, passwords)
            push!(passwords, randstring(['Q', 'W', 'E', 'A', 'S', 'D'], PWD_LENGTH))
            refresh_passwords!()
        end

        input_txt = ""
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

    global base_health, HEALTH_LABEL, HEALTH_BAR, STATUS_LABEL

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
            HEALTH_LABEL = TextActor("Structural Integrity: $(base_health * 20)%", "helvetica", font_size = 15, color = Int[106, 190, 48, 255], x=1010, y = 80)
            HEALTH_BAR = Actor("health-$(base_health)", x = 1010, y = 30)
        end
    end
    
    # global LABEL
    # LABEL = TextActor("$(target.rad), $(target.y)", "helvetica", font_size = 18, color = Int[255, 255, 255, 255], x=target.x, y=target.y)
end

function draw()
    draw(background)
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
    draw(HEALTH_LABEL)
    draw(HEALTH_BAR)
    draw(STATUS_LABEL)
end
