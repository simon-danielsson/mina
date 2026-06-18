package main

import "core:math/rand"
import rl "vendor:raylib"

calc_bombs_closeby :: proc(cl: ^[GAME_AREA]Cell) {
    for &c in cl {
        if c.is_bomb {
            continue
        }
        northwest_cell := c.id - GAME_SIZE - 1; north_cell := c.id - GAME_SIZE
        northeast_cell := c.id - GAME_SIZE + 1; west_cell := c.id - 1
        east_cell := c.id + 1; southwest_cell := c.id + GAME_SIZE - 1
        south_cell := c.id + GAME_SIZE; southeast_cell := c.id + GAME_SIZE + 1

        for &c_closeby in cl {
            if c_closeby.is_bomb {
                if c_closeby.id == north_cell ||
                    c_closeby.id == northwest_cell ||
                    c_closeby.id == west_cell ||
                    c_closeby.id == east_cell ||
                    c_closeby.id == southwest_cell ||
                    c_closeby.id == southeast_cell ||
                    c_closeby.id == south_cell ||
                    c_closeby.id == northeast_cell {
                        c.bombs_closeby += 1
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
        calc_bombs_closeby(&cl)
        return cl
    }
