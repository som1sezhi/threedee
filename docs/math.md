# Math Utilities

#### `Vec3`

A 3D vector.

### Properties

#### `Vec3.[1]: number`
X component.

#### `Vec3.[2]: number`
Y component.

#### `Vec3.[3]: number`
Z component.

### Methods

#### `Vec3:new(x?: number, y?: number, z?: number): Vec3`
Creates a new Vec3.
If no arguments are given, `(0, 0, 0)` is returned.

#### `Vec3:add(other: Vec3): Vec3`
Sets `self` to the result of `self + other`.

#### `Vec3:applyQuat(quat: Quat): Vec3`
Applies a quaternion rotation to `self`.

#### `Vec3:clone(): Vec3`
Returns a copy of `self`.

#### `Vec3:copy(source: Vec3): Vec3`
Copies the value of `source` to `self`.

#### `Vec3:cross(other: Vec3): Vec3`
Sets `self` to the cross product between `self` and `other`.

#### `Vec3:div(other: Vec3): Vec3`
Sets `self` to the result of an element-wise division between
`self` and `other`.

#### `Vec3:dot(other: Vec3): number`
Returns the dot product between `self` and `other`.

#### `Vec3:length(): number`
Returns the length of `self`.

#### `Vec3:lengthSquared(): number`
Returns the squared length of `self`.

#### `Vec3:mul(other: Vec3): Vec3`
Sets `self` to the result of an element-wise multiplication between
`self` and `other`.

#### `Vec3:neg(): Vec3`
Sets `self` to the value of `-self`.

#### `Vec3:normalize(): Vec3`
Normalizes the length of `self`. If `self` has length zero, this does nothing.

#### `Vec3:scale(r: number): Vec3`
Scales `self` by the scalar `r`.

#### `Vec3:set(x: number, y: number, z: number): Vec3`
Sets the components of `self`.

#### `Vec3:setFromMatCol(m: Mat3, i: 1|2|3): Vec3`
Sets `self` as the `i`th column vector of matrix `m`.



#### `Vec3:setFromMatRow(m: Mat3, i: 1|2|3): Vec3`
Sets `self` as the `i`th row vector of matrix `m`.



#### `Vec3:sub(other: Vec3): Vec3`
Sets `self` to the result of `self - other`.

## `Vec4`

A 4D vector.

### Properties

#### `Vec4.[1]: number`
X component.

#### `Vec4.[2]: number`
Y component.

#### `Vec4.[3]: number`
Z component.

#### `Vec4.[4]: number`
W component.

### Methods

#### `Vec4:new(x?: number, y?: number, z?: number, w?: number): Vec4`
Creates a new Vec4.
If no arguments are given, `(0, 0, 0, 0)` is returned.

#### `Vec4:add(other: Vec4): Vec4`
Sets `self` to the result of `self + other`.

#### `Vec4:clone(): Vec4`
Returns a copy of `self`.

#### `Vec4:copy(source: Vec4): Vec4`
Copies the value of `source` to `self`.

#### `Vec4:div(other: Vec4): Vec4`
Sets `self` to the result of an element-wise division between
`self` and `other`.

#### `Vec4:dot(other: Vec4): number`
Returns the dot product between `self` and `other`.

#### `Vec4:length(): number`
Returns the length of `self`.

#### `Vec4:lengthSquared(): number`
Returns the squared length of `self`.

#### `Vec4:mul(other: Vec4): Vec4`
Sets `self` to the result of an element-wise multiplication between
`self` and `other`.

#### `Vec4:neg(): Vec4`
Sets `self` to the value of `-self`.

#### `Vec4:normalize(): Vec4`
Normalizes the length of `self`. If `self` has length zero, this does nothing.

#### `Vec4:scale(r: number): Vec4`
Scales `self` by the scalar `r`.

#### `Vec4:set(x: number, y: number, z: number, w: number): Vec4`
Sets the components of `self`.

#### `Vec4:setFromMatCol(m: Mat4, i: 1|2|3|4): Vec4`
Sets `self` as the `i`th column vector of matrix `m`.



#### `Vec4:setFromMatRow(m: Mat4, i: 1|2|3|4): Vec4`
Sets `self` as the `i`th row vector of matrix `m`.



#### `Vec4:sub(other: Vec4): Vec4`
Sets `self` to the result of `self - other`.

## `Mat3`

A 3x3 matrix. Entries are in column-major order.

### Properties

#### `Mat3.[1]: number`
Element at row 1, column 1.

#### `Mat3.[2]: number`
Element at row 2, column 1.

#### `Mat3.[3]: number`
Element at row 3, column 1.

#### `Mat3.[4]: number`
Element at row 1, column 2.

#### `Mat3.[5]: number`
Element at row 2, column 2.

#### `Mat3.[6]: number`
Element at row 3, column 2.

#### `Mat3.[7]: number`
Element at row 1, column 3.

#### `Mat3.[8]: number`
Element at row 2, column 3.

#### `Mat3.[9]: number`
Element at row 3, column 3.

### Methods

#### `Mat3:new(a11?: number, a21?: number, a31?: number, a12?: number, a22?: number, a32?: number, a13?: number, a23?: number, a33?: number): Mat3`
Creates a new Mat3.
Entries should be specified in column-major order.
If no arguments are given, the identity matrix is returned.

#### `Mat3:add(other: Mat3): Mat3`
Sets `self` to the result of `self + other`.

#### `Mat3:clone(): Mat3`
Returns a copy of `self`.

#### `Mat3:copy(source: Mat3): Mat3`
Copies the elements of `source` to `self`.

#### `Mat3:identity(): Mat3`
Sets `self` to the identity matrix.

#### `Mat3:mul(other: Mat3): Mat3`
Sets `self` to the result of the matrix multiplication `self * other`.

#### `Mat3:mulMatrices(matrixA: Mat3, matrixB: Mat3): Mat3`
Sets `self` to the result of the matrix multiplication `matrixA * matrixB`.

#### `Mat3:neg(): Mat3`
Sets `self` to the result of `-self`.

#### `Mat3:premul(other: Mat3): Mat3`
Sets `self` to the result of the matrix multiplication `other * self`.

#### `Mat3:scale(r: number): Mat3`
Scales `self` by the scalar `r`.

#### `Mat3:set(a11: number, a21: number, a31: number, a12: number, a22: number, a32: number, a13: number, a23: number, a33: number): Mat3`
Sets the entries of `self`.
Entries should be specified in column-major order.

#### `Mat3:setFromAxisAngle(axis: Vec3, angle: number): Mat3`
Sets `self` to the rotation matrix specified by `axis` and `angle`.
`axis` must be a unit vector and `angle` should be specified in radians.
Note that positive angles go clockwise when viewing in the positive direction
of the axis (e.g. looking rightwards for the X axis).

#### `Mat3:setFromCols(col1: Vec3, col2: Vec3, col3: Vec3): Mat3`
Sets `self` in terms of column vectors.

#### `Mat3:setFromEuler(euler: Euler): Mat3`
Sets `self` to a rotation matrix as specified by Euler angles `euler`.

#### `Mat3:setFromMat4(mat: Mat4): Mat3`
Sets `self` to the upper 3x3 submatrix of `mat`.

#### `Mat3:setFromQuat(q: Quat): Mat3`
Sets `self` to a rotation matrix as specified by quaternion `q`.

#### `Mat3:setFromRows(row1: Vec3, row2: Vec3, row3: Vec3): Mat3`
Sets `self` in terms of row vectors.

#### `Mat3:sub(other: Mat3): Mat3`
Sets `self` to the result of `self - other`.

#### `Mat3:transpose(): Mat3`
Sets `self` to its `transpose`.

## `Mat4`

A 4x4 matrix. Entries are in column-major order.

### Properties

#### `Mat4.[1]: number`
Element at row 1, column 1.

#### `Mat4.[2]: number`
Element at row 2, column 1.

#### `Mat4.[3]: number`
Element at row 3, column 1.

#### `Mat4.[4]: number`
Element at row 4, column 1.

#### `Mat4.[5]: number`
Element at row 1, column 2.

#### `Mat4.[6]: number`
Element at row 2, column 2.

#### `Mat4.[7]: number`
Element at row 3, column 2.

#### `Mat4.[8]: number`
Element at row 4, column 2.

#### `Mat4.[9]: number`
Element at row 1, column 3.

#### `Mat4.[10]: number`
Element at row 2, column 3.

#### `Mat4.[11]: number`
Element at row 3, column 3.

#### `Mat4.[12]: number`
Element at row 4, column 3.

#### `Mat4.[13]: number`
Element at row 1, column 4.

#### `Mat4.[14]: number`
Element at row 2, column 4.

#### `Mat4.[15]: number`
Element at row 3, column 4.

#### `Mat4.[16]: number`
Element at row 4, column 4.

### Methods

#### `Mat4:new(a11?: number, a21?: number, a31?: number, a41?: number, a12?: number, a22?: number, a32?: number, a42?: number, a13?: number, a23?: number, a33?: number, a43?: number, a14?: number, a24?: number, a34?: number, a44?: number): Mat4`
Creates a new Mat3.
Entries should be specified in column-major order.
If no arguments are given, the identity matrix is returned.

#### `Mat4:add(other: Mat4): Mat4`
Sets `self` to the result of `self + other`.

#### `Mat4:clone(): Mat4`
Returns a copy of `self`.

#### `Mat4:copy(source: Mat4): Mat4`
Copies the elements of `source` to `self`.

#### `Mat4:frustum(l: number, r: number, b: number, t: number, zn: number, zf: number): Mat4`
Sets `self` to a projection matrix for a general frustum.
All coordinates should be in view space.

#### `Mat4:identity(): Mat4`
Sets `self` to the identity matrix.

#### `Mat4:lookAt(eye: Vec3, at: Vec3, up?: Vec3): Mat4`
Sets `self` to a view matrix for a camera at position `eye` looking at `at`, with the view's
up direction oriented based on `up`. If `up` is not given, the world up vector `(0, -1, 0)` is used
by default.

Be aware that this gives a view matrix, not a world matrix for the camera/any other object.

#### `Mat4:mul(other: Mat4): Mat4`
Sets `self` to the result of the matrix multiplication `self * other`.

#### `Mat4:mulMatrices(matrixA: Mat4, matrixB: Mat4): Mat4`
Sets `self` to the result of the matrix multiplication `matrixA * matrixB`.

#### `Mat4:neg(): Mat4`
Sets `self` to the result of `-self`.

#### `Mat4:orthographic(l: number, r: number, t: number, b: number, near: number, far: number): Mat4`
Sets `self` to a projection matrix for an orthographic camera.

#### `Mat4:perspective(fovY: number, aspectRatio: number, near: number, far: number): Mat4`
Sets `self` to a projection matrix for a perspective camera. Note that
`fovY` specifies the vertical FOV in radians.

#### `Mat4:premul(other: Mat4): Mat4`
Sets `self` to the result of the matrix multiplication `other * self`.

#### `Mat4:scale(r: number): Mat4`
Scales `self` by the scalar `r`.

#### `Mat4:set(a11: number, a21: number, a31: number, a41: number, a12: number, a22: number, a32: number, a42: number, a13: number, a23: number, a33: number, a43: number, a14: number, a24: number, a34: number, a44: number): Mat4`
Sets the entries of `self`.
Entries should be specified in column-major order.

#### `Mat4:setFromCols(col1: Vec4, col2: Vec4, col3: Vec4, col4: Vec4): Mat4`
Sets `self` in terms of column vectors.

#### `Mat4:setFromRows(row1: Vec4, row2: Vec4, row3: Vec4, row4: Vec4): Mat4`
Sets `self` in terms of row vectors.

#### `Mat4:setUpperMat3(mat: Mat3): Mat4`
Sets the upper 3x3 submatrix of `self` to `mat`.

#### `Mat4:sub(other: Mat4): Mat4`
Sets `self` to the result of `self - other`.

#### `Mat4:symmetricFrustum(r: number, t: number, zn: number, zf: number): Mat4`
Sets `self` to a projection matrix for a symmetric frustum.
Equivalent to `frustum(-r, r, -t, t, zn, zf)`.
All coordinates should be in view space.

#### `Mat4:transpose(): Mat4`
Sets `self` to its `transpose`.

## `Quat`

A quaternion, often used to represent rotations.

### Properties

#### `Quat.[1]: number`
X component (imaginary).

#### `Quat.[2]: number`
Y component (imaginary).

#### `Quat.[3]: number`
Z component (imaginary).

#### `Quat.[4]: number`
W component (real part).

### Methods

#### `Quat:new(x?: number, y?: number, z?: number, w?: number): Quat`
Creates a new quaternion.
If no arguments are given, an identity quaternion is created.

#### `Quat:clone(): Quat`
Returns a copy of `self`.

#### `Quat:conj(): Quat`
Sets `self` to its conjugate (i.e. the opposite rotation to `self`).

#### `Quat:copy(source: Quat): Quat`
Copies the components of `source` into `self`.

#### `Quat:identity(): Quat`
Sets `self` to the identity quaternion (representing no rotation).

#### `Quat:lookRotation(forwards: Vec3, up?: Vec3): Quat`
Sets `self` to a rotation that rotates `(0, 0, -1)` (the "forwards" direction)
to the direction specified by `forwards`, with the up view direction oriented
based on `up`. If `up` is not give, the world up direction `(0, -1, 0)` is
used by default.

#### `Quat:mul(other: Quat): Quat`
Multiplies `self` by `other`.

#### `Quat:mulQuats(q1: Quat, q2: Quat): Quat`
Sets `self` to the result of multiplying `q1` by `q2`.

#### `Quat:normalize(): Quat`
Normalizes `self`.

#### `Quat:premul(other: Quat): Quat`
Pre-multiplies `self` by `other`.

#### `Quat:set(x: number, y: number, z: number, w: number): Quat`
Sets the components of `self`.

#### `Quat:setFromAxisAngle(axis: Vec3, angle: number): Quat`
Sets `self` to the rotation specified by `axis` and `angle`.
`axis` must be a unit vector and `angle` should be specified in radians.
Note that positive angles go clockwise when viewing in the positive direction
of the axis (e.g. looking rightwards for the X axis).

#### `Quat:setFromEuler(euler: Euler): Quat`
Sets `self` to a rotation matrix as specified by Euler angles `euler`.

#### `Quat:setFromMat3(rot: Mat3): Quat`
Sets `self` to a rotation as specified by the rotation matrix `rot`.

#### `Quat:slerp(qb: Quat, t: number): Quat`
Sets self to the result of spherical linear interpolation from `self` to `qb`
based on parameter `t`.

## `Euler`

A rotation represented as Euler angles.
Note that positive angles go clockwise when viewing in the positive direction
of the axis (e.g. looking rightwards for the X axis).

### Properties

#### `Euler.[1]: number`
Rotation around X axis (in radians).

#### `Euler.[2]: number`
Rotation around Y axis (in radians).

#### `Euler.[3]: number`
Rotation around Z axis (in radians).

#### `Euler.order: 'xyz'|'xzy'|'yxz'|'yzx'|'zxy'|'zyx'`
The order in which to apply the rotations.

### Methods

#### `Euler:new(x?: number, y?: number, z?: number, order?: 'xyz'|'xzy'|'yxz'|'yzx'|'zxy'|'zyx'): Euler`
Creates a new Euler object. All angles should be specified in radians.
Note that positive angles go clockwise when viewing in the positive direction
of the axis (e.g. looking rightwards for the X axis).

If no arguments are given, all angles will be set to 0.
If `order` is not given, `'zyx'` will be used as the default order.



#### `Euler:clone(): Euler`
Returns a copy of `self`.

#### `Euler:copy(source: Euler): Euler`
Copies the components of `source` into `self`.

#### `Euler:nitgUnpack(): number, number, number`
Unpacks the Euler into 3 numbers that can be consumed by actor methods such as `Actor:rotationxyz()`.
This converts the components into degrees, and also negates the Z component because 
for some reason NotITG's Z rotation matrix rotates in the opposite direction of
the other rotation matrices.

#### `Euler:set(x: number, y: number, z: number): Euler`
Sets the components of `self`.

#### `Euler:setFromMat3(m: Mat3, order?: 'xyz'|'xzy'|'yxz'|'yzx'|'zxy'|'zyx'): Euler`
Sets `self` to the rotation specified by a pure rotation matrix `m`.
If `order` is not given, `'zyx'` will be used as the default order.



#### `Euler:setFromQuat(q: Quat, order?: 'xyz'|'xzy'|'yxz'|'yzx'|'zxy'|'zyx'): Euler`
Sets `self` to the rotation specified by the quaternion `q`.
If `order` is not given, `'zyx'` will be used as the default order.



