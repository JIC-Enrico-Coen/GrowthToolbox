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
%   If there is an option called 'variant', this is treated specially.
%   First, that option is set, then the model's
%   GFtbox_selectVariant_Callback is invoked to set all options that depend
%   on that variant, and then the remaining options are set. This allows
%   the interaction function to define canned sets of options labelled by
%   different values of the 'variant' option, while allowing them to be
%   overridden by explicitly specified options.
%
%   See also: setUpModelOptions, addModelOptions, setOptions

    ok = true;

    % Ignore an empty argument list.
    if isempty(varargin)
        return;
    end
   
    % Put the arguments into the form of a struct.
    if isstruct( varargin{1} )
        s = varargin{1};
    else
        s = safemakestruct( 'setModelOptions', varargin );
    end
    
    % Handle the 'variant' option, if present.
    if isfield( s, 'variant' )
        v = s.variant;
        timedFprintf( 'Setting ''variant'' option ''%s''\n', v );
        m = setModelOption( m, 'variant', v );
        [m,ok1] = invokeIFcallback( m, 'selectVariant' );
        if isempty(ok1)
            % The i.f. does not define a selectVariant callback.
            ok1 = true;
        end
        ok = ok && ok1;
        s = rmfield( s, 'variant' );
    end
    
    % Set the remaining options.
    [m.modeloptions,ok1] = setOptions( m.modeloptions, s );
    ok = ok && ok1;
end
