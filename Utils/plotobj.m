function plotobj( filename, alph )
    if nargin < 2
        alph = 1;
    end
    m = addToRawMesh( [], filename, struct() );
    cla;
    if isfield(m,'vc')
        m.vc = m.vc*alph + (1-alph);
        patch( 'Faces', m.f, 'Vertices', m.v, ...
               'FaceVertexCData', m.vc, 'FaceColor', 'interp' );
    else
        m.fc = m.fc*alph + (1-alph);
        patch( 'Faces', m.f, 'Vertices', m.v, ...
               'FaceVertexCData', m.fc, 'FaceColor', 'flat' );
    end
end
