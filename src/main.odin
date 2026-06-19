package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

DEBUG :: false

GAME_SIZE :: 9 // master size

GAME_AREA :: GAME_SIZE * GAME_SIZE
CELL_SIZE :: WIN_SIZE / GAME_SIZE
WIN_SIZE :: GAME_SIZE * 80
BOMB_AMT :: (GAME_SIZE * 10) / 8 // difficulty scales with GAME_SIZE

#assert(WIN_SIZE % GAME_SIZE == 0)

GameState :: enum {
    PLAY,
    LOSE,
    WIN,
}

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
    hovered:       bool, // cursor hover ui signal
    neighbors:     [8]CellPos, // positions of neighbors
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

update :: proc(cl: ^[GAME_AREA]Cell) -> (Cell, GameState) {
    mousePoint := rl.GetMousePosition()

    cr := Cell{}
    for &c in cl {
        if (rl.CheckCollisionPointRec(mousePoint, c.rect)) {
            c.hovered = true

            if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
                c.state = CellState.OPENED
                if c.is_bomb {return c, GameState.LOSE}
                cr = c; break
            }

            if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
                c.state =
                CellState.FLAGGED if c.state == CellState.UNOPENED else CellState.UNOPENED
            }

        } else {
            c.hovered = false
        }
    }
    return cr, GameState.PLAY
}

check_win :: proc(cl: ^[GAME_AREA]Cell) -> bool {
    for &c in cl {
        if c.is_bomb {
            if c.state == CellState.UNOPENED || c.state == CellState.FLAGGED {
                continue
            } else {
                panic("the program is not supposed to be here")
            }
        }
        if c.state == CellState.OPENED {
            continue
        }
        if c.state == CellState.UNOPENED || c.state == CellState.FLAGGED {
            return false
        }
    }
    return true
}

main :: proc() {
    cl := init_cells()

    rl.InitWindow(WIN_SIZE, WIN_SIZE, "mina")
    rl.SetTargetFPS(20)
    state := GameState.PLAY

    for !rl.WindowShouldClose() {

        // update -------------------------------------------------------------
        if state == GameState.PLAY {
            cr := Cell{}
            cr, state = update(&cl)
            auto_open_neighboring_cells(&cr, &cl)
        }

        // drawing ------------------------------------------------------------

        rl.BeginDrawing()

        rl.ClearBackground(rl.DARKGRAY)

        for c in cl {draw_cell(c)}

        if DEBUG {
            fps := rl.GetFPS()
            text := fmt.tprint(fps)
            rl.DrawText(strings.clone_to_cstring(text), 0, 0, 20, rl.PURPLE)
        }

        if check_win(&cl) || state == GameState.WIN {
            draw_end_text("You win!", state)
            state = GameState.WIN
        }
        if state == GameState.LOSE {
            draw_end_text("You exploded!", state)
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}
