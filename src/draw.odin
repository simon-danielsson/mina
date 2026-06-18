package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

draw_end_text :: proc(s: string) {
    text := strings.clone_to_cstring(s)
    font_size: i32 = WIN_SIZE / 12
    text_w := rl.MeasureText(text, font_size)
    rl.DrawText(text, (WIN_SIZE / 2) - text_w / 2, WIN_SIZE / 2, font_size, rl.BLACK)
}

draw_cell :: proc(c: Cell) {
    color := rl.GRAY
    if c.hovered {
        color = rl.ColorAlpha(color, 0.85)
    }
    if c.state == CellState.OPENED {
        color = rl.ColorAlpha(color, 0.6)
    }
    border_col := rl.ColorAlpha(rl.DARKGRAY, 0.9)
    border_thickness := i32(CELL_SIZE) / 20

    // border
    rl.DrawRectangle(i32(c.rect.x), i32(c.rect.y), CELL_SIZE, CELL_SIZE, border_col)

    // body
    rl.DrawRectangle(
        i32(c.rect.x + f32(border_thickness)),
        i32(c.rect.y + f32(border_thickness)),
        CELL_SIZE - border_thickness,
        CELL_SIZE - border_thickness,
        color,
    )

    if c.state == CellState.FLAGGED {
        // stick
        flag_len: f32 = CELL_SIZE / 2
        rl.DrawLineEx(
            startPos = rl.Vector2{c.rect.x + flag_len, c.rect.y + (flag_len / 2)},
            endPos = rl.Vector2{c.rect.x + flag_len, c.rect.y + CELL_SIZE - (flag_len / 2)},
            thick = flag_len / 8,
            color = rl.ColorBrightness(rl.BROWN, -0.1),
        )
        // flag
        rl.DrawTriangle(
            v2 = rl.Vector2{c.rect.x + flag_len, c.rect.y + (flag_len / 2)},
            v3 = rl.Vector2{c.rect.x + flag_len, c.rect.y + (flag_len)},
            v1 = rl.Vector2 {
                c.rect.x + flag_len + (CELL_SIZE / 4),
                c.rect.y + (flag_len / 4) + (CELL_SIZE / 4),
            },
            color = rl.ColorBrightness(rl.RED, -0.22),
        )
    }

    if c.state == CellState.OPENED && c.is_bomb {
        bomb_size :: CELL_SIZE / 5
        // body
        rl.DrawCircle(
            i32(c.rect.x) + (CELL_SIZE / 2),
            i32(c.rect.y) + (CELL_SIZE / 2),
            bomb_size,
            rl.BLACK,
        )

        // sparkle
        rl.DrawCircle(
            i32(c.rect.x) + (CELL_SIZE / 2) - (CELL_SIZE / 17),
            i32(c.rect.y) + (CELL_SIZE / 2) - (CELL_SIZE / 17),
            bomb_size / 5,
            rl.LIGHTGRAY,
        )
    }

    text := fmt.tprint(c.bombs_closeby)
    if c.bombs_closeby > 0 && c.state == CellState.OPENED {
        font_size: i32 = 20
        rl.DrawText(
            strings.clone_to_cstring(text),
            i32(c.rect.x + (CELL_SIZE / 2) - f32(font_size / 2)),
            i32(c.rect.y + (CELL_SIZE / 2) - f32(font_size / 2)),
            font_size,
            rl.YELLOW,
        )
    }

    // debug text
    text = fmt.tprint(c.id)
    if DRAW_DEBUG_TEXT_ON_CELLS {
        font_size: i32 = 20
        rl.DrawText(
            strings.clone_to_cstring(text),
            i32(c.rect.x + (CELL_SIZE / 2) - f32(font_size / 2)),
            i32(c.rect.y + (CELL_SIZE / 2) - f32(font_size / 2)),
            font_size,
            rl.GREEN,
        )
    }
}
