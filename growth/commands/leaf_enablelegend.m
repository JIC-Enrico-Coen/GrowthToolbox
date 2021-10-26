function m = leaf_enablelegend( m, varargin )
%m = leaf_enablelegend( m, enable )
%   Cause the legend to be drawn or not drawn.
%   When not drawn, the graphic item that holds the legend text will be
%   made invisible.
%
%   Arguments:
%       enable: A boolean specifying whether to draw the legend (default true).
%
%   Topics: Plotting.

    if isempty(m), return; end
    if nargin < 2
        enable = 1;
    elseif numel(varargin{1}) ~= 1
        complain( '%s: ''enable'' argument is expected to be a single logical or numerical value, %d values supplied.\n', ...
            mfilename(), numel(varargin{1}) );
        return;
    elseif ~islogical(varargin{1}) && ~isnumeric(varargin{1})
        complain( '%s: ''enable'' argument is expected to be logical or numerical, value of type ''%s'' supplied.\n', ...
            mfilename(), class(varargin{1}) );
        return;
    else
        if nargin > 2
            fprintf( 1, '%s: %d extra arguments ignored.\n', nargin-2 );
        end
        enable = varargin{1} ~= 0;
    end
    
    m.plotdefaults.drawlegend = enable;
    for i=1:length(m.pictures)
        h = guidata( m.pictures(i) );
        nonemptyLegend = ~isempty( get(h.legend,'String') );
        set( h.legend, 'Visible', boolchar( enable && nonemptyLegend, 'on', 'off' ) );
    end
end
