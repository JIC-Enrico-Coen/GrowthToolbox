function d = isDiffusible( varargin )
%d = isDiffusible( m, morphogenindex )
%d = isDiffusible( c )
%d = isDiffusible( m )
%   The first type of call translates to the second:
%       d = isDiffusible( m.conductivity(morphogenindex) )
%   The third type asks for the diffusibility of all morphogens.
%
%   For each morphogen, the corresponding result is true if and only if
%   the morphogen has somewhere a non-zero diffusion coefficient.

    if nargin==1
        c = varargin{1};
    else
        c = varargin{1}.conductivity(varargin{2});
    end
    if isfield( c, 'conductivity' )
        c = c.conductivity;
    end
    d = false(1,length(c));
    for i=1:length(c)
        d(i) = any( c(i).Dpar > 0 ) || any( c(i).Dper > 0 );
    end
end
