function [dpar,dper] = averageConductivity( varargin )
%d = averageConductivity( m, morphogenindex )
%d = averageConductivity( c )
%   The first type of call translates to the second:
%       d = averageConductivity( m.conductivity(morphogenindex) )
%   Make a crude estimate of the average conductivity given by c.Dpar and
%   c.Dper.  This is accurate when the conductivity is uniform, but should
%   not be used for numerical computation if it is non-uniform, only for
%   giving a rough estimate.
%   c can be a struct array, and morphogenindex can be an array of
%   indexes.  d will be an array of average conductivities of the same
%   length.
    if nargin==1
        c = varargin{1};
    else
        mgenindex = FindMorphogenIndex(varargin{1},varargin{2});
        if isempty(mgenindex) || (mgenindex==0)
            dpar = [];
            dper = [];
            return;
        end
        c = varargin{1}.conductivity(mgenindex);
    end
    if isfield( c, 'conductivity' )
        c = c.conductivity;
    end
    dpar = zeros(1,length(c));
    dper = zeros(1,length(c));
    for i=1:length(c)
        dpar(i) = sum(c(i).Dpar);
        if ~isempty(c(i).Dpar)
            dpar(i) = dpar(i)/length(c(i).Dpar);
        end
        if isempty( c(i).Dper )
            dper(i) = dpar(i);
        else
            dper(i) = sum(c(i).Dper);
            if ~isempty(c(i).Dper)
                dper(i) = dper(i)/length(c(i).Dper);
            end
        end
    end
    if nargout < 2
        dpar = sqrt(dpar.*dper);
    end
end
