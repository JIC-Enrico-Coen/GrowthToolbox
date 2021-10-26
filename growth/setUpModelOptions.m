function [m,options] = setUpModelOptions( m, varargin )
%[m,options] = setUpModelOptions( m, varargin )
%   Arguments are in triples: field name, cell array of possible
%   values, and actual value.  If there is not a finite set of
%   possible values, use the empty cell array.
%   The cell arrays are installed in m.modeloptions, if it exists,
%   otherwise m.userdata.ranges, and the actual values are selected.  If
%   the cell array is nonempty, the actual value must occur in it, or an
%   error is thrown.  If the cell array is empty, this signifies that any
%   value is allowed.
%
%   See also: addModelOptions, setModelOptions

    m = clearModelOptions( m );
    [m,options] = addModelOptions( m, varargin{:} );
end

