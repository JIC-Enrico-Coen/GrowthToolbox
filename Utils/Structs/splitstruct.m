function varargout = splitstruct( s, varargin )
%varargout = splitstruct( s, varargin )
%   The optional arguments are cell arrays of strings, which are expected
%   to be field names of the struct s.
%   There should be as many optional output arguments as optional input
%   arguments.  Each output argument is set to a struct which contains
%   those components of s whose field names are listed in the corresponding
%   optional input argument.  Field names in the input arguments that are
%   not fields of s are ignored.

    varargout = cell(1,nargout);
    for j=1:nargout
        varargout{j} = struct();
    end
    for i=1:min(length(varargin),nargout)
        f = varargin{i};
        si = struct();
        for j=1:length(f)
            if isfield(s,f{j})
                si.(f{j}) = s.(f{j});
            end
        end
        varargout{i} = si;
    end
end
