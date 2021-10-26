function [m,options] = addModelOptions( m, varargin )
%[m,options] = addModelOptions( m, varargin )
%   Arguments are as for setUpModelOptions, from which this differs only in
%   not clearing any previously existing options.
%
%   See also: setUpModelOptions, setModelOptions

    if isfield( m, 'modeloptions' )
        m.modeloptions = addOptions( m.modeloptions, varargin{:} );
    else
        m.userdata.ranges = addOptions( m.userdata.ranges, varargin{:} );
    end
    options = getModelOptions( m );
end

