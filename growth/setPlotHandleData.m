function setPlotHandleData( m, field, varargin )
%setGFtboxHandleType( m, field, ... )
%   Set the userdata field of m.plothandles.(field) to contain a 'type'
%   field equal to FIELD, plus all the other name/value pairs supplied.
%   Existing fields not listed in the arguments will be unaltered.

    setUserdataFields( m.plothandles.(field), 'type', field, varargin{:} );
end
