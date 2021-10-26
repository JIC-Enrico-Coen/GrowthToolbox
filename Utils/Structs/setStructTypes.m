function s = setStructTypes( s, varargin )
    for i=1:2:(length(varargin)-1)
        fn = varargin{i};
        ft = varargin{i+1};
        switch ft
            case 'int32'
                s.(fn) = int32( s.(fn) );
            case 'int16'
                s.(fn) = int16( s.(fn) );
            case 'int8'
                s.(fn) = int8( s.(fn) );
            case 'uint32'
                s.(fn) = uint32( s.(fn) );
            case 'uint16'
                s.(fn) = uint16( s.(fn) );
            case 'uint8'
                s.(fn) = uint8( s.(fn) );
            case 'logical'
                s.(fn) = logical( s.(fn) );
            case 'double'
                s.(fn) = double( s.(fn) );
            case 'char'
                s.(fn) = char( s.(fn) );
        end
    end
end