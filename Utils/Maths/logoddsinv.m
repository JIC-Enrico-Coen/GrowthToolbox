function p = logoddsinv( o )
%p = logoddsinv( o )
%   Calculate the probability corresponding to a log-odds value, i.e.
%   p = 1 ./ (1 + exp(-o)).  o can be a matrix of any shape.
%   logoddsinv(-Inf) = 0 and logoddsinv(Inf) = 1.
%
%   SEE ALSO: logodds.

    p = 1 ./ (1 + exp(-o));
end
