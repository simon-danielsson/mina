package main

import "core:strings"
import rl "vendor:raylib"

DRAW_DEBUG_TEXT_ON_CELLS :: false

GAME_SIZE :: 9 // master size

GAME_AREA :: GAME_SIZE * GAME_SIZE
CELL_SIZE :: WIN_SIZE / GAME_SIZE
WIN_SIZE :: GAME_SIZE * 80
BOMB_AMT :: (GAME_SIZE * 10) / 8 // difficulty scales with GAME_SIZE

#assert(WIN_SIZE % GAME_SIZE == 0)

CellState :: enum {
    UNOPENED,
    OPENED,
    FLAGGED,
}

CellPos :: struct {
    row: int,
    col: int,
}

Cell :: struct {
    id:            int,
    state:         CellState,
    is_bomb:       bool,
    bombs_closeby: int,
    rect:          rl.Rectangle,
    cell_pos:      CellPos, // pos on the game grid
    hovered:       bool,
    neighbors:     [8]CellPos,
}

auto_open_neighboring_cells :: proc(c: ^Cell, cl: ^[GAME_AREA]Cell) {
    if c.is_bomb {return}
    c.state = CellState.OPENED
    for pos in cl[c.id].neighbors {
        for &cn in cl {
            if cn.is_bomb {continue}
            if cn.cell_pos == pos {
                if cn.state != CellState.FLAGGED {
                    cn.state = CellState.OPENED
                }
            }
        }
    }
}

update :: proc(cl: ^[GAME_AREA]Cell) -> (Cell, bool) {
    mousePoint := rl.GetMousePosition()
    btnAction := false

    cr := Cell{}
    for &c in cl {
        if (rl.CheckCollisionPointRec(mousePoint, c.rect)) {
            c.hovered = true

            if c.state == CellState.UNOPENED || c.state == CellState.FLAGGED {
                if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
                    c.state = CellState.OPENED
                    if c.is_bomb {return c, true}
                    cr = c; break
                }

                if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
                    c.state = CellState.FLAGGED
                }
            }
        } else {
            c.hovered = false
        }
    }
    return cr, false
}

main :: proc() {
    cl := init_cells()

    rl.InitWindow(WIN_SIZE, WIN_SIZE, "mina")

    game_over := false

    for !rl.WindowShouldClose() {

        // update -------------------------------------------------------------
        cr := Cell{}
        if !game_over {
            cr, game_over = update(&cl)
            auto_open_neighboring_cells(&cr, &cl)
        }

        // drawing ------------------------------------------------------------

        rl.BeginDrawing()

        rl.ClearBackground(rl.DARKGRAY)

        for c in cl {
            draw_cell(c)
        }

        if game_over {
            text := strings.clone_to_cstring("You exploded!")
            font_size: i32 = WIN_SIZE / 12
            text_w := rl.MeasureText(text, font_size)
            rl.DrawText(text, (WIN_SIZE / 2) - text_w / 2, WIN_SIZE / 2, font_size, rl.BLACK)
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}
