function ok = haveOptions( options, mode, varargin )
%ok = haveOptions( options, mode, optionname1, optionname2, ... )
%   Check whether OPTIONS has the given options.  'mode' is 'incl',
%   'only', or 'exact'.
    [~,ok] = checkstructfields( options, mode, varargin{:} );
end
