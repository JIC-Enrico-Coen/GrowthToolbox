function rs = randSign( varargin )
%rs = randSign( varargin )
%   Generate values of -1 or +1 independently at random with equal
%   probability.
%
%   The arguments are the same as for rand().

    rs = 2 * (rand( varargin{:} ) < 0.5) - 1;
end
