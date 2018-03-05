import numpy as np

cdef class BaseValue:
    cdef _BaseValue * get_thisptr(self):
        return self.thisptr
    cdef double get_value(self, double * row):
        return self.thisptr.getValue(row)

cdef class Lookup (BaseValue):
    def __cinit__(self, int aid):
        cdef _Lookup * temp_ptr = new _Lookup(aid)
        self.thisptr = <_BaseValue * > temp_ptr
    def __dealloc__(self):
        del self.thisptr

cdef class Formula (BaseValue):
    def __cinit__(self, aids, func_name):
        cdef vector[int] aid_vector = aids
        b_func_name = func_name.encode('ascii')
        cdef string func_name_string = <string> b_func_name
        cdef map[string, FormulaFncPtr] func_map = getFormulaFncPtrMap()
        if func_map.find(func_name_string) == func_map.end():
            print('ERROR: "{}" not in FormulaFncPtrMap'.format(func_name))
            print('    EXITING')
            exit()
        cdef FormulaFncPtr func_ptr = func_map[func_name_string]
        cdef _Formula * temp_ptr = new _Formula(aid_vector, func_ptr)
        self.thisptr = <_BaseValue * > temp_ptr
    def __dealloc__(self):
        del self.thisptr

cdef class GaussConstraint (BaseValue):
    def __cinit__(self, aids, double mu, sigmas, func_name):
        cdef vector[int] aid_vector 
        for aid in aids:
            aid_vector.push_back(aid)
        cdef vector[double] sigmas_vector 
        for sigma in sigmas:
            sigmas_vector.push_back(sigma)
        b_func_name = func_name.encode('ascii')
        cdef string func_name_string = <string> b_func_name
        cdef map[string, GaussChi2FunctionPtr] func_map = getGaussChi2FunctionPtrMap()
        if func_map.find(func_name_string) == func_map.end():
            print('ERROR: "{}" not in GaussChi2FunctionPtrMap'.format(func_name))
            print('    EXITING')
            exit()
        cdef GaussChi2FunctionPtr func_ptr = func_map[func_name_string]
        cdef _GaussConstraint * temp_ptr = new _GaussConstraint(aid_vector, mu, 
                sigmas_vector, func_ptr)
        self.thisptr = <_BaseValue * > temp_ptr
    def __dealloc__(self):
        del self.thisptr

cdef class MneuMgM12gM3gX2Lookup (BaseValue):
    def __cinit__(self, aids, file_name, double default_X2):
        # Prepare array Ids
        cdef vector[int] aid_vector 
        for aid in aids:
            aid_vector.push_back(aid)
        # Prepare all data
        data = np.loadtxt(file_name)
        ind = np.lexsort((data[:,3],data[:,2],data[:,1],data[:,0]))
        unique_mneu = np.unique(data[:, 0]) 
        mneus = data[:, 0]
        mgs = data[:, 1]
        m12gs = data[:, 2]
        m3gs = data[:, 3]
        X2s = data[:, 4]
        cdef vector[double] mneu_vector = unique_mneu
        cdef vector[vector[double]] grid_X2s
        cdef vector[vector[double]] grid_mgs 
        cdef vector[vector[double]] grid_m12gs 
        cdef vector[vector[double]] grid_m3gs 
        cdef vector[double] mneu_X2s
        cdef vector[double] mneu_mgs
        cdef vector[double] mneu_m12gs
        cdef vector[double] mneu_m3gs
        for mneu in unique_mneu:
            ids = (mneus==mneu)
            # First copy all X2 values for the given mneu
            mneu_X2s.clear()
            mneu_X2s = X2s[mneus==mneu]
            grid_X2s.push_back(mneu_X2s)
            # Next add the unique values of mg (for the given mneu) to grid_mgs
            mneu_mgs.clear()
            mneu_mgs = np.unique(mgs[mneus==mneu])
            grid_mgs.push_back(mneu_mgs)
            # Next add the unique values of mg (for the given mneu) to grid_mgs
            mneu_m12gs.clear()
            mneu_m12gs = np.unique(m12gs[mneus==mneu])
            grid_m12gs.push_back(mneu_m12gs)
            # Next add the unique values of mg (for the given mneu) to grid_mgs
            mneu_m3gs.clear()
            mneu_m3gs = np.unique(m3gs[mneus==mneu])
            grid_m3gs.push_back(mneu_m3gs)
        cdef _MneuMgM12gM3gX2Lookup * temp_ptr = new _MneuMgM12gM3gX2Lookup(
                aid_vector, grid_X2s, default_X2, mneu_vector, grid_mgs, 
                grid_m12gs, grid_m3gs)
        self.thisptr = <_BaseValue * > temp_ptr
    def __dealloc__(self):
        del self.thisptr

cdef class ContourConstraint(BaseValue):
    def __cinit__(self, aids, contour_options_list, function_name):
        # Prepare array Ids
        cdef vector[int] aid_vector 
        for aid in aids:
            aid_vector.push_back(aid)
        # Prepare contours
        cdef vector[pair[double, double]] coordinates_vec
        cdef _Contour * contour_ptr = NULL
        cdef _LogXLogYContour * log_x_log_y_contour_ptr = NULL
        cdef _RadialContour * radial_contour_ptr = NULL

        for contour_options in contour_options_list:
            type = contour_options['type'] 
            file = contour_options['file'] 
            coords = np.loadtxt(file)
            coordinates_vec.clear()
            for xy in coords:
                coordinates_vec.push_back(xy)
            if type == 'default':
                default_contour_ptr = new _DefaultContour(coordinates_vec)
                contour_ptr = <_Contour * > default_contour_ptr
                self._contours.push_back(contour_ptr)
            elif type == 'log_x_log_y':
                log_x_log_y_contour_ptr = new _LogXLogYContour(coordinates_vec)
                contour_ptr = <_Contour * > log_x_log_y_contour_ptr 
                self._contours.push_back(contour_ptr)
            elif type == 'radial':
                radial_contour_ptr = new _RadialContour(coordinates_vec)
                contour_ptr = <_Contour * > radial_contour_ptr
                self._contours.push_back(contour_ptr)
            else:
                print('ERROR: Constraint type "{}" not found'.format(type))
        # Get ContourChi2FunctionPtr
        b_function_name = function_name.encode('utf-8')
        cdef string function_name_string = <string> b_function_name
        cdef map[string, ContourChi2FunctionPtr] function_map = getContourChi2FunctionPtrMap()
        if function_map.find(function_name_string) == function_map.end():
            print('ERROR: "{}" not in ContourChi2FunctionPtrMap'.format(function_name))
            print('    EXITING')
            exit()
        cdef ContourChi2FunctionPtr func_ptr = function_map[function_name_string]
        cdef vector[_Contour * ] contours = self._contours
        cdef _ContourConstraint * temp_ptr = new _ContourConstraint(aid_vector, 
                contours, func_ptr)
        self.thisptr = <_BaseValue *> temp_ptr
    def __dealloc__(self):
        for contour_ptr in self._contours:
            del contour_ptr
        del self.thisptr

cdef class Contour2dConstraint(BaseValue):
    def __cinit__(self, aids, contour_options_list, function_name):
        # Prepare array Ids
        cdef vector[int] aid_vector
        for aid in aids:
            aid_vector.push_back(aid)
        # Prepare contours
        cdef vector[triple[double, double, double]] coordinates_vec
        cdef _Contour * contour_ptr = NULL
        cdef _LogXLogYLogZContour * log_x_log_y_log_z_contour_ptr = NULL
        cdef _RadialContour * radial_contour_ptr = NULL

        for contour_options in contour_options_list:
            type = contour_options['type']
            file = contour_options['file']
            coords = np.loadtxt(file)
            coordinates_vec.clear()
            for xyz in coords:
                coordinates_vec.push_back(xyz)
            if type == 'default':
                default_contour_ptr = new _DefaultContour(coordinates_vec)
                contour_ptr = <_Contour * > default_contour_ptr
                self._contours.push_back(contour_ptr)
            elif type == 'log_x_log_y':
                log_x_log_y_log_z_contour_ptr = new _LogXLogYLogZContour(coordinates_vec)
                contour_ptr = <_Contour * > log_x_log_y_log_z_contour_ptr
                self._contours.push_back(contour_ptr)
            elif type == 'radial':
                radial_contour_ptr = new _RadialContour(coordinates_vec)
                contour_ptr = <_Contour * > radial_contour_ptr
                self._contours.push_back(contour_ptr)
            else:
                print('ERROR: Constraint type "{}" not found'.format(type))
        # Get ContourChi2FunctionPtr
          b_function_name = function_name.encode('utf-8')
        cdef string function_name_string = <string> b_function_name
        cdef map[string, ContourChi2FunctionPtr] function_map = getContourChi2FunctionPtrMap()
        if function_map.find(function_name_string) == function_map.end():
            print('ERROR: "{}" not in ContourChi2FunctionPtrMap'.format(function_name))
            print('    EXITING')
            exit()
        cdef ContourChi2FunctionPtr func_ptr = function_map[function_name_string]
        cdef vector[_Contour * ] contours = self._contours
        cdef _ContourConstraint * temp_ptr = new _ContourConstraint(aid_vector,
                contours, func_ptr)
        self.thisptr = <_BaseValue *> temp_ptr
    def __dealloc__(self):
        for contour_ptr in self._contours:
            del contour_ptr
        del self.thisptr


cdef class SmsLimit(BaseValue):
    def __cinit__(self, aids, file, int n_x_inputs, mneus, left_mus, 
            left_sigmas, right_mus, right_sigmas, mass_gaps):
        # Fill the c++ vectors
        cdef vector[int] aids_vec = aids
        cdef vector[pair[double, double]] contour_points_vec
        contour_points = np.loadtxt(file, delimiter=',')
        for xy in contour_points:
            contour_points_vec.push_back(xy)
        cdef vector[double] mneus_vec = mneus
        cdef vector[double] left_mus_vec = left_mus
        cdef vector[double] left_sigmas_vec = left_sigmas
        cdef vector[double] right_mus_vec = right_mus
        cdef vector[double] right_sigmas_vec = right_sigmas
        cdef vector[double] mass_gaps_vec = mass_gaps
        cdef _SmsLimit * temp_ptr = new _SmsLimit(aids_vec, contour_points_vec, 
                n_x_inputs, mneus_vec, left_mus_vec, left_sigmas_vec, 
                right_mus_vec, right_sigmas_vec, mass_gaps_vec)
        self.thisptr = <_BaseValue *> temp_ptr
    def __dealloc__(self):
        del self.thisptr

cdef class Chi2Calculator(BaseValue):
    def __cinit__(self, constraints):
        # Fill the c++ vectors
        cdef vector[_BaseValue *] constraints_vec
        cdef BaseValue temp_constraint
        for constraint in constraints:
            temp_constraint = constraint
            constraints_vec.push_back(temp_constraint.get_thisptr())
        cdef _Chi2Calculator * temp_ptr = new _Chi2Calculator(constraints_vec)
        self.thisptr = <_BaseValue *> temp_ptr
    def __dealloc__(self):
        del self.thisptr
