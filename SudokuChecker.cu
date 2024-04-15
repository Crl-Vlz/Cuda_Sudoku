
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <set>

const int board[9][9] = { {5, 3, 0, 0, 7, 0, 0, 0, 0},
                 {6, 0, 0, 1, 9, 5, 0, 0, 0},
                 {0, 9, 8, 0, 0, 0, 0, 6, 0},
                 {8, 0, 0, 0, 6, 0, 0, 0, 3},
                 {4, 0, 0, 8, 0, 3, 0, 0, 1},
                 {7, 0, 0, 0, 2, 0, 0, 0, 6},
                 {0, 6, 0, 0, 0, 0, 2, 8, 0},
                 {0, 0, 0, 4, 1, 9, 0, 0, 5},
                 {0, 0, 0, 0, 8, 0, 0, 7, 9} };

bool host_check_general(int cols, int rows) {
    if (cols != 9) {
        printf("\nBoard does not respect 9x9 format");
        return 0;
    }
    if (rows != 9) {
        printf("\nBoard does not respect 9x9 format");
        return 0;
    }
    return 1;
}

bool host_check_row(int * board, int row) {
    int starter = row * 9 ; // Passes n values to start a new row
    std::set<int> row_values;
    for (int i = 0; i < 9; i++) {
        if (board[i + starter] == 0) continue;
        if (row_values.find(board[i + starter]) != row_values.end()) return 0;
        row_values.insert(board[i + starter]);
    }
    return true;
}

bool host_check_col(int * board, int col) {
    int starter = col;
    std::set<int> col_values;
    for (int i = 0; i < 9; i++) {
        if (board[i * 9 + starter] == 0) continue;
        if (col_values.find(board[i * 9 + starter]) != col_values.end()) return 0;
        col_values.insert(board[i * 9 + starter]);
    }
    return true;
}

bool host_check_subsquare(int* board, int sub) {
    int col = (sub % 3) * 3, row = (sub / 3) * 3;
    std::set<int> square_values;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            int starter = (row + i) * 9 + col + j;
            if (board[starter] == 0) continue;
            if (square_values.find(board[starter]) != square_values.end()) return 0;
            square_values.insert(board[starter]);
        }
    }
    return 1;
}

void print_pointer(int* pointer, int size, int max_inline = -1) {
    if (max_inline <= 0) {
        for (int i = 0; i < size; i++) printf("\n%d", pointer[i]);
    }
    else {
        int flag = size / max_inline;
        int vals = size % max_inline == 0 ? flag : flag + 1;
        for (int i = 0; i < vals; i++) {
            printf("\n");
            for (int j = 0; j < max_inline; j++) {
                if (j + i * max_inline >= size) return;
                printf("%d ", pointer[j + i * max_inline]);
            }
        }
    }
}

int main()
{
    int* host_pointer;
    // 81 because sudoku boards always have 81 values
    host_pointer = (int*)malloc(sizeof(int) * 81);
    for (int i = 0; i < 81; i++) {
        int row = i / 9;
        int col = i % 9;
        host_pointer[i] = board[row][col];
    }
    bool format = true;
    for (int i = 0; i < 9; i++) {
        format = format && host_check_row(host_pointer, i);
    }
    for (int i = 0; i < 9; i++) {
        format = format && host_check_col(host_pointer, i);
    }
    for (int i = 0; i < 9; i++) {
        format = format && host_check_subsquare(host_pointer, i);
    }
    printf("\nThe format of the board is: %d", format);
    print_pointer(host_pointer, 81, 9);
}
