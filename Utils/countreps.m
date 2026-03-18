function varargout = countreps( x )
%y = countreps( x )
%   X is a vector.  X is divided into runs of repeated elements.
%   Y is set to an N*3 array in which row i = [a,b,c] represents the i'th run
%   by the value A, the number of repetitions B, and the index in x of the
%   first occurrence of A in that run.
%
%[values,reps,first] = countreps( x )
%   As above, but returning the three types of result in three variables.
%   These have the property that values = x(first) (provided that x is a
%   column vector, otherwise these have the same values in the same order
%   but a different shape).

    if isempty(x)
        values = zeros(0,1);
        reps = zeros(0,1);
        first = zeros(0,1);
    else
        x = x(:);
        steps = find( x(1:(end-1)) ~= x(2:end) );
        starts = [ 0; steps ];
        ends = [ steps; length(x) ];
        values = x(ends);
        reps = ends-starts;
        first = starts+1;
    end
    if nargout==3
        varargout = {values,reps,first};
    else
        varargout = {[values,reps,first]};
    end
end
