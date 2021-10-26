function [m,ok] = setModelOptions( m, varargin )
%m = setModelOptions( m, optionname1, value1, optionname2, value2, ... )
%   Set model options of m, a GFtbox mesh. Options not provided in the
%   argument list remain unchanged. Options in the argument list that are
%   not present in m are ignored.
%
%m = setModelOptions( m, optionStruct )
%   As the previous version, but the options are provided as a struct whose
%   fields are the option names that are being set. If later arguments are
%   given, they are ignored.
%
%   See also: setUpModelOptions, addModelOptions, setOptions

    if isempty(varargin)
        ok = true;
    else
        [m.modeloptions,ok] = setOptions( m.modeloptions, varargin{:} );
    end
end
