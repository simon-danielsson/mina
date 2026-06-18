#+feature dynamic-literals
package main

import "core:math/rand"
import rl "vendor:raylib"

DRAW_DEBUG_TEXT_ON_CELLS :: false

GAME_SIZE :: 9 // master size
GAME_AREA :: GAME_SIZE * GAME_SIZE
WIN_SIZE :: GAME_SIZE * 80
CELL_SIZE :: WIN_SIZE / GAME_SIZE
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
    cell_pos:      CellPos,
    real_pos:      rl.Vector2,
}

init_cells :: proc() -> [GAME_AREA]Cell {
    cl := [GAME_AREA]Cell{}
    counter := 0
    bombs_planted := 0
    for row := 0; row < GAME_SIZE; row += 1 {
        for col := 0; col < GAME_SIZE; col += 1 {

            b: bool = (rand.int32_range(0, GAME_AREA)) % 7 == 0
            if counter > 10 {
                if bombs_planted == BOMB_AMT || cl[counter - 2].is_bomb {
                    b = false
                }
            }

            cl[counter] = Cell {
                id            = counter,
                bombs_closeby = 0,
                is_bomb       = b,
                state         = CellState.OPENED,
                cell_pos      = CellPos{row, col},
                real_pos      = rl.Vector2 {
                    f32(WIN_SIZE / GAME_SIZE) * f32(col),
                    f32(WIN_SIZE / GAME_SIZE) * f32(row),
                },
            }
            if cl[counter].is_bomb {
                bombs_planted += 1
            }

            counter += 1
        }
    }

    // add in more bombs in second pass (if not enough were added)
    i := GAME_AREA - 1
    for bombs_planted != BOMB_AMT {
        if cl[i].is_bomb || cl[i - 1].is_bomb || cl[i - 2].is_bomb {
            i -= 1
            continue
        }
        b: bool = (rand.int32_range(0, GAME_AREA)) % 7 == 0
        cl[i].is_bomb = b
        bombs_planted += 1
        i -= 1

    }

    assert(counter == GAME_AREA)
    assert(bombs_planted == BOMB_AMT)
    return cl
}

main :: proc() {
    cl := init_cells()

    rl.InitWindow(WIN_SIZE, WIN_SIZE, "mina")

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        for c in cl {
            draw_cell(c)
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}
