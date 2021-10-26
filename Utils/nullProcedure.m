function varargout = nullProcedure( varargin )
%varargout = nullProcedure( varargin )
%   A procedure that takes any number of arguments and does nothing. If
%   output arguments are requested they are all set to [].

    for i=nargout:-1:1
        varargout{i} = [];
    end
end