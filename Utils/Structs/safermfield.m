function x = safermfield( x, varargin )
%x = safermfield( x, varargin )
%   Like RMFIELD, but does not throw an exception if a field is not present
%   or if no fields are given. The fields can be given as separate
%   arguments or as a cell array of strings.

    if ~isstruct(x), return; end
    OLDMATLAB = false;
    if isempty(varargin)
        return;
    end
    if iscell(varargin{1})
        fields = varargin{1};
        z = false(1,length(fields));
        for i = 1:length(fields)
            z(i) = isfield( x, fields{i} );
        end
        remove = fields(z);
    elseif OLDMATLAB
        z = false(1,length(varargin));
        for i = 1:length(varargin)
            z(i) = isfield( x, varargin{i} );
        end
        remove = varargin(z);
    else
        remove = varargin( isfield( x, varargin ) );
    end
    if ~isempty(remove)
        x = rmfield( x, remove );
    end
end

