function [options,ok] = setOptions( options, varargin )
%[options,ok] = setOptions( options, optionname1, value1, optionname2, value2, ... )
%   Set options. Options not provided in the
%   argument list remain unchanged. Options in the argument list that are
%   not present in m and ignored.
%
%[options,ok] = setOptions( options, optionStruct )
%   As the previous version, but the options are provided as a struct whose
%   fields are the option names that are being set. If later arguments are
%   given, they are ignored.
%
%   See also: setUpModelOptions, setModelOptions, addModelOptions,
%             addOptions

    ok = true;
    if isempty(varargin)
        return;
    end
    if isstruct( varargin{1} )
        s = varargin{1};
    else
        s = safemakestruct( 'setModelOptions', varargin );
    end
    fns = fieldnames(s);
    for i=1:length(fns)
        fn = fns{i};
        [options,index] = setOptionIndex( options, fn, s.(fn) );
        if index==-1
            ok = false;
        end
    end
end
