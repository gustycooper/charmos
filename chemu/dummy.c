#define PY_SSIZE_T_CLEAN
#include <Python.h>

// /Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.8/Headers

// Register values
#define CHEMU_INSTRUCTION_DISPLAY_COUNT 17
static int registers[CHEMU_INSTRUCTION_DISPLAY_COUNT];

/**
 * @brief The C implementation of the chemu.do(command) method
 * 
 * @param self The calling Python object
 * @param args The arguments passed via the Python call to the function
 * @return PyObject* a dict containing changed registers and the current 17 visible instructions
 */
static PyObject *method_do(PyObject *self, PyObject *args) {
    char *command;
    if (!PyArg_ParseTuple(args, "s", &command)) {
        return NULL;
    }
    // we now know what the user sent over...

    // printf("%s", command);
    PyObject *instructions = PyList_New(0);
    char hex_buffer[11];
    char cpsr_value[11];
    for (int i = 0; i < CHEMU_INSTRUCTION_DISPLAY_COUNT; i++) {
        int rn = rand();
        registers[i] = rn;
        snprintf(hex_buffer, 11, "0x%08X", rn);
        if (i == 8) {
            strcpy(cpsr_value, hex_buffer);
        }
        PyList_Append(instructions, Py_BuildValue("{ssss}", "instruction", "testing", "address", hex_buffer));
    }

    PyObject *registers = PyList_New(0);

    PyObject *reg16 = Py_BuildValue("{siss}", "register", rand() % 16, "value", "0xfeedabee");
    PyObject *cpsr = Py_BuildValue("{siss}", "register", 16, "value", cpsr_value);
    
    PyList_Append(registers, reg16);
    PyList_Append(registers, cpsr);

    PyObject *returnValue = Py_BuildValue("{sOsO}", "registers", registers, "instructions", instructions);
    return returnValue;
}

// Null-terminated array of methods available in the module
static PyMethodDef chemuMethods[] = {
    {"do", method_do, METH_VARARGS, "Python interface for Chemu"},
    {NULL, NULL, 0, NULL}
};

// Module struct pointing to chemuMethods
static struct PyModuleDef chemuModule = {
    PyModuleDef_HEAD_INIT,
    "chemu",
    "Python interface for Chemu",
    -1,
    chemuMethods
};

/**
 * @brief Function called by Python to initialize the module
 * 
 * @return PyMODINIT_FUNC An object containing the module's methods
 */
PyMODINIT_FUNC PyInit_chemu(void) {
    // initalize RNG with current time as seed
    time_t t;
    time(&t);
    srand(t);

    // return the filled-in module struct
    return PyModule_Create(&chemuModule);
}