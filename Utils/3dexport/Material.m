classdef Material < matlab.mixin.Copyable
    properties
        id                  % string
        facealpha           % double in range 0...1
        facecolor           % 1x3 double in range 0...1
        edgealpha           % double in range 0...1
        edgecolor           % 1x3 double in range 0...1
    end
    
    methods (Static)
        
        function m = DefaultMaterial()
            global DEFAULT_MATERIAL;
            if isempty(DEFAULT_MATERIAL)
                DEFAULT_MATERIAL = Material( 'id', 'Material-DEFAULT' );
            end
            m = DEFAULT_MATERIAL;
        end
        
    end
        
    methods

        function m = Material( varargin )
            m.id = uniqueID( 'Material' );
            m.facealpha = 1;
            m.facecolor = [0.8 0.8 0.8];
            m.edgealpha = 1;
            m.edgecolor = [0 0 0];
            initialiseClass( m, varargin{:} );
        end
    end
end
