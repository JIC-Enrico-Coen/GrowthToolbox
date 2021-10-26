function ok = haveModelOptions( m, mode, varargin )
%ok = haveModelOptions( m, mode, optionname1, optionname2, ... )
%   Check whether the mesh m has the given options.  'mode' is 'incl',
%   'only', or 'exact'.

    ok = isfield( m, 'modeloptions' ) && haveOptions( m.modeloptions, mode, varargin{:} );
end
