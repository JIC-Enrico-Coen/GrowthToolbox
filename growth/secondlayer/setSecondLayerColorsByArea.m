function m = setSecondLayerColorsByArea( m, ci )
    if ~hasNonemptySecondLayer( m )
        return;
    end
    if nargin < 2
        ci = 1:length(m.secondlayer.cellarea);
    end
    x = m.secondlayer.cellarea(ci);
    x = x - min(x);
    x = x/max(x);
    
    v = linspace( 0, 1, 6 );
    
    r = interp1(v,[0 0 0 1 1 1],x);
    g = interp1(v,[0 1 1 1 0.5 0],x);
    b = interp1(v,[1 1 0 0 0 0],x);
    m.secondlayer.cellcolor(ci,:) = [ r, g, b ];
end
