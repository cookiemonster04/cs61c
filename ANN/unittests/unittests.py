from unittest import TestCase
from framework import AssemblyTest, print_coverage


class TestAbs(TestCase):
    def test_zero(self):
        t = AssemblyTest(self, "abs.s")
        # load 0 into register a0
        t.input_scalar("a0", 0)
        # call the abs function
        t.call("abs")
        # check that after calling abs, a0 is equal to 0 (abs(0) = 0)
        t.check_scalar("a0", 0)
        # generate the `assembly/TestAbs_test_zero.s` file and run it through venus
        t.execute()

    def test_one(self):
        # same as test_zero, but with input 1
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", 1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    def test_minus_one(self):
        # Indicates we are creating the test for the `abs.s` file
        t = AssemblyTest(self, "abs.s")
        # Setting the argument register a0 to have value of -1
        t.input_scalar("a0", -1)
        # Calling the abs function
        t.call("abs")
        # The a0 register is now the return value
        # Checking if a0 is now 1
        t.check_scalar("a0", 1)
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("abs.s", verbose=False)


class TestRelu(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the relu function
        t.call("relu")
        # check that the array0 was changed appropriately
        t.check_array(array0, [1, 0, 3, 0, 5, 0, 7, 0, 9])
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute()
    
    def test_empty(self):
        # same thing as above but empty array
        t = AssemblyTest(self, "relu.s")
        arraye = t.array([])
        t.input_array("a0", arraye)
        t.input_scalar("a1", len(arraye))
        t.call("relu")
        t.execute(code=32)

    @classmethod
    def tearDownClass(cls):
        print_coverage("relu.s", verbose=False)


class TestArgmax(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([3, 1, 4, 1, 5, 9, 2, 6, 5])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", len(array0))
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 5)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_empty(self):
        t = AssemblyTest(self, "argmax.s")
        arraye = t.array([])
        t.input_array("a0", arraye)
        t.input_scalar("a1", len(arraye))
        t.call("argmax")
        t.execute(code=32)
        
    def test_neg(self):
        t = AssemblyTest(self, "argmax.s")
        array2 = t.array([3, 1, -4, -5, -9, 2, -6, 5])
        t.input_array("a0", array2)
        t.input_scalar("a1", len(array2))
        t.call("argmax")
        t.check_scalar("a0", 7)
        t.execute()
        
    @classmethod
    def tearDownClass(cls):
        print_coverage("argmax.s", verbose=False)


class TestDot(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array01 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        array02 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        t.input_scalar("a2", len(array01))
        # load array addresses into argument registers
        t.input_array("a0", array01)
        t.input_array("a1", array02)
        # load array attributes into argument registers
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        # call the `dot` function
        t.call("dot")
        # check the return value
        t.check_scalar("a0", 285)
        t.execute()
    
    def test_empty(self):
        t = AssemblyTest(self, "dot.s")
        arraye1 = t.array([])
        arraye2 = t.array([])
        t.input_scalar("a2", len(arraye1))
        t.input_array("a0", arraye1)
        t.input_array("a1", arraye2)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 3)
        t.call("dot")
        t.execute(code=32)
    
    def test_non_unit_stride(self):
        t = AssemblyTest(self, "dot.s")
        array1 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        array2 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        t.input_scalar("a2", 3)
        t.input_array("a0", array1)
        t.input_array("a1", array2)
        t.input_scalar("a3", 3)
        t.input_scalar("a4", 3)
        t.call("dot")
        t.check_scalar("a0", 66)
        t.execute()
    
    def test_stride_first(self):
        t = AssemblyTest(self, "dot.s")
        array1 = t.array([5, 7])
        array2 = t.array([2, 4])
        t.input_scalar("a2", len(array1))
        t.input_array("a0", array1)
        t.input_array("a1", array2)
        t.input_scalar("a3", 0)
        t.input_scalar("a4", 1)
        t.call("dot")
        t.execute(code=33)
        
    def test_stride_second(self):
        t = AssemblyTest(self, "dot.s")
        array1 = t.array([3, 6])
        array2 = t.array([9, 8])
        t.input_scalar("a2", len(array1))
        t.input_array("a0", array1)
        t.input_array("a1", array2)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 0)
        t.call("dot")
        t.execute(code=33)
        
    def test_stride_both(self):
        t = AssemblyTest(self, "dot.s")
        array1 = t.array([1, 1])
        array2 = t.array([4, 7])
        t.input_scalar("a2", len(array1))
        t.input_array("a0", array1)
        t.input_array("a1", array2)
        t.input_scalar("a3", 0)
        t.input_scalar("a4", 0)
        t.call("dot")
        t.execute(code=33)
        
    @classmethod
    def tearDownClass(cls):
        print_coverage("dot.s", verbose=False)


class TestMatmul(TestCase):

    def do_matmul(self, m0, m0_rows, m0_cols, m1, m1_rows, m1_cols, result, code=0):
        t = AssemblyTest(self, "matmul.s")
        # we need to include (aka import) the dot.s file since it is used by matmul.s
        t.include("dot.s")

        # create arrays for the arguments and to store the result
        array0 = t.array(m0)
        array1 = t.array(m1)
        array_out = t.array([0] * len(result))

        # load address of input matrices and set their dimensions
        t.input_array("a0", array0)
        t.input_scalar("a1", m0_rows)
        t.input_scalar("a2", m0_cols)
        t.input_array("a3", array1)
        t.input_scalar("a4", m1_rows)
        t.input_scalar("a5", m1_cols)
        # load address of output array
        t.input_array("a6", array_out)

        # call the matmul function
        t.call("matmul")

        # check the content of the output array
        t.check_array(array_out, result)

        # generate the assembly file and run it through venus, we expect the simulation to exit with code `code`
        t.execute(code=code)

    def test_simple(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [30, 36, 42, 66, 81, 96, 102, 126, 150]
        )
    
    def test_zero_dimension_error(self):
        self.do_matmul([1, 2, 3, 4, 5, 6, 7, 8, 9], 0, 3, [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3, [30, 36, 42, 66, 81, 96, 102, 126, 150], 34)
        self.do_matmul([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 0, [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3, [30, 36, 42, 66, 81, 96, 102, 126, 150], 34)
        self.do_matmul([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3, [1, 2, 3, 4, 5, 6, 7, 8, 9], 0, 3, [30, 36, 42, 66, 81, 96, 102, 126, 150], 34)
        self.do_matmul([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3, [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 0, [30, 36, 42, 66, 81, 96, 102, 126, 150], 34)
    
    def test_mismatch_dimension_error(self):
        self.do_matmul([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 2, [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 2, [30, 36, 42, 66, 81, 96, 102, 126, 150], 34)
        self.do_matmul([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 2, [1, 2, 3, 4, 5, 6, 7, 8, 9], 2, 3, [9, 12, 15, 19, 26, 33, 29, 40, 51])
        self.do_matmul([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 2, [1, 2, 3, 4, 5, 6, 7, 8, 9], 2, 1, [5, 11, 17])
    
    @classmethod
    def tearDownClass(cls):
        print_coverage("matmul.s", verbose=False)


class TestReadMatrix(TestCase):

    def do_read_matrix(self, input_file, ans_array, fail='', code=0):
        t = AssemblyTest(self, "read_matrix.s")
        # load address to the name of the input file into register a0
        t.input_read_filename("a0", input_file)

        # allocate space to hold the rows and cols output parameters
        rows = t.array([-1])
        cols = t.array([-1])

        # load the addresses to the output parameters into the argument registers
        
        t.input_array("a1", rows)
        t.input_array("a2", cols)

        # call the read_matrix function
        t.call("read_matrix")

        # check the output from the function
        t.check_array_pointer("a0", ans_array)

        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)

    def test_simple(self):
        self.do_read_matrix("inputs/test_read_matrix/test_input.bin", [1, 2, 3, 4, 5, 6, 7, 8, 9])
	
    def test_fails(self):
        file = "inputs/test_read_matrix/test_input.bin"
        ans = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        self.do_read_matrix(file, ans, 'malloc', 48)
        self.do_read_matrix(file, ans, 'fopen', 64)
        self.do_read_matrix(file, ans, 'fread', 66)
        self.do_read_matrix(file, ans, 'fclose', 65)

    def test_rect_matrix(self):
        self.do_read_matrix("inputs/test_read_matrix/rect_input.bin", [1, 2, 3, 4, 5, 6, 7, 8])

    @classmethod
    def tearDownClass(cls):
        print_coverage("read_matrix.s", verbose=False)


class TestWriteMatrix(TestCase):

    def do_write_matrix(self, row, col, list, ans, fail='', code=0):
        t = AssemblyTest(self, "write_matrix.s")
        outfile = "outputs/test_write_matrix/student.bin"
        # load output file name into a0 register
        t.input_write_filename("a0", outfile)
        # load input array and other arguments
        t.input_array("a1", t.array(list))
        t.input_scalar("a2", row)
        t.input_scalar("a3", col)
        # call `write_matrix` function
        t.call("write_matrix")
        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)
        # compare the output file against the reference
        if code == 0:
            t.check_file_output(outfile, ans)

    def test_simple(self):
        list = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        self.do_write_matrix(3, 3, list, "outputs/test_write_matrix/reference.bin")

    def test_fails(self):
        list = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        self.do_write_matrix(3, 3, list, "outputs/test_write_matrix/reference.bin", 'fopen', 64)
        self.do_write_matrix(3, 3, list, "outputs/test_write_matrix/reference.bin", 'fwrite', 67)
        self.do_write_matrix(3, 3, list, "outputs/test_write_matrix/reference.bin", 'fclose', 65)

    def test_rect_matrix(self):
        list = [1, 2, 3, 4, 5, 6, 7, 8]
        self.do_write_matrix(4, 2, list, "outputs/test_write_matrix/rect_reference.bin")

    @classmethod
    def tearDownClass(cls):
        print_coverage("write_matrix.s", verbose=False)


class TestClassify(TestCase):

    def make_test(self):
        t = AssemblyTest(self, "classify.s")
        t.include("argmax.s")
        t.include("dot.s")
        t.include("matmul.s")
        t.include("read_matrix.s")
        t.include("relu.s")
        t.include("write_matrix.s")
        return t
    def do_test(self, input, output_id, print, ans, fail = "", code=0):
        t = self.make_test()
        args = [f"{input}/m0.bin", f"{input}/m1.bin",
                f"{input}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
                
        if fail == "cnt":
            args = [f"{input}/m0.bin", f"{input}/m1.bin",
                f"{input}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin", "extra_arg"]
                
        out = f"outputs/test_basic_main/student{output_id}.bin"
        reference = f"outputs/test_basic_main/reference{output_id}.bin"
        t.input_scalar("a2", print)
        t.call("classify")
        if fail == "cnt":
            t.execute(code, args=args)
        else:
            t.execute(code, args=args, fail=fail)
        if fail == "":
            t.check_stdout(ans)
            t.check_file_output(out, reference)
        
    def test_simple0_input0(self):
        self.do_test("inputs/simple0/bin", "0", 0, "2\n")

    def test_simple1_input1(self):
        self.do_test("inputs/simple1/bin", "1", 0, "1\n")

    def test_malloc_error(self):
        self.do_test("inputs/simple0/bin", "0", 0, "2\n", "malloc", 48)

    # def test_cnt_error(self):
        # self.do_test("inputs/simple0/bin", "0", 0, "2\n", "cnt", 35)

    @classmethod
    def tearDownClass(cls):
        print_coverage("classify.s", verbose=False)


# The following are some simple sanity checks:
import subprocess, pathlib, os
script_dir = pathlib.Path(os.path.dirname(__file__)).resolve()

def compare_files(test, actual, expected):
    assert os.path.isfile(expected), f"Reference file {expected} does not exist!"
    test.assertTrue(os.path.isfile(actual), f"It seems like the program never created the output file {actual}!")
    # open and compare the files
    with open(actual, 'rb') as a:
        actual_bin = a.read()
    with open(expected, 'rb') as e:
        expected_bin = e.read()
    test.assertEqual(actual_bin, expected_bin, f"Bytes of {actual} and {expected} did not match!")

class TestMain(TestCase):
    """ This sanity check executes src/main.S using venus and verifies the stdout and the file that is generated.
    """

    def run_main(self, inputs, output_id, label):
        args = [f"{inputs}/m0.bin", f"{inputs}/m1.bin",
                f"{inputs}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
        reference = f"outputs/test_basic_main/reference{output_id}.bin"

        t= AssemblyTest(self, "main.s", no_utils=True)
        t.call("main")
        t.execute(args=args)
        t.check_stdout(label)
        t.check_file_output(args[-1], reference)

    def test0(self):
        self.run_main("inputs/simple0/bin", "0", "2")

    def test1(self):
        self.run_main("inputs/simple1/bin", "1", "1")