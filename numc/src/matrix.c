#include "matrix.h"
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

// Include SSE intrinsics
#if defined(_MSC_VER)
#include <intrin.h>
#elif defined(__GNUC__) && (defined(__x86_64__) || defined(__i386__))
#include <immintrin.h>
#include <x86intrin.h>
#endif

/* Below are some intel intrinsics that might be useful
 * void _mm256_storeu_pd (double * mem_addr, __m256d a)
 * __m256d _mm256_set1_pd (double a)
 * __m256d _mm256_set_pd (double e3, double e2, double e1, double e0)
 * __m256d _mm256_loadu_pd (double const * mem_addr)
 * __m256d _mm256_add_pd (__m256d a, __m256d b)
 * __m256d _mm256_sub_pd (__m256d a, __m256d b)
 * __m256d _mm256_fmadd_pd (__m256d a, __m256d b, __m256d c)
 * __m256d _mm256_mul_pd (__m256d a, __m256d b)
 * __m256d _mm256_cmp_pd (__m256d a, __m256d b, const int imm8)
 * __m256d _mm256_and_pd (__m256d a, __m256d b)
 * __m256d _mm256_max_pd (__m256d a, __m256d b)
*/

/* Generates a random double between low and high */
double rand_double(double low, double high) {
    double range = (high - low);
    double div = RAND_MAX / range;
    return low + (rand() / div);
}

/* Generates a random matrix */
void rand_matrix(matrix *result, unsigned int seed, double low, double high) {
    srand(seed);
    for (int i = 0; i < result->rows; i++) {
        for (int j = 0; j < result->cols; j++) {
            set(result, i, j, rand_double(low, high));
        }
    }
}

/*
 * Allocates space for a matrix struct pointed to by the double pointer mat with
 * `rows` rows and `cols` columns. You should also allocate memory for the data array
 * and initialize all entries to be zeros. `parent` should be set to NULL to indicate that
 * this matrix is not a slice. You should also set `ref_cnt` to 1.
 * You should return -1 if either `rows` or `cols` or both have invalid values. Return -2 if any
 * call to allocate memory in this function fails. Remember to set the error messages in numc.c.
 * Return 0 upon success.
 */
int allocate_matrix(matrix **mat, int rows, int cols) {
	if (rows <= 0 || cols <= 0)
		return -1;
	matrix *new_matrix = (matrix*) malloc(sizeof(matrix));
	if (new_matrix == NULL)
		return -2;
	(*mat) = new_matrix;
	(*mat)->rows = rows;
	(*mat)->cols = cols;
	(*mat)->parent = NULL;
	(*mat)->ref_cnt = 1;
	(*mat)->data = (double*) calloc(sizeof(double), rows*cols);
	if ((*mat)->data == NULL)
		return -2;
	return 0;
}

/*
 * Allocates space for a matrix struct pointed to by `mat` with `rows` rows and `cols` columns.
 * Its data should point to the `offset`th entry of `from`'s data (you do not need to allocate memory)
 * for the data field. `parent` should be set to `from` to indicate this matrix is a slice of `from`.
 * You should return -1 if either `rows` or `cols` or both have invalid values. Return -2 if any
 * call to allocate memory in this function fails.
 * Remember to set the error messages in numc.c.
 * Return 0 upon success.
 */
int allocate_matrix_ref(matrix **mat, matrix *from, int offset, int rows, int cols) {
    if (rows <= 0 || cols <= 0)
		return -1;
	matrix *new_matrix = (matrix*) malloc(sizeof(matrix));
	if (new_matrix == NULL)
		return -2;
	(*mat) = new_matrix;
	(*mat)->rows = rows;
	(*mat)->cols = cols;
	(*mat)->parent = from;
    from->ref_cnt++;
	(*mat)->ref_cnt = 1;
	(*mat)->data = from->data+offset;
	return 0;
}

/*
 * You need to make sure that you only free `mat->data` if `mat` is not a slice and has no existing slices,
 * or that you free `mat->parent->data` if `mat` is the last existing slice of its parent matrix and its parent matrix has no other references
 * (including itself). You cannot assume that mat is not NULL.
 */
void deallocate_matrix(matrix *mat) {
    if (mat == NULL) {
        return;
    }
    if (mat->parent == NULL) {
        if (mat->ref_cnt == 1) {
            free(mat->data);
            free(mat);
        }
		else {
			mat->ref_cnt--;
		}
    }
    else {
        if (mat->parent->ref_cnt == 1) {
            free(mat->parent->data);
            free(mat->parent);
            free(mat);
        }
		else {
			mat->parent->ref_cnt--;
			free(mat);
		}
    }
}

/*
 * Returns the double value of the matrix at the given row and column.
 * You may assume `row` and `col` are valid.
 */
double get(matrix *mat, int row, int col) {
    return mat->data[row*mat->cols+col];
}

/*
 * Sets the value at the given row and column to val. You may assume `row` and
 * `col` are valid
 */
void set(matrix *mat, int row, int col, double val) {
    mat->data[row*mat->cols+col] = val;
}

/*
 * Sets all entries in mat to val
 */
void fill_matrix(matrix *mat, double val) {
    int mx = mat->rows * mat->cols;
	__m256d val_vec = _mm256_set1_pd(val);
    double *mat_data = mat->data;
    #pragma omp parallel for
    for (int i = 0; i < mx/4*4; i+=4) {
		_mm256_storeu_pd(mat_data+i, val_vec);
    }
	for (int i = mx/4*4; i < mx; i++) {
		mat_data[i] = val;
	}
}

/*
 * Store the result of adding mat1 and mat2 to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 */
int add_matrix(matrix *result, matrix *mat1, matrix *mat2) {
    if (result == NULL || mat1 == NULL || mat2 == NULL) {
        return -1;
    }
    if (result->rows != mat1->rows || mat2->rows != mat1->rows || result->cols != mat1->cols || mat2->cols != mat1->cols) {
        return -2;
    }
    int mx = mat1->rows * mat1->cols;
    int cap = mx/4*4;
    double *mat1_data = mat1->data;
    double *mat2_data = mat2->data;
    double *res_data = result->data;
    #pragma omp parallel for
    for (int i = 0; i < cap; i+=4) {
		__m256d tmp_vec1 = _mm256_loadu_pd(mat1_data+i);
		__m256d tmp_vec2 = _mm256_loadu_pd(mat2_data+i);
		__m256d sum_vec = _mm256_add_pd(tmp_vec1, tmp_vec2);
		_mm256_storeu_pd(res_data+i, sum_vec);
    }
	for (int i = cap; i < mx; i++) {
		(*(res_data+i)) = (*(mat1_data+i))+(*(mat2_data+i));
	}
    return 0;
}

/*
 * (OPTIONAL)
 * Store the result of subtracting mat2 from mat1 to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 */
int sub_matrix(matrix *result, matrix *mat1, matrix *mat2) {
    if (result == NULL || mat1 == NULL || mat2 == NULL) {
        return -1;
    }
    if (result->rows != mat1->rows || mat2->rows != mat1->rows || result->cols != mat1->cols || mat2->cols != mat1->cols) {
        return -2;
    }
    int mx = mat1->rows * mat1->cols;
    int cap = mx/4*4;
    #pragma omp parallel for
    for (int i = 0; i < cap; i+=4) {
		__m256d tmp_vec1 = _mm256_loadu_pd(mat1->data+i);
		__m256d tmp_vec2 = _mm256_loadu_pd(mat2->data+i);
		__m256d sub_vec = _mm256_sub_pd(tmp_vec1, tmp_vec2);
		_mm256_storeu_pd(result->data+i, sub_vec);
    }
	for (int i = cap; i < mx; i++) {
		result->data[i] = mat1->data[i]-mat2->data[i];
	}
    return 0;
}

/*
 * Store the result of multiplying mat1 and mat2 to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 * Remember that matrix multiplication is not the same as multiplying individual elements.
 */
int mul_matrix(matrix *result, matrix *mat1, matrix *mat2) {
    if (result == NULL || mat1 == NULL || mat2 == NULL) {
        return -1;
    }
    if (mat1->cols != mat2->rows || result->rows != mat1->rows || result->cols != mat2->cols) {
        return -2;
    }
    int r1 = mat1->rows, c2 = mat2->cols, c1 = mat1->cols;
    int c1_vec_cap = c1/4*4;
    // int c2_vec_cap = c2/4*4;
    double *mat1_data = mat1->data;
    double *res_data = result->data;
    /* i, j, k with transpose matrix */
    matrix *transposed;
    int ret = allocate_matrix(&transposed, c2, c1);
    if (ret != 0)
        return ret;
    double *mat2_data = transposed->data;
    double *original_mat2_data = mat2->data;
    #pragma omp parallel for
    for (int j = 0; j < c2; j++) {
        for (int k = 0; k < c1; k++) {
            mat2_data[j*c1+k] = original_mat2_data[k*c2+j];
        }
    }
    #pragma omp parallel for
    for (int i = 0; i < r1; i++) {
        double *vec2_start = mat2_data;
        double *vec1_reset_val = mat1_data+i*c1;
        double *res_start = res_data+i*c2;
        for (int j = 0; j < c2; j++) {
            __m256d sum_vec = _mm256_setzero_pd();
            double *vec1_start = vec1_reset_val;
            for (int k = 0; k < c1_vec_cap; k+=4) {
                sum_vec = _mm256_fmadd_pd(_mm256_loadu_pd(vec1_start), _mm256_loadu_pd(vec2_start), sum_vec);
                vec1_start += 4; vec2_start += 4;
            }
            double tmp_arr[4];
            _mm256_storeu_pd((__m256d*)tmp_arr, sum_vec);
            double sum = tmp_arr[0]+tmp_arr[1]+tmp_arr[2]+tmp_arr[3];
            for (int k = c1_vec_cap; k < c1; k++) {
                sum += (*vec1_start) * (*vec2_start);
                vec1_start++; vec2_start++;
            }
            (*res_start) = sum;
            res_start++;
        }
    }
    deallocate_matrix(transposed);
    /* i, k, j with pointer increments */
    // if (r1 < 100 && c2 < 100 && c1 < 100) {
    //     double *mat1_ptr = mat1_data;
    //     double *res_start = res_data;
    //     for (int i = 0; i < r1; i++) {
    //         double *mat2_ptr = mat2_data;
    //         for (int k = 0; k < c1; k++) {
    //             double *res_ptr = res_start;
    //             double mat1_val = *mat1_ptr; // constant throughout j loop
    //             __m256d mat1_vec = _mm256_set1_pd(mat1_val);
    //             for (int j = 0; j < c2_vec_cap; j+=4) {
    //                 __m256d tmp_vec = _mm256_loadu_pd(mat2_ptr);
    //                 __m256d res_vec = _mm256_loadu_pd(res_ptr);
    //                 res_vec = _mm256_fmadd_pd (mat1_vec, tmp_vec, res_vec);
    //                 _mm256_storeu_pd(res_ptr, res_vec);
    //                 mat2_ptr += 4;
    //                 res_ptr += 4;
    //             }
    //             for (int j = c2_vec_cap; j < c2; j++) {
    //                 (*res_ptr) += mat1_val * (*mat2_ptr);
    //                 mat2_ptr++;
    //                 res_ptr++;
    //             }
    //             mat1_ptr++;
    //         }
    //         mat1_ptr += c1;
    //         res_start += c2;
    //     }
    // }
    // else {
    //     #pragma omp parallel for
    //     for (int i = 0; i < r1; i++) {
    //         double *mat1_ptr = mat1_data + (i*c1);
    //         double *res_start = res_data + (i*c2);
    //         double *mat2_ptr = mat2_data;
    //         for (int k = 0; k < c1; k++) {
    //             double *res_ptr = res_start;
    //             double mat1_val = *mat1_ptr; // constant throughout j loop
    //             __m256d mat1_vec = _mm256_set1_pd(mat1_val);
    //             for (int j = 0; j < c2_vec_cap; j+=4) {
    //                 __m256d tmp_vec = _mm256_loadu_pd(mat2_ptr);
    //                 __m256d res_vec = _mm256_loadu_pd(res_ptr);
    //                 res_vec = _mm256_fmadd_pd (mat1_vec, tmp_vec, res_vec);
    //                 _mm256_storeu_pd(res_ptr, res_vec);
    //                 mat2_ptr += 4;
    //                 res_ptr += 4;
    //             }
    //             for (int j = c2_vec_cap; j < c2; j++) {
    //                 (*res_ptr) += mat1_val * (*mat2_ptr);
    //                 mat2_ptr++;
    //                 res_ptr++;
    //             }
    //             mat1_ptr++;
    //         }
    //     }
    // }
	
    /* i, k, j */
    // #pragma omp parallel for
    // for (int i = 0; i < r1; i++) {
	// 	double *res_start = result->data+(i*c2);
	// 	for (int k = 0; k < c1; k++) {
	// 		double mat1_val = mat1->data[i*c1+k]; // constant throughout j loop
	// 		double *mat2_start = mat2->data+(k*c2);
	// 		__m256d mat1_vec = _mm256_set1_pd(mat1_val);
	// 		for (int j = 0; j < c2_vec_cap; j+=4) {
	// 			__m256d tmp_vec = _mm256_loadu_pd(mat2_start+j);
	// 			__m256d res_vec = _mm256_loadu_pd(res_start+j);
	// 			res_vec = _mm256_fmadd_pd (mat1_vec, tmp_vec, res_vec);
	// 			_mm256_storeu_pd(res_start+j, res_vec);
	// 		}
	// 		for (int j = c2_vec_cap; j < c2; j++) {
	// 			result->data[i*c2+j] += mat1_val * mat2->data[k*c2+j];
	// 		}
	// 	}
    // }
    /* i, j, k */
    // #pragma omp parallel for
    // for (int i = 0; i < r1; i++) {
    //     for (int j = 0; j < c2; j++) {
    //         __m256d sum_vec = _mm256_set1_pd(0);
    //         double *vec1_start = mat1->data+i*c1;
    //         // double *vec2_start = mat2->data+j;
    //         for (int k = 0; k < c1_vec_cap; k+=4) {
    //             __m256d vec1 = _mm256_loadu_pd(vec1_start+k);
    //             __m256d vec2 = _mm256_set_pd(mat2->data[(k+3)*c2+j], mat2->data[(k+2)*c2+j], mat2->data[(k+1)*c2+j], mat2->data[k*c2+j]);
    //             sum_vec = _mm256_fmadd_pd(vec1, vec2, sum_vec);
    //         }
    //         double tmp_arr[4];
    //         _mm256_storeu_pd((__m256d*)tmp_arr, sum_vec);
    //         double sum = tmp_arr[0]+tmp_arr[1]+tmp_arr[2]+tmp_arr[3];
    //         for (int k = c1_vec_cap; k < c1; k++) {
    //             sum += mat1->data[i*c1+k] * mat2->data[k*c2+j];
    //         }
    //         result->data[i*c2+j] = sum;
    //     }
    // }
    return 0;
}

/*
 * Store the result of raising mat to the (pow)th power to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 * Remember that pow is defined with matrix multiplication, not element-wise multiplication.
 */
int pow_matrix(matrix *result, matrix *mat, int pow) {
    /*
    if (mat->rows != mat->cols || result->rows != mat->rows || result->cols != mat->cols)
        return -1;
    if (pow == 0) {
        fill_matrix(result, 0);
        for (int i = 0; i < mat->rows; i++) {
            set(result, i, i, 1);
        }
        return 0;
    }
    matrix *mul_mat;
    int ret = allocate_matrix(&mul_mat, mat->rows, mat->cols);
    if (ret != 0)
        return ret;
    ret = pow_matrix(mul_mat, mat, pow/2);
    if (ret != 0)
        return ret;
    ret = mul_matrix(result, mul_mat, mul_mat);
    if (ret != 0)
        return ret;
    if (pow % 2 == 1) {
        ret = mul_matrix(mul_mat, result, mat);
        if (ret != 0)
            return ret;
        copy(result, mul_mat);
    }
    deallocate_matrix(mul_mat);
    return 0;
    */
    if (mat->rows != mat->cols || result->rows != mat->rows || result->cols != mat->cols)
        return -3;
    fill_matrix(result, 0);
    int s = mat->rows;
    double *res_data = result->data;
    #pragma omp parallel for
    for (int i = 0; i < s; i++) {
        *(res_data+i*(s+1)) = 1;
    }
    matrix *mul_mat;
    int ret = allocate_matrix(&mul_mat, s, s);
    if (ret != 0)
        return ret;
    matrix *tmp1;
    matrix *tmp2;
    ret = allocate_matrix(&tmp1, s, s);
    if (ret != 0) return ret;
    ret = allocate_matrix(&tmp2, s, s);
    if (ret != 0) return ret;
    deep_copy(tmp1, mat);
    int res1 = 1; // is the result in tmp1?
    int mulres = 0; // is the result in mul_mat?
    for (int i = 1; i <= pow; i <<= 1) {
        if (pow & i) {
            mul_matrix(mulres ? result : mul_mat, mulres ? mul_mat : result, res1 ? tmp1 : tmp2);
            mulres = !mulres;
        }
        if (res1) {
            mul_matrix(tmp2, tmp1, tmp1);
        } else {
            mul_matrix(tmp1, tmp2, tmp2);
        }
        res1 = !res1;
    }
    if (mulres) {
        copy(result, mul_mat);
    }
    deallocate_matrix(mul_mat);
    deallocate_matrix(tmp1);
    deallocate_matrix(tmp2);
    return 0;
}

void deep_copy(matrix *result, matrix *mat) {
    int mx = mat->rows * mat->cols;
    double *res_data = result->data;
    double *mat_data = mat->data;
    #pragma omp parallel for
    for (int i = 0; i < mx; i++) {
        *(res_data+i) = *(mat_data+i);
    }
}

void copy(matrix *result, matrix *mat) {
	result->data = mat->data;
	mat->ref_cnt++;
}

/*
 * (OPTIONAL)
 * Store the result of element-wise negating mat's entries to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 */
int neg_matrix(matrix *result, matrix *mat) {
    if (mat->rows != result->rows || mat->cols != result->cols)
        return -1;
    int mx = mat->rows * mat->cols;
	__m256d zero_vec = _mm256_set1_pd(0);
    int cap = mx/4*4;
    double *mat_data = mat->data;
    double *res_data = result->data;
    #pragma omp parallel for
    for (int i = 0; i < cap; i+=4) {
		__m256d tmp_vec = _mm256_loadu_pd(mat_data+i);
		__m256d res_vec = _mm256_sub_pd(zero_vec, tmp_vec);
        _mm256_storeu_pd(res_data+i, res_vec);
    }
	for (int i = cap; i < mx; i++) {
		*(res_data+i) = -(*(mat_data+i));
	}
    return 0;
}

/*
 * Store the result of taking the absolute value element-wise to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 */
int abs_matrix(matrix *result, matrix *mat) {
    if (mat->rows != result->rows || mat->cols != result->cols)
        return -1;
    int mx = mat->rows * mat->cols;
	__m256d zero_vec = _mm256_set1_pd(0);
    int cap = mx/4*4;
    double *mat_data = mat->data;
    double *res_data = result->data;
    #pragma omp parallel for
	for (int i = 0; i < cap; i+=4) {
		__m256d pos_vec = _mm256_loadu_pd(mat_data+i);
		__m256d neg_vec = _mm256_sub_pd(zero_vec, pos_vec);
		__m256d res_vec = _mm256_max_pd(pos_vec, neg_vec);
		_mm256_storeu_pd(res_data+i, res_vec);
	}
    for (int i = cap; i < mx; i++) {
        *(res_data+i) = *(mat_data+i) >= 0 ? *(mat_data+i) : -(*(mat_data+i));
    }
	
    return 0;
}
