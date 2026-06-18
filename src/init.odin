package main

import "core:math/rand"
import rl "vendor:raylib"

get_cell_neighbors :: proc(c: ^Cell) {
    n: [8]CellPos = {}
    n[0] = CellPos { 	// northwest
        row = c.cell_pos.row - 1,
        col = c.cell_pos.col - 1,
    }
    n[1] = CellPos { 	// northeast
        row = c.cell_pos.row - 1,
        col = c.cell_pos.col + 1,
    }
    n[2] = CellPos { 	// north
        row = c.cell_pos.row - 1,
        col = c.cell_pos.col,
    }
    n[3] = CellPos { 	// west
        row = c.cell_pos.row,
        col = c.cell_pos.col - 1,
    }
    n[4] = CellPos { 	// east
        row = c.cell_pos.row,
        col = c.cell_pos.col + 1,
    }
    n[5] = CellPos { 	// southwest
        row = c.cell_pos.row + 1,
        col = c.cell_pos.col - 1,
    }
    n[6] = CellPos { 	// south
        row = c.cell_pos.row + 1,
        col = c.cell_pos.col,
    }
    n[7] = CellPos { 	// southeast
        row = c.cell_pos.row + 1,
        col = c.cell_pos.col + 1,
    }
    c.neighbors = n
}

calc_bombs_closeby :: proc(cl: ^[GAME_AREA]Cell) {
    for &c in cl {
        if c.is_bomb {
            continue
        }

        for &c_closeby in cl {
            if c_closeby.is_bomb {
                for pos in c.neighbors {
                    if c_closeby.cell_pos == pos {
                        c.bombs_closeby += 1
                    }
                }
            }
        }
    }
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
                id = counter,
                bombs_closeby = 0,
                is_bomb = b,
                rect = rl.Rectangle {
                    x = f32(WIN_SIZE / GAME_SIZE) * f32(col),
                    y = f32(WIN_SIZE / GAME_SIZE) * f32(row),
                    width = CELL_SIZE,
                    height = CELL_SIZE,
                },
                state = CellState.UNOPENED,
                cell_pos = CellPos{row, col},
                hovered = false,
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
    for &c in cl {
        get_cell_neighbors(&c)
    }
    calc_bombs_closeby(&cl)
    return cl
}
