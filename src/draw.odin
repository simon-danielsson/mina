package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

draw_cell :: proc(c: Cell) {
    color := rl.GRAY
    border_col := rl.ColorBrightness(rl.DARKGRAY, 0.5)
    border_thickness := i32(CELL_SIZE) / 20

    // border
    rl.DrawRectangle(i32(c.real_pos.x), i32(c.real_pos.y), CELL_SIZE, CELL_SIZE, border_col)

    // body
    rl.DrawRectangle(
        i32(c.real_pos.x + f32(border_thickness)),
        i32(c.real_pos.y + f32(border_thickness)),
        CELL_SIZE - border_thickness,
        CELL_SIZE - border_thickness,
        color,
    )

    if c.state == CellState.FLAGGED {
        // stick
        flag_len: f32 = CELL_SIZE / 2
        rl.DrawLineEx(
            startPos = rl.Vector2{c.real_pos.x + flag_len, c.real_pos.y + (flag_len / 2)},
            endPos = rl.Vector2 {
                c.real_pos.x + flag_len,
                c.real_pos.y + CELL_SIZE - (flag_len / 2),
            },
            thick = flag_len / 8,
            color = rl.BROWN,
        )
        // flag
        rl.DrawTriangle(
            v2 = rl.Vector2{c.real_pos.x + flag_len, c.real_pos.y + (flag_len / 2)},
            v3 = rl.Vector2{c.real_pos.x + flag_len, c.real_pos.y + (flag_len)},
            v1 = rl.Vector2 {
                c.real_pos.x + flag_len + (CELL_SIZE / 4),
                c.real_pos.y + (flag_len / 4) + (CELL_SIZE / 4),
            },
            color = rl.RED,
        )

    }

    if c.state == CellState.OPENED && c.is_bomb {
        bomb_size :: CELL_SIZE / 5
        // body
        rl.DrawCircle(
            i32(c.real_pos.x) + (CELL_SIZE / 2),
            i32(c.real_pos.y) + (CELL_SIZE / 2),
            bomb_size,
            rl.BLACK,
        )

        // sparkle
        rl.DrawCircle(
            i32(c.real_pos.x) + (CELL_SIZE / 2) - (CELL_SIZE / 17),
            i32(c.real_pos.y) + (CELL_SIZE / 2) - (CELL_SIZE / 17),
            bomb_size / 5,
            rl.LIGHTGRAY,
        )
    }

    // debug text
    text := fmt.tprint(c.id)
    if DRAW_DEBUG_TEXT_ON_CELLS {
        font_size: i32 = 20
        rl.DrawText(
            strings.clone_to_cstring(text),
            i32(c.real_pos.x + (CELL_SIZE / 2) - f32(font_size / 2)),
            i32(c.real_pos.y + (CELL_SIZE / 2) - f32(font_size / 2)),
            font_size,
            rl.GREEN,
        )

    }
}
