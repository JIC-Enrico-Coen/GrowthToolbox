function r = rotateFrameToFrame( f1, f2 )
%r = rotateFrameToFrame( f1, f2 )
%   f1 and f2 are frames of reference, i.e. 3D matrices in which the rows
%   are basis vectors.  Each of them can contain one, two, or three vectors,
%   and the vectors need not be orthonormal.  If fewer vectors are
%   supplied, then the frames will automatically be completed.
%
%   The result is an isometric matrix that rotates frame f1 onto frame f2.
%
%   If f1 and f2 have the samw handedness, the matrix will be a rotation,
%   otherwise it will be a reflection.
%
%   If f1 or f2 need completing to a set of three vectors, the resulting
%   frame will always be right-handed.  Thus if both f1 and f2 need
%   completing, the result will be a rotation.

    f1r = completeFrame(f1);
    f2r = completeFrame(f2);
    r = f1r'*f2r;
end
