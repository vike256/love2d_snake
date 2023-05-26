function love.load()
    tile_size = 32
    grid_size_x = 12
    grid_size_y = 12


    function start()
        snake_body = {
            { x = 3, y = 1 },
            { x = 2, y = 1 },
            { x = 1, y = 1 },
        }
        direction_queue = {'right'}

        apple_position = {x = 0, y = 0}
        change_apple_pos()

        alive = true
        score = 0
        timer = 0
    end
    start()
end

function love.update(dt)
    timer = timer + dt
    if alive then
        if timer >= 0.15 then
            timer = 0

            if #direction_queue > 1 then
                table.remove(direction_queue, 1)
            end

            local next_x_position = snake_body[1].x
            local next_y_position = snake_body[1].y

            if direction_queue[1] == 'up' then
                next_y_position = next_y_position - 1
                if next_y_position < 0 then
                    next_y_position = grid_size_y - 1
                end
            elseif direction_queue[1] == 'down' then
                next_y_position = next_y_position + 1
                if next_y_position >= grid_size_y then
                    next_y_position = 0
                end
            elseif direction_queue[1] == 'left' then
                next_x_position = next_x_position - 1
                if next_x_position < 0 then
                    next_x_position = grid_size_x - 1
                end
            elseif direction_queue[1] == 'right' then
                next_x_position = next_x_position + 1
                if next_x_position >= grid_size_x then
                    next_x_position = 0
                end
            end

            table.insert(snake_body, 1, {
                x = next_x_position, y = next_y_position
            })

            if on_top_of_apple() then
                score = score + 1
                change_apple_pos()
            else
                table.remove(snake_body)
            end

            for i = 2, #snake_body do
                if snake_body[1].x == snake_body[i].x
                and snake_body[1].y == snake_body[i].y then
                    alive = false
                end
            end
        end
    else
        if love.keyboard.isDown('space') then
            start()
        end
    end
end

function love.draw()
    draw_grid()
    draw_apple()
    draw_snake()
    love.graphics.print(score, 0, 0)
end

function love.keypressed(key)
    if key == 'w'
    and direction_queue[#direction_queue] ~= 'up'
    and direction_queue[#direction_queue] ~= 'down' then
        table.insert(direction_queue, 'up')
    elseif key == 's'
    and direction_queue[#direction_queue] ~= 'down'
    and direction_queue[#direction_queue] ~= 'up' then
        table.insert(direction_queue, 'down')
    elseif key == 'a'
    and direction_queue[#direction_queue] ~= 'left'
    and direction_queue[#direction_queue] ~= 'right' then
        table.insert(direction_queue, 'left')
    elseif key == 'd'
    and direction_queue[#direction_queue] ~= 'right'
    and direction_queue[#direction_queue] ~= 'left' then
        table.insert(direction_queue, 'right')
    end
end

function change_apple_pos()
    local possible_apple_positions = {}

    for x_pos = 0, grid_size_x - 1 do
        for y_pos = 0, grid_size_y - 1 do
            local possible = true

            for _, piece in ipairs(snake_body) do
                if x_pos == piece.x and y_pos == piece.y then
                    possible = false
                end
            end

            if possible then
                table.insert(possible_apple_positions, {x = x_pos, y = y_pos})
            end
        end
    end

    local position = possible_apple_positions[math.random(#possible_apple_positions)]
    apple_position = position
end

function draw_grid()
    for x = 0, grid_size_x - 1 do
        for y = 0, grid_size_y - 1 do
            if (x + y) % 2 == 0 then
                love.graphics.setColor(.2, .3, .4, 1)
            else
                love.graphics.setColor(.3, .4, .5, 1)
            end
            love.graphics.rectangle('fill', x * tile_size, y * tile_size, tile_size, tile_size)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function draw_apple()
    love.graphics.setColor(.8, .3, .1, 1)
    love.graphics.circle(
        'fill',
        apple_position.x * tile_size + tile_size/2,
        apple_position.y * tile_size + tile_size/2,
        tile_size/2.5
    )
    love.graphics.setColor(1, 1, 1, 1)
end

function draw_snake()

    -- Head
    if alive then
        love.graphics.setColor(.8, .7, .6, 1)
    else
        love.graphics.setColor(.2, .2, .2, 1)
    end
    love.graphics.rectangle('fill', snake_body[1].x * tile_size, snake_body[1].y * tile_size, tile_size, tile_size)

    -- Body
    if alive then
        love.graphics.setColor(.9, .8, .7, 1)
    else
        love.graphics.setColor(.3, .3, .3, 1)
    end
    for i = 2, #snake_body do
        love.graphics.rectangle('fill', snake_body[i].x * tile_size, snake_body[i].y * tile_size, tile_size, tile_size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function on_top_of_apple()
    if snake_body[1].x == apple_position.x
    and snake_body[1].y == apple_position.y then
        return true
    else
        return false
    end
end